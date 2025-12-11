local env                        = select(2, ...)
local UIKit_Renderer_Positioning = env.WPM:New("wpm_modules/ui-kit/renderer/positioning")


-- Position
--------------------------------

function UIKit_Renderer_Positioning.SetPoint(frame, point, relativePoint)
    local _, relativeTo, _, offsetX, offsetY = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo or frame:GetParent() or UIParent, relativePoint or point, offsetX or 0, offsetY or 0)
end

function UIKit_Renderer_Positioning.SetAnchor(frame, anchorFrame)
    local point, _, relativePoint, offsetX, offsetY = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point or "TOPLEFT", anchorFrame, relativePoint or point, offsetX or 0, offsetY or 0)
end

function UIKit_Renderer_Positioning.SetOffset(frame, x, y)
    local point, relativeTo, relativePoint = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point or "TOPLEFT", relativeTo or frame:GetParent(), relativePoint or point, x, y)
end

function UIKit_Renderer_Positioning.SetOffsetX(frame, x)
    local point, relativeTo, relativePoint, _, offsetY = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point or "TOPLEFT", relativeTo or frame:GetParent(), relativePoint or point, x, offsetY or 0)
end

function UIKit_Renderer_Positioning.SetOffsetY(frame, y)
    local point, relativeTo, relativePoint, offsetX = frame:GetPoint()
    frame:ClearAllPoints()
    frame:SetPoint(point or "TOPLEFT", relativeTo or frame:GetParent(), relativePoint or point, offsetX or 0, y)
end


-- Sizing
--------------------------------

function UIKit_Renderer_Positioning.Fill(frame, insets)
    if frame.uk_fillApplied and frame.uk_lastParent == frame:GetParent() then return end
    frame.uk_fillApplied = true
    frame.uk_lastParent = frame:GetParent()

    local parent = frame:GetParent() or UIParent
    local leftInset, rightInset, topInset, bottomInset = 0, 0, 0, 0

    if type(insets) == "table" then
        leftInset = insets.left or 0
        rightInset = insets.right or 0
        topInset = insets.top or 0
        bottomInset = insets.bottom or 0

        if not (insets.left or insets.right or insets.top or insets.bottom) and insets.delta then
            local split = (insets.delta or 0) * 0.5
            leftInset, rightInset, topInset, bottomInset = split, split, split, split
        end
    else
        local split = (insets or 0) * 0.5
        leftInset, rightInset, topInset, bottomInset = split, split, split, split
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", leftInset, -topInset)
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -rightInset, bottomInset)
    frame:TriggerEvent("OnSizeChanged")
end
