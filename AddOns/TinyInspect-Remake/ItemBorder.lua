
-------------------------------------
-- 物品邊框 Author: M
-------------------------------------

local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")

local function SafeNumber(value, fallback)
    if (type(value) ~= "number") then
        return fallback
    end
    local ok, normalized = pcall(function()
        return value + 0
    end)
    if (ok and type(normalized) == "number") then
        return normalized
    end
    return fallback
end

local function SafeGetSize(frame, fallbackW, fallbackH)
    local w, h = fallbackW, fallbackH
    if (frame and frame.GetSize) then
        local ok, fw, fh = pcall(frame.GetSize, frame)
        if (ok) then
            w = SafeNumber(fw, w)
            h = SafeNumber(fh, h)
        end
    end
    return w, h
end

local function CreateEdgeSet(parent, thickness, inset, layer)
    local edges = {
        top = parent:CreateTexture(nil, layer),
        bottom = parent:CreateTexture(nil, layer),
        left = parent:CreateTexture(nil, layer),
        right = parent:CreateTexture(nil, layer),
    }
    for _, edge in pairs(edges) do
        edge:SetTexture("Interface\\Buttons\\WHITE8X8")
    end
    edges.top:SetPoint("TOPLEFT", parent, "TOPLEFT", inset, -inset)
    edges.top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -inset, -inset)
    edges.top:SetHeight(thickness)
    edges.bottom:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", inset, inset)
    edges.bottom:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -inset, inset)
    edges.bottom:SetHeight(thickness)
    edges.left:SetPoint("TOPLEFT", parent, "TOPLEFT", inset, -inset)
    edges.left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", inset, inset)
    edges.left:SetWidth(thickness)
    edges.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -inset, -inset)
    edges.right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -inset, inset)
    edges.right:SetWidth(thickness)
    return edges
end

local function SetEdgeSetColor(edges, r, g, b, a)
    if (not edges) then return end
    edges.top:SetVertexColor(r, g, b, a or 1)
    edges.bottom:SetVertexColor(r, g, b, a or 1)
    edges.left:SetVertexColor(r, g, b, a or 1)
    edges.right:SetVertexColor(r, g, b, a or 1)
end


local function SetItemAngularBorderScheduled(button, quality, itemIDOrLink)
    if (button.angularFrame) then return end
    LibSchedule:AddTask({
        identity  = tostring(button),
        begined   = math.random() / 2,
        elasped   = 0.5,
        expired   = GetTime() + 2,
        button    = button,
        onExecute = function(self)
            if (not self.button.angularFrame) then
                local anchor = self.button.IconBorder or self.button
                local w, h = SafeGetSize(self.button, 32, 32)
                local ww, hh = SafeGetSize(anchor, w, h)
                if (ww <= 0 or hh <= 0) then
                    anchor = self.button.Icon or self.button.icon or self.button
                    w, h = SafeGetSize(anchor, w, h)
                else
                    w, h = min(w, ww), min(h, hh)
                end
                if (w <= 0) then w = 32 end
                if (h <= 0) then h = 32 end
                if (w > h * 1.28) then
                    w = h
                end
                self.button.angularFrame = CreateFrame("Frame", nil, self.button)
                self.button.angularFrame:SetFrameLevel(5)
                self.button.angularFrame:SetSize(w, h)
                self.button.angularFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
                self.button.angularFrame:Hide()
                self.button.angularFrame.mask = CreateEdgeSet(self.button.angularFrame, 2, 1, "ARTWORK")
                SetEdgeSetColor(self.button.angularFrame.mask, 0, 0, 0)
                self.button.angularFrame.border = CreateEdgeSet(self.button.angularFrame, 1, 0, "OVERLAY")
            end
            if (self.button.isBag) then
                self.button.angularFrame:Hide()
            elseif (TinyInspectRemakeDB and TinyInspectRemakeDB.ShowItemBorder) then
                LibEvent:trigger("SET_ITEM_ANGULARBORDER", self.button.angularFrame, quality, itemIDOrLink)
            else
                self.button.angularFrame:Hide()
            end
            return true
        end,
    })
end

--直角邊框 @trigger SET_ITEM_ANGULARBORDER
local function SetItemAngularBorder(self, quality, itemIDOrLink)
    if (not self) then return end
    if (not self.angularFrame) then
        return SetItemAngularBorderScheduled(self, quality, itemIDOrLink)
    end
    if (self.isBag) then
        self.angularFrame:Hide()
    elseif (TinyInspectRemakeDB and TinyInspectRemakeDB.ShowItemBorder) then
        LibEvent:trigger("SET_ITEM_ANGULARBORDER", self.angularFrame, quality, itemIDOrLink)
    else
        self.angularFrame:Hide()
    end
end

--功能附着
hooksecurefunc("SetItemButtonQuality", SetItemAngularBorder)
LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_InspectUI") then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(self)
            local textureName = GetInventoryItemTexture(InspectFrame.unit, self:GetID())
            if (not textureName) then SetItemAngularBorder(self, false) end
        end)
    end
end)

--設置物品直角邊框
LibEvent:attachTrigger("SET_ITEM_ANGULARBORDER", function(self, frame, quality, itemIDOrLink)
    if (quality) then
        local r, g, b = GetItemQualityColor(quality)
        if (quality <= 1) then
            r = r - 0.3
            g = g - 0.3
            b = b - 0.3
        end
        SetEdgeSetColor(frame.border, r, g, b)
        frame:Show()
    else
        frame:Hide()
    end
end)

--直角邊框时需要调整艾泽拉斯项链等级框架
local RankFrame = CharacterNeckSlot and CharacterNeckSlot.RankFrame
if (RankFrame) then
    RankFrame:SetFrameLevel(8)
    RankFrame.Texture:Hide()
    RankFrame:SetPoint("CENTER", CharacterNeckSlot, "BOTTOM", 0, 8)
    local fontFile, fontSize, fontFlags = TextStatusBarText:GetFont()
    RankFrame.Label:SetFont(fontFile, fontSize, "THINOUTLINE")
    RankFrame.Label:SetTextColor(0, 0.9, 0.9)
end
