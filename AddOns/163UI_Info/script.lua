--[=[
	SCRIPT
--]=]

local This, Private = ...;

local time = time;
local UnitExists = UnitExists;
local UnitIsPlayer = UnitIsPlayer;
local GetRealmID = GetRealmID;
local GetRealmName = GetRealmName;
local UnitName = UnitName;
local UnitClassBase = UnitClassBase;
local UnitRace = UnitRace;
local UnitLevel = UnitLevel;
local UnitFactionGroup = UnitFactionGroup;
local InCombatLockdown = InCombatLockdown;
local GetNumGroupMembers, GetRaidRosterInfo = GetNumGroupMembers, GetRaidRosterInfo;
local IsInRaid = IsInRaid;
local NewTimer = C_Timer.NewTimer;
----------------------------------------------------------------

local Frame = CreateFrame('FRAME');
Private.Frame = Frame;

Frame.GroupRosterList = {
	party = {},
	raid = {},
};
for i = 1, 4 do Frame.GroupRosterList.party[i] = 'party' .. i; end
for i = 1, 40 do Frame.GroupRosterList.raid[i] = 'raid' .. i; end

function Frame.SaveUnitInfo(Frame, unit)
	if UnitIsPlayer(unit) then
		local GUID = UnitGUID(unit);
		local name, realm = UnitName(unit);
		if realm == nil or realm == "" then
			realm = Frame.ThisRealm;
		end
		Frame.GlobalVar.HeyBro[GUID] = {
			realmName = realm,
			guid = GUID,
			name = UnitName(unit),
			class = UnitClassBase(unit),
			race = UnitRace(unit),
			level = UnitLevel(unit),
			faction = UnitFactionGroup(unit),
		};
		return true;
	end
end
function Frame.ADDON_LOADED(Frame, event, addon)
	if addon == This then
		Frame.loaded = true;
		Frame:UnregisterEvent("ADDON_LOADED");
		_G.DDPFGlobal = _G.DDPFGlobal or {  };
		Frame.GlobalVar = _G.DDPFGlobal;
	end
end
function Frame.PLAYER_LOGIN(Frame, event)
	if not Frame.loaded then
		Frame:OnEvent("ADDON_LOADED", This);
	end
	Frame.ThisRealm = GetRealmName();
	local GV = Frame.GlobalVar;
	GV.MyChar = GV.MyChar or {  };
	GV.HeyBro = GV.HeyBro or {  };
	local GUID = UnitGUID('player');
	GV.MyChar[GUID] = {
		loginTime = time(),
		realmID = GetRealmID(),
		realmName = Frame.ThisRealm,
		guid = GUID,
		name = UnitName('player'),
		class = UnitClassBase('player'),
		race = UnitRace('player'),
		level = UnitLevel('player'),
		faction = UnitFactionGroup('player'),
	};
	Frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	Frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	Frame:RegisterEvent("GROUP_ROSTER_UPDATE");
end
function Frame.PLAYER_TARGET_CHANGED(Frame, event)
	if not InCombatLockdown() then
		return Frame:SaveUnitInfo('target');
	end
end
function Frame.UPDATE_MOUSEOVER_UNIT(Frame, event)
	if not InCombatLockdown() then
		return Frame:SaveUnitInfo('mouseover');
	end
end
function Frame.DelaySaveGroupInfo()
	Frame.GroupTimer = nil;
	Frame.MarkToUpdateGroup = nil;
	local num = GetNumGroupMembers();
	local index = 1;
	local list = Frame.GroupRosterList[IsInRaid() and 'raid' or 'party'];
	local unit = list[index];
	while num > 0 and unit do
		if Frame:SaveUnitInfo(unit) then
			num = num - 1;
		end
		index = index + 1;
		unit = list[index];
	end
end
function Frame.GROUP_ROSTER_UPDATE(Frame, event)
	if InCombatLockdown() then
		Frame:RegisterEvent("PLAYER_REGEN_ENABLED");
		Frame.MarkToUpdateGroup = true;
	else
		if Frame.GroupTimer ~= nil then
			Frame.GroupTimer:Cancel();
		end
		Frame.GroupTimer = NewTimer(1.0, Frame.DelaySaveGroupInfo);
	end
end
function Frame.PLAYER_REGEN_ENABLED(Frame, event)
	Frame:UnregisterEvent("PLAYER_REGEN_ENABLED");
	if Frame.MarkToUpdateGroup then
		return Frame:GROUP_ROSTER_UPDATE("GROUP_ROSTER_UPDATE");
	end
end
function Frame.OnEvent(Frame, event, ...)
	if Frame[event] then
		return Frame[event](Frame, event, ...);
	end
end
function Frame.OnLoad(Frame)
	Frame:SetScript("OnEvent", Frame.OnEvent);
	Frame:RegisterEvent("ADDON_LOADED");
	if IsLoggedIn() then
		return Frame:OnEvent("PLAYER_LOGIN");
	else
		Frame:RegisterEvent("PLAYER_LOGIN");
	end
end

Frame:OnLoad();
