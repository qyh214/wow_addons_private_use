local ns = select(2, ...) ---@type ns @The addon namespace.

local locale = GetLocale()

local L = {
	__index = function(_, k)
		return format("[%s] %s", locale, tostring(k))
	end
}

function ns:NewLocale()
	return setmetatable({}, L)
end

function ns:IsSameLocale(name1, name2, name3)
	local l = GetLocale()
	return name1 == l or name2 == l or name3 == l
end
