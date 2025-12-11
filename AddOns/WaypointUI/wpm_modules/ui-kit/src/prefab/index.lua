local env            = select(2, ...)

local assert         = assert
local type           = type

local Utils_Standard = env.WPM:Import("wpm_modules/utils/standard")
local UIKit_Prefab   = env.WPM:New("wpm_modules/ui-kit/prefab")

local EMPTY_TABLE    = { dummy = true }


-- Prefab Constructor Method
--------------------------------

local function newPrefabConstructor(constructor)
    assert(constructor, "Invalid variable `constructor`")
    assert(type(constructor) == "function", "Invalid variable `constructor`: Must be of type `function`")

    return function(name, children, ...)
        -- Handle first argument as children
        if type(name) == "table" then
            children = name; name = nil
        end

        -- Create a unique ID for the instance
        local id = Utils_Standard.GenerateRandomID()

        -- Set the name to "undefined" if nil
        name = name or "undefined"

        -- Return the constructor with the proper arguments
        return constructor(id, name, children or EMPTY_TABLE, ...)
    end
end


-- API
--------------------------------

function UIKit_Prefab.New(constructor)
    return newPrefabConstructor(constructor)
end
