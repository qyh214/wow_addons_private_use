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
local ORDER_HALL_MAC_ITEM_LEVEL=900
local module=addon:NewSubClass("FollowerPage") --#module
local UIDropDownMenu_SetSelectedID,	UIDropDownMenu_Initialize,	UIDropDownMenu_CreateInfo,UIDropDownMenu_AddButton
=UIDropDownMenu_SetSelectedID,UIDropDownMenu_Initialize,	UIDropDownMenu_CreateInfo,UIDropDownMenu_AddButton
local UIDropDownMenu_SetWidth,UIDropDownMenu_SetButtonWidth,UIDropDownMenu_JustifyText=UIDropDownMenu_SetWidth,UIDropDownMenu_SetButtonWidth,UIDropDownMenu_JustifyText
local UIDropDownMenu_SetText=UIDropDownMenu_SetText
function module:ShowImprovements()
	local scroller=self:GetScroller("Items")
	scroller:AddRow("Follower Upgrades",C.Orange())
	for i,v in pairs(self:GetUpgrades()) do
		scroller:AddRow(i,C.Yellow())
		for itemID,_ in pairs(v) do
			local b=scroller:AddItem(itemID)
			b:SetUserData("item",itemID)
			b:SetCallback("OnEnter",function(this)

--[===[@debug@
			print("Item:",this:GetUserData("item"))
--@end-debug@]===]
			GameTooltip:SetOwner(this.frame,"ANCHOR_CURSOR")
			GameTooltip:AddLine("Reward")
			GameTooltip:SetItemByID(this:GetUserData("item"))
			GameTooltip:Show() end)
			b:SetCallback("OnLeave",function(this) GameTooltip:Hide() end)
--[===[@debug@
			b:SetCallback("OnClick",function(this) print("Click") end)
--@end-debug@]===]
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
		return module:Popup(format(CONFIRM2,upgrade,losing,name),0,DoUpgradeFollower,true,followerID,true)
	else
		if addon:GetToggle("NOCONFIRM") then
			return G.CastSpellOnFollower(followerID);
		else
			return module:Popup(format(CONFIRM1,upgrade,name),0,DoUpgradeFollower,true,followerID,true)
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
function addon:ApplyUPG(value)
	module:ShowUpgradeButtons()
end
function addon:ApplySWAPBUTTONS(value)
	module:ShowUpgradeButtons()
end
function module:BindingClick(tipo,level)
	local gf=GMF.FollowerTab
	if (not gf:IsVisible() or not gf.upgradeButtons) then return end
	if (not gf.ItemWeapon:IsVisible() or not gf.ItemArmor:IsVisible()) then
		return
	end
	local current=tipo=="w" and gf.ItemWeapon.itemLevel or gf.ItemArmor.itemLevel
	for _,b in pairs(gf.upgradeButtons) do
		if b:IsVisible() then
			print(current,b.tipo,b.Level:GetText(),b.rawLevel)
			if (tipo==tipo:sub(1,1) and level==b.rawlevel) then
				b:Click()
			end
		else
			return
		end
	end
end
local upgradeButtons
function module:ShowUpgradeButtons(force)
	if InCombatLockdown() then
		self:ScheduleLeaveCombatAction("ShowUpgradeButtons",force)
		return
	end
	local gf=GMF.FollowerTab
	if not self:GetBoolean("UPG") then
		if not upgradeButtons then return end
		local b=upgradeButtons
		for i=1,#b	 do
			b[i]:Hide()
		end
		return
	end
	if (not force and not gf:IsVisible()) then return end
	if not upgradeButtons then upgradeButtons ={} end
	--if not gf.upgradeFrame then gf.upgradeFrame=CreateFrame("Frame",nil,gf.model) end
	local b=upgradeButtons
	local upgrades=self:GetUpgrades()
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
	local overTheTop=(gf.ItemWeapon.itemLevel + gf.ItemArmor.itemLevel) >=(GARRISON_FOLLOWER_MAX_ITEM_LEVEL *2)
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
					A:SetFrameLevel(20)
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
function module:DelayedRefresh(delay)
	if GMF.FollowerTab:IsShown() then
		if not tonumber(delay) then delay=0.5 end
		return C_Timer.After(delay,function() module:ShowUpgradeButtons() end)
	end
end
function module:OnInitialized()
	self:SafeSecureHookScript("GarrisonMissionFrame","OnShow","Setup")
	for catId,list in pairs (ns.traitTable) do
		for abId,_ in pairs(list) do
			ns.traitTable[catId][abId]=G.GetFollowerAbilityName(abId)
		end
	end
ns.catTable={
	[L["Environment Preference"]]=1,
	[L["Increased Rewards"]]=2,
	[L["Mission Duration"]]=3,
	[L["Mission Success"]]=4,
	[L["Other"]]=5,
	[L["Profession"]]=6,
	[L["Racial Preference"]]=7,
	[L["Slayer"]]=8,
	[L["Threat Counter"]]=9,
}

end
function module:Setup()
	self:RegisterEvent("GARRISON_FOLLOWER_UPGRADED","DelayedRefresh")
	self:RegisterEvent("CHAT_MSG_LOOT","DelayedRefresh")
--[===[@debug@
	self:GarrisonTraitCountersFrame_OnLoad(GarrisonTraitCountersFrame, L["%s |4follower:followers; with %s"] .. " (%d)")
--@end-debug@]===]
--@non-debug@
	self:GarrisonTraitCountersFrame_OnLoad(GarrisonTraitCountersFrame, L["%s |4follower:followers; with %s"])
--@end-non-debug@
	self:SafeHookScript(GarrisonTraitCountersFrame,"OnEvent","GarrisonTraitCountersFrame_OnEvent")
	self:SafeHookScript(GarrisonTraitCountersFrame,"OnShow","GarrisonTraitCountersFrame_OnShow")
	self:ShowUpgradeButtons()
end
function module:Cleanup()
	self:UnregisterAllEvents()
end
--[[
		<Scripts>
			<OnLoad function="GarrisonTraitCountersFrame_OnLoad"/>
			<OnEvent function="GarrisonTraitCountersFrame_OnEvent"/>
			<OnShow function="GarrisonTraitCountersFrame_Update"/>
		</Scripts>
--]]
local list={}
local chooser
local function sel(this,category,categoryId)
	--UIDropDownMenu_SetSelectedID(chooser,index)
	module:FillCounters(chooser:GetParent(),categoryId)
	UIDropDownMenu_SetText(chooser,category)
end
function module:GarrisonTraitCountersFrame_OnLoad(this, tooltipString)

	this:ClearAllPoints()
	this:SetParent(GarrisonThreatCountersFrame:GetParent())
	this:SetPoint("BOTTOMLEFT",185,0)
	this:Show()
	this.tooltipString = tooltipString;
	if not this.choice then
		this.choice=CreateFrame('Frame',this:GetName()..'Choice',this,"UIDropDownMenuTemplate")
		this.choice.button=_G[this.choice:GetName()..'Button']
		chooser=this.choice
		this.choice:SetPoint("TOPLEFT",-192,0)
	end
	this.TraitsList[1]:SetScript("OnEnter",_G.GarrisonTraitCounter_OnEnter)
	--this.TraitsList[1]:SetScript("OnEnter",pp)
	local startcat=""
	do
		local frame=this.choice
		if #list > 0 then wipe(list) end
		local done
		local i=0
		for k,v in kpairs(ns.catTable) do
			if not done then
				done=true
				module:FillCounters(this,v)
				startcat=k
			end
			if ns.traitTable[v] then
				i=i+1
				tinsert(list,{text=k,value=v,func=sel,arg1=k,arg2=v,notCheckable=true})
			end
		end
		done=nil
		frame.button:SetScript("OnClick",function() EasyMenu(list,frame,this,-180,-7,nil,5) end )
		--EasyMenu(list,frame,this,0,0,nil,5)
		UIDropDownMenu_SetWidth(frame, 150);
		UIDropDownMenu_SetButtonWidth(frame, 174)
		UIDropDownMenu_SetText(frame,startcat)
		UIDropDownMenu_JustifyText(frame, "LEFT")
	end
	this:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end
function module:GarrisonTraitCountersFrame_OnEvent(this, event, ...)
	if ( this:IsVisible() ) then
		self:GarrisonTraitCountersFrame_OnShow(this);
	end
end

function module:GarrisonTraitCountersFrame_OnShow(this)
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
	GameTooltip:SetText(this:GetParent().tooltipString:format(this.Count:GetText(), this.name,this.id) , nil, nil, nil, nil, true);
end
function module:FillCounters(this,category)
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
-- Binding descriptions
_G.BINDING_HEADER_GCFOLLOWER="Garrison Commander - Follower Page"

for _,v in pairs(addon:GetUpgrades()) do
	local t,_,l=strsplit(':',v)
	t=t:upper()
	l=tonumber(l)
	local keyname="BINDING_NAME_GC"..t..l
	if (l<600) then
			_G[keyname]= format(L["Add %1$d levels to %2$s"],l,(t:sub(1,1)=="W" and "weapon" or "armor"))
	else
			_G[keyname]=  format(L["Upgrade %1$s to  %2$d itemlevel"],(t:sub(1,1)=="W" and "weapon" or "armor"),l)
	end
end
_G.BINDING_NAME_GCWE=L["Applies the best weapon upgrade"]
_G.BINDING_NAME_GCAE=L["Applies the best armor upgrade"]
_G.BINDING_NAME_GCWF=L["Applies the best weapon set"]
_G.BINDING_NAME_GCAF=L["Applies the best armor set"]
_G.BINDING_NAME_GCWT=L["Uses weapon token"]
_G.BINDING_NAME_GCAT=L["Uses armor token"]
