local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ImprovedAddonListAddonListTooltipsItemMixin = {}

local TRANSPARENT_COLOR = CreateColor(0, 0, 0, 0)

function ImprovedAddonListAddonListTooltipsItemMixin:Update()
    local item = self:GetElementData()

    local addonInfo = item.Addon
    local iconText = Addon:CreateAddonIconText(addonInfo.IconText)

    local label
    if addonInfo.Remark and strlenutf8(addonInfo.Remark) > 0 then
        label = iconText .. " " .. WrapTextInColor("*", DISABLED_FONT_COLOR) .. addonInfo.Remark
    else
        label = iconText .. " " .. addonInfo.Title
    end
    self.Label:SetText(label)
    
    self.LockStatus:SetShown(addonInfo.IsLocked)

    local color = item.Color or TRANSPARENT_COLOR
    self.Background:SetColorTexture(color:GetRGBA())
end

local AddonListTooltipsMixin = {}

function AddonListTooltipsMixin:Init()
    self.Padding = 15
    self.ScrollBoxMaxHeight = 600
    self.ScrollBoxItemHeight = 20
    self.ScrollBoxItemWidth = 200
    self.ScrollBoxItemHorizontalSpacing = 5
    self.ScrollBoxItemVerticalSpacing = 5

    self:SetFrameStrata("TOOLTIP")
    self:SetFrameLevel(1)
    self:SetClampedToScreen(true)

    local Label = self:CreateFontString(nil, nil, "GameFontHighlight")
    self.Label = Label
    Label:SetPoint("TOP", 0, -self.Padding)
    Label:SetSpacing(4)

    local ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = ScrollBox

    local ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    self.ScrollBar = ScrollBar

    local scrollView = CreateScrollBoxListGridView(1, 0, 0, 0, 0, self.ScrollBoxItemHorizontalSpacing, self.ScrollBoxItemVerticalSpacing)
    scrollView:SetElementFactory(function(factory, node)
        local function Initializer(button, node)
            button:Update()
        end
        factory("ImprovedAddonListAddonListTooltipsItemTemplate", Initializer)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, scrollView)

    self:SetScript("OnHide", self.ReleaseOwner)
end

function AddonListTooltipsMixin:GetDataProvider()
    self.DataProvider = self.DataProvider or CreateDataProvider()
    return self.DataProvider
end

function AddonListTooltipsMixin:RefreshAddons(addons, legends, stride)
    local dataProvider = self:GetDataProvider()
    dataProvider:Flush()

    self.ScrollBox:GetView():SetStride(stride)

    if addons then
        for _, addon in ipairs(addons) do
            local color
            if addon.Legend and legends and legends[addon.Legend] then
                color = legends[addon.Legend].Color
            end
            dataProvider:Insert({ Addon = Addon:GetAddonInfoByName(addon.Name), Color = color })
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
end

function AddonListTooltipsMixin:GetOrCreateLegend(index)
    self.Legends = self.Legends or {}

    local legend = self.Legends[index]
    if not legend then
        legend = {}
        legend.Icon = self:CreateTexture()
        legend.Icon:SetSize(12, 12)
        legend.Text = self:CreateFontString(nil, nil, "GameFontWhite")
        legend.Text:SetPoint("LEFT", legend.Icon, "RIGHT", 4, 1)

        self.Legends[index] = legend
    end

    return legend
end

function AddonListTooltipsMixin:RefreshLegends(legends, stride)
    local legendsSize = 0
    if legends then
        local contentWidth = self:GetWidth() - self.Padding * 2
        local columnWidth = contentWidth / stride
        for _, legendInfo in pairs(legends) do
            legendsSize = legendsSize + 1
            local legend = self:GetOrCreateLegend(legendsSize)

            legend.Icon:SetColorTexture(legendInfo.Color:GetRGBA())
            legend.Text:SetText(legendInfo.Title)
            local legendWidth = legend.Icon:GetWidth() + legend.Text:GetStringWidth() + 4

            local row = math.floor((legendsSize - 1) / stride)
            local column = (legendsSize - 1) % stride
            local x = columnWidth * column + self.Padding + (columnWidth - legendWidth) / 2
            local y = row * 20 + self.Padding
            legend.Icon:ClearAllPoints()
            legend.Icon:SetPoint("LEFT", x, 0)
            legend.Icon:SetPoint("TOP", self.Label, "BOTTOM", 0, -(y + 4))
        end
    end

    local rows = math.ceil(legendsSize / stride)
    if rows > 0 then
        self.LegendsHeight = rows * 20 + self.Padding
    else
        self.LegendsHeight = 0
    end

    if self.Legends then
        for index, legend in ipairs(self.Legends) do
            legend.Icon:SetShown(index <= legendsSize)
            legend.Text:SetShown(index <= legendsSize)
        end
    end
end

function AddonListTooltipsMixin:SetupAddons(owner, info)
    self:SetScale(Addon:GetUIScale())

    local addonCount = info.Addons and #info.Addons or 0
    local stride = 1
    if addonCount * (self.ScrollBoxItemHeight + self.ScrollBoxItemVerticalSpacing) >= self.ScrollBoxMaxHeight then
        stride = 2
    end
    local rows = math.floor(addonCount/stride)
    local scrollBoxHeight = math.min(rows * (self.ScrollBoxItemHeight + self.ScrollBoxItemVerticalSpacing), self.ScrollBoxMaxHeight)
    self.ScrollBox:SetHeight(scrollBoxHeight)

    local scrollBarShown = false
    local scrollBarWidth = 0
    if stride > 1 and scrollBoxHeight >= self.ScrollBoxMaxHeight then
        scrollBarShown = true
        scrollBarWidth = self.ScrollBar:GetWidth() + 5
    end

    local width
    if stride == 1 then
        width = self.ScrollBoxItemWidth + self.Padding * 2 + scrollBarWidth
    else
        width = self.ScrollBoxItemWidth * 2 + self.ScrollBoxItemHorizontalSpacing + self.Padding * 2 + scrollBarWidth
    end
    self:SetWidth(width)
    self.Label:SetWidth(width - self.Padding * 2)
    self.Label:SetText(info.Label or "")
    self:RefreshLegends(info.Legends, stride)

    local height = self.Label:GetStringHeight() + self.LegendsHeight + scrollBoxHeight + self.Padding * 3
    self:SetHeight(height)

    self.ScrollBar:ClearAllPoints()
    self.ScrollBox:ClearAllPoints()
    self.ScrollBox:SetPoint("TOP", self.Label, "BOTTOM", 0, -self.Padding - self.LegendsHeight)
    self.ScrollBox:SetPoint("LEFT", self.Padding, 0)
    if scrollBarShown then
        self.ScrollBar:Show()
        self.ScrollBox:SetPoint("RIGHT", self.ScrollBar, "LEFT", -5, 0)
        self.ScrollBar:SetPoint("RIGHT", self, "RIGHT", -self.Padding, 0)
        self.ScrollBar:SetPoint("BOTTOM", self, "BOTTOM", 0, self.Padding)
        self.ScrollBar:SetPoint("TOP", self.Label, "BOTTOM", 0, -self.Padding - self.LegendsHeight)
    else
        self.ScrollBar:Hide()
        self.ScrollBox:SetPoint("RIGHT", self, "RIGHT", -self.Padding, 0)
    end

    self:RefreshAddons(info.Addons, info.Legends, stride)

    self:SetOwner(owner)

    local scaledHeight = height * self:GetEffectiveScale()
    local scaledWidth = self:GetWidth() * self:GetEffectiveScale()
    local ownerLeft = owner:GetScaledRect()
    local x, y = 0, 0
    
    local relativePoint
    local point
    
    if ownerLeft < scaledWidth then
        point = "LEFT"
        relativePoint = "RIGHT"
    else
        point = "RIGHT"
        relativePoint = "LEFT"
    end

    self:ClearAllPoints()
    self:SetPoint(point, owner, relativePoint, x, y)

    self:Show()
end

function AddonListTooltipsMixin:ReleaseOwner()
    if self.Owner then
        self.Owner:SetScript("OnMouseWheel", self.OwnerOriginMouseWheel)
    end
    self.Owner = nil
    self.OwnerOriginMouseWheel = nil
end

function AddonListTooltipsMixin:SetOwner(owner)
    self:ReleaseOwner()
    self.Owner = owner
    self.OwnerOriginMouseWheel = owner:GetScript("OnMouseWheel")

    owner:SetScript("OnMouseWheel", function(_, delta)
        local propagateToOwner = self.ScrollBox:GetWheelPanPercentage() <= 0 or (delta < 0 and self.ScrollBox:IsAtEnd()) or (delta > 0 and self.ScrollBox:IsAtBegin())

        self.ScrollBox:OnMouseWheel(delta)
        if propagateToOwner and self.OwnerOriginMouseWheel then
            self.OwnerOriginMouseWheel(_, delta)
        end
    end)
end

function Addon:ShowAddonListTooltips(owner, info)
    if self.AddonListTooltips then
        self.AddonListTooltips:SetupAddons(owner, info)
        return 
    end

    local AddonListTooltips = Mixin(CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate"), AddonListTooltipsMixin)
    self.AddonListTooltips = AddonListTooltips

    AddonListTooltips:Init()
    AddonListTooltips:SetupAddons(owner, info)
end

function Addon:HideAddonListTooltips()
    if self.AddonListTooltips then
        self.AddonListTooltips:Hide()
    end
end