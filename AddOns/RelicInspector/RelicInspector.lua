-- RelicInspector.lua
-- Author: Thoralie

local addonName, addon = ...

local function invertTable(table)
	if type(table) ~= "table" then return end
	local invTable = {}
	for k, v in pairs(table) do
		invTable[v] = k 
	end
	return invTable
end

local RelicSpells = addon.SpellIDByRelic
local RelicTypeNames = addon.RelicTypes
local RelicSlotsByArtifact = addon.RelicSlots
local PowersToScrape = addon.PowersToScrape
local SpecByArtifact = addon.Artifacts
local ArtifactBySpec = invertTable(addon.Artifacts)

local DEBUG = 0
local MAX_LINE_LENGTH = 80

-- 7.2 Hack for lack of item links
local t_threshold = 1.0
local itemRefLinkInfo = {'',0}
local xSetHyperlink = ItemRefTooltip.SetHyperlink
ItemRefTooltip.SetHyperlink = function(self, link, ...)
	itemRefLinkInfo[1] = link 
	itemRefLinkInfo[2] = GetTime()
	xSetHyperlink(self, link, ...)
end

local GameLinkInfo = {'',0}
local function gHack(self, unit, slot) 
	local link = GetInventoryItemLink(unit, slot)
	GameLinkInfo[1] = link 
	GameLinkInfo[2] = GetTime()
end
hooksecurefunc(GameTooltip,'SetInventoryItem', gHack)
--

local options, optionsFrame, db, charDB

local modifierPressed = 0

local itemLevelOptions = {
    [1] = "Relic",
    [2] = "Artifact",
}
local invItemLevelOptions = invertTable(itemLevelOptions)

local locItemLevelOptions = {
    [1] = INVTYPE_RELIC,
    [2] = ITEM_QUALITY6_DESC,
}

local hoverOptions = {
    [1] = "Never",
    [2] = "CTRL Key",
    [3] = "Always" 
}
local invHoverOptions = invertTable(hoverOptions)

local locHoverOptions = {
    [1] = NEVER,
    [2] = CTRL_KEY,
    [3] = ALWAYS
}

local linkOptions = {
    [1] = "Never",
    [2] = "Always" 
}
local invLinkOptions = invertTable(linkOptions)

local locLinkOptions = {
    [1] = NEVER,
    [2] = ALWAYS
}

local relicOffspecOptions = {
    [1] = "None",
    [2] = "All",
}
local invRelicOffspecOptions = invertTable(relicOffspecOptions)

local locRelicOffspecOptions = {
    [1] = NONE,
    [2] = ALL_SPECS,
}

local relicSpecOptions = {
    [1] = "None",
    [2] = "Specs",
    [3] = "SpecsAndQuantities",
    [4] = "SpecsAndTraits",
    [5] = "SpecsTraitDescription",
}
local invRelicSpecOptions = invertTable(relicSpecOptions)

local locRelicSpecOptions = {
    [1] = NONE,
    [2] = ALL_SPECS,
    [3] = ALL_SPECS .. " (with Quantities)",
    [4] = ALL_SPECS .. " & " .. ARTIFACTS_PERK_TAB,
    [5] = ALL_SPECS .. ", " .. ARTIFACTS_PERK_TAB .. ", & " .. DESCRIPTION
}

local defaults = {
	profile = {
		enabled = true,
		itemLevelDisplay = "Relic",
		hoverTraitNames = "Always",
		hoverTraitDesc = "CTRL Key",
		hoverNLC = "Always",
		linkTraitNames = "Always",
		linkTraitDesc = "Always",
		relicSpecs = "Specs",
		offspecsToShow = "All"
	}
}

local function SetupOptions()
	if options then return options end

	options = {
		name = "RelicInspector",
		type = "group",
		args = {
			general = {
				name = "Options",
				type = "group",
				args = {
					enabled = {
						name = "Enable",
						desc = "Enables / Disables RelicInspector",
						type = "toggle",
						width = "double",
						set = function(info,val) db.profile.enabled = val end,
						get = function(info) return db.profile.enabled end,
						order = 10
					},
					itemLevelChoice = {
						name = "Item Level To Display:",
						desc = "Whether to show relic item level or weapon gain",
						type = "select",
						width = "double",
						set = function(info,val) db.profile.itemLevelDisplay = itemLevelOptions[val] end,
						get = function(info) return invItemLevelOptions[db.profile.itemLevelDisplay] end,
						order = 15,
						values = locItemLevelOptions
					},
					itemTooltipHeader = {
						name = "Artifact Item Tooltips",
						type = "header",
						order = 20
					},
					itemTooltipTraitNames = {
						name = "Show Trait Names:",
						desc = "When to show trait names on artifact tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.hoverTraitNames = hoverOptions[val] end,
						get = function(info) return invHoverOptions[db.profile.hoverTraitNames] end,
						order = 21,
						values = locHoverOptions
					},
					itemTooltipTraitDesc = {
						name = "Show Trait Descriptions:",
						desc = "When to show trait descriptions on artifact tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.hoverTraitDesc = hoverOptions[val] end,
						get = function(info) return invHoverOptions[db.profile.hoverTraitDesc] end,
						order = 22,
						values = locHoverOptions
					},
					itemTooltipNetherlight = {
						name = "Show " .. SPLASH_LEGION_NEW_7_3_FEATURE1_TITLE .. " " .. ARTIFACTS_PERK_TAB .. ":",
						desc = "When to show Netherlight Crucible traits on artifact tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.hoverNLC = linkOptions[val] end,
						get = function(info) return invLinkOptions[db.profile.hoverNLC] end,
						order = 23,
						values = locLinkOptions
					},
					linkTooltipHeader = {
						name = "Artifact Link Tooltips",
						type = "header",
						order = 30
					},
					linkTooltipTraitNames = {
						name = "Show Trait Names:",
						desc = "When to show trait names on link tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.linkTraitNames = linkOptions[val] end,
						get = function(info) return invLinkOptions[db.profile.linkTraitNames] end,
						order = 31,
						values = locLinkOptions
					},
					linkTooltipTraitDesc = {
						name = "Show Trait Descriptions:",
						desc = "When to show trait descriptions on link tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.linkTraitDesc = linkOptions[val] end,
						get = function(info) return invLinkOptions[db.profile.linkTraitDesc] end,
						order = 32,
						values = locLinkOptions
					},
					relicTooltipHeader = {
						name = "Relic Tooltips",
						type = "header",
						order = 40
					},
					relicTooltipOffspecs = {
						name = "Unequipped Artifact Traits to Show:",
						desc = "Which unequipped artifacts to show relic traits for",
						type = "select",
						width = "double",
						set = function(info,val) db.profile.offspecsToShow = relicOffspecOptions[val] end,
						get = function(info) return invRelicOffspecOptions[db.profile.offspecsToShow] end,
						order = 41,
						values = locRelicOffspecOptions
					},
					relicSpecs = {
						name = "Show Spec Requirements on Relics:",
						desc = "What spec information to show on relics",
						type = "select",
						width = "double",
						set = function(info,val) db.profile.relicSpecs = relicSpecOptions[val] end,
						get = function(info) return invRelicSpecOptions[db.profile.relicSpecs] end,
						order = 43,
						values = locRelicSpecOptions
					},
				}
			},
		}
	}

	return options
end

local function initialize()
	db = _G.LibStub("AceDB-3.0"):New("RelicInspectorDB", defaults, "Default")
	local config = _G.LibStub("AceConfig-3.0")
	local dialog = _G.LibStub("AceConfigDialog-3.0")
	local options = SetupOptions()

	config:RegisterOptionsTable("RelicInspector", options)
	optionsFrame = dialog:AddToBlizOptions("RelicInspector", "RelicInspector", nil, "general")

	-- Init the per-character DB also
	charDB = _G.LibStub("AceDB-3.0"):New("RelicInspectorCharDB")
end

local RISpellTooltip = CreateFrame('GameTooltip', 'RISpellTooltip', nil, 'GameTooltipTemplate')
local function GetDescriptionFromTooltip(powerID) 
	if not powerID then return nil end
	if not PowersToScrape[powerID] then return nil end

	RISpellTooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
	RISpellTooltip:SetArtifactPowerByID(powerID)

	local str = _G['RISpellTooltipTextLeft3']
	local text = str and str:GetText()
	return text
end

local function scrubRelicLink(link)
	if link == nil then return nil end
	local pieces = {strsplit(':', link)}
	pieces[10] = '' --remove Level
	pieces[11] = '' --remove Spec
	local str = pieces[1]
	for u=2,#pieces do
		str = str .. ':' .. pieces[u]
	end
	return str
end

local function updateArtifactCache()
	local artifactID,_,_,_,_,aLvl = C_ArtifactUI.GetArtifactInfo()

	if nil ~= artifactID then
		local weaponCache = {}
		if nil == charDB.char.artifactCache then
			charDB.char.artifactCache = {}
		elseif nil ~= charDB.char.artifactCache[artifactID] then
			weaponCache = charDB.char.artifactCache[artifactID]
		end

		local t = GetTime()
		weaponCache['timestamp'] = t
		weaponCache['level'] = aLvl

		local crucibled = weaponCache['crucibled'] or false
		
		for n=1,3 do
			local relicCache = {}
			local relicInfo = {C_ArtifactUI.GetRelicInfo(n)}
			if nil ~= relicInfo then
				if DEBUG ~=0 then print(format("Updating Relic: %s",relicInfo[1])) end
				relicInfo[4] = scrubRelicLink(relicInfo[4])
				relicCache['relic'] = relicInfo
			end

			if C_ArtifactRelicForgeUI.IsAtForge() then -- if we're not, we can't update NLC stuff
				if DEBUG ~=0 then print("I'm At the NLC") end
				local relicTalents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(n)

				--Cache the spellID for each "power"
				if nil ~= relicTalents then
					crucibled = true -- per-weapon check
					charDB.char.crucibleUsed = true -- per character check
					for p=1,#relicTalents do
						local pID = relicTalents[p].powerID
						local sID = C_ArtifactUI.GetPowerInfo(pID).spellID
						if nil ~= sID then
							relicTalents[p].spellID = sID
							if DEBUG ~=0 then print(format('Spell ID: %s',sID)) end
						end
					end
				end
				relicCache['traits'] = relicTalents
				weaponCache[n] = relicCache
			else 
				-- Still check relics but try not to nuke the NLC stuff if they haven't changed
				if nil ~= weaponCache[n] then
					if nil ~= weaponCache[n].relic then
						if nil ~= weaponCache[n].relic[4] then
							if nil ~= relicInfo[4] then
								if weaponCache[n].relic[4] == relicInfo[4] then
								else 
									weaponCache[n] = relicCache
								end
							end
						end
					end
				end
			end
		end
		weaponCache['crucibled'] = crucibled
		
		--store it in the per-character DB
		if nil == charDB.char.artifactCache then
			charDB.char.artifactCache = {}
		end
		charDB.char.artifactCache[artifactID] = weaponCache
	end
end

local function isItemRef(self)
	return (self:GetName() == "ItemRefTooltip")
end

local function DecorateArtifact(self)
	local _, link = self:GetItem()
	if type(link) == 'string' and db.profile.enabled == true then
		local _, itemID, _, relic1, relic2, relic3, _, _, _, _, _, upgradeID = strsplit(':', link)

		-- 7.2-introduced hack for lack of proper item links
		if nil == itemID or '' == itemID then 
			if isItemRef(self) and itemRefLinkInfo[1] ~= nil and itemRefLinkInfo[1] ~= '' then
				local tc = GetTime()
				local tdelta = tc-itemRefLinkInfo[2]
				local _, itemRefID, _, IRrelic1, IRrelic2, IRrelic3, _, _, _, _, _, IRupgradeID = strsplit(':', itemRefLinkInfo[1])
				if nil ~= itemRefID and '' ~= itemRefID then 
					if tdelta < t_threshold then
						link,itemID,relic1,relic2,relic3,upgradeID = itemRefLinkInfo[1],itemRefID,IRrelic1,IRrelic2,IRrelic3,IRupgradeID
					else
						self:AddLine(format('|cffff0000%s|r', "Double click link to reload and view relic info"), 1, 1, 1, true)
					end
				end
			elseif self:GetName() == "GameTooltip" and GameLinkInfo[1] ~= nil and GameLinkInfo[1] ~= '' then
				local tc = GetTime()
				local tdelta = tc-GameLinkInfo[2]
				local _, gID, _, grelic1, grelic2, grelic3, _, _, _, _, _, gupgradeID = strsplit(':', GameLinkInfo[1])
				if nil ~= gID and '' ~= gID then 
					if tdelta < t_threshold then
						link,itemID,relic1,relic2,relic3,upgradeID = GameLinkInfo[1],gID,grelic1,grelic2,grelic3,gupgradeID
					end
				end
			end
		end  

		if (upgradeID == '256' or upgradeID == '16777472') and nil ~= RelicSlotsByArtifact[tonumber(itemID)] then
			--It's a recognized artifact item
			local showTraitNames, showTraitDesc, showCrucibleTraits = false, false, false

			-- check if the user wants Crucible talents shown, then start eliminating reasons
			if invLinkOptions[db.profile.hoverNLC] == 2 then
				showCrucibleTraits = true
			end
			if(isItemRef(self)) then
				-- Item Links
				showCrucibleTraits = false -- Never show Crucible for links
				
				if invLinkOptions[db.profile.linkTraitNames] == 2 then
					showTraitNames = true
				end
				if invLinkOptions[db.profile.linkTraitDesc] == 2 then
					showTraitDesc = true
				end
			else -- Game or Shopping Hover Tooltips
				if invHoverOptions[db.profile.hoverTraitNames] == 3 or
					(invHoverOptions[db.profile.hoverTraitNames] == 2 and modifierPressed ~= 0) then
					showTraitNames = true
				end
				if invHoverOptions[db.profile.hoverTraitDesc] == 3 or
					(invHoverOptions[db.profile.hoverTraitDesc] == 2 and modifierPressed ~= 0) then
					showTraitDesc = true
				end

				--Check what we're mousing over
				local owner = self:GetOwner()
				if nil ~= owner then
					local parent = owner:GetParent()
					if nil ~= parent and parent == InspectPaperDollItemsFrame then
						showCrucibleTraits = false
					end
				end
			end
			local _,_,_,nc = GetAchievementInfo(12072) -- is the Crucible unlocked?
			if not nc then
				showCrucibleTraits = false
			end
			local artiCache = charDB.char.artifactCache
			if nil == artiCache then
				showCrucibleTraits = false
			end

			local relics = {relic1,relic2,relic3}
			local showNewNLCTraitMsg = false
			for i = 1,#relics do 
				if '' ~= relics[i] then
					if DEBUG ~=0 then print(format('Found a Relic: %s',relics[i])) end
					local name, gemLink = GetItemGem(link,i)
					if type(gemLink) == 'string' then
						--Display the gem name, item level, and relic type
						local _, _, _, gemLevel = GetItemInfo(gemLink)
						local relicType = RelicTypeNames[RelicSlotsByArtifact[tonumber(itemID)][i]]
						if nil == relicType then relicType = "???" end
						
						local itemLevel = gemLevel
						if invItemLevelOptions[db.profile.itemLevelDisplay] == 2 then
							local artifactLevelGain = C_ArtifactUI.GetItemLevelIncreaseProvidedByRelic(gemLink)
							itemLevel = "+" .. artifactLevelGain
						end

						if (showTraitNames or showTraitDesc) and showCrucibleTraits then
							self:AddLine(' ',1,1,1,false)  -- Blank line as a spacer
						end
						self:AddDoubleLine(format('|cffffd400(%s) %s|r', itemLevel or '???', gemLink or '???'), 
							format('|cff00ff00(%s)',relicType), 0, 1, 0, 0, 1, 0)

						-- Let's add the Ranks and Trait names if we are supposed to
						if showTraitNames or showTraitDesc then
							local traitsToDisplay = {}

							-- Add the native trait 
							local spellLookupKey = itemID .. '.' .. relics[i]
							if nil ~= RelicSpells[spellLookupKey] then
								local nativeTrait = {}
								nativeTrait['spellID'] = RelicSpells[spellLookupKey]
								nativeTrait['powerID'] = 0 -- We don't really care what this is for now
								tinsert(traitsToDisplay,nativeTrait)
							end

							if showCrucibleTraits then
								local artiCacheWeapon = artiCache[tonumber(itemID)]
								if nil ~= artiCacheWeapon then
									local weaponArtifactLevel = artiCacheWeapon.level or 0
									local artiCacheRelic = artiCacheWeapon[i]
									if nil ~= artiCacheRelic then
										local traitCache = artiCacheRelic.traits
										if nil ~= traitCache then
											if DEBUG ~=0 then print(format("Traits not nil for relic %d",i)) end
											local traitsChosen = {}
											for p = 1,#traitCache do 
												if nil ~= traitCache[p] then
													if traitCache[p].isChosen then 
														traitsChosen[traitCache[p].requiredArtifactLevel] = true
														if traitCache[p].powerID == 1739 then -- 1739 is Netherlight Fortification (+5 Item levels). Show that first since it's special.
															tinsert(traitsToDisplay,1,traitCache[p])
														else
															tinsert(traitsToDisplay,traitCache[p])
														end
													else
														if nil == traitsChosen[traitCache[p].requiredArtifactLevel] then
															traitsChosen[traitCache[p].requiredArtifactLevel] = false
														end
													end
												end
											end
											for l,isChosen in pairs(traitsChosen) do 
												if not isChosen and l <= weaponArtifactLevel then
													-- Should have a new trait available!
													if DEBUG ~=0 then print(format('Relic %d NLC Trait for Level %d should be available',i,l)) end
													showNewNLCTraitMsg = true
												end

											end
										else
											--No cached traits, but is it bc we haven't unlocked any? Or bc we just changed a relic?
											if artiCacheWeapon.crucibled then
												--We've theoretically unlocked traits on this weapon before, so at least one should be available.
												--Prompt user to return to forge
												showNewNLCTraitMsg = true
											elseif charDB.char.crucibleUsed then
												showNewNLCTraitMsg = true
											end
										end
									elseif charDB.char.crucibleUsed then
										showNewNLCTraitMsg = true
									end
								else
									if charDB.char.crucibleUsed then
										showNewNLCTraitMsg = true
									end	
								end
							end

							for w = 1,#traitsToDisplay do
								local t = traitsToDisplay[w]
								--Add Trait Name
								if showTraitNames == true then
									if t.powerID == 1739 then -- 1739 is Netherlight Fortification
										self:AddLine(format(RELIC_TOOLTIP_ILVL_INCREASE, 5), 0, 1, 0, false)
									else  
										local traitName = GetSpellInfo(t.spellID)
										if nil ~= traitName then
											-- Still assuming 1 Rank per relic/trait. Will have to update this if relics ever start giving more than 1 rank
											self:AddLine(format(RELIC_TOOLTIP_RANK_INCREASE, 1, traitName), 1, 1, 1, false)
										end
									end
								end
								--Add Trait Description
								if showTraitDesc == true then
									if t.powerID ~= 1739 then -- +Item Levels is pretty self explanatory, doesn't need a desc
										local traitDesc = GetDescriptionFromTooltip(t.powerID) -- Check if it's one we should scrape first, do that
										if not traitDesc then
											traitDesc = GetSpellDescription(t.spellID)
										end
										if nil ~= traitDesc then
											traitDesc = string.gsub(traitDesc,string.char(10),"")
											traitDesc = string.gsub(traitDesc,string.char(13),string.char(13).."  ")
											self:AddLine(format('|cffff78ff  %s|r', traitDesc), 1, 1, 1, (string.len(traitDesc) > MAX_LINE_LENGTH))
										end
									end
								end
							end
						end
					end	
				end
			end

			if showCrucibleTraits and showNewNLCTraitMsg then
				self:AddLine(' ',1,1,1,false)
				self:AddLine(format(ARTIFACT_RELIC_TALENT_AVAILABLE, 1, traitName), 1, 0, 0, false)
			end
		end	
	end
end

local function DecorateRelic(self)
	local _, link = self:GetItem()
	if type(link) == 'string' and db.profile.enabled == true then
		local _, itemID = strsplit(':', link)
		if nil == itemID or '' == itemID then return end  -- If there's no itemID we can't do anything

		local _, _, relicTypeKey = C_ArtifactUI.GetRelicInfoByItemID(tonumber(itemID))

		if nil == relicTypeKey then	return end -- If it's not a relic then we don't care

		local showOffspecs = false 
		if invRelicOffspecOptions[db.profile.offspecsToShow] > 1 then
			showOffspecs = true
		end

		if showOffspecs then
			local _, _, classID = UnitClass("player")
			local currentSpec = GetSpecializationInfo(GetSpecialization())

			local specTraitInfo = {}
			for a = 1,4 do -- Only Druids need 4, but should run them all in case
				local theSpecID = GetSpecializationInfoForClassID(classID,a)
				if nil ~= theSpecID then
					local anArtifactID = ArtifactBySpec[theSpecID]
					if nil ~= anArtifactID then
						local spellLookupKey = anArtifactID .. '.' .. itemID
						local traitSpellID = RelicSpells[spellLookupKey]

						if nil ~= traitSpellID then
							local specArtifactInfo = {theSpecID,anArtifactID,traitSpellID} 
							if theSpecID ~= currentSpec then 	-- Current spec is already shown by Blizzard UI (if you have that one)
								tinsert(specTraitInfo,specArtifactInfo)
							end
						end
					end
				end
			end

			if #specTraitInfo > 0 then 
				self:AddLine(' ',1,1,1,false) 
			end
			local showTraitNames, showTraitDesc = true, true  -- Change this if we want to give options for it
			for r = 1,#specTraitInfo do
				local tSpec, tArtifact, tSpellID = specTraitInfo[r][1], specTraitInfo[r][2], specTraitInfo[r][3]
				local _, specName = GetSpecializationInfoByID(tSpec)
				local _, artifactLink = GetItemInfo(tArtifact)

				if nil ~= specName and nil ~= artifactLink then
					self:AddLine(format('%s: %s', specName, artifactLink), 1, 1, 1, false)

					if showTraitNames == true then
						local traitName = GetSpellInfo(tSpellID)
						if nil ~= traitName then
							-- Assuming 1 Rank per relic right now. Will have to update this if relics start giving more than 1 rank
							self:AddLine(format(' ' .. RELIC_TOOLTIP_RANK_INCREASE, 1, traitName), 1, 1, 1, false)
						end
					end
					if showTraitDesc == true then
						local traitDesc = GetSpellDescription(tSpellID)
						if nil ~= traitDesc then
							traitDesc = string.gsub(traitDesc,string.char(10),"")
							traitDesc = string.gsub(traitDesc,string.char(13),"")
							self:AddLine(format('|cffff78ff  %s|r', traitDesc), 1, 1, 1, true)
						end
					end
				end
			end
		end

		-- See if spec requirements are enabled for relics
		if invRelicSpecOptions[db.profile.relicSpecs] > 1 then
			self:AddLine(' ',1,1,1,false)
			-- First find the specs that use it, and how many of each
			local usableSpecs = {}
			for k, v in pairs(RelicSlotsByArtifact) do
				local aSpec = SpecByArtifact[k]
				local specRelicCount = 0
				for i = 1,3 do
					if(v[i] == relicTypeKey) then
						specRelicCount = specRelicCount + 1
					end
				end
				if specRelicCount > 0 then
					tinsert(usableSpecs,aSpec,specRelicCount)
				end
			end

			-- Make a table of required specs and sort that to keep class specs together
			local specKeys = {}
			for k in pairs(usableSpecs) do
				tinsert(specKeys,k)
			end
			table.sort(specKeys) 

			if invRelicSpecOptions[db.profile.relicSpecs] > 3 then
				for q = 1,#specKeys do
					local _, specName, _, _, _, classKey = GetSpecializationInfoByID(specKeys[q])
					local classColorSet = RAID_CLASS_COLORS[classKey]
					local classColor = classColorSet.colorStr
					local spellLookupKey = ArtifactBySpec[specKeys[q]] .. '.' .. itemID
					local traitSpellID = RelicSpells[spellLookupKey]
					local traitName = GetSpellInfo(traitSpellID)

					local quantity = ""
					if usableSpecs[specKeys[q]] > 1 then
						quantity = format(' (%d)',usableSpecs[specKeys[q]])
					end

					local specLine = format('|c%s%s%s:|r %s',classColor,specName,quantity,traitName or "???")
					self:AddLine(format(specLine), 1, 1, 1, false)
					if invRelicSpecOptions[db.profile.relicSpecs] > 4 then
						local traitDesc = GetSpellDescription(traitSpellID)
						if nil ~= traitDesc then
							traitDesc = string.gsub(traitDesc,string.char(10),"")
							traitDesc = string.gsub(traitDesc,string.char(13),"")
							self:AddLine(format('|cffffd200  %s|r', traitDesc), 1, 1, 1, (string.len(traitDesc) > MAX_LINE_LENGTH))
						end
					end
				end
			else
				-- Assemble the string of all specs (and quantities if applicable)
				local specsStr = ""
				for q = 1,#specKeys do
					local _, specName, _, _, _, classKey = GetSpecializationInfoByID(specKeys[q])
					local classColorSet = RAID_CLASS_COLORS[classKey]
					local classColor = classColorSet.colorStr
					local separator = ", "
					if q == #specKeys then separator = "" end
					local quantity = "" 
					if invRelicSpecOptions[db.profile.relicSpecs] == 3 and usableSpecs[specKeys[q]] > 1 then
						quantity = format(' (%d)',usableSpecs[specKeys[q]])
					end
					local specString = format('|c%s%s%s|r%s',classColor,specName,quantity,separator)
					specsStr = specsStr .. specString
				end
				self:AddLine(format(ITEM_REQ_SPECIALIZATION,specsStr), 1, 1, 1, true)
			end
		end
	end
end

local m = CreateFrame('frame')
m:HookScript("OnEvent", function(self, event, key, state)
	if event == "MODIFIER_STATE_CHANGED" and (key == "LCTRL" or key == "RCTRL") then
		modifierPressed = state
	end
end)
m:RegisterEvent("MODIFIER_STATE_CHANGED")

local f = CreateFrame('frame')
f:SetScript('OnEvent', function(self, event, arg1)
  if arg1 == addonName then
    self:UnregisterEvent('ADDON_LOADED')
    initialize()
  end
end)
f:RegisterEvent('ADDON_LOADED')

local af = CreateFrame('frame')
af:SetScript('OnEvent', function(self, event, arg1)
	updateArtifactCache()
end)
af:RegisterEvent('ARTIFACT_RELIC_FORGE_UPDATE')
af:RegisterEvent('ARTIFACT_UPDATE')


ItemRefTooltip:HookScript('OnTooltipSetItem', DecorateArtifact)
GameTooltip:HookScript('OnTooltipSetItem', DecorateArtifact)
ShoppingTooltip1:HookScript('OnTooltipSetItem', DecorateArtifact)
ShoppingTooltip2:HookScript('OnTooltipSetItem', DecorateArtifact)

GameTooltip:HookScript('OnTooltipSetItem', DecorateRelic)
ItemRefTooltip:HookScript('OnTooltipSetItem', DecorateRelic)

WorldMapTooltip.ItemTooltip.Tooltip:HookScript('OnTooltipSetItem', DecorateRelic)
