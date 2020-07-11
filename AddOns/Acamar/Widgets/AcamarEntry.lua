--[[-----------------------------------------------------------------------------
Label Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "AcamarEntry", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontHighlightSmall

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	GameTooltip:Hide()
	frame.obj:Fire("OnLeave")
end

local function Label_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

-- functions of events
local function HyperLinkEnter(frame)
	--print("HyperLinkEnter TritonEntry")
	frame.obj:Fire("OnHyperlinkEnter")
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateImageAnchor(self, shouldHide)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local image = self.image
	local label = self.label
	local refLable = self.refLable
	local height

	-- fix by Triton
	local extra_height_only_with_content = 2

	label:ClearAllPoints()
	refLable:ClearAllPoints()
	image:ClearAllPoints()

	-- set reference color to total transparent
	refLable:SetTextColor(1, 1, 1, 0)
	--refLable:Hide()

	if shouldHide then
		frame:SetHeight(0)
		frame.height = 0
		frame:SetWidth(0)
		frame,width = 0
	else
		if self.imageshown then
			print("has image")
			local imagewidth = image:GetWidth()
			if (width - imagewidth) < 200 or (label:GetText() or "") == "" then
				-- image goes on top centered when less than 200 width for the text, or if there is no text
				image:SetPoint("TOP")
				label:SetPoint("TOP", image, "BOTTOM")
				label:SetPoint("LEFT")
				label:SetWidth(width)
				refLable:SetPoint("TOP", image, "BOTTOM")
				refLable:SetPoint("LEFT")
				refLable:SetWidth(width)
				height = image:GetHeight() + refLable:GetStringHeight()
			else
				-- image on the left
				image:SetPoint("TOPLEFT")
				if image:GetHeight() > label:GetStringHeight() then
					label:SetPoint("LEFT", image, "RIGHT", 4, 0)
					refLable:SetPoint("LEFT", image, "RIGHT", 4, 0)
				else
					label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)
					refLable:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)
				end
				label:SetWidth(width - imagewidth - 4)
				refLable:SetWidth(width - imagewidth - 4)
				height = max(image:GetHeight(), refLable:GetStringHeight())
			end
		else
			--print("no image")
			-- no image shown
			label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			label:SetWidth(width)
			refLable:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
			refLable:SetWidth(width)
			height = refLable:GetStringHeight()
		end

		--print("height=" .. tostring(height))
		-- avoid zero-height labels, since they can used as spacers
		if not height or height == 0 then
			height = 0
		end

		self.resizing = true
		-- print('resizing frame to ' .. tostring(height))
		if height == 0 then
			frame:SetHeight(0)
			frame.height = 0
			frame:SetWidth(0)
			frame,width = 0
		else
			height = height + extra_height_only_with_content
			frame:SetHeight(height)
			frame.height = height
		end

		self.resizing = nil
		--refLable:Hide()
	end
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetText()
		self:SetImage(nil)
		self:SetImageSize(16, 16)
		self:SetColor()
		self:SetFontObject()
		self:SetJustifyH("LEFT")
		self:SetJustifyV("TOP")

		-- reset the flag
		self.resizing = nil
		-- run the update explicitly
		UpdateImageAnchor(self, false)
	end,

	-- ["OnRelease"] = nil,

	["OnWidthSet"] = function(self, width)
		UpdateImageAnchor(self, false)
	end,

	["SetText"] = function(self, text)
		self.label:SetText(text)
		self.refLable:SetText(text)
		UpdateImageAnchor(self, false)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and g and b) then
			r, g, b = 1, 1, 1
		end
		--self.label:SetVertexColor(r, g, b)
	end,

	["SetImage"] = function(self, path, ...)
		local image = self.image
		image:SetTexture(path)

		if image:GetTexture() then
			self.imageshown = true
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		else
			self.imageshown = nil
		end
		UpdateImageAnchor(self, false)
	end,

	["SetFont"] = function(self, font, height, flags)
		self.label:SetFont(font, height, flags)
		self.refLable:SetFont(font, height, flags)
	end,

	["SetFontObject"] = function(self, font)
		self:SetFont((font or GameFontHighlightSmall):GetFont())
	end,

	["SetImageSize"] = function(self, width, height)
		self.image:SetWidth(width)
		self.image:SetHeight(height)
		UpdateImageAnchor(self, false)
	end,

	["SetJustifyH"] = function(self, justifyH)
		self.label:SetJustifyH(justifyH)
		self.refLable:SetJustifyH(justifyH)
	end,

	["SetJustifyV"] = function(self, justifyV)
		self.label:SetJustifyV(justifyV)
		self.refLable:SetJustifyV(justifyV)
	end,

	["Hide"] = function(self)
		--self.resizing = true
		UpdateImageAnchor(self, true)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		--self.resizing = true
		UpdateImageAnchor(self, false)
		self.frame:Show()
	end,

	["OnHyperlinkEnter"] = function(self)
		--self.resizing = true
		UpdateImageAnchor(self, false)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local lineHeight

	_,lineHeight,_ = GameFontNormalSmall:GetFont()

	-- print("lineHeight=" .. lineHeight)

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	
	local image = frame:CreateTexture(nil, "BACKGROUND")
	local refLable = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	local label = CreateFrame("SimpleHTML", nil, frame)

	label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	refLable:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	--frame:SetWidth(260)
	--frame:SetHeight(lineHeight)

	label:SetWidth(260)
	label:SetHeight(lineHeight)


	local Backdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
		--edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = false, 
		tileSize = 1, 
		edgeSize = 5, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	--frame:SetBackdrop(Backdrop)
	--frame:SetBackdropColor(0, 0, 1, 0.36)

	--label:SetBackdrop(Backdrop)
	--label:SetBackdropColor(1, 0, 0, 0.36)

	label:EnableMouse(true)

	label:SetScript("OnEnter", Control_OnEnter)
	label:SetScript("OnLeave", Control_OnLeave)
	label:SetScript("OnMouseDown", Label_OnClick)

	label:SetHyperlinksEnabled(true)
	label:SetScript("OnHyperlinkEnter", function(self,link)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(link)
		end)
	label:SetScript('OnHyperlinkLeave',function() 
			GameTooltip:Hide() 
		end)

	-- create widget
	local widget = {
		frame = frame,
		label = label,
		refLable = refLable,
		image = image,
		type  = Type
	}

	for method, func in pairs(methods) do
		widget[method] = func
	end

	label.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
