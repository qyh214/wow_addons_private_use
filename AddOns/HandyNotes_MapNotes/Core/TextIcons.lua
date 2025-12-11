local fmt = string.format

TextIcon = {}
TextIcon.__index = TextIcon

function TextIcon.new(cls, iconfile)
	local self = setmetatable({}, cls)
	self.IconFile = iconfile or ""
	self.SizeOne, self.SizeTwo = 0, nil
	self.OffsetX, self.OffsetY = 0, 0
	return self
end

function TextIcon:GetIconStringInner()
	local path = self.IconFile or ""
	local w = tonumber(self.SizeOne) or 0
	local h = (self.SizeTwo ~= nil) and tonumber(self.SizeTwo) or ""
	local xOff = tonumber(self.OffsetX) or 0
	local yOff = tonumber(self.OffsetY) or 0
	return fmt("%s:%d:%s:%d:%d", path, w, h, xOff, yOff)
end

function TextIcon:GetIconString()
	return fmt("|T%s|t", self:GetIconStringInner())
end

local DEFAULT_ICON_SIZE = 17
setmetatable(TextIcon, {
	__call = function(cls, path, opts)
    local obj = cls:new(path)
    local size = DEFAULT_ICON_SIZE
    if type(opts) == "table" then
    	if opts.Size == "auto" then size = 0
    	elseif type(opts.Size) == "number" then size = opts.Size end
    	if type(opts.OffsetX) == "number" then obj.OffsetX = opts.OffsetX end
    	if type(opts.OffsetY) == "number" then obj.OffsetY = opts.OffsetY end
    end
    obj.SizeOne = size
    obj.SizeTwo = (size > 0) and size or nil
    return obj
  end
})

do
  local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
  if AceGUI and AceGUI.WidgetRegistry then
  	local ctor = AceGUI.WidgetRegistry["CheckBox"]

  	if type(ctor) == "function" and not AceGUI.__MN_PatchedCheckBox then
  	  AceGUI.__MN_PatchedCheckBox = true

  	  local oldCtor = ctor
  	  AceGUI.WidgetRegistry["CheckBox"] = function(...)
  	    local w = oldCtor(...)
  	    local text = w and w.text
  	    if text and text.SetJustifyV then
  	      text:SetWordWrap(false)

  	      if text.SetMaxLines then text:SetMaxLines(1) end
  	      text:SetJustifyV("MIDDLE")

  	      local _, fh = text:GetFont()
  	      local h = math.max(fh or 14, (w.checkbg and w.checkbg.GetHeight and w.checkbg:GetHeight()) or 18)
  	      text:SetHeight(h)
  	      text:ClearAllPoints()
  	      text:SetPoint("LEFT", w.checkbg or w.frame, "RIGHT", 3, 0)
  	      end
  	    return w
  	  end
  	end
  end
end