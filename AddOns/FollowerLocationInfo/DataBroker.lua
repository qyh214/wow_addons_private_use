
local addon, ns = ...;
local D,L,C,Ticker;
local LDB  = LibStub("LibDataBroker-1.1");
local LDBi = LibStub("LibDBIcon-1.0");
local LDB_UpdateShort, LDB_UpdateLong = 0.2, 10;
local LDB_Object;

local function pairsByFields(t, f1, ...)
	local i,a = 0,{};
	for k,v in pairs(t) do
		local f = tostring(v[f1] or " ");
		for _,fn in ipairs({...})do
			if v[fn] then
				f=f..tostring(v[fn]);
			end
		end
		tinsert(a,{k,f});
	end
	table.sort(a,function(b,c) return b[2]<c[2]; end);
	return function()
		i=i+1;
		if a[i]~=nil then
			return a[i][1], t[a[i][1]];
		end
	end;
end

local function counter2string(v)
	return C(v[2]>0 and "green" or "gray",v[2]) .. "/" .. C("yellow",v[1]);
end

function FollowerLocationInfo_MinimapButton()
	if not (LDBi and LDBi:IsRegistered(addon)) then return; end
	if (FollowerLocationInfoDB.LDBi_Enabled) then
		LDBi:Hide(addon);
		FollowerLocationInfoDB.LDBi_Enabled = false;
	else
		LDBi:Show(addon);
		FollowerLocationInfoDB.LDBi_Enabled = true;
	end
end

function ns.LDB_Update()
	if not LDB_Object or not FollowerLocationInfoData then return end
	local label = {};

	if not D then
		D = FollowerLocationInfoData;
		L = D.Locale;
		C = FollowerLocationInfo.LibColors.color;
	end

	-- coords
	if(FollowerLocationInfoDB.LDB_PlayerCoords)then
		local x, y = GetPlayerMapPosition("player")
		if(x~=0 and y~=0)then
			tinsert(label,("%1.2f, %1.2f"):format(x*100,y*100));
		else
			tinsert(label,"−−.−, −−.−");
		end
	end

	-- follower count / max
	if(FollowerLocationInfoDB.LDB_NumFollowers)then
		tinsert(label,C(D.counter.collectables[2]>0 and "green" or "gray",D.counter.collectables[2]) .. "/" .. C("yellow",D.counter.collectables[1]));
	end

	if(#label==0)then
		tinsert(label,addon);
	end

	LDB_Object.text = table.concat(label,", ");

	local duration = (FollowerLocationInfoDB.LDB_PlayerCoords and LDB_UpdateShort or LDB_UpdateLong);
	if Ticker._duration~=duration then
		Ticker:Cancel();
		Ticker = C_Timer.NewTicker(duration, ns.LDB_Update);
		Ticker._duration = duration;
	end
end

local function LDB_Tooltip(tt)
	tt:AddLine(addon);
	tt:AddDoubleLine(C("hunter",COLLECTED),counter2string(D.counter.collectables));
	tt:AddDoubleLine(C("hunter",L["Recruited"]),counter2string(D.counter.recruitables));
	tt:AddLine(" ");
	tt:AddLine(L["Obtainable by"]);
	for i,v in pairsByFields(D.otherFiltersOrder,2)do
		if not (v[1]=="Reputation" or v[1]=="Garrison building" or v[1]=="Outpost") then
			tt:AddDoubleLine(C("mage",v[2]),counter2string(D.otherFiltersCount[v[1]]));
		end
	end
	tt:AddLine(" ");
	tt:AddLine(L["Left-click"]..": "..L["Show/Hide journal frame"]);
	tt:AddLine(L["Right-click"]..": "..L["Open option menu"]);
end

function ns.LDB_Init()
	if not (LDB and LDBi) then return end
	if LDB_Object~=nil then return end

	LDB_Object = LDB:NewDataObject(addon, {
		type = "data source",
		label = addon,
		icon = "Interface\\Icons\\Achievement_GarrisonFollower_Rare",
		text = addon,
		OnClick = function(self,button)
			if (button=="LeftButton") then
				FollowerLocationInfo_ToggleJournal();
			elseif (button=="RightButton") then
				FollowerLocationInfo_OptionMenu(self,"TOP","BOTTOM");
			end
		end,
		OnTooltipShow = LDB_Tooltip
	});
	
	if GetAddOnInfo("SlideBar") and GetAddOnEnableState(UnitName("player"),"SlideBar")>1 then
		LDB:NewDataObject(addon..".Launcher", {
			type = "launcher",
			icon = "Interface\\Icons\\Achievement_GarrisonFollower_Rare",
			OnClick = function()
				FollowerLocationInfo_ToggleJournal()
			end
		});
	end

	if(not LDB_Object)then
		LDB_Object = LDB:GetDataObjectByName(addon);
	end

	if(FollowerLocationInfoDB.LDBi_Data==nil)then
		FollowerLocationInfoDB.LDBi_Data={};
	end

	FollowerLocationInfoDB.LDBi_Data.hide = not FollowerLocationInfoDB.LDBi_Enabled;

	LDBi:Register(addon, LDB_Object, FollowerLocationInfoDB.LDBi_Data);

	local duration = (FollowerLocationInfoDB.LDB_PlayerCoords and LDB_UpdateShort or LDB_UpdateLong);
	Ticker = C_Timer.NewTicker(duration, ns.LDB_Update);
	Ticker._duration = duration;
end
