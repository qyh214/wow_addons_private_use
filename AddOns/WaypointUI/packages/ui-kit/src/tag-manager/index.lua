local env = select(2, ...)
local UIKit_TagManager = env.modules:New("packages\\ui-kit\\tag-manager")

local type = type
local find = string.find
local match = string.match


UIKit_TagManager.Id = { Registry = {} }
UIKit_TagManager.Tag = { Registry = {} }



local function WithGroup(value, groupID)
    return (value and groupID) and (value .. "_" .. groupID) or value
end

local GROUP_CAPTURE_PATTERN = "(.-)$groupID(.+)"

function UIKit_TagManager.NewGroupCaptureString(id, groupID)
    return id .. "$groupID" .. groupID
end

function UIKit_TagManager.ReadGroupCaptureString(groupCaptureString)
    return match(groupCaptureString, GROUP_CAPTURE_PATTERN)
end

function UIKit_TagManager.IsGroupCaptureString(groupCaptureString)
    local isString = (type(groupCaptureString) == "string")
    local hasGroupIDString = (isString and find(groupCaptureString, "$groupID") ~= nil)

    return isString and hasGroupIDString
end



function UIKit_TagManager.Id.Add(frame, id, groupID)
    local registry = UIKit_TagManager.Id.Registry
    local normalizedId = WithGroup(id, groupID)
    local previousId = frame.uk_tagManager_id

    if previousId == normalizedId then return end

    if previousId then
        registry[previousId] = nil
    end

    if normalizedId then
        registry[normalizedId] = frame
    end

    frame.uk_tagManager_id = normalizedId
end

function UIKit_TagManager.Id.Remove(id, groupID)
    local registry = UIKit_TagManager.Id.Registry
    local normalizedId = WithGroup(id, groupID)
    if not normalizedId then return end

    local frame = registry[normalizedId]
    if frame then
        frame.uk_tagManager_id = nil
        registry[normalizedId] = nil
    end
end

function UIKit_TagManager.GetElementById(id, groupID)
    return UIKit_TagManager.Id.Registry[WithGroup(id, groupID)]
end

function UIKit_TagManager.CleanupFrame(frame)
    if not frame then return end

    if frame.uk_tagManager_id then
        UIKit_TagManager.Id.Remove(frame.uk_tagManager_id)
    end
end
