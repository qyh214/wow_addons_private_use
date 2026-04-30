---@diagnostic disable
-- Preydator Localization Bootstrap
-- Must load before all other Preydator files (listed first in .toc).
-- Creates PreydatorL global; any string not found falls back to its English key.

if not _G.PreydatorL then
    _G.PreydatorL = setmetatable({}, {
        __index = function(_, k) return k end,
    })
end
