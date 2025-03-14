local ns = select(2, ...) ---@class ns @The addon namespace.

local locale = GetLocale()

local L = {
	__index = function(_, k)
		return format("[%s] %s", locale, tostring(k))
	end
}

---@class Locale

---@return Locale
function ns:NewLocale()
	return setmetatable({}, L)
end

---@param name1? string
---@param name2? string
---@param name3? string
function ns:IsSameLocale(name1, name2, name3)
	local l = GetLocale()
	return name1 == l or name2 == l or name3 == l
end
