local env                               = select(2, ...)

local UIKit_Primitives_Frame            = env.WPM:Import("wpm_modules/ui-kit/primitives/frame")
local UIKit_Primitives_LayoutGrid       = env.WPM:Import("wpm_modules/ui-kit/primitives/layout-grid")
local UIKit_Primitives_LayoutHorizontal = env.WPM:Import("wpm_modules/ui-kit/primitives/layout-horizontal")
local UIKit_Primitives_LayoutVertical   = env.WPM:Import("wpm_modules/ui-kit/primitives/layout-vertical")
local UIKit_Primitives_Text             = env.WPM:Import("wpm_modules/ui-kit/primitives/text")
local UIKit_Primitives_LazyScrollView   = env.WPM:Import("wpm_modules/ui-kit/primitives/lazy-scroll-view")
local UIKit_Primitives_ScrollView       = env.WPM:Import("wpm_modules/ui-kit/primitives/scroll-view")
local UIKit_Primitives_ScrollBar        = env.WPM:Import("wpm_modules/ui-kit/primitives/scroll-bar")
local UIKit_Primitives_Input            = env.WPM:Import("wpm_modules/ui-kit/primitives/input")
local UIKit_Primitives_LinearSlider     = env.WPM:Import("wpm_modules/ui-kit/primitives/linear-slider")
local UIKit_Primitives_InteractiveRect  = env.WPM:Import("wpm_modules/ui-kit/primitives/interactive-rect")
local UIKit_Primitives_List             = env.WPM:Import("wpm_modules/ui-kit/primitives/list")

local Utils_LazyTable                   = env.WPM:Import("wpm_modules/utils/lazy-table")
local UIKit_FrameCache                  = env.WPM:Import("wpm_modules/ui-kit/frame-cache")
local UIKit_UI_Parser                   = env.WPM:New("wpm_modules/ui-kit/ui/parser")


-- Helper
--------------------------------

local FRAME_CONSTRUCTORS = {
    Frame            = function(name) return UIKit_Primitives_Frame.New("Frame", name, nil) end,
    LayoutGrid       = UIKit_Primitives_LayoutGrid.New,
    LayoutHorizontal = UIKit_Primitives_LayoutHorizontal.New,
    LayoutVertical   = UIKit_Primitives_LayoutVertical.New,
    Text             = UIKit_Primitives_Text.New,
    LazyScrollView   = UIKit_Primitives_LazyScrollView.New,
    ScrollView       = UIKit_Primitives_ScrollView.New,
    ScrollBar        = UIKit_Primitives_ScrollBar.New,
    Input            = UIKit_Primitives_Input.New,
    LinearSlider     = UIKit_Primitives_LinearSlider.New,
    InteractiveRect  = UIKit_Primitives_InteractiveRect.New,
    List             = UIKit_Primitives_List.New,
}

local function getActualParentFrame(parentFrame, parentFrameType)
    if (parentFrameType == "ScrollView" or parentFrameType == "LazyScrollView") and parentFrame.GetContentFrame then
        return parentFrame:GetContentFrame()
    end

    return parentFrame
end

local function setupRegularFrameParent(childFrame, parentFrame, parentFrameType)
    local aliasName = childFrame.uk_prop_under
    local alias = aliasName and parentFrame:GetAlias(aliasName)

    if alias then
        -- Parent to the alias instead of the main frame
        childFrame:SetParent(alias)
        childFrame:SetFrameParent(alias)
    else
        -- Parent to the actual frame (or its ContentFrame for scroll view
        local actualParent = getActualParentFrame(parentFrame, parentFrameType)
        childFrame:SetParent(actualParent)
        childFrame:SetFrameParent(parentFrame)
    end

    if childFrame.uk_prop_frameLevel then
        childFrame:SetFrameLevel(childFrame.uk_prop_frameLevel)
    else
        childFrame:SetFrameLevel(parentFrame:GetFrameLevel() + 1)
    end
end


-- Parser
--------------------------------

local currentFrameID = 0

function UIKit_UI_Parser:CreateFrameFromType(frameType, name, children)
    local constructor = FRAME_CONSTRUCTORS[frameType]
    if not constructor then return end

    -- Handle overloaded parameters: if name is a table and children is nil,
    -- treat name as children (allows calling without explicit name)
    if children == nil and type(name) == "table" then
        children = name
        name = nil
    end

    currentFrameID = currentFrameID + 1
    local frameName = name or "undefined"
    local frame = constructor(frameName)
    UIKit_FrameCache.Add(currentFrameID, frame)

    frame.uk_id = currentFrameID
    frame.uk_type = frameType
    frame.uk_ready = false
    Utils_LazyTable.New(frame, "uk_children")

    -- Attach all children to this frame
    if children then
        local childFrame

        for i = 1, #children do
            childFrame = children[i]

            if childFrame then
                -- Regular frames with SetParent method
                if childFrame and childFrame.SetParent then
                    setupRegularFrameParent(childFrame, frame, frameType)
                end

                -- Track child in parent's children list (for all frame types)
                frame:AddFrameChild(childFrame)
            end
        end
    end

    return frame
end
