
FollowerLocationInfoDB = {};
local addon, ns = ...;

local D = FollowerLocationInfoData;
local L = D.Locale;
local levelIdx,qualityIdx,classIdx,classSpecIdx,portraitIdx,modelIdx,modelHeightIdx,modelScaleIdx,abilitiesIdx,countersIdx,traitsIdx,isCollectableIdx = 1,2,3,4,5,6,7,8,9,10,11,12; -- table indexes for FollowerLocationInfoData.basics entries.
local UpdateCallbacks,UpdateLock,isLoaded=false,false,false;
local garrLevel = 0;

function ns.print(...)
	print("|cff00ff00"..addon.."|r",...)
end

local function count(t,v,d)
	if(t[v]==nil)then t[v]=0; end
	t[v]=t[v]+d;
end

function ns.GetLinkData(link)
	assert(type(link)=="string","argument #1 must be a string, got "..type(link));
	local tt,data,reg,_ = FollowerLocationInfo_Tooltip,{};

	local retry = function()
		local link = tt.nextLinks[1];
		tremove(tt.nextLinks,1);
		ns.GetLinkData(link);
	end

	if(tt.nextLinks==nil)then
		tt.nextLinks = {};
		tt.retry = 0;
	end

	if(tt.currentLink)then
		tinsert(tt.nextLinks,link);
		tt.retry = tt.retry+1;
		if(tt.retry==1)then
			C_Timer.After(0.314159, retry);
		end
		return false;
	end

	tt.currentLink=link;

	tt:Show();
	tt:SetOwner(UIParent,"LEFT",0,0);
	tt:SetHyperlink(link);
	for _,v in pairs({tt:GetRegions()}) do
		if v and v:GetObjectType()=="FontString" and v:GetText() then
			tinsert(data,v:GetText());
		end
	end
	tt:ClearLines();
	tt:Hide();

	tt.currentLink = nil;

	if(#tt.nextLinks>0)then
		C_Timer.After(0.314159, retry);
	end

	return data, line;
end

local function UpdateFollowers()
	if UpdateLock==true then return; end

	-- sometimes blizzards functions returning data from wrong faction.
	-- 99% chance on characters without own garrison. (too high for a bug)
	-- 1% chance on characters with garrisons. (maybe a bug)
	local dataFaction = C_Garrison.GetFollowerInfo(34).displayID==55047 and "Alliance" or "Horde";
	local blizz = {};
	local pLevel = UnitLevel("player");
	garrLevel = (garrLevel>0 and garrLevel) or C_Garrison.GetGarrisonInfo() or 0;

	-- Sometimes PLAYER_ENTERING_WORLD aren't late enough to get some data from blizz.
	if pLevel>=90 and garrLevel==0 then
		C_Timer.After(6,function()
			UpdateFollowers();
		end);
		return;
	end

	UpdateLock = true;

	wipe(D.unknown);
	wipe(D.collected);
	wipe(D.collectGroups);

	--- reset all counter
	D.counter.blizz=0;
	D.counter.collectables[2]=0;
	D.counter.recruitables[2]=0;

	-- reset all collected counter
	for _,k in ipairs({"class","classspec","abilities","counters","traits"})do
		for K,v in pairs(D.counter[k])do
			D.counter[k][K][2]=0;
		end
	end
	for i in pairs(D.otherFiltersCount)do
		D.otherFiltersCount[i][2]=0;
	end
	---

	for id, data in pairs(D.basics)do
		if(#data[abilitiesIdx]>0 or #data[traitsIdx]>0)then
			local basicIds = {};
			for i=1, #data[abilitiesIdx] do
				basicIds[data[abilitiesIdx][i]] = true;
			end
			for i=1, #data[traitsIdx] do
				basicIds[data[traitsIdx][i]] = true;
			end
			for _,a in ipairs(C_Garrison.GetFollowerAbilities(id) or {}) do
				if basicIds[a.id] and a.name then
					local n = a.isTrait and "traits" or "abilities";
					if D[n][a.id]==nil then
						a.link = C_Garrison.GetFollowerAbilityLink(a.id); -- missing link from C_Garrison.GetFollowerAbilities()
						D[n][a.id]=a;
						if D.counter[n][a.id]==nil then
							D.counter[n][a.id]={data[isCollectableIdx] and 1 or 0,0};
						end
					end
					if n~="traits" and a.counters then
						for I,b in pairs(a.counters) do
							if D.counters[I]==nil then
								D.counters[I] = b;
								if data[isCollectableIdx] and D.counter.counters[I]==nil then
									D.counter.counters[I] = {data[isCollectableIdx] and 1 or 0,0};
								end
							end
							if D.ability2counters[a.id]==nil then
								D.ability2counters[a.id] = {};
							end
							D.ability2counters[a.id][I]=true;
							if D.counters2ability[I]==nil then
								D.counters2ability[I] = {};
							end
							D.counters2ability[I][a.id]=true;
						end
					end
				end
			end
		end

		if D.classSpec[data[classSpecIdx]]==nil then
			local v = C_Garrison.GetFollowerInfo(id);
			local class = gsub(v.classAtlas,"GarrMission_ClassIcon%-",""):lower();
			D.classSpec[data[classSpecIdx]]={
				C_Garrison.GetFollowerClassSpecName(id), -- localized class specialization name
				class, -- englsh class name
				LOCALIZED_CLASS_NAMES_MALE[class:upper()], -- localized class name
				D.ClassName2ID[v.class] -- class id
			};
		end

		if D.counter.classspec[data[classSpecIdx]]==nil then
			D.counter.classspec[data[classSpecIdx]] = {data[isCollectableIdx] and 1 or 0,0};
		end

		if(D.descriptions[id])then
			if(D.descriptions[id].collectGroup)then
				D.collectGroups[D.descriptions[id]] = D.collected[id]==true;
			end
		end

		count(D.counter,data[isCollectableIdx] and "collectable" or "recruitable",1);
	end

	if dataFaction==D.Faction then
		blizz = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_6_0);
		D.counter.blizz=#blizz;
	end

	if(#blizz>0) then
		for i,v in ipairs(blizz)do
			local id = tonumber(v.garrFollowerID or v.followerID);
			local b = D.basics[id];
			local isCollectable = b[isCollectableIdx];
			v.class = gsub(v.classAtlas,"GarrMission_ClassIcon%-",""):lower();

			D.collected[id] = v.isCollected or nil;

			if(isCollectable and v.isCollected)then
				for _,I in ipairs(b[abilitiesIdx])do
					count(D.counter.abilities[I],2,1);
				end
				for _,I in ipairs(b[countersIdx])do
					count(D.counter.counters[I],2,1);
				end
				for _,I in ipairs(b[traitsIdx])do
					count(D.counter.traits[I],2,1);
				end
				count(D.counter.class[D.ClassName2ID[v.class]],2,1);
				count(D.counter.classspec[v.classSpec],2,1);
				count(D.counter.qualities[b[qualityIdx]],2,1);
				if D.descriptions[id] then
					for _,obj in ipairs(D.descriptions[id])do
						if(obj[1]=="Requirements")then
							for i=2, #obj do
								local subObj = obj[i];
								if(D.otherFilters[subObj[1]] and D.otherFilters[subObj[1]][id])then
									count(D.otherFiltersCount[subObj[1]],2,1);
								end
							end
						elseif(D.otherFilters[obj[1]] and D.otherFilters[obj[1]][id])then
							count(D.otherFiltersCount[obj[1]],2,1);
						end
					end
				end
				count(D.counter.collectables,2,1);
			elseif not isCollectable then
				count(D.counter.recruitables,2,1);
			end

			if not b then
				local t={abilities={},counters={},traits={}};
				for _,a in ipairs(C_Garrison.GetFollowerAbilities(id) or {}) do
					if a.name then
						local n = a.isTrait and "traits" or "abilities";
						tinsert(t[n],a.id);
						a.link = C_Garrison.GetFollowerAbilityLink(a.id);
						if D[n][a.id]==nil then
							D[n][a.id]=a;
						end
						if D.counter[n][a.id]==nil then
							D.counter[n][a.id]={1,v.isCollected and 1 or 0};
						end
						if n~="traits" and a.counters then
							for I,b in pairs(a.counters) do
								if D.counters[I]==nil then
									D.counters[I] = b;
								end
								if D.ability2counters[a.id]==nil then
									D.ability2counters[a.id] = {};
								end
								D.ability2counters[a.id][I]=true;
								if D.counters2ability[I]==nil then
									D.counters2ability[I] = {};
								end
								D.counters2ability[I][a.id]=true;
								if isCollectable and D.counter.counters[I]==nil then
									D.counter.counters[I] = {1,v.isCollected and 1 or 0};
								end
							end
						end
					end
				end

				D.basics[id] = {
					v.level,
					v.quality,
					0, --v.class,
					v.classSpec,
					v.portraitIconID,
					v.displayID,
					v.displayHeight,
					v.displayScale,
					t.abilities,
					t.counters,
					t.traits,
					(not collectable[i])
				};
				tinsert(D.unknown,id);
				count(D.counter,"unknown",1,1);
			end

			if not rawget(L,"follower_"..id) then
				L["follower_"..id] = v.name;
			end
		end

		D.counter.unknown = #D.unknown;
	end

	if(UpdateCallbacks)then
		for _,func in pairs(UpdateCallbacks)do
			func();
		end
	end

	UpdateLock = false;
end

local function CheckAndLoadJournal()
	if(not FollowerLocationInfoJournal)then
		local _,_,_,_,status = GetAddOnInfo(addon.."_Journal");
		if status~="MISSING" then
			EnableAddOn(addon.."_Journal");
		end
		LoadAddOn(addon.."_Journal");
		if( not FollowerLocationInfoJournal)then
			FollowerLocationInfo_ShowInfoBox("journal not loadable");
			return false;
		end
	end
	return true;
end

--[=[ some global accessable functions ]=]
function FollowerLocationInfo_RegisterUpdateCallback(func)
	if(not UpdateCallbacks)then UpdateCallbacks={}; end
	local funcID = tostring(func);
	if(not UpdateCallbacks[funcID])then
		UpdateCallbacks[funcID] = func;
	end
end

function FollowerLocationInfo_UnregisterUpdateCallback(func)
	if(not UpdateCallbacks)then return end
	local funcID = tostring(func);
	if(UpdateCallback[funcID])then
		UpdateCallbacks[funcID] = nil;
	end
end

function FollowerLocationInfo_OptionMenu(parent,point,relativePoint)
	if not parent.tooltip then
		parent.tooltip = { OPTIONS };
		return;
	end
	local db = FollowerLocationInfoDB;

	PlaySound("igMainMenuOptionCheckBoxOn");
	ns.MenuGenerator.InitializeMenu();
	ns.MenuGenerator.addEntry({
		{ label = "DataBroker", title=true },
		{
			label = L["Show minimap button"], tooltip = {L["Minimap"],L["Show/Hide minimap button"]},
			checked = function() return db.LDBi_Enabled; end,
			func = function() FollowerLocationInfo_MinimapButton(); end
		},
		{
			label = L["Broker button text"], tooltip = {L["Broker button text"],L["Choose what you want to look on broker button"]},
			childs = {
				{
					label = L["Addon name"],
					checked = function()
						return	db.LDB_PlayerCoords==false
								--and db.LDB_TargetCoords==false
								and db.LDB_NumFollowers==false;
					end,
					func=function(self)
						db.LDB_PlayerCoords = false;
						--db.LDB_TargetCoords = false;
						db.LDB_NumFollowers = false;
						UIDropDownMenu_Refresh(FollowerLocationInfoEasyMenu,nil,2);
					end,
					event=function() ns.LDB_Update(); end,
				},
				{
					label = L["Your coordinates"],
					checked = function()
						return	db.LDB_PlayerCoords==true
								--and db.LDB_TargetCoords==false
								and db.LDB_NumFollowers==false;
					end,
					func=function()
						db.LDB_PlayerCoords = true;
						--db.LDB_TargetCoords = false;
						db.LDB_NumFollowers = false;
						UIDropDownMenu_Refresh(FollowerLocationInfoEasyMenu,nil,2);
					end,
					event=function() ns.LDB_Update(); end,
				},
				{
					label = L["Collected followers"],
					checked = function()
						return	db.LDB_PlayerCoords==false
								--and db.LDB_TargetCoords==false
								and db.LDB_NumFollowers==true;
					end,
					func=function()
						db.LDB_PlayerCoords = false;
						--db.LDB_TargetCoords = false;
						db.LDB_NumFollowers = true;
						UIDropDownMenu_Refresh(FollowerLocationInfoEasyMenu,nil,2);
					end,
					event=function() ns.LDB_Update(); end,
				},
				{
					label = L["Your coordinates + collected followers"],
					checked = function()
						return	db.LDB_PlayerCoords==true
								--and db.LDB_TargetCoords==false
								and db.LDB_NumFollowers==true;
					end,
					func=function()
						db.LDB_PlayerCoords = true;
						--db.LDB_TargetCoords = false;
						db.LDB_NumFollowers = true;
						UIDropDownMenu_Refresh(FollowerLocationInfoEasyMenu,nil,2);
					end,
					event=function() ns.LDB_Update(); end,
				},
			}
		},
		{ separator = true },
		{ label = "Journal", title=true },
		{
			label = L["Favorite website"], tooltip = {L["Favorite website"],L["Choose your favorite website for further informations"]},
			dbType="select", keyName="ExternalURL",
			default = "WoWHead",
			values = ns.ExternalURLValues,
			event = function() FollowerLocationInfoJournalFollowerCard_Update(); FollowerLocationInfoJournalFollowerDesc_Update() end
		},
		{
			label = L["Standalone mode"], tooltip={L["Standalone mode"],L["Display the journal like garrison report with own window"],"|cffff0000"..L["Needs UI reload!"].."|r","|cffff8800"..L["Will be automatically reload your ui while your are not in combat..."].."|r"},
			dbType = "bool", keyName="standalone",
			event = function() if not InCombatLockdown() then ReloadUI(); end end
		},
		{
			label = L["Show FollowerID"], tooltip={L["FollowerID"],L["Show followerIDs in follower list"]},
			dbType="bool", keyName="ShowFollowerID",
			event = function() FollowerLocationInfoJournalFollowerList_Update(); end
		},
		--[[
		{ separator = true },
		{ label = "Tracker.", title=true },
		{
			label = L[ "Show coordination frame"], tooltip = {L[ "Coordination frame"],L[ "Show the coordinates frame"]},
			dbType="bool", keyName="ShowCoordsFrame",
			event  = function()
				if (db.ShowCoordsFrame) then
					FollowerLocationInfoCoordFrame:Show();
				else
					FollowerLocationInfoCoordFrame:Hide();
				end
			end
		},
		--]]
	});
	ns.MenuGenerator.ShowMenu(parent, point or "TOPLEFT", relativePoint or "TOPRIGHT");
end

--- InfoBox
-- Display an frame for infomation and error messages
-- @params:
-- msg - a string that must be match to an error message entry from table infoBoxErrors.
local infoBoxErrors = {
	["missing data"] = L["Your installed version of FollowerLocationInfo requires an additional addon to work.|nPlease install FollowerLocationInfo_Data."],
	["data too old"] = L["Your installed version of FollowerLocationInfo requires a newer version of FollowerLocationInfo_Data.|nPlease update it..."],
	["journal not loadable"] = L["Couldn't load FollowerLocationInfo_Journal. Please check if FollowerLocationInfo_Data is enabled."]
}
function FollowerLocationInfo_ShowInfoBox(msg)
	local self = FollowerLocationInfo;
	local smallbr,br,deco = "<p>|n</p>","<br />","<p>|TInterface\\AddOns\\FollowerLocationInfo_Data\\media\\%s:15:320:0:12:128:16:24:64:1:16|t</p>";
	local message,errorMessage = {},{"<h2>|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:0|t Houston, we have a problem!</h2>",deco:format("red")};

	if(msg=="version")then
		message = {
			"<h2>Sorry...</h2>",
			deco:format("blue"),
			"<h3>for the long time without updates.</h3>",
			br,
			"<h2>Whats new in FollowerLocationInfo?</h2>",
			deco:format("blue"),
			"<h3>* basic data, descriptions, images and localization part of FollowerLocationInfo_Data.</h3>",
			"<h3>* FollowerLocationInfo found its new home under 'collections'.</h3>",
			"<h3>* Some new images and partly updated descriptions.</h3>",
			br,
			"<h2>Annotation / Known problems</h2>",
			deco:format("red"),
			"<h3>* The chat commands are disabled. Not match with new version. </h3>",
			"<h3>* Some images maybe too dark? Let me know... :-)</h3>",
			br,
			"<h3>|cffffee00Greetings Hizuro|r</h3>",
			"<h3>(May the light be with you)</h3>",
		};
	elseif(infoBoxErrors[msg])then
		message = errorMessage;
		tinsert(message,"<h3>"..infoBoxErrors[msg].."</h3>");
	else
		return; -- no match for msg - no infobox :)
	end

	self.InfoBox:SetText("<html><body>"..smallbr..table.concat(message,"")..smallbr.."</body></html>");
	self.msg = msg;

	local height = self.InfoBox:GetContentHeight()+40;
	self:SetHeight( height>460 and 460 or height );

	self:Show();
end

--[=[ Tooltip functions ]=]
function FollowerLocationInfoTooltip_OnEnter(self)
	if (self.tooltip) then
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
		if (type(self.tooltip)=="string") then
			GameTooltip:SetText(self.tooltip);
		elseif (type(self.tooltip)=="table") and (#self.tooltip>0) then
			GameTooltip:SetText(self.tooltip[1]);
			for i=2, #self.tooltip do
				GameTooltip:AddLine(self.tooltip[i],1,1,1,1);
			end
		end
		GameTooltip:Show();
	end
end

function FollowerLocationInfoTooltip_OnLeave(self)
	GameTooltip:Hide();
end

--[=[ Frame functions ]=]
function FollowerLocationInfo_ToggleJournal()
	if FollowerLocationInfoData.journalDocked then
		if(not CollectionsJournal)then
			LoadAddOn("Blizzard_Collections");
		end

		if not CheckAndLoadJournal() then
			return;
		end

		if FollowerLocationInfoJournal:IsShown() and FollowerLocationInfoJournal:IsVisible() then
			FollowerLocationInfoJournal:Hide();
			ToggleCollectionsJournal();
		else
			FollowerLocationInfoJournal:Show();
			ToggleCollectionsJournal(FollowerLocationInfoData.JournalTabID);
		end
	else
		if not FollowerLocationInfoJournalFrame then
			LoadAddOn(addon.."_Journal");
		end
		if FollowerLocationInfoJournalFrame:IsShown() then
			HideUIPanel(FollowerLocationInfoJournalFrame);
		else
			ShowUIPanel(FollowerLocationInfoJournalFrame);
			FollowerLocationInfoJournal:Show();
		end
	end
end
	
function FollowerLocationInfo_OnEvent(self,event,arg1)
	if event=="ADDON_LOADED" then
		if arg1==addon then
			-- check config
			if (FollowerLocationInfoDB==nil) then
				FollowerLocationInfoDB={};
			end
			for key,val in pairs({
				-- LDB Options
				LDB_PlayerCoords = false,
				LDB_TargetCoords = false,
				LDB_NumFollowers = true,
				LDBi_Enabled = true,

				-- FLI Options
				showInfoBox = true,
				ShowFollowerID = true,
				ExternalURL = "WoWHead",
				standalone = false,

				-- FLI Tracker options
				--HideInCombat = true,
				--LockedInCombat = true,
				--CoordsFrame Options
				--ShowCoordsFrame = true,
				--CoordsFrameTarget = false,
				--TargetMark = false,
				--CoordsFrame_HideInCombat = true,
				--CoordsFrame_LockedInCombat = true
			}) do
				if (FollowerLocationInfoDB[key]==nil) then
					FollowerLocationInfoDB[key]=val;
				end
			end

			if FollowerLocationInfoDB.Minimap~=nil and FollowerLocationInfoDB.Minimap.enabled~=nil then
				FollowerLocationInfoDB.LDBi_Enabled = FollowerLocationInfoDB.Minimap.enabled;
				FollowerLocationInfoDB.Minimap = nil;
			end

			local _,_,_,_,status = GetAddOnInfo(addon.."_Data");
			local loaded,finished = IsAddOnLoaded(addon.."_Data")
			if status~="MISSING" and not loaded then
				EnableAddOn(addon.."_Data");
				LoadAddOn(addon.."_Data");
			end

			FollowerLocationInfoData.journalDocked = not FollowerLocationInfoDB.standalone;

			ns.LDB_Init();
			ns.print("AddOn loaded...");
		elseif arg1==addon.."_Data" then
			-- now localization is part of FollowerLocationInfo_Data.
			-- thats makes easier to update follower and localization.
			BINDING_HEADER_FOLLOWERLOCATIONINFO		= "FollowerLocationInfo";
			BINDING_NAME_TOGGLEFOLLOWERLOCATIONINFO	= L["Toggle FollowerLocationInfo Journal"];
			--StaticPopupDialogs["FOLLOWERLOCATIONINFO_EXTERNALURL_DIALOG"].text = L["URL"];

			for i,v in pairs(D.otherFilters)do
				tinsert(D.otherFiltersOrder,{i,L[i]});
			end

			D.Version = {Core=GetAddOnMetadata(addon,"Version"),Data=GetAddOnMetadata(arg1,"Version")};

	
			local min_data_version = tonumber((GetAddOnMetadata(addon,"X-Min-Data-Version") or 0):match("([%d%.]+)")) or 0;
			local current_data_version = tonumber(D.Version.Data:match("([%d%.]+)")) or 0;

			if (D.Version.Data=="0.11-release4")then
				-- nothing ^^
			elseif (current_data_version<min_data_version) then
				self.error = "data too old";
			else
				ns.print("Data loaded...");
			end

			-- check data cache
			if (FollowerLocationInfoDataDB==nil)then
				FollowerLocationInfoDataDB={};
			end

			--- Clear name caches on changed cvar "textLocale"
			if (FollowerLocationInfoDataDB.Locale~=D.locale) then
				FollowerLocationInfoDataDB.Locale=D.locale;
				FollowerLocationInfoDataDB.questNames = {};
				FollowerLocationInfoDataDB.npcNames = {};
				FollowerLocationInfoDataDB.objectNames = {};
				FollowerLocationInfoDataDB.npcTitles = {};
			end

			if (FollowerLocationInfoDataDB.questNames==nil) then
				FollowerLocationInfoDataDB.questNames = {};
			end

			if (FollowerLocationInfoDataDB.npcNames==nil) then
				FollowerLocationInfoDataDB.npcNames = {};
			end

			if (FollowerLocationInfoDataDB.npcTitles==nil) then
				FollowerLocationInfoDataDB.npcTitles = {};
			end

			if (FollowerLocationInfoDataDB.objectNames==nil) then
				FollowerLocationInfoDataDB.objectNames = {};
			end

			isLoaded=true;
		elseif arg1=="Blizzard_GarrisonUI" then
			GarrisonMissionFrame:HookScript("OnHide",function()
				UpdateFollowers();
			end);
		elseif FollowerLocationInfoData.journalDocked and arg1=="Blizzard_Collections" then
			LoadAddOn("FollowerLocationInfo_Journal");
		end
	elseif isLoaded then
		self.ExternalURL_unsupportedTypes = ns.ExternalURL_unsupportedTypes;
		if event=="PLAYER_ENTERING_WORLD" then
			C_Timer.After(4,function()
				UpdateFollowers();
			end);
			self:UnregisterEvent(event);
		elseif event=="GARRISON_FOLLOWER_LIST_UPDATE" and not ((GarrisonMissionFrame and GarrisonMissionFrame:IsShown()) or (GarrisonShipyardFrame and GarrisonShipyardFrame:IsShown())) then
			UpdateFollowers();
		end
	end
	if event=="PLAYER_ENTERING_WORLD" then
		C_Timer.After(5,function()
			if FollowerLocationInfo:IsShown() then return end
			if not isLoaded then
				local _,_,_,_,status = GetAddOnInfo(addon.."_Data");
				if status=="MISSING" then
					FollowerLocationInfo_ShowInfoBox("missing data");
				end
			elseif self.error~=nil then
				FollowerLocationInfo_ShowInfoBox(self.error);
				self.error=nil;
			elseif FollowerLocationInfoDB.showInfoBox then
				FollowerLocationInfo_ShowInfoBox("version");
			end
		end);
		self:UnregisterEvent(event);
	end
end

function FollowerLocationInfo_OnHide(self)
	if(self.msg=="version")then
		FollowerLocationInfoDB.showInfoBox = false;
	end
	self.msg = nil;
end

function FollowerLocationInfo_OnLoad(self)
	self.MenuGenerator = ns.MenuGenerator;
	self.LibColors = LibStub("LibColors-1.0");

	self:SetScale(0.8);
	tinsert(UISpecialFrames, self:GetName());

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end
