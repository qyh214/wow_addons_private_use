---@class AbstractFramework
local AF = _G.AbstractFramework

local LibDBIcon = AF.Libs.LibDBIcon
local LibDataBroker = AF.Libs.LibDataBroker

---@param name string
---@param db table
---@param onClick fun(displayFrame: Frame, buttonName: string)
---@param tooltip fun(tooltip: GameTooltip)|table|string
---@param onEnter fun(self)
---@param onLeave fun(self)
function AF.NewMinimapButton(name, icon, db, onClick, tooltip, onEnter, onLeave)
    local onTooltipShow
    if type(tooltip) == "function" then
        onTooltipShow = tooltip
    elseif type(tooltip) == "table" then
        onTooltipShow = function(tt)
            for _, line in ipairs(tooltip) do
                if type(line) == "table" then
                    tt:AddDoubleLine(line[1], line[2])
                else
                    tt:AddLine(line)
                end
            end
        end
    elseif type(tooltip) == "string" then
        onTooltipShow = function(tt)
            tt:AddLine(tooltip)
        end
    end

    local dataBroker = LibDataBroker:NewDataObject(name, {
        type = "launcher",
        icon = icon,
        OnClick = onClick,
        OnTooltipShow = onTooltipShow,
        OnEnter = onEnter,
        OnLeave = onLeave,
    })
    LibDBIcon:Register(name, dataBroker, db)
    return dataBroker
end

-- TODO:
-- function AF.NewDataBroker() end