local pp=print
local me, ns = ...
ns.Configure()
local GetItemCount=GetItemCount
local addon=addon --#addon
local over=over --#over
local _G=_G
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
local LE_FOLLOWER_TYPE_GARRISON_7_0=LE_FOLLOWER_TYPE_GARRISON_7_0
local module=addon:NewSubClass('OrderHall') --#Module
local GameTooltip=GameTooltip
local GCS
local GHF
local GHFMissions
function module:OnInitialize(...)
	if not ns.GHF then return end -- Waiting to be late initialized by init routine
	if GetAddOnEnableState(UnitName("player"),"OrderHallCommander") > 0 then
		self:Print("Delegating hall management to OrderHallCommander")
		return
	end
	GHF=ns.GHF
	GHFMissions=ns.GHFMissions
	--GARRISON_SHIPYARD_NPC_OPEN
	--GARRISON_SHIPYARD_NPC_CLOSE
	self:SafeSecureHook("GarrisonFollowerButton_UpdateCounters")
	local ref=GHFMissions.CompleteDialog.BorderFrame.ViewButton
	local bt = CreateFrame('BUTTON','GCQuickHallMissionCompletionButton', ref, 'UIPanelButtonTemplate')
	bt.missionType=LE_FOLLOWER_TYPE_GARRISON_7_0
	bt:SetWidth(300)
	bt:SetText(L["Garrison Comander Quick Mission Completion"])
	bt:SetPoint("CENTER",0,-50)
	addon:ActivateButton(bt,"MissionComplete",L["Complete all missions without confirmation"])
	self:SafeSecureHookScript(GHF,"OnShow","Setup",true)
	self:SafeRegisterEvent("ADVENTURE_MAP_CLOSE")
	self:SafeRegisterEvent("GARRISON_MISSION_STARTED")
	--GarrisonShipyardFrameFollowersListScrollFrameButton1
	--GarrisonShipyardMapMission1
	addon:AddLabel(L["OrderHall Appearance"])
	addon:AddToggle("HALLMOVEPANEL",true,L["Unlock Panel"],L["Makes Order Hall Mission panel movable"])
	--addon:AddToggle("BIGSCREEN",true,L["Use big screen"],L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"])
	addon:AddToggle("HALLPIN",true,L["Show Garrison Commander menu"],L["Disable if you dont want the full Garrison Commander Header."])
	--addon:HallSort()
	for _,b in ipairs(GHF.MissionTab.MissionList.listScroll.buttons) do
		local scale=0.8
		local f,h,s=b.Title:GetFont()
		b.Title:SetFont(f,h*scale,s)
		local f,h,s=b.Summary:GetFont()
		b.Summary:SetFont(f,h*scale,s)
		b:RegisterForClicks("LeftButtonUp","RightButtonUp")
		b.hall=true
		addon:SafeSecureHookScript(b,"OnEnter","ScriptGarrisonMissionButton_OnEnter")
		self:SafeRawHookScript(b,"OnClick","ScriptGarrisonMissionButton_OnClick")
	end
	GHF.MissionTab.MissionList.Update=addon.HookedGarrisonMissionList_Update
	GHF.MissionTab.MissionList.SetTab=addon.HookedGarrisonMissionList_SetTab
	addon:AddLabel("Order Hall")
	addon:AddSelect("MSORTH","Garrison_SortMissions_Original",
	{
		Garrison_SortMissions_Original=L["Original method"],
		Garrison_SortMissions_Chance=L["Success Chance"],
		Garrison_SortMissions_Followers=L["Number of followers"],
		Garrison_SortMissions_Age=L["Expiration Time"],
		Garrison_SortMissions_Xp=L["Global approx. xp reward"],
		Garrison_SortMissions_Duration=L["Duration Time"],
		Garrison_SortMissions_Class=L["Reward type"],
	},
	L["Sort missions by:"],L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"])

end
function module:AddLevel(source,button,mission,missionID,bigscreen)
	button.Level:SetPoint("CENTER", button, "TOPLEFT", 40, -36);
	local quality=math.min(math.max(mission.level-UnitLevel("player")+3,0),6)
	button.Level:SetText(mission.level)
	button.Level:SetTextColor(self:GetQualityColor(quality))
	button.ItemLevel:Show();
end

function module:ScriptGarrisonMissionButton_OnClick(this,...)
	if this.info then
		addon:AddExtraData(this.info)
		local perc=addon:MatchMaker(this.info)
	end
	return addon:ScriptGarrisonMissionButton_OnClick(this,...)
end
function module:GetMain()
	return GHF
end
function module:GetMissions()
	return GHFMissions
end
function module:GetBigScreen()
	return false
end
---

function module:Setup(this,...)
--[===[@debug@
print("Doing one time initialization for",this:GetName(),...)
--@end-debug@]===]
	addon:CheckMP()
	self:SafeSecureHookScript("OrderHallMissionFrame","OnShow")
	GCS=addon:CreateHeader(self,'HALLPIN')
	GHF.FollowerStatusInfo=GHF:CreateFontString(nil, "BORDER", "GameFontNormal")
	GHF.FollowerStatusInfo:SetPoint("TOPRIGHT",-30,0)
	GHF.FollowerStatusInfo:SetHeight(25)
	GHF.FollowerStatusInfo:Show()
	self:ScriptOrderHallMissionFrame_OnShow()
	self:RefreshParties()
	self:FollowerSetup()
end
function module:ScriptOrderHallMissionFrame_OnShow()
--[===[@debug@
	print("Doing all time initialization")
	print(GetTime())
--@end-debug@]===]
	GCS:Show()
	GCS:SetWidth(GHF:GetWidth())
	GHF:ClearAllPoints()
	GHF:SetPoint("TOPLEFT",GCS,"BOTTOMLEFT",0,23)
	GHF:SetPoint("TOPRIGHT",GCS,"BOTTOMRIGHT",0,23)
	self:RefreshMenu()
	self:RefreshFollowerStatus()
--[===[@debug@
	print("Done all time initialization")
	print(GetTime())
--@end-debug@]===]
end

function addon:EventADVENTURE_MAP_CLOSE(event,...)
--[===[@debug@
print("NPC CLOSED")
--@end-debug@]===]
	if (GCS) then
		self:RemoveMenu()
		GCS:Hide()
	end
end
function addon:ApplyMSORTH(value)
	self:ApplyMSORT(value)
	self:RefreshMissions()
end

function module:EventGARRISON_MISSION_STARTED(event,missionType,missionID,...)
	--[===[@debug@
	print(event,missionID)
	--@end-debug@]===]
	self:RefreshFollowerStatus()
end
function module:RefreshParties()
	if true then
		addon:OnAllGarrisonMissions(function(missionID) addon:MatchMaker(missionID)end,false,LE_FOLLOWER_TYPE_GARRISON_7_0)
	else
		self:coroutineExecute(0.001,function()
			addon:OnAllGarrisonMissions(function(missionID) addon:MatchMaker(missionID) coroutine.yield(true) end)
			end
		)
	end
end
function module:RefreshMenu()
	if not GCS then return end  -- This could be called before header is built
	if not self.currentmenu or not self.currentmenu:IsVisible() then
		self:RemoveMenu()
		self:AddMenu()
	end
end
function module:AddMenu()
--[===[@debug@
print("Adding Menu",GCS.Menu,GHF.MissionTab:IsVisible(),GHF.FollowerTab:IsVisible())
--@end-debug@]===]
	if GCS.Menu then
		return
	end
	local menu,size

	if GHF.MissionTab:IsVisible() then
		self.currentmenu=GHF.MissionTab
		menu,size=self:CreateOptionsLayer('HALLMOVEPANEL','MSORTH')
	elseif GHF.FollowerTab:IsVisible() then
		self.currentmenu=GHF.FollowerTab
		menu,size=self:CreateOptionsLayer('HALLMOVEPANEL')
	--elseif GSF.MissionControlTab:IsVisible() then
	--	self.currentmenu=GSF.MissionControlTab
	--	menu,size=self:CreateOptionsLayer('BIGSCREEN','GCSKIPRARE','GCSKIPEPIC')
	else
		self.currentmenu=nil
		menu,size=self:CreateOptionsLayer('HALLMOVEPANEL')
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
do
	local s=setmetatable({},{__index=function(t,k) return 0 end})
	local FOLLOWER_STATUS_FORMAT=(ns.bigscreen and L["Followers status "] or "" )..
								C(AVAILABLE..':%d ','green') ..
								C(GARRISON_FOLLOWER_WORKING .. ":%d ",'cyan') ..
								C(GARRISON_FOLLOWER_ON_MISSION .. ":%d ",'red')
	function module:RefreshFollowerStatus()

		wipe(s)
		for _,followerID in self:GetHeroesIterator() do
			local status=self:GetFollowerStatus(followerID)
			s[status]=s[status]+1
		end
		if (GHF.FollowerStatusInfo) then
			GHF.FollowerStatusInfo:SetWidth(0)
			GHF.FollowerStatusInfo:SetFormattedText(
				FOLLOWER_STATUS_FORMAT,
				s[AVAILABLE],
				s[GARRISON_FOLLOWER_WORKING],
				s[GARRISON_FOLLOWER_ON_MISSION]
				)
		end
	end
	function module:GetTotFollowers(status)
		if not status then
			return s[AVAILABLE]+
				s[GARRISON_FOLLOWER_WORKING]+
				s[GARRISON_FOLLOWER_ON_MISSION]
		else
			return s[status] or 0
		end
	end
end
function module:DelayedRefresh(delay)
	if GHF.FollowerTab:IsShown() then
		if not tonumber(delay) then delay=0.5 end
		return C_Timer.After(delay,function() module:ShowUpgradeButtons() end)
	end
end
function module:FollowerSetup()
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED","DelayedRefresh")
	self:RegisterEvent("CHAT_MSG_LOOT","DelayedRefresh")
	self:ShowUpgradeButtons()
end
function module:ShowUpgradeButtons(force)
	if InCombatLockdown() then
		self:ScheduleLeaveCombatAction("ShowUpgradeButtons",force)
		return
	end
	local gf=GHF.FollowerTab
	if not self:GetBoolean("UPG") then
		if not gf.upgradeButtons then return end
		local b=gf.upgradeButtons
		for i=1,#b	 do
			b[i]:Hide()
		end
		return
	end
	if (not force and not gf:IsVisible()) then return end
	if not gf.upgradeButtons then gf.upgradeButtons ={} end
	--if not gf.upgradeFrame then gf.upgradeFrame=CreateFrame("Frame",nil,gf.model) end
	local b=gf.upgradeButtons
	local upgrades=self:GetUpgrades(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local axpos=self:GetBoolean("SWAPBUTTONS") and 7 or 243
	local wxpos=self:GetBoolean("SWAPBUTTONS") and 243 or 7
	local wypos=-85
	local aypos=-85
	local used=1
	if not gf.followerID then
		return self:DelayedRefresh(0.1)
	end
	local followerID=gf.followerID
	local followerInfo = followerID and G.GetFollowerInfo(followerID);
--	gf.ItemWeapon.itemLevel=674
--	gf.ItemArmor.itemLevel=674
	local overTheTop=false
	if (not overTheTop and  followerInfo and followerInfo.isCollected and not followerInfo.status and followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL ) then
		ClearOverrideBindings(gf)
		local binded={}
		local currentType=""
		local shown
		local reuse
		for i=#upgrades,1,-1 do
			local tipo,itemID,level=strsplit(":",upgrades[i])
			if not b[used] then
				b[used]=CreateFrame("Button","GCUPGRADES"..used,gf,"GarrisonCommanderUpgradeButton,SecureActionbuttonTemplate")
			end
			level=tonumber(level)
			local A=b[used]
			local qt=GetItemCount(itemID)
--[===[@debug@
			print(tipo,level)
--@end-debug@]===]
			repeat
				if (qt>0) then
					A:ClearAllPoints()
					A.tipo=tipo
					if tipo ~=currentType then
						shown=false
						currentType=tipo
					end
					local currentlevel=tipo:sub(1,1)=="w" and gf.ItemWeapon.itemLevel or  gf.ItemArmor.itemLevel
					if currentlevel == GARRISON_FOLLOWER_MAX_ITEM_LEVEL then
						break
					end
					if level > 600 and level <= currentlevel then
						break -- Pointless item for this toon
					end
					if level<600 and level + currentlevel > GARRISON_FOLLOWER_MAX_ITEM_LEVEL then
						if shown then
							reuse=true
						end
					end
					if (not binded[tipo]) then
						binded[tipo]=true
						local kb=GetBindingKey("GC" .. tipo:upper())
						if (kb ) then
							SetOverrideBindingClick(gf,false,kb,A:GetName())
							A.Shortcut:SetText(GetBindingText(kb,"",true))
						else
							A.Shortcut:SetText('')
						end
					else
						A.Shortcut:SetText('')
					end
					shown=true
					if reuse then
						A=b[used-1]
						reuse=false
					else
						used=used+1
						if (tipo:sub(1,1)=="a") then
							A:SetPoint("TOPLEFT",axpos,aypos)
							aypos=aypos-45
						else
							A:SetPoint("TOPLEFT",wxpos,wypos)
							wypos=wypos-45
						end
					end
					A:SetSize(40,40)
					A.Icon:SetSize(40,40)
					A.itemID=itemID
					GarrisonMissionFrame_SetItemRewardDetails(A)
					A.rawlevel=level
					A.Level:SetText(level < 600 and (currentlevel+level) or level)
					local c=colors[level]
					A.Level:SetTextColor(C[c]())
					A.Quantity:SetFormattedText("%d",qt)
					A.Quantity:SetTextColor(C.Yellow())
					if toc <70000 then
						A:SetFrameLevel(gf.Model:GetFrameLevel()+1)
					else
						A:SetFrameLevel(20)
					end
					A.Quantity:Show()
					A.Level:Show()
					A:EnableMouse(true)
					A:RegisterForClicks("LeftButtonDown")
					A:SetAttribute("type","item")
					A:SetAttribute("item",select(2,GetItemInfo(itemID)))
					A:Show()
					if tipo=="at" or tipo =="wt" then
						A.Level:Hide()
						A:SetScript("PostClick",nil)
					else
						A.Level:Show()
						A:SetScript("PostClick",UpgradeFollower)
					end
				end
			until true -- Continue dei poveri
		end
	end
	for i=used,#b do
		b[i]:Hide()
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