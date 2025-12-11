---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class ComponentBase
local componentBase = {}
Private.Components.Base = componentBase

function componentBase:MixTables(...)
    local mixed = {}
    for _, tbl in pairs({ ... }) do
        if type(tbl) == "table" then
            Mixin(mixed, tbl)
        end
    end
    return mixed
end
