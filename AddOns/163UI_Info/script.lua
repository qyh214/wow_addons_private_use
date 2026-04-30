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
	
	-- Clear the memory leak table if it exists
	if GV.HeyBro then
		GV.HeyBro = nil;
	end

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
