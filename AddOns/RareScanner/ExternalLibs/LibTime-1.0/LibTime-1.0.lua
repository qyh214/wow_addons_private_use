
--[[
Name: LibTime-1.0
Revision: $Revision: r41 $
Author: Hizuro (hizuro@gmx.net)
Description: A little library around date, time and GetGameTime and more...
Dependencies: LibStub
License: GPL v3
]]

local MAJOR, MINOR = "LibTime-1.0", tonumber((gsub("r41","r",""))) or 999;
local lib = LibStub:NewLibrary(MAJOR, MINOR);

if not lib then return; end

local GetGameTime, date, time, _G = GetGameTime, date, time, _G;
local RequestTimePlayed,strsplit,ipairs = RequestTimePlayed,strsplit,ipairs;
local tonumber,tinsert,unpack = tonumber,tinsert,unpack;
local hms,hm = "%02d:%02d:%02d","%02d:%02d";
local realmTime,minute = nil,nil;
local IsPlayerLoggedIn,IsPlayedTimeRequested = false,false;
local playedTotal, playedLevel, playedSession;
local realmTimeSyncTicker,chatFrames,UnregisterEvent,RegisterEvent
local events = {};

lib.countryLocalizedNames = {}; -- filled on end of the file

local countries = {};
local countryNames = {};
local countryList = {
	"Afghanistan;4.5;0","Alaska;-9;1","Arabian;3;0","Argentina;-3;0","Armenia;4;1","Australian Central;9.5;1","Australian Eastern;10;1",
	"AustralianWestern;8;0","Azerbaijan;4;1","Azores;-1;1","Bangladesh;6;0","Bhutan;6;0","Bolivia;-4;0","Brazil;-3;0","Brunei;8;0","Cape Verde;-1;0",
	"Central Africa;2;0","Central Brazilian;-4;1","Central European;1;1","Central Greenland;-3;1","Central Indonesian;8;0","Chamorro;10;0","Chile;-4;1",
	"China;8;0","Christmas Island;7;0","Chuuk;10;0","Cocos Islands;6.5;0","Colombia;-5;0","Cook Islands;-10;0","East Africa;3;0","Eastern;-5;1",
	"Eastern European;2;1","Eastern Indonesian;9;0","Eastern Kazakhstan;6;0","East Greenland;-1;1","East Timor;9;0","Ecuador;-5;0","Falkland Island;-4;0",
	"Fernando de Noronha;-2;0","Fiji;12;1","French Guiana;-3;0","Galapagos;-6;0","Georgia;4;0","Germany;1;1","Gilbert Island;12;0","Greenwich Mean;0;1",
	"Gulf;4;0","Guyana;-4;0","Hawaii;-10;1","Hovd;7;0","Indian;5.5;0","Indochina;7;0","Iran;3.5;1","Irkutsk;9;0","Israel;2;1","Japan;9;0",
	"Kaliningrad;3;0","Korea;9;0","Krasnoyarsk;8;0","Kyrgyzstan;5;0","Magadan;12;0","Malaysia;8;0","Maldives;5;0","Marshall Islands;12;0","Mauritius;4;0",
	"Moscow;4;0","Mountain;-7;1","Myanmar;6.5;0","Nauru;12;0","Nepal;5.75;0","New Caledonia;11;0","Newfoundland;-3.5;1","New Zealand;12;1","Niue;-11;0",
	"Norfolk;11.5;0","Omsk;7;0","Pacific;-8;1","Pakistan;5;0","Palau;9;0","Papua New Guinea;10;0","Paraguay;-4;1","Peru;-5;0","Philippine;8;0",
	"Pierre & Miquelon;-3;1","Ponape;11;0","Reunion;4;0","Seychelles;4;0","Singapore;8;0","Solomon Islands;11;0","South Africa;2;0","Sri Lanka;5.5;0",
	"Suriname;-3;0","Tahiti;-10;0","Tajikistan;5;0","Tokelau;13;0","Tonga;13;0","Turkmenistan;5;0","Tuvalu;12;0","Ulaanbaatar;8;0","Uruguay;-3;1",
	"US Central Standart Time (CST);-6;1","Uzbekistan;5;0","Vanuatu;11;0","Venezuela;-4.5;0","Vladivostok;11;0","Wallis & Futuna;12;0","West Africa;1;1",
	"Western European;0;1","Western Indonesian;7;0","Western Kazakhstan;5;0","West Samoa;13;1","Yakutsk;10;0","Yap;10;0","Yekaterinburg;6;0"
};


--[[ internal event and update functions ]]--

local function toggleChatFramesTimePlayedMsgEvent()
	if not UnregisterEvent then
		local mt = getmetatable(_G["ChatFrame1"]).__index;
		if mt and mt.UnregisterEvent then
			UnregisterEvent = mt.UnregisterEvent;
			RegisterEvent = mt.RegisterEvent;
		end
	end
	if not chatFrames then
		-- unregister TIME_PLAYED_MSG to hide played time message in chat
		chatFrames = {};
		for i=1, 10 do
			local frame = _G["ChatFrame"..i];
			if frame and frame.messageTypeList then
				for _, group in ipairs(frame.messageTypeList) do
					if group=="SYSTEM" then
						UnregisterEvent(frame,"TIME_PLAYED_MSG");
						tinsert(chatFrames,i);
					end
				end
			end
		end
	else
		-- re register event TIME_PLAYED_MSG
		for i=1, #chatFrames do
			if _G["ChatFrame"..chatFrames[i]] then
				RegisterEvent(_G["ChatFrame"..chatFrames[i]],"TIME_PLAYED_MSG");
			end
		end
		chatFrames = nil
	end
end

local function DoRequestTimePlayed()
	-- played time already known
	if playedTotal then
		return
	end
	-- disable played message output in chat windows
	toggleChatFramesTimePlayedMsgEvent();
	-- request /played if event PLAYER_LOGIN already fired
	if IsPlayerLoggedIn then
		RequestTimePlayed();
	end
end

local function realmTimeSyncTickerFunc()
	local hours, minutes, seconds = GetGameTime();
	if minute~=minutes then
		minute = nil;
		local t = date("*t");
		t.hour,t.min,t.sec = hours,minutes,0;
		realmTime = time() - time(t);
		realmTimeSyncTicker:Cancel();
	end
end

function events.PLAYER_LOGIN()
	for index,data in ipairs(countryList) do
		local name,shift,dst = strsplit(";",data);
		countries[index] = {name=lib.countryLocalizedNames[name] or name,timeshift=tonumber(shift),dst=dst==1};
		countryNames[index] = lib.countryLocalizedNames[name] or name;
	end
	countryList=nil;

	local hours, minutes, seconds = GetGameTime();
	playedSession = time();
	if tonumber(seconds) then
		-- YEAH! Surprise! GetGameTime returns time "with seconds"... [maybe in future? ^_^]
		lib.GetGameTime = GetGameTime;
	else
		minute = minutes;
		realmTimeSyncTicker = C_Timer.NewTicker(0.5,realmTimeSyncTickerFunc);
	end
	IsPlayerLoggedIn=true;
	if IsPlayedTimeRequested then
		DoRequestTimePlayed()
	end
end

function events.TIME_PLAYED_MSG(...)
	playedTotal, playedLevel = ...;
	if chatFrames and #chatFrames>0 then
		-- reenable played time messages in chat windows
		toggleChatFramesTimePlayedMsgEvent();
	end
	UIParent:UnregisterEvent("TIME_PLAYED_MSG");
end

UIParent:HookScript("OnEvent",function(self,event,...)
	if events[event] then
		events[event](...);
		events[event]=nil;
	end
end);

UIParent:RegisterEvent("TIME_PLAYED_MSG");


--[[ library functions ]]--
local function get_date(timeval,b24h,bUTC)
	local datestr = (bUTC and "!" or "") .. (b24h and "%H:%M:%S" or "%I:%M:%S:%p");
	local t = {strsplit(":",date(datestr,timeval))};
	return tonumber(t[1]),tonumber(t[2]),tonumber(t[3]), t[4];
end


--- GetGameTime
-- @param b24hours [bool]
-- @param inSeconds [bool]
-- @return hours, minutes, seconds, boolSecondsSynced
function lib.GetGameTime(b24hours,inSeconds)
	if realmTime then
		local t = time()-realmTime;
		if inSeconds==true then
			return t,(minute==nil);
		end
		local H,M,S,P = get_date(t,b24hours);
		return H,M,S,P,(minute==nil)
	end
	if inSeconds==true then
		return time();
	end
	return lib.GetLocalTime(b24hours);
end


--- GetLocalTime
-- @param b24hours [bool]
-- @return hours, minutes, seconds
function lib.GetLocalTime(b24hours)
	return get_date(nil,b24hours);
end


--- GetUTCTime
-- @param b24hours [bool]
-- @param inSeconds [bool]
-- @return hours, minutes, seconds
function lib.GetUTCTime(b24hours,inSeconds)
	if inSeconds==true then
		return time(date("!*t"));
	end
	return get_date(nil,b24hours,true);
end


--- GetCountryTime
-- @param country [string|number]
-- @param b24hours [bool]
-- @param inSeconds [bool]
-- @return hour, minute, second, country name
function lib.GetCountryTime(countryId,b24hours,inSeconds)
	assert(countryId and countries[countryId], "usage: <LibTime-1.0>.GetCountryTime(<iCountryId>[,<bInSeconds>])");
	local country = countries[countryId];
	local t = lib.GetUTCTime(true);
	local l = date("*t");
	if (l.isdst==true and country.dst==0) then
		t = t - 3600;
	elseif (l.isdst==false and country.dst==1) then
		t = t + 3600;
	end
	t = t+(3600*country.timeshift);
	if inSeconds==true then
		return t, country.name;
	end
	local H,M,S,P = get_date(t,b24hours);
	return H,M,S,P,country.name;
end


--- ListCountries - plain list of countries. table index corresponding with neccessary countryId in other functions of this library
-- @return [table]
function lib.iterateCountryList()
	return ipairs(countryNames);
end


--- GetPlayedTime - Get played time. Requires use of RequestPlayedTime.
-- @return playedTotal, playedLevel, playedSession
function lib.GetPlayedTime()
	local session = time()-playedSession;
	if (playedTotal) then
		return playedTotal+session, playedLevel+session, session;
	end
	return 0, 0, session;
end


--- RequestPlayedTime - Now it is required to request played time before get it.
-- @return nil
function lib.RequestPlayedTime()
	if playedTotal then
		return -- played time already known
	end
	-- request /played if event PLAYER_LOGIN already fired
	if IsPlayerLoggedIn then
		DoRequestTimePlayed();
	else -- wait on event PLAYER_LOGIN for request from client api
		IsPlayedTimeRequested = true;
	end
end


--- GetTimeString
-- @param name of time   <GameTime|LocalTime|UTCTime|CountryTime>
-- @param 24hours        [boolean] - optional, default = true
-- @param displaySeconds [boolean] - optional, default = false
-- @param countryId      [number]  - only for use with GetCountryTime
function lib.GetTimeString(name,b24hours,displaySeconds,countryId)
	assert(lib["Get"..name],"Usage: <LibTime-1.0>.GetTimeString(<GameTime|LocalTime|UTCTime|CountryTime>[,<b24hours>[,<bDisplaySeconds>[,<iCountryId>]]])");
	if b24hours==nil then
		b24hours = true;
	end
	local params = {b24hours};
	if countryId then
		tinsert(params,1,countryId);
	end
	local h,m,s,p,synced = lib["Get"..name](unpack(params));
	local suffix = p and " "..p or "";
	if (displaySeconds==true) then
		if name=="GameTime" and not synced then
			suffix = ":−−"..suffix;
		else
			return hms:format(h,m,s)..suffix;
		end
	end
	return hm:format(h,m)..suffix;
end


--- SuppressAllPlayedForSeconds - Deprecated!
function lib.SuppressAllPlayedForSeconds()
	print("LibTime-1.0:", " Warning. SuppressAllPlayedForSeconds function is deprecated. Will be removed soon.")
end


--- Localizations
-- Do you want to help localize this library?
-- https://legacy.curseforge.com/wow/addons/libtime-1-0/localization

-- [Info]:
-- I don't like it really but this localization was made with google translation.
-- Do you found wrong translations please go to the curseforge localization page and add the correct translation.
do
	local L = lib.countryLocalizedNames;
	if _G["LOCALE_deDE"] then
		L["Afghanistan"] = "Afghanistan"
		L["Alaska"] = "Alaska"
		L["Arabian"] = "arabisch"
		L["Argentina"] = "Argentinien"
		L["Armenia"] = "Armenien"
		L["Australian Central"] = "Australische Zentrale"
		L["Australian Eastern"] = "Australischer Osten"
		L["AustralianWestern"] = "Australischer Western"
		L["Azerbaijan"] = "Aserbaidschan"
		L["Azores"] = "Azoren"
		L["Bangladesh"] = "Bangladesch"
		L["Bhutan"] = "Bhutan"
		L["Bolivia"] = "Bolivien"
		L["Brazil"] = "Brasilien"
		L["Brunei"] = "Brunei"
		L["Cape Verde"] = "Kap Verde"
		L["Central Africa"] = "Zentralafrika"
		L["Central Brazilian"] = "Zentralbrasilianisch"
		L["Central European"] = "Mitteleuropäisch"
		L["Central Greenland"] = "Zentralgrönland"
		L["Central Indonesian"] = "Zentralindonesisch"
		L["Chamorro"] = "Chamorro"
		L["Chile"] = "Chile"
		L["China"] = "China"
		L["Christmas Island"] = "Weihnachtsinsel"
		L["Chuuk"] = "Chuuk"
		L["Cocos Islands"] = "Kokosinseln"
		L["Colombia"] = "Kolumbien"
		L["Cook Islands"] = "Cookinseln"
		L["East Africa"] = "Ostafrika"
		L["Eastern"] = "Östlich"
		L["Eastern European"] = "Osteuropäer"
		L["Eastern Indonesian"] = "Ostindonesisch"
		L["Eastern Kazakhstan"] = "Ostkasachstan"
		L["East Greenland"] = "Ostgrönland"
		L["East Timor"] = "Osttimor"
		L["Ecuador"] = "Ecuador"
		L["Falkland Island"] = "Falklandinsel"
		L["Fernando de Noronha"] = "Fernando de Noronha"
		L["Fiji"] = "Fidschi"
		L["French Guiana"] = "Französisch-Guayana"
		L["Galapagos"] = "Galapagos"
		L["Georgia"] = "Georgia"
		L["Germany"] = "Deutschland"
		L["Gilbert Island"] = "Gilbert-Insel"
		L["Greenwich Mean"] = "Greenwich-Mittelwert"
		L["Gulf"] = "Golf"
		L["Guyana"] = "Guyana"
		L["Hawaii"] = "Hawaii"
		L["Hovd"] = "Hovd"
		L["Indian"] = "indisch"
		L["Indochina"] = "Indochina"
		L["Iran"] = "Iran"
		L["Irkutsk"] = "Irkutsk"
		L["Israel"] = "Israel"
		L["Japan"] = "Japan"
		L["Kaliningrad"] = "Kaliningrad"
		L["Korea"] = "Korea"
		L["Krasnoyarsk"] = "Krasnojarsk"
		L["Kyrgyzstan"] = "Kirgisistan"
		L["Magadan"] = "Magadan"
		L["Malaysia"] = "Malaysia"
		L["Maldives"] = "Malediven"
		L["Marshall Islands"] = "Marshallinseln"
		L["Mauritius"] = "Mauritius"
		L["Moscow"] = "Moskau"
		L["Mountain"] = "Berg"
		L["Myanmar"] = "Myanmar"
		L["Nauru"] = "Nauru"
		L["Nepal"] = "Nepal"
		L["New Caledonia"] = "Neu-Kaledonien"
		L["Newfoundland"] = "Neufundland"
		L["New Zealand"] = "Neuseeland"
		L["Niue"] = "Niue"
		L["Norfolk"] = "Norfolk"
		L["Omsk"] = "Omsk"
		L["Pacific"] = "Pazifik"
		L["Pakistan"] = "Pakistan"
		L["Palau"] = "Palau"
		L["Papua New Guinea"] = "Papua Neu-Guinea"
		L["Paraguay"] = "Paraguay"
		L["Peru"] = "Peru"
		L["Philippine"] = "Philippinisch"
		L["Pierre & Miquelon"] = "Pierre und Miquelon"
		L["Ponape"] = "Ponape"
		L["Reunion"] = "Wiedervereinigung"
		L["Seychelles"] = "Seychellen"
		L["Singapore"] = "Singapur"
		L["Solomon Islands"] = "Salomon-Inseln"
		L["South Africa"] = "Südafrika"
		L["Sri Lanka"] = "Sri Lanka"
		L["Suriname"] = "Surinam"
		L["Tahiti"] = "Tahiti"
		L["Tajikistan"] = "Tadschikistan"
		L["Tokelau"] = "Tokelau"
		L["Tonga"] = "Tonga"
		L["Turkmenistan"] = "Turkmenistan"
		L["Tuvalu"] = "Tuvalu"
		L["Ulaanbaatar"] = "Ulaanbaatar"
		L["Uruguay"] = "Uruguay"
		L["US Central Standart Time (CST)"] = "US Central Standard Time (CST)"
		L["Uzbekistan"] = "Usbekistan"
		L["Vanuatu"] = "Vanuatu"
		L["Venezuela"] = "Venezuela"
		L["Vladivostok"] = "Wladiwostok"
		L["Wallis & Futuna"] = "Wallis und Futuna"
		L["West Africa"] = "Westafrika"
		L["Western European"] = "Westeuropäische"
		L["Western Indonesian"] = "Westindonesisch"
		L["Western Kazakhstan"] = "Westkasachstan"
		L["West Samoa"] = "West-Samoa"
		L["Yakutsk"] = "Jakutsk"
		L["Yap"] = "Kläffen"
		L["Yekaterinburg"] = "Jekaterinburg"
	elseif _G["LOCALE_esES"] or _G["LOCALE_esMX"] then
		L["Afghanistan"] = "Afganistán"
		L["Alaska"] = "Alaska"
		L["Arabian"] = "Árabe"
		L["Argentina"] = "Argentina"
		L["Armenia"] = "Armenia"
		L["Australian Central"] = "Australia Central"
		L["Australian Eastern"] = "Australia Oriental"
		L["Australian Western"] = "Australia Occidental"
		L["Azerbaijan"] = "Azerbaiyán"
		L["Azores"] = "Azores"
		L["Bangladesh"] = "Bangladesh"
		L["Bhutan"] = "Bután"
		L["Bolivia"] = "Bolivia"
		L["Brazil"] = "Brasil"
		L["Brunei"] = "Brunéi"
		L["Cape Verde"] = "Cabo Verde"
		L["Central Africa"] = "África Central"
		L["Central Brazilian"] = "Brasil Central"
		L["Central European"] = "Europa Central"
		L["Central Greenland"] = "Groenlandia Central"
		L["Central Indonesian"] = "Indonesia Central"
		L["Chamorro"] = "Chamorro"
		L["Chile"] = "Chile"
		L["China"] = "China"
		L["Christmas Island"] = "Isla de Navidad"
		L["Chuuk"] = "Chuuk"
		L["Cocos Islands"] = "Islas Cocos"
		L["Colombia"] = "Colombia"
		L["Cook Islands"] = "Islas Cook"
		L["East Africa"] = "África Oriental"
		L["East Greenland"] = "Groenlandia Oriental"
		L["East Timor"] = "Timor Oriental"
		L["Eastern"] = "Oriental"
		L["Eastern European"] = "Europa Oriental"
		L["Eastern Indonesian"] = "Indonesia Oriental"
		L["Eastern Kazakhstan"] = "Kazajistán Oriental"
		L["Ecuador"] = "Ecuador"
		L["Falkland Island"] = "Islas Malvinas"
		L["Fernando de Noronha"] = "Fernando de Noronha"
		L["Fiji"] = "Fiyi"
		L["French Guiana"] = "Guayana Francesa"
		L["Galapagos"] = "Galápagos"
		L["Georgia"] = "Georgia"
		L["Gilbert Island"] = "Kiribati"
		L["Greenwich Mean"] = "Meridiano de Greenwich"
		L["Gulf"] = "Golfo"
		L["Guyana"] = "Guyana"
		L["Hawaii"] = "Hawái"
		L["Hovd"] = "Hovd"
		L["Indian"] = "India"
		L["Indochina"] = "Indochina"
		L["Iran"] = "Irán"
		L["Irkutsk"] = "Irkutsk"
		L["Israel"] = "Israel"
		L["Japan"] = "Japón"
		L["Kaliningrad"] = "Kaliningrado"
		L["Korea"] = "Corea"
		L["Krasnoyarsk"] = "Krasnoyarsk"
		L["Kyrgyzstan"] = "Kirguistán"
		L["Magadan"] = "Magadán"
		L["Malaysia"] = "Malasia"
		L["Maldives"] = "Maldivas"
		L["Marshall Islands"] = "Islas Marshall"
		L["Mauritius"] = "Mauricio"
		L["Moscow"] = "Moscú"
		L["Mountain"] = "Mountain"
		L["Myanmar"] = "Myanmar"
		L["Nauru"] = "Nauru"
		L["Nepal"] = "Nepal"
		L["New Caledonia"] = "Nueva Caledonia"
		L["New Zealand"] = "Nueva Zelanda"
		L["Newfoundland"] = "Terranova y Labrador"
		L["Niue"] = "Niue"
		L["Norfolk"] = "Norfolk"
		L["Omsk"] = "Omsk"
		L["Pacific"] = "Pacífico"
		L["Pakistan"] = "Pakistán"
		L["Palau"] = "Palaos"
		L["Papua New Guinea"] = "Papúa Nueva Guinea"
		L["Paraguay"] = "Paraguay"
		L["Peru"] = "Perú"
		L["Philippine"] = "Filipinas"
		L["Pierre & Miquelon"] = "San Pedro y Miquelón"
		L["Ponape"] = "Ponapé"
		L["Reunion"] = "Reunión"
		L["Seychelles"] = "Seychelles"
		L["Singapore"] = "Singapur"
		L["Solomon Islands"] = "Islas Salomón"
		L["South Africa"] = "Sudáfrica"
		L["Sri Lanka"] = "Sri Lanka"
		L["Suriname"] = "Surinam"
		L["Tahiti"] = "Tahití"
		L["Tajikistan"] = "Tayikistán"
		L["Tokelau"] = "Tokelau"
		L["Tonga"] = "Tonga"
		L["Turkmenistan"] = "Turkmenistán"
		L["Tuvalu"] = "Tuvalu"
		L["Ulaanbaatar"] = "Ulán Bator"
		L["Uruguay"] = "Uruguay"
		--L["US Central Standart Time (CST)"] = "EE.UU. Hora Estándar Central (CST)"
		L["Uzbekistan"] = "Uzbekistán"
		L["Vanuatu"] = "Vanuatu"
		L["Venezuela"] = "Venezuela"
		L["Vladivostok"] = "Vladivostok"
		L["Wallis & Futuna"] = "Wallis y Futuna"
		L["West Africa"] = "África Occidental"
		L["West Samoa"] = "Samoa Occidental"
		L["Western European"] = "Europa Occidental"
		L["Western Indonesian"] = "Indonesia Occidental"
		L["Western Kazakhstan"] = "Kazajistán Occidental"
		L["Yakutsk"] = "Yakutsk"
		L["Yap"] = "Yap"
		L["Yekaterinburg"] = "Ekaterimburgo"
	elseif _G["LOCALE_frFR"] then
		L["Afghanistan"] = "Afghanistan"
		L["Alaska"] = "Alaska"
		L["Arabian"] = "arabe"
		L["Argentina"] = "Argentine"
		L["Armenia"] = "Arménie"
		L["Australian Central"] = "Centre australien"
		L["Australian Eastern"] = "Est australien"
		L["AustralianWestern"] = "AustralienWestern"
		L["Azerbaijan"] = "Azerbaïdjan"
		L["Azores"] = "Açores"
		L["Bangladesh"] = "Bengladesh"
		L["Bhutan"] = "Bhoutan"
		L["Bolivia"] = "Bolivie"
		L["Brazil"] = "Brésil"
		L["Brunei"] = "Brunéi"
		L["Cape Verde"] = "Cap-Vert"
		L["Central Africa"] = "Afrique centrale"
		L["Central Brazilian"] = "Centre du Brésil"
		L["Central European"] = "Europe centrale"
		L["Central Greenland"] = "Centre du Groenland"
		L["Central Indonesian"] = "Indonésien central"
		L["Chamorro"] = "Chamorro"
		L["Chile"] = "Chili"
		L["China"] = "Chine"
		L["Christmas Island"] = "L'île de noël"
		L["Chuuk"] = "Chuuk"
		L["Cocos Islands"] = "Îles Cocos"
		L["Colombia"] = "Colombie"
		L["Cook Islands"] = "les Îles Cook"
		L["East Africa"] = "Afrique de l'Est"
		L["Eastern"] = "Est"
		L["Eastern European"] = "européen de l'Est"
		L["Eastern Indonesian"] = "Indonésien oriental"
		L["Eastern Kazakhstan"] = "Kazakhstan oriental"
		L["East Greenland"] = "Est du Groenland"
		L["East Timor"] = "Timor oriental"
		L["Ecuador"] = "Equateur"
		L["Falkland Island"] = "Île Falkland"
		L["Fernando de Noronha"] = "Ferdinand de Noronha"
		L["Fiji"] = "Fidji"
		L["French Guiana"] = "Guyane Française"
		L["Galapagos"] = "Galapagos"
		L["Georgia"] = "Géorgie"
		L["Germany"] = "Allemagne"
		L["Gilbert Island"] = "Île Gilbert"
		L["Greenwich Mean"] = "Moyenne de Greenwich"
		L["Gulf"] = "Golfe"
		L["Guyana"] = "Guyane"
		L["Hawaii"] = "Hawaii"
		L["Hovd"] = "Hovd"
		L["Indian"] = "Indien"
		L["Indochina"] = "Indochine"
		L["Iran"] = "L'Iran"
		L["Irkutsk"] = "Irkoutsk"
		L["Israel"] = "Israël"
		L["Japan"] = "Japon"
		L["Kaliningrad"] = "Kaliningrad"
		L["Korea"] = "Corée"
		L["Krasnoyarsk"] = "Krasnoïarsk"
		L["Kyrgyzstan"] = "Kirghizistan"
		L["Magadan"] = "Magadan"
		L["Malaysia"] = "Malaisie"
		L["Maldives"] = "Maldives"
		L["Marshall Islands"] = "Iles Marshall"
		L["Mauritius"] = "Maurice"
		L["Moscow"] = "Moscou"
		L["Mountain"] = "Montagne"
		L["Myanmar"] = "Birmanie"
		L["Nauru"] = "Nauru"
		L["Nepal"] = "Népal"
		L["New Caledonia"] = "Nouvelle Calédonie"
		L["Newfoundland"] = "Terre-Neuve"
		L["New Zealand"] = "Nouvelle-Zélande"
		L["Niue"] = "Niué"
		L["Norfolk"] = "Norfolk"
		L["Omsk"] = "Omsk"
		L["Pacific"] = "Pacifique"
		L["Pakistan"] = "Pakistan"
		L["Palau"] = "Palaos"
		L["Papua New Guinea"] = "Papouasie Nouvelle Guinée"
		L["Paraguay"] = "Paraguay"
		L["Peru"] = "Pérou"
		L["Philippine"] = "Philippine"
		L["Pierre & Miquelon"] = "Pierre-et-Miquelon"
		L["Ponape"] = "Ponapé"
		L["Reunion"] = "Réunion"
		L["Seychelles"] = "les Seychelles"
		L["Singapore"] = "Singapour"
		L["Solomon Islands"] = "Les îles Salomon"
		L["South Africa"] = "Afrique du Sud"
		L["Sri Lanka"] = "Sri Lanka"
		L["Suriname"] = "Suriname"
		L["Tahiti"] = "Tahiti"
		L["Tajikistan"] = "Tadjikistan"
		L["Tokelau"] = "Tokélaou"
		L["Tonga"] = "Tonga"
		L["Turkmenistan"] = "Turkménistan"
		L["Tuvalu"] = "Tuvalu"
		L["Ulaanbaatar"] = "Oulan-Bator"
		L["Uruguay"] = "Uruguay"
		--L["US Central Standart Time (CST)"] = "Heure normale du centre des États-Unis (CST)"
		L["Uzbekistan"] = "Ouzbékistan"
		L["Vanuatu"] = "Vanuatu"
		L["Venezuela"] = "Venezuela"
		L["Vladivostok"] = "Vladivostok"
		L["Wallis & Futuna"] = "Wallis et Futuna"
		L["West Africa"] = "Afrique de l'Ouest"
		L["Western European"] = "européen de l'Ouest"
		L["Western Indonesian"] = "Indonésien occidental"
		L["Western Kazakhstan"] = "Kazakhstan occidental"
		L["West Samoa"] = "Samoa occidentales"
		L["Yakutsk"] = "Iakoutsk"
		L["Yap"] = "Japper"
		L["Yekaterinburg"] = "Iekaterinbourg"
	elseif _G["LOCALE_itIT"] then
		L["Afghanistan"] = "Afghanistan"
		L["Alaska"] = "Alaska"
		L["Arabian"] = "arabo"
		L["Argentina"] = "Argentina"
		L["Armenia"] = "Armenia"
		L["Australian Central"] = "centrale australiano"
		L["Australian Eastern"] = "Orientale australiano"
		L["AustralianWestern"] = "AustralianWestern"
		L["Azerbaijan"] = "Azerbaigian"
		L["Azores"] = "Azzorre"
		L["Bangladesh"] = "Bangladesh"
		L["Bhutan"] = "Bhutan"
		L["Bolivia"] = "Bolivia"
		L["Brazil"] = "Brasile"
		L["Brunei"] = "Brunei"
		L["Cape Verde"] = "capo Verde"
		L["Central Africa"] = "Africa centrale"
		L["Central Brazilian"] = "centrale brasiliana"
		L["Central European"] = "centroeuropeo"
		L["Central Greenland"] = "Groenlandia centrale"
		L["Central Indonesian"] = "Indonesiano centrale"
		L["Chamorro"] = "Camorro"
		L["Chile"] = "Chile"
		L["China"] = "Cina"
		L["Christmas Island"] = "Isola di Natale"
		L["Chuuk"] = "Chuuk"
		L["Cocos Islands"] = "Isole Cocco"
		L["Colombia"] = "Colombia"
		L["Cook Islands"] = "Isole Cook"
		L["East Africa"] = "Africa dell'est"
		L["Eastern"] = "Orientale"
		L["Eastern European"] = "est europeo"
		L["Eastern Indonesian"] = "indonesiano orientale"
		L["Eastern Kazakhstan"] = "Kazakistan orientale"
		L["East Greenland"] = "Groenlandia orientale"
		L["East Timor"] = "Timor Est"
		L["Ecuador"] = "Ecuador"
		L["Falkland Island"] = "Isole Falkland"
		L["Fernando de Noronha"] = "Fernando de Noronha"
		L["Fiji"] = "Figi"
		L["French Guiana"] = "Guiana francese"
		L["Galapagos"] = "Galapagos"
		L["Georgia"] = "Georgia"
		L["Germany"] = "Germania"
		L["Gilbert Island"] = "Isola Gilbert"
		L["Greenwich Mean"] = "Media di Greenwich"
		L["Gulf"] = "Golfo"
		L["Guyana"] = "Guyana"
		L["Hawaii"] = "Hawaii"
		L["Hovd"] = "Hovd"
		L["Indian"] = "indiano"
		L["Indochina"] = "Indocina"
		L["Iran"] = "Iran"
		L["Irkutsk"] = "Irkutsk"
		L["Israel"] = "Israele"
		L["Japan"] = "Giappone"
		L["Kaliningrad"] = "Kaliningrad"
		L["Korea"] = "Corea"
		L["Krasnoyarsk"] = "Krasnojarsk"
		L["Kyrgyzstan"] = "Kirghizistan"
		L["Magadan"] = "Magadan"
		L["Malaysia"] = "Malaysia"
		L["Maldives"] = "Maldive"
		L["Marshall Islands"] = "Isole Marshall"
		L["Mauritius"] = "Maurizio"
		L["Moscow"] = "Mosca"
		L["Mountain"] = "Montagna"
		L["Myanmar"] = "Birmania"
		L["Nauru"] = "Nauru"
		L["Nepal"] = "Nepal"
		L["New Caledonia"] = "Nuova Caledonia"
		L["Newfoundland"] = "Terranova"
		L["New Zealand"] = "Nuova Zelanda"
		L["Niue"] = "Niue"
		L["Norfolk"] = "Norfolk"
		L["Omsk"] = "Omsk"
		L["Pacific"] = "Pacifico"
		L["Pakistan"] = "Pakistan"
		L["Palau"] = "Palau"
		L["Papua New Guinea"] = "Papua Nuova Guinea"
		L["Paraguay"] = "Paraguay"
		L["Peru"] = "Perù"
		L["Philippine"] = "filippino"
		L["Pierre & Miquelon"] = "Pierre & Miquelon"
		L["Ponape"] = "Ponape"
		L["Reunion"] = "Riunione"
		L["Seychelles"] = "Seychelles"
		L["Singapore"] = "Singapore"
		L["Solomon Islands"] = "Isole Salomone"
		L["South Africa"] = "Sud Africa"
		L["Sri Lanka"] = "Sri Lanka"
		L["Suriname"] = "Suriname"
		L["Tahiti"] = "Tahiti"
		L["Tajikistan"] = "Tagikistan"
		L["Tokelau"] = "Tokelau"
		L["Tonga"] = "Tonga"
		L["Turkmenistan"] = "Turkmenistan"
		L["Tuvalu"] = "Tuvalù"
		L["Ulaanbaatar"] = "Ulan Bator"
		L["Uruguay"] = "Uruguay"
		--L["US Central Standart Time (CST)"] = "Ora standard centrale degli Stati Uniti (CST)"
		L["Uzbekistan"] = "Uzbekistan"
		L["Vanuatu"] = "Vanuatu"
		L["Venezuela"] = "Venezuela"
		L["Vladivostok"] = "Vladivostok"
		L["Wallis & Futuna"] = "Wallis e Futuna"
		L["West Africa"] = "Africa occidentale"
		L["Western European"] = "Europa occidentale"
		L["Western Indonesian"] = "Indonesiano occidentale"
		L["Western Kazakhstan"] = "Kazakistan occidentale"
		L["West Samoa"] = "Samoa occidentali"
		L["Yakutsk"] = "Jakutsk"
		L["Yap"] = "Già"
		L["Yekaterinburg"] = "Ekaterinburg"
	elseif _G["LOCALE_koKR"] then
		L["Afghanistan"] = "아프가니스탄"
		L["Alaska"] = "알래스카"
		L["Arabian"] = "아라비아 사람"
		L["Argentina"] = "아르헨티나"
		L["Armenia"] = "아르메니아"
		L["Australian Central"] = "호주 중부"
		L["Australian Eastern"] = "호주 동부"
		L["AustralianWestern"] = "호주서부"
		L["Azerbaijan"] = "아제르바이잔"
		L["Azores"] = "아조레스"
		L["Bangladesh"] = "방글라데시"
		L["Bhutan"] = "부탄"
		L["Bolivia"] = "볼리비아"
		L["Brazil"] = "브라질"
		L["Brunei"] = "브루나이"
		L["Cape Verde"] = "카보베르데"
		L["Central Africa"] = "중앙아프리카"
		L["Central Brazilian"] = "중앙 브라질"
		L["Central European"] = "중앙 유럽"
		L["Central Greenland"] = "중앙 그린란드"
		L["Central Indonesian"] = "중부 인도네시아"
		L["Chamorro"] = "차모로어"
		L["Chile"] = "칠레"
		L["China"] = "중국"
		L["Christmas Island"] = "크리스마스 섬"
		L["Chuuk"] = "축"
		L["Cocos Islands"] = "코코스 제도"
		L["Colombia"] = "콜롬비아"
		L["Cook Islands"] = "쿡 제도"
		L["East Africa"] = "동 아프리카"
		L["Eastern"] = "동부"
		L["Eastern European"] = "동유럽"
		L["Eastern Indonesian"] = "동부 인도네시아어"
		L["Eastern Kazakhstan"] = "카자흐스탄 동부"
		L["East Greenland"] = "이스트 그린란드"
		L["East Timor"] = "동 티모르"
		L["Ecuador"] = "에콰도르"
		L["Falkland Island"] = "포클랜드 섬"
		L["Fernando de Noronha"] = "페르난도 데 노로냐"
		L["Fiji"] = "피지"
		L["French Guiana"] = "프랑스령 기아나"
		L["Galapagos"] = "갈라파고스"
		L["Georgia"] = "그루지야"
		L["Germany"] = "독일"
		L["Gilbert Island"] = "길버트 섬"
		L["Greenwich Mean"] = "그리니치 평균"
		L["Gulf"] = "만"
		L["Guyana"] = "가이아나"
		L["Hawaii"] = "하와이"
		L["Hovd"] = "호브드"
		L["Indian"] = "인도 사람"
		L["Indochina"] = "인도차이나"
		L["Iran"] = "이란"
		L["Irkutsk"] = "이르쿠츠크"
		L["Israel"] = "이스라엘"
		L["Japan"] = "일본"
		L["Kaliningrad"] = "칼리닌그라드"
		L["Korea"] = "한국"
		L["Krasnoyarsk"] = "크라스노야르스크"
		L["Kyrgyzstan"] = "키르기스스탄"
		L["Magadan"] = "마가단"
		L["Malaysia"] = "말레이시아"
		L["Maldives"] = "몰디브"
		L["Marshall Islands"] = "마셜 제도"
		L["Mauritius"] = "모리셔스"
		L["Moscow"] = "모스크바"
		L["Mountain"] = "산"
		L["Myanmar"] = "미얀마"
		L["Nauru"] = "나우루"
		L["Nepal"] = "네팔"
		L["New Caledonia"] = "뉴 칼레도니아"
		L["Newfoundland"] = "뉴펀들랜드"
		L["New Zealand"] = "뉴질랜드"
		L["Niue"] = "니우에"
		L["Norfolk"] = "노퍽"
		L["Omsk"] = "옴스크"
		L["Pacific"] = "태평양"
		L["Pakistan"] = "파키스탄"
		L["Palau"] = "팔라우"
		L["Papua New Guinea"] = "파푸아 뉴기니"
		L["Paraguay"] = "파라과이"
		L["Peru"] = "페루"
		L["Philippine"] = "필리핀"
		L["Pierre & Miquelon"] = "피에르 앤 미클롱"
		L["Ponape"] = "포나페"
		L["Reunion"] = "재결합"
		L["Seychelles"] = "세이셸"
		L["Singapore"] = "싱가포르"
		L["Solomon Islands"] = "솔로몬 제도"
		L["South Africa"] = "남아프리카"
		L["Sri Lanka"] = "스리랑카"
		L["Suriname"] = "수리남"
		L["Tahiti"] = "타히티"
		L["Tajikistan"] = "타지키스탄"
		L["Tokelau"] = "토켈라우"
		L["Tonga"] = "통가"
		L["Turkmenistan"] = "투르크메니스탄"
		L["Tuvalu"] = "투발루"
		L["Ulaanbaatar"] = "울란바토르"
		L["Uruguay"] = "우루과이"
		--L["US Central Standart Time (CST)"] = "미국 중부 표준시(CST)"
		L["Uzbekistan"] = "우즈베키스탄"
		L["Vanuatu"] = "바누아투"
		L["Venezuela"] = "베네수엘라"
		L["Vladivostok"] = "블라디보스토크"
		L["Wallis & Futuna"] = "월리스 푸투나"
		L["West Africa"] = "서 아프리카"
		L["Western European"] = "서유럽"
		L["Western Indonesian"] = "서부 인도네시아어"
		L["Western Kazakhstan"] = "서부 카자흐스탄"
		L["West Samoa"] = "서사모아"
		L["Yakutsk"] = "야쿠츠크"
		L["Yap"] = "얍"
		L["Yekaterinburg"] = "예 카테 린 부르크"
	elseif _G["LOCALE_ptBR"] or _G["LOCALE_ptPT"] then
		L["Afghanistan"] = "Afeganistão"
		L["Alaska"] = "Alasca"
		L["Arabian"] = "árabe"
		L["Argentina"] = "Argentina"
		L["Armenia"] = "Armênia"
		L["Australian Central"] = "Austrália Central"
		L["Australian Eastern"] = "leste australiano"
		L["AustralianWestern"] = "australiano ocidental"
		L["Azerbaijan"] = "Azerbaijão"
		L["Azores"] = "Açores"
		L["Bangladesh"] = "Bangladesh"
		L["Bhutan"] = "Butão"
		L["Bolivia"] = "Bolívia"
		L["Brazil"] = "Brasil"
		L["Brunei"] = "Brunei"
		L["Cape Verde"] = "cabo Verde"
		L["Central Africa"] = "África Central"
		L["Central Brazilian"] = "Brasil Central"
		L["Central European"] = "centro-europeu"
		L["Central Greenland"] = "Groenlândia Central"
		L["Central Indonesian"] = "indonésio central"
		L["Chamorro"] = "Chamorro"
		L["Chile"] = "Chile"
		L["China"] = "China"
		L["Christmas Island"] = "Ilha do Natal"
		L["Chuuk"] = "Chuuk"
		L["Cocos Islands"] = "Ilhas Cocos"
		L["Colombia"] = "Colômbia"
		L["Cook Islands"] = "Ilhas Cook"
		L["East Africa"] = "este de África"
		L["Eastern"] = "Oriental"
		L["Eastern European"] = "leste Europeu"
		L["Eastern Indonesian"] = "leste indonésio"
		L["Eastern Kazakhstan"] = "Leste do Cazaquistão"
		L["East Greenland"] = "Leste da Groenlândia"
		L["East Timor"] = "Timor Leste"
		L["Ecuador"] = "Equador"
		L["Falkland Island"] = "Ilha Malvinas"
		L["Fernando de Noronha"] = "Fernando de Noronha"
		L["Fiji"] = "Fiji"
		L["French Guiana"] = "Guiana Francesa"
		L["Galapagos"] = "Galápagos"
		L["Georgia"] = "Geórgia"
		L["Germany"] = "Alemanha"
		L["Gilbert Island"] = "Ilha Gilbert"
		L["Greenwich Mean"] = "Média de Greenwich"
		L["Gulf"] = "Golfo"
		L["Guyana"] = "Guiana"
		L["Hawaii"] = "Havaí"
		L["Hovd"] = "Hovd"
		L["Indian"] = "indiano"
		L["Indochina"] = "Indochina"
		L["Iran"] = "Irã"
		L["Irkutsk"] = "Irkutsk"
		L["Israel"] = "Israel"
		L["Japan"] = "Japão"
		L["Kaliningrad"] = "Kaliningrado"
		L["Korea"] = "Coréia"
		L["Krasnoyarsk"] = "Krasnoyarsk"
		L["Kyrgyzstan"] = "Quirguistão"
		L["Magadan"] = "Magadan"
		L["Malaysia"] = "Malásia"
		L["Maldives"] = "Maldivas"
		L["Marshall Islands"] = "Ilhas Marshall"
		L["Mauritius"] = "maurício"
		L["Moscow"] = "Moscou"
		L["Mountain"] = "Montanha"
		L["Myanmar"] = "Mianmar"
		L["Nauru"] = "Nauru"
		L["Nepal"] = "Nepal"
		L["New Caledonia"] = "Nova Caledônia"
		L["Newfoundland"] = "Terra Nova"
		L["New Zealand"] = "Nova Zelândia"
		L["Niue"] = "Niue"
		L["Norfolk"] = "Norfolk"
		L["Omsk"] = "Omsk"
		L["Pacific"] = "Pacífico"
		L["Pakistan"] = "Paquistão"
		L["Palau"] = "Palau"
		L["Papua New Guinea"] = "Papua Nova Guiné"
		L["Paraguay"] = "Paraguai"
		L["Peru"] = "Peru"
		L["Philippine"] = "filipino"
		L["Pierre & Miquelon"] = "Pierre & Miquelon"
		L["Ponape"] = "Ponape"
		L["Reunion"] = "Reunião"
		L["Seychelles"] = "Seychelles"
		L["Singapore"] = "Cingapura"
		L["Solomon Islands"] = "Ilhas Salomão"
		L["South Africa"] = "África do Sul"
		L["Sri Lanka"] = "Sri Lanka"
		L["Suriname"] = "Suriname"
		L["Tahiti"] = "Taiti"
		L["Tajikistan"] = "Tadjiquistão"
		L["Tokelau"] = "Toquelau"
		L["Tonga"] = "Tonga"
		L["Turkmenistan"] = "Turquemenistão"
		L["Tuvalu"] = "Tuvalu"
		L["Ulaanbaatar"] = "Ulaanbaatar"
		L["Uruguay"] = "Uruguai"
		--L["US Central Standart Time (CST)"] = "Horário Padrão Central dos EUA (CST)"
		L["Uzbekistan"] = "Uzbequistão"
		L["Vanuatu"] = "Vanuatu"
		L["Venezuela"] = "Venezuela"
		L["Vladivostok"] = "Vladivostok"
		L["Wallis & Futuna"] = "Wallis & Futuna"
		L["West Africa"] = "África Ocidental"
		L["Western European"] = "Europeu ocidental"
		L["Western Indonesian"] = "indonésio ocidental"
		L["Western Kazakhstan"] = "Cazaquistão Ocidental"
		L["West Samoa"] = "Samoa Ocidental"
		L["Yakutsk"] = "Iakutsk"
		L["Yap"] = "Yap"
		L["Yekaterinburg"] = "Ecaterimburgo"
	elseif _G["LOCALE_ruRU"] then
		L["Afghanistan"] = "Афганистан"
		L["Alaska"] = "Аляска"
		L["Arabian"] = "арабский"
		L["Argentina"] = "Аргентина"
		L["Armenia"] = "Армения"
		L["Australian Central"] = "Центральная Австралия"
		L["Australian Eastern"] = "Австралийский восточный"
		L["AustralianWestern"] = "австралийский вестерн"
		L["Azerbaijan"] = "Азербайджан"
		L["Azores"] = "Азорские острова"
		L["Bangladesh"] = "Бангладеш"
		L["Bhutan"] = "Бутан"
		L["Bolivia"] = "Боливия"
		L["Brazil"] = "Бразилия"
		L["Brunei"] = "Бруней"
		L["Cape Verde"] = "Кабо-Верде"
		L["Central Africa"] = "Центральная Африка"
		L["Central Brazilian"] = "Центральный бразильский"
		L["Central European"] = "Центральноевропейский"
		L["Central Greenland"] = "Центральная Гренландия"
		L["Central Indonesian"] = "Центральный индонезийский"
		L["Chamorro"] = "Чаморро"
		L["Chile"] = "Чили"
		L["China"] = "Китай"
		L["Christmas Island"] = "Остров Рождества"
		L["Chuuk"] = "Чуук"
		L["Cocos Islands"] = "Кокосовые острова"
		L["Colombia"] = "Колумбия"
		L["Cook Islands"] = "Острова Кука"
		L["East Africa"] = "Восточная Африка"
		L["Eastern"] = "Восточный"
		L["Eastern European"] = "Восточноевропейская"
		L["Eastern Indonesian"] = "Восточно-индонезийский"
		L["Eastern Kazakhstan"] = "Восточный Казахстан"
		L["East Greenland"] = "Восточная Гренландия"
		L["East Timor"] = "Восточный Тимор"
		L["Ecuador"] = "Эквадор"
		L["Falkland Island"] = "Фолклендские острова"
		L["Fernando de Noronha"] = "Фернандо де Норонья"
		L["Fiji"] = "Фиджи"
		L["French Guiana"] = "Французская Гвиана"
		L["Galapagos"] = "Галапагосские острова"
		L["Georgia"] = "Грузия"
		L["Germany"] = "Германия"
		L["Gilbert Island"] = "Остров Гилберта"
		L["Greenwich Mean"] = "Среднее по Гринвичу"
		L["Gulf"] = "залив"
		L["Guyana"] = "Гайана"
		L["Hawaii"] = "Гавайи"
		L["Hovd"] = "Ховд"
		L["Indian"] = "индийский"
		L["Indochina"] = "Индокитай"
		L["Iran"] = "Иран"
		L["Irkutsk"] = "Иркутск"
		L["Israel"] = "Израиль"
		L["Japan"] = "Япония"
		L["Kaliningrad"] = "Калининград"
		L["Korea"] = "Корея"
		L["Krasnoyarsk"] = "Красноярск"
		L["Kyrgyzstan"] = "Кыргызстан"
		L["Magadan"] = "Магадан"
		L["Malaysia"] = "Малайзия"
		L["Maldives"] = "Мальдивы"
		L["Marshall Islands"] = "Маршалловы острова"
		L["Mauritius"] = "Маврикий"
		L["Moscow"] = "Москва"
		L["Mountain"] = "Гора"
		L["Myanmar"] = "Мьянма"
		L["Nauru"] = "Науру"
		L["Nepal"] = "Непал"
		L["New Caledonia"] = "Новая Каледония"
		L["Newfoundland"] = "Ньюфаундленд"
		L["New Zealand"] = "Новая Зеландия"
		L["Niue"] = "Ниуэ"
		L["Norfolk"] = "Норфолк"
		L["Omsk"] = "Омск"
		L["Pacific"] = "Тихий океан"
		L["Pakistan"] = "Пакистан"
		L["Palau"] = "Палау"
		L["Papua New Guinea"] = "Папуа - Новая Гвинея"
		L["Paraguay"] = "Парагвай"
		L["Peru"] = "Перу"
		L["Philippine"] = "филиппинский"
		L["Pierre & Miquelon"] = "Пьер и Микелон"
		L["Ponape"] = "Понапе"
		L["Reunion"] = "Воссоединение"
		L["Seychelles"] = "Сейшелы"
		L["Singapore"] = "Сингапур"
		L["Solomon Islands"] = "Соломоновы острова"
		L["South Africa"] = "Южная Африка"
		L["Sri Lanka"] = "Шри-Ланка"
		L["Suriname"] = "Суринам"
		L["Tahiti"] = "Таити"
		L["Tajikistan"] = "Таджикистан"
		L["Tokelau"] = "Токелау"
		L["Tonga"] = "Тонга"
		L["Turkmenistan"] = "Туркменистан"
		L["Tuvalu"] = "Тувалу"
		L["Ulaanbaatar"] = "Улан-Батор"
		L["Uruguay"] = "Уругвай"
		--L["US Central Standart Time (CST)"] = "Центральное стандартное время США (CST)"
		L["Uzbekistan"] = "Узбекистан"
		L["Vanuatu"] = "Вануату"
		L["Venezuela"] = "Венесуэла"
		L["Vladivostok"] = "Владивосток"
		L["Wallis & Futuna"] = "Уоллис и Футуна"
		L["West Africa"] = "Западная Африка"
		L["Western European"] = "западноевропейский"
		L["Western Indonesian"] = "западный индонезийский"
		L["Western Kazakhstan"] = "Западный Казахстан"
		L["West Samoa"] = "Западное Самоа"
		L["Yakutsk"] = "Якутск"
		L["Yap"] = "Яп"
		L["Yekaterinburg"] = "Екатеринбург"
	elseif _G["LOCALE_zhCN"] then
		L["Afghanistan"] = "阿富汗"
		L["Alaska"] = "阿拉斯加州"
		L["Arabian"] = "阿拉伯"
		L["Argentina"] = "阿根廷"
		L["Armenia"] = "亚美尼亚"
		L["Australian Central"] = "澳大利亚中央"
		L["Australian Eastern"] = "澳大利亚东部"
		L["AustralianWestern"] = "澳洲西部"
		L["Azerbaijan"] = "阿塞拜疆"
		L["Azores"] = "亚速尔群岛"
		L["Bangladesh"] = "孟加拉国"
		L["Bhutan"] = "不丹"
		L["Bolivia"] = "玻利维亚"
		L["Brazil"] = "巴西"
		L["Brunei"] = "文莱"
		L["Cape Verde"] = "佛得角"
		L["Central Africa"] = "中非"
		L["Central Brazilian"] = "巴西中部"
		L["Central European"] = "中欧"
		L["Central Greenland"] = "格陵兰中部"
		L["Central Indonesian"] = "中印尼语"
		L["Chamorro"] = "查莫罗"
		L["Chile"] = "智利"
		L["China"] = "中国"
		L["Christmas Island"] = "圣诞岛"
		L["Chuuk"] = "丘克"
		L["Cocos Islands"] = "科科斯群岛"
		L["Colombia"] = "哥伦比亚"
		L["Cook Islands"] = "库克群岛"
		L["East Africa"] = "东非"
		L["Eastern"] = "东"
		L["Eastern European"] = "东欧"
		L["Eastern Indonesian"] = "印尼东部"
		L["Eastern Kazakhstan"] = "东哈萨克斯坦"
		L["East Greenland"] = "东格陵兰"
		L["East Timor"] = "东帝汶"
		L["Ecuador"] = "厄瓜多尔"
		L["Falkland Island"] = "福克兰群岛"
		L["Fernando de Noronha"] = "费尔南多·迪诺罗尼亚群岛"
		L["Fiji"] = "斐济"
		L["French Guiana"] = "法属圭亚那"
		L["Galapagos"] = "加拉帕戈斯群岛"
		L["Georgia"] = "乔治亚州"
		L["Germany"] = "德国"
		L["Gilbert Island"] = "吉尔伯特岛"
		L["Greenwich Mean"] = "格林威治平均值"
		L["Gulf"] = "海湾"
		L["Guyana"] = "圭亚那"
		L["Hawaii"] = "夏威夷"
		L["Hovd"] = "霍夫德"
		L["Indian"] = "印度人"
		L["Indochina"] = "印度支那"
		L["Iran"] = "伊朗"
		L["Irkutsk"] = "伊尔库茨克"
		L["Israel"] = "以色列"
		L["Japan"] = "日本"
		L["Kaliningrad"] = "加里宁格勒"
		L["Korea"] = "韩国"
		L["Krasnoyarsk"] = "克拉斯诺亚尔斯克"
		L["Kyrgyzstan"] = "吉尔吉斯斯坦"
		L["Magadan"] = "马加丹"
		L["Malaysia"] = "马来西亚"
		L["Maldives"] = "马尔代夫"
		L["Marshall Islands"] = "马绍尔群岛"
		L["Mauritius"] = "毛里求斯"
		L["Moscow"] = "莫斯科"
		L["Mountain"] = "山"
		L["Myanmar"] = "缅甸"
		L["Nauru"] = "瑙鲁"
		L["Nepal"] = "尼泊尔"
		L["New Caledonia"] = "新喀里多尼亚"
		L["Newfoundland"] = "纽芬兰"
		L["New Zealand"] = "新西兰"
		L["Niue"] = "纽埃"
		L["Norfolk"] = "诺福克"
		L["Omsk"] = "鄂木斯克"
		L["Pacific"] = "太平洋"
		L["Pakistan"] = "巴基斯坦"
		L["Palau"] = "帕劳"
		L["Papua New Guinea"] = "巴布亚新几内亚"
		L["Paraguay"] = "巴拉圭"
		L["Peru"] = "秘鲁"
		L["Philippine"] = "菲律宾语"
		L["Pierre & Miquelon"] = "皮埃尔和密克隆群岛"
		L["Ponape"] = "波纳佩"
		L["Reunion"] = "团圆"
		L["Seychelles"] = "塞舌尔"
		L["Singapore"] = "新加坡"
		L["Solomon Islands"] = "所罗门群岛"
		L["South Africa"] = "南非"
		L["Sri Lanka"] = "斯里兰卡"
		L["Suriname"] = "苏里南"
		L["Tahiti"] = "大溪地"
		L["Tajikistan"] = "塔吉克斯坦"
		L["Tokelau"] = "托克劳"
		L["Tonga"] = "汤加"
		L["Turkmenistan"] = "土库曼斯坦"
		L["Tuvalu"] = "图瓦卢"
		L["Ulaanbaatar"] = "乌兰巴托"
		L["Uruguay"] = "乌拉圭"
		--L["US Central Standart Time (CST)"] = "美国中部标准时间 (CST)"
		L["Uzbekistan"] = "乌兹别克斯坦"
		L["Vanuatu"] = "瓦努阿图"
		L["Venezuela"] = "委内瑞拉"
		L["Vladivostok"] = "符拉迪沃斯托克"
		L["Wallis & Futuna"] = "瓦利斯群岛和富图纳群岛"
		L["West Africa"] = "西非（非洲西部"
		L["Western European"] = "西欧"
		L["Western Indonesian"] = "西印尼语"
		L["Western Kazakhstan"] = "西哈萨克斯坦"
		L["West Samoa"] = "西萨摩亚"
		L["Yakutsk"] = "雅库茨克"
		L["Yap"] = "邑"
		L["Yekaterinburg"] = "叶卡捷琳堡"
	elseif _G["LOCALE_zhTW"] then
		L["Afghanistan"] = "阿富汗"
		L["Alaska"] = "阿拉斯加州"
		L["Arabian"] = "阿拉伯"
		L["Argentina"] = "阿根廷"
		L["Armenia"] = "亞美尼亞"
		L["Australian Central"] = "澳大利亞中央"
		L["Australian Eastern"] = "澳大利亞東部"
		L["AustralianWestern"] = "澳洲西部"
		L["Azerbaijan"] = "阿塞拜疆"
		L["Azores"] = "亞速爾群島"
		L["Bangladesh"] = "孟加拉國"
		L["Bhutan"] = "不丹"
		L["Bolivia"] = "玻利維亞"
		L["Brazil"] = "巴西"
		L["Brunei"] = "文萊"
		L["Cape Verde"] = "佛得角"
		L["Central Africa"] = "中非"
		L["Central Brazilian"] = "巴西中部"
		L["Central European"] = "中歐"
		L["Central Greenland"] = "格陵蘭中部"
		L["Central Indonesian"] = "中印尼語"
		L["Chamorro"] = "查莫羅"
		L["Chile"] = "智利"
		L["China"] = "中國"
		L["Christmas Island"] = "聖誕島"
		L["Chuuk"] = "丘克"
		L["Cocos Islands"] = "科科斯群島"
		L["Colombia"] = "哥倫比亞"
		L["Cook Islands"] = "庫克群島"
		L["East Africa"] = "東非"
		L["Eastern"] = "東"
		L["Eastern European"] = "東歐"
		L["Eastern Indonesian"] = "印尼東部"
		L["Eastern Kazakhstan"] = "東哈薩克斯坦"
		L["East Greenland"] = "東格陵蘭"
		L["East Timor"] = "東帝汶"
		L["Ecuador"] = "厄瓜多爾"
		L["Falkland Island"] = "福克蘭群島"
		L["Fernando de Noronha"] = "費爾南多·迪諾羅尼亞群島"
		L["Fiji"] = "斐濟"
		L["French Guiana"] = "法屬圭亞那"
		L["Galapagos"] = "加拉帕戈斯群島"
		L["Georgia"] = "喬治亞州"
		L["Germany"] = "德國"
		L["Gilbert Island"] = "吉爾伯特島"
		L["Greenwich Mean"] = "格林威治平均值"
		L["Gulf"] = "海灣"
		L["Guyana"] = "圭亞那"
		L["Hawaii"] = "夏威夷"
		L["Hovd"] = "霍夫德"
		L["Indian"] = "印度人"
		L["Indochina"] = "印度支那"
		L["Iran"] = "伊朗"
		L["Irkutsk"] = "伊爾庫茨克"
		L["Israel"] = "以色列"
		L["Japan"] = "日本"
		L["Kaliningrad"] = "加里寧格勒"
		L["Korea"] = "韓國"
		L["Krasnoyarsk"] = "克拉斯諾亞爾斯克"
		L["Kyrgyzstan"] = "吉爾吉斯斯坦"
		L["Magadan"] = "馬加丹"
		L["Malaysia"] = "馬來西亞"
		L["Maldives"] = "馬爾代夫"
		L["Marshall Islands"] = "馬紹爾群島"
		L["Mauritius"] = "毛里求斯"
		L["Moscow"] = "莫斯科"
		L["Mountain"] = "山"
		L["Myanmar"] = "緬甸"
		L["Nauru"] = "瑙魯"
		L["Nepal"] = "尼泊爾"
		L["New Caledonia"] = "新喀裡多尼亞"
		L["Newfoundland"] = "紐芬蘭"
		L["New Zealand"] = "新西蘭"
		L["Niue"] = "紐埃"
		L["Norfolk"] = "諾福克"
		L["Omsk"] = "鄂木斯克"
		L["Pacific"] = "太平洋"
		L["Pakistan"] = "巴基斯坦"
		L["Palau"] = "帕勞"
		L["Papua New Guinea"] = "巴布亞新幾內亞"
		L["Paraguay"] = "巴拉圭"
		L["Peru"] = "秘魯"
		L["Philippine"] = "菲律賓語"
		L["Pierre & Miquelon"] = "皮埃爾和密克隆群島"
		L["Ponape"] = "波納佩"
		L["Reunion"] = "團圓"
		L["Seychelles"] = "塞舌爾"
		L["Singapore"] = "新加坡"
		L["Solomon Islands"] = "所羅門群島"
		L["South Africa"] = "南非"
		L["Sri Lanka"] = "斯里蘭卡"
		L["Suriname"] = "蘇里南"
		L["Tahiti"] = "大溪地"
		L["Tajikistan"] = "塔吉克斯坦"
		L["Tokelau"] = "托克勞"
		L["Tonga"] = "湯加"
		L["Turkmenistan"] = "土庫曼斯坦"
		L["Tuvalu"] = "圖瓦盧"
		L["Ulaanbaatar"] = "烏蘭巴托"
		L["Uruguay"] = "烏拉圭"
		--L["US Central Standart Time (CST)"] = "美國中部標準時間 (CST)"
		L["Uzbekistan"] = "烏茲別克斯坦"
		L["Vanuatu"] = "瓦努阿圖"
		L["Venezuela"] = "委內瑞拉"
		L["Vladivostok"] = "符拉迪沃斯托克"
		L["Wallis & Futuna"] = "瓦利斯群島和富圖納群島"
		L["West Africa"] = "西非（非洲西部"
		L["Western European"] = "西歐"
		L["Western Indonesian"] = "西印尼語"
		L["Western Kazakhstan"] = "西哈薩克斯坦"
		L["West Samoa"] = "西薩摩亞"
		L["Yakutsk"] = "雅庫茨克"
		L["Yap"] = "邑"
		L["Yekaterinburg"] = "葉卡捷琳堡"
	end
end
