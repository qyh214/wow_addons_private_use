---@class Private
local Private = select(2, ...)

---@param name string
---@param maybeRealm string
---@return ProviderProfileV2|nil
function Private.GetProfile(name, maybeRealm)
	local realm = Private.GetRealmOrDefault(maybeRealm)

	if realm == nil then
		return
	end

	local profile = Private.GetProviderProfile(name, realm)

	Private.Print(profile or {}, "loading profile for " .. name .. "-" .. realm)

	return profile
end
