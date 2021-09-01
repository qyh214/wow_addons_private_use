		-------------------------------------------------
		-- Paragon Reputation 1.37 by Fail US-Ragnaros --
		-------------------------------------------------

		  --[[	  Special thanks to Ammako for
				  helping me with the vars and
				  the options.						]]--

local ADDON_NAME,ParagonReputation = ...
local PR = ParagonReputation

local COLOR_CHECK_LIST = {"BLUE","GREEN","YELLOW","ORANGE","RED"}
local COLOR_CHECK_VALUE = {{0,.5,.9,1},{0,.6,.1,1},{.9,.7,0,1},{.75,.27,0,1},{1,.25,.62,1}}
local TEXT_CHECK_LIST = {"PARAGON","EXALTED","CURRENT","VALUE","DEFICIT"}

-- [Toast] Create Base Frame
local toast = CreateFrame("FRAME","ParagonReputation_Toast",UIParent)
toast:SetPoint("TOP",UIParent,"TOP",0,-160)
toast:SetWidth(302)
toast:SetHeight(70)
toast:SetMovable(true)
toast:SetUserPlaced(false)
toast:SetClampedToScreen(true)
toast:RegisterForDrag("LeftButton")
toast:SetScript("OnDragStart",toast.StartMoving)
toast:SetScript("OnDragStop",toast.StopMovingOrSizing)
toast:Hide()

-- [Toast] Create Background Texture
toast.texture = toast:CreateTexture(nil,"BACKGROUND")
toast.texture:SetPoint("TOPLEFT",toast,"TOPLEFT",-6,4)
toast.texture:SetPoint("BOTTOMRIGHT",toast,"BOTTOMRIGHT",4,-4)
toast.texture:SetTexture("Interface\\Garrison\\GarrisonToast")
toast.texture:SetTexCoord(0,.61,.33,.48)

-- [Toast] Create Title Text
toast.title = toast:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
toast.title:SetPoint("TOPLEFT",toast,"TOPLEFT",23,-10)
toast.title:SetWidth(260)
toast.title:SetHeight(16)
toast.title:SetJustifyV("TOP")
toast.title:SetJustifyH("LEFT")

-- [Toast] Create Description Text
toast.description = toast:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
toast.description:SetPoint("TOPLEFT",toast.title,"TOPLEFT",1,-23)
toast.description:SetWidth(258)
toast.description:SetHeight(32)			
toast.description:SetJustifyV("TOP")
toast.description:SetJustifyH("LEFT")

-- [Toast] Create Reset Button
toast.reset = CreateFrame("Button",nil,toast,"OptionsButtonTemplate")
toast.reset:SetPoint("BOTTOMLEFT",toast,"BOTTOMLEFT",5,6)
toast.reset:SetWidth(146)
toast.reset:SetScript("OnClick",function()
	PR:ResetButton()
end)

-- [Toast] Create Lock Button
toast.lock = CreateFrame("Button",nil,toast,"OptionsButtonTemplate")
toast.lock:SetPoint("BOTTOMRIGHT",toast,"BOTTOMRIGHT", -5, 6)
toast.lock:SetWidth(146)
toast.lock:SetScript("OnClick",function()
	PlaySound(687,"Master")
	PR:LockButton()
end)

PR.toast = toast

-- [ADDON_LOADED] Set the AddOn on load.
local DB = {
	value = {0,.5,.9,1},
	color = "BLUE",
	text = "PARAGON",
	toast = false,
	sound = true,
	fade = 5,
	point = {"TOP","TOP",0,-160},
}
local vars = CreateFrame("FRAME")
vars:RegisterEvent("ADDON_LOADED")
vars:SetScript("OnEvent",function(self,event,name)
	if event == "ADDON_LOADED" and name == ADDON_NAME then
		self:UnregisterEvent("ADDON_LOADED")
		if ParagonReputationDB == nil then
			ParagonReputationDB = DB
		else
			for key,value in pairs(DB) do
				if ParagonReputationDB[key] == nil then
					ParagonReputationDB[key] = value
				end
			end
		end
		PR.DB = ParagonReputationDB
		PR:SetToastPosition()
		PR:CreateOptions()
		PR:HookScript()
	end
end)

-- [Toast] Set Toast Position
function ParagonReputation:SetToastPosition()
	local point,relative,x,y = unpack(PR.DB.point)
	PR.toast:ClearAllPoints()
	PR.toast:SetPoint(point,UIParent,relative,x,y)
end

-- [AddOn Options] Creata AddOn Options
function ParagonReputation:CreateOptions()	
	-- [Interface Options] Create Options
	PR.options = CreateFrame("FRAME",nil)
	PR.options.name = "Paragon Reputation"
	InterfaceOptions_AddCategory(PR.options)

	-- [Interface Options] Title
	PR.options.title = PR.options:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	PR.options.title:SetPoint("TOPLEFT",16,-16)
	PR.options.title:SetText("|cff0088eeParagon|r Reputation |cff0088eev"..GetAddOnMetadata(ADDON_NAME,"Version").."|r")

	-- [Interface Options] Title Description
	PR.options.description1 = PR.options:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	PR.options.description1:SetPoint("TOPLEFT",PR.options.title,"BOTTOMLEFT",0,-2)
	PR.options.description1:SetText(PR.L["OPTIONDESC"])
	PR.options.description1:SetJustifyH("LEFT")
	PR.options.description1:SetWidth(592)

	-- [Interface Options] Color Label
	PR.options.label1 = PR.options:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	PR.options.label1:SetPoint("TOPLEFT",PR.options.description1,"BOTTOMLEFT",0,-4)
	PR.options.label1:SetText(PR.L["LABEL001"])
	
	-- [Interface Options] Color Check
	local COLOR_CHECK_NAME = {PR.L["BLUE"],PR.L["GREEN"],PR.L["YELLOW"],PR.L["ORANGE"],PR.L["RED"]}	
	for n=1,#COLOR_CHECK_LIST do
		PR.options["color"..n] = PR:CreateCheckButton(COLOR_CHECK_LIST[n],COLOR_CHECK_NAME[n],PR.DB.color,"COLOR")
		if n == 1 then
			PR.options["color"..n]:SetPoint("TOPLEFT",PR.options.label1,"BOTTOMLEFT",-4,2)
		else
			PR.options["color"..n]:SetPoint("TOPLEFT",PR.options["color"..n-1],"BOTTOMLEFT",0,10)
		end
		_G[PR.options["color"..n]:GetName().."Text"]:SetTextColor(unpack(COLOR_CHECK_VALUE[n]))
	end

	-- [Interface Options] Text Label
	PR.options.label2 = PR.options:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	PR.options.label2:SetPoint("TOPLEFT",PR.options.label1,"TOPLEFT",210,0)
	PR.options.label2:SetText(PR.L["LABEL002"])
	
	-- [Interface Options] Text Check
	local TEXT_CHECK_NAME = {PR.L["PARAGON"].." |cffa0a0a0(0/10,000)|r",FACTION_STANDING_LABEL8.." |cffa0a0a0(0/10,000)|r","0 |cffa0a0a0(0/10,000)|r","0/10,000",PR.L["DEFICIT"]}
	for n=1,#TEXT_CHECK_LIST do
		PR.options["text"..n] = PR:CreateCheckButton(TEXT_CHECK_LIST[n],TEXT_CHECK_NAME[n],PR.DB.text,"TEXT")
		if n == 1 then
			PR.options["text"..n]:SetPoint("TOPLEFT",PR.options.label2,"BOTTOMLEFT",-4,2)
		else
			PR.options["text"..n]:SetPoint("TOPLEFT",PR.options["text"..n-1],"BOTTOMLEFT",0,10)
		end
	end
	
	-- [Interface Options] Toast Label
	PR.options.label3 = PR.options:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
	PR.options.label3:SetPoint("TOPLEFT",PR.options.label1,"BOTTOMLEFT",24,-112)
	PR.options.label3:SetText(PR.L["LABEL003"])
	
	-- [Interface Options] Toast Check
	PR.options.toast = CreateFrame("CheckButton",nil,PR.options,"ChatConfigCheckButtonTemplate")
	PR.options.toast:SetPoint("RIGHT",PR.options.label3,"LEFT",2,0)
	PR.options.toast:SetWidth(30)
	PR.options.toast:SetHeight(30)
	PR.options.toast:SetChecked(PR.DB.toast)
	PR.options.toast:SetScript("OnClick",function()
		PlaySound(687,"Master")
		PR.DB.toast = PR.options.toast:GetChecked()		
	end)
	
	-- [Interface Options] Toast Description
	PR.options.description2 = PR.options:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	PR.options.description2:SetPoint("TOPLEFT",PR.options.label3, "BOTTOMLEFT",-24,-2)
	PR.options.description2:SetText(PR.L["TOASTDESC"])
	PR.options.description2:SetJustifyH("LEFT")
	PR.options.description2:SetWidth(592)
	
	-- [Interface Options] Toast Fade Duration
	PR.options.fade1 = PR.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	PR.options.fade1:SetPoint("TOPLEFT",PR.options.description2,"BOTTOMLEFT",63,-32.5)
	PR.options.fade1:SetText(PR.DB.fade.."s")
	PR.options.fade1:SetJustifyH("CENTER")
	PR.options.fade1:SetWidth(32)

	-- [Interface Options] Toast Fade Slider
	PR.options.fade2 = CreateFrame("Slider","ParagonReputation_FadeSlider",PR.options,"OptionsSliderTemplate")
	PR.options.fade2:ClearAllPoints()
	PR.options.fade2:SetPoint("TOPLEFT",PR.options.description2,"BOTTOMLEFT",4,-18)
	PR.options.fade2:SetMinMaxValues(3,10)
	PR.options.fade2:SetValue(PR.DB.fade)
	PR.options.fade2:SetValueStep(1)
	PR.options.fade2:SetObeyStepOnDrag(true)
	PR.options.fade2:SetOrientation("HORIZONTAL")
	_G[PR.options.fade2:GetName().."Low"]:SetText("3s")
	_G[PR.options.fade2:GetName().."High"]:SetText("10s")
	_G[PR.options.fade2:GetName().."Text"]:SetText(AUCTION_DURATION)
	PR.options.fade2.last = -1
	PR.options.fade2:SetScript("OnValueChanged",function(self,value)
		if value == self.last then return end
		self.last = value
		PlaySound(687,"Master")
		PR.DB.fade = value
		PR.options.fade1:SetText(PR.options.fade2:GetValue().."s")		
	end)
	
	-- [Interface Options] Sound Check
	PR.options.sound = CreateFrame("CheckButton","ParagonReputation_CheckSound",PR.options,"ChatConfigCheckButtonTemplate")
	PR.options.sound:SetPoint("TOPLEFT",PR.options.description2,"BOTTOMLEFT",-3,-53)
	PR.options.sound:SetWidth(30)
	PR.options.sound:SetHeight(30)
	_G[PR.options.sound:GetName().."Text"]:SetText(PR.L["SOUND"])
	PR.options.sound:SetChecked(PR.DB.sound)
	PR.options.sound:SetScript("OnClick",function()
		PlaySound(687,"Master")
		PR.DB.sound = PR.options.sound:GetChecked()
	end)

	-- [Interface Options] Toggle Button
	PR.options.toggle = CreateFrame("Button",nil,PR.options,"OptionsButtonTemplate")
	PR.options.toggle:SetPoint("TOPLEFT",PR.options.description2,"BOTTOMLEFT",208,-10)
	PR.options.toggle:SetText(PR.L["ANCHOR"])
	PR.options.toggle:SetWidth(192)
	PR.options.toggle:SetScript("OnClick",function()
		if PR.toast:IsVisible() then
			PR:LockButton()
		else
			HideUIPanel(InterfaceOptionsFrame)
			HideUIPanel(GameMenuFrame)
			PR.toast:Show()
			PR.toast:SetAlpha(1)
			PR.toast:EnableMouse(true)
			PR.toast.title:SetAlpha(1)
			PR.toast.title:SetText(MOVE_FRAME)
			PR.toast.description:SetAlpha(1)
			PR.toast.description:SetText("")
			PR.toast.lock:Show()
			PR.toast.lock:SetText(LOCK)
			PR.toast.reset:Show()
			PR.toast.reset:SetText(RESET_POSITION)
		end
	end)

	-- [Interface Options] Reset Button
	PR.options.reset = CreateFrame("Button",nil,PR.options,"OptionsButtonTemplate")
	PR.options.reset:SetPoint("TOPLEFT", PR.options.description2,"BOTTOMLEFT", 208, -32)
	PR.options.reset:SetText(RESET_POSITION)
	PR.options.reset:SetWidth(192)
	PR.options.reset:SetScript("OnClick",function()
		PR:ResetButton()
	end)
end

function ParagonReputation:CreateCheckButton(name,text,db,class)
	local frame = CreateFrame("CheckButton","ParagonReputation_Check"..string.gsub(string.lower(name),"^%l",string.upper),PR.options,"ChatConfigCheckButtonTemplate")
	frame:SetSize(30,30)
	frame.class = class
	_G[frame:GetName().."Text"]:SetText(text)
	frame:SetChecked(name == db)
	frame:SetScript("OnClick",function(self)
		PR:SetCheck(self)
	end)
	return frame
end

function ParagonReputation:SetCheck(self)
	PlaySound(687,"Master")
	if self.class == "COLOR" then
		for n=1,#COLOR_CHECK_LIST do
			if self == PR.options["color"..n] then
				PR.DB.color = COLOR_CHECK_LIST[n]
				PR.DB.value = COLOR_CHECK_VALUE[n]
				self:SetChecked(true)
			else
				PR.options["color"..n]:SetChecked(false)
			end
		end
	elseif self.class == "TEXT" then
		for n=1,#TEXT_CHECK_LIST do
			if self == PR.options["text"..n] then
				PR.DB.text = TEXT_CHECK_LIST[n]
				self:SetChecked(true)
			else
				PR.options["text"..n]:SetChecked(false)
			end
		end
	end
end

function ParagonReputation:ResetButton()
	PlaySound(687,"Master")
	PR.DB.point = {"TOP","TOP",0,-160}
	PR:SetToastPosition()
end

function ParagonReputation:LockButton()
	local point,_,relative,x,y = PR.toast:GetPoint()
	PR.DB.point = {point,relative,x,y}
	InterfaceOptionsFrame_OpenToCategory("Paragon Reputation")
	InterfaceOptionsFrame_OpenToCategory("Paragon Reputation") --Done twice just because of an odd glitch on this function.
	PR.toast:Hide()
	PR.toast.reset:Hide()
	PR.toast.lock:Hide()
	PR.toast.title:SetText("")
	PR.toast.description:SetText("")
	PR.toast:EnableMouse(false)
end