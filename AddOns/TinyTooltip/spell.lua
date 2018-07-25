
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local addon = TinyTooltip

local function ColorBorder(tip)
    if (addon.db.spell.borderColor) then
        LibEvent:trigger("tooltip.style.border.color", tip, unpack(addon.db.spell.borderColor))
    end
end

local function ColorBackground(tip)
    if (addon.db.spell.background) then
        LibEvent:trigger("tooltip.style.background", tip, unpack(addon.db.spell.background))
    end
end

local function SpellIcon(tip)
    if (addon.db.spell.showIcon) then
        local id = select(2, tip:GetSpell())
        local texture = GetSpellTexture(id or 0)
        local text = addon:GetLine(tip,1):GetText()
        if (texture and not strfind(text, "^|T")) then
            addon:GetLine(tip,1):SetFormattedText("|T%s:16|t %s", texture, text)
        end
    end
end

LibEvent:attachTrigger("tooltip:spell", function(self, tip)
    SpellIcon(tip)
    ColorBorder(tip)
    ColorBackground(tip)
end)
