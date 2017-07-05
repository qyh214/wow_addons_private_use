
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local addon = TinyTooltip

local function ColorBorder(tip, r, g, b)
    if (addon.db.quest.coloredQuestBorder) then
        LibEvent:trigger("tooltip.style.border.color", tip, r, g, b)
    end
end

hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(self, link)
    local schema, id, level = string.match(link, "|?H?(%a+):(%d+):([%-%d]+)")
    level = tonumber(level)
    if (schema and schema == "quest" and level) then
        local color = GetQuestDifficultyColor(level < 0 and UnitLevel("player") or level)
        ColorBorder(self, color.r, color.g, color.b)
    end
end)
