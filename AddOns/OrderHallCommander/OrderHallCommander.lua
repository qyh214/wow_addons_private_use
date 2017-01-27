local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file, must be 1
local function pp(...) print(GetTime(),"|cff009900",__FILE__:sub(-15),strjoin(",",tostringall(...)),"|r") end
--*TYPE addon
--*CONFIG noswitch=false,profile=true,enhancedProfile=true
--*MIXINS "AceHook-3.0","AceEvent-3.0","AceTimer-3.0"
--*MINOR 35
-- Generated on 20/01/2017 08:15:04
local me,ns=...
local LibInit,minor=LibStub("LibInit",true)
assert(LibInit,me .. ": Missing LibInit, please reinstall")
assert(minor>=35,me ..': Need at least Libinit version 35')
local addon=LibInit:NewAddon(ns,me,{noswitch=false,profile=true,enhancedProfile=true},"AceHook-3.0","AceEvent-3.0","AceTimer-3.0") --#Addon
-- Template
local G=C_Garrison
local _
local AceGUI=LibStub("AceGUI-3.0")
local C=addon:GetColorTable()
local L=addon:GetLocale()
local new=addon.NewTable
local del=addon.DelTable
local kpairs=addon:GetKpairs()
--local empty=addon:GetEmpty()
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
local dprint=print
local ddump
--[===[@debug@
LoadAddOn("Blizzard_DebugTools")
ddump=DevTools_Dump
LoadAddOn("LibDebug")
-- Addon Build, we need to create globals the easy way
local function encapsulate()
if LibDebug then LibDebug() dprint=print end
end
encapsulate()
local pcall=pcall
local function parse(default,rc,...)
	if rc then return default else return ... end
end
addon.safeG=setmetatable({},{
	__index=function(table,key)
		rawset(table,key,
			function(default,...)
				return parse(default,pcall(G[key],...))
			end
		) 
		return table[key]
	end
})

--@end-debug@]===]
--@non-debug@
dprint=function() end
ddump=function() end
local print=function() end
--@end-non-debug@

-- End Template - DO NOT MODIFY ANYTHING BEFORE THIS LINE
--*BEGIN
local MISSING=ITEM_MISSING:format('|cff'..C.Red.c)..'|r'
local ctr=0
-- Sometimes matchmakimng starts before these are defined, so I put here a sensible default (actually, this values are constans)
addon.MAXLEVEL=110
addon.MAXQUALITY=4
addon.MAXQLEVEL=addon.MAXLEVEL+addon.MAXQUALITY
function addon.resolve(frame) 
	local name
	if type(frame)=="table" and frame.GetName then
		name=frame:GetName()
		if not name then
			local parent=frame:GetParent()
			if not parent then return "UIParent" end
			for k,v in pairs(parent) do
				if v==frame then
					name=resolve(parent) .. '.'..k
					return name
				end
			end
		else
			return name
		end
		_G['UNK_'..ctr]=frame
		return 'UNK_'..ctr
	end
	return "unk"
end
function addon.colors(c1,c2)
	return C[c1].r,C[c1].g,C[c1].b,C[c2].r,C[c2].g,C[c2].b
end
function addon:ColorFromBias(followerBias)
		if ( followerBias == -1 ) then
			--return 1, 0.1, 0.1
			return C:Red()
		elseif ( followerBias < 0 ) then
			--return 1, 0.5, 0.25
			return C:Orange()
		else
			--return 1, 1, 1
			return C:Green()
		end
end
local colors=addon.colors
_G.OrderHallCommanderMixin={}
_G.OrderHallCommanderMixinThreats={}
_G.OrderHallCommanderMixinFollowerIcon={} 
_G.OrderHallCommanderMixinMenu={}
local Mixin=OrderHallCommanderMixin --#Mixin
local MixinThreats=OrderHallCommanderMixinThreats --#MixinThreats
local MixinMenu=OrderHallCommanderMixinMenu --#MixinMenu
local MixinFollowerIcon= OrderHallCommanderMixinFollowerIcon --#MixinFollowerIcon

function Mixin:CounterTooltip()
	local tip=self:AnchorTT()
	tip:AddLine(self.Ability)
	tip:AddLine(self.Description)
	tip:Show()
	
end
function Mixin:DebugOnLoad()
	self:RegisterForDrag("LeftButton")
end
function Mixin:Bump(tipo,value)
	value = value or 1
	local riga=tipo..'Refresh'
	self[tipo]=self[tipo]+value
	self[riga]:SetFormattedText("%s: %d",tipo,self[tipo])
end
function Mixin:Set(tipo,value)
	value = value or 0
	local riga=tipo..'Refresh'
	self[tipo]=value
	self[riga]:SetFormattedText("%s: %d",tipo,self[tipo])
end
function Mixin:DragStart()
	self:StartMoving()
end
function Mixin:DragStop()
	self:StopMovingOrSizing()
end
function Mixin:AnchorTT(anchor)
	anchor=anchor or "ANCHOR_TOPRIGHT"
	GameTooltip:SetOwner(self,anchor)
	return GameTooltip
end
function Mixin:ShowTT()
	if not self.tooltip then return end
	local tip=Mixin.AnchorTT(self)
	tip:SetText(self.tooltip)
	tip:Show()
end
function Mixin:HideTT()
	GameTooltip:Hide()
end
function Mixin:Dump(data)
	local	tip=self:AnchorTT("ANCHOR_CURSOR")
	if type(data)~="table" then
		data=self
	end
	tip:AddLine(data:GetName(),C:Green())
	self.DumpData(tip,data)
	tip:Show()
end
function Mixin.DumpData(tip,data)
	for k,v in kpairs(data) do
		local color="Silver"
		if type(v)=="number" then color="Cyan" 
		elseif type(v)=="string" then color="Yellow" v=v:sub(1,30)
		elseif type(v)=="boolean" then v=v and 'True' or 'False' color="White" 
		elseif type(v)=="table" then color="Green" if v.GetObjectType then v=v:GetObjectType() else v=tostring(v) end
		else v=type(v) color="Blue"
		end
		if k=="description" then v =v:sub(1,10) end
		tip:AddDoubleLine(k,v,colors("Orange",color))
	end
end
local threatPool
function Mixin:ThreatsOnLoad()
	if not threatPool then threatPool=CreateFramePool("Frame",UIParent,"OHCThreatsCounters") end
	self.usedPool={}
end

function MixinThreats:AddIconsAndCost(mechanics,biases,cost,color,notEnoughResources)
	local icons=OHF.abilityCountersForMechanicTypes
	if not icons then
		--[===[@debug@
		print("Empty icons")
		--@end-debug@ ]===]
		return false 
	end
	for i=1,#self.usedPool do
		threatPool:Release(self.usedPool[i])
	end
	self.mechanics=mechanics
	wipe(self.usedPool)
	local previous
	for index,mechanic in pairs(mechanics) do
		local th=threatPool:Acquire()
		tinsert(self.usedPool,th)
		th.Icon:SetTexture(icons[mechanic.id].icon)
		th.Name=mechanic.name
		th.Description=mechanic.description
		th.Ability=mechanic.ability.name
		th:SetParent(self)
		th:SetFrameStrata(self:GetFrameStrata())
		th:SetFrameLevel(self:GetFrameLevel()+1)
		if not previous then
			th:SetPoint("BOTTOMLEFT",0,0)
			previous=th
		else
			th:SetPoint("BOTTOMLEFT",previous,"BOTTOMRIGHT",5,0)
			previous=th
		end
		th.Border:SetVertexColor(addon:ColorFromBias(biases[mechanic] or mechanic.bias))
		th:Show()
	end
	if cost >=0 then
		self.Cost:Show()
		self.Cost:SetFormattedText(addon.resourceFormat,cost)
		self.Cost:SetTextColor(C[color]())
		self.Cost:ClearAllPoints()
		self.Cost:SetPoint("BOTTOMLEFT",previous,"BOTTOMRIGHT",5,0)
		self.HighCost:SetTextColor(C.Orange())
		self.HighCost:ClearAllPoints()
		self.HighCost:SetPoint("BOTTOMLEFT",previous,"BOTTOMRIGHT",5,0)
		if notEnoughResources then
			self.HighCost:Show()
		else
			self.HighCost:Hide()
		end
	else
		self.Cost:Hide()
		self.HighCost:Hide()
	end
	return true
end

function MixinFollowerIcon:SetFollower(followerID,checkStatus)
	local info=addon:GetFollowerData(followerID)
	if not info or not info.followerID then
		local rc
		rc,info=pcall(G.GetFollowerInfo,followerID)
		if not rc or not info then 	
			return self:SetEmpty(LFG_LIST_APP_TIMED_OUT)
		end
	end
	self.followerID=followerID
	self:SetupPortrait(info)
	local status=(followerID and checkStatus) and G.GetFollowerStatus(followerID) or nil
	if status then 
		self:SetILevel(0) --CHAT_FLAG_DND
		self.Level:SetText(status);		
		self.Portrait:SetDesaturated(true)
		self:SetQuality(1)
		self:GetParent():SetNotReady(true)
	else
		self.Portrait:SetDesaturated(false)
		if info.isMaxLevel then
			self:SetILevel(info.iLevel)
		else
			self:SetLevel(info.level)
		end
	end
end
function MixinFollowerIcon:SetEmpty(message)
	self.followerID=false
	self:SetLevel(message or MISSING)
	self:SetPortraitIcon()
	self:SetQuality(1)
	self:GetParent():SetNotReady(true)
end
function MixinFollowerIcon:ShowTooltip()
	if not self.followerID then
--[===[@debug@
		return self:Dump()
--@end-debug@]===]
--@non-debug@
		return
--@end-non-debug@	
	end
	local link = C_Garrison.GetFollowerLink(self.followerID);
	if link then
		local levelXP=G.GetFollowerLevelXP(self.followerID)
		local xp=G.GetFollowerXP(self.followerID)
		GarrisonFollowerTooltip:ClearAllPoints()
		GarrisonFollowerTooltip:SetPoint("BOTTOM", self, "TOP")
		local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = strsplit(":", link)
		GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), true, tonumber(quality), tonumber(level), xp,levelXP,  tonumber(itemLevel), tonumber(spec1), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4))
		if not GarrisonFollowerTooltip.Status then 		
			GarrisonFollowerTooltip.Status=GarrisonFollowerTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			GarrisonFollowerTooltip.Status:SetPoint("BOTTOM",0,5)
		end
		local status=G.GetFollowerStatus(self.followerID)
		if status then
			GarrisonFollowerTooltip.Status:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE.. ': ' .. status)
			GarrisonFollowerTooltip.Status:SetTextColor(C:Orange())
			GarrisonFollowerTooltip.Status:Show()
			GarrisonFollowerTooltip:SetHeight(GarrisonFollowerTooltip:GetHeight()+10)
		else
			GarrisonFollowerTooltip.Status:Hide()
		end
	end
end
function MixinFollowerIcon:HideTooltip()
	GarrisonFollowerTooltip:Hide()
end
function Mixin:MembersOnLoad()
	for i=1,3 do
		if self.Champions[i] then
			self.Champions[1]:SetPoint("RIGHT")
		else
			self.Champions[i]=CreateFrame("Frame",nil,self,"OHCFollowerIcon")
			self.Champions[i]:SetPoint("RIGHT",self.Champions[i-1],"LEFT",-15,0)
		end
		self.Champions[i]:SetFrameLevel(self:GetFrameLevel()+1)
		self.Champions[i]:Show()
		self.Champions[i]:SetEmpty()
	end
	self:SetWidth(self.Champions[1]:GetWidth()*3+30)
	self.NotReady.Text:SetFormattedText(RAID_MEMBER_NOT_READY,STATUS_TEXT_PARTY)
	self.NotReady.Text:SetTextColor(C.Orange())
end
function Mixin:MembersOnShow()
	self:SetNotReady()
end
function Mixin:SetNotReady(show)
	if show then
		self.NotReady:Show()
	else
		self.NotReady:Hide()
	end
end
function MixinMenu:OnLoad()
	self.Top:SetAtlas("_StoneFrameTile-Top", true);
	self.Bottom:SetAtlas("_StoneFrameTile-Bottom", true);
	self.Left:SetAtlas("!StoneFrameTile-Left", true);
	self.Right:SetAtlas("!StoneFrameTile-Left", true);
	self.GarrCorners.TopLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.TopRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomLeftGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.GarrCorners.BottomRightGarrCorner:SetAtlas("StoneFrameCorner-TopLeft", true);
	self.CloseButton:SetScript("OnClick",function() MixinMenu.OnClick(self) end)
end	
if not addon.GetEmpty then -- Will be moved into LibInit
--[===[@debug@
	print("Used internal GetEmpty")
--@end-debug@]===]
	local type=type
	local function empty(obj)
		if not obj then return true end -- Simplest case, obj evaluates to false in boolean context
		local t=type(obj)
		if t=="number" then
			return obj==0
		elseif t=="bool" then
			return true
		elseif t=="string" then
			return obj=='' or obj==tostring(nil)
		elseif t=="table" then
			return not next(obj)
		end
		return false -- Userdata and threads can never be empty
	end
	function addon:GetEmpty()
		return empty
	end
end

