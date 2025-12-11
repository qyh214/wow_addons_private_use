local env = select(2, ...)
local Pool = env.WPM:New("wpm_modules/pool")


-- Helpers
--------------------------------

local function reserve(pool, capacity)
    pool.capacity = capacity or math.huge

    if pool.capacity ~= math.huge then
        for index = 1, pool.capacity do
            pool:Acquire()
        end
        pool:ReleaseAll()
    end
end

local function getObjectIsInvalidMsg(object, poolCollection)
    return string.format("Attempted to release inactive object '%s'", tostring(object))
end


-- Pool
--------------------------------

local PoolBaseMixin = {}
do
    function PoolBaseMixin:Acquire()
        if self:GetNumActive() == self.capacity then
            return nil, false
        end

        local object = self:PopInactiveObject()
        local new = object == nil
        if new then
            object = self:CallCreate()

            --[[
                While pools don't necessarily need to only contain tables, support for other types
                has not been tested, and therefore isn't allowed until we can justify a use for them.
            ]]
            assert(type(object) == "table")

            --[[
                The reset function will error if forbidden actions are attempted insecurely,
                particularly in scenarios involving forbidden and protected frames. If an error
                is thrown, it will do so before we make any further modifications to this pool.

                Note this does create a potential for a dangling frame or region, but that is less of a
                concern than mutating the pool.
            ]]
            self:CallReset(object, new)
        end

        self:AddObject(object)
        return object, new
    end

    function PoolBaseMixin:Release(object, canFailToFindObject)
        local active = self:IsActive(object)

        if not canFailToFindObject then
            assertsafe(active, getObjectIsInvalidMsg, object, self)
        end

        if active then
            self:CallReset(object)

            self:ReclaimObject(object)
        end

        return active
    end

    function PoolBaseMixin:Dump()
        for index, object in self:EnumerateActive() do
            print(tostring(object))
        end
    end
end

local PoolMixin = CreateFromMixins(PoolBaseMixin)
do
    function PoolMixin:Init(createFunc, resetFunc, capacity)
        self.createFunc = createFunc
        self.resetFunc = resetFunc
        self.activeObjects = {}
        self.inactiveObjects = {}
        self.activeObjectCount = 0

        reserve(self, capacity)
    end

    function PoolMixin:CallReset(object, new)
        if not self.resetFunc then return end
        self.resetFunc(self, object, new)
    end

    function PoolMixin:CallCreate()
        -- The pool argument 'self' is passed only for addons already reliant on it.
        return self.createFunc(self)
    end

    function PoolMixin:PopInactiveObject()
        return tremove(self.inactiveObjects)
    end

    function PoolMixin:AddObject(object)
        local dummy = true
        self.activeObjects[object] = dummy
        self.activeObjectCount = self.activeObjectCount + 1
    end

    function PoolMixin:ReclaimObject(object)
        tinsert(self.inactiveObjects, object)
        self.activeObjects[object] = nil
        self.activeObjectCount = self.activeObjectCount - 1
    end

    function PoolMixin:ReleaseAll()
        for object in pairs(self.activeObjects) do
            self:Release(object)
        end
    end

    function PoolMixin:EnumerateActive()
        return pairs(self.activeObjects)
    end

    function PoolMixin:GetNextActive(current)
        return next(self.activeObjects, current)
    end

    function PoolMixin:IsActive(object)
        return self.activeObjects[object] ~= nil
    end

    function PoolMixin:GetNumActive()
        return self.activeObjectCount
    end
end


function Pool.New(createFunc, resetFunc, capacity)
    local pool = CreateFromMixins(PoolMixin)
    pool:Init(createFunc, resetFunc, capacity)
    return pool
end
