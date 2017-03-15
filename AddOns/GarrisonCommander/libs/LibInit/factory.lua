--- Class used to build lightweight widgets for configuration options.
-- You can obtain it calling GetFactory() method.
-- 
-- All widgets communicate with your code via the OnChange Callback and expose a
-- SetOnChange method to set it
-- 
-- @classmod factory
-- @author Alar of Runetotem
-- @release 1
-- @usage
-- local addon=LibStub("LibInit"):newAddon("example")
-- local factory=addon:GetFactory()
-- local widget=factory:Checkbox(frame,true,"Checkbox","Checkbox tooltip")
-- widget:SetOnChange(function(checked) end)

 
local factory=LibStub:NewLibrary("LibInit-Factory",1) --#factory
if (not factory) then return end
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
local nonce=0
local GetTime=GetTime
local function GetUniqueName(type,father)
	if father then 
		local name=father:GetName()
		if name then 
			type=type..name 
		else
			type=type..father:GetObjectType()
		end
	end
	nonce=nonce+1
	return type .. tostring(GetTime()*1000) ..nonce
end
local function SetScript(this,...)
	this.child:SetScript(...)
end
local function SetStep(this,value)
	this:SetObeyStepOnDrag(true)
	this:SetValueStep(value)
	this:SetStepsPerPage(1)
end
--- Creates a slider.
-- 
-- @tparam frame father Parent frame to use
-- @tparam number min Minimum value
-- @tparam number max Maximum value
-- @tparam number current Actual value
-- @tparam string|table message String with description or table with .desc and .tooltip fields 
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table) 
-- @treturn widget slider widget object
-- 
function factory:Slider(father,min,max,current,message,tooltip)
	if type(message)=="table" then
		tooltip=message.desc
		message=message.name
	end
	local name=GetUniqueName("slider",father)
	local sl = CreateFrame('Slider',name, father, 'OptionsSliderTemplate')
	sl:SetWidth(128)
	sl:SetHeight(20)
	sl:SetOrientation('HORIZONTAL')
	sl:SetMinMaxValues(min, max)
	sl:SetValue(current or -1)
	sl.SetStep=SetStep
	sl.Low=_G[name ..'Low']
	sl.Low:SetText(min)
	sl.High=_G[name .. 'High']
	sl.High:SetText(max)
	sl.Text=_G[name.. 'Text']
	sl.Text:SetText(message)
	sl.Text:SetFontObject(GameFontNormalSmall)
	sl.Value=sl:CreateFontString(name..'Value','ARTWORK','GameFontHighlightSmall')
	sl.Value:SetPoint("TOP",sl,"BOTTOM")
	sl.Value:SetJustifyH("CENTER")
	sl.SetText=function(this,value) this.Text:SetText(value) end
	sl.SetFormattedText=function(this,...) this.Text:SetFormattedText(...) end
	sl.SetTextColor=function(this,...) this.Text:SetTextColor(...) end
	sl.tooltipText=tooltip
	function sl:OnValueChanged(value)
		if (not self.unrounded) then
			value = math.floor(value)
		end
		if (self.isPercent) then
			self.Value:SetFormattedText('%d%%',value)
		else
			self.Value:SetText(value)
		end
		self:OnChange(value)
	end
	function sl:OnChange(value) end
	function sl:SetOnChange(func) self.OnChange=func end
	sl:SetScript("OnValueChanged",sl.OnValueChanged)
	sl:OnValueChanged(current)
	return sl
end
--- Creates a checkbox.
-- 
-- @tparam frame father Parent frame to use
-- @tparam bool current Actual value
-- @tparam string|table message String with description or table with .desc and .tooltip fields 
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table)
-- @treturn widget checkbox widget object
-- 
function factory:Checkbox(father,current,message,tooltip)
	if type(message)=="table" then
		tooltip=message.desc
		message=message.name
	end
	local frame=CreateFrame("Frame",nil,father)
	local name=GetUniqueName("checkbox",father)
	local ck=CreateFrame("CheckButton",name,frame,"ChatConfigCheckButtonTemplate")
	ck.OnClick=function(this)
		this.frame:OnChange(this:GetChecked())
	end		
	frame.SetScript=SetScript
	frame.child=ck
	ck.frame=frame
	ck:SetPoint('TOPLEFT')
	ck:SetScript("OnClick",ck.OnClick)
	ck.Text=_G[name..'Text']
	ck.Text:SetText(message)
	ck:SetChecked(current)
	ck.tooltip=tooltip
	frame:SetWidth(ck:GetWidth()+ck.Text:GetWidth()+2)
	frame:SetHeight(ck:GetHeight())
	function frame:OnChange(value) end
	function frame:SetOnChange(func) self.OnChange=func end
	return frame
end
--- Creates a buttom.
-- 
-- @tparam frame father Parent frame to use
-- @tparam string|table message String with description or table with .desc and .tooltip fields 
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table
-- @treturn widget button widget object
-- 
function factory:Button(father,message,tooltip)
	if type(message)=="table" then
		tooltip=message.desc
		message=message.name
	end
	local name=GetUniqueName("button",father)
	local bt=CreateFrame("Button",name,father,"SecureActionButtonTemplate,GameMenuButtonTemplate")
	bt:SetText(message)
	bt.tooltipText=tooltip
	function bt:SetOnChange(func)
		if type(func)=="function" then
			bt:SetScript("OnClick",func)
		else
			bt:SetScript("OnClick",function(this,...) this.obj[func](this.obj,this,...) end)
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
-- @tparam[opt] string tooltip Tooltip message (ignored if message is a table) 
-- @treturn widget dropdown widget object
-- 
	function factory:DropDown(father,current,list,message,tooltip)
	if type(message)=="table" then
		tooltip=message.desc
		message=message.name
	end
	local frame=CreateFrame("Frame",nil,father)
	local framename=GetUniqueName("dropdown",father)
	local dd=CreateFrame("Frame",framename,frame,"UIDropDownMenuTemplate")
	_G[framename.."Left"]:SetPoint("TOPLEFT",-15,17)
	_G[framename.."Middle"]:SetWidth(140)
	dd:SetPoint("BOTTOMLEFT")
	dd:SetPoint("BOTTOMRIGHT")
	frame.SetScript=SetScript
	frame.child=dd
	dd.frame=frame
	local desc=frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	desc:SetText(message)
	desc:SetPoint("TOPLEFT")
	desc:SetPoint("TOPRIGHT")
	frame:SetWidth(140)
	frame:SetHeight(45)		
	if (tooltip) then
		dd.tooltip=tooltip
		dd:SetScript("OnEnter",function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, (self.tooltipStyle or true));
			end
		)
	end
	dd:SetScript("OnLeave",function() GameTooltip:Hide() end)
	dd.text=dd:CreateFontString(nil,"ARTWORK","GameFontHighlight")
	function frame:SetText(...)
		self.child.text:SetText(...)
	end
	function frame:SetFormattedText(...)
		self.child.text:SetFormattedText(...)
	end
	function frame:SetTextColor(...)
		self.child.text:SetTextColor(...)
	end
	dd.list=list
	local name=tostring(GetTime()*1000) ..nonce
	--dd.dropdown=CreateFrame('Frame',name,father,"UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dd, function(...)
		local i=0
		for k,v in pairs(dd.list) do
			i=i+1
			local info=UIDropDownMenu_CreateInfo()
			info.text=v
			info.value=k
			info.func=function(...) return dd:OnValueChanged(...) end
			info.arg1=i
			info.arg2=k
			--info.notCheckable=true
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(dd, current)
	UIDropDownMenu_JustifyText(dd, "LEFT")
	function dd:OnValueChanged(this,index,value,...)
		value=value or index
		UIDropDownMenu_SetSelectedID(dd,index)
		return self.frame:OnChange(value)
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
function factory:Option(addon,father,flag)
	if not addon or not addon.GetVarInfo or not father or not flag then
		return		
	end
	local info=addon:GetVarInfo(flag)
	if not info then error("factory:Option() Not existent " ..flag,2) end
	local f=father
	local w
	local tipo=info.type
	if (tipo=="toggle") then
		w=self:Checkbox(f,addon:ToggleGet(flag,tipo),info)
		w:SetOnChange(ToggleSet)
	elseif( tipo=="select") then
		w=self:DropDown(f,addon:ToggleGet(flag,tipo),info.values,info)			
		w:SetOnChange(ToggleSet)
	elseif (tipo=="range") then
		w=self:Slider(f,info.min,info.max,addon:ToggleGet(flag,info.type),info)
		w:SetOnChange(ToggleSet)
	elseif (tipo=="execute") then
		w=self:Button(f,info)
		w:SetOnChange(info.func)
	end
	w.flag=flag
	w.tipo=tipo
	w.obj=addon
	return w		
end
factory.Dropdown=factory.DropDown -- compatibility


