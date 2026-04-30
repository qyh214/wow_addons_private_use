local _, core = ...

TraitsTreeFrameMixin = {}
function TraitsTreeFrameMixin:OnLoad()
	self:SetTabs(self.TraitsInset, 4, MURLOKEXPORT_TRAITS_CLASS, MURLOKEXPORT_TRAITS_SPECIALIZATION, MURLOKEXPORT_TRAITS_HERO, MURLOKEXPORT_TRAITS_PVP)
end

function TraitsTreeFrameMixin:OnShow()
	self:SelectedTabOnClick()
end

function TraitsTreeFrameMixin:SetPreviewMode(previewMode)
	self.traits.previewMode = previewMode
	self.TalentImportButton:SetEnabled(previewMode)
end

function TraitsTreeFrameMixin:GetPreviewMode()
	return self.traits.previewMode
end

function TraitsTreeFrameMixin:OnClick(hero_atlas)
	self:SetPreviewMode(false)
	self.traits.HeroTalentsContainer.HeroSpecButton.Icon:SetAtlas(hero_atlas)
	self:SelectedTabOnClick()
end

function TraitsTreeFrameMixin:SelectedTabOnClick()
	local tabId = 1
	if self.TraitsInset.selectedTab and self.TraitsInset.selectedTab > 0 then
		tabId = self.TraitsInset.selectedTab
	end
	self:TabOnClick(_G[self.TraitsInset:GetName() .. "TraitsTab" .. tabId])
end

function TraitsTreeFrameMixin:TabOnClick(tab)
	self.traits.tabId = tab:GetID()
	PanelTemplates_SetTab(self.TraitsInset, tab:GetID())

	if not UIMurlokExport.ClassListFrame.activeSpecId or not UIMurlokExport.ClassListFrame.activeStats then
		return
	end

	self.traits.HeroTalentsContainer:SetShown(tab:GetID() == 3)
	self.traits.PvPTraits:SetShown(tab:GetID() == 4)
	self.traits.ReloadButton:SetShown(false)

	if tab:GetID() ~= 4 then
		local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
		self.traits:SetConfigID(configId)
		self.traits:SetTalentTreeID(C_ClassTalents.GetTraitTreeForSpec(UIMurlokExport.ClassListFrame.activeSpecId), true)
	else
		self.traits:ReleaseAllTalentButtons()
		self.traits.PvPTraits:Update()
	end
end

function TraitsTreeFrameMixin:SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs

	local frameName = frame:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName .. "TraitsTab" .. i, frame, "PanelTopTabButtonTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", function() self:TabOnClick(tab) end)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 36)
		else
			tab:SetPoint("TOPLEFT", _G[frameName .. "TraitsTab" .. (i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

TalentImportButtonMixin = {}
function TalentImportButtonMixin:OnLoad()
	local prefix = "hud-microbutton-"
	local name = "Talents"
	self:SetNormalAtlas(prefix..name.."-Up")
	self:SetPushedAtlas(prefix..name.."-Down")
	self:SetDisabledAtlas(prefix..name.."-Disabled")
	self:ClearHighlightTexture()
end

function TalentImportButtonMixin:OnClick()
	local mode = UIMurlokExport.ClassListFrame.selectedTab.displayMode
	local function callback()
		EventRegistry:UnregisterCallback("PlayerSpellsFrame.CloseFrame", self)
		core:Toggle()
	end
	EventRegistry:RegisterCallback("PlayerSpellsFrame.CloseFrame", callback, self)
	PlayerSpellsFrame:Show()
	PlayerSpellsFrame:SetTab(PlayerSpellsFrame.talentTabID)
	UIMurlokExport:Hide()

	ClassTalentLoadoutImportDialog:ShowDialog()
	ClassTalentLoadoutImportDialog.ImportControl:SetText(UIMurlokExport.TraitsTreeFrame.traits.importText)
	ClassTalentLoadoutImportDialog.NameControl:SetText("ME_" .. mode .. "_" .. date("%Y-%m-%dT%H:%M"))

	-- 	-- fix Blizzards casting bar bug
	-- 	PlayerSpellsFrame.TalentsFrame.enableCommitEndFlash = false
	-- 	PlayerSpellsFrame.TalentsFrame.enableCommitSpinner = false
	-- 	PlayerSpellsFrame.TalentsFrame.enableCommitCastBar = false
	-- 	PlayerSpellsFrame.TalentsFrame:ImportLoadout(self.talentBox.EditBox:GetText(), "ME_" .. mode .. date("%Y-%m-%dT%H:%M"))
end

PvPTraitsButtonMixin = {}
function PvPTraitsButtonMixin:Init(elementData)
	self.talentId = elementData.talentId
	self.talentInfo = C_SpecializationInfo.GetPvpTalentInfo(elementData.talentId)
	if self.talentInfo == nil then
		return
	end

	self.Name:SetText(self.talentInfo.name)
	self.Icon:SetTexture(self.talentInfo.icon)
	if elementData.count > 0 then
		self.SpendText:SetText(core:GetRankColor(elementData.rank) .. elementData.count .. "|r")
		self.Icon:SetDesaturated(false)
	else
		self.SpendText:SetText(nil)
		self.Icon:SetDesaturated(true)
	end
	self.SpendText:SetScale(0.7)

	if GameTooltip:GetOwner() == self then
		self:OnEnter()
	end
end

function PvPTraitsButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetPvpTalent(self.talentId, true)
	GameTooltip:Show()
end

PvPTraitsMixin = {}
function PvPTraitsMixin:OnLoad()
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("PvPTraitsButtonTemplate", function(button, elementData) button:Init(elementData) end)
	view:SetPadding(1, 0, 0, 0, PVP_TALENT_LIST_BUTTON_OFFSET)

	self.ScrollBox:Init(view)
end

function PvPTraitsMixin:Update()
	local dataProvider = CreateDataProvider()
	local traits = UIMurlokExport.ClassListFrame.activeStats['traits']['pvp']
	for talentId, data in core:IPairs(traits, function (k1, k2) return k1[2].count > k2[2].count end) do
		if data then
			dataProvider:Insert({talentId=talentId, count=data.count, rank=data.rank})
		else
			dataProvider:Insert({talentId=talentId, count=0, rank=-1})
		end
	end
	self.ScrollBox:SetDataProvider(dataProvider)
end

function PvPTraitsMixin:OnShow()
	self.ScrollBox:ScrollToBegin()
end

TraitsFrameMixin = CreateFromMixins(TalentFrameBaseMixin)
local heroMinC = 10
local heroMaxCol = 13
function TraitsFrameMixin:ShouldInstantiateNode(nodeId, nodeInfo)
	if nodeInfo.subTreeID then
		local heroId = UIMurlokExport.ClassListFrame.activeHeroId
		nodeInfo.subTreeActive = heroId == nodeInfo.subTreeID
		return nodeInfo.isVisible and self.requiredNodeIds[nodeId] and nodeInfo.subTreeActive
	end
	return nodeInfo.isVisible and self.requiredNodeIds[nodeId]
end

local CLASS_OFFSETS = {
    [1] = { x = 30, y = 31, }, -- Warrior
    [2] = { x = -60, y = -29, }, -- Paladin
    [3] = { x = 0, y = -29, }, -- Hunter
    [4] = { x = 30, y = -29, }, -- Rogue
    [5] = { x = -30, y = -29, }, -- Priest
    [6] = { x = 0, y = 1, }, -- DK
    [7] = { x = 0, y = 1, }, -- Shaman
    [8] = { x = 30, y = -29, }, -- Mage
    [9] = { x = 0, y = 1, }, -- Warlock
    [10] = { x = 0, y = -29, }, -- Monk
    [11] = { x = 30, y = -29, }, -- Druid
    [12] = { x = 30, y = -29, }, -- Demon Hunter
    [13] = { x = 30, y = -29, }, -- Evoker
}
-- taken from ClassTalentTalentsTabTemplate XML
local BASE_PAN_OFFSET_X = 4
local BASE_PAN_OFFSET_Y = -30

local roundingFactor = 100
local function Round(coordinate)
    return math.floor((coordinate / roundingFactor) + 0.5) * roundingFactor
end

local function GetGridLineFromCoordinate(start, spacing, halfwayEnabled, coordinate)
    local bucketSpacing = halfwayEnabled and (spacing / 4) or (spacing / 2)
    -- breaks out at 25, which is well above the expected max
    for testLine = 1, 25, (halfwayEnabled and 0.5 or 1) do
        local bucketStart = (start - spacing) + (spacing * testLine) - bucketSpacing
        local bucketEnd = bucketStart + (bucketSpacing * 2)
        if coordinate >= bucketStart and coordinate < bucketEnd then
            return testLine
        end
    end

    return nil
end

local isMidnight = select(4, GetBuildInfo()) >= 120000
local function GetNodeGridPosition(configId, classId, nodeInfo)
    local posX = nodeInfo.posX
	local posY = nodeInfo.posY

    local offsetX = BASE_PAN_OFFSET_X - (CLASS_OFFSETS[classId] and CLASS_OFFSETS[classId].x or 0)
    local offsetY = BASE_PAN_OFFSET_Y - (CLASS_OFFSETS[classId] and CLASS_OFFSETS[classId].y or 0)

    local rawX, rawY = posX, posY

    posX = (Round(posX) / 10) - offsetX
    posY = (Round(posY) / 10) - offsetY
    local colSpacing = 60
    local subTreeColSpacing = colSpacing * 10
    local subTreeColOffset = 9

    local row, col
    local subTreeID = nodeInfo and nodeInfo.subTreeID

    if subTreeID then
        local subTreeInfo = C_Traits.GetSubTreeInfo(configId, subTreeID)
        if subTreeInfo then
            local topCenterPosX = subTreeInfo.posX
            local topCenterPosY = subTreeInfo.posY

            local colStart = topCenterPosX - (subTreeColSpacing * (isMidnight and 1.5 or 1))
            local halfColEnabled = true
            col = subTreeColOffset + (GetGridLineFromCoordinate(colStart, subTreeColSpacing, halfColEnabled, rawX) or 0)

            local rowStart = topCenterPosY
            local rowSpacing = 2400 / 4 -- 2400 is generally the height of a sub tree, 4 is number of "gaps" between 5 rows
            local halfRowEnabled = false
            row = GetGridLineFromCoordinate(rowStart, rowSpacing, halfRowEnabled, rawY) or 0
        end
    elseif nodeInfo and nodeInfo.isSubTreeSelection then
        col = 10
        row = 5.5
    end
    if not row or not col then
        local colStart = 176
        local halfColEnabled = true
        local classColEnd = 656
        local specColStart = 956
        local subTreeOffset = (isMidnight and 4 or 3) * colSpacing
        local classSpecGap = (specColStart - classColEnd) - subTreeOffset
        if (posX > (classColEnd + (classSpecGap / 2))) then
            posX = posX - classSpecGap + colSpacing
        end
        col = GetGridLineFromCoordinate(colStart, colSpacing, halfColEnabled, posX)

        local rowStart = 151
        local rowSpacing = 60
        local halfRowEnabled = false
        row = GetGridLineFromCoordinate(rowStart, rowSpacing, halfRowEnabled, posY)
    end

    return col, row
end

local function CompareTrait(previewMode, spendValue, spendValueCompare, rankColorCompare)
	local state = TalentButtonUtil.BaseVisualState.Normal
	local compareText = ''
	if previewMode then
		if spendValue < (spendValueCompare or 0) then
			compareText = ERROR_COLOR:GenerateHexColorMarkup() .. '≠|r' .. rankColorCompare .. (spendValueCompare or 0) .. "|r"
			state = TalentButtonUtil.BaseVisualState.DisplayError
		elseif spendValue > (spendValueCompare or 0) then
			compareText = INCREASE_STAT_COLOR:GenerateHexColorMarkup() .. '≠|r' .. rankColorCompare .. (spendValueCompare or 0) .. "|r"
			state = TalentButtonUtil.BaseVisualState.Selectable
		-- else
		-- 	compareText = INCREASE_STAT_COLOR:GenerateHexColorMarkup() .. '=|r' .. rankColorCompare .. (spendValueCompare or 0) .. "|r"
		-- 	state = TalentButtonUtil.BaseVisualState.Selectable
		end
	end
	return previewMode and compareText or '', state
end

function TraitsFrameMixin:PreviewTraits(importText)
	self.importText = importText
	UIMurlokExport.TraitsTreeFrame:SetPreviewMode(true)

	local talentFrame = PlayerSpellsFrame.TalentsFrame
	local importStream = ExportUtil.MakeImportDataStream(importText)
	local headerValid, serializationVersion, specId = PlayerSpellsFrame.TalentsFrame:ReadLoadoutHeader(importStream)
	local currentSerializationVersion = C_Traits.GetLoadoutSerializationVersion()
	if(not headerValid or serializationVersion ~= currentSerializationVersion or specId ~= PlayerUtil.GetCurrentSpecID()) then
		self:ReleaseAllTalentButtons()
		UIMurlokExport.ClassListFrame.activeStats = {['traits']= {['class'] = {}, ['spec'] = {}, ['hero'] = {}, ['pvp'] = {}}}
		return
	end

	local treeInfo = C_Traits.GetTreeInfo(talentFrame:GetConfigID(), talentFrame:GetTalentTreeID())
	local configId = talentFrame:GetConfigID()

	local loadoutContent = talentFrame:ReadLoadoutContent(importStream, treeInfo.ID)
	local loadoutInfos = talentFrame:ConvertToImportLoadoutEntryInfo(configId, treeInfo.ID, loadoutContent)
	local selectedEntryInfo = {}
	for _, loadoutInfo in ipairs(loadoutInfos) do
		local definitionId = C_Traits.GetEntryInfo(configId, loadoutInfo.selectionEntryID).definitionID
		if definitionId then
			selectedEntryInfo[definitionId] = {['count'] = loadoutInfo.ranksPurchased + loadoutInfo.ranksGranted, ['rank'] = 2}
		end
	end

	local activeTraits = {['class'] = {}, ['spec'] = {}, ['hero'] = {}, ['pvp'] = {}}
	local configId = C_ClassTalents.GetActiveConfigID()
	for k, nodeId in ipairs(C_Traits.GetTreeNodes(self:GetTalentTreeID())) do
		local nodeInfo = C_Traits.GetNodeInfo(configId, nodeId)
		local col, row = GetNodeGridPosition(configId, UIMurlokExport.ClassListFrame.activeClassId, nodeInfo)
		local category = nil
		if col and col < heroMinC then
			category = 'class'
		elseif col and col > heroMaxCol then
			category = 'spec'
		elseif nodeInfo.subTreeID then
			category = 'hero'
		end
		if category then
			for i, entryId in core:IPairs(nodeInfo.entryIDs) do
				local entryInfo = C_Traits.GetEntryInfo(configId, entryId)
				if entryInfo.definitionID then
					local trait = nil
					if (tContains(nodeInfo.entryIDsWithCommittedRanks, entryId) or row == 11) then
						trait =  {['count'] = nodeInfo.currentRank, ['rank'] = 6}
					else
						trait =  {['count'] = 0, ['rank'] = 6}
					end
					local entryInfoCompare = selectedEntryInfo[entryInfo.definitionID]
					if entryInfoCompare then
						trait['countCompare'] = entryInfoCompare['count']
						trait['rankCompare'] = entryInfoCompare['rank']
					end
					if category then
						activeTraits[category][entryInfo.definitionID] = trait
					end
				end
			end
		end
	end
	for _, talentId in ipairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do
		activeTraits['pvp'][talentId] = {['count'] = 1, ['rank'] = 6}
	end

	UIMurlokExport.ClassListFrame.activeStats = {['traits']= activeTraits}
end

function TraitsFrameMixin:LoadTalentTreeInternal()
	local traitsCategories = {'class', 'spec', 'hero'}
	local activeTab = traitsCategories[self.tabId]
	local traits = UIMurlokExport.ClassListFrame.activeStats['traits'][activeTab]
	local specId = UIMurlokExport.ClassListFrame.activeSpecId

    C_ClassTalents.InitializeViewLoadout(specId, core.MAX_LEVEL)
    C_ClassTalents.ViewLoadout({})

	local requiredNodeIds = {}
	for k, nodeId in ipairs(C_Traits.GetTreeNodes(self:GetTalentTreeID())) do
		local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeId)
		local col, row = GetNodeGridPosition(self:GetConfigID(), UIMurlokExport.ClassListFrame.activeClassId, nodeInfo)
		local heroId = UIMurlokExport.ClassListFrame.activeHeroId
		if col and row and (activeTab == 'class' and col < heroMinC or activeTab == 'spec' and (col > heroMaxCol or row == 11) or activeTab == 'hero' and nodeInfo.subTreeID == heroId and (col >= heroMinC and col <= heroMaxCol)) then
			requiredNodeIds[nodeId] = nodeInfo
			for _, entryId in ipairs(nodeInfo.entryIDs) do
				local entryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), entryId)
				if entryInfo and entryInfo.definitionID and traits[entryInfo.definitionID] == nil then
					traits[entryInfo.definitionID] = {['count'] = 0, ['rank'] = -1}
				end
			end
		end
	end

	if core:TableLength(requiredNodeIds) == 0 then
		self:ReleaseAllTalentButtons()
		self:ClearInfoCaches()
		self.ReloadButton:SetShown(true)
		self.HeroTalentsContainer:SetShown(false)
		return
	end

	self.requiredNodeIds = requiredNodeIds
	TalentFrameBaseMixin.LoadTalentTreeInternal(self)

	local zoomFactor = 0.68
	self:SetZoomLevelInternal(zoomFactor)
	self:DisableZoomAndPan()
	self.gatePool:ReleaseAll()
	self.HeroTalentsContainer:SetScale(0.78)

	local minX = nil
	local maxY = nil
	local maxX = nil
	local minY = nil

	for _, button in pairs(self.nodeIDToButton) do
		local _, _, _, offsetX, offsetY = button:GetPointByName("CENTER")
		if minX == nil or math.abs(offsetX) < minX then minX = math.abs(offsetX) end
		if maxY == nil or math.abs(offsetY) > maxY then maxY = math.abs(offsetY) end
		if maxX == nil or math.abs(offsetX) > maxX then maxX = math.abs(offsetX) end
		if minY == nil or math.abs(offsetY) < minY then minY = math.abs(offsetY) end

		button:SetVisualState(TalentButtonUtil.BaseVisualState.Locked)

		button.SpendText:ClearAllPoints()
		if true or self.previewMode then
			button.SpendText:SetJustifyH("CENTER")
			button.SpendText:SetPoint("BOTTOM", button, "BOTTOM", 5, -10)
		else
			button.SpendText:SetJustifyH("LEFT")
			button.SpendText:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", -15, -5)
		end
		TalentButtonUtil.SetSpendText(button, nil)

		local firstSpendValue
		local firstRankColor
		local firstSpendValueCompare
		local firstRankColorCompare
		for i, entryId in ipairs(button.nodeInfo.entryIDs) do
			local entryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), entryId)
			local trait = traits[entryInfo.definitionID]
			if entryInfo and entryInfo.definitionID and trait then
				if trait.count > 0 or (trait.countCompare or 0) > 0 or #button.nodeInfo.entryIDs >= 2 then
					if i == 1 then
						firstSpendValue = trait.count or 0
						firstRankColor = core:GetRankColor(trait.rank) or self.previewMode and core:GetRankColor(6) or core:GetRankColor(-1)
						firstSpendValueCompare = trait.countCompare or 0
						firstRankColorCompare = core:GetRankColor(trait.rankCompare or 2)
					elseif #button.nodeInfo.entryIDs == 3 then
						firstSpendValueCompare = firstSpendValueCompare + (trait.countCompare or 0)
					end
					if #button.nodeInfo.entryIDs == 1 and (firstSpendValue > 0 or firstSpendValueCompare > 0) then
						local compareText, state = CompareTrait(self.previewMode, firstSpendValue, firstSpendValueCompare, firstRankColorCompare)
						TalentButtonUtil.SetSpendText(button, firstRankColor .. firstSpendValue .. "|r" .. compareText)
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
						button:UpdateStateBorder(state)
					elseif #button.nodeInfo.entryIDs == 2 and i == 2 and (firstSpendValue > 0 or firstSpendValueCompare > 0 or trait.count > 0 or (trait.countCompare or 0) > 0) then
						local firstCompareText, firstState = CompareTrait(self.previewMode, firstSpendValue, firstSpendValueCompare, firstRankColorCompare)
						local compareText, state = CompareTrait(self.previewMode, trait.count, trait.countCompare, core:GetRankColor(trait.rankCompare or 2))
						local separator = "||" --self.previewMode and "\r\n" or 
						TalentButtonUtil.SetSpendText(button, firstRankColor .. firstSpendValue .. "|r" .. firstCompareText .. separator .. core:GetRankColor(trait.rank) .. trait.count .. "|r" .. compareText)
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
						if firstState ~= TalentButtonUtil.BaseVisualState.Normal and state == TalentButtonUtil.BaseVisualState.Normal then
							button:UpdateStateBorder(firstState)
						elseif firstState == TalentButtonUtil.BaseVisualState.Normal and state ~= TalentButtonUtil.BaseVisualState.Normal then
							button:UpdateStateBorder(state)
						elseif firstState ~= TalentButtonUtil.BaseVisualState.Normal and state ~= TalentButtonUtil.BaseVisualState.Normal then
							button.StateBorder:SetAtlas(button.artSet.ghost, TextureKitConstants.UseAtlasSize)
						end
					elseif #button.nodeInfo.entryIDs == 3 and i == 3 and (firstSpendValue > 0 or firstSpendValueCompare > 0) then
						local compareText, state = CompareTrait(self.previewMode, firstSpendValue, firstSpendValueCompare, firstRankColorCompare)
						TalentButtonUtil.SetSpendText(button, firstRankColor .. firstSpendValue .. "|r" .. compareText)
						button.SpendText:ClearAllPoints()
						button.SpendText:SetPoint("BOTTOM", button, "BOTTOM", 5, 9)
						button.SpendText:Show()
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
						button:UpdateStateBorder(state)
					end
				end
			end
		end
	end

	if minX and maxX and minY and maxY then
		local dX = (self.ButtonsParent:GetWidth() - math.abs(maxX - minX))/2
		local dY = (self.ButtonsParent:GetHeight() - math.abs(maxY - minY))/2
		for _, button in pairs(self.nodeIDToButton) do
			button:AdjustPointsOffset(-minX + dX, minY - dY)
		end
	end
end

function TraitsFrameMixin:IsInspecting()
	return true
end

function TraitsFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self)
end

function TraitsFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self)
end

function TraitsFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self)
end

function TraitsFrameMixin:OnUpdate()
	-- 1.4.0: suppress TalentFrameBaseMixin.OnUpdate() to prevent reset of talent buttons
	self:SetScript("OnUpdate", nil)
	for button, isDirty in pairs(self.buttonsWithDirtyEdges) do
		if isDirty then
			self:UpdateEdgesForButton(button)
		end
	end
end

function TraitsFrameMixin:OnEvent(event, ...)
	-- 1.3.0: commented out. resets all talent buttons in ME if any talent is changed
	-- TalentFrameBaseMixin.OnEvent(self, event, ...)
end

function TraitsFrameMixin:ReleaseAllTalentButtons()
	TalentFrameBaseMixin.ReleaseAllTalentButtons(self)
end
