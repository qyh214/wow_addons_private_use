local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

-- the DebugLog addon
---@diagnostic disable-next-line: undefined-global
local D = DLAPI

--- An empty function
local function EmptyFunc()
end

--- Adds a debug message to the DebugLog log
---@param ... any Messages to add to the debug log
local function Debug(...)
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    D.DebugLog(AddOnFolderName, "%s", msg)
end

--- Adds a stack trace to the DebugLog log
---@diagnostic disable: undefined-field
local function Trace()
    D.DebugLog(AddOnFolderName, "%s", "======== Trace ==")
    for i, v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            D.DebugLog(AddOnFolderName, "%d: %s", i, v)
        end
    end
    D.DebugLog(AddOnFolderName, "%s", "-----------------")
end

if D then
    private.Debug = Debug
    private.Trace = Trace
    SetCVar("fstack_preferParentKeys", 0)
    Debug("DebugLog setup complete")
else
    private.Debug = EmptyFunc
    private.Trace = EmptyFunc
end
