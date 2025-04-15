-- self == L
-- rawset(t, key, value)
-- Sets the value associated with a key in a table without invoking any metamethods
-- t - A table (table)
-- key - A key in the table (cannot be nil) (value)
-- value - New value to set for the key (value)
select(2, ...).L = setmetatable({
    ["WHISPER_TEMPLATE"] = "Hi! Can you craft [r] with your [p] skills? Will tip [f] for your service. Thanks!"
}, {
    __index = function(self, key)
        if (key ~= nil) then
           rawset(self, key, key)
           return key
        end
    end
})