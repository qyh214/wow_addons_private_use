--[[
ToDo:
*Get Localization for all languages
*Re-structure Options UI
]]

local UPDATEPERIOD, elapsed = 0.5, 0
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleILevel")

SIL_Alt = LibStub("AceAddon-3.0"):NewAddon('SIL_Alt', "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0");

SIL_Alt.action = {};        -- DB of unitGUID->function to run when a update comes through
SIL_Alt.hooks = {};         -- List of hooks in [type][] = function;
SIL_Alt.autoscan = 0;       -- time() value of last autoscan, must be more then 1sec
SIL_Alt.lastScan = {};      -- target = time();
SIL_Alt.grayScore = 7;      -- Number of items to consider gray/aprox
SIL_Alt.ldbAuto = false;    -- AceTimer for LDB
SIL_Alt.playerNames = {};

local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local LibQTip = LibStub:GetLibrary("LibQTip-1.0");
SIL_Alt.callback = LibStub("CallbackHandler-1.0"):New(SIL_Alt);

local dataobj = ldb:GetDataObjectByName(L.core.name);
dataobj.OnTooltipShow = nil;


function SIL_Alt:OnInitialize()
	self.sort_table = {}
	self.scanqueue = {}
    
	self.faction = UnitFactionGroup("player")
	self.realm = GetRealmName()
	self.pc = UnitName("player")
     
	SIL:Print(L.alts.load, GetAddOnMetadata("SimpleILevel_Alts", "Version"));
    
	self.db = LibStub("AceDB-3.0"):New("SIL_Alts", SILAlt_Defaults, true);
	SIL.aceConfig:RegisterOptionsTable(L.alts.nameShort, SILAlt_Options, {"sia", "silalt", "simpleilevelalts"});
	SIL.aceConfigDialog:AddToBlizOptions(L.alts.nameShort, "Alts", L.core.name);
    
	
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function() SIL_Alt:StartScore('player'); end);
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function() SIL_Alt:StartScore('player'); end);
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function() SIL_Alt:StartScore('player'); end);
    
	SIL_Alt:StartScore('player');
	SIL_Alt:UpdateLDB();
	self:SetupSILMenu();
end   


function dataobj:OnEnter()
	-- Start Define the tooltip
	local tooltip = LibQTip:Acquire("SimpleiLevel", 5, "LEFT", "LEFT", "CENTER", "CENTER", "CENTER")
	self.tooltip = tooltip
	tooltip:Clear()
	-- End Define the tooltip

	-- Start Setup new default fonts 
	-- New font looking like GameTooltipText but White with height 12
	local white10Font = CreateFont("white10Font")
	white10Font:SetFont(GameTooltipText:GetFont(), 10)
	white10Font:SetTextColor(1,1,1)

	-- New font looking like White15font but with height 14
	local white14Font = CreateFont("white14Font")
	white14Font:CopyFontObject(white10Font)
	white14Font:SetFont(white14Font:GetFont(), 14)

	-- New font for Horde faction header
	local hordeFont = CreateFont("hordeFont")
	hordeFont:CopyFontObject(white10Font)
	hordeFont:SetTextColor(1,0,0)
	hordeFont:SetFont(hordeFont:GetFont(), 14)

	-- New font for Alliance faction header
	local allianceFont = CreateFont("allianceFont")
	allianceFont:CopyFontObject(white10Font)
	allianceFont:SetTextColor(0,0,1)
	allianceFont:SetFont(allianceFont:GetFont(), 14)

	-- New font for Neutral faction header
	local neutralFont = CreateFont("neutralFont")
	neutralFont:CopyFontObject(white10Font)
	neutralFont:SetTextColor(0.5,0.5,0.5)
	neutralFont:SetFont(neutralFont:GetFont(), 14)

	-- New font looking like GameTooltipText but White with height 15
	local green12Font = CreateFont("green12Font")
	green12Font:SetFont(GameTooltipText:GetFont(), 12)
	green12Font:SetTextColor(0,1,0)
	-- End Setup new default fonts


	-- Start Building the tooltip
	tooltip:SetFont(white10Font)
	tooltip:SetHeaderFont(white14Font)
	-- Start Build the tooltip header
	local line, column = tooltip:AddHeader()
	tooltip:SetCell(line, 1, L.alts.tooltip.labelHeader, "CENTER", 5)
	tooltip:AddLine()
	tooltip:SetCell(line + 1, 1, L.alts.tooltip.labelName, "LEFT", 2)
	tooltip:SetCell(line + 1, 3, L.alts.tooltip.labelPrimary, "CENTER")
	tooltip:SetCell(line + 1, 4, L.alts.tooltip.labelSecondary, "CENTER")
	if SIL_Alts.global.options.showTotals then
		tooltip:SetCell(line + 1, 5, L.alts.tooltip.labelTotal, "RIGHT")
	end
	names = {}
	tooltip:AddSeparator()
	-- End Build the tooltip header

	-- Start Populate Faction/Realm/Character 
	for faction, faction_table in pairs (SIL_Alts.global.alts) do
		-- Determine if we should show all factions or only the current character's faction
		if SIL_Alts.global.options.showAllFactions or faction == SIL_Alt.faction  then
			if faction ~= "partyData" then
				if faction == "Horde" then
					tooltip:SetHeaderFont(hordeFont)
				elseif faction == "Alliance" then
					tooltip:SetHeaderFont(allianceFont)
				else
					tooltip:SetHeaderFont(neutralFont)
				end
				if SIL_Alts.global.options.showAllFactions then
					tooltip:AddHeader(faction)
				end
				-- Get the realm for each character
				for realm, realm_table in pairs (faction_table) do
					-- Determine if we should show all realms or only the current character's realm
					if SIL_Alts.global.options.showAllRealms or realm == SIL_Alt.realm then
						tooltip:SetHeaderFont(green12Font)
						if SIL_Alts.global.options.showAllRealms then
							tooltip:AddHeader(realm)
						end
						SIL_Alt:FetchOrderedNames(names, realm_table)
						for _,name in ipairs (names) do
							userver = " - " .. realm;
							if not SIL_Alts.global.ignore[name .. userver].show == false then
								
								-- Build tooltip for Max Level Characters Only
								if SIL_Alts.global.options.onlyMaxLevel and SIL_Alts.global.alts[faction][realm][name].level == 90 then
									local line, column = tooltip:AddLine()
									tooltip:SetCell(line, 1, SIL_Alts.global.alts[faction][realm][name].name, CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
									if not SIL_Alts.global.options.onlyMaxLevel then
										tooltip:SetCell(line, 2, SIL_Alts.global.alts[faction][realm][name].level, CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class], "CENTER") 
									end
									-- Show Character's Primary Spec
									if SIL_Alts.global.alts[faction][realm][name]["Primary"] then
										if SIL_Alts.global.alts[faction][realm][name]["Primary"].score and SIL_Alts.global.alts[faction][realm][name]["Primary"].score >= 1 then
											local p_tex = " \124T"..SIL_Alts.global.alts[faction][realm][name]["Primary"].icon..":0\124t"
											if SIL_Alts.global.options.colorizeILvl then
												local p_score = SIL_Alts.global.alts[faction][realm][name]["Primary"].score
												local p_items = SIL_Alts.global.alts[faction][realm][name]["Primary"].items
												p_text = p_tex .. SIL:FormatScore(p_score, p_items, true);
												tooltip:SetCell(line, 3, p_text)
											else
												tooltip:SetCell(line, 3, p_tex .. string.format("%.1f",SIL_Alts.global.alts[faction][realm][name]["Primary"].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 3, "--")
										end
									end
									-- Show Character's Secondary Spec
									if SIL_Alts.global.alts[faction][realm][name]["Secondary"] then
										if SIL_Alts.global.alts[faction][realm][name]["Secondary"].score and SIL_Alts.global.alts[faction][realm][name]["Secondary"].score >= 1 then
											local s_tex = " \124T"..SIL_Alts.global.alts[faction][realm][name]["Secondary"].icon..":0\124t"
											if SIL_Alts.global.options.colorizeILvl then
												local s_score = SIL_Alts.global.alts[faction][realm][name]["Secondary"].score
												local s_items = SIL_Alts.global.alts[faction][realm][name]["Secondary"].items
												s_text = s_tex .. SIL:FormatScore(s_score, s_items, true);
												tooltip:SetCell(line, 4, s_text)
											else
												tooltip:SetCell(line, 4, s_tex .. string.format("%.1f",SIL_Alts.global.alts[faction][realm][name]["Secondary"].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 4, "--")
										end
									end
									-- Show Characters's Total ilevel
									if SIL_Alts.global.options.showTotals then
										if SIL_Alts.global.alts[faction][realm][name].score and SIL_Alts.global.alts[faction][realm][name].score >= 1 then
											if SIL_Alts.global.options.colorizeILvl then
												local score = SIL_Alts.global.alts[faction][realm][name].score
												local tems = SIL_Alts.global.alts[faction][realm][name]["Primary"].items
												text = SIL:FormatScore(score, items, true);
												tooltip:SetCell(line, 5, text)
											else
												tooltip:SetCell(line, 5, string.format("%.1f",SIL_Alts.global.alts[faction][realm][name].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 5, "--")
										end
									end
								
								-- Build tooltip for All Level Characters
								elseif not SIL_Alts.global.options.onlyMaxLevel then
									local line, column = tooltip:AddLine()
									tooltip:SetCell(line, 1, SIL_Alts.global.alts[faction][realm][name].name, CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
									if not SIL_Alts.global.options.onlyMaxLevel then
										tooltip:SetCell(line, 2, SIL_Alts.global.alts[faction][realm][name].level, CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
									end
									-- Show Character's Primary Spec
									if SIL_Alts.global.alts[faction][realm][name]["Primary"] then
										if SIL_Alts.global.alts[faction][realm][name]["Primary"].score and SIL_Alts.global.alts[faction][realm][name]["Primary"].score >= 1 then
											local p_tex = " \124T"..SIL_Alts.global.alts[faction][realm][name]["Primary"].icon..":0\124t"
											if SIL_Alts.global.options.colorizeILvl then
												local p_score = SIL_Alts.global.alts[faction][realm][name]["Primary"].score
												local p_items = SIL_Alts.global.alts[faction][realm][name]["Primary"].items
												p_text = p_tex .. SIL:FormatScore(p_score, p_items, true);
												tooltip:SetCell(line, 3, p_text)
											else
												tooltip:SetCell(line, 3, p_tex .. string.format("%.1f",SIL_Alts.global.alts[faction][realm][name]["Primary"].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 3, "--")
										end
									end
									-- Show Character's Secondary Spec
									if SIL_Alts.global.alts[faction][realm][name]["Secondary"] then
										if SIL_Alts.global.alts[faction][realm][name]["Secondary"].score and SIL_Alts.global.alts[faction][realm][name]["Secondary"].score >= 1 then
											local s_tex = " \124T"..SIL_Alts.global.alts[faction][realm][name]["Secondary"].icon..":0\124t"
											if SIL_Alts.global.options.colorizeILvl then
												local s_score = SIL_Alts.global.alts[faction][realm][name]["Secondary"].score
												local s_items = SIL_Alts.global.alts[faction][realm][name]["Secondary"].items
												s_text = s_tex .. SIL:FormatScore(s_score, s_items, true);
												tooltip:SetCell(line, 4, s_text)
											else
												tooltip:SetCell(line, 4, s_tex .. string.format("%.1f",SIL_Alts.global.alts[faction][realm][name]["Secondary"].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 4, "--")
										end
									end
									-- Show Player's total ilevel
									if SIL_Alts.global.options.showTotals then
										if SIL_Alts.global.alts[faction][realm][name].score and SIL_Alts.global.alts[faction][realm][name].score >= 1 then
											if SIL_Alts.global.options.colorizeILvl then
												local score = SIL_Alts.global.alts[faction][realm][name].score
												local tems = SIL_Alts.global.alts[faction][realm][name]["Primary"].items
												text = SIL:FormatScore(score, items, true);
												tooltip:SetCell(line, 5, text)
											else
												tooltip:SetCell(line, 5, string.format("%.1f",SIL_Alts.global.alts[faction][realm][name].score), CLASS_FONTS[SIL_Alts.global.alts[faction][realm][name].class])
											end
										else
											tooltip:SetCell(line, 5, "--")
										end
									end
								end
							end
						end
					end
				end
				tooltip:AddLine(" ")
			end
		end
	end
     	
	tooltip:AddLine(L.core.minimapClick);
	tooltip:AddLine(L.core.minimapClickDrag);

	-- Use smart anchoring code to anchor the tooltip to our frame
	tooltip:SmartAnchorTo(self)

	-- Show it, et voil‡ !
	tooltip:Show()
end
 

function dataobj:OnLeave()
	-- Release the tooltip
	LibQTip:Release(self.tooltip)
	self.tooltip = nil
end


function SIL_Alt:StartScore(target, callback)
	if InCombatLockdown() or not CanInspect(target) then 
		if callback then callback(false, target); end
		return false;
	end
	self.autoscan = time();
	local guid = SIL_Alt:AddPlayer(target);
	if not self.lastScan[target] or self.lastScan[target] ~= time() then
		if guid then
			self.action[guid] = callback;
			self.lastScan[target] = time();
			local canInspect = self.inspect:RequestItems(target, true);
			if not canInspect and callback then
				callback(false, target);
			else
				return true;
			end
		end
	end
	if callback then callback(false, target); end
	return false;
end


function SIL_Alt:AddPlayer(target, callback)
	if InCombatLockdown() or not CanInspect(target) then 
		if callback then callback(false, target); end
	return false;
	end
	local guid = UnitGUID("player");
	if guid then
		local name, realm = UnitName("player");
		local className, class = UnitClass("player");
		local level = UnitLevel("player");
		local faction = UnitFactionGroup("player");
		local avgilvl = GetAverageItemLevel();
		local specID = GetActiveSpecGroup();
		local isSpecd = GetSpecialization()
		local specType = "";
		if specID == 1 then
			specType = "Primary";
		elseif specID == 2 then
			specType = "Secondary";
		else
			specType = "None";
		end
		if not realm then
			realm = GetRealmName();
		end
		if name and realm and class and level then
			
			-- Start a table for them
			if not self.db.global.alts[faction][realm][name] then
				self.db.global.alts[faction][realm][name] = {};
			end
			local userver = " - " .. realm;
			local combinedname = name .. realm;
			if not self.db.global.ignore[combinedname] then
				self.db.global.ignore[combinedname] = {};
			end
			self.db.global.alts[faction][realm][name].guid = guid;
			self.db.global.alts[faction][realm][name].name = name;
			self.db.global.alts[faction][realm][name].realm = realm;
			self.db.global.alts[faction][realm][name].class = class;
			self.db.global.alts[faction][realm][name].level = level;
			self.db.global.alts[faction][realm][name].target = target;

			if isSpecd then
				local spec, specName, specDescription, specIcon, specBackground, specRole = GetSpecializationInfo(GetSpecialization());
				if specType ~= "None" then
					if not self.db.global.alts[faction][realm][name][specType] then
						self.db.global.alts[faction][realm][name][specType] = {};
					end
					self.db.global.alts[faction][realm][name][specType].id = spec;
					self.db.global.alts[faction][realm][name][specType].name = specName;
					self.db.global.alts[faction][realm][name][specType].icon = specIcon;
					local score, age, items = SIL:GetScoreGUID(guid)
					self.db.global.alts[faction][realm][name][specType].score = score;
					self.db.global.alts[faction][realm][name][specType].items = items;
					self.db.global.alts[faction][realm][name].time = age;
				end
			end
			if not self.db.global.alts[faction][realm][name].score then
				self.db.global.alts[faction][realm][name].score = 0;
			end
			if avgilvl and avgilvl >= 1 then
				self.db.global.alts[faction][realm][name].score = avgilvl;
			else
				self.name = name
				self.faction = faction
				self.realm = realm
				self.db.global.alts[faction][realm][name].score = 0;
				self.ilvltimer = self:ScheduleRepeatingTimer("DelayedAvgIlvl", 10)
			end
		end
	end
end


function SIL_Alt:DelayedAvgIlvl()
	self.avgilvl = GetAverageItemLevel();
	if self.avgilvl and self.avgilvl >= 1 then
		self.db.global.alts[self.faction][self.realm][self.name].score = self.avgilvl;
		self:CancelTimer(self.ilvltimer)
	end		
end


function SIL_Alt:UpdateLDB(force, auto)
	local label = UnitName('player');
	local text = 'n/a';
	if UnitGUID('player') then
		local score, age, items = SIL:GetScoreTarget('player');
		text = SIL:FormatScore(score, items, true);
	end
	SIL_Alt:UpdateLDBText(label, text)
end


function SIL_Alt:UpdateLDBText(label, text)   
	-- Add the label
	local ldbtext = text;
	local ldbUpdated = time();
	local ldbLable = label;
end


function SIL_Alt:FetchOrderedNames(names, characters)
	wipe(names)
	for name, name_table in pairs(characters) do
		table.insert(names, name)
	end
	SIL_Alt.sort_table = characters 
	table.sort(names, revilvlSort)
end


function revilvlSort(a,b) return SIL_Alt.sort_table[b].score < SIL_Alt.sort_table[a].score end


--[[
    Setters, Getters and Togglers
]]
function SIL_Alt:SetShowAllRealms(v) self.db.global.options.showAllRealms = v; end
function SIL_Alt:SetShowAllFactions(v) self.db.global.options.showAllFactions = v; end
function SIL_Alt:SetOnlyMaxLevel(v) self.db.global.options.onlyMaxLevel = v; end
function SIL_Alt:SetColorizeILvl(v) self.db.global.options.colorizeILvl = v; end
function SIL_Alt:SetShowTotals(v) self.db.global.options.showTotals = v; end

function SIL_Alt:GetShowAllRealms() return self.db.global.options.showAllRealms; end
function SIL_Alt:GetShowAllFactions() return self.db.global.options.showAllFactions; end
function SIL_Alt:GetOnlyMaxLevel() return self.db.global.options.onlyMaxLevel; end
function SIL_Alt:GetColorizeILvl() return self.db.global.options.colorizeILvl; end
function SIL_Alt:GetShowCharacter(e) return self.db.global.ignore[e].show; end
function SIL_Alt:GetShowTotals() return self.db.global.options.showTotals; end

function SIL_Alt:ToggleShowAllRealms() self:SetShowAllRealms(not self:GetShowAllRealms()); end
function SIL_Alt:ToggleShowAllFactions() self:SetShowAllFactions(not self:GetShowAllFactions()); end
function SIL_Alt:ToggleOnlyMaxLevel() self:SetOnlyMaxLevel(not self:GetOnlyMaxLevel()); end
function SIL_Alt:ToggleColorizeILvl() self:SetColorizeILvl(not self:GetColorizeILvl()); end
function SIL_Alt:ToggleShowCharacter(e) self:SetShowCharacter(e, not self:GetShowCharacter(e)); end
function SIL_Alt:ToggleShowTotals() self:SetShowTotals(not self:GetShowTotals()); end

-- More advanced ones
function SIL_Alt:SetShowCharacter(e, v) 
	self.db.global.ignore[e].show = v; 
end

function SIL_Alt:GetPlayerNames()
	for pfaction, pfaction_table in pairs(self.db.global.alts) do
		for prealm, prealm_table in pairs(pfaction_table) do
			for pname in pairs(prealm_table) do
				pserver = " - " .. prealm;
				SIL_Alt.playerNames[pname .. pserver] = pname .. pserver;
			end
		end
	end
	return SIL_Alt.playerNames;
end


-- Add SiL Menu Options
function SIL_Alt:SetupSILMenu()
	SIL:AddMenuItems('middle', {
		text = L.alts.options.name,
		isTitle = 1,
		notCheckable = 1,
	}, 1);
	SIL:AddMenuItems('middle', {    
		text = L.alts.options.onlyMaxLevel,
		func = function() SIL_Alt:ToggleOnlyMaxLevel(); end,
		checked = function() return SIL_Alt:GetOnlyMaxLevel(); end,
	}, 1);
	SIL:AddMenuItems('middle', {    
		text = L.alts.options.showAllRealms,
		func = function() SIL_Alt:ToggleShowAllRealms(); end,
		checked = function() return SIL_Alt:GetShowAllRealms(); end,
	}, 1);
	SIL:AddMenuItems('middle', {    
		text = L.alts.options.showAllFactions,
		func = function() SIL_Alt:ToggleShowAllFactions(); end,
		checked = function() return SIL_Alt:GetShowAllFactions(); end,
	}, 1);
	SIL:AddMenuItems('middle', {
		text = L.alts.options.showTotals,
		func = function() SIL_Alt:ToggleShowTotals(); end,
		checked = function() return SIL_Alt:GetShowTotals(); end,
	}, 1);
	SIL:AddMenuItems('middle', {
		text = L.alts.options.colorizeILvl,
		func = function() SIL_Alt:ToggleColorizeILvl(); end,
		checked = function() return SIL_Alt:GetColorizeILvl(); end,
	}, 1);
end


-- Options displayed in Blizz Interface options pane
SILAlt_Options = {
	name = L.alts.options.name,
	type = "group",
	args = {
		colorizeILvl = {
			name = L.alts.options.colorizeILvl,
			desc = L.alts.options.colorizeILvlDesc,
			type = "toggle",
			set = function(i,v) SIL_Alt:SetColorizeILvl(v); end,
			get = function(i) return SIL_Alt:GetColorizeILvl(); end,
			order = 5,
		},
		showAllRealms = {
			name = L.alts.options.showAllRealms,
			desc = L.alts.options.showAllRealmsDesc,
			type = "toggle",
			set = function(i,v) SIL_Alt:SetShowAllRealms(v); end,
			get = function(i) return SIL_Alt:GetShowAllRealms(); end,
			order = 6,
		},
		showAllFactions = {
			name = L.alts.options.showAllFactions,
			desc = L.alts.options.showAllFactionsDesc,
			type = "toggle",
			set = function(i,v) SIL_Alt:SetShowAllFactions(v); end,
			get = function(i) return SIL_Alt:GetShowAllFactions(); end,
			order = 7,
		},
		onlyMaxLevel = {
			name = L.alts.options.onlyMaxLevel,
			desc = L.alts.options.onlyMaxLevelDesc,
			type = "toggle",
			set = function(i,v) SIL_Alt:SetOnlyMaxLevel(v); end,
			get = function(i) return SIL_Alt:GetOnlyMaxLevel(); end,
			order = 8,
		},
		showTotals = {
			name = L.alts.options.showTotals,
			desc = L.alts.options.showTotalsDesc,
			type = "toggle",
			set = function(i,v) SIL_Alt:SetShowTotals(v); end,
			get = function(i) return SIL_Alt:GetShowTotals(); end,
			order = 9,
		},
		playerNames = {
			name = L.alts.options.showCharacter,
			type = 'multiselect', 
			values = function() return SIL_Alt:GetPlayerNames(); end;
			get = function(s,e) return SIL_Alt:GetShowCharacter(e) end;
			set = function(s,e,v) return SIL_Alt:SetShowCharacter(e, v) end;
			order = 100,
		},
	}
}


-- Default SV Table
SILAlt_Defaults = {
	global = {
		options = {
			color = true,
			showAllRealms = true,
			colorizeILvl = true,
			showAllFactions = true,
			onlyMaxLevel = false,
			showTotals = true,
		},
		alts = {
			-- Faction
			['*'] = {
				-- Realm
				['*'] = {
					-- Name
					['*'] = {
						["score"] = 0,
						-- Spec
						['*'] = {
							["id"] = "",
							["name"] = "",
							["icon"] = "",
							["score"] = 0,
						}
					}
				}
			}
		},
		ignore = {
			['*'] = {
				show = "true",
			}
		},
	}
};
