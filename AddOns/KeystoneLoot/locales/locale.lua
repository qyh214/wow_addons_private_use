local AddonName, KeystoneLoot = ...;

KeystoneLoot.L = setmetatable({}, {
    __index = function(t, key)
        rawset(t, key, key);
        return key;
    end
});
