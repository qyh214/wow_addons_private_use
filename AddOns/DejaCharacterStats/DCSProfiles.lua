local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

-- DCS, DejaView Child Panel
	DejaCharacterStatsPanel.DejaCharacterStatsProfilesPanel = CreateFrame( "Frame", "DejaCharacterStatsProfilesPanel", DejaCharacterStatsPanel);
	DejaCharacterStatsPanel.DejaCharacterStatsProfilesPanel.name = "Profiles";
		-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
	DejaCharacterStatsPanel.DejaCharacterStatsProfilesPanel.parent = DejaCharacterStatsPanel.name;
		-- Add the child to the Interface Options
	InterfaceOptions_AddCategory(DejaCharacterStatsPanel.DejaCharacterStatsProfilesPanel);
	
local dcsprofiles=CreateFrame("Frame", "DCSProfiles", DejaCharacterStatsProfilesPanel)
	dcsprofiles:SetPoint("TOPLEFT", 5, -5)
	dcsprofiles:SetScale(2.0)
	dcsprofiles:SetWidth(150)
	dcsprofiles:SetHeight(50)
	dcsprofiles:Show()

local dcsprofilesFS = dcsprofiles:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dcsprofilesFS:SetText('|cff00c0ffDejaCharacterStats - Profiles|r')
	dcsprofilesFS:SetPoint("TOPLEFT", 0, 0)
	dcsprofilesFS:SetFont("Fonts\\FRIZQT__.TTF", 10)

local dcsprofiles2FS = dcsprofiles:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dcsprofiles2FS:SetText('|cff00c0ffTop Sekret Dossiers - Unauthorized Personnel Only|r')
	dcsprofiles2FS:SetPoint("TOPLEFT", 0, -25)
	dcsprofiles2FS:SetFont("Fonts\\FRIZQT__.TTF", 6)	

local dcsprofiles3FS = dcsprofiles:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dcsprofiles3FS:SetText('|cff00c0ffCOMING SOON™ - Do NOT tell anyone!|r')
	dcsprofiles3FS:SetPoint("TOPLEFT", 0, -40)
	dcsprofiles3FS:SetFont("Fonts\\FRIZQT__.TTF", 6)

-- Dropdown New Profile

local DCSProfilesNewProfileEditBox = CreateFrame("EditBox", "DCSProfilesNewProfileEditBox", DejaCharacterStatsProfilesPanel, "InputBoxTemplate")
DCSProfilesNewProfileEditBox:ClearAllPoints()
DCSProfilesNewProfileEditBox:SetPoint("BOTTOMLEFT", DejaCharacterStatsProfilesPanel, "LEFT", 21, 99)
DCSProfilesNewProfileEditBox:Show()
DCSProfilesNewProfileEditBox:SetWidth(164)
DCSProfilesNewProfileEditBox:SetHeight(15)
DCSProfilesNewProfileEditBox:SetAutoFocus(false)
DCSProfilesNewProfileEditBox:SetText("Create a new DCS profile.")
DCSProfilesNewProfileEditBox:Show()

local DCSProfilesNewProfileEditBoxFS = DCSProfilesNewProfileEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	DCSProfilesNewProfileEditBoxFS:SetText('|cff00c0ffCreate A New Profile|r')
	DCSProfilesNewProfileEditBoxFS:SetPoint("TOPLEFT", -5, 13)
	DCSProfilesNewProfileEditBoxFS:SetFont("Fonts\\FRIZQT__.TTF", 10)

DCSProfilesNewProfileEditBox:SetScript("OnEnterPressed", function(self)
	msg = ("I have sacrificed everything. What have you given?")
	if UnitExists("PLAYERTARGET") then
		SendChatMessage(msg, "WHISPER", nil, GetUnitName("PLAYERTARGET"))
	else
		SendChatMessage(msg, "SAY", nil, GetUnitName("PLAYER"))
	end
	self:SetText("")
	self:ClearFocus()
end)
	
DCSProfilesNewProfileEditBox:SetScript("OnEscapePressed", function(self)
	self:SetText("Create a new DCS profile.")
	self:ClearFocus()
end)

-- Dropdown Existing Profiles

local DCSProfilesDropDownExistingMenu = CreateFrame("Button", "DCSProfilesDropDownExistingMenu", DejaCharacterStatsProfilesPanel, "UIDropDownMenuTemplate")
DCSProfilesDropDownExistingMenu:ClearAllPoints()
DCSProfilesDropDownExistingMenu:SetPoint("BOTTOMLEFT", DejaCharacterStatsProfilesPanel, "LEFT", 0, 14)
DCSProfilesDropDownExistingMenu:Show()
 
local DCSProfilesDropDownExistingMenuFS = DCSProfilesDropDownExistingMenu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	DCSProfilesDropDownExistingMenuFS:SetText('|cff00c0ffExisting Profiles|r')
	DCSProfilesDropDownExistingMenuFS:SetPoint("TOPLEFT", 15, 9)
	DCSProfilesDropDownExistingMenuFS:SetFont("Fonts\\FRIZQT__.TTF", 10)
	
local items = {
	"Lost Survivors",
	"Illidan",
	"Harambe",
	"Tupac",
	"Elvis",
	"Biggie",
	"Diana",
	"MJ",
}
 
local function OnClick(self)
   UIDropDownMenu_SetSelectedID(DCSProfilesDropDownExistingMenu, self:GetID())
	msg = ("You totally just Scooby-Doo'd me didn't you?")
	if UnitExists("PLAYERTARGET") then
		SendChatMessage(msg, "WHISPER", nil, GetUnitName("PLAYERTARGET"))
	else
		SendChatMessage(msg, "SAY", nil, GetUnitName("PLAYER"))
	end
end
 
local function initialize(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end
 
 
UIDropDownMenu_Initialize(DCSProfilesDropDownExistingMenu, initialize)
UIDropDownMenu_SetWidth(DCSProfilesDropDownExistingMenu, 152);
UIDropDownMenu_SetButtonWidth(DCSProfilesDropDownExistingMenu, 160)
UIDropDownMenu_SetSelectedID(DCSProfilesDropDownExistingMenu, 1)
UIDropDownMenu_JustifyText(DCSProfilesDropDownExistingMenu, "LEFT")

-- Dropdown Profile Copy

local DCSProfilesDropDownCopyMenu = CreateFrame("Button", "DCSProfilesDropDownCopyMenu", DejaCharacterStatsProfilesPanel, "UIDropDownMenuTemplate")
DCSProfilesDropDownCopyMenu:ClearAllPoints()
DCSProfilesDropDownCopyMenu:SetPoint("TOPLEFT", DejaCharacterStatsProfilesPanel, "LEFT", 0, -30)
DCSProfilesDropDownCopyMenu:Show()
 
local DCSProfilesDropDownCopyMenuFS = DCSProfilesDropDownCopyMenu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	DCSProfilesDropDownCopyMenuFS:SetText('|cff00c0ffCopy Profiles|r')
	DCSProfilesDropDownCopyMenuFS:SetPoint("TOPLEFT", 15, 9)
	DCSProfilesDropDownCopyMenuFS:SetFont("Fonts\\FRIZQT__.TTF", 10)
	
local items = {
	"Occam's razor",
	"Holmes",
	"Lecter",
	"House",
	"Hyde",
	"Jekyll",
}
 
local function OnClick(self)
	UIDropDownMenu_SetSelectedID(DCSProfilesDropDownCopyMenu, self:GetID())
	msg = ("Everybody lies.")
	if UnitExists("PLAYERTARGET") then
		SendChatMessage(msg, "WHISPER", nil, GetUnitName("PLAYERTARGET"))
	else
		SendChatMessage(msg, "SAY", nil, GetUnitName("PLAYER"))
	end
end
 
local function initialize(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end
 
 
UIDropDownMenu_Initialize(DCSProfilesDropDownCopyMenu, initialize)
UIDropDownMenu_SetWidth(DCSProfilesDropDownCopyMenu, 152);
UIDropDownMenu_SetButtonWidth(DCSProfilesDropDownCopyMenu, 160)
UIDropDownMenu_SetSelectedID(DCSProfilesDropDownCopyMenu, 1)
UIDropDownMenu_JustifyText(DCSProfilesDropDownCopyMenu, "LEFT")

-- Dropdown Profile Delete

local DCSProfilesDropDownDeleteMenu = CreateFrame("Button", "DCSProfilesDropDownDeleteMenu", DejaCharacterStatsProfilesPanel, "UIDropDownMenuTemplate")
DCSProfilesDropDownDeleteMenu:ClearAllPoints()
DCSProfilesDropDownDeleteMenu:SetPoint("TOPLEFT", DejaCharacterStatsProfilesPanel, "LEFT", 0, -107)
DCSProfilesDropDownDeleteMenu:Show()
 
local DCSProfilesDropDownDeleteMenuFS = DCSProfilesDropDownDeleteMenu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	DCSProfilesDropDownDeleteMenuFS:SetText('|cff00c0ffDelete Profiles|r')
	DCSProfilesDropDownDeleteMenuFS:SetPoint("TOPLEFT", 15, 9)
	DCSProfilesDropDownDeleteMenuFS:SetFont("Fonts\\FRIZQT__.TTF", 10)
	
local items = {
	"The truth is out there...",
	'"Aliens"',
	"Sasquatch",
	"UFO",
	"Tseric",
	"MiB",
	"MKUltra",
}
 
local function OnClick(self)
	UIDropDownMenu_SetSelectedID(DCSProfilesDropDownDeleteMenu, self:GetID())
	msg = ("IM IN UR AKOUNT SHARDING UR PURPLZ")
	if UnitExists("PLAYERTARGET") then
		SendChatMessage(msg, "WHISPER", nil, GetUnitName("PLAYERTARGET"))
	else
		SendChatMessage(msg, "SAY", nil, GetUnitName("PLAYER"))
	end
end
 
local function initialize(self, level)
   local info = UIDropDownMenu_CreateInfo()
   for k,v in pairs(items) do
      info = UIDropDownMenu_CreateInfo()
      info.text = v
      info.value = v
      info.func = OnClick
      UIDropDownMenu_AddButton(info, level)
   end
end
 
 
UIDropDownMenu_Initialize(DCSProfilesDropDownDeleteMenu, initialize)
UIDropDownMenu_SetWidth(DCSProfilesDropDownDeleteMenu, 152);
UIDropDownMenu_SetButtonWidth(DCSProfilesDropDownDeleteMenu, 160)
UIDropDownMenu_SetSelectedID(DCSProfilesDropDownDeleteMenu, 1)
UIDropDownMenu_JustifyText(DCSProfilesDropDownDeleteMenu, "LEFT")