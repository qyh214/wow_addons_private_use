local env              = select(2, ...)

local type             = type
local find             = string.find

local UIKit_TagManager = env.WPM:New("wpm_modules/ui-kit/tag-manager")
UIKit_TagManager.Id    = { Registry = {} }
UIKit_TagManager.Tag   = { Registry = {} }


-- Helper
--------------------------------

local function withGroup(value, groupID)
    return (value and groupID) and (value .. "_" .. groupID) or value
end


-- Group Capture String
--------------------------------

function UIKit_TagManager.NewGroupCaptureString(id, groupID)
    return tostring(id .. "$groupID" .. groupID)
end

function UIKit_TagManager.ReadGroupCaptureString(groupCaptureString)
    local id, groupID = string.match(groupCaptureString, "(.-)$groupID(.+)")
    return id, groupID
end

function UIKit_TagManager.IsGroupCaptureString(groupCaptureString)
    local isString = (type(groupCaptureString) == "string")
    local hasGroupIDString = (isString and find(groupCaptureString, "$groupID") ~= nil)

    return isString and hasGroupIDString
end


-- Id
--------------------------------

function UIKit_TagManager.Id.Add(frame, id, groupID)
    local registry = UIKit_TagManager.Id.Registry
    local normalizedId = withGroup(id, groupID)
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
    local normalizedId = withGroup(id, groupID)
    if not normalizedId then return end

    local frame = registry[normalizedId]
    if frame then
        frame.uk_tagManager_id = nil
        registry[normalizedId] = nil
    end
end


-- Get
--------------------------------

function UIKit_TagManager.GetElementById(id, groupID)
    return UIKit_TagManager.Id.Registry[withGroup(id, groupID)]
end


-- Clean up
--------------------------------

function UIKit_TagManager.CleanupFrame(frame)
    if not frame then return end

    if frame.uk_tagManager_id then
        UIKit_TagManager.Id.Remove(frame.uk_tagManager_id)
    end
end
