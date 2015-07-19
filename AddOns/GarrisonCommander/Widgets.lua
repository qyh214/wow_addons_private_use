local me, ns = ...
ns.Configure()
local addon=addon
local _G=_G
local wipe=wipe
local format=format
local UNKNOWN=UNKNOWN
local LE_FOLLOWER_TYPE_GARRISON_6_0=LE_FOLLOWER_TYPE_GARRISON_6_0
local LE_FOLLOWER_TYPE_SHIPYARD_6_2=LE_FOLLOWER_TYPE_SHIPYARD_6_2

local module=addon:NewSubModule("Widgets") --#module
local function Constructor()
	local widget= AceGUI:Create("Label")
	widget.SetAtlas=function (atlasname)
		widget.image:SetAtlas(atlasname)
	end
	widget.OnRelease=function() widget.image:SetAtlas(nil) end
end
AceGUI:RegisterWidgetType("AtlasLabel", Constructor, 1)
--- Quick backdrop
--
local backdrop = {
	bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
	edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	tile=true,
	tileSize=16,
	edgeSize=16,
	insets={bottom=7,left=7,right=7,top=7}
}
local function addBackdrop(f,color)
	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(C[color or 'Yellow']())
end
local function GMCList()
	local Type="GCMCList"
	local Version=1
	local m={} --#GMCList
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
	function m:Show()
		self.frame:Show()
	end
	function m:Hide()
		self.frame:Hide()
		self:Release()
	end
	function m:AddButton(text,action)
		local obj=self.scroll
		local b=AceGUI:Create("Button")
		b:SetFullWidth(true)
		b:SetText(text)
		b:SetCallback("OnClick",action)
		obj:AddChild(b)
	end
	function m:AddMissionButton(mission,party,perc)
		if not self.missions[mission.missionID] then
			local obj=self.scroll
			local b=AceGUI:Create("GMCSlimMissionButton")
			b:SetMission(mission,party,perc)
			b:SetScale(0.7)
			b:SetFullWidth(true)
			self.missions[mission.missionID]=b
			obj:AddChild(b)
			b.frame.Success:Hide()
			b.frame.Failure:Hide()
			b.frame.Spinner:Show()
			b.frame.Spinner.Anim:Play()
		end

	end
	function m:AddMissionResult(missionID,success)
		local mission=self.missions[missionID]
		if mission then
			local frame=mission.frame
			frame.Spinner.Anim:Stop()
			frame.Spinner:Hide()
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
	function m:AddFollower(follower,xp,levelup)
		print(follower)
		local followerID=follower.followerID
		local followerType=follower.followerTypeID
		if follower.maxed and not levelup then
			return self:AddFollowerIcon(followerType,addon:GetFollowerTexture(followerID),
								format("%s is already at maximum xp",addon:GetFollowerData(followerID,'fullname')))
		end
		local quality=G.GetFollowerQuality(followerID) or follower.quality
		local level=G.GetFollowerLevel(followerID) or follower.level
		if levelup then
			PlaySound("UI_Garrison_CommandTable_Follower_LevelUp");
		end
		return self:AddFollowerIcon(followerType,
			addon:GetFollowerTexture(followerID,followerType),
			format("%s gained %d xp%s%s",
				addon:GetAnyData(followerType,followerID,'fullname',UNKNOWN),
				xp,
				levelup and " |cffffed1a*** Level Up ***|r ." or ".",
				format(" %d to go.",addon:GetAnyData(followerType,followerID,'levelXP')-addon:GetAnyData(followerType,followerID,'xp')))
		)
	end
	function m:AddFollowerIcon(followerType,icon,text)
		local l=self:AddIconText(icon,text)
		if followerType==LE_FOLLOWER_TYPE_SHIPYARD_6_2 then
			local left,right,top,bottom
			left=0
			right=0.6
			top=0
			bottom=0.5
			l:SetImage(icon,left,right,top,bottom)
			l:SetImageSize(36,36)
			l:SetHeight(38)
		end
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
		l:SetHeight(26)
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
			self:AddIconText(itemtexture,itemID,qt)
		else
			self:AddIconText(itemtexture,itemlink,qt)
		end
	end
	---@function [parent=#GMCList]
	local function Constructor()
		local widget=AceGUI:Create("GMCGUIContainer")
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
local function GMCGUIContainer()
	local Type="GMCGUIContainer"
	local Version=1
	local m={} --#GMCGUIContainer
	function m:Close()
		self.frame.CloseButton:Click()
	end
	function m:OnAcquire()
		self.frame:EnableMouse(true)
		self:SetTitleColor(C.Yellow())
		self.frame:SetFrameStrata("HIGH")
		self.frame:SetFrameLevel(999)
	end
	function m:SetContentWidth(x)
		self.content:SetWidth(x)
	end
	---@function [parent=#GMCGUIContainer]
	local function Constructor()
		local frame=CreateFrame("Frame",Type..(GetTime()*1000),nil,"GarrisonUITemplate")
		for _,f in pairs({frame:GetRegions()}) do
			if (f:GetObjectType()=="Texture" and f:GetAtlas()=="Garr_WoodFrameCorner") then f:Hide() end
		end
		local widget={frame=frame,missions={}}
		widget.type=Type
		widget.SetTitle=function(self,...) self.frame.TitleText:SetText(...) end
		widget.SetTitleColor=function(self,...) self.frame.TitleText:SetTextColor(...) end
		for k,v in pairs(m) do widget[k]=v end
		frame:SetScript("OnHide",function(self) self.obj:Fire('OnClose') end)
		frame.obj=widget
		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		widget.content = content
		--addBackdrop(content,'Green')
		content.obj = widget
		content:SetPoint("TOPLEFT",25,-25)
		content:SetPoint("BOTTOMRIGHT",-25,25)
		AceGUI:RegisterAsContainer(widget)
		return widget
	end
	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end
local function GMCLayer()
	local Type="GMCLayer"
	local Version=1
	local function OnRelease(self)
		wipe(self.childs)
	end
	local m={} --#GMCLayer
	function m:OnAcquire()
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("HIGH")
		self.frame:SetHeight(50)
		self.frame:SetWidth(100)
		self.frame:Show()
		self.frame:SetPoint("LEFT")
	end
	function m:Show()
		return self.frame:Show()
	end
	function m:Hide()
		self.frame:Hide()
		self:Release()
	end
	function m:SetScript(...)
		return self.frame:SetScript(...)
	end
	function m:SetParent(...)
		return self.frame:SetParent(...)
	end
	function m:PushChild(child,index)
		self.childs[index]=child
		self.scroll:AddChild(child)
	end
	function m:RemoveChild(index)
		local child=self.childs[index]
		if (child) then
			self.childs[index]=nil
			child:Hide()
			self:DoLayout()
		end
	end
	function m:ClearChildren()
		wipe(self.childs)
		self:AddScroll()
	end
	function m:AddScroll()
		if (self.scroll) then
			self:ReleaseChildren()
			self.scroll=nil
		end
		self.scroll=AceGUI:Create("ScrollFrame")
		local scroll=self.scroll
		self:AddChild(scroll)
		scroll:SetLayout("List") -- probably?
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)
		scroll:SetPoint("TOPLEFT",self.title,"BOTTOMLEFT",0,0)
		scroll:SetPoint("TOPRIGHT",self.title,"BOTTOMRIGHT",0,0)
		scroll:SetPoint("BOTTOM",self.content,"BOTTOM",0,0)
	end
	---@function [parent=#GMCLayer]
	local function Constructor()
		local frame=CreateFrame("Frame")
		local title=frame:CreateFontString(nil, "BACKGROUND", "GameFontNormalHugeBlack")
		title:SetJustifyH("CENTER")
		title:SetJustifyV("CENTER")
		title:SetPoint("TOPLEFT")
		title:SetPoint("TOPRIGHT")
		title:SetHeight(0)
		title:SetWidth(0)
		addBackdrop(frame)
		local widget={childs={}}
		widget.title=title
		widget.type=Type
		widget.SetTitle=function(self,...) self.title:SetText(...) end
		widget.SetTitleColor=function(self,...) self.title:SetTextColor(...) end
		widget.SetFormattedTitle=function(self,...) self.title:SetFormattedText(...) end
		widget.SetTitleWidth=function(self,...) self.title:SetWidth(...) end
		widget.SetTitleHeight=function(self,...) self.title:SetHeight(...) end
		widget.frame=frame
		frame.obj=widget
		for k,v in pairs(m) do widget[k]=v end
		frame:SetScript("OnHide",function(self) self.obj:Fire('OnClose') end)
		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		widget.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",title,"BOTTOMLEFT")
		content:SetPoint("BOTTOMRIGHT")
		AceGUI:RegisterAsContainer(widget)
		return widget
	end
	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end

local function GMCMissionButton()
	local Type1="GMCMissionButton"
	local Type2="GMCSlimMissionButton"
	local Version=1
	local unique=0
	local m={} --#GMCMissionButton
	function m:OnAcquire()
		local frame=self.frame
		frame.info=nil
		frame:SetHeight(self.type==Type1 and 80 or 80)
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
	function m:SetMission(mission,party,perc)
		self.frame.info=mission
		self.frame.fromFollowerPage=true
		self.frame:EnableMouse(true)
		self.frame.party=party
		if self.type==Type1 then
			addon:DrawSingleButton(false,self.frame,false,false)
			self.frame:SetScript("OnEnter",GarrisonMissionButton_OnEnter)
			self.frame:SetScript("OnLeave",ns.OnLeave)
		else
			addon:DrawSingleSlimButton(false,self.frame,false,false)
			self.frame:SetScript("OnEnter",nil)
			self.frame:SetScript("OnLeave",nil)
		end
		if self.type==Type2 then
			self.frame.Percent:SetFormattedText("%d%%",perc or party.perc)
			self.frame.Percent:SetTextColor(addon:GetDifficultyColors(perc or party.perc))
		end
	end

	local function Constructor(type)
		unique=unique+1
		local frame=CreateFrame("Button",type..unique,nil,"GarrisonMissionListButtonTemplate") --"GarrisonCommanderMissionListButtonTemplate")
		frame.Title:SetFontObject("QuestFont_Shadow_Small")
		frame.Summary:SetFontObject("QuestFont_Shadow_Small")
		frame:SetScript("OnEnter",nil)
		frame:SetScript("OnLeave",nil)
		frame:SetScript("OnClick",function(self,button) return self.obj:Fire("OnClick",self,button) end)
		frame.LocBG:SetPoint("LEFT")
		frame.MissionType:SetPoint("TOPLEFT",5,-2)
		--[[
		frame.members={}
		for i=1,3 do
			local f=CreateFrame("Button",nil,frame,"GarrisonCommanderMissionPageFollowerTemplateSmall" )
			frame.members[i]=f
			f:SetPoint("BOTTOMRIGHT",-65 -65 *i,5)
			f:SetScale(0.8)
		end
		--]]
		local widget={}
		setmetatable(widget,{__index=frame})
		widget.frame=frame
		widget.scripts={}
		frame.obj=widget
		for k,v in pairs(m) do widget[k]=v end
		return widget
	end
	---@function [parent=#GMCMissionButton]
	local function Constructor1()
		local widget=Constructor(Type1)
		widget.type=Type1
		return AceGUI:RegisterAsWidget(widget)
	end
	---@function [parent=#GMCMissionButton]
	local function Constructor2()
		local widget=Constructor(Type2)
		local frame=widget.frame
		widget.type=Type2
		local indicators=CreateFrame("Frame",nil,frame,"GarrisonCommanderIndicators")
		indicators.Percent:SetJustifyH("LEFT")
		indicators.Percent:SetJustifyV("CENTER")
		indicators:SetPoint("LEFT",70,0)
		indicators.Age:Hide()
		local spinner=CreateFrame("Frame",nil,frame,"LoadingSpinnerTemplate")
		frame.Spinner=spinner
		frame.Indicators=indicators
		frame.Percent=indicators.Percent
		frame.Failure=frame:CreateFontString()
		frame.Success=frame:CreateFontString()
		frame.Failure:SetFontObject("GameFontRedLarge")
		frame.Success:SetFontObject("GameFontGreenLarge")
		frame.Failure:SetText(FAILED)
		frame.Success:SetText(SUCCESS)
		frame.Failure:Hide()
		frame.Success:Hide()
		frame.Title:SetPoint("TOPLEFT",frame.Indicators,"TOPRIGHT",0,0)
		frame.Success:SetPoint("BOTTOMLEFT",frame.Indicators,"BOTTOMRIGHT",0,10)
		frame.Failure:SetPoint("BOTTOMLEFT",frame.Indicators,"BOTTOMRIGHT",0,10)
		frame.Spinner:SetPoint("BOTTOMLEFT",frame.Indicators,"BOTTOMRIGHT",0,-2)

		--widget.frame.MissionType:Hide()
		--widget.frame.IconBG:Hide()
		return AceGUI:RegisterAsWidget(widget)
	end
	AceGUI:RegisterWidgetType(Type1,Constructor1,Version)
	AceGUI:RegisterWidgetType(Type2,Constructor2,Version)
end
function module:OnInitialized()
	GMCGUIContainer()
	GMCLayer()
	GMCMissionButton()
	GMCList()
end
