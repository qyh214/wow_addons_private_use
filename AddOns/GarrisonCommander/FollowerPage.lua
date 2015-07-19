local me, ns = ...
local pp=print
local _G=_G
ns.Configure()
local addon=ns.addon --#addon
local factory=addon:GetFactory()
local wipe=wipe
local pairs=pairs
local tinsert=tinsert
local coroutine=coroutine
local GetItemInfo=GetItemInfo
local GarrisonMissionFrame_SetItemRewardDetails=GarrisonMissionFrame_SetItemRewardDetails
local GetItemCount=GetItemCount
local strsplit=strsplit
local GarrisonFollower_DisplayUpgradeConfirmation=GarrisonFollower_DisplayUpgradeConfirmation
local StaticPopup_Show=StaticPopup_Show
local CONFIRM_GARRISON_FOLLOWER_UPGRADE=CONFIRM_GARRISON_FOLLOWER_UPGRADE
local GameTooltip=GameTooltip
local StaticPopupDialogs=StaticPopupDialogs
local YES=YES
local NO=NO
local GARRISON_FOLLOWER_MAX_ITEM_LEVEL=GARRISON_FOLLOWER_MAX_ITEM_LEVEL
function addon:ShowImprovements()
	local scroller=self:GetScroller("Items")
	scroller:AddRow("Follower Upgrades",C.Orange())
	for i,v in pairs(self:GetUpgrades()) do
		scroller:AddRow(i,C.Yellow())
		for itemID,_ in pairs(v) do
			local b=scroller:AddItem(itemID)
			b:SetUserData("item",itemID)
			b:SetCallback("OnEnter",function(this)
				print("Item:",this:GetUserData("item"))
				GameTooltip:SetOwner(this.frame,"ANCHOR_CURSOR")
				GameTooltip:AddLine("Reward")
				GameTooltip:SetItemByID(this:GetUserData("item"))
				GameTooltip:Show() end)
			b:SetCallback("OnLeave",function(this) GameTooltip:Hide() end)
			b:SetCallback("OnClick",function(this) print("Clicckete") end)
		end
	end
	scroller:AddRow("Item Tokens",C.Orange())
	for i,v in pairs(self:GetItems()) do
		local b=scroller:AddItem(i)
	end
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
		return addon:Popup(format(CONFIRM2,upgrade,losing,name),0,DoUpgradeFollower,true,followerID,true)
	else
		if addon:GetToggle("NOCONFIRM") then
			return G.CastSpellOnFollower(followerID);
		else
			return addon:Popup(format(CONFIRM1,upgrade,name),0,DoUpgradeFollower,true,followerID,true)
		end
	end
end
local colors={
	[1]="Yellow",
	[3]="Uncommon",
	[6]="Rare",
	[9]="Epic",
	[615]="Uncommon",
	[630]="Rare",
	[645]="Epic"
}
function addon:ShowUpgradeButtons(force)
	local gf=GMF.FollowerTab
	if (not force and not gf:IsShown()) then return end
	if (not gf.showUpgrades) then
		gf.showUpgrades=self:GetFactory():Checkbox(gf.Model,self:GetToggle("UPG"),self:GetVarInfo("UPG"))
		gf.showUpgrades:SetPoint("TOPLEFT")
		gf.showUpgrades:Show()
		gf.showUpgrades:SetScript("OnClick",function(this)
			addon:SetBoolean("UPG",this:GetChecked())
			addon:ShowUpgradeButtons()
		end)
	end
	if (not gf.noConfirm) then
		gf.noConfirm=self:GetFactory():Checkbox(gf.Model,self:GetToggle("NOCONFIRM"),self:GetVarInfo("NOCONFIRM"))
		gf.noConfirm:SetPoint("TOPLEFT",0,-20)
		gf.noConfirm:Show()
		gf.noConfirm:SetScript("OnClick",function(this)
			addon:SetBoolean("NOCONFIRM",this:GetChecked())
		end)
	end
	if not gf.upgradeButtons then gf.upgradeButtons ={} end
	--if not gf.upgradeFrame then gf.upgradeFrame=CreateFrame("Frame",nil,gf.model) end
	local b=gf.upgradeButtons
	local upgrades=self:GetUpgrades()
	local axpos=243
	local wxpos=7
	local wypos=-135
	local aypos=-135
	local used=1
	if not gf.followerID then
		return self:DelayedRefresh(0.1)
	end
	local followerID=gf.followerID
	local followerInfo = followerID and G.GetFollowerInfo(followerID);
	local overTheTop=(gf.ItemWeapon.itemLevel + gf.ItemArmor.itemLevel) ==(GARRISON_FOLLOWER_MAX_ITEM_LEVEL *2)
	if (not overTheTop and  followerInfo and followerInfo.isCollected and not followerInfo.status and followerInfo.level == GARRISON_FOLLOWER_MAX_LEVEL ) then
		for i=1,#upgrades do
			if not b[used] then
				b[used]=CreateFrame("Button",nil,gf,"GarrisonCommanderUpgradeButton,SecureActionbuttonTemplate")
			end
			local tipo,itemID,level=strsplit(":",upgrades[i])
			level=tonumber(level)
			local A=b[used]
			local qt=GetItemCount(itemID)
			repeat
			if (qt>0) then
				A:ClearAllPoints()
				A.tipo=tipo
				local currentlevel=tipo:sub(1,1)=="w" and gf.ItemWeapon.itemLevel or  gf.ItemArmor.itemLevel
				if level > 600 and level <= currentlevel then
					break -- Pointless item for this toon
				end
				if level<600 and level + currentlevel > GARRISON_FOLLOWER_MAX_ITEM_LEVEL then
					break
				end
				used=used+1
				if (tipo:sub(1,1)=="a") then
					A:SetPoint("TOPLEFT",axpos,aypos)
					aypos=aypos-45
				else
					A:SetPoint("TOPLEFT",wxpos,wypos)
					wypos=wypos-45
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
				A:SetFrameLevel(gf.Model:GetFrameLevel()+1)
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
function addon:DelayedRefresh(delay)
	if GMF.FollowerTab:IsShown() then
		if not tonumber(delay) then delay=0.5 end
		return C_Timer.After(delay,function() addon:ShowUpgradeButtons() end)
	end
end
function addon:FollowerPageStartUp()
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED","DelayedRefresh")
	self:RegisterEvent("CHAT_MSG_LOOT","DelayedRefresh")
	self:GarrisonTraitCountersFrame_OnLoad(GarrisonTraitCountersFrame, L["%s |4follower:followers with %s"])
	self:HookScript(GarrisonTraitCountersFrame,"OnEvent","GarrisonTraitCountersFrame_OnEvent")
	self:HookScript(GarrisonTraitCountersFrame,"OnShow","GarrisonTraitCountersFrame_OnShow")
end
--[[
		<Scripts>
			<OnLoad function="GarrisonTraitCountersFrame_OnLoad"/>
			<OnEvent function="GarrisonTraitCountersFrame_OnEvent"/>
			<OnShow function="GarrisonTraitCountersFrame_Update"/>
		</Scripts>
--]]

function addon:GarrisonTraitCountersFrame_OnLoad(this, tooltipString)
	print("Load")
	this:ClearAllPoints()
	this:SetParent(GarrisonThreatCountersFrame:GetParent())
	this:SetPoint("BOTTOMLEFT",185,6)
	this:Show()
	this.tooltipString = tooltipString;
	this.choice=CreateFrame('Frame',this:GetName()..tostring(GetTime()*1000),this,"UIDropDownMenuTemplate")
	this.choice.button=_G[this.choice:GetName()..'Button']
	this.choice:SetPoint("TOPLEFT",-192,0)
	addon:FillCounters(this,1)
	this.TraitsList[1]:SetScript("OnEnter",_G.GarrisonTraitCounter_OnEnter)
	--this.TraitsList[1]:SetScript("OnEnter",pp)
	do
		local frame=this.choice
		local list=G.GetRecruiterAbilityCategories()
		local function sel(this,category,index)
			UIDropDownMenu_SetSelectedID(frame,index)
			self:FillCounters(frame:GetParent(),category)
		end
		UIDropDownMenu_Initialize(frame, function(...)
			local i=0
			for v,k in pairs(list) do
				if ns.traitTable[v] then
					i=i+1
					local info=UIDropDownMenu_CreateInfo()
					info.text=k
					info.value=v
					info.func=sel
					info.arg1=v
					info.arg2=i
					UIDropDownMenu_AddButton(info,1)
				end
			end
		end)
		UIDropDownMenu_SetWidth(frame, 150);
		UIDropDownMenu_SetButtonWidth(frame, 174)
		UIDropDownMenu_SetSelectedID(frame, 1)
		UIDropDownMenu_JustifyText(frame, "LEFT")
		--EasyMenu(list,frame,frame,0,0,nil,5)
	end
	this:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end

function addon:GarrisonTraitCountersFrame_OnEvent(this, event, ...)
	if ( this:IsVisible() ) then
		self:GarrisonTraitCountersFrame_OnShow(this);
	end
end

function addon:GarrisonTraitCountersFrame_OnShow(this)
	for i = 1, #this.TraitsList do
		local t=addon:GetFollowersWithTrait(this.TraitsList[i].id)
		local n=t and #t or 0
		this.TraitsList[i].Count:SetText(n);
	end
end

---@function [parent=#addon] GarrisonTraitCounter_OnEnter
-- Need to be a global
function _G.GarrisonTraitCounter_OnEnter(this)
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetText(this:GetParent().tooltipString:format(this.Count:GetText(), this.name), nil, nil, nil, nil, true);
end
function addon:FillCounters(this,category)
	local i=0
	for id,name in pairs(ns.traitTable[category]) do
		i=i+1
		local frame = this.TraitsList[i];
		local offset=(ns.bigscreen and 22 or 17)

		if ( not frame ) then
			frame = CreateFrame("Button", nil, this, "GarrisonTraitCounterTemplate");
			frame:SetPoint("LEFT", this.TraitsList[i-1], "RIGHT", 14, 0);
			frame:SetScript("OnEnter",GarrisonTraitCounter_OnEnter)
			this.TraitsList[i] = frame;
		end
		frame.Icon:SetTexture(G.GetFollowerAbilityIcon(id))
		frame.name = name;
		frame.id = id;
		frame:Show()
	end
	self:GarrisonTraitCountersFrame_OnShow(GarrisonTraitCountersFrame)
	for j=i+1,#this.TraitsList do
		this.TraitsList[j]:Hide()
	end
end

