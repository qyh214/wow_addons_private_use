
local _, ns = ...;

ns.language=GetLocale();
ns.classspec_locales = {};
ns.faction_locales = {};
ns.follower_locales = {};
ns.npc_locales = {};
ns.zone_locales = {};

ns.locale = setmetatable({},{__index=function(t,k)
	local v = tostring(k);
	rawset(t,k,v);
	return v;
end})

