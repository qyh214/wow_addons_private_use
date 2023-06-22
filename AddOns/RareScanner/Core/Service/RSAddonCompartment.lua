-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local LibStub = _G.LibStub
local ADDON_NAME, private = ...

-- Locales
local AL = LibStub("AceLocale-3.0"):GetLocale("RareScanner");

---============================================================================
-- Addon compartiment
---============================================================================

local tooltip

function RareScanner_OnAddonCompartmentClick(addonName, button)
	if (button == "LeftButton") then
		RSExplorerFrame:Show()
	elseif (button == "RightButton") then
		InterfaceOptionsFrame_OpenToCategory("RareScanner")
		InterfaceOptionsFrame_OpenToCategory("RareScanner")
	end
end

function RareScanner_OnAddonCompartmentEnter(addonName, button)
	if (not tooltip) then
		tooltip = CreateFrame("GameTooltip", "RareScanner_AddonCompartimentTooltip", UIParent, "GameTooltipTemplate")
	end
	
    tooltip:SetOwner(button, "ANCHOR_LEFT");
	tooltip:SetText("RareScanner")
	tooltip:AddLine(AL["MINIMAP_ICON_TOOLTIP1"], 1, 1, 1)
	tooltip:AddLine(AL["MINIMAP_ICON_TOOLTIP2"], 1, 1, 1)
	tooltip:Show()
end

function RareScanner_OnAddonCompartmentLeave(addonName, button)
	tooltip:Hide()
end