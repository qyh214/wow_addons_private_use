
local addon, ns = ...;

local order,L = {
	"journal",
	--"ids",
	"minimap",
	"reset"
};

local cmdList = {
	journal = {
		desc = "Show/Hide journal frame",
		func = function() FollowerLocationInfo_ToggleJournal() end
	},
	--[[
	ids = {
		desc = "Show/Hide followerID in journal",
		func = function() FollowerLocationInfo_ToggleIDs() end
	},
	--]]
	minimap = {
		desc = "Show/Hide minimap button",
		func = function() FollowerLocationInfo_MinimapButton() end
	},
	reset = {
		desc = "Reset addon settings |cffff6666and automatically reloading the UI!|r",
		func = function()
			--FollowerLocationInfoDB = nil;
			ReloadUI();
		end
	},
};

local _print = function(...)
	local e = {"|cff00ff00 |||cffffff00",...};
	if #e>2 then
		tinsert(e,3,"|cff00ff00|||r");
	else
		e[1] = "|cff00ff00 |||cff44ffff";
		tinsert(e,"|r");
	end
	print(unpack(e));
end

SlashCmdList["FOLLOWERLOCATIONINFO"] = function(cmd)
	local cmd, arg = strsplit(" ", cmd, 2)
	L = FollowerLocationInfoData.Locale;

	if cmdList[cmd] then
		cmdList[cmd].func();
	else
		ns.print(L["Chat command usage"]);
		_print("/followerlocationinfo "..L["<command>"]);
		_print(L["or"].." /fli "..L["<command>"]);
		ns.print(L["Commands"]);
		for _, key in ipairs(order)do
			if cmdList[key] then
				_print(key,L[cmdList[key].desc]);
			end
		end
	end
end

SLASH_FOLLOWERLOCATIONINFO1 = "/fli";
SLASH_FOLLOWERLOCATIONINFO2 = "/followerlocationinfo";

--[=[
L["Show/Hide journal frame"]
L["Show/Hide followerID in journal"]
L["Show/Hide minimap button"]
L["Reset addon settings |cffff6666and automatically reloading the UI!|r"]
--]=]
