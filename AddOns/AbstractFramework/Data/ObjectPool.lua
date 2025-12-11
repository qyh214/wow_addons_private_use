---@class AbstractFramework
local AF = _G.AbstractFramework

local insert = table.insert
local CreateObjectPool = CreateObjectPool

---@class ObjectPool
---@field Acquire fun():UIObject Furnishes a new or reused widget
---@field Release fun(widget:UIObject) Restores a widget to original condition for reuse
---@field ReleaseAll function Restores all widgets sourced from the pool to original condition for reuse
---@field EnumerateActive function Returns an iterator to cycle through widgets sourced from the pool
---@field EnumerateInactive function Returns an iterator to cycle through widgets released back to the pool
---@field GetNextActive fun(current:UIObject?):UIObject Moves to the next active widget within the pool, or returns nil
---@field GetNextInactive fun(current:UIObject?):UIObject Moves to the next inactive widget within the pool, or returns nil
---@field IsActive fun(widget:UIObject):boolean Indicates if the widget is presently acquired from the pool
---@field GetNumActive fun():number Returns the number of widgets presently acquired from the pool
---@field GetAllActives fun():table Returns a table of all widgets presently acquired from the pool

local AF_ObjectPoolMixin = {}
function AF_ObjectPoolMixin:GetAllActives()
    -- return self.activeObjects -- secure
    local actives = {}
    for obj in self:EnumerateActive() do
        insert(actives, obj)
    end
    return actives
end

---@param creationFunc fun(pool:ObjectPool):UIObject
---@param resetterFunc fun(pool:ObjectPool, widget:UIObject)
---@return ObjectPool pool
function AF.CreateObjectPool(creationFunc, resetterFunc)
    local pool = CreateObjectPool(creationFunc, resetterFunc)
    Mixin(pool, AF_ObjectPoolMixin)
    return pool
end