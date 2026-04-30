local env = select(2, ...)
local UIKit_Renderer_Cleaner = env.modules:Import("packages\\ui-kit\\renderer\\cleaner")
local UIKit_Define = env.modules:Import("packages\\ui-kit\\define")
local UIKit_Renderer_Scanner = env.modules:New("packages\\ui-kit\\renderer\\scanner")

local type = type
local AddDirty = UIKit_Renderer_Cleaner.AddDirty
local UIKit_Define_Percentage = UIKit_Define.Percentage
local UIKit_Define_Fit = UIKit_Define.Fit
local ACTION_SIZE_STATIC = UIKit_Renderer_Cleaner.ACTION_SIZE_STATIC
local ACTION_SIZE_FIT = UIKit_Renderer_Cleaner.ACTION_SIZE_FIT
local ACTION_SIZE_FILL = UIKit_Renderer_Cleaner.ACTION_SIZE_FILL
local ACTION_POSITION_OFFSET = UIKit_Renderer_Cleaner.ACTION_POSITION_OFFSET
local ACTION_ANCHOR = UIKit_Renderer_Cleaner.ACTION_ANCHOR
local ACTION_POINT = UIKit_Renderer_Cleaner.ACTION_POINT
local ACTION_LAYOUT = UIKit_Renderer_Cleaner.ACTION_LAYOUT
local ACTION_SCROLLBAR = UIKit_Renderer_Cleaner.ACTION_SCROLLBAR

local scanStack = {}
local scanStackTop = 0

local LAYOUT_TYPE_LOOKUP = {
    LayoutGrid       = true,
    LayoutVertical   = true,
    LayoutHorizontal = true
}

local function AnalyzeFrameProperty(frame)
    local frameType = frame.uk_type
    local propWidth = frame.uk_prop_width
    local propHeight = frame.uk_prop_height

    -- Point
    if frame.uk_prop_point then AddDirty(ACTION_POINT, frame) end

    -- Anchor
    if frame.uk_prop_anchor then AddDirty(ACTION_ANCHOR, frame) end

    -- Position (x/y)
    local propX = frame.uk_prop_x
    local propY = frame.uk_prop_y
    if (propX == UIKit_Define_Percentage or type(propX) == "number") or (propY == UIKit_Define_Percentage or type(propY) == "number") then AddDirty(ACTION_POSITION_OFFSET, frame) end

    -- Size (width/height)
    if propWidth == UIKit_Define_Percentage or propHeight == UIKit_Define_Percentage then AddDirty(ACTION_SIZE_STATIC, frame) end
    if propWidth == UIKit_Define_Fit or propHeight == UIKit_Define_Fit then AddDirty(ACTION_SIZE_FIT, frame) end

    -- Layout
    if LAYOUT_TYPE_LOOKUP[frameType] and (propWidth or propHeight) then AddDirty(ACTION_LAYOUT, frame) end

    -- Size Fill
    if frame.uk_prop_fill then AddDirty(ACTION_SIZE_FILL, frame) end

    -- Scroll Bar
    if frameType == "ScrollBar" then AddDirty(ACTION_SCROLLBAR, frame) end
end

function UIKit_Renderer_Scanner.ScanFrame(rootFrame)
    -- Reset stack and push root frame
    scanStackTop = 1
    scanStack[1] = rootFrame

    while scanStackTop > 0 do
        -- Pop frame from stack
        local frame = scanStack[scanStackTop]
        scanStack[scanStackTop] = nil -- Clear reference to allow GC
        scanStackTop = scanStackTop - 1

        AnalyzeFrameProperty(frame)

        -- Push ScrollContainer/LazyScrollContainer Content onto stack
        local contentFrame = frame.GetContentFrame and frame:GetContentFrame()
        if contentFrame then
            scanStackTop = scanStackTop + 1
            scanStack[scanStackTop] = contentFrame
        end

        -- Push child frames onto stack (in reverse order for correct processing order)
        local children = frame.GetFrameChildren and frame:GetFrameChildren()
        if children then
            for i = #children, 1, -1 do
                local child = children[i]
                if child and not child.uk_flag_renderBreakpoint then
                    scanStackTop = scanStackTop + 1
                    scanStack[scanStackTop] = child
                end
            end
        end
    end
end

function UIKit_Renderer_Scanner.ScanFrameOnly(frame)
    if not frame then return end
    AnalyzeFrameProperty(frame)

    -- Scan content frame
    local contentFrame = frame.GetContentFrame and frame:GetContentFrame()
    if contentFrame then
        AnalyzeFrameProperty(contentFrame)
    end
end
