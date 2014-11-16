local _, Grid = ...
local GridFrame = Grid:GetModule("GridFrame")
local L = Grid.L

GridFrame:RegisterIndicator("frameAlpha", L["Frame Alpha"],
	-- New
	nil,

	-- Reset
	nil,

	-- SetStatus
	function(self, color, text, value, maxValue, texture, texCoords, count, start, duration)
		if not color then return end

		local frame = self.__owner
		frame:SetAlpha(color.a or 1)
	end,

	-- ClearStatus
	function(self)
		local frame = self.__owner
		frame:SetAlpha(1)
	end
)
