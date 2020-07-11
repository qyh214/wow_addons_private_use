--[[-----------------------------------------------------------------------------
Button Widget
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "AcamarSimpleHTML", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function OnAcquire(self)
	self:SetText("")
end
local function OnRelease(self)
	self.frame:ClearAllPoints()
	self.frame:Hide()
end
local function SetText(self, text)
	self.frame:SetText(text or "")
end
local function SetWidth(self, w)
	self.frame:SetWidth(w)
end
local function SetHeight(self, w)
	self.frame:SetHeight(w)
end
local function SetFont(self, font, size)
	self.frame:SetFont(font, size)
end
local function Constructor()
	local frame = CreateFrame("SimpleHTML",nil,UIParent)
	frame:SetScript('OnHyperlinkEnter',function(self,link)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
	end)
	frame:SetScript('OnHyperlinkLeave',function() GameTooltip:Hide() end)
	local self = {}
	self.type = Type
	self.OnRelease = OnRelease
	self.OnAcquire = OnAcquire
	self.SetText = SetText
	self.SetWidth = SetWidth
	self.SetHeight = SetHeight
	self.SetFont = SetFont
	self.frame = frame
	frame.obj = self
	frame:SetHeight(18)
	frame:SetWidth(200)
	--frame:SetFontObject(GameFontHighlightSmall)
	AceGUI:RegisterAsWidget(self)
	return self
end
AceGUI:RegisterWidgetType(Type,Constructor,Version)