-- App locals
local appName, app = ...;
local SearchForField = app.SearchForField;
local UpdateGroups = app.UpdateGroups;
local IsRetrieving = app.Modules.RetrievingData.IsRetrieving;
local rawset, tostring = rawset, tostring;

-- WoW API Cache
local GetItemInfo = app.WOWAPI.GetItemInfo;
local GetItemID = app.WOWAPI.GetItemID;

-- Uncomment this section to also harvest tooltip data.
--[[
local ItemHarvester = CreateFrame("GameTooltip", "ATTCItemHarvester", UIParent, "GameTooltipTemplate");
CreateItemHarvester = app.ExtendClass("ItemHarvester", "ItemTooltipHarvester", "itemID", {
	IsClassIsolated = true,
	text = function(t)
		local link = t.link;
		if link then
			ItemHarvester:SetOwner(UIParent,"ANCHOR_NONE")
			ItemHarvester:SetHyperlink(link);
			local lineCount = ItemHarvester:NumLines();
			local str = ATTCItemHarvesterTextLeft1:GetText();
			if not IsRetrieving(str) and lineCount > 0 then
				local requirements = {};
				for index=2,lineCount,1 do
					local line = _G["ATTCItemHarvesterTextLeft" .. index] or _G["ATTCItemHarvesterText" .. index];
					if line then
						local text = line:GetText();
						if text then
							if text:find("Classes: ") then
								local classes = {};
								local _,list = (":"):split(text);
								for i,className in ipairs({(","):split(list)}) do
									tinsert(classes, app.ClassInfoByClassName[className:trim()].classID);
								end
								if #classes > 0 then
									t.info.classes = classes;
								end
							elseif text:find("Races: ") then
								local races = {};
								local _,list = (":"):split(text);
								for i,raceName in ipairs({(","):split(list)}) do
									tinsert(races, app.RaceDB[raceName:trim()]);
								end
								if #races > 0 then
									t.info.races = races;
								end
							elseif text:find("Requires") and not text:find("Level") and not text:find("Riding") then
								local c = text:sub(1, 1);
								if c ~= " " and c ~= "\t" and c ~= "\n" and c ~= "\r" then
									text = text:trim():sub(9);
									if text:find("-") then
										t.info.minReputation = app.CreateFactionStandingFromText(text);
									else
										if text:find("%(") then
											if t.info.requireSkill then
												-- If non-specialization skill is already assigned, skip this part.
												text = nil;
											else
												text = ("("):split(text);
											end
										end
										if text then
											local spellName = text:trim();
											if spellName == "Herbalism" then spellName = "Herb Gathering"; end
											local spellID = app.SpellNameToSpellID[spellName];
											if spellID then
												local skillID = app.SpellIDToSkillID[spellID];
												if skillID then
													t.info.requireSkill = skillID;
												else
													print("Unknown Skill '" .. spellName .. "'");
													tinsert(requirements, spellName);
												end
											else
												print("Unknown Spell '" .. spellName .. "'");
												tinsert(requirements, spellName);
											end
										end
									end
								end
							end
						end
					end
				end
				if #requirements > 0 then
					t.info.otherRequirements = requirements;
				end
				rawset(t, "text", link);
				rawset(t, "collected", true);
			end
			ItemHarvester:Hide();
			return link;
		end
	end
});
]]--

-- Implementation
if app.GameBuildVersion > 30000 then
local GetAchievementCategory, GetAchievementInfo, GetAchievementNumCriteria, GetAchievementCriteriaInfo
	= GetAchievementCategory, GetAchievementInfo, GetAchievementNumCriteria, GetAchievementCriteriaInfo;
local HarvestedAchievementDatabase = {};
app:CreateWindow("AchievementFinder", {
	HideFromSettings = true,
	Commands = { "attfindachievements" },
	OnRebuild = function(self, ...)
		if not self.data then
			local CreateAchievementHarvester = app.ExtendClass("Achievement", "AchievementHarvester", "achievementID", {
				IsClassIsolated = true,
				collectible = app.ReturnTrue,
				collected = app.ReturnFalse,
				text = function(t) return t.name; end,
				name = function(t)
					local achievementID = t.achievementID;
					if achievementID then
						local IDNumber, Name, _, _, _, _, _, Description, _, Image, _, isGuildAch = GetAchievementInfo(achievementID);
						if Name then
							local info = {
								["name"] = Name,
								["achievementID"] = IDNumber,
								["parentCategoryID"] = GetAchievementCategory(achievementID) or -1,
								["icon"] = Image,
								["isGuild"] = isGuildAch and true or nil,
							};
							if Description ~= nil and Description ~= "" then
								info.description = Description;
							end
							local totalCriteria = GetAchievementNumCriteria(achievementID);
							if totalCriteria > 0 then
								local criteria = {};
								for criteriaID=totalCriteria,1,-1 do
									---@diagnostic disable-next-line: redundant-parameter
									local criteriaString, criteriaType, _, _, reqQuantity, _, flags, assetID, _, criteriaUID = GetAchievementCriteriaInfo(achievementID, criteriaID, true);
									local crit = { ["criteriaID"] = criteriaID, ["criteriaUID"] = criteriaUID };
									if criteriaString ~= nil and criteriaString ~= "" then
										crit.name = criteriaString;
									end
									if assetID and assetID ~= 0 then
										crit.assetID = assetID;
									end
									if reqQuantity and reqQuantity > 0 then
										crit.rank = reqQuantity;
									end
									if criteriaType then
										-- Unknown type, not sure what to do with this.
										crit.criteriaType = criteriaType;
										if crit.assetID then
											if criteriaType == 27 then	-- Quest Completion
												crit._quests = { assetID };
												crit.criteriaType = nil;
												crit.assetID = nil;
												if crit.rank and crit.rank == 1 then
													crit.rank = nil;
												end
											elseif criteriaType == 36 or criteriaType == 41 or criteriaType == 42 then
												-- 36: Items (Generic)
												-- 41: Items (Use/Eat)
												-- 42: Items (Loot)
												if crit.rank and crit.rank < 2 then
													crit.provider = { "i", crit.assetID };
												else
													crit.cost = { { "i", crit.assetID, crit.rank }};
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
												crit.rank = nil;
											elseif criteriaType == 43 then	-- Exploration?!
												crit.explorationID = crit.assetID;
												crit.criteriaType = nil;
												crit.assetID = nil;
												crit.rank = nil;
											elseif criteriaType == 0 then	-- NPC Kills
												crit._npcs = { crit.assetID };
												if crit.rank and crit.rank < 2 then
													crit.rank = nil;
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
											elseif criteriaType == 96 then	-- Collect Pets
												crit._npcs = { crit.assetID };
												if crit.rank and crit.rank < 2 then
													crit.rank = nil;
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
											elseif criteriaType == 68 or criteriaType == 72 then	-- Interact with Object (68) / Fish from a School (72)
												crit._objects = { crit.assetID };
												if crit.rank and crit.rank < 2 then
													crit.rank = nil;
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
											elseif criteriaType == 7 then	-- Skill ID, Rank is Requirement
												crit.requireSkill = crit.assetID;
												crit.criteriaType = nil;
												crit.assetID = nil;
											elseif criteriaType == 40 then	-- Skill ID Learned
												crit.requireSkill = crit.assetID;
												crit.criteriaType = nil;
												crit.assetID = nil;
												crit.rank = nil;
											elseif criteriaType == 8 then	-- Achievements as Children
												crit._achievements = { crit.assetID };
												if crit.rank and crit.rank < 2 then
													crit.rank = nil;
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
											elseif criteriaType == 12 then	-- Currencies (Collected Total)
												if crit.rank and crit.rank < 2 then
													crit.cost = { { "c", crit.assetID, 1 }};
												else
													crit.cost = { { "c", crit.assetID, crit.rank }};
												end
												crit.criteriaType = nil;
												crit.assetID = nil;
												crit.rank = nil;
											elseif criteriaType == 26 then
												-- 26: Environmental Deaths
												--  0: fatigue
												--  1: drowning
												--  2: falling
												--  3/5: fire/lava
												-- https://wowwiki-archive.fandom.com/wiki/API_GetAchievementCriteriaInfo
												if crit.rank and totalCriteria == 1 then
													info.rank = crit.rank;
												end
											elseif criteriaType == 29 or criteriaType == 69 then	-- Cast X Spell Y Times
												if crit.rank and totalCriteria == 1 then
													info.rank = crit.rank;
												else
													crit.spellID = crit.assetID;
													crit.criteriaType = nil;
													crit.assetID = nil;
												end
											elseif criteriaType == 46 then	-- Minimum Faction Requirement
												crit.minReputation = { crit.assetID, crit.rank };
												crit.criteriaType = nil;
												crit.assetID = nil;
												crit.rank = nil;
											end
											-- 28: Something to do with event-based encounters, not sure what assetID is.
											-- 49: Something to do with Equipment Slots, assetID is the equipSlotID. (useless maybe?)
											-- 52: Honorable kill on a specific Class, assetID is the ClassID. (useless maybe? might be able to use a class icon?)
											-- 53: Honorable kill on a specific Class at level 35+, assetID is the ClassID. (useless maybe? might be able to use a class icon?)
											-- 54: Show a critter you /love them, assetID is useless or not present.
											-- 70: Honorable Kill at a specific place.
											-- 71: Instance Clears, assetID is of an unknown type... might be Saved Instance ID?
											-- 73: Mal'Ganis? Complete Objective? (useless)
											-- 74: No idea, tracking of some kind
											-- 92: Encounter Kills, of non-NPC type. (Group of NPCs - IE: Lilian Voss)
										elseif criteriaType == 0 or criteriaType == 3 or criteriaType == 5 or criteriaType == 6 or criteriaType == 9 or criteriaType == 10 or criteriaType == 14 or criteriaType == 15 or criteriaType == 17 or criteriaType == 19 or criteriaType == 26 or criteriaType == 37 or criteriaType == 45 or criteriaType == 75 or criteriaType == 78 or criteriaType == 79 or criteriaType == 81 or criteriaType == 90 or criteriaType == 91 or criteriaType == 109 or criteriaType == 124 or criteriaType == 126 or criteriaType == 130 or criteriaType == 134 or criteriaType == 135 or criteriaType == 136 or criteriaType == 138 or criteriaType == 139 or criteriaType == 151 or criteriaType == 156 or criteriaType == 157 or criteriaType == 158 or criteriaType == 200 or criteriaType == 203 or criteriaType == 207 then
											-- 0: Some tracking statistic, generally X/Y format and simple enough to not justify a type if no assetID is present.
											-- 3: Collect X of something that's generic for Archeology
											-- 5: Level Requirement
											-- 6: Digsites (Archeology)
											-- 9: Total Quests Completed
											-- 10: Daily Quests, every day for X days.
											-- 14: Total Daily Quests Completed
											-- 15: Battleground battles
											-- 17: Total Deaths
											-- 19: Instances Run
											-- 26: Environmental Deaths
											-- 37: Ranked Arena Wins
											-- 45: Bank Slots Purchased
											-- 75: Mounts (Total - on one Character)
											-- 78: Kill NPCs
											-- 79: Cook Food
											-- 81: Pet battle achievement points
											-- 90: Gathering (Nodes)
											-- 91: Pet Charm Totals
											-- 109: Catch Fish
											-- 124: Guild Member Repairs
											-- 126: Guild Crafting
											-- 130: Rated Battleground Wins
											-- 134: Complete Quests
											-- 135: Honorable Kills (Total)
											-- 136: Kill Critters
											-- 138: Guild Scenario Challenges Completed
											-- 139: Guild Challenges Completed
											-- 151: Guild Scenario Completed
											-- 156: Collect Pets (Total)
											-- 157: Collect Pets (Rare)
											-- 158: Pet Battles
											-- 200: Recruit Troops
											-- 203: World Quests (Total Complete)
											-- 207: Honor Earned (Total)
											-- https://wowwiki-archive.fandom.com/wiki/API_GetAchievementCriteriaInfo
											if crit.rank and totalCriteria == 1 then
												info.rank = crit.rank;
											end
										elseif criteriaType == 38 or criteriaType == 39 or criteriaType == 58 or criteriaType == 63 or criteriaType == 65 or criteriaType == 66 or criteriaType == 76 or criteriaType == 77 or criteriaType == 82 or criteriaType == 83 or criteriaType == 84 or criteriaType == 85 or criteriaType == 86 or criteriaType == 107 or criteriaType == 128 or criteriaType == 152 or criteriaType == 153 or criteriaType == 163 then	-- Ignored
											-- 38: Team Rating, which is irrelevant.
											-- 39: Personal Rating, which is irrelevant.
											-- 58: Killing Blows, might specifically be PvP.
											-- 63: Total Gold (Spent on Travel)
											-- 65: Total Gold (Spent on Barber Shop)
											-- 66: Total Gold (Spent on Mail)
											-- 76: Duels Won
											-- 77: Duels Lost
											-- 82: Auctions (Total Posted)
											-- 83: Auctions (Highest Bid)
											-- 84: Auctions (Total Purchases)
											-- 85: Auctions (Highest Sold)]
											-- 86: Most Gold Ever Owned
											-- 107: Quests Abandoned
											-- 128: Guild Bank Tabs
											-- 152: Defeat Scenarios
											-- 153: Ride to Location?
											-- 163: Also ride to location
											break;
										elseif criteriaType == 59 or criteriaType == 62 or criteriaType == 67 or criteriaType == 80 then	-- Gold Cost, if available.
											-- 59: Total Gold (Vendors)
											-- 62: Total Gold (Quest Rewards)
											-- 67: Total Gold (Looted)
											-- 80: Total Gold (Auctions)
											if crit.rank and crit.rank > 1 then
												if totalCriteria == 1 then
													-- Generic, such as the Bread Winner
													info.rank = crit.rank;
												else
													crit.cost = { { "g", crit.assetID, crit.rank } };
													crit.criteriaType = nil;
													crit.assetID = nil;
													info.rank = nil;
												end
											else
												-- nothing
											end
										end
										-- 155: Collect Battle Pets from a Raid, no assetID though RIP
										-- 158: Defeat Master Trainers
										-- 161: Capture a Battle Pet in a Zone
										-- 163: Defeat an Encounter of some kind? AssetID useless
										-- 169: Construct a building, assetID might be the buildingID.
									end
									tinsert(criteria, 1, crit);
								end
								if #criteria > 0 then info.criteria = criteria; end
							end

							HarvestedAchievementDatabase[achievementID] = info;
							AllTheThingsHarvestItems = HarvestedAchievementDatabase;
							setmetatable(t, app.BaseAchievement);
							t.name = Name;
							t.collected = true;
							return Name;
						end
						-- Save an empty value just so the Saved Variable table is always in order for easier partial-replacements if needed
						HarvestedAchievementDatabase[achievementID] = 0;
						t.collected = true;
						t.collectible = false;
					end
				end,
			});
			self.data = {
				text = "Achievement Finder",
				icon = app.asset("WindowIcon_RaidAssistant"),
				description = "This is a contribution debug tool. NOT intended to be used by the majority of the player base.\n\nUsing this tool will lag your WoW every 5 seconds. Not sure why - likely a bad Blizzard Database thing.",
				visible = true,
				expanded = true,
				progress = 0,
				total = 0,
				back = 1,
				current = 0,
				limit = 45000,
				g = { },
				OnUpdate = function(header)
					local g = header.g;
					if g then
						local count = #g;
						if count > 0 then
							for i=count,1,-1 do
								if g[i].collected then
									tremove(g, i);
								end
							end
						end
						for count=#g,5000 do
							local i = header.current + 1;
							if i <= header.limit then
								header.current = i;
								tinsert(g, CreateAchievementHarvester(i, {
									parent = header
								}));
							end
						end
					end
				end
			};
		end
	end,
	OnUpdate = function(self, ...)
		self.data.progress = 0;
		self.data.total = 0;
		UpdateGroups(self.data, self.data.g);
		self:DefaultUpdate(...);
		if self.data.OnUpdate then self.data.OnUpdate(self.data); end
	end,
	OnRefresh = function(self, ...)
		self:DelayedUpdate();
		return true;
	end,
});
end
app:CreateWindow("ItemFinder", {
	HideFromSettings = true,
	Commands = { "attfinditems" },
	OnRebuild = function(self, ...)
		if not self.data then
			local ItemHarvester = CreateFrame("GameTooltip", "ATTCItemHarvester", UIParent, "GameTooltipTemplate");
			local CreateItemHarvester = app.ExtendClass("Item", "ItemHarvester", "itemID", {
				IsClassIsolated = true,
				collectible = app.ReturnTrue,
				collected = app.ReturnFalse,
				text = function(t)
					if GetItemID(t.itemID) then
						local link = t.link;
						if link then
							local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
							itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent
								= GetItemInfo(link);
							if itemName then
								local spellName, spellID;
								if classID == "Recipe" or classID == "Mount" then
									spellName, spellID = GetItemSpell(t.itemID);
									if spellName == "Learning" then spellID = nil; end	-- RIP.
								end
								--setmetatable(t, t.conditions[2]);
								local info = {
									["name"] = itemName,
									["itemID"] = t.itemID,
									["equippable"] = itemEquipLoc and itemEquipLoc ~= "" and true or false,
									["class"] = classID,
									["subclass"] = subclassID,
									["inventoryType"] = C_Item.GetItemInventoryTypeByID(t.itemID),
									["b"] = bindType,
									["q"] = itemQuality,
									["iLvl"] = itemLevel,
									["spellID"] = spellID,
								};
								if itemMinLevel and itemMinLevel > 1 then
									info.lvl = itemMinLevel;
								end
								if info.inventoryType == 0 then
									info.inventoryType = nil;
								end
								if info.b and info.b ~= 1 then
									info.b = nil;
								end
								if info.q and info.q < 1 then
									info.q = nil;
								end
								if info.iLvl and info.iLvl < 2 then
									info.iLvl = nil;
								end
								t.itemType = itemType;
								t.itemSubType = itemSubType;
								t.info = info;
								t.retries = nil;
								self.HarvestedItemDatabase[t.itemID] = info;
								if link then
									ItemHarvester:SetOwner(UIParent,"ANCHOR_NONE")
									ItemHarvester:SetHyperlink(link);
									local lineCount = ItemHarvester:NumLines();
									local str = ATTCItemHarvesterTextLeft1:GetText();
									if not IsRetrieving(str) and lineCount > 0 then
										local requirements = {};
										for index=2,lineCount,1 do
											local line = _G["ATTCItemHarvesterTextLeft" .. index] or _G["ATTCItemHarvesterText" .. index];
											if line then
												local text = line:GetText();
												if text then
													if text:find("Classes: ") then
														local classes = {};
														local _,list = (":"):split(text);
														for i,className in ipairs({(","):split(list)}) do
															tinsert(classes, app.ClassInfoByClassName[className:trim()].classID);
														end
														if #classes > 0 then
															info.classes = classes;
														end
													elseif text:find("Races: ") then
														local races = {};
														local _,list = (":"):split(text);
														for i,raceName in ipairs({(","):split(list)}) do
															tinsert(races, app.RaceDB[raceName:trim()]);
														end
														if #races > 0 then
															info.races = races;
														end
													elseif text:find("Requires") and not text:find("Level") and not text:find("Riding") then
														local c = text:sub(1, 1);
														if c ~= " " and c ~= "\t" and c ~= "\n" and c ~= "\r" then
															text = text:trim():sub(9);
															if text:find("-") then
																info.minReputation = app.CreateFactionStandingFromText(text);
															else
																if text:find("%(") then
																	if info.requireSkill then
																		-- If non-specialization skill is already assigned, skip this part.
																		text = nil;
																	else
																		text = ("("):split(text);
																	end
																end
																if text then
																	local spellName = text:trim();
																	if spellName == "Herbalism" then spellName = "Herb Gathering"; end
																	local spellID = app.SpellNameToSpellID[spellName];
																	if spellID then
																		local skillID = app.SpellIDToSkillID[spellID];
																		if skillID then
																			info.requireSkill = skillID;
																		else
																			print("Unknown Skill '" .. spellName .. "'");
																			tinsert(requirements, spellName);
																		end
																	else
																		print("Unknown Spell '" .. spellName .. "'");
																		tinsert(requirements, spellName);
																	end
																end
															end
														end
													end
												end
											end
										end
										if #requirements > 0 then
											info.otherRequirements = requirements;
										end
										rawset(t, "text", itemName);
										rawset(t, "collected", true);
									end
									ItemHarvester:Hide();
									return itemName;
								end
								return link or itemName;
							end
						end
						
						t.retries = (t.retries or 0) + 1;
						if t.retries > 3 then
							rawset(t, "collected", true);
						end
					else
						rawset(t, "collected", true);
					end
					return tostring(t.itemID);
				end,
			});
			self.data = {
				text = "Item Finder",
				icon = app.asset("WindowIcon_RaidAssistant"),
				description = "This is a contribution debug tool. NOT intended to be used by the majority of the player base.\n\nUsing this tool will lag your WoW every 5 seconds. Not sure why - likely a bad Blizzard Database thing.",
				visible = true,
				expanded = true,
				progress = 0,
				total = 0,
				back = 1,
				currentItemID = 237826,
				minimumItemID = 1,
				OnUpdate = function(header)
					local g = header.g;
					if not g then
						g = {};
						header.g = g;
						for i=header.currentItemID,header.minimumItemID,-1 do
							if not self.HarvestedItemDatabase[i] then
								tinsert(g, CreateItemHarvester(i, {
									parent = header
								}));
							end
						end
					end
				end
			};
		end
	end,
	OnUpdate = function(self, ...)
		self.data.progress = 0;
		self.data.total = 0;
		UpdateGroups(self.data, self.data.g);
		self:DefaultUpdate(...);
		if self.data.OnUpdate then self.data.OnUpdate(self.data); end
	end,
	--[[
	OnRefresh = function(self, ...)
		self:DelayedCall("Update", 5);
		return true;
								
	end,
	]]--
	OnLoad = function(self, settings)
		self.HarvestedItemDatabase = AllTheThingsAD.HarvestedItemDatabase or {};
	end,
	OnSave = function(self, settings)
		if self.HarvestedItemDatabase then
			AllTheThingsAD.HarvestedItemDatabase = self.HarvestedItemDatabase;
		end
	end,
});
app:CreateWindow("QuestFinder", {
	HideFromSettings = true,
	Commands = { "attfindquests" },
	OnRebuild = function(self, ...)
		if not self.data then
			local CreateQuestHarvester = app.ExtendClass("Quest", "QuestHarvester", "questID", {
				IsClassIsolated = true,
				collectible = app.ReturnFalse,
				collected = app.ReturnTrue,
			},
			"AsPending", {
				collectible = app.ReturnTrue,
				collected = app.ReturnFalse,
				text = function(t)
					local link = t.name;
					if link and link ~= "" and link ~= " " and not IsRetrieving(link) then
						return link;
					end
					
					t.retries = (t.retries or 0) + 1;
					if t.retries > 30 then
						rawset(t, "collected", true);
					end
					return RETRIEVING_DATA;
				end,
			},
			function(t)
				return #SearchForField("questID", t.questID) == 0;
			end);
			self.data = {
				text = "Quest Finder",
				icon = app.asset("WindowIcon_RaidAssistant"),
				description = "This is a contribution debug tool. NOT intended to be used by the majority of the player base.\n\nUsing this tool will lag your WoW every 5 seconds. Not sure why - likely a bad Blizzard Database thing.",
				visible = true,
				expanded = true,
				progress = 0,
				total = 0,
				back = 1,
				currentID = 88749,
				minimumID = 78295,
				g = { },
				OnUpdate = function(header)
					local g = header.g;
					if g then
						local count = #g;
						if count > 0 then
							for i=count,1,-1 do
								if g[i].collected then
									tremove(g, i);
								end
							end
						end
						for count=#g,5000 do
							local i = header.currentID - 1;
							if i > header.minimumID then
								header.currentID = i;
								tinsert(g, CreateQuestHarvester(i, {
									parent = header
								}));
							end
						end
					end
				end
			};
		end
	end,
	OnUpdate = function(self, ...)
		self.data.progress = 0;
		self.data.total = 0;
		UpdateGroups(self.data, self.data.g);
		self:DefaultUpdate(...);
		if self.data.OnUpdate then self.data.OnUpdate(self.data); end
	end,
	OnRefresh = function(self, ...)
		self:DelayedCall("Update", 5);
		return true;
	end,
});
app:CreateWindow("SpellFinder", {
	HideFromSettings = true,
	Commands = { "attfindspells" },
	OnRebuild = function(self, ...)
		if not self.data then
			local CreateSpellHarvester = app.ExtendClass("Spell", "SpellHarvester", "spellID", {
				IsClassIsolated = true,
				collectible = app.ReturnFalse,
				collected = app.ReturnTrue,
			},
			"AsPending", {
				collectible = app.ReturnTrue,
				collected = app.ReturnFalse,
				text = function(t)
					local link = t.name;
					if link and link ~= "" and link ~= " " then
						return link;
					end
					
					t.retries = (t.retries or 0) + 1;
					if t.retries > 30 then
						rawset(t, "collected", true);
					end
					return RETRIEVING_DATA;
				end,
			},
			function(t)
				return #SearchForField("spellID", t.spellID) == 0;
			end);
			self.data = {
				text = "Spell Finder",
				icon = app.asset("WindowIcon_RaidAssistant"),
				description = "This is a contribution debug tool. NOT intended to be used by the majority of the player base.\n\nUsing this tool will lag your WoW every 5 seconds. Not sure why - likely a bad Blizzard Database thing.",
				visible = true,
				expanded = true,
				progress = 0,
				total = 0,
				back = 1,
				currentID = 450000,
				minimumID = 0,
				g = { },
				OnUpdate = function(header)
					local g = header.g;
					if g then
						local count = #g;
						if count > 0 then
							for i=count,1,-1 do
								if g[i].collected then
									tremove(g, i);
								end
							end
						end
						for count=#g,5000 do
							local i = header.currentID - 1;
							if i > header.minimumID then
								header.currentID = i;
								tinsert(g, CreateSpellHarvester(i, {
									parent = header
								}));
							end
						end
					end
				end
			};
		end
	end,
	OnUpdate = function(self, ...)
		self.data.progress = 0;
		self.data.total = 0;
		UpdateGroups(self.data, self.data.g);
		self:DefaultUpdate(...);
		if self.data.OnUpdate then self.data.OnUpdate(self.data); end
	end,
	OnRefresh = function(self, ...)
		self:DelayedCall("Update", 5);
		return true;
	end,
});