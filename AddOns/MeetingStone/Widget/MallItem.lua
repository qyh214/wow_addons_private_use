
BuildEnv(...)

local MallItem = Addon:NewClass('MallItem', GUI:GetClass('ItemButton'))

GUI:Embed(MallItem, 'Refresh')

function MallItem:Constructor(parent)
    local Background = self:CreateTexture(nil, 'BACKGROUND') do
        Background:SetTexture([[Interface\Store\Store-Main]])
        Background:SetTexCoord(0.18457031, 0.32714844, 0.64550781, 0.84960938)
        Background:SetAllPoints(true)
    end

    local Shadows = self:CreateTexture(nil, 'BACKGROUND', nil, 2) do
        Shadows:SetTexture([[Interface\Store\Store-Main]])
        Shadows:SetTexCoord(0.84375000, 0.97851563, 0.29980469, 0.37011719)
        Shadows:SetSize(138, 72)
        Shadows:SetPoint('CENTER')
    end

    local Icon = self:CreateTexture(nil, 'ARTWORK') do
        Icon:SetSize(63, 63)
        Icon:SetPoint('TOP', 0, -36)
        local IconBorder = self:CreateTexture(nil, 'ARTWORK', nil, 2)
        IconBorder:SetTexture([[Interface\Store\Store-Main]])
        IconBorder:SetTexCoord(0.84375000, 0.92187500, 0.37207031, 0.45117188)
        IconBorder:SetSize(80, 81)
        IconBorder:SetPoint('CENTER', Icon, 0, -3)

        local org_SetShown = Icon.SetShown
        Icon.SetShown = function(_, enable)
            org_SetShown(Icon, enable)
            IconBorder:SetShown(enable)
        end
    end

    local Price = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2', 3) do
        Price:SetPoint('BOTTOM', 0, 30)
    end

    local SalePrice = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2', 3) do
        SalePrice:SetPoint('BOTTOMLEFT', self, 'BOTTOM', 2, 30)
        SalePrice:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        SalePrice:Hide()
    end

    local Strikethrough = self:CreateTexture(nil, 'OVERLAY') do
        Strikethrough:SetTexture([[Interface\Store\Store-Main]])
        Strikethrough:SetTexCoord(0.93457031, 0.96582031, 0.14257813, 0.15234375)
        Strikethrough:SetSize(32, 10)
        Strikethrough:SetPoint('TOPLEFT', Price, -2, 0)
        Strikethrough:SetPoint('BOTTOMRIGHT', Price, 2, 0)
        Strikethrough:Hide()
    end

    local Name = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed3') do
        Name:SetSize(120, 40)
        Name:SetPoint('BOTTOM', 0, 42)
        Name:SetTextColor(1, 1, 1, 1)
    end

    local CheckedTexture = self:CreateTexture(nil, 'ARTWORK', nil, 1) do
        CheckedTexture:SetTexture([[Interface\Store\Store-Main]])
        CheckedTexture:SetTexCoord(0.37011719, 0.50683594, 0.74218750, 0.94042969)
        CheckedTexture:SetBlendMode('ADD')
        CheckedTexture:SetPoint('CENTER')
        CheckedTexture:Hide()
    end

    local HighlightTexture = self:CreateTexture(nil, 'ARTWORK', nil, 2) do
        HighlightTexture:SetTexture([[Interface\Store\Store-Main]])
        HighlightTexture:SetTexCoord(0.37011719, 0.50683594, 0.54199219, 0.74023438)
        HighlightTexture:SetBlendMode('ADD')
        HighlightTexture:SetPoint('CENTER')
        HighlightTexture:Hide()
    end

    local Model = CreateFrame('PlayerModel', nil, self) do
        Model:SetSize(126, 124)
        Model:SetPoint('BOTTOM', 0, 80)
    end

    local Magnifier = CreateFrame('Button', nil, self) do
        Magnifier:SetSize(31, 35)
        Magnifier:SetPoint('TOPLEFT', 8, -8)
        Magnifier:SetNormalTexture([[Interface\Store\Store-Main]])
        Magnifier:GetNormalTexture():SetSize(31, 35)
        Magnifier:GetNormalTexture():SetTexCoord(0.32910156, 0.35937500, 0.72363281, 0.75781250)
        Magnifier:SetHighlightTexture([[Interface\Store\Store-Main]], 'ADD')
        Magnifier:GetHighlightTexture():SetSize(31, 35)
        Magnifier:GetHighlightTexture():SetTexCoord(0.32910156, 0.35937500, 0.72363281, 0.75781250)
        Magnifier:Hide()
        Magnifier:SetScript('OnEnter', function()
            self:SetMagnifier(true)
        end)
        Magnifier:SetScript('OnLeave', function()
            self:SetMagnifier(false)
        end)
        Magnifier:SetScript('OnClick', function()
            if not self.model then
                return
            end
            local frame = ModelPreviewFrame
            ModelPreviewFrame_ShowModel(self.model, true)
            frame.Display.Name:SetText(self.text)
        end)
    end

    local Discount = CreateFrame('Frame', nil, self) do
        Discount:SetFrameLevel(Model:GetFrameLevel() + 1)
        Discount:SetPoint('TOPRIGHT', 1, -2)
        Discount:SetSize(32,32)
        Discount:Hide()

        local DiscountRight = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountRight:SetTexture([[Interface\Store\Store-Main]])
        DiscountRight:SetTexCoord(0.98828125, 0.99609375, 0.19921875, 0.23046875)
        DiscountRight:SetSize(8, 32)
        DiscountRight:SetPoint('TOPRIGHT', 1, -2)

        local DiscountLeft = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountLeft:SetTexture([[Interface\Store\Store-Main]])
        DiscountLeft:SetTexCoord(0.98828125, 0.99609375, 0.10546875, 0.13671875)
        DiscountLeft:SetSize(8, 32)
        DiscountLeft:SetPoint('TOPLEFT', -1, -2)

        local DiscountMiddle = Discount:CreateTexture(nil, 'ARTWORK', nil, 3)
        DiscountMiddle:SetTexture([[Interface\Store\Store-Main]])
        DiscountMiddle:SetTexCoord(0.32910156, 0.36230469, 0.69042969, 0.72167969)
        DiscountMiddle:SetSize(34, 32)
        DiscountMiddle:SetPoint('RIGHT', DiscountRight, 'LEFT', 0, 0)
        DiscountMiddle:SetPoint('LEFT', DiscountLeft, 'RIGHT', 0, 0)

        local Text = Discount:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed2')
        Text:SetPoint('CENTER', DiscountMiddle, 1, 2)
        Text:SetTextColor(1, 1, 1)

        Discount.SetText = function(_, text)
            Text:SetText(text)
            Discount:SetWidth(Text:GetStringWidth() + 20)
        end
    end

    self:SetScript('OnEvent', self.Refresh)

    self:SetCheckedTexture(CheckedTexture)
    self:SetHighlightTexture(HighlightTexture)

    self.Price = Price
    self.Icon = Icon
    self.Shadows = Shadows
    self.Model = Model
    self.Magnifier = Magnifier
    self.Name = Name
    self.Strikethrough = Strikethrough
    self.SalePrice = SalePrice
    self.Discount = Discount

    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function MallItem:OnSizeChanged(width, height)
    self:GetHighlightTexture():SetSize(width-6, height-6)
    self:GetCheckedTexture():SetSize(width-6, height-6)
end

function MallItem:IsMagnifierShown()
    return self.model
end

function MallItem:SetMagnifier(enable)
    if self:IsMagnifierShown() then
        self.Magnifier:SetShown(enable)
    else
        self.Magnifier:SetShown(false)
    end
end

function MallItem:SetPrice(price, originalPrice)
    self.price, self.originalPrice = price, originalPrice
    self:Refresh()
end

function MallItem:SetText(text)
    self.text = text
    self:Refresh()
end

function MallItem:SetModel(id)
    self.model = id
    self:Refresh()
end

function MallItem:SetItem(id)
    self.item = id
    self:Refresh()
end

function MallItem:SetIcon(icon)
    self.icon = icon
    self:Refresh()
end

function MallItem:SetStartTime(hour)
    self.hour = hour
    self:Refresh()
end

function MallItem:SetCurrency(currency)
    self.currency = currency
    self:Refresh()
end

function MallItem:Update()
    if self.item then
        local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, icon = GetItemInfo(self.item)
        if name then
            self:UnregisterAllEvents()
            self.text = name
            self.icon = icon
        else
            self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
            self.text = RED_FONT_COLOR_CODE .. RETRIEVING_ITEM_INFO .. '|r'
            self.icon = GetItemIcon(self.item)
        end
    end

    self.Model:SetShown(self.model)
    self.Icon:SetShown(not self.model)

    if self.model then
        self.Model:SetDisplayInfo(self.model)
        self.Model:SetDoBlend(false)
        self.Model:SetAnimation(0, -1)
        self.Model:SetRotation(0.61)
        self.Model:SetPosition(0, 0, 0)
        self.Model:SetPortraitZoom(0)
    elseif self.icon then
        local id = tonumber(self.icon)
        if id then
            if self.Icon:SetToFileData(id) then
                SetPortraitToTexture(self.Icon, self.Icon:GetTexture())
            end
        else
            SetPortraitToTexture(self.Icon, self.icon)
        end
    end

    if self.price then
        self.Price:ClearAllPoints()
        self.SalePrice:SetShown(self.originalPrice)
        self.Strikethrough:SetShown(self.originalPrice)

        if self.originalPrice then
            self.SalePrice:SetText(self.price .. (self.currency or '*'))
            self.Price:SetText(self.originalPrice .. (self.currency or '*'))
            self.Price:SetPoint('BOTTOMRIGHT', self, 'BOTTOM', -2, 30)
        else
            self.Price:SetText(self.price .. (self.currency or '*'))
            self.Price:SetPoint('BOTTOM', self, 0, 30)
        end
    end

    if self.hour then
        self.Discount:SetText(format('%d:00 秒杀', self.hour))
        self.Discount:Show()
    elseif self.price and self.originalPrice then
        self.Discount:SetText(format(L['%.1f折'], ceil(self.price/self.originalPrice*100)/10))
        self.Discount:Show()
    else
        self.Discount:Hide()
    end

    if self.text then
        self.Name:SetText(self.text)
    end
end

function MallItem:Clear()
    self.item = nil
    self.model = nil
    self.price = nil
    self.originalPrice = nil
    self.hour = nil
    self.icon = nil
    self.currency = nil
end

local orig_FireFormat = MallItem.FireFormat
function MallItem:FireFormat()
    self:Clear()
    orig_FireFormat(self)
end
