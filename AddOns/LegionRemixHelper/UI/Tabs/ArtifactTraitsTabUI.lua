---@class AddonPrivate
local Private = select(2, ...)

---@class ArtifactTraitsTabUI
---@field contentFrame Frame
---@field isUICreated boolean
---@field placeholder LabelComponentObject
---@field rowsFrame Frame
local artifactTraitsTabUI = {
    contentFrame = nil,
    isUICreated = false,
    placeholder = nil,
    rowsFrame = nil,
    ---@type table<any, string>
    L = nil
}
Private.ArtifactTraitsTabUI = artifactTraitsTabUI

local const = Private.constants
local components = Private.Components

function artifactTraitsTabUI:CreateTabUI()
    local utils = Private.ArtifactTraitUtils
    local configID = utils:GetConfigID()

    local rowFrame = CreateFrame("Frame", nil, self.contentFrame)
    rowFrame:SetPoint("TOPLEFT")
    rowFrame:SetPoint("BOTTOMRIGHT", 0, 100)
    local WIDTH, HEIGHT = rowFrame:GetSize()
    self.rowsFrame = rowFrame

    local rowFrameBackground = rowFrame:CreateTexture(nil, "BACKGROUND")
    rowFrameBackground:SetAllPoints()
    rowFrameBackground:SetAtlas("spec-background")

    local specs = {}
    local activeRow = utils:GetPlayerRow()

    local function changeActive(newActive)
        if activeRow == newActive then return end
        if not specs[newActive] then return end

        local activeFrame = specs[activeRow]
        if activeFrame then
            ---@cast activeFrame SpecSelectComponentObject
            activeFrame:SetActive(false)
        end

        activeRow = newActive
        activeFrame = specs[activeRow]
        ---@cast activeFrame SpecSelectComponentObject
        activeFrame:SetActive(true)
    end

    for rowID, rowName in ipairs(utils:GetRowNames()) do
        local sW = WIDTH / 5
        local rowSelect = components.SpecSelect:CreateFrame(rowFrame, {
            name = rowName,
            onClick = function()
                changeActive(rowID)
                utils:SetRowForSpec(utils:GetSpecID(), rowID)
            end,
            onSettingsClick = function(obj)
                local ownerFrame = obj.frame
                local function GeneratorFunction(genOwner, rootDescription)
                    ---@cast rootDescription RootMenuDescriptionProxy
                    rootDescription:CreateTitle(self.L["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"])

                    for _, specID in ipairs(utils:GetSpecs()) do
                        local specName = select(2, GetSpecializationInfoByID(specID))
                        rootDescription:CreateCheckbox(specName,
                            function()
                                return utils:GetRowForSpec(specID) == rowID
                            end,
                            function()
                                utils:SetRowForSpec(specID, rowID)
                            end
                        )
                    end
                end


                MenuUtil.CreateContextMenu(ownerFrame, GeneratorFunction);
            end,
            active = (rowID == activeRow),
            width = sW,
            height = HEIGHT,
            anchors = { { "TOPLEFT", (rowID - 1) * (sW), 0 } },
        })

        specs[rowID] = rowSelect
    end

    for index, row in pairs(utils:GetRowTraits()) do
        local traitIndex = 0
        for _, nodeID in pairs(row) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            if nodeInfo and nodeInfo.entryIDs then
                local entryID = nodeInfo.entryIDs[1]
                local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                local spellID = utils:GetSpellIDFromEntryID(entryID, configID)
                if spellID and (entryInfo.type == Enum.TraitNodeEntryType.SpendCircle or entryInfo.type == Enum.TraitNodeEntryType.SpendSquare) then
                    traitIndex = traitIndex + 1
                    local circle = components.RoundedIcon:CreateFrame(specs[index].frame, {
                        width = 40,
                        height = 40,
                        anchors = {
                            { "TOP", specs[index].sample, "BOTTOM", 0, (10 + (45 * (traitIndex - 1))) * -1 - 10 },
                        },
                        show_tooltip = true,
                        frame_strata = "HIGH"
                    })
                    local spell = Spell:CreateFromSpellID(spellID)
                    spell:ContinueOnSpellLoad(function()
                        circle:SetLink(C_Spell.GetSpellLink(spellID))
                        circle:SetTexture(C_Spell.GetSpellTexture(spellID))
                    end)
                end
            end
        end
        index = index + 1
    end

    local bottomBar = self.contentFrame:CreateTexture()
    bottomBar:SetPoint("BOTTOMLEFT", 0, 0)
    bottomBar:SetPoint("TOPRIGHT", rowFrame, "BOTTOMRIGHT", 0, 0)
    bottomBar:SetAtlas("talents-background-bottombar", true)

    for i, slotInfo in ipairs(utils:GetJewelrySlots()) do
        local slotName = _G["INVTYPE_" .. slotInfo.NAME]
        ---@class JewelrySlotSwitcher : NodeIconComponentObject
        local jewelery = components.NodeIcon:CreateFrame(self.contentFrame, {
            anchors = {
                { "LEFT", bottomBar, "LEFT", (i - 1) * 70 + 15, 0 },
            },
            show_tooltip = true,
            onClick = function(jeweleryObj)
                local function GeneratorFunction(genOwner, rootDescription)
                    ---@cast rootDescription RootMenuDescriptionProxy
                    rootDescription:CreateTitle(slotName)

                    local highestItems = utils:GetJewelryBySlot(slotInfo.INV_TYPE)
                    for _, itemInfo in ipairs(highestItems) do
                        rootDescription:CreateButton(utils:GetJewelryTooltip(itemInfo.location), function()
                            utils:EquipJewelryForSlot(itemInfo.location, slotInfo.SLOT)
                        end)
                    end
                end


                MenuUtil.CreateContextMenu(jeweleryObj.frame, GeneratorFunction);
            end,
            tooltipTextGetter = function()
                return utils:GetJewelryTooltip(utils:GetEquippedJewelryBySlot(slotInfo.SLOT))
            end,
        })
        jewelery.Slot = slotInfo.SLOT

        local function UpdateJewelrySlot()
            local equippedItem = utils:GetEquippedJewelryBySlot(jewelery.Slot)
            if equippedItem then
                jewelery:SetState("SELECT")
                jewelery:SetIconTexture(C_Item.GetItemIcon(equippedItem))

                local itemID = C_Item.GetItemID(equippedItem)
                if itemID then
                    local entryID = utils:GetEntryIDFromItemID(itemID)
                    if entryID then
                        local spellID = utils:GetSpellIDFromEntryID(entryID, configID)
                        if spellID then
                            jewelery:SetIconTexture(C_Spell.GetSpellTexture(spellID))
                        end
                    end
                end
            else
                jewelery:SetState("EMPTY")
            end
        end
        UpdateJewelrySlot()
        utils:AddCallback(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_EQUIPPED, UpdateJewelrySlot)
    end

    self.contentFrame:HookScript("OnShow", function()
        changeActive(utils:GetActiveRowID())
    end)

    utils:AddCallback(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_ROW, function()
        changeActive(utils:GetActiveRowID())
    end)
end

function artifactTraitsTabUI:ShowPlaceholder()
    if not self.placeholder then
        local placeholder = components.Label:CreateFrame(self.contentFrame, {
            text = self.L["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"],
            color = const.COLORS.LIGHT_GREY,
            justifyH = "CENTER",
            justifyV = "MIDDLE",
            anchors = {
                { "TOPLEFT" },
                { "BOTTOMRIGHT" },
            },
            font = "GameFontHighlightHuge2"
        })
        self.placeholder = placeholder
    end
    self.placeholder.frame:Show()
end

---@return boolean hasArtifact
function artifactTraitsTabUI:HasArtifactEquipped()
    for _, slot in pairs(const.INV_SLOT) do
        if C_RemixArtifactUI.ItemInSlotIsRemixArtifact(slot) then
            return true
        end
    end
    return false
end

function artifactTraitsTabUI:HandleShowUI()
    if self:HasArtifactEquipped() then
        if not self.isUICreated then
            self:CreateTabUI()
            self.isUICreated = true
        end
        self.rowsFrame:Show()
        if self.placeholder then
            self.placeholder.frame:Hide()
        end
        return
    end
    if self.rowsFrame then
        self.rowsFrame:Hide()
    end
    self:ShowPlaceholder()
end

---@param contentFrame Frame
function artifactTraitsTabUI:Init(contentFrame)
    self.L = Private.L
    self.contentFrame = contentFrame

    Private.Addon:RegisterEvent("WEAPON_SLOT_CHANGED", "ArtifactTraitsTabUI_WeaponSlotChanged", function()
        self:HandleShowUI()
    end)

    contentFrame:HookScript("OnShow", function()
        self:HandleShowUI()
    end)
end

Comps = components
