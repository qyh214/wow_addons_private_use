local env = select(2, ...)
local UIKit_Enum = env.modules:Import("packages\\ui-kit\\enum")
local UIKit_Renderer = env.modules:Import("packages\\ui-kit\\renderer")
local UIKit_Renderer_Cleaner = env.modules:Import("packages\\ui-kit\\renderer\\cleaner")
local UIKit_UI_Scanner = env.modules:New("packages\\ui-kit\\ui\\scanner")

local UpdateMode_None = UIKit_Enum.UpdateMode.None
local UpdateMode_All = UIKit_Enum.UpdateMode.All
local UpdateMode_ExcludeVisibilityChanged = UIKit_Enum.UpdateMode.ExcludeVisibilityChanged
local UpdateMode_ChildrenVisibilityChanged = UIKit_Enum.UpdateMode.ChildrenVisibilityChanged

local BLOCK_VISIBILITY_MODE_LOOKUP = {
    [UpdateMode_None]                     = true,
    [UpdateMode_ExcludeVisibilityChanged] = true
}

local function OnVisibilityChanged(frame)
    local parentFrame = frame.uk_parent

    while parentFrame do
        local parentUpdateMode = parentFrame.uk_flag_updateMode

        if not parentUpdateMode or BLOCK_VISIBILITY_MODE_LOOKUP[parentUpdateMode] then
            return
        end

        if parentUpdateMode == UpdateMode_ChildrenVisibilityChanged then
            UIKit_UI_Scanner.ScanFrame(parentFrame)
            return
        end

        if parentUpdateMode == UpdateMode_All then
            parentFrame = parentFrame.uk_parent
        else
            return
        end
    end
end

local function SetupFrame(frame)
    local frameType = frame.uk_type
    local frameUpdateMode = frame.uk_flag_updateMode
    local isUpdateAll = frameUpdateMode == UpdateMode_All

    if isUpdateAll then
        if frameType == "Input" then
            frame:HookEvent("OnSizeChanged", UIKit_UI_Scanner.ScanFrameFromEvent)
        else
            frame:SetScript("OnSizeChanged", UIKit_UI_Scanner.ScanFrameFromEvent)
        end

        if frameType == "Text" then
            frame:HookEvent("OnTextChanged", UIKit_UI_Scanner.ScanFrameFromEvent)
        end
    end

    if isUpdateAll or frameUpdateMode == UpdateMode_ChildrenVisibilityChanged then
        frame:HookScript("OnShow", OnVisibilityChanged)
        frame:HookScript("OnHide", OnVisibilityChanged)
    end

    frame.uk_ready = true
end

function UIKit_UI_Scanner.SetupFrame(frame)
    SetupFrame(frame)
end

function UIKit_UI_Scanner.SetupFrameRecursive(rootFrame)
    local childFrames = rootFrame:GetFrameChildren()
    if not childFrames then return end

    for i = 1, #childFrames do
        local childFrame = childFrames[i]
        if not childFrame.uk_flag_renderBreakpoint then
            SetupFrame(childFrame)
            UIKit_UI_Scanner.SetupFrameRecursive(childFrame)
        end
    end

    local aliasRegistry = rootFrame.uk_aliasRegistry
    if aliasRegistry then
        for _, aliasFrame in pairs(aliasRegistry) do
            if aliasFrame.GetObjectType and aliasFrame:GetObjectType() == "Frame" then
                SetupFrame(aliasFrame)
                UIKit_UI_Scanner.SetupFrameRecursive(aliasFrame)
            end
        end
    end
end

function UIKit_UI_Scanner.ScanFrame(frame)
    if UIKit_Renderer.Cleaner.onCooldown or UIKit_Renderer_Cleaner.IsBatching() then
        return
    end

    local ukParent = frame.uk_parent
    local scanRoot = (ukParent and ukParent.uk_parent) or ukParent or frame
    if not scanRoot or scanRoot == UIParent then
        scanRoot = frame
    end

    UIKit_Renderer.Scanner.ScanFrame(scanRoot)
end

function UIKit_UI_Scanner.ScanFrameFromEvent(frame)
    if frame.uk_flag_updateMode == UpdateMode_All then
        UIKit_UI_Scanner.ScanFrame(frame)
    end
end
