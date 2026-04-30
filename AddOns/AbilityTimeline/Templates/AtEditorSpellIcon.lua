local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtEditorSpellIcon"
local Version = 1
local variables = {
	BackdropBorderColor = { 0.25, 0.25, 0.25, 0.9 },
	BackdropColor = { 0, 0, 0, 0.9 },
	Backdrop = {
		bgFile = nil,
		edgeFile = nil,
		tile = true,
		tileSize = 16,
		edgeSize = 1,
	},
	IconSize = {
		width = 16,
		height = 16,
	},
	Padding = { x = 2, y = 2 },
}

---@param self AtEditorSpellIcon
local function OnAcquire(self)
end

---@param self AtEditorSpellIcon
local function OnRelease(self)

end


local SetAbility = function(self, icon, text)
	self.frame.SpellIcon:SetImage(icon)
	self.frame.SpellName:SetText(text)
	self.frame.SpellIcon.frame:Show()
	self.frame.SpellName.frame:Show()
end

local function Constructor()
	local count = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", Type .. count, UIParent, "BackdropTemplate")
	frame:SetSize(variables.IconSize.width, variables.IconSize.height)

	frame.SpellIcon = AceGUI:Create("Icon")
	frame.SpellIcon:SetImageSize(variables.IconSize.width, variables.IconSize.height)
	frame.SpellIcon:SetPoint("LEFT", frame, "LEFT")
	frame.SpellName = AceGUI:Create("Label")
	frame.SpellName:SetPoint("LEFT", frame.SpellIcon.frame, "RIGHT")
	frame.SpellName:SetPoint("RIGHT", frame, "RIGHT")


	---@class AtEditorSpellIcon : AceGUIWidget
	local widget = {
		OnAcquire = OnAcquire,
		OnRelease = OnRelease,
		type = Type,
		count = count,
		frame = frame,
		SetAbility = SetAbility,
	}

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
