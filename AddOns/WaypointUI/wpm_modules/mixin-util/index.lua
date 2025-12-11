local env = select(2, ...)

local select = select
local pairs = pairs
local next = next
local rawset = rawset

local MixinUtil = env.WPM:New("wpm_modules/mixin-util")

function MixinUtil.Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        local k, v = next(mixin)
        while k do
            rawset(object, k, v)
            k, v = next(mixin, k)
        end
    end

    return object
end

function MixinUtil.CreateFromMixins(...)
    return MixinUtil.Mixin({}, ...)
end

function MixinUtil.CreateAndInitFromMixin(mixin, ...)
    local object = MixinUtil.Mixin({}, mixin)
    object:Init(...)
    return object
end
