---@diagnostic disable: duplicate-set-field

ItemUpgradeTipDisplayDataProviderMixin = CreateFromMixins(ItemUpgradeTipDataProviderMixin)

local itemCache = {}

function ItemUpgradeTipDisplayDataProviderMixin:OnLoad()
    ItemUpgradeTipDataProviderMixin.OnLoad(self)
    self.selectedIndexes = {}
    self.processCountPerUpdate = 200 --Reduce flickering when updating the display
    self.selectedIndexes = {}

    local function ApplyItemInfo(entry, itemLink)
        local icon = entry.itemIcon and CreateTextureMarkup(entry.itemIcon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

        entry.itemNamePretty = icon .. " " .. self:ApplyQualityColor(entry.itemName, itemLink)
    end

    -- Populate item level in any item names
    self:SetOnEntryProcessedCallback(function(entry)
        if entry.itemId == nil then
            self:NotifyCacheUsed()
            return
        end

        -- Use cached item level to reduce flickering and scroll jumping up and down
        if itemCache[entry.itemId] then
            entry.itemName, _, _, _, _, _, _, _, _, entry.itemIcon = C_Item.GetItemInfo(entry.itemId);
            ApplyItemInfo(entry, itemCache[entry.itemId])
            self:NotifyCacheUsed()
            return
        end

        local item = Item:CreateFromItemID(entry.itemId)
        item:ContinueOnItemLoad(function()
            if (not item:GetItemID()) then
                return
            end

            local itemIDr = C_Item.GetItemInfoInstant(item:GetItemID())
            if not itemIDr then
                return
            end

            entry.itemName, _, _, _, _, _, _, _, _, entry.itemIcon = C_Item.GetItemInfo(item:GetItemID());

            local itemLink = item:GetItemLink()

            if itemLink ~= nil then
                itemCache[entry.itemId] = itemLink
                ApplyItemInfo(entry, itemLink)
                self:SetDirty()
            end
        end)
    end)
end

function ItemUpgradeTipDisplayDataProviderMixin:OnShow()
    self:Refresh()
end

-- Load/refresh the current view
function ItemUpgradeTipDisplayDataProviderMixin:Refresh()
    error("This should be overridden.")
end

function ItemUpgradeTipDisplayDataProviderMixin:UniqueKey(entry)
    return tostring(entry)
end

function ItemUpgradeTipDisplayDataProviderMixin:IsSelected(index)
    return self.selectedIndexes[index] ~= nil
end

function ItemUpgradeTipDisplayDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipTableResultsRowTemplate"
end

function ItemUpgradeTipDisplayDataProviderMixin:ApplyQualityColor(name, link)
    return "|c" .. string.match(link, "|c(........)|") .. name .. "|r"
end
