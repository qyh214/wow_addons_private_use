local varFrame = CreateFrame("frame", nil, UIParent)
varFrame:RegisterEvent("ADDON_LOADED")
varFrame:SetScript("OnEvent", function(self, event, arg1)
if event == "ADDON_LOADED" and arg1 == "RightClickModifier" then
varFrame:UnregisterEvent("ADDON_LOADED")

----------

local default =
{
	rcmri = false,
	rcmdi = true,
	rcmro = true,
	rcmdo = true,
	rcmtf = .2,
}

local index =
{
	[1] = "rcmri",
	[2] = "rcmdi",
	[3] = "rcmro",
	[4] = "rcmdo",
	[5] = "rcmtf",
}

if RCM_SavedVariables == nil then
	RCM_SavedVariables = default
else
	for key, value in pairs(default) do
		if RCM_SavedVariables[key] == nil then
			RCM_SavedVariables[key] = value
		end
	end
end

RCM = {}
RCM.panel = CreateFrame("Frame", "RCM_Panel", UIParent)
RCM.panel.name = "Right Click Modifier"
local category = Settings.RegisterCanvasLayoutCategory(RCM.panel, "Right Click Modifier")
Settings.RegisterAddOnCategory(category)
RCM.panel.categoryID = category:GetID() 

local buttonList = {}

function createCheckButton(i, x, y)
	local list = 
	{
		" Disable right click targeting in combat",
		" Disable double click targeting in combat",
		" Disable right click targeting out of combat",
		" Disable double click targeting out of combat",
	}
	local checkButton = CreateFrame("CheckButton", "RCM_CheckButton" .. i, RCM.panel, "UICheckButtonTemplate")
	buttonList[i] = checkButton
	checkButton:ClearAllPoints()
	checkButton:SetPoint("TOPLEFT", x * 32, y * -32)
	checkButton:SetSize(32, 32)
	_G[checkButton:GetName() .. "Text"]:SetText(list[i])
	_G[checkButton:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
	buttonList[i]:SetScript("OnClick", function()
		if buttonList[i]:GetChecked() then
			RCM_SavedVariables[index[i]] = false
		else
			RCM_SavedVariables[index[i]] = true
		end
		setupButtons()
	end)
end

createCheckButton(1, 1, 1)
createCheckButton(2, 2, 2)
createCheckButton(3, 1, 4)
createCheckButton(4, 2, 5)

function setupButtons(i)
	for i = 1, 4 do
		if i % 2 == 1 then
			if RCM_SavedVariables[index[i]] then
				buttonList[i]:SetChecked(false)
				buttonList[i + 1]:SetAlpha(.5)
				buttonList[i + 1]:Disable()
			else
				buttonList[i]:SetChecked(true)
				buttonList[i + 1]:SetAlpha(1)
				buttonList[i + 1]:Enable()
			end
		else
			if RCM_SavedVariables[index[i]] then
				buttonList[i]:SetChecked(false)
			else
				buttonList[i]:SetChecked(true)
			end
		end
	end
end

function createSlider()
	local slider = CreateFrame("Slider", "RCM_Slider", RCM.panel, "OptionsSliderTemplate")
	slider:ClearAllPoints()
	slider:SetPoint("TOPLEFT", 32, -240)
	slider:SetSize(256,16)
	slider:SetMinMaxValues(.1, .5)
	slider:SetValueStep(.01)
	_G[slider:GetName() .. "Low"]:SetText("|c00ffcc00Min:|r 0.1")
	_G[slider:GetName() .. "High"]:SetText("|c00ffcc00Max:|r 0.5")
	slider:SetScript("OnValueChanged", function(self, event, arg1)
		local value = floor(slider:GetValue() * 100 + .5) / 100
		RCM_SavedVariables[index[5]] = value
		_G[slider:GetName() .. "Text"]:SetText("|c00ffcc00Double click time frame:|r " .. value)
		_G[slider:GetName() .. "Text"]:SetFont(GameFontNormal:GetFont(), 14, "NONE")
		setupSlider()
	end)
end

createSlider()

function setupSlider()
	RCM_Slider:SetValue(RCM_SavedVariables[index[5]])
end

SLASH_RCM1 = '/rcm'
function SlashCmdList.RCM(msg, editbox)
	if msg == "" then
		Settings.OpenToCategory(RCM.panel.categoryID)
	end
end

local x, y = 0, GetTime

function stopClick()
	x = y()
	MouselookStop()
end

WorldFrame:HookScript("OnMouseUp", function(self, button)
	if button == "RightButton" and not IsMouseButtonDown('RightButton') then
		if UnitAffectingCombat("player") then
			if not RCM_SavedVariables[index[1]] then
				if RCM_SavedVariables[index[2]] then
					if RCM_SavedVariables[index[5]] + x < y() then
						stopClick()
					end
				else
					stopClick()
				end
			end
		else
			if not RCM_SavedVariables[index[3]] then
				if RCM_SavedVariables[index[4]] then
					if RCM_SavedVariables[index[5]] + x < y() then
						stopClick()
					end
				else
					stopClick()
				end
			end
		end
	end
end)

local func1 = CreateFrame("Frame")
func1:RegisterEvent("ADDON_LOADED")
func1:SetScript("OnEvent", setupButtons)

local func2 = CreateFrame("Frame")
func2:RegisterEvent("ADDON_LOADED")
func2:SetScript("OnEvent", setupSlider)

----------

end
end)