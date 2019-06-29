
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local addon = TinyTooltip

LibEvent:attachTrigger("tooltip:init", function(self, tip)
    if (tip ~= GameTooltip) then return end
    if (not tip.model) then
        tip.model = CreateFrame("PlayerModel", nil, tip)
        tip.model:SetSize(100, 100)
        tip.model:SetFacing(-0.25)
        tip.model:SetPoint("BOTTOMRIGHT", tip, "TOPRIGHT", 8, -16)
        tip.model:Hide()
        tip.model:SetScript("OnUpdate", function(self, elapsed)
            if (IsControlKeyDown() or IsAltKeyDown()) then
                self:SetFacing(self:GetFacing() + math.pi * elapsed)
            end
        end)
    end
end)

LibEvent:attachTrigger("tooltip:unit", function(self, tip, unit)
    if (tip ~= GameTooltip) then return end
    if (not addon.db.unit.player.showModel) then return end
    if (not UnitIsVisible(unit)) then return end
    if (UnitIsPlayer(unit)) then
        tip.model:SetUnit(unit)
        tip.model:SetFacing(-0.25)
        tip.model:Show()
    else
        tip.model:ClearModel()
        tip.model:Hide()
    end
end)

LibEvent:attachTrigger("tooltip:cleared", function(self, tip)
    if (tip ~= GameTooltip) then return end
    tip.model:ClearModel()
    tip.model:Hide()
end)
