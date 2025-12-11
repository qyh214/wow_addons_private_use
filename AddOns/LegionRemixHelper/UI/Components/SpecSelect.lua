---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class SpecSelectComponentObject: SpecSelectComponentMixin

---@param self Frame|table
---@param mouseButton string
---@param isDown boolean
local function onClick(self, mouseButton, isDown)
    local obj = self.obj
    ---@cast obj SpecSelectComponentObject

    if obj:GetOnClick() then
        obj:GetOnClick()(obj, mouseButton, isDown)
    end
end

local function onSettingsClick(self, mouseButton, isDown)
    local obj = self.obj
    ---@cast obj SpecSelectComponentObject

    if obj:GetOnSettingsClick() then
        obj:GetOnSettingsClick()(obj, mouseButton, isDown)
    end
end

---@class SpecSelectComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field onClick fun(self, mouseButton:string, isDown:boolean)?
---@field onSettingsClick fun(self, mouseButton:string, isDown:boolean)?
---@field active boolean?
---@field name string?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 58,
    height = 52,
    anchors = {
        { "CENTER" }
    },
    onClick = nil,
    onSettingsClick = nil,
    active = false,
    name = "SpecNameHere"
}

---@class SpecSelectComponent
---@field defaultOptions SpecSelectComponentOptions
local specSelectComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.SpecSelect = specSelectComponent

local componentsBase = Private.Components.Base

---@class SpecSelectComponentMixin
---@field frame Frame|table
---@field active boolean
---@field onClick fun(self, mouseButton:string, isDown:boolean)|nil
---@field onSettingsClick fun(self, mouseButton:string, isDown:boolean)|nil
---@field activeFrames Texture[]|nil
---@field name FontString|nil
---@field sample FontString|nil
---@field activeB Button|nil
---@field activeS Texture|nil
---@field activeT FontString|nil
local specSelectComponentMixin = {
    active = false,
    onClick = nil,
    onSettingsClick = nil,
    activeFrames = nil,
    name = nil,
    sample = nil,
    activeB = nil,
    activeS = nil,
    activeT = nil,
}

---@param active boolean|nil
function specSelectComponentMixin:SetActive(active)
    active = active or false
    self.active = active

    for _, aFrame in pairs(self.activeFrames) do
        aFrame:SetShown(active)
    end
    self.activeT:SetShown(active)
    self.activeB:SetShown(not active)
end

---@return boolean isActive
function specSelectComponentMixin:IsActive()
    return self.active and true or false
end

---@param onClickFunc fun(self: any, mouseButton: string, isDown: boolean)|nil
function specSelectComponentMixin:SetOnClick(onClickFunc)
    self.onClick = onClickFunc
end

---@return fun(self: any, mouseButton: string, isDown: boolean)|nil
function specSelectComponentMixin:GetOnClick()
    return self.onClick
end

---@param onClickFunc fun(self: any, mouseButton: string, isDown: boolean)|nil
function specSelectComponentMixin:SetOnSettingsClick(onClickFunc)
    self.onSettingsClick = onClickFunc
end

---@return fun(self: any, mouseButton: string, isDown: boolean)|nil
function specSelectComponentMixin:GetOnSettingsClick()
    return self.onSettingsClick
end

---@return string name
function specSelectComponentMixin:GetName()
    return self.name:GetText()
end

---@param name string?
function specSelectComponentMixin:SetName(name)
    self.name:SetText(name or "")
end

---@param parent Frame?
---@param options SpecSelectComponentOptions
---@return SpecSelectComponentObject sampleFrame
function specSelectComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata(options.frame_strata)
    frame:SetSize(options.width, options.height)

    for _, anchor in ipairs(options.anchors) do
        frame:SetPoint(unpack(anchor))
    end

    local hover = frame:CreateTexture(nil, "BACKGROUND")
    hover:SetAllPoints()
    hover:SetAtlas("spec-hover-background")
    hover:SetAlpha(.05)
    hover:SetBlendMode("ADD")
    hover:Hide()

    local name = frame:CreateFontString(nil, nil, "Game13Font")
    name:SetJustifyH("CENTER")
    name:SetTextColor(1, 1, 1)
    name:SetPoint("TOP", 0, -50)
    name:SetText("SpecNameHere")

    local sample = frame:CreateFontString(nil, nil, "GameFontHighlightSmall2")
    sample:SetPoint("TOP", name, "BOTTOM", 0, -25)

    local activeT = frame:CreateFontString(nil, nil, "GameFontNormalSmall2")
    activeT:SetPoint("BOTTOM", 0, 50)
    activeT:SetTextColor(0, 1, 0)
    activeT:SetText(SPEC_ACTIVE)
    local activeB = CreateFrame("Button", nil, frame, "SharedButtonTemplate")
    activeB:SetPoint("BOTTOM", 0, 50)
    activeB:SetSize(options.width / 2, 25)
    activeB:SetText(TALENT_SPEC_ACTIVATE)
    local activeS = frame:CreateTexture()
    activeS:SetPoint("BOTTOM", 0, 15)
    activeS:SetAtlas("GM-icon-settings")
    activeS:SetSize(30, 30)

    local sep = frame:CreateTexture()
    sep:SetPoint("TOP", name, "BOTTOM", 0, -12)
    sep:SetAlpha(.2)
    sep:SetAtlas("spec-dividerline", true)
    sep:SetWidth(options.width * 0.7)

    local div = frame:CreateTexture()
    div:SetPoint("RIGHT", 3.5, 0)
    div:SetAtlas("spec-columndivider", true)
    div:SetHeight(options.height)

    local activeFrames = {}
    local aBG1 = frame:CreateTexture()
    aBG1:SetAllPoints()
    aBG1:SetAtlas("spec-selected-background1")
    aBG1:SetAlpha(.1)
    aBG1:SetBlendMode("ADD")
    tinsert(activeFrames, aBG1)
    local aBG2 = frame:CreateTexture()
    aBG2:SetAllPoints()
    aBG2:SetAtlas("spec-selected-background1")
    aBG2:SetAlpha(.1)
    aBG2:SetBlendMode("MOD")
    tinsert(activeFrames, aBG2)
    local aBGL1 = frame:CreateTexture()
    aBGL1:SetPoint("TOPLEFT", 3.5, 0)
    aBGL1:SetPoint("BOTTOMLEFT", 3.5, 0)
    aBGL1:SetAtlas("spec-selected-background2", true)
    aBGL1:SetBlendMode("ADD")
    tinsert(activeFrames, aBGL1)
    local aBGL2 = frame:CreateTexture()
    aBGL2:SetPoint("TOPLEFT", 3.5, 0)
    aBGL2:SetPoint("BOTTOMLEFT", 3.5, 0)
    aBGL2:SetAtlas("spec-selected-background3", true)
    aBGL2:SetAlpha(.1)
    aBGL2:SetBlendMode("ADD")
    tinsert(activeFrames, aBGL2)
    local aBGL3 = frame:CreateTexture()
    aBGL3:SetPoint("TOPLEFT", 3.5, 0)
    aBGL3:SetPoint("BOTTOMLEFT", 3.5, 0)
    aBGL3:SetAtlas("spec-selected-background4", true)
    aBGL3:SetAlpha(.1)
    aBGL3:SetBlendMode("ADD")
    tinsert(activeFrames, aBGL3)
    local aBGL4 = frame:CreateTexture()
    aBGL4:SetPoint("TOPLEFT", 3.5, 0)
    aBGL4:SetPoint("BOTTOMLEFT", 3.5, 0)
    aBGL4:SetAtlas("spec-selected-background5", true)
    aBGL4:SetAlpha(.1)
    aBGL4:SetBlendMode("ADD")
    tinsert(activeFrames, aBGL4)
    local aBGR1 = frame:CreateTexture()
    aBGR1:SetPoint("TOPRIGHT", -3.5, 0)
    aBGR1:SetPoint("BOTTOMRIGHT", -3.5, 0)
    aBGR1:SetAtlas("spec-selected-background2", true)
    aBGR1:SetTexCoord(1, 0, 0, 1)
    aBGR1:SetBlendMode("ADD")
    tinsert(activeFrames, aBGR1)
    local aBGR2 = frame:CreateTexture()
    aBGR2:SetPoint("TOPRIGHT", -3.5, 0)
    aBGR2:SetPoint("BOTTOMRIGHT", -3.5, 0)
    aBGR2:SetAtlas("spec-selected-background3", true)
    aBGR2:SetAlpha(.1)
    aBGR2:SetTexCoord(1, 0, 0, 1)
    aBGR2:SetBlendMode("ADD")
    tinsert(activeFrames, aBGR2)
    local aBGR3 = frame:CreateTexture()
    aBGR3:SetPoint("TOPRIGHT", -3.5, 0)
    aBGR3:SetPoint("BOTTOMRIGHT", -3.5, 0)
    aBGR3:SetAtlas("spec-selected-background4", true)
    aBGR3:SetTexCoord(1, 0, 0, 1)
    aBGR3:SetBlendMode("ADD")
    tinsert(activeFrames, aBGR3)
    local aBGR4 = frame:CreateTexture()
    aBGR4:SetPoint("TOPRIGHT", -3.5, 0)
    aBGR4:SetPoint("BOTTOMRIGHT", -3.5, 0)
    aBGR4:SetAtlas("spec-selected-background5", true)
    aBGR4:SetTexCoord(1, 0, 0, 1)
    aBGR4:SetBlendMode("ADD")
    tinsert(activeFrames, aBGR4)

    frame:SetScript("OnEnter", function() hover:Show() end)
    frame:SetScript("OnLeave", function() hover:Hide() end)
    activeB:SetScript("OnClick", onClick)
    activeS:SetScript("OnMouseUp", onSettingsClick)

    return self:CreateObject(frame, name, sample, activeB, activeS, activeT, activeFrames, options)
end

---@param frame Frame|table
---@param name FontString
---@param sample FontString
---@param activeB Button|table
---@param activeS Texture|table
---@param activeT FontString
---@param activeFrames Texture[]
---@param options SpecSelectComponentOptions
---@return SpecSelectComponentObject
function specSelectComponent:CreateObject(frame, name, sample, activeB, activeS, activeT, activeFrames, options)
    local obj = {}
    setmetatable(obj, { __index = specSelectComponentMixin })
    ---@cast obj SpecSelectComponentObject
    frame.obj = obj
    activeB.obj = obj
    activeS.obj = obj

    obj.frame = frame
    obj.name = name
    obj.sample = sample
    obj.activeB = activeB
    obj.activeS = activeS
    obj.activeT = activeT
    obj.activeFrames = activeFrames

    obj:SetActive(options.active)
    obj:SetOnClick(options.onClick)
    obj:SetOnSettingsClick(options.onSettingsClick)
    obj:SetName(options.name)

    return obj
end
