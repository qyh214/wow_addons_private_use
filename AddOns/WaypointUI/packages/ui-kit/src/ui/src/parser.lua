local env = select(2, ...)
local UIKit_Primitives_Frame = env.modules:Import("packages\\ui-kit\\primitives\\frame")
local UIKit_Primitives_LayoutGrid = env.modules:Import("packages\\ui-kit\\primitives\\layout-grid")
local UIKit_Primitives_LayoutHorizontal = env.modules:Import("packages\\ui-kit\\primitives\\layout-horizontal")
local UIKit_Primitives_LayoutVertical = env.modules:Import("packages\\ui-kit\\primitives\\layout-vertical")
local UIKit_Primitives_Text = env.modules:Import("packages\\ui-kit\\primitives\\text")
local UIKit_Primitives_ScrollContainer = env.modules:Import("packages\\ui-kit\\primitives\\scroll-container")
local UIKit_Primitives_LazyScrollContainer = env.modules:Import("packages\\ui-kit\\primitives\\lazy-scroll-container")
local UIKit_Primitives_ScrollBar = env.modules:Import("packages\\ui-kit\\primitives\\scroll-bar")
local UIKit_Primitives_ScrollContainerEdge = env.modules:Import("packages\\ui-kit\\primitives\\scroll-container-edge")
local UIKit_Primitives_Input = env.modules:Import("packages\\ui-kit\\primitives\\input")
local UIKit_Primitives_LinearSlider = env.modules:Import("packages\\ui-kit\\primitives\\linear-slider")
local UIKit_Primitives_HitRect = env.modules:Import("packages\\ui-kit\\primitives\\hit-rect")
local UIKit_Primitives_List = env.modules:Import("packages\\ui-kit\\primitives\\list")
local Utils_LazyTable = env.modules:Import("packages\\utils\\lazy-table")
local UIKit_FrameCache = env.modules:Import("packages\\ui-kit\\frame-cache")
local UIKit_UI_Parser = env.modules:New("packages\\ui-kit\\ui\\parser")

local type = type
local Utils_LazyTable_New = Utils_LazyTable.New
local UIKit_FrameCache_Add = UIKit_FrameCache.Add

local FRAME_CONSTRUCTORS = {
    Frame               = function(name) return UIKit_Primitives_Frame.New("Frame", name, nil) end,
    LayoutGrid          = UIKit_Primitives_LayoutGrid.New,
    LayoutHorizontal    = UIKit_Primitives_LayoutHorizontal.New,
    LayoutVertical      = UIKit_Primitives_LayoutVertical.New,
    Text                = UIKit_Primitives_Text.New,
    ScrollContainer     = UIKit_Primitives_ScrollContainer.New,
    LazyScrollContainer = UIKit_Primitives_LazyScrollContainer.New,
    ScrollBar           = UIKit_Primitives_ScrollBar.New,
    ScrollContainerEdge = UIKit_Primitives_ScrollContainerEdge.New,
    Input               = UIKit_Primitives_Input.New,
    LinearSlider        = UIKit_Primitives_LinearSlider.New,
    HitRect             = UIKit_Primitives_HitRect.New,
    List                = UIKit_Primitives_List.New
}

local function GetActualParentFrame(parentFrame, parentFrameType)
    if (parentFrameType == "ScrollContainer" or parentFrameType == "LazyScrollContainer") and parentFrame.GetContentFrame then
        return parentFrame:GetContentFrame()
    end

    return parentFrame
end

local function SetupRegularFrameParent(childFrame, parentFrame, parentFrameType)
    local aliasName = childFrame.uk_prop_under
    local alias = aliasName and parentFrame:GetAlias(aliasName)

    if alias then
        childFrame:SetParent(alias)
        childFrame:SetFrameParent(alias)
    else
        local actualParent = GetActualParentFrame(parentFrame, parentFrameType)
        childFrame:SetParent(actualParent)
        childFrame:SetFrameParent(parentFrame)
    end

    if childFrame.uk_prop_frameLevel then
        childFrame:SetFrameLevel(childFrame.uk_prop_frameLevel)
    else
        childFrame:SetFrameLevel(parentFrame:GetFrameLevel() + 1)
    end
end

local currentFrameID = 0

function UIKit_UI_Parser:CreateFrameFromType(frameType, name, children)
    local constructor = FRAME_CONSTRUCTORS[frameType]
    if not constructor then return end

    if children == nil and type(name) == "table" then
        children = name
        name = nil
    end

    currentFrameID = currentFrameID + 1
    local frame = constructor(name or "undefined")
    UIKit_FrameCache_Add(currentFrameID, frame)

    frame.uk_id = currentFrameID
    frame.uk_type = frameType
    frame.uk_ready = false
    Utils_LazyTable_New(frame, "uk_children")

    if children then
        for i = 1, #children do
            local childFrame = children[i]
            if childFrame then
                if childFrame.SetParent then
                    SetupRegularFrameParent(childFrame, frame, frameType)
                end
                frame:AddFrameChild(childFrame)
            end
        end
    end

    return frame
end
