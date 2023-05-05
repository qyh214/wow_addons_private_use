local AceGUI = LibStub("AceGUI-3.0")

local math_max = math.max
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

local layoutrecursionblock = nil
local function safelayoutcall(object, func, ...)
	layoutrecursionblock = true
	object[func](object, ...)
	layoutrecursionblock = nil
end

AceGUI:RegisterLayout("Flow-Nowrap-OmniCD", -- multiselect items
	function(content, children)
		if layoutrecursionblock then return end

		local rowheight = 0
		local width = 0
		local childWidth = 0

		local n = #children
		for i = 1, n do
			local child = children[i]
			local frame = child.frame
			frame:ClearAllPoints()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
				rowheight = frame.height or frame:GetHeight() or 0
				childWidth = frame.width or frame:GetWidth() or 0
			else
				width = width + childWidth
				frame:SetPoint("TOPLEFT", content, "TOPLEFT", width, 0)
			end
			frame:Show()
		end

		safecall(content.obj.LayoutFinished, content.obj, nil, rowheight + 3)
	end)

AceGUI:RegisterLayout("Flow-Nopadding-OmniCD", -- multiselect container (no top-bottom padding)
	function(content, children)
		if layoutrecursionblock then return end

		local height = 0
		local rowheight = 0

		local n = #children
		for i = 1, n do
			local child = children[i]
			local frame = child.frame

			frame:ClearAllPoints()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
				rowheight = frame.height or frame:GetHeight() or 0
			else
				height = height + rowheight
				frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
			end

			frame:SetPoint("RIGHT", content)

			frame:Show()
		end

		height = height + rowheight -- add last rowheight
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)
