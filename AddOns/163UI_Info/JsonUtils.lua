---@type ns
local ns = select(2, ...)

local JsonUtils = {}

local function table_size(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

local function isArray(t)
    if type(t) ~= "table" then return false end
    
    local maxIndex = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" then return false end
        if k > maxIndex then maxIndex = k end
    end
    
    for i = 1, maxIndex do
        if t[i] == nil then return false end
    end
    
    return true
end

local function serialize(tbl, level)
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return string.format("%q", tbl)
        else
            return tostring(tbl)
        end
    end
    
    local result = {}
    local indent = string.rep("  ", level)

    if isArray(tbl) then
        table.insert(result, "[\n")
        for i, v in ipairs(tbl) do
            local value = serialize(v, level + 1)
            local comma = (i == #tbl) and "\n" or ",\n"
            table.insert(result, string.format("%s  %s%s", indent, value, comma))
        end
        table.insert(result, indent .. "]")
    else
        table.insert(result, "{\n")
        local count = 0
        local totalCount = table_size(tbl)
        
        for k, v in pairs(tbl) do
            count = count + 1
            local key = (type(k) == "string" and string.format("%q", k)) or tostring(k)
            local value = serialize(v, level + 1)
            local comma = (count == totalCount) and "\n" or ",\n"
            table.insert(result, string.format("%s  %s: %s%s", indent, key, value, comma))
        end
        table.insert(result, indent .. "}")
    end

    return table.concat(result)
end

function JsonUtils.TableToJson(tbl)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end
    
    return serialize(tbl, 0)
end

ns.JsonUtils = JsonUtils

_G.JsonUtils = JsonUtils

return JsonUtils