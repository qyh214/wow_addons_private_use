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
local SpecByArtifact = addon.Artifacts
local ArtifactBySpec = invertTable(addon.Artifacts)

local DEBUG = 0

--Potential 7.2 Hack
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

local options, optionsFrame, db

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
						desc = "When to show trait names on item tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.hoverTraitNames = hoverOptions[val] end,
						get = function(info) return invHoverOptions[db.profile.hoverTraitNames] end,
						order = 21,
						values = locHoverOptions
					},
					itemTooltipTraitDesc = {
						name = "Show Trait Descriptions:",
						desc = "When to show trait descriptions on item tooltips",
						type = "select",
						width = "single",
						set = function(info,val) db.profile.hoverTraitDesc = hoverOptions[val] end,
						get = function(info) return invHoverOptions[db.profile.hoverTraitDesc] end,
						order = 22,
						values = locHoverOptions
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
end

local function DecorateArtifact(self)
	local _, link = self:GetItem()
	if type(link) == 'string' and db.profile.enabled == true then
		local _, itemID, _, relic1, relic2, relic3, _, _, _, _, _, upgradeID = strsplit(':', link)

		if nil == itemID or '' == itemID then 
			if self:GetName() == "ItemRefTooltip" and itemRefLinkInfo[1] ~= nil and itemRefLinkInfo[1] ~= '' then
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

			-- Check options to see what to display
			local showTraitNames, showTraitDesc = false, false
			if(self:GetName() == "ItemRefTooltip") then
				-- Item Links
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
			end

			local relics = {relic1,relic2,relic3}
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

						self:AddDoubleLine(format('|cffffd400 (%s) %s|r', itemLevel or '???', gemLink or '???'), 
							format('|cff00ff00(%s)',relicType), 0, 1, 0, 0, 1, 0)

						-- Let's add the Ranks and Trait names if we are supposed to
						if showTraitNames or showTraitDesc then
							local spellLookupKey = itemID .. '.' .. relics[i]
							local traitSpellID = RelicSpells[spellLookupKey]

							if nil ~= traitSpellID then
								--Add Trait Name
								if showTraitNames == true then
									local traitName = GetSpellInfo(traitSpellID)
									if nil ~= traitName then
										-- Assuming 1 Rank per relic right now. Will have to update this if relics start giving more than 1 rank
										self:AddLine(format(' ' .. RELIC_TOOLTIP_RANK_INCREASE, 1, traitName), 1, 1, 1, false)
									end
								end
								--Add Trait Description
								if showTraitDesc == true then
									local traitDesc = GetSpellDescription(traitSpellID)
									if nil ~= traitDesc then
										traitDesc = string.gsub(traitDesc,string.char(10),"")
										traitDesc = string.gsub(traitDesc,string.char(13),"")
										self:AddLine(format('|cffff78ff  %s|r', traitDesc), 1, 1, 1, true)
									end
								end
							end
						end
					end	
				end
			end
		end	
	end
end

local function DecorateRelic(self)
	local _, link = self:GetItem()
	if type(link) == 'string' and db.profile.enabled == true then
		local _, itemID = strsplit(':', link)
		if nil == itemID or '' == itemID then return end  -- If there's no itemID we can't do anything

		if DEBUG ~=0 then print(format('ItemID: %s',itemID)) end
		local _, _, relicTypeKey = C_ArtifactUI.GetRelicInfoByItemID(tonumber(itemID))

		if nil == relicTypeKey then	return end -- If it's not a relic then we don't care

		local showOffspecs = false -- Let's assume false to start
		if invRelicOffspecOptions[db.profile.offspecsToShow] > 1 then
			-- > 1 means all or obtained (if we can get that working)
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
				self:AddLine(' ',1,1,1,false)  -- Blank line as a spacer
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
							self:AddLine(format('|cffffd200  %s|r', traitDesc), 1, 1, 1, (string.len(traitDesc) > 80))
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


ItemRefTooltip:HookScript('OnTooltipSetItem', DecorateArtifact)
GameTooltip:HookScript('OnTooltipSetItem', DecorateArtifact)
ShoppingTooltip1:HookScript('OnTooltipSetItem', DecorateArtifact)
ShoppingTooltip2:HookScript('OnTooltipSetItem', DecorateArtifact)

GameTooltip:HookScript('OnTooltipSetItem', DecorateRelic)
ItemRefTooltip:HookScript('OnTooltipSetItem', DecorateRelic)

WorldMapTooltip.ItemTooltip.Tooltip:HookScript('OnTooltipSetItem', DecorateRelic)
