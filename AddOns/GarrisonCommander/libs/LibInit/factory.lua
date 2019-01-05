--- Class used to build lightweight widgets for configuration options.
-- You can obtain it calling GetFactory() method.
--
-- All widgets communicate with your code via the OnChange Callback and expose a
-- SetOnChange method to set it
--
-- @classmod factory
-- @author Alar of Runetotem
-- @usage
-- local addon=LibStub("LibInit"):newAddon("example")
-- local factory=addon:GetFactory()
-- local widget=factory:Checkbox(frame,true,"Checkbox","Checkbox tooltip")
-- widget:SetOnChange(function(checked) end)
-- --You can set a custom object so you can pass a method to SetOnChange:
-- widget:SetObj(mytable)
-- widget:SetOnChange("method")

local LibStub=LibStub
local libinit,MINOR_VERSION = LibStub("LibInit")
if not libinit then return end

local GetTime=GetTime
local GameTooltip=GameTooltip
local CreateFrame=CreateFrame
local type=type
local tostring=tostring

local factory=LibStub:NewLibrary("LibInit-Factory",MINOR_VERSION) --#factory
if (not factory) then return end
factory.nonce=factory.nonce or 0
local backdrop = {
	bgFile="Interface\\TutorialFrame\\TutorialFrameBackground",
	edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	tile=true,
	tileSize=16,
	edgeSize=16,
	insets={bottom=7,left=7,right=7,top=7}
}
local function addBackdrop(f,r,g,b)
	f:SetBackdrop(backdrop)
	f:SetBackdropBorderColor(r,g,b)
end
local function truncate(fontstring,width)
	fontstring:SetHeight(fontstring:GetStringHeight())
	fontstring:SetNonSpaceWrap(false)
	fontstring:SetWidth(width)
end
local function getPoint(frame)
	local a1,f,a2,x,y=frame:GetPoint()
	f=f:GetName() or tostring(f)
	return frame:GetName() or tostring(frame),a1,f,a2,x,y,frame:GetWidth()
end

local function GetUniqueName(type)
	factory.nonce=factory.nonce+1
	return ("LibInit%s%05d"):format(type,factory.nonce)
end
local function SetScript(this,...)
	this.child:SetScript(...)
end
local function SetStep(this,value)
	this:SetObeyStepOnDrag(true)
	this:SetValueStep(value)
	this:SetStepsPerPage(1)
end
local function OnTooltip(this)
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:AddLine(this.message or "Prova" ,0,1,0)
	if type(this.tooltip)=="table" then
		for i,row in pairs(this.tooltip) do
			if (type(i)=="number") then
				GameTooltip:AddLine(row, nil, nil, nil, nil, (this.tooltipStyle or true))
			else
				GameTooltip:AddDoubleLine(i,row)
			end
		end
	else
		GameTooltip:AddLine(this.tooltip, nil, nil, nil, nil, (this.tooltipStyle or true))
	end
	GameTooltip:Show()
end
---
-- tooltip can be
-- a string == AddLine
-- a multiline strinf == Multiple AddLine
-- a vector == Multiple AddLine
-- a hash == Multiple AddDoubleLine(key,value)
local function SetUp(father,widgetType,message,tooltip,maxwidth)
	local name=GetUniqueName(widgetType,father)
	if type(message)=="table" then
		tooltip=message.desc
		maxwidth=message.maxwidth
		message=message.name
	end
	if type(tooltip)=="string" and tooltip:find("\n") then
		tooltip={strsplit("\n",tooltip)}
	end
	local frame
	if widgetType=="Button" then
		frame=CreateFrame("Button",name,father,"SecureActionButtonTemplate,GameMenuButtonTemplate")
	else
		frame= CreateFrame('Frame',nil,father)
	end
	frame:SetScript("OnEnter",tooltip and OnTooltip or nil)
	frame:SetScript("OnLeave",function() GameTooltip:Hide() end)
	frame.SetObj=function(self,obj) self.obj=obj end
	maxwidth=maxwidth or 140
	frame:SetWidth(maxwidth)
	frame.message=message
	frame.tooltip=tooltip
	frame.maxwidth=maxwidth
	frame.widgetType=widgetType
	return frame,name
end
--- Creates a slider.
--
-- @tparam frame father Parent frame to use
-- @tparam number min Minimum value
-- @tparam number max Maximum value
-- @tparam number current Actual value
-- @tparam string|table message String with description or table with .desc and .tooltip fields
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table). Can be a table for a multiline tooltip
-- @tparam[opt] number maxwidth maximum widget width
-- @treturn widget slider widget object
--
function factory:Slider(father,min,max,current,...)
	local frame,name=SetUp(father,"Slider",...)
	local sl = CreateFrame('Slider',name, frame, 'OptionsSliderTemplate')
	frame:SetHeight(50)
	--sl:SetHeight(20)
	sl:SetOrientation('HORIZONTAL')
	sl:SetMinMaxValues(min, max)
	sl:SetValue(current or -1)
	sl.SetStep=SetStep
	sl.Low=_G[name ..'Low']
	sl.Low:SetText(min)
	sl.High=_G[name .. 'High']
	sl.High:SetText(max)
	sl.Text=_G[name.. 'Text']
	frame.Text=sl.Text
	frame.Text:SetText(frame.message)
	truncate(frame.Text,frame.maxwidth)
	local h=sl.Text:GetHeight()
	sl:SetPoint("LEFT",5,0)
	sl:SetPoint("RIGHT",-5,0)
	sl.Value=sl:CreateFontString(name..'Value','ARTWORK','GameFontHighlightSmall')
	sl.Value:SetPoint("TOP",sl,"BOTTOM")
	sl.Value:SetJustifyH("CENTER")
	frame.Text:SetFontObject(GameFontNormalSmall)
	frame.SetText=function(this,value) this.Text:SetText(value) end
	frame.SetFormattedText=function(this,...) this.Text:SetFormattedText(...) end
	frame.SetTextColor=function(this,...) this.Text:SetTextColor(...) end
	if frame.tooltip then
		sl:SetScript("OnEnter",function() frame:GetScript("OnEnter")(frame) end)
	end
	frame.lastvalue=max+1 -- makes sure that first update fires
	local function OnChange(self,value) end
	function frame:SetValue(value)
		sl:SetValue(value)
	end
	function frame:SetStep(value)
		sl:SetStep(value)
	end
	function frame:OnValueChanged(value)
		if (not sl.unrounded) then
			value = math.floor(value)
		end
		if (sl.isPercent) then
			sl.Value:SetFormattedText('%d%%',value)
		else
			sl.Value:SetText(value)
		end
		if value==frame.lastvalue then return end
		frame.lastvalue=value
		OnChange(frame,value)
	end
	function frame:SetOnChange(func)
		OnChange=func
	end
	function frame:SetScript(script,value)
		if script=="OnValueChanged" then
			OnChange=value
		else
			sl:SetScript(script,value)
		end
	end
	sl:SetScript("OnValueChanged",frame.OnValueChanged)
	frame:OnValueChanged(current)
	return frame
end
--- Creates a checkbox.
--
-- @tparam frame father Parent frame to use
-- @tparam bool current Actual value
-- @tparam string|table message String with description or table with .desc and .tooltip fields
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table).Can be a table for a multiline tooltip
-- @tparam[opt] number maxwidth maximum widget width
-- @treturn widget checkbox widget object
--
function factory:Checkbox(father,current,...)
	local frame,name=SetUp(father,"Checkbox",...)
	local ck=CreateFrame("CheckButton",name,frame,"ChatConfigCheckButtonTemplate")
	frame.SetScript=SetScript
	frame.child=ck
	ck.frame=frame
	local textlen=frame.maxwidth-ck:GetWidth()-2
	ck:SetPoint('TOPLEFT')
	ck:SetScript("OnClick",function(this) this.frame:OnChange(this:GetChecked()) end)
	ck.Text=_G[name..'Text']
	ck.Text:SetText(frame.message)
	ck.Text:SetJustifyH("LEFT")
	truncate(ck.Text,textlen)
	ck:SetChecked(current)
	local r,g,b,a=ck.Text:GetTextColor()
	if current then ck.Text:SetTextColor(0,1,0,1) end
	if frame.tooltip then
		ck:SetScript("OnEnter",function() frame:GetScript("OnEnter")(frame) end)
	end
	frame:SetWidth(ck:GetWidth()+ck.Text:GetWidth()+2)
	frame:SetHeight(ck:GetHeight())
	frame:SetWidth(frame.maxwidth)
	function frame:SetValue(value)
	   ck:SetChecked(value)
	   self:OnChange(value)
	end
	function frame:OnChange(value)
		if value then
			ck.Text:SetTextColor(0,1,0,1)
		else
			ck.Text:SetTextColor(r,g,b,a)
		end
		self:CustomOnChange(value)
	end
	function frame:CustomOnChange(value) end
	function frame:SetOnChange(func) self.CustomOnChange=func end
	return frame
end
--- Creates a buttom.
--
-- @tparam frame father Parent frame to use
-- @tparam string|table message String with description or table with .desc and .tooltip fields
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table. Can be a table for a multiline tooltip
-- @tparam[opt] number maxwidth maximum widget width
-- @treturn widget button widget object
--
function factory:Button(father,...)
	local bt,name=SetUp(father,"Button",...)
	bt:SetText(bt.message)
	bt:SetWidth(bt.maxwidth)
	truncate(bt:GetFontString(),bt.maxwidth)

	function bt:SetOnChange(func)
		if type(func)=="function" then
			bt:SetScript("OnClick",func)
		elseif type(func)=="string" and bt.obj and type(bt.obj[func])=="function" then
			bt:SetScript("OnClick",function(this,...) bt.obj[func](bt.obj,this,...) end)
		else
		  error("Or func is an invalid method or you didnt set an object [" .. tostring(bt.obj)..'] ['.. tostring(func)..']')
		end
	end
	return bt
end
--- Creates a dropdown menu.
-- Create a totally new frame in order to avoid taint
-- @tparam frame father Parent frame to use
-- @tparam mixed current Initial value
-- @tparam tab list Option list
-- @tparam string|table message String with description or table with .desc and .tooltip fields
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table). Can be a table for a multiline tooltip
-- @tparam[opt] number maxwidth maximum widget width
-- @treturn widget dropdown widget object
--
	function factory:DropDown(father,current,list,...)
	local frame,name=SetUp(father,"Dropdown",...)
	frame:SetHeight(50)
	frame:SetWidth(frame.maxwidth)
	frame.SetOnChange=function() end
	local dd=MSA_DropDownMenu_Create(name, frame)
	dd:SetPoint("BOTTOMLEFT")
	dd:SetPoint("BOTTOMRIGHT")
	dd.Left=_G[name.."Left"]
	dd.Left:SetPoint("TOPLEFT",-15,17)
	dd.Middle=_G[name.."Middle"]
	dd.Middle:SetWidth(frame.maxwidth-15)
	dd.Button=_G[name.."Button"]
	dd.Right=_G[name.."Right"]
	--dd.Left:SetPoint("TOPLEFT",0,0)
	dd.Icon:SetColorTexture(0,0,1,1)
	dd.Icon:Show()
	local desc=frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	desc:SetText(frame.message)
	desc:SetPoint("TOPLEFT",5,-2)
	desc:SetPoint("TOPRIGHT",0,-2)
	desc:SetJustifyH("LEFT")
	truncate(desc,desc:GetWidth())
	local h=dd.Text:GetHeight()
	--dd:SgetPointetPoint("TOPLEFT",-15,-h)
	--dd:SetPoint("TOPRIGHT",0,-h)
	frame.SetScript=SetScript
	frame.child=dd
	if frame.tooltip then
		dd:SetScript("OnEnter",function() frame:GetScript("OnEnter")(frame) end)
	end

	dd:SetScript("OnLeave",function() GameTooltip:Hide() end)
	dd.list=list
	MSA_DropDownMenu_Initialize(dd, function(...)
		local i=0
		for k,v in pairs(dd.list) do
			i=i+1
			local info=MSA_DropDownMenu_CreateInfo()
			info.text=v
			info.value=k
			info.func=function(...) return dd:OnValueChanged(...) end
			info.arg1=i
			info.arg2=k
			--info.notCheckable=true
			MSA_DropDownMenu_AddButton(info)
		end
	end)
	MSA_DropDownMenu_SetSelectedValue(dd, current)
	MSA_DropDownMenu_JustifyText(dd, "LEFT")
	function dd:OnValueChanged(this,index,value,...)
		value=value or index
		MSA_DropDownMenu_SetSelectedID(dd,index)
		return frame:OnChange(value)
	end
	function frame:OnChange(value) end
	function frame:SetOnChange(func) frame.OnChange=func end
	return frame
end
-- These functions directly map to variables
local function ToggleSet(this,value)
	this.obj:ToggleSet(this.flag,this.tipo,value)
end
--- Quickly defines a widget for a defined configuration variable
-- All data for the widget are inferred for the variable
-- @tparam table addon The addon wich defined the variable
-- @tparam frame father Parent frame to use
-- @tparam string flag name of the variable to use
-- @tparam[opt] number maxwidth maximum widget width
function factory:Option(addon,father,flag,maxwidth)
	if not addon or not addon.GetVarInfo or not father or not flag then
		return
	end
	local info=addon:GetVarInfo(flag)
	if not info then error("factory:Option() Not existent " ..flag,2) end
	local f=father
	local w
	local tipo=info.type
	info.maxwidth=maxwidth
	if (tipo=="toggle") then
		w=self:Checkbox(f,addon:ToggleGet(flag,tipo),info)
		w:SetOnChange(ToggleSet)
	elseif( tipo=="select") then
		w=self:DropDown(f,addon:ToggleGet(flag,tipo),info.values,info)
		w:SetOnChange(ToggleSet)
	elseif (tipo=="range") then
		w=self:Slider(f,info.min,info.max,addon:ToggleGet(flag,info.type),info)
		w:SetStep(info.step)
		w:SetOnChange(ToggleSet)
	elseif (tipo=="execute") then
		w=self:Button(f,info)
		w:SetOnChange(info.func)
	end
	info.maxwidth=nil
	w.flag=flag
	w.tipo=tipo
	w.obj=addon
	return w
end
factory.Dropdown=factory.DropDown -- compatibility
libinit:_SetFactory(factory)


