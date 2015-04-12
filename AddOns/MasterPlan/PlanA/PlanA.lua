local addonName, T = ...
local E, api, cdata = T.Evie, {}

local function gett(t, k, ...)
	if not k then
		return t
	elseif type(t[k]) ~= "table" then
		t[k] = {}
	end
	return gett(t[k], ...)
end

function E:ADDON_LOADED(addon)
	if addon ~= addonName then return end
	
	cdata = gett(_G, "MasterPlanAG", GetRealmName(), UnitName("player"))
	setmetatable(api, {__index={data=cdata}})
		
	return "remove"
end
function E:SHOW_LOOT_TOAST(rt, rl, _3, _4, _5, _6, source)
	if rt == "currency" and source == 10 and rl:match("currency:824") then
		cdata.lastCacheTime = time()
	end
end

MasterPlanA = api