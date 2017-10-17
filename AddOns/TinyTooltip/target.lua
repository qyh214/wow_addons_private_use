
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local YOU = YOU
local NONE = NONE
local EMPTY = EMPTY
local TARGET = TARGET
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME

local addon = TinyTooltip

local function GetTargetString(unit)
    if (not UnitExists(unit)) then return end
    local name = UnitName(unit)
    local icon = addon:GetRaidIcon(unit) or ""
    if UnitIsUnit(unit, "player") then
        return format("|cffff3333>>%s<<|r", strupper(YOU))
    elseif UnitIsPlayer(unit) then
        local class = select(2, UnitClass(unit))
        local colorCode = select(4, GetClassColor(class))
        return format("%s|c%s%s|r", icon, colorCode, name)
    elseif UnitIsOtherPlayersPet(unit) then
        return format("%s|cff%s<%s>|r", icon, addon:GetHexColor(GameTooltip_UnitColor(unit)), name)
    else
        return format("%s|cff%s[%s]|r", icon, addon:GetHexColor(GameTooltip_UnitColor(unit)), name)
    end
end

GameTooltip:HookScript("OnUpdate", function(self, elapsed)
    if (self.updateTooltip ~= TOOLTIP_UPDATE_TIME) then return end
    if (not UnitExists("mouseover")) then return end
    if (addon.db.unit.player.showTarget and UnitIsPlayer("mouseover"))
        or (addon.db.unit.npc.showTarget and not UnitIsPlayer("mouseover")) then
        local line = addon:FindLine(self, "^"..TARGET..":")
        local text = GetTargetString("mouseovertarget")
        if (line and not text) then
            addon:HideLine(self, "^"..TARGET..":")
            self:Show()
        elseif (not line and text) then
            self:AddLine(format("%s: %s", TARGET, text))
            self:Show()
        elseif (line) then
            line:SetFormattedText("%s: %s", TARGET, text)
        end
    end
end)


-- Targeted By

local function GetTargetByString(mouseover, num, tip)
    local count, prefix = 0, IsInRaid() and "raid" or "party"
    local roleIcon, colorCode, name
    local first = true
    local isPlayer = UnitIsPlayer(mouseover)
    for i = 1, num do
        if UnitIsUnit(mouseover, prefix..i.."target") and not UnitIsUnit(prefix..i, "player") then
            count = count + 1
            if (isPlayer or prefix == "party") then
                if (first) then
                    tip:AddLine(format("%s:", addon.L and addon.L.TargetBy or "Targeted By"))
                    first = false
                end
                roleIcon  = addon:GetRoleIcon(prefix..i) or ""
                colorCode = select(4,GetClassColor(select(2,UnitClass(prefix..i))))
                name      = UnitName(prefix..i)
                tip:AddLine("   " .. roleIcon .. " |c" .. colorCode .. name .. "|r")
            end
        end
    end
    if (count > 0 and not isPlayer and prefix ~= "party") then
        return format("|cff33ffff%s|r", count)
    end
end

LibEvent:attachTrigger("tooltip:unit", function(self, tip, unit)
    if (tip:IsUnit("mouseover")) then
        local num = GetNumGroupMembers()
        if (num >= 1) and
          ((addon.db.unit.player.showTargetBy and UnitIsPlayer("mouseover"))
          or (addon.db.unit.npc.showTargetBy and not UnitIsPlayer("mouseover"))) then
            local text = GetTargetByString("mouseover", num, tip)
            if (text) then
                tip:AddLine(format("%s: %s", addon.L and addon.L.TargetBy or "Targeted By", text), nil, nil, nil, true)
            end
        end
    end
end)
