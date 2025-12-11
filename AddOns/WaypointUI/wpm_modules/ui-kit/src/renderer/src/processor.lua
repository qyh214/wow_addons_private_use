local env                        = select(2, ...)
local UIKit_Define               = env.WPM:Import("wpm_modules/ui-kit/define")
local UIKit_Utils                = env.WPM:Import("wpm_modules/ui-kit/utils")
local UIKit_Renderer_Positioning = env.WPM:Import("wpm_modules/ui-kit/renderer/positioning")
local UIKit_Renderer_Processor   = env.WPM:New("wpm_modules/ui-kit/renderer/processor")


-- Size — Fit
--------------------------------

local function processSizeFit(frame)
    if frame.CustomFitContent then
        frame:CustomFitContent()
    elseif frame.FitContent then
        frame:FitContent()
    end
end
UIKit_Renderer_Processor.SizeFit = processSizeFit


-- Size — Num / Percentage
--------------------------------

local function processSizeStatic(frame)
    local parent = frame:GetParent() or UIParent

    local width = frame.uk_prop_width
    if width then
        if width == UIKit_Define.Num then
            frame:SetWidth(width.value)
        elseif width == UIKit_Define.Percentage then
            frame:SetWidth(UIKit_Utils:CalculateRelativePercentage(parent:GetWidth(), width.value, width.operator, width.delta, frame))
        end
    end

    local height = frame.uk_prop_height
    if height then
        if height == UIKit_Define.Num then
            frame:SetHeight(height.value)
        elseif height == UIKit_Define.Percentage then
            frame:SetHeight(UIKit_Utils:CalculateRelativePercentage(parent:GetHeight(), height.value, height.operator, height.delta, frame))
        end
    end
end
UIKit_Renderer_Processor.SizeStatic = processSizeStatic


-- Size — Fill
--------------------------------

local function processSizeFill(frame)
    UIKit_Renderer_Positioning.Fill(frame, frame.uk_prop_fill)
end
UIKit_Renderer_Processor.SizeFill = processSizeFill


-- Point
--------------------------------

local function processPositionPoint(frame)
    UIKit_Renderer_Positioning.SetPoint(frame, frame.uk_prop_point, frame.uk_prop_point_relative)
end
UIKit_Renderer_Processor.Point = processPositionPoint


local function processPositionAnchor(frame)
    UIKit_Renderer_Positioning.SetAnchor(frame, frame.uk_prop_anchor)
end
UIKit_Renderer_Processor.Anchor = processPositionAnchor


local function processPositionOffset(frame)
    local parent = frame:GetParent() or UIParent

    local x = frame.uk_prop_x
    if x then
        if x == UIKit_Define.Num then
            UIKit_Renderer_Positioning.SetOffsetX(frame, x.value)
        elseif x == UIKit_Define.Percentage then
            UIKit_Renderer_Positioning.SetOffsetX(frame, UIKit_Utils:CalculateRelativePercentage(parent:GetWidth(), x.value, x.operator, x.delta, frame))
        end
    end

    local y = frame.uk_prop_y
    if y then
        if y == UIKit_Define.Num then
            UIKit_Renderer_Positioning.SetOffsetY(frame, y.value)
        elseif y == UIKit_Define.Percentage then
            UIKit_Renderer_Positioning.SetOffsetY(frame, UIKit_Utils:CalculateRelativePercentage(parent:GetHeight(), y.value, y.operator, y.delta, frame))
        end
    end
end
UIKit_Renderer_Processor.PositionOffset = processPositionOffset


-- Layout Group
--------------------------------

local function processUpdateLayout(frame)
    local frameType = frame.uk_type
    if frameType == "LayoutGrid" or frameType == "LayoutVertical" or frameType == "LayoutHorizontal" then
        frame:RenderElements()
    end
end
UIKit_Renderer_Processor.Layout = processUpdateLayout


-- Scroll Bar
--------------------------------

local function processUpdateScrollBar(frame)
    frame:SetThumbSize()
    frame:SyncValue()
end
UIKit_Renderer_Processor.ScrollBar = processUpdateScrollBar
