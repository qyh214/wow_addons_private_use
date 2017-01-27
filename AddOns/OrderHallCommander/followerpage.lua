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
local module=addon:NewSubModule('Followerpage',"AceHook-3.0","AceEvent-3.0","AceTimer-3.0")  --#Module
function addon:GetFollowerpageModule() return module end
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
local UpgradeFrame
local UpgradeButtons={}
local pool={}
--[===[@debug@
local debugInfo
--@end-debug@]===]
function module:CheckSpell()
end
function module:OnInitialized()
	UpgradeFrame=CreateFrame("Frame",nil,OHFFollowerTab)
	local u=UpgradeFrame
	u:SetPoint("TOPLEFT",OHFFollowerTab,"TOPLEFT",5,-72)
	u:SetPoint("BOTTOMLEFT",OHFFollowerTab,"BOTTOMLEFT",5,7)
	u:SetWidth(70)
	u:Show()
	--addon:SetBackdrop(u,C:Green())
	self:SecureHook("GarrisonMission_SetFollowerModel","RefreshUpgrades")
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED")
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE","GARRISON_FOLLOWER_UPGRADED")
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED","GARRISON_FOLLOWER_UPGRADED")
	UpgradeFrame:EnableMouse(true)
	--[===[@debug@
	self:RawHookScript(UpgradeFrame,"OnEnter","ShowFollowerData")
	self:RawHookScript(UpgradeFrame,"OnLeave",function() GameTooltip:Hide() end)
	debugInfo=u:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	debugInfo:SetPoint("TOPLEFT",70,20)
--@end-debug@	]===]
end
function module:ShowFollowerData(this)
	local tip=GameTooltip
	tip:SetOwner(this,"CURSOR_ANCHOR")
	tip:AddLine(me)
	OrderHallCommanderMixin.DumpData(tip,addon:GetFollowerData(OHFFollowerTab.followerID))
	tip:Show()
end
function module:GARRISON_FOLLOWER_UPGRADED(event,followerType,followerId)
	if OHFFollowerTab:IsVisible() then
		self:ScheduleTimer("RefreshUpgrades",0.3)
	end
end
		
function module:RenderUpgradeButton(id,previous)
		local qt=GetItemCount(id)
		if qt== 0 then return previous end --Not rendering empty buttons
		print("Rendering",id,"for",qt,"pieces")
		local b=self:AcquireButton()
		if previous then
			b:SetPoint("TOPLEFT",previous,"BOTTOMLEFT",0,-8)
		else
			b:SetPoint("TOPLEFT",5,-10)
		end
		previous=b
		b.itemID=id
		b:SetAttribute("item",select(2,GetItemInfo(id)))		
		GarrisonMissionFrame_SetItemRewardDetails(b)
		b.Quantity:SetFormattedText("%d",qt)
		b.Quantity:SetTextColor(C.Yellow())
		b.Quantity:Show()
		b:Show()
		return b
end 
function module:RefreshUpgrades(model,followerID,displayID,showWeapon)
--[===[@debug@
	debugInfo:SetText(followerID)
--@end-debug@]===]
	if not OHFFollowerTab:IsVisible() then return end
	if model then
		UpgradeFrame:SetFrameStrata(model:GetFrameStrata())
		UpgradeFrame:SetFrameLevel(model:GetFrameLevel()+5)
	end
	if not followerID then followerID=OHFFollowerTab.followerID end
	local follower=addon:GetFollowerData(followerID)
	for i=1,#UpgradeButtons do
		self:ReleaseButton(UpgradeButtons[i])
	end
	wipe(UpgradeButtons)
	if not follower then print("No follower for ",followerID) return end
	if follower.isTroop then return end
	if not follower.isCollected then return end
	if follower.status==GARRISON_FOLLOWER_ON_MISSION then return end
	if follower.status==GARRISON_FOLLOWER_COMBAT_ALLY then return end
	if follower.status==GARRISON_FOLLOWER_INACTIVE then return end
	local u=UpgradeFrame
	local previous
	if follower.iLevel <850 then
		for _,id in pairs(addon:GetData("Upgrades")) do
			previous=self:RenderUpgradeButton(id,previous)
		end	
	end
	if not follower.isMaxLevel or  follower.quality ~=LE_ITEM_QUALITY_EPIC then
		for _,id in pairs(addon:GetData("Xp")) do
			previous=self:RenderUpgradeButton(id,previous)
		end	
	end
	if follower.quality >=LE_ITEM_QUALITY_RARE then
		for _,id in pairs(addon:GetData("Equipment")) do
			previous=self:RenderUpgradeButton(id,previous)
		end	
	end
end
function module:AcquireButton()
	local b=tremove(pool)
	if not b then
		b=CreateFrame("Button",nil,UpgradeFrame,"OHCUpgradeButton,SecureActionbuttonTemplate")
		b:EnableMouse(true)
		b:RegisterForClicks("LeftButtonDown")
		b:SetAttribute("type","item")
		b:SetSize(40,40)
		b.Icon:SetSize(40,40)
		b:EnableMouse(true)
		b:RegisterForClicks("LeftButtonDown")	
	end		
	tinsert(UpgradeButtons,b)
	return b
end
function module:ReleaseButton(u)
	u:Hide()
	u:ClearAllPoints()
	tinsert(pool,u)
end	
local CONFIRM1=L["Upgrading to |cff00ff00%d|r"].."\n" .. CONFIRM_GARRISON_FOLLOWER_UPGRADE
local CONFIRM2=L["Upgrading to |cff00ff00%d|r"].."\n|cffffd200 "..L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"].."|r\n" .. CONFIRM_GARRISON_FOLLOWER_UPGRADE
local function DoUpgradeFollower(this)
		G.CastSpellOnFollower(this.data);
end
local function UpgradeFollower(this)
	local follower=this:GetParent()
	local followerID=follower.followerID
	local upgradelevel=this.rawlevel
	local genere=this.tipo:sub(1,1)
	local currentlevel=genere=="w" and follower.ItemWeapon.itemLevel or  follower.ItemArmor.itemLevel
	local name = ITEM_QUALITY_COLORS[G.GetFollowerQuality(followerID)].hex..G.GetFollowerName(followerID)..FONT_COLOR_CODE_CLOSE;
	local losing=false
	local upgrade=math.min(upgradelevel>600 and upgradelevel or upgradelevel+currentlevel,GARRISON_FOLLOWER_MAX_ITEM_LEVEL)
	if upgradelevel > 600 and currentlevel>600 then
		if (currentlevel > upgradelevel) then
			losing=upgradelevel - 600
		else
			losing=currentlevel -600
		end
	elseif upgrade > GARRISON_FOLLOWER_MAX_ITEM_LEVEL then
		losing=(upgrade)-GARRISON_FOLLOWER_MAX_ITEM_LEVEL
	end
	if losing then
		return module:Popup(format(CONFIRM2,upgrade,losing,name),0,DoUpgradeFollower,true,followerID,true)
	else
		if addon:GetToggle("NOCONFIRM") then
			return G.CastSpellOnFollower(followerID);
		else
			return module:Popup(format(CONFIRM1,upgrade,name),0,DoUpgradeFollower,true,followerID,true)
		end
	end
end
