local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local TC = E:NewModule('TargetClass', 'AceEvent-3.0')

local frame

function TC:TargetChanged()
	frame:Hide()

	local class = UnitIsPlayer("target") and select(2, UnitClass("target")) or UnitClassification("target")
	if class then
		--local CLASS_BUTTONS = CLASS_BUTTONS
		local coordinates = CLASS_ICON_TCOORDS[class];
		--local coordinates = CLASS_BUTTONS[class]
		if coordinates then
			frame.Texture:SetTexCoord(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
			frame:Show()
		end
	end	
end

function TC:ToggleSettings()
	if frame.db.enable then
		frame:SetSize(frame.db.size, frame.db.size)
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", ElvUF_Target, "TOP", frame.db.xOffset, frame.db.yOffset)

		TC:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetChanged")
		TC:TargetChanged()
	else
		TC:UnregisterEvent("PLAYER_TARGET_CHANGED")
		frame:Hide()
	end
end

function TC:Initialize()
	frame = CreateFrame("Frame", "TargetClass", E.UIParent)
	frame:SetFrameLevel(12)
	frame.Texture = frame:CreateTexture(nil, "ARTWORK")
	frame.Texture:SetAllPoints()
	frame.Texture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
	frame.db = E.db.unitframe.units.target.classicon

	self:ToggleSettings()
end

E:RegisterModule(TC:GetName())
