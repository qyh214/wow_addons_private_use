---@class AbstractFramework
local AF = _G.AbstractFramework

AF.REGISTERED_ADDONS = {}

local PATTERN = AF.isRetail and "\n%[Interface/AddOns/([^/]+)/" or "@Interface/AddOns/([^/]+)/"
local strmatch = string.gmatch
local debugstack, print, type = debugstack, print, type
local tinsert, tconcat = table.insert, table.concat
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local DevTools_Dump = DevTools_Dump

---@return string addon, string|boolean alias
function AF.GetAddon()
    for addon in strmatch(debugstack(2), PATTERN) do
        if AF.REGISTERED_ADDONS[addon] then
            return addon, AF.REGISTERED_ADDONS[addon]
        end
    end
    return nil
end

---@param fieldName string
---@param addon string?
---@return string? fieldValue
function AF.GetAddOnMetadata(fieldName, addon)
    assert(fieldName, "fieldName is required")
    addon = addon or AF.GetAddon()
    if addon then
        return GetAddOnMetadata(addon, fieldName)
    end
end

---@param addon string?
---@return string? version
---@return number? versionNum
function AF.GetAddOnVersion(addon)
    addon = addon or AF.GetAddon()
    if addon then
        local version = GetAddOnMetadata(addon, "Version")
        if version then
            local versionNum = tonumber(version:match("(%d+)$")) or tonumber(version:match("%d+"))
            return version, versionNum
        end
    end
end

local function GetPrefix()
    local addon, alias = AF.GetAddon()
    if addon then
        return AF.WrapTextInColor("[" .. (type(alias) == "string" and alias or addon) .. "]", AF.GetAddonAccentColorName(addon))
    else
        return AF.WrapTextInColor("[AF]", "accent")
    end
end

function AF.Debug(arg, ...)
    if AFConfig and AFConfig.debugMode then
        if type(arg) == "string" or type(arg) == "number" or type(arg) == "boolean" then
            print(AF.WrapTextInColor("[DEBUG]", "red") .. GetPrefix(), arg, ...)
        elseif type(arg) == "table" then
            if IsAddOnLoaded("TableExplorer") then
                texplore(arg) -- kinda bug
            else
                DevTools_Dump(arg)
            end
        elseif type(arg) == "function" then
            arg(...)
        elseif arg == nil then
            return true
        end
    end
end

function AF.Print(...)
    print(GetPrefix(), ...)
end

function AF.Printf(msg, ...)
    AF.Print(msg:format(...))
end

local PRINT_STACK_PATTERN = "\n%[Interface/AddOns/([^/]+)/([^:]+)]:(%d+): in function"
function AF.PrintStack()
    local stack = {}
    for addon, file, line in strmatch(debugstack(2), PRINT_STACK_PATTERN) do
        tinsert(stack, AF.WrapTextInColor(addon, "gray") .. ": " .. file .. " (" .. line .. ")")
    end
    print(AF.WrapTextInColor("[CALL_STACK] ", "green") .. tconcat(stack, "\n-> "))
end

function AF.RegisterAddon(addonFolderName, alias)
    AF.REGISTERED_ADDONS[addonFolderName] = alias or true
    AF.SetAddonAccentColor(addonFolderName, "accent") -- setup with default accent color
end