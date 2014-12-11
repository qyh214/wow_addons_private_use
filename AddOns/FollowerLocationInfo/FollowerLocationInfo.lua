
local addon,ns = ...;
local L = ns.locale;

--
BINDING_HEADER_FOLLOWERLOCATIONINFO		= "FollowerLocationInfo";
BINDING_NAME_TOGGLEFOLLOWERLOCATIONINFO	= L["Toggle FollowerLocationInfo Display"];
--

ns.faction, ns.factionLocale = UnitFactionGroup("player"); L[ns.faction] = ns.factionLocale;
nFaction = ((ns.faction=="Alliance") and 1) or ((ns.faction=="Horde") and 2) or 0;

FollowerLocationInfo_Toggle, FollowerLocationInfo_ToggleCollected, FollowerLocationInfo_ToggleIDs, FollowerLocationInfo_ResetConfig,FollowerLocationInfo_MinimapButton,FollowerLocationInfo_ToggleList=nil,nil,nil,nil,nil,nil;
local NUM_FILTERS = 3;
local configMenu, List_Update, FollowerLocationInfoFrame_OnEvent,ExternalURL;
local nFaction = (ns.faction=="Alliance") and 1 or 2;
local followers, zoneNames, classes, collectGroups, classNames1, classNames2, abilityNames,counterNames = nil,{},{},{},{},{},{},{};
local numHidden,numRealFollowers, numKnownFollowers, numCollectedFollowers = (292-48),0,0,0;
local qualities = {nil,_G.UnitPopupButtons.ITEM_QUALITY2_DESC,_G.UnitPopupButtons.ITEM_QUALITY3_DESC,_G.UnitPopupButtons.ITEM_QUALITY4_DESC};
local initState,doRefresh={minimap=false},false;
local ClassFilterLabel, AbilityFilterLabel = L["Classes & Class speccs"], L["Abilities/Counters & Traits"];
local ListButtonOffsetX, ListButtonOffsetY = 0,1;
local updateLock,onEvent=false,false;
local ListEntrySelected, ListEntries = false,{};
local FollowersCollected,knownAbilities = {},{};
local SearchStr,Filters,ClassFilter,AbilityFilter = "",{},"","";
local ids = {[32]=true,[34]=true,[153]=true,[154]=true,[155]=true,[157]=true,[159]=true,[168]=true,[170]=true,[171]=true,[176]=true,[177]=true,[178]=true,[179]=true,[180]=true,[182]=true,[183]=true,[184]=true,[185]=true,[186]=true,[189]=true,[190]=true,[192]=true,[193]=true,[194]=true,[195]=true,[202]=true,[203]=true,[204]=true,[205]=true,[207]=true,[208]=true,[209]=true,[211]=true,[212]=true,[216]=true,[217]=true,[218]=true,[219]=true,[224]=true,[225]=true,[453]=true,[455]=true,[458]=true,[459]=true,[460]=true,[462]=true,[463]=true};
local factionZoneOrder = (ns.faction:lower()=="alliance") and {962,947,971,949,946,948,950,941,978,1009,964,969,984,987,988,989,993,994,995,1008,-1,0}
														   or {962,941,976,949,946,948,950,947,978,1011,964,969,984,987,988,989,993,994,995,1008,-1,0};
for i,v in ipairs(factionZoneOrder) do if (v>0) then zoneNames[v] = GetMapNameByID(v); end end
zoneNames[-1] = L["hidden followers"];
zoneNames[0] = L["No description found for..."];

local modelPositions={
	-- Alliance races ------------------------------------------
	DraeneiF	= {1.9,0,-0.7},		DraeneiM	= {1.5,0,-0.62},
	DwarfF		= {0.9,0,-0.27},	DwarfM		= {1.5,0,-0.45},
	GnomeF		= {0.5,0,-0.18},	GnomeM		= {0.5,0,-0.18},
	HumanF		= {1.2,0,-0.52},	HumanM		= {1.5,0,-0.59},
	NightElfF	= {2,0,-0.62},		NightElfM	= {2,0,-0.62},
	WorgenF		= {3,0,-0.62},		WorgenM		= {1.5,0,-0.62},
	-- Horde races ---------------------------------------------
	BloodElfF	= {1.5,0,-0.51},	BloodElfM	= {2,0,-0.62},
	GoblinF		= {0.7,0,-0.24},	GoblinM		= {0.7,0,-0.24},
	OrcF		= {1.25,0,-0.5},	OrcM		= {1.25,0,-0.5},
	ScourgeF	= {1.7,0,-0.56},	ScourgeM	= {1,0,-0.5},
	TaurenF		= {1.5,0,-0.39},	TaurenM		= {1.5,0,-0.39},
	TrollF		= {1.5,0,-0.42},	TrollM		= {1.5,0,-0.42},
	-- Neutral playable races ----------------------------------
	PandarenF	= {1.2,0,-0.62},	PandarenM	= {2,0,-0.58},
	-- Misc unplayable races -----------------------------------
	Mech		= {2,0,-2.5},		Orge		= {1.4,0,-0.67},
	Zyclope		= {8,0,-3},			Gnoll		= {0.5,0,-0.15},
	Saberon		= {1.45,0,-0.37},	Arakkoa		= {1.5,0,-0.28},
	Hozen		= {2,0,-0.62},		Jinyu		= {2,0,-0.62}
};


--[=[ Broker & Minimap ]=]

local broker = {obj=nil,minimap=nil,update=nil,tooltip=nil,click=nil};
do
	broker.lDB = LibStub("LibDataBroker-1.1");
	broker.lDBI = LibStub("LibDBIcon-1.0");

	broker.minimap = function()
		if (not broker.lDB) or (not broker.lDBI) or (not broker.obj) then return; end
		broker.lDBI:Register(addon, broker.obj, FollowerLocationInfoDB.Minimap);
	end

	broker.update = function()
		-- coords
		-- follower count / max
		
	end

	broker.tooltip = function()
		-- list of uncollected follower in current zone?
	end

	broker.click = function(self,button)
		if (button=="LeftButton") then
			FollowerLocationInfo_Toggle();
		elseif (button=="RightButton") then
			configMenu(self,"TOP","BOTTOM");
		end
	end

	broker.init = function()
		if (not broker.lDB) then return; end
		broker.obj = broker.lDB:NewDataObject(addon, {
			type          = "data source",
			label         = addon,
			icon          = "Interface\\Icons\\Achievement_GarrisonFollower_Rare",
			text          = addon,
			OnClick       = broker.click,
			--OnTooltipShow = broker.tooltip
		});

		if (GetAddOnInfo("SlideBar")) then
			if (GetAddOnEnableState(UnitName("player"),"SlideBar")>1) then
				local name = addon..".Launcher"
				local obj = broker.lDB:NewDataObject(name, {
					type          = "launcher",
					icon          = "Interface\\Icons\\Achievement_GarrisonFollower_Rare",
					OnClick       = function(self,button) FollowerLocationInfo_Toggle(); end
				});
			end
		end
	end
end


--[=[ External URL dialog ]=]
local urls = {
	WoWHead = function(t,id)
		local lang = {deDE="de",esES="es",esMX="es",frFR="fr",ptBR="pt"}
		local field = {q="quest",i="item",s="spell",o="object"}
		return ("http://%s.wowhead.com/%s=%d"):format(lang[GetLocale()] or "www",field[t],id);
	end,
	Buffed = function(t,id)
		local url = {deDE="http://wowdata.buffed.de/?%s=%d",ruRU="http://wowdata.buffed.ru/?%s=%d"}
		local field = {q="q",i="i",s="s",o="o"}
		return (url[GetLocale()] or "http://wowdata.getbuffed.com/?q=%d"):format(field[t],id);
	end,
	WoWDB = function(t,id)
		local field = {q="quests",i="items",s="spells",o="objects"}
		return ("http://www.wowdb.com/%s/%d"):format(field[t],id);
	end
}

StaticPopupDialogs["FLI_URL_DIALOG"] = {
	text = L["URL"], button2 = CLOSE, timeout = 0, whileDead = 1, 
	hasEditBox = 1, hideOnEscape = 1, maxLetters = 1024, editBoxWidth = 250,
	OnShow = function(f)
		local e,b = _G[f:GetName().."EditBox"],_G[f:GetName().."Button2"];
		if e then e:SetText(ExternalURL) e:SetFocus() e:HighlightText(0) end
		if b then b:ClearAllPoints() b:SetWidth(100) b:SetPoint("CENTER",e,"CENTER",0,-30) end
	end,
	EditBoxOnEscapePressed = function(f)
		f:GetParent():Hide()
	end
}


--[=[ Misc ]=]
local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

local function tableMerge(t1, t2)
	for k,v in pairs(t2) do
		if (type(v)=="table") then
			if (type(t1[k] or false)=="table") then
				tableMerge(t1[k] or {}, t2[k] or {});
			else
				t1[k]=v;
			end
		else
			t1[k]=v;
		end
	end
	return t1
end

local function getTableTree(_table,keys)
	assert(type(_table)=="table","argument #1 must be a table, got "..type(_table));
	assert(type(keys)=="table","argument #2 must be a table, got "..type(keys));
	local t=_table;
	for i,v in ipairs(keys) do
		t[v] = (t[v]) and t[v] or {};
		t=t[v];
	end
	return t;
end

local function addLocale(Type,id,value)
	local keys;
	if (FLI_tmpDB==nil) then
		FLI_tmpDB = {};
	end
	id=tostring(id)
	if (Type=="follower") then
		keys={Type.."_locales",id,ns.language};
		getTableTree(FLI_tmpDB,keys)[nFaction] = value;
	else
		keys={Type.."_locales",id};
		getTableTree(FLI_tmpDB,keys)[ns.language] = value;
	end
end

local function getLocale(Type,id)
	local t,keys;
	if (FLI_tmpDB==nil) then FLI_tmpDB={}; end
	id=tostring(id)
	if (Type=="follower") then
		keys={Type.."_locales",id,ns.language,nFaction};
		enKeys={Type.."_locales",id,"enUS",nFaction};
	else
		keys={Type.."_locales",id,ns.language};
		enKeys={Type.."_locales",id,"enUS"};
	end
	t=getTableTree(ns,keys);
	if (type(t)=="string") then return t; end
	t=getTableTree(FLI_tmpDB,keys);
	if (type(t)=="string") then return t; end
	t=getTableTree(ns,enKeys);
	if (type(t)=="string") then return t; end
	return false;
end

local function IsQuestCompleted(QuestID)
	if (not questsCompleted) or ((questsCompleted) and ((time() - questsCompleted.last)<300)) then
		questsCompleted = {ids=GetQuestsCompleted(), last=time()};
	end
	return (questsCompleted.ids[QuestID]==true);
end

local Collector = {data={},hLink=false};
do
	local this,tt = Collector;
	local tryouts = {};
	this.GetData = function(self)
		self:Show();
		local reg,data,line = {self:GetRegions()},{},0;
		for k, v in ipairs(reg) do
			if (v~=nil) and (v:GetObjectType()=="FontString") then
				str = v:GetText();
				if (str~=nil) and (strtrim(str)~="") then
					tinsert(data,str);
					line = line + 1;
				end
			end
		end
		self:Hide();
		if (this.hLink) then
			if (#data>0) then
				this.data[this.hLink] = data;
				this.hLink=false;
			elseif (tryouts[this.hLink]>4) then
				this.data[this.hLink] = false;
			end
		end
		return nil;
	end

	this.QueryHyperlinkData = function(hLink)
		if (not tt) then
			tt = _G.FollowerLocationInfoTooltip;
			tt:SetScript("OnTooltipSetQuest",this.GetData);
			tt:SetScript("OnTooltipSetSpell",this.GetData);
			tt:SetScript("OnTooltipSetItem",this.GetData);
		end
		if (this.hLink~=false) then
			return nil; -- single request per time...
		elseif (this.data[hLink]==false) then
			return false; -- data not collectable... maybe removed...
		elseif (this.data[hLink]==nil) then
			tt:SetOwner(UIParent,"ANCHOR_NONE");
			tt:SetPoint("RIGHT");
			tt:ClearLines();
			this.hLink = hLink;
			if (not tryouts[hLink]) then
				tryouts[hLink] = 1;
			else
				tryouts[hLink] = tryouts[hLink] + 1;
			end
			tt:SetHyperlink(hLink); -- try to request data... > gathered by Collector.GetData...
			return nil;
		else
			return unpack(this.data[hLink]);
		end
		return nil;
	end
	this.clearCache = function()
		wipe(this.data);
		collectgarbage("collect");
	end
end

local function GetQuestTitle(QuestID)
	if (not FollowerLocationInfoDB.questTitles[QuestID]) then
		FollowerLocationInfoDB.questTitles[QuestID] = Collector.QueryHyperlinkData("quest:"..QuestID);
	end
	return FollowerLocationInfoDB.questTitles[QuestID];
end

local function GetBlizzardData()
	if (updateLock) then return end
	local l,c,id,ID = C_Garrison.GetFollowers(),0;
	for i,v in ipairs(l) do
		if (v) then
			id=v.followerID;

			if (v.garrFollowerID) then
				id=tonumber(v.garrFollowerID);
				FollowersCollected[id] = true;
				c=c+1;
			end
		end
	end
	if (numCollectedFollowers~=c) then
		numCollectedFollowers=c;
		followers=nil;
	end
end

local function GetFollowers()
	followers={};
	classNames1={};
	classNames2={};
	abilityNames={};
	counterNames={};

	for i,v in pairs(ns.follower_basics) do
		local d = nil;

		if (FollowerLocationInfoDB.ShowHiddenFollowers==false) and (not ids[i]) then
			-- ignore
		else
			local abilities={};

			if (v) then
				d = {name=ns.follower_locales[tostring(i)][nFaction],followerID=i,collected=false,desc={}};
				d.level,d.quality,d.classSpec,d.portraitIconID,d.displayID,d.abilities,d.race,d.class = unpack( v[nFaction] );
				if (type(d.abilities)=="number") then
					d.abilities={d.abilities};
				end
				if (type(d.abilities)=="table") then
					for I,V in ipairs(d.abilities) do
						V=tostring(V);
						abilities[V] = {
							name = C_Garrison.GetFollowerAbilityName(V),
							icon = C_Garrison.GetFollowerAbilityIcon(V),
							trait = C_Garrison.GetFollowerAbilityIsTrait(V)
						};
						local counter={C_Garrison.GetFollowerAbilityCounterMechanicInfo(V)};
						if (#counter~=0) then
							abilities[V].counter_name,abilities[V].counter_icon = counter[2],counter[3];
						end
					end
				end
			end

			if (d) and (d.name) then
				-- is collected?
				if (FollowersCollected[i]==true) then
					d.collected = true;
				end

				-- add data from descripted follower
				if (ns.followers[i]) then
					local x;
					if (ns.followers[i][1]) then
						x = ns.followers[i][2];
					else
						x = ns.followers[i][nFaction+1];
					end
					if (type(x)=="table") and (#x>0) and (not x.ignore) then
						-- add zone
						d.zone = x.zone;

						-- add descriptions without zone
						for _,D in ipairs(x) do tinsert(d.desc,D); end

						-- member of a collectGroup? [only one of the group is collectable]
						if (x.collectGroup) then
							d.collectGroup=x.collectGroup;
							if (d.collected) then
								collectGroups[d.collectGroup] = true;
							end
						end
					end
				end

				-- class and specc
				d.className = ns.classspec_locales[tostring(d.classSpec)];
				d.classColor = (classes[d.class:upper()]) and classes[d.class:upper()].colorStr or "";

				-- add class and class specc names to filter table;
				if (classNames1[d.className:lower()]) then
					classNames1[d.className:lower()][3] = classNames1[d.className:lower()][3] + 1;
					if (d.collected) then
						classNames1[d.className:lower()][4] = classNames1[d.className:lower()][4] + 1;
					end
				else
					classNames1[d.className:lower()] = {d.className,d.class:lower(),1,(d.collected) and 1 or 0};
				end

				if (classNames2[d.class]) then
					classNames2[d.class][3] = classNames2[d.class][3] + 1;
					if (d.collected) then
						classNames2[d.class][4] = classNames2[d.class][4] + 1;
					end
				else
					classNames2[d.class] = {_G.LOCALIZED_CLASS_NAMES_MALE[d.class:upper()],d.class:lower(),1,(d.collected) and 1 or 0};
				end

				-- get abilities and add it to filter table
				local name,data;
				if (abilities) then
					for id,V in pairs(abilities) do
						if (abilityNames[V.name]) then
							abilityNames[V.name][3]=abilityNames[V.name][3]+1;
							if (d.collected) then
								abilityNames[V.name][4]=abilityNames[V.name][4]+1;
							end
						else
							abilityNames[V.name] = {V.name, V.trait, 1, (d.collected) and 1 or 0};
						end
						if (V.counter_name) then
							if (counterNames[V.counter_name]) then
								counterNames[V.counter_name][2]=counterNames[V.counter_name][2]+1;
								if (d.collected) then
									counterNames[V.counter_name][3]=counterNames[V.counter_name][3]+1;
								end
							else
								counterNames[V.counter_name]={V.counter_name, 1, (d.collected) and 1 or 0};
							end
						end
					end
					tinsert(d.desc,{"abilities",abilities});
				end

				if (not ids[i]) then
					-- mark as hidden and add it to special zone
					d.hidden=true;
					ns.followers[i] = {zone=-1};
				end
				followers[i] = d;
			end
		end
	end
end

local function MenuEntry_AddWaypoint(menu,zone,x,y,title)
	if (TomTom) then
		tinsert(menu,{
			label = L["Add waypoint to Tom Tom"],
			func = function()
				TomTom:AddMFWaypoint(zone,0,x/100,y/100,{title=title});
			end
		});
	end
end


--[=[ menus ]=]
local function createMenu(parent,menuElements,anchorA,anchorB)
	PlaySound("igMainMenuOptionCheckBoxOn");
	ns.MenuGenerator.InitializeMenu();
	ns.MenuGenerator.addEntry(menuElements);
	ns.MenuGenerator.ShowMenu(parent, anchorA, anchorB);
end


--[=[[ Configurations ]=]
function configMenu(self,anchorA,anchorB)
	createMenu(self,{
		--{ label = SETTINGS, title = true },
		--{ separator = true },
		{ label = "DataBroker", title=true }, --childs = {
			{
				label = L["Show minimap button"], tooltip = {L["Minimap"],L["Show/Hide minimap button"]},
				checked = function() return FollowerLocationInfoDB.Minimap.enabled; end,
				--func  = function() FollowerLocationInfoDB.Minimap.enabled = not FollowerLocationInfoDB.Minimap.enabled; if (not FollowerLocationInfoDB.Minimap.enabled) then lDBI:Hide(addon); else lDBI:Show(addon); end end
				func = function() FollowerLocationInfo_MinimapButton(); end
			},
			{
				label = L["Show coordinations on broker"], --tooltip={L[""],L[""]},
				dbType="bool", keyName="BrokerTitle_Coords",
				disabled = true
			},
			{
				label = L["Show follower count on broker"], --tooltip={L[""],L[""]},
				dbType="bool", keyName="BrokerTitle_NumFollowers",
				disabled = true
			},
		--}},
		{ separator = true },
		{ label = "Follower list", title=true }, --childs = {
			{
				label = L["Show FollowerID"], tooltip={L["Follower ID"],L["Show/Hide followerID's in follower list"]},
				dbType="bool", keyName="ShowFollowerID",
				event = function() List_Update(); end
			},
			{
				label = L["Show collected followers"], tooltip = {L["Collected followers"],L["Show/Hide collected and not collectable followers in follower list"]},
				dbType="bool", keyName="ShowCollectedFollower",
				event = function() followers=nil; List_Update(); end,
			},
			{
				label = L["Show hidden followers"], tooltip = {L["Hidden followers"],L["Show/Hide hidden followers in follower list"]},
				dbType="bool", keyName="ShowHiddenFollowers",
				event = function() followers=nil; List_Update(); end,
			},
		--}},
		{ separator = true },
		{ label = "Misc.", title=true },--childs = {
			{
				label = L["Show coordination frame"], --tooltip = {L[""],L[""]},
				dbType="bool", keyName="ShowCoordsFrame",
				--event  = function() end,
				disabled = true
			},
			--[[
			{
				--name = "questIdUrl",
				label = L["Fav. website"],
				tooltip = {L["Fav. website"],L["Choose your favorite website for further informations to a quest."]},
				dbType="select", keyName="questIdUrl
				default = "WoWHead",
				values = {
					WoWHead = "WoWHead",
					WoWDB = "WoWDB (english only)",
					Buffed = "Buffed"
				}
			}
			]]
		--}}
	},anchorA,anchorB);
end


--[=[ FLI.Desc ]=]
local DescSelected = false;

--local function Desc_TooltipEnter(self) end
--local function Desc_TooltipLeave(self) end

local function Desc_AddInfo(self, count, objType, ...)
	local p,objs,_ = self.Child,{...};
	local obj = objs[1];

	local addLine = function(title, text, img, menu, tooltip, click)
		local l = nil

		count = count + 1;

		if (not self.lines[count]) then
			self.lines[count] = CreateFrame("Button",nil,p,"FollowerLocationInfoDescLineTemplate");
			l = self.lines[count];
		else
			l = self.lines[count];
		end

		l.title:SetText((strlen(title)>0) and title..":" or "");

		if (img) then
			l.img:SetTexture("Interface\\addons\\"..addon.."\\media\\follower_"..self.info.followerID.."_"..img)
			--l.imgText:SetText();
			l:SetHeight( l.title:GetHeight() + l.img:GetHeight() + 8 );

			l.img:Show();
			--l.imgText:Show();
		else
			l.text:SetText(text);
			l:SetHeight( l.title:GetHeight() + l.text:GetHeight() + 8 );
			l.text:Show();
		end

		if (menu) and (type(menu)=="table") and (#menu>0) then
			l.Options:SetScript("OnClick",function(self) createMenu(self,menu,"TOPRIGHT","BOTTOMRIGHT") end);
			l.Options:Show();
		else
			l.Options:Hide();
		end

		if (tooltip) then
			l.tooltip = tooltip;
		end

		if (click)then
			l:SetScript("OnClick",click);
		else
			l:SetScript("OnClick",nil);
		end

		l:SetParent(p);
		l:SetPoint("TOP", (count==1) and p or self.lines[count-1], (count==1) and "TOP" or "BOTTOM", 0, (count==1) and -12 or -6);
		l:SetPoint("LEFT",self,0,0);
		l:SetPoint("RIGHT",self,0,0);
		l:Show();
	end

	if (objType=="pos") then
		local title = L["Location"];
		for i,v in ipairs(objs) do
			local location,menu=nil,{};
			if (type(v[1])=="number") then
				location = GetMapNameByID(v[1]);
			end
			if (type(v[2])=="number") and (type(v[3])=="number") then
				location = ("%s%1.1f, %1.1f"):format((location) and location.." @ " or "",v[2],v[3]);
				MenuEntry_AddWaypoint(menu,v[1],v[2],v[3],((v[4]) and v[4] or self.info.name).."|n("..location..")");
			end
			if (location) and (type(v[4])=="string") then
				addLine(title, ("%s|n(%s)"):format(v[4],location),nil,menu);
			else
				addLine(title, location, nil, menu);
			end
			title = "";
		end
	elseif (objType=="quest") or (objType=="questrow") or (objType=="event") then
		local title, qState, qTitle, qTitle2, qText, qGiver, qZone, qCoord, str, qGiverData;
		if objType=="quest" then
			title = L["Quests"];
		elseif objType=="questrow" then
			title = L["Quest row"];
		elseif objType=="event" then
			title = L["Event"];
		end
		for i,v in ipairs(objs) do
			local menu = {};
			qState, qGiver, qZone, qCoord, str = 0, "", "zone?", "?.?, ?.?", "%s|n  %s(%s @ %s)" --"%s|n    %s|n    (%s @ %s)"
			qTitle = GetQuestTitle(v[1]);
			qTitle2 = qTitle;
			if (qTitle) then
				local qIndex = GetQuestLogIndexByID(v[1]);
				if (qIndex~=0) then
					qTitle2 = qTitle .. " |cffeeee00"..L["(In questlog)"].."|r";
					tinsert(menu,{ label = TRACK_QUEST, func=function() QuestMapQuestOptions_TrackQuest(v[1]); end });
					tinsert(menu,{ label = L["Open questlog"], func=function() securecall("QuestMapFrame_OpenToQuestDetails", v[1]); end });
					tinsert(menu,{ label = L["Share quest"], func=function() QuestLogPushQuest(qIndex) end, disabled=(not (GetQuestLogPushable(qIndex) and IsInGroup())) });
				elseif (IsQuestCompleted(v[1])) then
					qTitle2 = qTitle .. " |cff888888"..L["(Completed)"].."|r"
				end
				tinsert(menu,{ label = L["On WoWHead"], func=function()
					ExternalURL = urls[FollowerLocationInfoDB.ExternalURL]("q",v[1]);
					StaticPopup_Show("FLI_URL_DIALOG");
				end });

				if ((type(v[2])=="number") and (v[2]>0) and (ns.npcs[v[2]])) or ((type(v[2])=="string") and (v[2]:find("^o[0-9]+$")) and (ns.npcs[v[2]])) then
					qGiver = ns.npcs[v[2]];
				end

				if (type(v[3])=="number") and (v[3]~=0) then
					qZone = GetMapNameByID(v[3]);
				end

				if (type(v[4])=="number") and (type(v[5])=="number") then
					qCoord = ("%1.1f, %1.1f"):format(v[4],v[5]);
					local title = qTitle .. ( (qGiver~="") and ("|n%s: %s"):format(L["Quest giver"],qGiver) or "" ) .. ("|n(%s @ %s)"):format(qZone,qCoord);
					MenuEntry_AddWaypoint(menu,v[3],v[4],v[5],title);
				elseif (type(v[4])=="string") then
					qCoord = L[v[4]];
				end

				addLine(title, str:format(qTitle2, (qGiver~="") and "» ".. qGiver.."|n   " or " ", qZone, qCoord),nil,menu);
			elseif v[1]==0 then
				addLine(title, L["Missing quest..."]);
			elseif (qTitle==false) then
				addLine(title, L["Error: quest name not found..."]);
			else
				addLine(title, L["Waiting for quest data..."]); -- from realm... (questid "..v[1]..")");
				doRefresh = true;
			end
			title = "";
		end
	elseif (objType=="desc") then
		local desc = false;
		local lang = GetLocale(); -- ns.language?

		if (obj[lang]) then
			desc = obj[lang];
		end

		if (not desc) and ((lang=="esES") or (lang=="esMX")) then
			desc = ( (obj.esES) and obj.esES ) or ( (obj.esMX) and obj.esMX ) or false;
		end
		if (not desc) and ((lang=="zhCN") or (lang=="zhTW")) then
			desc = ( (obj.zhCN) and obj.zhCN ) or ( (obj.zhTW) and obj.zhTW ) or false;
		end
		if (not desc) and ((lang=="enUS") or (lang=="enGB")) then
			desc = ( (obj.enUS) and obj.enUS ) or ( (obj.enGB) and obj.enGB ) or false;
		end
		if (not desc) and (obj.enUS) then -- fallback if possible?
			desc = obj.enUS;
		end

		if (desc) then
			if (type(desc)=="table") then
				desc = table.concat(desc,"|n");
			end
			addLine(L["Description"], desc:format(self.info.name));
		end
	elseif (objType=="img") then
		for i,v in ipairs(objs) do
			addLine(L["Image"] .. ((#objs>1) and " "..i or ""), nil, v);
		end
	elseif (objType=="vendor") then
		local title = L["Vendor"];
		local menu = {};
		for i,v in ipairs(objs) do
			local location, npc;
			if (type(v[1])=="number") and (ns.npcs[v[1]]~=nil) then
				npc = ns.npcs[v[1]];
			end
			if (type(v[2])=="number") then 
				location = GetMapNameByID(v[2])
			end
			if (type(v[3])=="number") and (type(v[4])=="number") then
				location = ("(%s%1.1f, %1.1f)"):format((location) and location.." @ " or "",v[3],v[4]); -- merge zone name with coordinations
				MenuEntry_AddWaypoint(menu,v[2],v[3],v[4],((npc) and npc or L["Vendor for "]..self.info.name).. "|n"..location );
			elseif (type(v[3])) then
				location = ("(%s @ %s)"):format(location,L[v[3]]); -- merge zone name with named location like buildings in garrison...
			end

			if (npc) and (location) then
				addLine(title,("%s|n    %s"):format(npc,location), nil, menu);
			elseif (npc) then
				addLine(title,npc,nil,nil);
			elseif (location) then
				addLine(title,location, nil, menu);
			end
			title = "";
		end
	elseif (objType=="mission") then
		for i,v in ipairs(objs) do
			if (type(v)=="number") then
				addLine(L["Mission"], C_Garrison.GetMissionName(v).."  |cff888888(MissionID: "..v..")|r");
			end
		end
	elseif (objType=="payment") then
		local str = "";
		for i,v in ipairs(objs) do
			if (strlen(str)>0) then str = str .. "|n"; end
			if v[1] == "gold" then
				str = str .. GetCoinTextureString(v[2]);
			elseif (GetCurrencyInfo(obj[1])) then
				local name,_,icon = GetCurrencyInfo(obj[1]);
				str = ("%s%s  |T%s:0|t (%s)"):format(str,obj[2],icon,name);
			else
				str = str .. obj[2] .. " ?";
			end
		end
		addLine(L["Payment"], str);
	elseif (objType=="reputation") then
		addLine(L["Reputation"], _G["FACTION_STANDING_LABEL"..obj[2]].." @ "..(ns.factions[obj[1]] or "(Oops, faction not found...)"));
	elseif (objType=="type") then
		addLine(L["Type"],L[obj]);
	elseif (objType=="requirements") then
		local req = {};
		for i,v in ipairs(objs) do
			tinsert(req,L[v]);
		end
		addLine(L["Requirements"], table.concat(req,"|n"));
	elseif (objType=="achievement") then
		local str,lnk = "";
		local IDNumber, Name, Points, Completed, Month, Day, Year, Description, Flags, Image, RewardText, IsGuild, WasEarnedByMe, EarnedBy = GetAchievementInfo(obj);
		local Char=UnitName("player");
		if (IDNumber) then
			lnk = GetAchievementLink(obj);
			str = lnk;
		else
			str = L["Can't get achievement data. %d isn't an achievement id?"]:format(obj);
		end
		addLine(L["Achievement"], str, nil, nil,
			function(self,tt) -- tooltip
				tt:SetHyperlink(lnk)
				--print(obj,lnk)
			end,
			function(self,button) -- click
				if ( not AchievementFrame ) then
					AchievementFrame_LoadUI();
				end
				
				if ( not AchievementFrame:IsShown() ) then
					AchievementFrame_ToggleAchievementFrame();
					AchievementFrame_SelectAchievement(obj);
				else
					if ( AchievementFrameAchievements.selection ~= obj ) then
						AchievementFrame_SelectAchievement(obj);
					else
						AchievementFrame_ToggleAchievementFrame();
					end
				end
			end
		);
	elseif (objType=="abilities") then
		local text = {};
		if (type(obj)=="table") then
			for _,data in pairs(obj) do
				if (data.counter_name) then
					tinsert(text,("|T%s:0|t %s (|T%s:0|t %s)"):format(data.icon, data.name, data.counter_icon, data.counter_name));
				else
					tinsert(text,("|T%s:0|t %s"):format(data.icon or "",data.name));
				end
			end
			if (#text>0) then
				addLine(L["Basic abilities/counters and traits"],table.concat(text,"|n"));
			end
		else
			--addLine(L["Basic abilities/counters and traits"],L["This follower has no basic abilities/counters or traits"]);
		end
	elseif (objType=="custom") then
		addLine(L[obj[1]], L[obj[2]]);
	end

	return count;
end

local function Desc_Update()
	local self = FollowerLocationInfoFrame.Desc;
	local DescHead = FollowerLocationInfoFrame.DescHeader;
	local InfoHead = FollowerLocationInfoFrame.InfoHeader;
	local Model = FollowerLocationInfoFrame.Model;
	local Loading = FollowerLocationInfoFrame.Loading;
	local BigModel = FollowerLocationInfoFrame.BigModelViewer.Model;
	local line,count = nil,0;

	if (not self.lines) then
		self.lines = {};
	end

	-- cleanup
	self:Hide();
	Model:Hide();
	DescHead:Hide();
	InfoHead:Hide();
	Loading:Show();
	for index=1, #self.lines do
		line = self.lines[index];
		line:SetParent(UIParent);
		line:SetHeight(0);
		line:ClearAllPoints();
		line:Hide();
		line.text:Hide();
		line.img:Hide();
		line.tooltip=nil;
	end

	Model:Hide();
	--FollowerLocationInfoDescLineTemplate
	if (DescSelected) then
		self.info = DescSelected;

		-- add all elements
		if (type(self.info.desc)=="table") then
			for i=1, #self.info.desc do
				count = Desc_AddInfo(self,count,unpack(self.info.desc[i]));
			end
		end

		if (doRefresh) then
			doRefresh=false;
			C_Timer.After(0.7, function()
				Desc_Update();
			end);
			return;
		else
			Collector.clearCache();
		end

		-- 3d Models
		local pos = {2,0,-0.62};
		if (self.info.race) and (modelPositions[self.info.race]) then
			pos = modelPositions[self.info.race];
		elseif (self.info.modelPosition) then
			pos = self.info.modelPosition;
		end
		BigModel:SetDisplayInfo(self.info.displayID);
		Model:SetDisplayInfo(self.info.displayID);
		Model:SetPosition(unpack(pos));

		if (not self.info.quality) then
			self.info.quality=2;
		end
		-- DescHead data
		DescHead.Name:SetText("|c" .. self.info.classColor .. self.info.name .. "|r");
		DescHead.Class:SetText("|cffffffff" .. self.info.className .. "|r");
		DescHead.Misc:SetText(("%s: %d, %s: %s%s|r"):format(
			LEVEL,		self.info.level,
			QUALITY,	qualities[self.info.quality].color.hex, qualities[self.info.quality].text
		));

		Model:Show();
		DescHead:Show();
		InfoHead:Hide();
	else
		local count = 0;
		local descs={
			{"Usage","Select a follower to see the description..."},
			--{"Greetings","Welcome to use this addon.|nCurrently it is still incomplete."},
			{"Followers",
				#C_Garrison.GetFollowers()..L[" listed in game (depends on your faction)"] .. "|n" ..
				numHidden..L[" hidden followers (Inn recruitement?)"] .. "|n" ..
				numKnownFollowers..L[" followers with description"]  .. "|n" ..
				numCollectedFollowers..L[" collected with this character"]
			},
			{"Version",GetAddOnMetadata(addon,"Version")},
			{"slash commands","/fli or /followerlocationinfo"},
			--{"Msg from Dev","|cff44eeffHello Friends.|n|nchanged |n|nHave a nice day|r"},
			{"Thanks @", "ditex2009 ruRU locales (horde) |nShooshpan ruRU locales (horde) |nmichaelselehov ruRU locales (alliance) |njerry99spkk zhTW locales (alliance) |nBNSSNB zhTW locales (alliance)|nananhaid zhCN locales (alliance & horde)|nand the nice community :)"}
		};

		for i,v in ipairs(descs) do
			count = Desc_AddInfo(self, count, "custom", v);
		end
		DescHead:Hide();
		InfoHead:Show();
	end
	Loading:Hide();
	self:Show();
end

local function Desc_OnScroll(self, xrange, yrange)
	if ( not yrange ) then
		yrange = self:GetVerticalScrollRange();
	end
	local value = self.Bar:GetValue();
	if ( value > yrange ) then
		value = yrange;
	end
	self.Bar:SetMinMaxValues(0, yrange);
	self.Bar:SetValue(value);
	if ( floor(yrange) == 0 ) then
		if ( self.scrollBarHideable ) then
			self.Bar:Hide();
			self.Bar.Thumb:Hide();
		else
			if ( not self.noScrollThumb ) then
				self.Bar.Thumb:Show();
			end
		end
	else
		self.Bar:Show();
		if ( not self.noScrollThumb ) then
			self.Bar.Thumb:Show();
		end
	end
end

local function Desc_OnVScroll(self,offset)
	self.Bar:SetValue(offset);
end

local function Desc_OnMouseWheel(self,value)
	local scrollStep = self.Bar:GetHeight() / 10
	if ( value > 0 ) then
		self.Bar:SetValue(self.Bar:GetValue() - scrollStep);
	else
		self.Bar:SetValue(self.Bar:GetValue() + scrollStep);
	end
end


--[=[ FLI.List ]=]
local function List_Search(self,bool)
	SearchBoxTemplate_OnTextChanged(self);
	SearchStr = (bool) and tostring(self:GetText()) or "";
	List_Update();
end

local function List_FilterUpdate()
	local self,last=FollowerLocationInfoFrame,0;

	for i=1, NUM_FILTERS do
		if (Filters[i]) then
			self["Filter"..i].Text:SetText(Filters[i][3]);
			self["Filter"..i]:Show();
			self["Filter"..i].Remove:Show();
			last=i;
		elseif(i==(last+1)) then
			self["Filter"..i].Text:SetText("");
			self["Filter"..i]:Show();
			self["Filter"..i].Remove:Hide();
		else
			self["Filter"..i].Text:SetText("");
			self["Filter"..i]:Hide();
			self["Filter"..i].Remove:Hide();
		end
	end
	List_Update();
end

local function List_FilterClear(self)
	local new={};
	for i,v in ipairs(Filters) do
		if(i~=self:GetParent().key) then
			tinsert(new,v);
		end
	end
	Filters=new;
	List_FilterUpdate();
end

local function List_FilterSet(n,t,v,l)
	Filters[n]={t,v,l};
	List_FilterUpdate();
end

local function List_FilterMenu(self)
	local Class1,Class2,Abs,Traits,Profs,Counters = {},{},{},{},{},{};
	local entries,cMax,page,nFilter = {},20,1,self:GetParent().key;

	local menu = {
		{ label = L["Choose"], title = true },
		{ separator = true },
	};

	for i,v in pairsByKeys(classNames2) do
		if (v) then
			local colorStr = classes[v[2]:upper()].colorStr
			if (type(colorStr)~="string") then colorStr="ffffff"; end
			tinsert(Class1, {
				label = ("|c%s%s|r (|cff%s%s|r/|cff%s%s|r)"):format(colorStr,v[1],(v[4]>0) and "00ff00" or "999999",v[4],"ffee00",v[3]),
				func=function() List_FilterSet(nFilter,"class",i,v[1]); end
			});
		end
	end

	for i,v in pairsByKeys(classNames1) do
		if (v) then
			tinsert(Class2,{
				label = ("|c%s%s|r (|cff%s%s|r/|cff%s%s|r)"):format(classes[v[2]:upper()].colorStr,v[1],(v[4]>0) and "00ff00" or "999999",v[4],"ffee00",v[3]),
				func=function() List_FilterSet(nFilter,"class",i,v[1]); end
			});
		end
	end

	for i,v in pairsByKeys(abilityNames) do
		if (v[2]) then
			tinsert(Traits,{
				label = ("%s (|cff%s%s|r/|cff%s%s|r)"):format(v[1],(v[4]>0) and "00ff00" or "999999",v[4],"ffee00",v[3]),
				func = function() List_FilterSet(nFilter,"ability",i,v[1]); end
			});
		else
			if (Abs[page]==nil) then Abs[page]={}; end
			tinsert(Abs[page],{
				label = ("%s (|cff%s%s|r/|cff%s%s|r)"):format(v[1],(v[4]>0) and "00ff00" or "999999",v[4],"ffee00",v[3]),
				func = function() List_FilterSet(nFilter,"ability",i,v[1]); end
			});
			if (#Abs[page]==cMax) then
				page = page+1;
			end
		end
	end

	for i,v in pairsByKeys(counterNames) do
		tinsert(Counters,{
			label = ("%s (|cff%s%s|r/|cff%s%s|r)"):format(v[1], (v[3]>0) and "00ff00" or "999999", v[3],"ffee00",v[2]),
			func = function() List_FilterSet(nFilter,"ability",i,v[1]); end
		});
	end

	if (#Class1>0)then
		tinsert(menu,{ label = L["Classes"], childs=Class1});
	end
	if (#Class2>0)then
		tinsert(menu,{ label = L["Class speccs"], childs=Class2});
	end

	if (#Traits>0) then
		tinsert(menu,{ label = L["Traits"], childs=Traits });
	end

	if (#Abs>0) then
		for i,v in ipairs(Abs) do
			tinsert(menu,{ label = L["Abilities (page %d)"]:format(i), childs=v });
		end
	end

	if (#Counters>0) then
		tinsert(menu,{ label = L["Counters"], childs=Counters });
	end

	if (#menu>2) then
		createMenu(self,menu,"TOPLEFT","TOPRIGHT");
	end
end

local function List_FilterInit(self)
	local f;
	for i=1, NUM_FILTERS do
		if (not self["Filter"..i]) then
			self["Filter"..i] = CreateFrame("Frame",nil,self,"FollowerLocationInfoFilterTemplate");
			f=self["Filter"..i];
			if (i==1) then
				f:SetPoint("TOPLEFT",self.Search,"BOTTOMLEFT",0,-2)
				f:SetPoint("TOPRIGHT",self.Search,"BOTTOMRIGHT",0,-2)
			else
				f:SetPoint("TOPLEFT",self["Filter"..(i-1)],"BOTTOMLEFT",0,-3)
				f:SetPoint("TOPRIGHT",self["Filter"..(i-1)],"BOTTOMRIGHT",0,-3)
			end
			f.Title:SetText(L["Filter %d/%d"]:format(i,NUM_FILTERS));
			f.Button:SetScript("OnClick", List_FilterMenu);
			f.Remove:SetScript("OnClick", List_FilterClear);
			f.key=i;
		end
		self["Filter"..i].Text:SetText("");
		if (i==1) then
			self["Filter"..i]:Show();
		else
			self["Filter"..i]:Hide();
		end
	end
end

local function ListEntries_Update(clear)
	local zones2follower,tmp,collected,ignore,_ = {},{};
	wipe(ListEntries);

	if (followers==nil) then
		GetFollowers();
	end

	for id,v in pairsByKeys(followers) do -- filter here!!
		ignore = false;

		-- filter 1: ShowHiddenFollowers option
		if (not FollowerLocationInfoDB.ShowHiddenFollowers) and (v.hidden) then
			ignore = true;
		end

		-- filter 2: ShowCollectedFollower option
		if (not FollowerLocationInfoDB.ShowCollectedFollower) then
			if (v.collected==true) then
				ignore = true;
			elseif (v.collectGroup) and (collectGroups[v.collectGroup]) then
				ignore = true;
			end
		end

		-- filter 3: 3 selectable filter options
		if (#Filters>0) then
			for _,filter in ipairs(Filters) do
				if (type(filter)=="table") and (type(filter[2])=="string") and (strlen(filter[2])>0) then
					if (filter[1]=="class") then
						if not (v.className:lower()==filter[2] or v.class==filter[2]) then
							ignore=true;
						end
					elseif (filter[1]=="ability") then
						local dontIgnore,name,cname=false,false,false;
						for _,V in ipairs(v.abilities) do
							V=tostring(V);
							name = C_Garrison.GetFollowerAbilityName(V);
							local counter = {C_Garrison.GetFollowerAbilityCounterMechanicInfo(V)};
							if (name) and (name==filter[2]) then
								dontIgnore=true;
							elseif (#counter~=0) and (counter[2]) and (counter[2]==filter[2]) then
								dontIgnore=true;
							end
						end
						if (not dontIgnore) then
							ignore = true;
						end
					elseif (filter[1]=="misc") then
						--[=[ ? ]=]
					end
				end
			end
		end

		-- filter 5: Searchbox filter
		if (SearchStr~="") and (not v.name:lower():find(SearchStr:lower())) then
			ignore=true;
		end

		-- now add all if not set as ignore...
		if (ignore~=true) then
			tmp[id]=v;
			if (v.zone) and (v.zone~=0) then
				if (zones2follower[v.zone]==nil) then
					zones2follower[v.zone]={};
				end
				tinsert(zones2follower[v.zone],id);
			else
				if (zones2follower[0]==nil) then
					zones2follower[0]={};
				end
				tinsert(zones2follower[0],id);
			end
		end
	end

	for i1,v1 in ipairs(factionZoneOrder) do
		if (zones2follower[v1]) then
			-- header element
			tinsert(ListEntries,{ZoneName=zoneNames[v1]});
			--
			for i2,v2 in ipairs(zones2follower[v1]) do
				tinsert(ListEntries,tmp[v2]);
			end
		end
	end
end

local function ListEntries_OnClick(self,button)
	if (ListEntrySelected==false) or (ListEntrySelected~=self.info.followerID) then
		ListEntrySelected = self.info.followerID;
		DescSelected = self.info;
	else
		ListEntrySelected = false;
		DescSelected = false;
	end

	List_Update();
	Desc_Update();
end

local function ListEntry_Setup(self,isHeader)
	if (isHeader) and (not self.IsHeader) then
		self.IsHeader = true;
		self.Portrait:Hide();
		self.Name:Hide();
		self.Level:Hide();
		self.ZoneName:Show();
		self.highlightTex:Hide();
		self.headerBG:Show();
	elseif (not isHeader) and (self.IsHeader) then
		self.IsHeader = false;
		self.headerBG:Hide();
		self.Portrait:Show();
		self.Name:Show();
		self.Level:Show();
		self.ZoneName:Hide();
		self.highlightTex:Show();
	end
	self.collected:Hide();
	self.notCollectable:Hide();
	self.quality2:Hide();
	self.quality3:Hide();
	self.quality4:Hide();
	self.selectedTex:Hide();
	self.followerID:Hide();
	self.tooltip=nil;
	self:SetScript("OnClick",nil);
	self:Disable();
end

function List_Update()
	if (not FollowerLocationInfoFrame:IsShown()) then return; end
	ListEntries_Update();
	local scroll = FollowerLocationInfoFrame.List;
	local button, index, obj;
	local offset = HybridScrollFrame_GetOffset(scroll);
	local nButtons = #scroll.buttons;
	local nEntries = #ListEntries;

	for i=1, nButtons do
		button = scroll.buttons[i];
		index = offset + i;

		if (index<=nEntries) then
			obj = ListEntries[index];

			ListEntry_Setup(button,(obj.ZoneName~=nil));
			if (obj.ZoneName) then
				button.ZoneName:SetText(obj.ZoneName);
				--button.tooltip = obj.ZoneName;
				button.tooltip = {obj.ZoneName,L["Click to expand/collapse"]};
				--[=[ TODO: add +/- button ]=]
			else
				button.info = obj;

				GarrisonFollowerPortrait_Set(button.Portrait,obj.portraitIconID);

				button.Name:SetText(("|c%s%s|r"):format(obj.classColor,obj.name));
				button.Level:SetText(obj.level);
				button.tooltip={("%s (%d)"):format(obj.name,obj.level)};

				if (obj.quality) then
					tinsert(button.tooltip,("%s: %s%s|r"):format(QUALITY,qualities[obj.quality].color.hex,qualities[obj.quality].text));
					if (button["quality"..obj.quality]) then
						button["quality"..obj.quality]:Show();
					end
				end

				if (obj.collected) then
					button.collected:Show();
					if (obj.collectGroup) then
						tinsert(button.tooltip,"|cff44ff44"..L["This follower is member of a collect group and already collected."].."|r");
					end
				end
				if (obj.collectGroup) then
					if (not obj.collected) then
						if (collectGroups[obj.collectGroup]==true) then
							button.notCollectable:Show();
							tinsert(button.tooltip,"|cffff4444"..L["This follower is member of a collect group and is no longer collectable."].."|r");
						else
							tinsert(button.tooltip,L["This follower is member of a collect group and is collectable."]);
						end
					end
					local members,t,d,c = {strsplit(".",obj.collectGroup)},{};
					for i,v in ipairs(members) do
						v=tonumber(v);
						if (v~=obj.followerID) then
							d = followers[v];
							if (d) then
								tinsert(t,((d.collected) and "|cff44ff44" or "|cffff4444") .. d.name .. "|r");
							end
						end
					end
					tinsert(button.tooltip,L["In group with:"] .. " " .. table.concat(t,", "));
				end

				if (FollowerLocationInfoDB.ShowFollowerID) then
					button.followerID:SetText("ID: "..obj.followerID);
					button.followerID:Show();
					tinsert(button.tooltip,"|cffbbbbbb"..L["FollowerID"]..": "..obj.followerID.."|r");
				end

				button:SetScript("OnClick",ListEntries_OnClick);
				if (ListEntrySelected) and (ListEntrySelected==obj.followerID) then
					button.selectedTex:Show();
				end
				button:Enable();
			end

			if (obj.tooltip) then
				button.tooltip=obj.tooltip;
			end

			button:Show();
		else
			button:Hide();
		end
	end

	local height = scroll.ButtonHeight + ListButtonOffsetY;
	HybridScrollFrame_Update(scroll, nEntries * height, nButtons * height);
end


--[=[ event handling ]=]
local eventFrame=CreateFrame("Frame");
eventFrame:SetScript("OnEvent", function(self,event,arg1,...)
	if (event=="ADDON_LOADED") and (arg1==addon) then
		if (FollowerLocationInfoDB==nil) then
			FollowerLocationInfoDB={Minimap={enabled=true}};
		end
		if (FollowerLocationInfoDB.questTitleLocale~=GetLocale()) then
			FollowerLocationInfoDB.questTitleLocale=GetLocale();
			FollowerLocationInfoDB.questTitles = {};
		end
		if (FollowerLocationInfoDB.questTitles==nil) then
			FollowerLocationInfoDB.questTitles = {};
		end
		for i,v in pairs({
			Minimap = {enabled=true},
			ShowFollowerID = true,
			ShowCoordsFrame = true,
			BrokerTitle_Coords = false,
			BrokerTitle_NumFollowers = true,
			ShowCollectedFollower = false,
			ShowHiddenFollowers = false,
			ExternalURL = "WoWHead",
			ListOpen = true,
			language = false
		}) do
			if (FollowerLocationInfoDB[i]==nil) then
				FollowerLocationInfoDB[i] = v;
			end
		end
		for i,v in pairs(_G.RAID_CLASS_COLORS) do
			if (_G.CUSTOM_CLASS_COLORS) and (_G.CUSTOM_CLASS_COLORS[i]) and (_G.CUSTOM_CLASS_COLORS[i].colorStr) then
				classes[i] = _G.CUSTOM_CLASS_COLORS[i];
			else
				classes[i] = v;
			end
		end

		numKnownFollowers = 0;
		for i,v in pairs(ns.followers) do
			local Data = ((neutral) and v[2]) or ((ns.faction=="Alliance") and v[2] or v[3]) or {};
			if (#Data>0) and (Data.zone~=0) and (not Data.ignore) then
				if (Data.collectGroup) and (collectGroups[Data.collectGroup]==nil) then
					collectGroups[Data.collectGroup]=false;
				end
				if (not notCount) then
					numKnownFollowers = numKnownFollowers + 1;
				end
			end
		end
	end

	if (event=="PLAYER_ENTERING_WORLD") then
		broker.init();
		onEvent=true;
		if (FollowerLocationInfoDB.Minimap.enabled) then
			broker.minimap();
		end
		if (FollowerLocationInfoDB.ListOpen) then
			FollowerLocationInfo_ToggleList(true);
		end
		if (UnitLevel("player")>=90) then
			GetBlizzardData();
			C_Timer.After(15,GetBlizzardData);
		end
	end

	if (event=="ADDON_LOADED" and arg1=="Blizzard_GarrisonUI") then
		GarrisonMissionFrame.MissionTab:HookScript("OnShow", function()
			updateLock=true;
		end);

		GarrisonMissionFrame.MissionTab:HookScript("OnHide", function()
			updateLock=false;
		end);
	end

	if (event=="GARRISON_FOLLOWER_LIST_UPDATE") then
		GetBlizzardData();
	end
end);
eventFrame:RegisterEvent("ADDON_LOADED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");


--[=[ public functions ]=]
function FollowerLocationInfo_Toggle()
	if (FollowerLocationInfoFrame:IsShown()) then
		FollowerLocationInfoFrame:Hide();
	else
		FollowerLocationInfoFrame:Show();
	end
end

function FollowerLocationInfo_ToggleCollected()
	FollowerLocationInfoDB.ShowCollectedFollower = not FollowerLocationInfoDB.ShowCollectedFollower;
	if (FollowerLocationInfoFrame:IsShown()) then
		List_Update();
	end
end

function FollowerLocationInfo_ToggleIDs()
	FollowerLocationInfoDB.ShowFollowerID = not FollowerLocationInfoDB.ShowFollowerID;
	if (FollowerLocationInfoFrame:IsShown()) then
		List_Update();
	end
end

function FollowerLocationInfo_ResetConfig()
	wipe(FollowerLocationInfoDB);
	ReloadUI();
end

function FollowerLocationInfo_MinimapButton()
	if (broker.lDBI:IsRegistered(addon)) then
		if (FollowerLocationInfoDB.Minimap.enabled) then
			broker.lDBI:Hide(addon);
			FollowerLocationInfoDB.Minimap.enabled = false;
		else
			broker.lDBI:Show(addon);
			FollowerLocationInfoDB.Minimap.enabled = true;
		end
	else
		FollowerLocationInfoDB.Minimap.enabled = true;
		broker.minimap();
	end
end

function FollowerLocationInfo_PrintMissingData(bool)
	local missing={npcs={},objs={},zones={},descs={}};

	local _=function(followerID,desc)
		if (not desc.zone) or (desc.zone==0) then
			missing.zones[followerID]=true;
		end
		if (#desc==0) then
			missing.descs[followerID]=true;
		else
			for index, data in ipairs(desc) do
				if (data[1]=="quest" or data[1]=="questrow" or data[1]=="event") then
					for i=2,#data do
						if (type(data[i][2])=="number") and (data[i][2]>0) and (bool or not ns.npcs[data[i][2]]) then
							missing.npcs[data[i][2]]=true;
						elseif (type(data[i][2])=="string" and data[i][2]:find("^o")) and (bool or not ns.npcs[data[i][2]]) then
							missing.objs[gsub(data[i][2],"o","")]=true;
						end
						if (type(data[i][8])=="number") and (data[i][8]>0) and (bool or not ns.npcs[data[i][8]]) then
							missing.npcs[data[i][8]]=true;
						elseif (type(data[i][8])=="string" and data[i][8]:find("^o")) and (bool or not ns.npcs[data[i][8]]) then
							missing.objs[gsub(data[i][8],"o","")]=true;
						end
					end
				elseif (data[1]=="vendor") then
					for i=2,#data do
						if (type(data[i][1])=="number") and (data[i][1]>0) and (bool or not ns.npcs[data[i][2]] ) then
							missing.npcs[data[i][1]]=true;
						end
					end
				end
			end
		end
	end

	for followerID,data in pairs(ns.followers) do
		_(followerID,data[2] or {}); -- neutral or alliance data
		if (data[1]==false) then
			_(followerID,data[3] or {}); -- horde data
		end
	end

	local x;
	for i,v in pairs(missing) do
		x={}; for k in pairs(v) do tinsert(x,k); end
		if (#x>0) then
			table.sort(x);
			print("|cffff4444FLI|r","|cffffff00"..i.."?|r", "|cff44aaff"..table.concat(x,"|r, |cff44aaff").."|r");
		end
	end
	collectgarbage("collect");
end

function FollowerLocationInfo_ToggleList(force)
	local self = FollowerLocationInfoFrame;
	if (onEvent==false) and (not self:IsShown()) then return end

	local n, h = self.ListToggle:GetNormalTexture(),self.ListToggle:GetHighlightTexture();
	if (force==false) or (self.List:IsShown()) then
		local tx=[[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]];
		self.List:Hide();
		self.ListBG:Hide();
		self.ListOptionBG:Hide()
		self.Search:Hide();
		self.Filter1:Hide();
		self.Filter2:Hide();
		self.Filter3:Hide();
		n:SetTexture(tx);
		h:SetTexture(tx);
		if (force==nil) then
			FollowerLocationInfoDB.ListOpen=false;
		end
	elseif (force==true) or (not self.List:IsShown()) then
		local tx = [[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]];
		self.List:Show();
		self.ListBG:Show();
		self.ListOptionBG:Show()
		self.Search:Show();
		n:SetTexture(tx);
		h:SetTexture(tx);
		if (force==nil) then
			FollowerLocationInfoDB.ListOpen=true;
		end
		List_FilterUpdate();
		--List_Update();
	end
end

function FollowerLocationInfo_UpdateLock(bool)
	-- dummy, this function is deprecated
end

function FollowerLocationInfo_ResetScale()
	FollowerLocationInfoDB.scale = 1;
	FollowerLocationInfoFrame:SetScale(1);
end


--[=[ temporary function ]=]
local FollowerLocationInfo_Collector=nil;
do
	local f=false;
	function FollowerLocationInfo_Collector()
		if (UnitLevel("player")<90) then
			print("Sorry, the collect function can't work on characters under level 90. blizzards function contains a bug to return wrong data.");
			return;
		end

		if (not f) then
			f = CreateFrame("Frame");
			f.doUpdate=false;
			f.updateCount=0;
			f:SetScript("OnUpdate",function(self,elapsed)
				if (not f.doUpdate) then
					return;
				end

				if (self.elapse == nil) then
					self.elapse = 0;
				end

				if (self.elapse>5) then
					self.elapse = 0;
					f.updateCount=f.updateCount+1;
					FollowerLocationInfo_Collector();
				else
					self.elapse=self.elapse+elapsed;
				end
			end);
		end

		local test=C_Garrison.GetFollowerInfo(34);
		if ((faction==1) and (test.displayID~=55047)) or ((faction==2) and (test.displayID~=55046)) then -- is it save to test on displayID?
			if (f.updateCount==3) then
				f.doUpdate = false;
				print("collector failed. please try it again on an other character.");
				return;
			end
			f.doUpdate = true;
			print("wrong faction data... retry to collect in 5 sec.");
			return;
		else
			f.doUpdate = false;
		end

		for i=32, 463 do
			local d=C_Garrison.GetFollowerInfo(i);
			if (d) and (d.portraitIconID>0) then
				addLocale("follower",(d.garrFollowerID) and tonumber(d.garrFollowerID) or d.followerID,d.name);
				addLocale("classspec",tostring(d.classSpec),d.className);
			end
		end
		print("collector finished");
	end
end


--[=[ FollowerLocationInfoFrame ]=]
local function FollowerLocationInfoFrame_OnShow(self)
	--DescSelected=false;
	ListEntrySelected=false;
	List_Update();
	Desc_Update();
end

function FollowerLocationInfoFrame_OnLoad(self)
	-- FLI.List
	self.List.Bar:SetScale(0.7);
	self.List.Bar.trackBG:Hide();
	self.List.Bar.doNotHide=true;
	self.List.update = List_Update;
	HybridScrollFrame_CreateButtons(self.List, "FollowerLocationInfoListButtonTemplate",0,0,nil,nil,ListButtonOffsetX, -ListButtonOffsetY);
	if (select(4,GetBuildInfo())<60000) then
		self.List.buttons[2]:SetPoint("TOPLEFT",self.List.buttons[1],"BOTTOMLEFT",1, (-ListButtonOffsetY) - 1)
	end
	self.List.ButtonHeight = self.List.buttons[1]:GetHeight();

	-- FLI.Desc
	self.Desc.Bar:SetScale(0.7);
	self.Desc:SetScript("OnScrollRangeChanged",Desc_OnScroll)
	self.Desc:SetScript("OnVerticalScroll",Desc_OnVScroll)
	self.Desc:SetScript("OnMouseWheel",Desc_OnMouseWheel)

	-- FLI.ConfigButton
	self.ConfigButton:SetScript("OnClick",function(self) configMenu(self,"TOPRIGHT","BOTTOMRIGHT") end);

	-- FLI
	self:SetUserPlaced(true);
	self:SetFrameLevel(10);
	self:SetScript("OnShow", FollowerLocationInfoFrame_OnShow);
	self.RegisterEvent = error;
	self.UnregisterEvent = error;

	-- FLI -- FilterElements
	self.Search:SetScript("OnTextChanged", List_Search);
	List_FilterInit(self)

	-- FLI.ListBG / FLI.ListOptionBG
	self.ListBG:SetFrameLevel(self:GetFrameLevel()-2);
	self.ListOptionBG:SetFrameLevel(self:GetFrameLevel()-4);
	self.ListToggle.tooltip = L["Show/Hide follower list"];

	-- FLI.BigModelViewer
	self.BigModelViewer:SetFrameLevel(self:GetFrameLevel()-4);
	self.BigModelViewer.Border:SetFrameLevel(self:GetFrameLevel()-2);
	self.BigModelViewerToggle.tooltip = L["Show/Hide big 3d model viewer"];
end


--[=[ Blizzard environment hooks ]=]
_G.WorldMapFrame:HookScript("OnShow",function(self)
	local f = FollowerLocationInfoFrame;
	if (not f:IsUserPlaced()) then
		f:ClearAllPoints();
		f:SetPoint("LEFT",self,"RIGHT",30,0);
	end
end);

_G.WorldMapFrame:HookScript("OnHide",function(self)
	local f = FollowerLocationInfoFrame;
	if (not f:IsUserPlaced()) then
		f:ClearAllPoints();
		f:SetPoint("LEFT",UIParent,"LEFT", 300,0);
	end
end);


--[=[ chat command ]=]
SlashCmdList["FOLLOWERLOCATIONINFO"] = function(cmd)
	local cmd, arg = strsplit(" ", cmd, 2)
	local _print = function(...) print("|cffff4444FLI|r", "|cff44aaff", ..., "|r"); end
	cmd = cmd:lower()
	if (cmd=="toggle") then
		FollowerLocationInfo_Toggle();
	elseif (cmd=="collected") then
		FollowerLocationInfo_ToggleCollected();
	elseif (cmd=="ids") then
		FollowerLocationInfo_ToggleIDs();
	--elseif (cmd=="missing") then
		--FollowerLocationInfo_PrintMissingData();
	elseif (cmd=="minimap") then
		FollowerLocationInfo_MinimapButton();
	elseif (cmd=="list") then
		FollowerLocationInfo_ToggleList();
	elseif (cmd=="reset") then
		FollowerLocationInfo_ResetConfig();
	--elseif (cmd=="resetscale") then
		--FollowerLocationInfo_ResetScale();
	elseif (cmd=="collectlocales") then
		FollowerLocationInfo_Collector();
	elseif (cmd=="delcollectedlocales") then
		FLI_tmpDB = {};
	else
		_print(L["Commandline options for %s"]:format(addon));
		_print(L["Usage: /fli <command>"]);
		_print("      "..L["or /followerlocationinfo <command>"]);
		_print(L["Commands:"]);
		_print("  toggle = "     .. L["Show/Hide frame"]);
		_print("  collected = "  .. L["Show/Hide collected followers"]);
		_print("  ids = "        .. L["Show/Hide follower ids"]);
		_print("  list = "       .. L["Show/Hide follower list"]);
		_print("  minimap = "    .. L["Show/Hide minimap button"]);
		_print("  reset =    "   .. L["Reset addon settings"]);
		--_print("  resetscale = " .. L["Reset window scaling"]);
		_print("~ development commands ~");
		--_print("  missing = "    .. L["Print missing data (follower and npc id's)"]);
		_print("  collectlocales = "    .. L["Collects localized follower names from one faction. It is recommented to use it on both factions. The character must be level 90 or higher."]);
		_print("  delcollectedlocales = "..L["Deletes collected localized follower names"]);
	end
end

SLASH_FOLLOWERLOCATIONINFO1 = "/fli";
SLASH_FOLLOWERLOCATIONINFO2 = "/followerlocationinfo";

