-- RelicInspector.lua
-- Author: Thoralie

local addonName, addon = ...

local RelicTypeNames = addon.RelicTypes
local RelicSlotsByArtifact = addon.RelicSlots
local SpecByArtifact = addon.Artifacts

local DEBUG = 0

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

local options, optionsFrame, db

local defaults = {
	profile = {
		enabled = true,
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

local function isItemRef(self)
	return (self:GetName() == "ItemRefTooltip")
end

local function DecorateArtifact(self)
	local _, link = self:GetItem()
	if type(link) == 'string' and db.profile.enabled == true then
		local _, itemID, _, relic1, relic2, relic3, _, _, _, _, _, upgradeID = strsplit(':', link)

		-- 7.2-introduced hack for lack of proper item links (still persists in 8.0)
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
			self:AddLine(' ',1,1,1,false)  -- Blank line as a spacer
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
						
						local artifactLevelGain = C_ArtifactUI.GetItemLevelIncreaseProvidedByRelic(gemLink)

						self:AddDoubleLine(format('|cffffd400(%s) %s|r', gemLevel or '???', gemLink or '???'), 
							format('|cff00ff00(%s)',relicType), 0, 1, 0, 0, 1, 0)
						self:AddLine(format(" " .. RELIC_TOOLTIP_ILVL_INCREASE, artifactLevelGain), 1, 1, 1, false)
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

		local _, _, relicTypeKey = C_ArtifactUI.GetRelicInfoByItemID(tonumber(itemID))
		if nil == relicTypeKey then	return end -- If it's not a relic then we don't care

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

		-- Assemble the string of all specs
		local specsStr = ""
		for q = 1,#specKeys do
			local _, specName, _, _, _, classKey = GetSpecializationInfoByID(specKeys[q])
			local classColorSet = RAID_CLASS_COLORS[classKey]
			local classColor = classColorSet.colorStr
			local separator = ", "
			if q == #specKeys then separator = "" end
			local specString = format('|c%s%s|r%s',classColor,specName,separator)
			specsStr = specsStr .. specString
		end
		self:AddLine(format(ITEM_REQ_SPECIALIZATION,specsStr), 1, 1, 1, true)
	end
end

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
