
local addon, ns = ...;
local Addon = gsub(addon,"_Journal","");
local MenuGenerator = FollowerLocationInfo.MenuGenerator;
local SecureTabs = LibStub('SecureTabs-1.0');
local levelIdx,qualityIdx,classIdx,classSpecIdx,portraitIdx,modelIdx,modelHeightIdx,modelScaleIdx,abilitiesIdx,countersIdx,traitsIdx,isCollectableIdx = 1,2,3,4,5,6,7,8,9,10,11,12; -- table indexes for FollowerLocationInfoData.basics entries.
local L,D,LC,journalVisibleEntries,activeFilter={},{},{},{},{};
local tconcat,tsort = table.concat,table.sort;
local CurrentFollower,CurrentFollower_reloaded,journalCollapsedZones,FollowerLocationInfoJournalFollowerList_UpdateVisibleEntries;
local searchText,ttShown,timeout = false,false,false;
local SPECS = LEVEL_UP_SPECIALIZATION_LINK:match("%[(.*)%]");
local NUM_FILTERS = 3;
local listPrefix = LOCALE_zhCN and "&#xB7;" or "&#xA0;&#x2022;&#xA0;";
local filter_collected = nil;


----------------------------
--- Misc local functions ---
----------------------------
function ns.print(...)
	print("|cff00ff00"..Addon.."|r",...)
end

local function pairsByKeys(t, f)
	local i,a = 0,{};
	for k in pairs(t) do
		tinsert(a, k);
	end
	tsort(a, f);
	return function() -- iterator function
		i=i+1
		if a[i]~=nil then
			return a[i], t[a[i]]
		end
	end;
end

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
	tsort(a,function(b,c) return b[2]<c[2]; end);
	return function()
		i=i+1;
		if a[i]~=nil then
			return a[i][1], t[a[i][1]];
		end
	end;
end

local function Loading(active,appendMsg,opt)
	local f=FollowerLocationInfoJournalDesc.Loading;
	if(active)then
		f:Show();
		if(type(appendMsg)=="string")then
			local tbl,str = {}, (opt~="new" and f.Info:GetText() or "");
			if(opt~="nobr" and strlen(str)>0)then
				tinsert(tbl,str);
			end
			if(opt=="nobr")then
				tinsert(tbl,str..appendMsg);
			else
				tinsert(tbl,appendMsg);
			end
			f.Info:SetText(table.concat(tbl,"|n"));
		end
	else
		f:Hide();
	end
end

function CreateExternalURL(Type,Id)
	local url,Target = nil,Type=="player" and "BattleNet" or FollowerLocationInfoDB.ExternalURL;
	local uTypes = FollowerLocationInfo.ExternalURL_unsupportedTypes;
	if not (uTypes[Target] and uTypes[Target][Type]==true) then
		url = ("|c%s|Hexternalurl:%s:%s|h[%s]|h|r"):format(LC.color("quality5"),Type,Id,L["Link to"].." "..Target);
	end
	return url;
end

-----------------------
--- Search / Filter ---
-----------------------
local GetFilterText = {
	collected = function(i) return i and COLLECTED or NOT_COLLECTED; end,
	classes   = function(i) return D.classes[i][3]; end,
	classspec = function(i) return D.classSpec[i][1]; end,
	qualities = function(i) return D.qualities[i][2]; end,
	traits    = function(i) return D.traits[i].name; end,
	abilities = function(i) return D.abilities[i].name; end,
	counters  = function(i) return D.counters[i].name; end,
	others    = function(i) return L[i]; end
};

function FollowerLocationInfoJournal_UpdateFilter()
	local p,last = FollowerLocationInfoJournal.Filter,0;
	for i=1, NUM_FILTERS do
		local f,af = p["Filter"..i],activeFilter[i];
		f.Title:SetText(FILTER..(" %d/%d"):format(i,NUM_FILTERS));
		if (af) then
			f.Text:SetText( GetFilterText[af[1]](af[2]) );
			f:Show(); f.Remove:Show();
			last=i;
		elseif(i==(last+1)) then
			f.Text:SetText("");
			f:Show(); f.Remove:Hide();
		else
			f.Text:SetText("");
			f:Hide(); f.Remove:Hide();
		end
	end
	FollowerLocationInfoJournalFollowerList_UpdateVisibleEntries();
	FollowerLocationInfoJournalFollowerList_Update();
end

function FollowerLocationInfoJournal_SetFilter(filterID,filterType,filterValue)
	activeFilter[filterID]={filterType,filterValue};
	if filterType=="collected" then
		filter_collected = filterValue;
	end
	FollowerLocationInfoJournal_UpdateFilter();
end

function FollowerLocationInfoJournal_ClearFilter(self,button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	if button=="RightButton" then
		wipe(activeFilter);
		filter_collected=nil;
	else
		if activeFilter[self:GetParent():GetID()][1]=="collected" then
			filter_collected=nil;
		end
		table.remove(activeFilter,self:GetParent():GetID());
	end
	FollowerLocationInfoJournal_UpdateFilter();
end

function FollowerLocationInfoJournal_SearchText(self)
	SearchBoxTemplate_OnTextChanged(self)
	searchText = self:GetText() or false;
	if(searchText~=false and strlen(searchText)==0)then
		searchText = false;
	end
	FollowerLocationInfoJournalFollowerList_UpdateVisibleEntries();
	FollowerLocationInfoJournalFollowerList_Update();
end

function FollowerLocationInfoJournal_FilterMenu(parent)
	local menus,disabled = {classes={},classspec={},qualities={},abilities={},traits={},counters={},others={}},{};
	local labelStr,labelStrDisabled,entries,cMax,page,filterID = "%s (|cff%s%s|r/|cff%s%s|r)","%s (%s/%s)",{},20,1,parent:GetParent():GetID();

	local get_counter = function(n,i,noColor)
		local v = {};
		if(i and type(D.counter[n][i])=="table")then
			v = D.counter[n][i];
		elseif(type(D.counter[n])=="table")then
			v = D.counter[n];
		end
		if noColor then
			return v[2] or "?", v[1] or "?";
		end
		return (type(v[2])=="number" and v[2]>0) and "00ff00" or "999999", v[2] or "?", "ffee00", v[1] or "?";
	end

	local active = {};
	for i=1, #activeFilter do
		if active[activeFilter[i][1]]==nil then
			active[activeFilter[i][1]]={};
		end
		active[activeFilter[i][1]][activeFilter[i][2]]=true;
	end

	-- CLASSES
	local sortedClasses = CopyTable(D.classes);
	tsort(sortedClasses,function(a,b) return a[3]<b[3]; end);
	for i,v in ipairs(sortedClasses) do
		local childs = {};
		tinsert(menus.classes,{
			label = labelStr:format(
				LC.color(v[2],v[3]),
				D.counter.class[v[1]][2]>0 and "00ff00" or "999999",
				D.counter.class[v[1]][2],"ffee00",
				D.counter.class[v[1]][1]
			),
			func=function()
				FollowerLocationInfoJournal_SetFilter(filterID,"classes",v[1]);
			end
		});
	end

	-- CLASS SPECS
	for specId, specData in pairsByFields(D.classSpec,3,1)do
		if D.counter.classspec[specId][1]>0 then
			local disabled, label = false, labelStr:format(LC.color(specData[2],specData[1]), get_counter("classspec",specId));
			if (active.classes~=nil and active.classes[specData[4]]~=true) then
				disabled,label = true,labelStrDisabled:format(specData[1], get_counter("classspec",specId,true));
			end
			tinsert(menus.classspec,{
				label = label,
				func=function()
					FollowerLocationInfoJournal_SetFilter(filterID,"classspec",specId);
				end,
				disabled = disabled
			});
		end
	end
	
	-- Qualities
	for k,v in ipairs(D.qualities) do
		if(D.counter.qualities[v[1]])then
			tinsert(menus.qualities,{
				label = labelStr:format(LC.color("quality"..v[1],v[2]), get_counter("qualities",v[1]));
				func=function()
					FollowerLocationInfoJournal_SetFilter(filterID,"qualities",v[1]);
				end
			});
		end
	end

	-- Traits
	local lastTitle = false;
	for k,v in pairsByFields(D.traits,"category","name")do
		--if D.counter.traits[k][1]>0 then
			if lastTitle~=v.category then
				if lastTitle~=false then
					tinsert(menus.traits,{separator=true});
				end
				tinsert(menus.traits,{label=v.category, title=true});
				lastTitle=v.category;
			end
			tinsert(menus.traits,{
				label=labelStr:format(v.name, get_counter("traits",k)),
				icon=v.icon,
				func=function()
					FollowerLocationInfoJournal_SetFilter(filterID,"traits",k);
				end
			});
		--end
	end

	-- Abilities
	for k,v in pairsByFields(D.abilities,"name") do
		if D.counter.abilities[k][1]>0 then
			local disabled,label = false,labelStr:format(v.name, get_counter("abilities",k));
			local counters = D.ability2counters[k];
			for i in pairs(counters) do
				if(active.counters~=nil and active.counters[i]~=true)then
					disabled,label = true,labelStrDisabled:format(v.name,get_counter("abilities",k,true));
				end
			end
			tinsert(menus.abilities,{
				label=label,
				icon=v.icon,
				func=function()
					FollowerLocationInfoJournal_SetFilter(filterID,"abilities",k);
				end,
				disabled = disabled
			});
		end
	end

	-- Counters
	for k,v in pairsByFields(D.counters,"name") do
		if D.counter.counters[k][1]>0 then
			tinsert(menus.counters,{
				label=labelStr:format(v.name, get_counter("counters",k)),
				icon=v.icon,
				func=function()
					FollowerLocationInfoJournal_SetFilter(filterID,"counters",k);
				end
			});
		end
	end

	-- other filter options
	for i,v in pairsByFields(D.otherFiltersOrder,2)do
		tinsert(menus.others,{
			label = labelStr:format(LC.color("white",v[2]),D.otherFiltersCount[v[1]][1]>0 and "00ff00" or "999999",D.otherFiltersCount[v[1]][2],"ffee00",D.otherFiltersCount[v[1]][1]),
			func = function() FollowerLocationInfoJournal_SetFilter(filterID,"others",v[1]); end
		});
	end

	-- check on empty submenus and disable it
	for i,v in pairs(menus)do
		if #menus[i]==0 then
			disabled[i]=true;
			menus[i]=nil;
		end
	end

	-- check on active filters and disable submenus
	for i=1, #activeFilter do
		if(filterID~=i)then
			disabled[activeFilter[i][1]]=true;
			menus[activeFilter[i][1]]=nil;
		end
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
	MenuGenerator.InitializeMenu();
	MenuGenerator.addEntry({
		{ label = COLLECTED, func=function() FollowerLocationInfoJournal_SetFilter(filterID,"collected",true); end, disabled = filter_collected==true},
		{ label = NOT_COLLECTED, func=function() FollowerLocationInfoJournal_SetFilter(filterID,"collected",false); end, disabled = filter_collected==false},
		{ separator = true },
		{ label = L["Classes"], childs=menus.classes, disabled = disabled.classes },
		{ label = SPECS, childs=menus.classspec, disabled = disabled.classspec },
		{ label = QUALITY, childs=menus.qualities, disabled = disabled.qualities },
		{ label = GARRISON_TRAITS, childs=menus.traits, disabled = disabled.traits },
		{ label = ABILITIES, childs=menus.abilities, disabled = disabled.abilities },
		{ label = L["Counters"], childs=menus.counters, disabled = disabled.counters },
		{ label = L["Obtainable by"], childs=menus.others, disalbed = disabled.others }
	});
	MenuGenerator.ShowMenu(parent, "TOPLEFT","TOPRIGHT");
end


--------------------------------------
--- Journal FollowerList Functions ---
--------------------------------------
function FollowerLocationInfoJournal_OnHyperlinkEnter(self,link,text,forced)
	local forceReload,ttImageSize,tt=false,300;
	-- all "garr" prefixed hyperlinks are part of a special tooltip type
	-- and doesn't work with normal GameTooltip:SetHyperlink().
	if(link:match("^garr"))then
		tt=GarrisonFollowerAbilityTooltip;
		tt:ClearAllPoints();
		tt:SetPoint("LEFT", CollectionsJournal, "RIGHT", 1, 0);

		if(link:match("^garrfollowerability"))then
			local _,id = strsplit(":",link);
			GarrisonFollowerAbilityTooltip_Show(tonumber(id),LE_FOLLOWER_TYPE_GARRISON_6_0);
		else
			-- GarrisonFollowerTooltipShow( ?
		end
	else
		tt=GameTooltip;
		tt:Hide(); tt:ClearLines();
		tt:SetOwner(FollowerLocationInfoJournalDesc,"ANCHOR_NONE");
		tt:SetPoint("LEFT", CollectionsJournal, "RIGHT", 1, 0);

		if(link:match("^image"))then
			-- custom hyperlink type "image"
			local _,id,idx = strsplit(":",link);
			tt:AddLine(("|TInterface\\AddOns\\FollowerLocationInfo_Data\\media\\follower_%s_%s:%d:%d:0:0|t"):format(id,idx,ttImageSize,ttImageSize));
			forceReload=true;
		elseif(link:match("^externalurl"))then
			-- custom hyperlink type "externalurl"
			if(link:match("player"))then
				tt:AddLine(L["Link to"].." BattleNet");
			else
				tt:AddLine(L["Link to"].." "..FollowerLocationInfoDB.ExternalURL);
			end
			tt:AddLine(L["Opening a dialog popup with the web address"]);
		elseif(link:match("^tomtom"))then
			-- custom hyperlink type "tomtom"
			local _, zone, x, y, label = strsplit(":",link);
			tt:AddLine("TomTom");
			if label~="-" then
				tt:AddDoubleLine(L["Label"],label);
			end
			tt:AddDoubleLine(ZONE,GetMapNameByID(zone));
			tt:AddDoubleLine(L["Coordinations"],x..", "..y);
			tt:AddLine(" ");
			tt:AddDoubleLine(L["Left-click"],L["Add waypoint to TomTom"]);
		else
			-- regular blizzard hyperlinks
			tt:SetHyperlink(link);
		end

		tt:Show();
	end
	if forceReload and forced~=true then
		C_Timer.After(0.2,function()
			if tt:IsShown() then
				tt:Hide();
				tt:ClearLines();
				FollowerLocationInfoJournal_OnHyperlinkEnter(self,link,text,true);
			end
		end);
	end
end

function FollowerLocationInfoJournal_OnHyperlinkLeave(self,link,text)
	ttShown=false;
	GameTooltip:Hide();
	GarrisonFollowerAbilityTooltip:Hide();
end

function FollowerLocationInfoJournal_OnHyperlinkClick(self,link,text,button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local Type = link:match("^([a-zA-Z0-9]*):");
	-- creates an modifier string with fixed order. -- [Alt][Shift][Ctrl]
	local Modifiers = (IsAltKeyDown() and "Alt" or "") .. (IsShiftKeyDown() and "Shift" or "") .. (IsControlKeyDown() and "Ctrl" or "");

	--- blizzHyperlinks & customizedHyperlinks
	-- that defines default and customized hyperlink actions on regular and FLI internal hyperlinks.
	-- [<linkType>] = true or {[<Modifier + Button>] = true}
	local customizedHyperlinks = {
		image=true,
		tomtom=true,
		achievement={LeftButton=true},
		externalurl=true
	};

	local blizzHyperlinks = {
		spell=true,
		unit=true,
		achievement=true
	};

	if customizedHyperlinks[Type]==true or (type(customizedHyperlinks[Type])=="table" and customizedHyperlinks[Type][Modifiers..button]==true) then
		if Type=="tomtom" then
			local _, zone, x, y, title = strsplit(":",link);
			zone,x,y=tonumber(zone),tonumber(x)/100,tonumber(y)/100;
			if(title)then
				title = {title=title};
			else
				title = nil;
			end
			TomTom:AddMFWaypoint(zone,0,x,y,title);
		elseif Type=="achievement" then
			local id = tonumber(link:match("achievement:(%d+)"));
			if ( not AchievementFrame ) then
				AchievementFrame_LoadUI();
			end
			
			if ( not AchievementFrame:IsShown() ) then
				AchievementFrame_ToggleAchievementFrame();
				AchievementFrame_SelectAchievement(id);
			else
				if ( AchievementFrameAchievements.selection ~= id ) then
					AchievementFrame_SelectAchievement(id);
				else
					AchievementFrame_ToggleAchievementFrame();
				end
			end
		elseif Type=="externalurl" then
			local _, oType, oId, oRealm = strsplit(":",link);
			StaticPopup_Show("FOLLOWERLOCATIONINFO_EXTERNALURL_DIALOG",nil,nil,{oType,oId,oRealm});
		end
		-- Type=="image" -- no action
	elseif blizzHyperlinks[Type]==true then
		SetItemRef(link,text,button,self);
	end
	-- StaticPopup_Show("FOLLOWERLOCATIONINFO_EXTERNALURL_DIALOG",nil,nil,{<Type[string]>,<Id[number|string]>});
end


--------------------------------------
--- Journal FollowerList Functions ---
--------------------------------------
function FollowerLocationInfoJournalFollowerList_UpdateVisibleEntries()
	if(not journalCollapsedZones)then
		journalCollapsedZones = {};
		for i,v in pairs(D.zoneOrder)do
			journalCollapsedZones[v] = false;
		end
		journalCollapsedZones[0.3] = true;
		journalCollapsedZones[0.4] = true;
	end

	local Zone = {};
	for i,v in pairs(D.zoneOrder)do
		Zone[v] = {};
	end

	-- filter[<classes|classspec|traits|abilities|counters|others>] = <value[number|string]>
	local filter = {};
	if #activeFilter>0 then
		for i,v in ipairs(activeFilter) do
			filter[v[1]] = v[2];
		end
	else
		filter = false;
	end

	for id, v in pairs(D.basics)do
		local add = true;

		if filter then

			if filter.collected==true and not D.collected[id] then
				add = false;
			elseif filter.collected==false and D.collected[id] then
				add = false;
			end
			if filter.classes and filter.classes~=v[classIdx] then
				add = false;
			end
			if filter.classspec and filter.classspec~=v[classSpecIdx] then
				add = false;
			end
			if filter.qualities and filter.qualities~=v[qualityIdx] then
				add = false;
			end
			if filter.abilities then
				local tmp = false;
				for i=1, #v[abilitiesIdx] do
					if filter.abilities==v[abilitiesIdx][i] then
						tmp = true;
					end
				end
				if(not tmp)then
					add = false;
				end
			end
			if filter.counters then
				local tmp = false;
				for i=1, #v[countersIdx] do
					if filter.counters==v[countersIdx][i] then
						tmp = true;
					end
				end
				if(not tmp)then
					add = false;
				end
			end
			if filter.traits then
				local tmp = false;
				for i=1, #v[traitsIdx] do
					if filter.traits==v[traitsIdx][i] then
						tmp = true;
					end
				end
				if(not tmp)then
					add = false;
				end
			end
			if filter.others and D.otherFilters[filter.others][id]~=true then
				add = false;
			end
		else
			add = true;
		end

		if type(searchText)=="string" and rawget(L,"follower_"..id)~=nil and not L["follower_"..id]:lower():match(searchText:lower()) then
			add = false;
		end

		if(add)then
			local zone,from = 0.4,0;
			if(not v[isCollectableIdx])then
				zone = 0.3; -- recruitable follower by Lunarfall Inn / Frostwall Tavern
				from = 1;
			elseif(D.descriptions[id])then
				zone = D.descriptions[id].zone; -- zone id is part of the description
				from = 2;
				if(D.zone2zoneGroup[zone])then
					zone = D.zone2zoneGroup[zone];
					from = 3;
				end
			end
			if(Zone[zone]==nil)then
				--ns.print(type(zone),zone,from);
			end
			tinsert(Zone[zone],id);
		end
	end

	local entries = {};
	for _,zoneID in pairs(D.zoneOrder)do
		if(#Zone[zoneID]>0)then
			tinsert(entries,{zoneID, D.zoneNames[zoneID], journalCollapsedZones[zoneID], #Zone[zoneID]});
			if(not journalCollapsedZones[zoneID])then
				for i,v in ipairs(Zone[zoneID])do
					tinsert(entries,v);
				end
			end
		end
	end

	journalVisibleEntries = entries;
end

function FollowerLocationInfoJournalFollowerList_Update()
	if(not FollowerLocationInfoJournal:IsVisible())then return end
	local self = FollowerLocationInfoJournalFollowerList;

	local cGroups = {};
	local nButtons,nEntries,button,index,id=#self.buttons,#journalVisibleEntries;

	-- Update scroll frame
	if ( not FauxScrollFrame_Update(self, nEntries, nButtons, self.buttonHeight,nil,nil,nil,nil,nil,nil,true ) ) then
		self.ScrollBar:SetValue(0);
	end

	local offset = FauxScrollFrame_GetOffset(self);

	for i=1, nButtons do
		button = self.buttons[i];
		index = offset + i;

		if index<=nEntries then
			id = journalVisibleEntries[index];

			button.collected:Hide();
			button.notCollectable:Hide();
			button.followerID:Hide();
			button.tooltip=nil;
			button.selected:Hide();

			if(type(id)=="table")then
				button.zoneToggle.id=id[1];
				button.zoneToggle:SetNormalTexture("Interface\\Buttons\\UI-"..(not id[3] and "Minus" or "Plus").."Button-Up");
				if id[4]==0 then
					button.zone:SetText("|cff888888"..L[id[2]].."|r");
					button.zoneToggle:Disable();
				else
					button.zone:SetText(L[id[2]]);
					button.zoneToggle:Enable();
				end
				button.zoneToggle:Show();
				button.zone:Show();
				if(button.portrait)then
					button.portrait:Hide();
				end
				button.name:Hide();
				button.quality:Hide();
				button.background:Hide();
				button:Disable();
			else
				if(button.portrait)then
					GarrisonFollowerPortrait_Set(button.portrait,D.basics[id][portraitIdx]);
				end

				button.id = id;
				local name = LC.color(D.classes[D.basics[id][classIdx]][2],L["follower_"..id]);
				button.name:SetText(name);
				button.tooltip={name};

				if (D.basics[id][qualityIdx]) then
					local q = D.basics[id][qualityIdx];
					local c = ITEM_QUALITY_COLORS[q];
					tinsert(button.tooltip,("%s: %s%s|r"):format(QUALITY,c.hex, _G[("ITEM_QUALITY%d_DESC"):format(q)]));
					button.quality:SetVertexColor(c.r, c.g, c.b);
				end

				-- check collected status
				if(D.collected[id])then
					button.collected:Show();
				end

				-- check collect group membership
				if ((D.descriptions[id]) and D.descriptions[id].collectGroup) then
					if(D.collected[id])then
						tinsert(button.tooltip,"|cff00bb00"..L["This follower is member of a collect group and already collected."].."|r");
					else
						local collected = false;
						for i,v in ipairs(D.descriptions[id].collectGroup)do
							if D.collected[v] then
								collected=true;
							end
						end
						if (collected) then
							button.notCollectable:Show();
							tinsert(button.tooltip,"|cffee0000"..L["This follower is member of a collect group and isn't longer obtainable."].."|r");
						else
							tinsert(button.tooltip,"|cffffcc00"..L["This follower is member of a collect group and is obtainable."].."|r");
						end
					end
				end

				button.followerID:SetText("ID: "..id);
				if (FollowerLocationInfoDB.ShowFollowerID) then
					button.followerID:Show();
					tinsert(button.tooltip,"|cffbbbbbb"..L["FollowerID"]..": "..id.."|r");
				end

				button.zoneToggle:Hide();
				button.zone:Hide();
				if(button.portrait)then
					button.portrait:Show();
				end
				button.name:Show();
				button.quality:Show();
				button.background:Show();
				if(self.selected == id)then
					button.selected:Show();
				end

				button:Enable();
			end
			button:Show();
		else
			button:Hide();
		end
	end
end

function FollowerLocationInfoJournalFollowerList_OnVerticalScroll(self,offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, self.buttonHeight, FollowerLocationInfoJournalFollowerList_Update);
end

function FollowerLocationInfoJournalFollowerList_OnLoad(self)
	self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 8, -16);
	self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 8, 16);
	self.offset = 0;
	self.buttonHeight = 33;

	local maxButtons = 12;
	if FollowerLocationInfoData.journalDocked then
		maxButtons = 13;
	end

	self.buttons = {};
	for i=1, maxButtons do
		self.buttons[i] = CreateFrame("Button",nil,self,"FollowerLocationInfoJournalFollowerList_ButtonTemplate");
		if(i==1)then
			self.buttons[i]:SetPoint("TOP", self, "TOP", 0, 0);
		else
			self.buttons[i]:SetPoint("TOP", self.buttons[i-1], "BOTTOM", 0, -1);
		end
	end
end

function FollowerLocationInfoJournal_ToggleZone(zoneID)
	if(rawget(D.zoneNames,zoneID))then
		journalCollapsedZones[zoneID] = not journalCollapsedZones[zoneID];
	end
	local scroll = FollowerLocationInfoJournalFollowerList;
	local offset = HybridScrollFrame_GetOffset(scroll);
	FollowerLocationInfoJournalFollowerList_UpdateVisibleEntries();
	FollowerLocationInfoJournalFollowerList_Update();
end


---------------------------------------------------
--- Journal Follower Card&Description Functions ---
---------------------------------------------------
function FollowerLocationInfoJournalFollowerCard_Update()
	local id = CurrentFollower;
	local data = FollowerLocationInfoJournalFollowerCard.Data;
	local model = FollowerLocationInfoJournalFollowerCard.model;
	local link;

	if id then
		link = CreateExternalURL("gf",id) or "|n";
	else
		link = CreateExternalURL("player",UnitName("player")) or "|n";
	end

	local html = "<html><body>"..
				 "<h1>|c%1$s%2$s|r</h1>"..
				 "<p>|c%1$s%3$s|r</p>"..
				 "<p>"..link.."</p>"..
				 ((LOCALE_zhCN or LOCALE_zhTW) and "<p>|n</p>" or "<p>|n</p><br/>").. 
				 "<h3>|cffffcc00"..LEVEL..":|r %4$s</h3>"..
				 "<p>|n</p>"..
				 "<h3>|cffffcc00"..QUALITY..":|r %5$s</h3>"..
				 "<p>|n</p>"..
				 "<h3>|cffffcc00"..ABILITIES.."/"..GARRISON_TRAITS..":|r</h3>"..
				 "%6$s"..
				 "</body></html>";

	if(id)then
		local basic = D.basics[id];
		local abilitiesStr = "";
		if(#basic[abilitiesIdx]>0 or #basic[traitsIdx]>0)then
			local Abs = {};
			for i,v in ipairs(basic[abilitiesIdx])do
				if D.abilities[v] then
					abilitiesStr = abilitiesStr .. "<h3>|T" .. D.abilities[v].icon .. ":0|t " .. D.abilities[v].link.."</h3>";
				else
					tinsert(D.errors,"ability-"..v.."-missing");
				end
			end
			for i,v in ipairs(basic[traitsIdx])do
				if D.traits[v] then
					abilitiesStr = abilitiesStr .. "<h3>|T" .. D.traits[v].icon .. ":0|t " .. D.traits[v].link.."</h3>";
				else
					tinsert(D.errors,"triat-"..v.."-missing");
				end
			end
		end

		data:SetText(html:format(
			LC.color(D.classes[basic[classIdx]][2]),
			L["follower_"..id],
			D.classSpec[basic[classSpecIdx]][1],
			basic[levelIdx],
			LC.color("quality"..basic[qualityIdx],_G["ITEM_QUALITY"..basic[qualityIdx].."_DESC"]),
			abilitiesStr
		));
		model:SetDisplayInfo(basic[modelIdx]);

		data:Show();
		model:Show();

	elseif( true )then

		local quality = 6;
		local _,class,classID = UnitClass("player"); -- 6
		local classSpec = GetSpecialization(); -- 2
		if classID and classSpec and D.playerSpec[classID][classSpec] and D.classSpec[D.playerSpec[classID][classSpec]] then
			classSpec = D.classSpec[D.playerSpec[classID][classSpec]][1];
		else
			--[=[
			ns.print(
				classID,
				classSpec,
				D.playerSpec[classID][classSpec],
				D.classSpec[D.playerSpec[classID][classSpec]]
			);
			--]=]
			classSpec = UNKNOWN;
		end

		local abilities = {};
		for i,v in ipairs({GetProfessions()}) do
			if i<=3 then
				local name, icon = GetProfessionInfo(v);
				if name and D.playerTraits[name] and D.traits[D.playerTraits[name]] then
					local v = D.traits[D.playerTraits[name]];
					tinsert(abilities,"|T" .. v.icon .. ":0|t " .. v.link);
				end
			end
		end

		data:SetText(html:format(
			LC.color(class),
			UnitName("player"),
			classSpec,
			UnitLevel("player"),
			LC.color("quality"..quality,_G["ITEM_QUALITY"..quality.."_DESC"]),
			#abilities>0 and "<h3>"..table.concat(abilities,", ").."</h3>" or ""
		));
		model:SetUnit("player");

		data:Show();
		model:Show();
	else
		data:Hide();
		model:Hide();
	end
end

function FollowerLocationInfoJournalFollowerDesc_Update()
	local P = FollowerLocationInfoJournalDesc;
	if not P:IsVisible() then return end

	Loading(true,L["Init description generator..."],"new");
	P.html:Hide();

	local id,html,doRetry,title = CurrentFollower,{},false;
	local h1,h2,h3,lnk,a = "<h1>%s</h1>","<h2>%s</h2><p>|TInterface\\AddOns\\FollowerLocationInfo_Data\\media\\%s:9:256:0:8:128:16:24:64:0:16|t</p>","<h3>%s</h3>","|c%s|H%s|h[%s]|h|r","<a href='%s'>%s</a>";
	local p,pl,pr,br,img = "<p>%s</p>","<p align='left'>%s</p>","<p align='right'>%s</p>","<br/>","|cFF33aaff|Himage:%1$s:%2$s|h["..L["Image"].." %2$d]|h|r";
	local checked = " |TInterface\\Buttons\\UI-CheckBox-Check:14:14:0:0:32:32:3:29:3:29|t";
	local stateColor = {[0]="ff0000","ff9900","04ff07","ffffff"};
	local Desc = false;
	local shared = {};

	shared["Garrison building"]=function(_,id)
		local glvl = C_Garrison.GetGarrisonInfo();
		local result,state,Name,Lvl,name,lvl,_= {},0;
		_,name,_,_,_,lvl = C_Garrison.GetBuildingInfo(id);
		if glvl~=nil and  glvl>0 then
			for i,v in ipairs(C_Garrison.GetBuildings())do
				_,Name,_,_,_,Lvl = C_Garrison.GetBuildingInfo(v.buildingID);
				if(v.buildingID==id) or (name==Name)then
					state = 1;
					if(Lvl>=lvl)then
						state = 2;
					end
					break;
				end
			end
		end

		return	name,
				LEVEL .." ".. lvl .. (lvl<3 and " " .. L["or higher"] or ""),
				CreateExternalURL("b",id),
				{state=state,current=Lvl};
	end;

	shared["Brawler's Guild"]=function(_, factionId, rank)
		local _, friendRep, friendMaxRep, friendName, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionId);
		local state,standingNum = 0,tonumber(friendTextLevel:match("(%d+)"));
		if standingNum then
			state = 1;
			if standingNum>=rank then
				state = 2;
			end
		end
		return	friendName,
				RANK .. " " .. rank,
				CreateExternalURL("f",factionId),
				{state=state,current=("%s ( %d / %d )"):format(friendTextLevel,friendRep-friendThreshold,nextFriendThreshold)}
	end

	shared.Professions=function(_,id,skillNeed)
		local state, current, Name, icon, skillLevel, maxSkillLevel=0, L["Not learned"];
		local name,_,icon = GetSpellInfo(id);
		local p = {GetProfessions()};
		for i=1,#p do
			if p[i] then
				Name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(p[i]);
				if(name==Name)then
					state = 1;
					current = skillLevel.."/"..maxSkillLevel;
					if(skillLevel>=skillNeed)then
						state = 2;
					end
					break;
				end
			end
		end
		return	name,
				SKILL.." "..skillNeed,
				nil, -- CreateExternalURL("p",),
				{state=state,current=current};
	end;

	shared.Reputation=function(_,id,standingNum)
		local name, _, standingID, barMin, barMax, barValue, _, _, _, _, hasRep, _, _, _, hasBonusRepGain, canBeLFGBonus = GetFactionInfoByID(id);
		local standingColor,chk,current = "red","",("%s ( %d / %d )"):format(_G["FACTION_STANDING_LABEL"..standingID],barValue-barMin,barMax);
		local state = 0;
		if standingID then
			state = 1;
			if standingID>=standingNum then
				state = 2;
			end
		end
		return	name,
				_G["FACTION_STANDING_LABEL"..standingNum],
				CreateExternalURL("f",id),
				{state=state,current=current};
	end;

	-- shared.Friendship=function(_,id,standingNum) end;

	shared.Location=function(zoneId,coordX,coordY,customStr,tomtomLabel)
		local location,position,tomtom = "";

		if(type(coordX)=="number" and type(coordY)=="number")then
			position = ("%1.1f, %1.1f"):format(coordX,coordY);
			if TomTom and TomTom.AddMFWaypoint then
				tomtom = ("|cff33aaff|Htomtom:%d:%1.2f:%1.2f:%s|h[%s]|h|r"):format(zoneId,coordX,coordY,tomtomLabel or "-",L["Add waypoint to TomTom"]);
			end
		end

		if(type(customStr)=="table") and (shared[customStr[1]])then
			customStr = shared[customStr[1]](unpack(customStr));
		elseif(type(customStr)=="string")then
			customStr = L[customStr];
		end

		if(position or customStr)then
			location = " @ " .. (position or customStr) .. ((position and customStr) and " ("..customStr..")" or "");
		end

		return GetMapNameByID(zoneId) .. location, tomtom;
	end;

	shared.Outpost=function(_,zone,option)
		local op,outpost = {},D.Outpost[zone][option];

		tinsert(op,L[outpost[1]]);

		local location,tomtom = shared.Location(zone,outpost[2],outpost[3],nil,L[outpost[1]]);
		tinsert(op,location);
		if tomtom then
			tinsert(op,tomtom);
		end
		return tconcat(op,"|n"..listPrefix);
	end

	shared.Images=function(followerId,imageTable,delimiter)
		local images,faction = {};
		for _,image in ipairs(imageTable)do
			if(type(image)=="table")then
				faction = (image[3]~=true and "") or (D.faction==1 and "a") or "h";
				tinsert(images,("|cFF55FFFF|Himage:%s:%s|h[%s]|h|r"):format(followerId..faction,image[1],L[image[2]]));
			end
		end
		return tconcat(images,delimiter);
	end;


	if(id and D.descriptions[id] and #D.descriptions[id]>0)then
		Desc = D.descriptions[id];
	elseif(id and D.basics[id][isCollectableIdx]==false)then
		Desc = D.descriptions[0];
	end

	if Desc then
		if Desc.collectGroup then
			local members,collected = {},0;
			for i=1, #Desc.collectGroup do
				if D.collected[Desc.collectGroup[i]] then
					collected = Desc.collectGroup[i];
				end
			end
			for i,v in ipairs(Desc.collectGroup) do
				local color, chk = "eeff00", "";
				if(collected==v)then
					color, chk = "00ff00", checked;
				elseif(collected~=0)then
					color = "888888";
				end
				tinsert(members,("|cff%s%s|r"):format(color,L["follower_"..v])..chk);
			end
			tinsert(html,
				h2:format(L["Collect group"],"blue")
				..
				p:format(
					L["You can only obtain one follower from this group"]..":"
					..
					"|n".. listPrefix .. table.concat(members,"|n".. listPrefix)
				)
				..
				br
			);
		end

		for I=1, #Desc do
			title = nil;
			local cnt,delimiter={},"";
			if(Desc[I][1]=="Location")then
				local locations = {};
				for i=2, #Desc[I] do
					location = {};
					if(type(Desc[I][i])=="string")then
						tinsert(location,L[Desc[I][i]]);
					else
						local v = Desc[I][i];
						if(v[4])then
							tinsert(location,L[v[4]]);
						end
						local coords, tomtom = shared.Location(v[1],v[2],v[3],nil,v[4]~=nil and L[v[4]]);
						tinsert(location,coords);
						if tomtom then
							tinsert(location,tomtom);
						end
						if(type(v.Images)=="table")then
							tinsert(location,shared.Images(id,v.Images," "));
						end
					end
					tinsert(locations,tconcat(location,"|n"..listPrefix));
				end
				tinsert(cnt,p:format(tconcat(locations,"|n|n")));
			elseif(Desc[I][1]=="Quests" or Desc[I][1]=="Events")then
				Loading(true,L["Collecting quest data... (%d entries)"]:format(#Desc[I]-1),"new");
				title = Desc[I][1]=="Events" and EVENTS_LABEL or QUESTS_LABEL;
				local quests = {};
				for i=2, #Desc[I] do
					local quest,v,coord,index,zone,npc = {},Desc[I][i],"","","","";
					Loading(true,L["Query data (questId: %d)..."]:format(v[1]));
					if(type(v[1])=="number")then
						-- true=completed, number=inQuestLog, nil=open/notInLog
						index = GetQuestLogIndexByID(v[1]);
						if(index and index>0)then
							D.QuestName[v[1]] = GetQuestLogTitle(index);
						end

						if(type(D.QuestName[v[1]])=="string")then
							tinsert(quest,lnk:format("ffffcc00", ("quest:%d:%d"):format(v[1],v[2]), D.QuestName[v[1]]));
						else
							doRetry = true;
						end
					end
					if(not doRetry and type(v[3])=="number")then
						if(v[3]<1)then
							local objId = gsub(tostring(v[3]),"^0%.","");
							if(rawget(L,"object_"..objId))then
								tinsert(quest,L["object_"..objId]);
							end
							--tinsert(quest,D.ObjectName[v[3]]);
						elseif(v[3]>=1)then
							if(type(D.NpcName[v[3]])=="string")then
								tinsert(quest,D.NpcName[v[3]]);
							else
								doRetry = true;
							end
						end
					end
					if(not doRetry)then
						local location, tomtom = shared.Location(v[4],v[5],v[6],(type(v[5])=="table" or type(v[5])=="string") and v[5] or nil, (v[3] and D.NpcName[v[3]] or nil))
						tinsert(quest,location);
						if tomtom then
							tinsert(quest,tomtom);
						end

						local link = CreateExternalURL("q",v[1]);
						if link then tinsert(quest,link); end

						if(type(v.Images)=="table")then
							tinsert(quest,shared.Images(id,v.Images," "));
						end

						local status = STATUS..": |cff%s%s|r";
						if(index and index>0)then
							tinsert(quest,status:format("ffee00",L["In your Questlog"]));
						elseif IsQuestFlaggedCompleted(v[1]) then
							tinsert(quest,status:format("00aa00",AUCTION_TIME_LEFT0)..checked);
						else
							tinsert(quest,status:format("04ff07",L["Open"]));
						end

						tinsert(quests,tconcat(quest,"|n"..listPrefix));
						Loading(true,checked,"nobr");
					end
				end
				if #quests>0 then
					tinsert(cnt,p:format(tconcat(quests,"|n|n")));
				end
			elseif(Desc[I][1]=="Missions")then
				title = GARRISON_MISSIONS;
				for i=2, #Desc[I] do
					if (type(Desc[I][i])=="number") then
						-- garrmission:<missionid> does not work with blizzards GameTooltip:SetHyperlink().
						-- tinsert(cnt,p:format( C_Garrison.GetMissionLink(Desc[I][i]) ));
						local missionData,numMaxFollower = {C_Garrison.GetMissionName(Desc[I][i])},GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS;
						if (C_Garrison.GetFollowerTypeByMissionID(Desc[I][i])==LE_FOLLOWER_TYPE_SHIPYARD_6_2)then
							numMaxFollower=GARRISON_SHIPYARD_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS;
						end
						tinsert(missionData,""..listPrefix..numMaxFollower:format(C_Garrison.GetMissionMaxFollowers(Desc[I][i])));
						local link = CreateExternalURL("m",Desc[I][i]);
						if link then tinsert(missionData,listPrefix..link); end
						local rewardList,rewards = C_Garrison.GetMissionRewardInfo(Desc[I][i]),{};
						for _,reward in pairs(rewardList)do
							local name,link,_,_,_,_,_,_,_,icon = GetItemInfo(reward.itemID);
							local hlink = CreateExternalURL("i",reward.itemID);
							if link and icon then
								tinsert(rewards,
									("|T%s:14:14:0:0:64:64:4:56:4:56|t %s"):format(icon,link) ..
									(hlink~=nil and "|n"..listPrefix..hlink or "")
								);
							else
								--print("Error:", "Mission reward item not found.", "itemID:"..reward.itemID,"missionID:"..Desc[I][i]);
							end
						end
						if(#rewards>0)then
							tinsert(missionData,"|n"..REWARDS..":|n"..tconcat(rewards,"|n"));
						end
						tinsert(cnt,p:format(tconcat(missionData,"|n")));
					end
				end
			elseif(Desc[I][1]=="Description")then
				title = DESCRIPTION;
				tinsert(cnt,p:format(L[Desc[I][2]]));
			elseif(Desc[I][1]=="Images")then
				tinsert(cnt,
					pr:format("|cffa0a0a0"..L["(mouse over to show image)"].."|r")
					..
					pl:format(shared.Images(id,Desc[I],"|n"))
				);
			elseif(Desc[I][1]=="Merchant")then
				Loading(true,L["Collection vendor data..."],"new");
				title = MERCHANT;
				local merchants = {};
				for i=2, #Desc[I] do
					Loading(true,L["Query data (npcID: %d)..."]:format(Desc[I][i][1]));
					local merchant = {};
					local name = D.NpcName[Desc[I][i][1]];
					if(name)then
						tinsert(merchant,name);
						local location, tomtom = shared.Location(Desc[I][i][2],Desc[I][i][3],Desc[I][i][4],(type(Desc[I][i][3])=="table" or type(Desc[I][i][3])=="string") and Desc[I][i][3] or nil,name);
						tinsert(merchant,location);
						if tomtom then
							tinsert(merchant,tomtom);
						end
						local link = CreateExternalURL("n",Desc[I][i][1]);
						if link then tinsert(merchant,link); end
						tinsert(merchants,tconcat(merchant,"|n"..listPrefix));
						Loading(true,checked,"nobr");
					else
						doRetry = true;
					end
				end
				if(#merchants>0)then
					tinsert(cnt,p:format(tconcat(merchants,"|n|n")));
				end
			elseif(Desc[I][1]=="Npc")then
				Loading(true,L["Query data (npcID: %d)..."]:format(Desc[I][2]));
				title = L["NPC"];
				local name,npc = D.NpcName[Desc[I][2]];
				if(name)then
					npc = {};
					tinsert(npc,name);
					if(D.NpcTitle[Desc[I][2]])then
						--title = D.NpcTitle[Desc[I][2]];
						tinsert(npc,UNIT_NAME_PLAYER_TITLE..": "..D.NpcTitle[Desc[I][2]]);
					end

					local location, tomtom = shared.Location(Desc[I][3],Desc[I][4],Desc[I][5],(type(Desc[I][4])=="table" or type(Desc[I][4])=="string") and Desc[I][4] or nil,name);
					tinsert(npc,location);
					if tomtom then
						tinsert(npc,tomtom);
					end

					local link = CreateExternalURL("n",Desc[I][1]);
					if link then tinsert(npc,link); end

					Loading(true,checked,"nobr");
				else
					doRetry = true;
				end
				if npc then
					tinsert(cnt,p:format(tconcat(npc,"|n"..listPrefix)));
				end
			elseif(Desc[I][1]=="Spell")then
				title = SPELLS;
				local hlink = CreateExternalURL("s",Desc[I][2]);
				tinsert(cnt,p:format(
					"|T"..GetSpellTexture(Desc[I][2])..":14:14:0:0|t "..GetSpellLink(Desc[I][2])..
					(hlink~=nil and "|n"..listPrefix..hlink or "")
				));
			elseif(Desc[I][1]=="Items")then
				title = #Desc[I]>2 and ITEMS or HELPFRAME_ITEM_TITLE;
				local items = {};
				for i=2, #Desc[I] do
					local item = {};
					local v,name,link,icon,coords,_ = Desc[I][i];
					name,link,_,_,_,_,_,_,_,icon = GetItemInfo(v[1]);

					if link then
						tinsert(item, ("|T%s:0|t %s"):format(icon,link));

						if(v[2] and v[3] and v[4])then
							local location, tomtom = shared.Location(v[2],v[3],v[4],nil,name);
							tinsert(item,location);
							if tomtom then
								tinsert(item,tomtom);
							end
						end

						local link = CreateExternalURL("i",Desc[I][i][1]);
						if link then tinsert(item,link); end

						if(type(v.Images)=="table")then
							tinsert(item,shared.Images(id,v.Images," "));
						end
						tinsert(items,tconcat(item,"|n"..listPrefix));
					end
				end
				tinsert(cnt,p:format(tconcat(items,"|n|n")));
			elseif(Desc[I][1]=="Requirements")then
				local reqs = {};
				local titles = {["Garrison building"]=L["Garrison building"],Professions=TRADE_SKILLS,Reputation=REPUTATION,["Brawler's Guild"]=L["Brawler's Guild"]}
				for i=2, #Desc[I] do
					local req,v = {},Desc[I][i];
					if(type(v)=="table" and shared[v[1]])then
						if v[1]=="Garrison building" or v[1]=="Professions" or v[1]=="Reputation" or v[1]=="Brawler's Guild" then
							local name, need, url, data = shared[v[1]](unpack(v));
							local state1 = data.state>=1 and 2 or 0;
							tinsert(req,titles[v[1]]..":");
							if v[1]=="Reputation" or v[1]=="Brawler's Guild" then
								tinsert(req,name);
							else
								tinsert(req,("|cff%s%s|r"):format(stateColor[state1],name) .. (state1==2 and checked or ""));
							end
							tinsert(req,("|cff%s%s|r"):format(stateColor[data.state],need) .. (data.state==2 and checked or ""));
							if(data.state==1 and data.current)then
								tinsert(req,("|cff888888%s %s|r"):format(CURRENT_PET,data.current));
							end
							tinsert(req,url);
						else
							local titles = {Outpost=L["Outpost building"]}
							local result = {shared[v[1]](unpack(v))};
							if #result>0 then
								if(titles[v[1]])then
									tinsert(req,titles[v[1]]..":");
								end
								for x=1, #result do
									if(type(result[x])=="string")then
										tinsert(req,result[x]);
									end
								end
							end
						end
					elseif v[1]=="Unlock" then
						local color, chk = "yellow","";
						if(IsQuestFlaggedCompleted(v[2]))then
							color, chk = "green", checked;
						end
						tinsert(req, LC.color(color, L[v[3]])..chk);
					elseif(type(v)=="string")then
						tinsert(req,L[v]);
					end
					tinsert(reqs,tconcat(req,"|n"..listPrefix));
				end
				tinsert(cnt,p:format(tconcat(reqs,"|n|n")));
			elseif(Desc[I][1]=="Achievements")then
				title = ACHIEVEMENTS;
				local achievements = {};
				for i=2, #Desc[I] do
					local achievement,link = {},GetAchievementLink(Desc[I][i]);
					if link then
						local _, name, points, completed, _, _, _, description, _, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(Desc[I][i]);
						local cat,catId = {},GetAchievementCategory(Desc[I][i]);
						tinsert(achievement,link);

						for i=1, 3 do
							local Name,parentId,flag = GetCategoryInfo(catId);
							Name = gsub(Name,"&","&amp;");
							tinsert(cat,1,Name);
							if parentId<0 then break end
							catId=parentId;
						end
						tinsert(achievement,tconcat(cat," &#xBB; "));

						local link = CreateExternalURL("a",Desc[I][i]);
						if link then tinsert(achievement,link); end

						local status = ("|cff%s%s|r"):format("04ff07",L["Open"]);
						if completed and wasEarnedByMe then
							status = ("|cff%s%s|r"):format("00aa00",AUCTION_TIME_LEFT0)..checked;
						end
						tinsert(achievement,STATUS..": "..status);

						tinsert(achievements,
							"|T"..icon..":32:32:0:0:32:32:0:32:0:32|t|n" ..
							tconcat(achievement,"|n"..listPrefix));
					end
				end
				if #achievements>0 then
					tinsert(cnt, p:format(tconcat(achievements,"|n|n")));
				end
			elseif(Desc[I][1]=="Price")then
				title = AUCTION_PRICE;
				local sum = {};
				for i=2, #Desc[I] do
					local price = {};
					if Desc[I][i][1] == "Gold" then
						tinsert(price,BONUS_ROLL_REWARD_MONEY);
						tinsert(price,GetCoinTextureString(Desc[I][i][2]));
					elseif Desc[I][i][1] == "Currency" then
						local name,itemId,icon = GetCurrencyInfo(Desc[I][i][2]);
						local link = GetCurrencyLink(Desc[I][i][2]);
						if name and icon then
							tinsert(price,link or name);
							tinsert(price,("%s |T%s:0|t"):format(Desc[I][i][3],icon));
							local link = CreateExternalURL("c",Desc[I][i][2]);
							if link then tinsert(price,link); end
						end
					elseif Desc[I][i][1] == "Item" then
						local name,link,_,_,_,_,_,_,_,icon = GetItemInfo(Desc[I][i][2]);
						if name and icon then
							tinsert(price,link);
							tinsert(price,("%s |T%s:0|t"):format(Desc[I][i][3],icon));
							local link = CreateExternalURL("i",Desc[I][i][2]);
							if link then tinsert(price,link); end
						else
							doRetry = true;
						end
					end
					tinsert(sum,tconcat(price,"|n"..listPrefix));
				end
				tinsert(cnt,p:format(tconcat(sum,"|n|n")));
			end
			if(#cnt>0)then
				tinsert(html, h2:format(title or L[Desc[I][1]],"blue") .. tconcat(cnt,delimiter) .. br);
			end
		end
	elseif(id)then
		tinsert(html,"error");
	else
		local collectBy = {};
		local follower= function(label,num)
			return ("%s: |cff%s%d|r / |cff%s%d|r"):format(
				label,
				num[2]>0 and "00ff00" or "aaaaaa",
				num[2],
				"eeee00",
				num[1]
			);
		end
		for i,v in pairsByFields(D.otherFiltersOrder,2)do
			local num = D.otherFiltersCount[v[1]];
			if not (v[1]=="Reputation" or v[1]=="Garrison building" or v[1]=="Outpost") then
				tinsert(collectBy,follower(v[2],num));
			end
		end
		local section = h2..p..br;
		html = {
			section:format(
				L["Usage"],
				"blue",
				L["Select a follower to see the description..."]
			),
			section:format(
				GARRISON_FOLLOWERS,
				"blue",
				follower(COLLECTED,D.counter.collectables)
				.."|n"..
				follower(L["Recruited"],D.counter.recruitables)
			),
			section:format(
				L["Obtainable by"],
				"blue",
				tconcat(collectBy,"|n")
			),
			section:format(
				GAME_VERSION_LABEL,
				"blue",
				"Core = "..D.Version.Core.."|n"..
				"Data = "..D.Version.Data
			),
			--section:format(L["Chat commands"],"/fli "..L["or"] .. "/followerlocationinfo"),
			--[[
			section:format(L["Thanks"],
				"ditex2009 ruRU locales (horde)|n"..
				"Shooshpan ruRU locales (horde)|n"..
				"michaelselehov ruRU locales (alliance)|n"..
				"jerry99spkk zhTW locales (alliance)|n"..
				"BNSSNB zhTW locales (alliance)|n"..
				"ananhaid zhCN locales (alliance &amp; horde)|n"..
				"and the nice community :)"
			)
			--]]
		};
	end

	if doRetry then
		C_Timer.After(1.4,FollowerLocationInfoJournalFollowerDesc_Update);
		return;
	else
		P.html:SetText("<html><body>"..tconcat(html,"").."<br /></body></html>");
		Loading(false);
		P.html:Show();
	end

	if not CurrentFollower_reloaded then
		CurrentFollower_reloaded = true;
		C_Timer.After(0.2,FollowerLocationInfoJournalFollowerDesc_Update);
	end
end

function FollowerLocationInfoJournal_ShowFollower(self)
	if not (self and self.id) then return end

	CurrentFollower_reloaded = nil;
	if CurrentFollower~=self.id then
		CurrentFollower = self.id;
	else
		CurrentFollower = nil;
	end

	for i,v in ipairs(self:GetParent().buttons) do
		v.selected:Hide();
	end
	if CurrentFollower then
		self.selected:Show();
	end
	FollowerLocationInfoJournalFollowerList.selected = CurrentFollower;

	FollowerLocationInfoJournalDesc:SetHorizontalScroll(0);
	FollowerLocationInfoJournalDesc:SetVerticalScroll(0);

	FollowerLocationInfoJournalFollowerCard_Update();
	FollowerLocationInfoJournalFollowerDesc_Update();
end

function FollowerLocationInfoJournalFollowerDesc_OnLoad(self) end


-------------------------------
--- Journal Frame Functions ---
-------------------------------
function FollowerLocationInfoJournal_OnUpdate()
end

function FollowerLocationInfoJournal_OnShow(self)
	if(not D.counter.recruitable)then
		-- D.counter can create later on slower connections.
		-- need a little timeout.
		if not timeout then
			C_Timer.After(2, function() FollowerLocationInfoJournal_OnShow(self) end);
			timeout=true;
		end
		return;
	end
	timeout=false;

	CollectionsJournalTitleText:SetText("FollowerLocationInfo");
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\Achievement_GarrisonFollower_Rare");
	FollowerLocationInfoJournalFollowerList_Update();

	FollowerLocationInfoJournalFollowerCard_Update();
	FollowerLocationInfoJournalFollowerDesc_Update();

	self.counters.Collectables.Count:SetText(D.counter.collectables[2].."/"..D.counter.collectables[1]);
	self.counters.Recruitables.Count:SetText(D.counter.recruitables[2].."/"..D.counter.recruitables[1]);
	self.counters:Show();
end

function FollowerLocationInfoJournal_OnHide()
	FollowerLocationInfoJournalCounters:Hide();
end

function FollowerLocationInfoJournal_OnEvent(self,event) end

function FollowerLocationInfoJournal_OnLoad(self)
	D,L = FollowerLocationInfoData,FollowerLocationInfoData.Locale;
	LC = FollowerLocationInfo.LibColors;

	self.counters = FollowerLocationInfoJournalCounters;
	self.counters:SetParent(self);

	if FollowerLocationInfoData.journalDocked then
		local journals = {CollectionsJournal};

		for i,v in ipairs({CollectionsJournal:GetChildren()})do
			if(v.GetObjectType and v:GetObjectType("Frame") and v:GetName() and issecurevariable(v:GetName()) and CollectionsJournal:GetHeight()==v:GetHeight())then
				tinsert(journals,v);
			end
		end

		SecureTabs:Startup(unpack(journals));
		self.Tab = SecureTabs:Add(CollectionsJournal, self, "FollowerLocationInfo", HeirloomsJournal);
		FollowerLocationInfoData.JournalTabID = self.Tab:GetID();

		CollectionsJournal:HookScript("OnHide",function()
			FollowerLocationInfoJournalCounters:Hide();
			FollowerLocationInfoJournal:Hide();
		end);

		CollectionsJournal:HookScript("OnShow",function(self)
			C_Timer.After(0.5,function()
				if self.selectedTab==FollowerLocationInfoData.JournalTabID then
					FollowerLocationInfoJournalCounters:Show();
					FollowerLocationInfoJournal:Show();
				else
					FollowerLocationInfoJournalCounters:Hide();
					FollowerLocationInfoJournal:Hide();
				end
			end);
		end);

		if(CollectionsJournal:IsShown())then
			CollectionsJournal:Hide();
			CollectionsJournal:Show();
		end

		self:SetParent(CollectionsJournal);
		self:SetPoint("TOPLEFT", 0, -60);
		self:SetPoint("BOTTOMRIGHT");
		self.counters:SetPoint("TOPLEFT",CollectionsJournal,"TOPLEFT", 65, -33);
		self.Options:SetPoint("TOPRIGHT",CollectionsJournal,"TOPRIGHT",-6,-26);
	else
		self:SetParent(FollowerLocationInfoJournalFrame);
		self:SetPoint("TOPLEFT",FollowerLocationInfoJournalFrame.HeaderBar,"BOTTOMLEFT",0,-3);
		self:SetPoint("RIGHT",FollowerLocationInfoJournalFrame.HeaderBar,"RIGHT",0,0);
		self:SetPoint("BOTTOM",-30,32);
		self.counters:SetPoint("TOPLEFT",FollowerLocationInfoJournalFrame,"TOPLEFT", 72, -10);
		self.Options:SetPoint("RIGHT",FollowerLocationInfoJournalFrame.HeaderBar,"RIGHT",-18,0);
		for key,val in pairs(self)do
			if tostring(key):match("Inset$") then
				val.Bg:SetAlpha(.24);
				for key2,val2 in pairs(val)do
					if tostring(key2):match("^InsetBorder")then
						val2:SetAlpha(.7);
					elseif tostring(key2):match("^OverlayShadow") then
						val2:SetAlpha(.7);
					end
				end
			end
		end
		UIPanelWindows["FollowerLocationInfoJournalFrame"] = { area = "left", pushable = 0, whileDead = 1, width = 830};
	end

	self.counters.Collectables.Label:SetText(COLLECTED);
	self.counters.Recruitables.Label:SetText(L["Recruited"]);

	FollowerLocationInfoJournal_UpdateFilter();

	self.FollowerDesc.ScrollBar.trackBG:Hide();
	self.FollowerDesc.ScrollBar:SetPoint("TOPLEFT",self.FollowerDesc,"TOPRIGHT",4,-12);
	self.FollowerDesc.ScrollBar:SetPoint("BOTTOMLEFT",self.FollowerDesc,"BOTTOMRIGHT",4,11);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
end
