local _, Grid = ...
local GridFrame = Grid:GetModule("GridFrame")
local Media = LibStub("LibSharedMedia-3.0")
local L = Grid.L

GridFrame:RegisterIndicator("healingBar", L["Healing Bar"],
	-- New
	function(frame)
		local bar = CreateFrame("StatusBar", nil, frame)

		bar:SetStatusBarTexture("Interface\\Addons\\Grid\\gradient32x32")
		bar.texture = bar:GetStatusBarTexture()

		bar:SetStatusBarColor(0, 1, 0, 0.5)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)
		bar:Hide()

		return bar
	end,

	-- Reset
	function(self)
		if self.__owner.unit then
			--print("Reset", self.__id, self.__owner.unit)
		end

		local profile = GridFrame.db.profile
		local texture = Media:Fetch("statusbar", profile.texture) or "Interface\\Addons\\Grid\\gradient32x32"

		local frame = self.__owner

		self:SetPoint("BOTTOMLEFT", frame.indicators.bar.texture, "TOPLEFT")
		self:SetPoint("BOTTOMRIGHT", frame.indicators.bar.texture, "TOPRIGHT")

		self:SetAlpha(profile.healingBar_intensity)
		self:SetOrientation(profile.orientation)
		-- TODO: does changing orientation reset the value?

		local r, g, b = self:GetStatusBarColor()
		self:SetStatusBarTexture(texture)
		self.texture:SetHorizTile(false)
		self.texture:SetVertTile(false)
		self:SetStatusBarColor(r, g, b)
	end,

	-- SetStatus
	function(self, color, text, value, maxValue, texture, texCoords, count, start, duration)
		-- TODO: update this!
		if true or not value or not maxValue or value == 0 then
			return self:Hide()
		end

		local profile = GridFrame.db.profile
		local frame = self.__owner

		self:SetMinMaxValues(0, maxValue)
		self:SetValue(value)

		local perc = value / maxValue
		local coord = (perc > 0 and perc <= 1) and perc or 1
		if profile.orientation == "VERTICAL" then
			self.texture:SetTexCoord(0, 1, 1 - coord, 1)
		else
			self.texture:SetTexCoord(0, coord, 0, 1)
		end

		if profile.healingBar_useStatusColor then
			--print("SetStatus", self.__id, self.__owner.unit)
			if profile.invertBarColor then
				self:SetStatusBarColor(color.r, color.g, color.b)
			else
				local mu = profile.healingBar_intensity
				self:SetStatusBarColor(color.r * mu, color.g * mu, color.b * mu)
			end
		end
	end,

	-- ClearStatus
	function(self)
		local profile = GridFrame.db.profile

		self:Hide()
		self:SetValue(0)

		if profile.healingBar_useStatusColor then
			self:SetStatusBarColor(0, 1, 0, 0.5)
		end
	end
)
