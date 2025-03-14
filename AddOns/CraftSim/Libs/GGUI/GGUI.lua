---@class GGUI-2.1
local GGUI = LibStub:NewLibrary("GGUI-2.1", 27)
if not GGUI then return end -- if version already exists

---@type GGUI_GUTIL
local GUTIL = GGUI_GUTIL

--- CLASSICS insert
---@class Object
local Object = {}
Object.__index = Object

GGUI.Object = Object

function Object:new()
end

function Object:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Object:implement(...)
    for _, cls in pairs({ ... }) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__tostring()
    return "Object"
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:new(...)
    return obj
end

--- CLASSICS END

-- GGUI CONST
GGUI.CONST = {}
GGUI.CONST.EMPTY_TEXTURE = "Interface\\containerframe\\bagsitemslot2x"

---@class GGUI.AnchorPoint
---@field anchorParent Region?
---@field anchorA FramePoint?
---@field anchorB FramePoint?
---@field offsetX number?
---@field offsetY number?

---@class GGUI.ConstructorOptions
---@field debug? boolean

-- GGUI UTILS
function GGUI:DebugPrint(objectConstructorOptions, text)
    if objectConstructorOptions.debug then
        print(GUTIL:ColorizeText("GGUI Debug: ", GUTIL.COLORS.EPIC) .. tostring(text))
    end
end

---@param errorMessage string
function GGUI:ThrowError(message)
    error(GUTIL:ColorizeText("GGUI Error: ", GUTIL.COLORS.RED) .. tostring(message))
end

--- Requires DevTool Addon
function GGUI:DebugTable(objectConstructorOptions, t, label)
    if objectConstructorOptions.debug and DevTool then
        DevTool:AddData(t, "GGUI: " .. label)
    end
end

---@generic T
---@param frame T | GGUI.Frame
---@param onCloseCallback? fun(frame : T)
---@param closeButtonOptions? GGUI.Button.ConstructorOptions
function GGUI:MakeFrameCloseable(frame, onCloseCallback, closeButtonOptions)
    closeButtonOptions = closeButtonOptions or {}
    closeButtonOptions.parent = closeButtonOptions.parent or frame
    closeButtonOptions.anchorParent = closeButtonOptions.anchorParent or frame
    closeButtonOptions.anchorA = closeButtonOptions.anchorA or "TOP"
    closeButtonOptions.anchorB = closeButtonOptions.anchorB or "TOPRIGHT"
    closeButtonOptions.sizeX = closeButtonOptions.sizeX or 25
    closeButtonOptions.sizeY = closeButtonOptions.sizeY or 20
    closeButtonOptions.offsetX = closeButtonOptions.offsetX or -20
    closeButtonOptions.offsetY = closeButtonOptions.offsetY or -10
    closeButtonOptions.anchorPoints = closeButtonOptions.anchorPoints
    closeButtonOptions.label = closeButtonOptions.label or "X"
    closeButtonOptions.clickCallback = function()
        frame:Hide()
        if onCloseCallback then
            onCloseCallback(frame)
        end
    end
    frame.closeButton = GGUI.Button(closeButtonOptions)
end

---@param gFrame GGUI.Frame
function GGUI:MakeFrameMoveable(gFrame)
    gFrame.frame.hookFrame:SetMovable(true)
    gFrame.frame:HookScript("OnMouseDown", function(self, button)
        local anchorParent = select(2, gFrame.frame.hookFrame:GetPoint())
        gFrame.preMoveAnchorParent = anchorParent
        gFrame.frame.hookFrame:StartMoving()
    end)
    gFrame.frame:HookScript("OnMouseUp", function(self, button)
        gFrame.frame.hookFrame:StopMovingOrSizing()
        if not gFrame.preMoveAnchorParent then return end
        local x, y = gFrame.frame.hookFrame:GetCenter()
        local relativeX, relativeY = gFrame.preMoveAnchorParent:GetCenter()

        -- Calculate the offset between the original anchor parent and the new position
        local offsetX = x - relativeX
        local offsetY = y - relativeY

        -- Reapply the anchor point with the offset
        gFrame.frame.hookFrame:ClearAllPoints()
        gFrame.frame.hookFrame:SetPoint("CENTER", gFrame.preMoveAnchorParent, "CENTER", offsetX, offsetY)

        gFrame:SavePosition(offsetX, offsetY)
    end)
end

---@param frame Frame
---@param itemLink string
---@param owner Frame
---@param anchor TooltipAnchor
function GGUI:SetItemTooltip(frame, itemLink, owner, anchor)
    local function onEnter()
        local _, ItemLink = GameTooltip:GetItem()
        GameTooltip:SetOwner(owner, anchor);

        if ItemLink ~= itemLink then
            -- to not set it again and hide the tooltip..
            GameTooltip:SetHyperlink(itemLink)
        end
        GameTooltip:Show();
    end
    local function onLeave()
        GameTooltip:Hide();
    end
    if itemLink then
        frame:SetScript("OnEnter", onEnter)
        frame:SetScript("OnLeave", onLeave)
    else
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end
end

---@param frame Frame
---@param spellID number
---@param owner Frame
---@param anchor TooltipAnchor
function GGUI:SetSpellTooltip(frame, spellID, owner, anchor)
    local function onEnter()
        local _, currentSpellID = GameTooltip:GetSpell()
        GameTooltip:SetOwner(owner, anchor);

        if currentSpellID ~= spellID then
            -- to not set it again and hide the tooltip..
            GameTooltip:SetSpellByID(spellID)
        end
        GameTooltip:Show();
    end
    local function onLeave()
        GameTooltip:Hide();
    end
    if spellID then
        frame:SetScript("OnEnter", onEnter)
        frame:SetScript("OnLeave", onLeave)
    else
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end
end

function GGUI:SetTooltipsByTooltipOptions(frame, optionsOwner)
    local function handleTooltipOnEnter()
        if not optionsOwner.tooltipOptions then return end

        ---@type GGUI.TooltipOptions
        local tooltipOptions = optionsOwner.tooltipOptions

        GameTooltip:SetOwner(tooltipOptions.owner or frame, tooltipOptions.anchor);

        if tooltipOptions.spellID then
            local _, currentSpellID = GameTooltip:GetSpell()

            if currentSpellID ~= tooltipOptions.spellID then
                -- to not set it again and hide the tooltip..
                GameTooltip:SetSpellByID(tooltipOptions.spellID)
            end
        elseif tooltipOptions.itemID then
            GameTooltip:SetItemByID(tooltipOptions.itemID)
        elseif tooltipOptions.itemLink then
            GameTooltip:SetHyperlink(tooltipOptions.itemLink)
        elseif tooltipOptions.text then
            GameTooltip:SetText(tooltipOptions.text, nil, nil, nil, nil,
                tooltipOptions.textWrap)
        elseif tooltipOptions.frame then
            if tooltipOptions.frameUpdateCallback then
                tooltipOptions.frameUpdateCallback(tooltipOptions.frame)
            end
            GameTooltip_InsertFrame(GameTooltip, tooltipOptions.frame)
        end

        if tooltipOptions.scale then
            GameTooltip:SetScale(tooltipOptions.scale)
        else
            GameTooltip:SetScale(1)
        end

        GameTooltip:Show();
    end
    local function handleTooltipOnLeave()
        if not optionsOwner.tooltipOptions then return end
        GameTooltip:Hide();
    end

    frame:HookScript("OnEnter", function()
        handleTooltipOnEnter()
    end)
    frame:HookScript("OnLeave", function()
        handleTooltipOnLeave()
    end)
end

function GGUI:EnableHyperLinksForFrameAndChilds(frame)
    if type(frame) == "table" and frame.SetHyperlinksEnabled and not frame.enabledLinks then -- prevent inf loop by references
        frame.enabledLinks = true
        frame:SetHyperlinksEnabled(true)
        frame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

        for possibleFrame1, possibleFrame2 in pairs(frame) do
            GGUI:EnableHyperLinksForFrameAndChilds(possibleFrame1)
            GGUI:EnableHyperLinksForFrameAndChilds(possibleFrame2)
        end
    end
end

---@param region Region
---@param anchorPoints GGUI.AnchorPoint[]
function GGUI:SetPointsByAnchorPoints(region, anchorPoints)
    region:ClearAllPoints()
    for _, anchorPoint in ipairs(anchorPoints) do
        GGUI:SetPointByAnchorPoint(region, anchorPoint)
    end
end

---@param region Region
---@param anchorPoint GGUI.AnchorPoint
function GGUI:SetPointByAnchorPoint(region, anchorPoint)
    region:SetPoint(anchorPoint.anchorA or "CENTER", anchorPoint.anchorParent,
        anchorPoint.anchorB or "CENTER",
        anchorPoint.offsetX or 0,
        anchorPoint.offsetY or 0)
end

---@param backdropFrame BackdropTemplate
---@param backdropOptions GGUI.BackdropOptions?
function GGUI:SetBackdropByBackdropOptions(backdropFrame, backdropOptions)
    if not backdropOptions then return end

    if backdropOptions.backdropInfo then
        backdropFrame:SetBackdrop(backdropOptions.backdropInfo)
    end
    if backdropOptions.backdropRGBA and #backdropOptions.backdropRGBA == 4 then
        backdropFrame:SetBackdropColor(backdropOptions.backdropRGBA[1], backdropOptions.backdropRGBA[2],
            backdropOptions.backdropRGBA[3], backdropOptions.backdropRGBA[4])
    end
    if backdropOptions.borderRGBA and #backdropOptions.borderRGBA == 4 then
        backdropFrame:SetBackdropBorderColor(backdropOptions.borderRGBA[1], backdropOptions.borderRGBA[2],
            backdropOptions.borderRGBA[3], backdropOptions.borderRGBA[4])
    end
end

---- GGUI Widgets

--- GGUI Widget

---@class GGUI.Widget : Object
GGUI.Widget = GGUI.Object:extend()

function GGUI.Widget:new(frame)
    self.frame = frame
    self.isGGUI = true
end

--- forward common frame/region methods to original frame
function GGUI.Widget:SetScript(...)
    self.frame:SetScript(...)
end

function GGUI.Widget:HookScript(...)
    self.frame:HookScript(...)
end

function GGUI.Widget:Show()
    self.frame:Show()
end

function GGUI.Widget:Hide()
    self.frame:Hide()
end

function GGUI.Widget:SetEnabled(enabled)
    self.frame:SetEnabled(enabled)
end

function GGUI.Widget:SetVisible(visible)
    if visible then
        self:Show()
    else
        self:Hide()
    end
end

function GGUI.Widget:GetHeight()
    return self.frame:GetHeight()
end

function GGUI.Widget:GetWidth()
    return self.frame:GetWidth()
end

function GGUI.Widget:SetTransparency(transparency)
    self.frame:SetBackdropColor(0, 0, 0, transparency) -- TODO: with current color
end

function GGUI.Widget:IsVisible()
    return self.frame:IsVisible()
end

function GGUI.Widget:SetPoint(...)
    return self.frame:SetPoint(...)
end

--- super constructor needs to be called beforehand so that self.frame is existent
---@param anchorPoints GGUI.AnchorPoint[]
function GGUI.Widget:SetPointsByAnchorPoints(anchorPoints)
    GGUI:SetPointsByAnchorPoints(self.frame, anchorPoints)
end

function GGUI.Widget:Raise()
    self.frame:Raise()
end

function GGUI.Widget:Lower()
    self.frame:Lower()
end

function GGUI.Widget:SetFrameLevel(...)
    self.frame:SetFrameLevel(...)
end

--- GGUI Frame

---@class GGUI.FrameStatus[]
---@field statusID string
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field title? string
---@field activationCallback? function

---@class GGUI.FrameConstructorOptions : GGUI.ConstructorOptions
---@field globalName? string
---@field title? string
---@field titleOptions? GGUI.TextConstructorOptions
---@field parent? Frame
---@field anchorParent? Region DEPRICATED use anchorPoints
---@field anchorA? FramePoint DEPRICATED use anchorPoints
---@field anchorB? FramePoint DEPRICATED use anchorPoints
---@field offsetX? number DEPRICATED use anchorPoints
---@field offsetY? number DEPRICATED use anchorPoints
---@field anchorPoints? GGUI.AnchorPoint[]
---@field sizeX? number
---@field sizeY? number
---@field scale? number
---@field frameID? string
---@field scrollableContent? boolean
---@field closeable? boolean
---@field closeButtonOptions? GGUI.Button.ConstructorOptions
---@field collapseable? boolean
---@field collapsed? boolean
---@field moveable? boolean
---@field frameStrata? FrameStrata if omitted will be same as parent
---@field frameLevel? number if omitted will be 1 higher than parent
---@field onCloseCallback? function
---@field onCollapseCallback? function
---@field onCollapseOpenCallback? function
---@field backdropOptions? GGUI.BackdropOptions
---@field initialStatusID? string
---@field frameTable? table The table where your addon stores its frames for later retrieval
---@field frameConfigTable? table The saved variable table where your addon stores any frame config like position
---@field closeOnClickOutside? boolean
---@field tooltipOptions? GGUI.TooltipOptions
---@field hide? boolean
---@field raiseOnInteraction? boolean

---@class GGUI.BackdropOptions
---@field backdropInfo? backdropInfo
---@field backdropRGBA? table<number>
---@field borderRGBA? table<number>

---@param frameTable table the table where your addon stores your frames
---@param frameID string The ID string you gave the frame
---@return GGUI.Frame | nil
function GGUI:GetFrame(frameTable, frameID)
    if not frameTable[frameID] then
        return nil
    end
    return frameTable[frameID]
end

---@class GGUI.Frame : GGUI.Widget
---@overload fun(options:GGUI.FrameConstructorOptions): GGUI.Frame
GGUI.Frame = GGUI.Widget:extend()

---@param options GGUI.FrameConstructorOptions
function GGUI.Frame:new(options)
    options = options or {}
    -- handle defaults
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 100
    options.scale = options.scale or 1
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.frameTable = options.frameTable or {}
    options.frameConfigTable = options.frameConfigTable or {}
    local numFrames = GUTIL:Count(options.frameTable) + 1
    self.frameConfigTable = options.frameConfigTable
    self.originalX = options.sizeX
    self.originalY = options.sizeY
    self.originalOffsetX = options.offsetX
    self.originalOffsetY = options.offsetY
    self.originalAnchorParent = options.anchorParent
    self.originalAnchorA = options.anchorA
    self.originalAnchorB = options.anchorB
    self.frameID = options.frameID or ("GGUIFrame" .. numFrames)
    self.scrollableContent = options.scrollableContent or false
    self.closeable = options.closeable or false
    self.collapseable = options.collapseable or false
    self.moveable = options.moveable or false
    self.frameStrata = options.frameStrata
    self.collapsed = false
    self.activeStatusID = options.initialStatusID
    ---@type GGUI.FrameStatus[]
    self.statusList = {}
    self.onCollapseCallback = options.onCollapseCallback
    self.onCollapseOpenCallback = options.onCollapseOpenCallback
    self.closeOnClickOutside = options.closeOnClickOutside or false
    self.onCloseCallback = options.onCloseCallback

    GGUI:DebugTable(options, options, "Frame Options")

    local hookFrame = CreateFrame("frame", nil, options.parent)
    if not options.anchorPoints then
        hookFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    else
        GGUI:SetPointsByAnchorPoints(hookFrame, options.anchorPoints)
    end
    local frame = CreateFrame("frame", options.globalName, hookFrame, "BackdropTemplate")
    GGUI.Frame.super.new(self, frame)
    frame.hookFrame = hookFrame
    hookFrame:SetSize(options.sizeX, options.sizeY)
    frame:SetSize(options.sizeX, options.sizeY)
    frame:SetScale(options.scale)
    frame:SetFrameStrata(options.frameStrata or options.parent:GetFrameStrata())
    frame:SetFrameLevel(options.frameLevel or (options.parent:GetFrameLevel() + 1))

    ---@type number sourced by GetTime() which gives the id of the current render frame
    self.onShowRenderFrameTimestamp = 0

    frame:HookScript("OnShow", function()
        self.onShowRenderFrameTimestamp = tonumber(GUTIL:Round(GetTime(), 1))
    end)

    if options.raiseOnInteraction then
        frame:SetToplevel(true)
    end

    if options.hide then
        frame:Hide()
    end

    if self.closeOnClickOutside then
        -- Check for clicks outside the scaled frame
        frame:HookScript("OnUpdate", function()
            if IsMouseButtonDown("LeftButton") and frame:IsShown() then
                if not frame:IsMouseOver() then
                    local renderFrameTimestamp = tonumber(GUTIL:Round(GetTime(), 1))
                    -- if render frame time stamp is younger than 2 secs
                    -- due to the frame being able to set to visible by a button that is not in its mouse over area
                    if renderFrameTimestamp > (self.onShowRenderFrameTimestamp + 0.3) then
                        frame:Hide()
                        if self.onCloseCallback then
                            self.onCloseCallback()
                        end
                    end
                end
            end
        end)
    end

    local titleOptions = options.titleOptions or {}

    titleOptions.parent = titleOptions.parent or frame
    titleOptions.anchorPoints = titleOptions.anchorPoints or {}
    titleOptions.anchorPoints[1] = titleOptions.anchorPoints[1] or {}
    titleOptions.anchorPoints[1].anchorParent = titleOptions.anchorPoints[1].anchorParent or frame
    titleOptions.anchorPoints[1].anchorA = titleOptions.anchorPoints[1].anchorA or "TOP"
    titleOptions.anchorPoints[1].anchorB = titleOptions.anchorPoints[1].anchorB or "TOP"
    titleOptions.anchorPoints[1].offsetY = titleOptions.anchorPoints[1].offsetY or -15
    titleOptions.text = options.title or titleOptions.text

    self.title = GGUI.Text(titleOptions)

    frame:SetPoint("TOP", hookFrame, "TOP", 0, 0)

    if options.backdropOptions then
        if options.backdropOptions.backdropInfo then
            GGUI:DebugPrint(options, "Setting backdrop by backdropoptions")
            GGUI:SetBackdropByBackdropOptions(frame, options.backdropOptions)
        else
            local backdropOptions = options.backdropOptions
            backdropOptions.colorR = backdropOptions.colorR or 0
            backdropOptions.colorG = backdropOptions.colorG or 0
            backdropOptions.colorB = backdropOptions.colorB or 0
            backdropOptions.colorA = backdropOptions.colorA or 1
            backdropOptions.tile = backdropOptions.tile or false
            backdropOptions.tileSize = backdropOptions.tileSize or 32
            backdropOptions.borderOptions = backdropOptions.borderOptions or {}
            local borderOptions = backdropOptions.borderOptions
            borderOptions.colorR = borderOptions.colorR or 0
            borderOptions.colorG = borderOptions.colorG or 0
            borderOptions.colorB = borderOptions.colorB or 0
            borderOptions.colorA = borderOptions.colorA or 1
            borderOptions.edgeSize = borderOptions.edgeSize or 16
            borderOptions.insets = borderOptions.insets or { left = 8, right = 6, top = 8, bottom = 8 }
            frame:SetBackdropBorderColor(borderOptions.colorR, borderOptions.colorG, borderOptions.colorB,
                borderOptions.colorA)
            frame:SetBackdrop({
                bgFile = backdropOptions.bgFile,
                edgeFile = borderOptions.edgeFile,
                edgeSize = borderOptions.edgeSize,
                insets = borderOptions.insets,
                edgeInsets = borderOptions.edgeInsets,
                tile = backdropOptions.tile,
                tileSize = backdropOptions.tileSize,
            })
            frame:SetBackdropColor(backdropOptions.colorR, backdropOptions.colorG, backdropOptions.colorB,
                backdropOptions.colorA)
        end
    end

    if self.closeable then
        GGUI:MakeFrameCloseable(frame, options.onCloseCallback, options.closeButtonOptions)
    end

    if self.collapseable then
        GGUI:MakeFrameCollapsable(self)
    end

    if self.moveable then
        GGUI:MakeFrameMoveable(self)
    end

    if self.scrollableContent then
        -- scrollframe
        frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        frame.scrollFrame.scrollChild = CreateFrame("frame")
        local scrollFrame = frame.scrollFrame
        local scrollChild = scrollFrame.scrollChild
        scrollFrame:SetSize(frame:GetWidth(), frame:GetHeight())
        scrollFrame:SetPoint("TOP", frame, "TOP", 0, -30)
        scrollFrame:SetPoint("LEFT", frame, "LEFT", 20, 0)
        scrollFrame:SetPoint("RIGHT", frame, "RIGHT", -35, 0)
        scrollFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
        scrollFrame:SetScrollChild(scrollFrame.scrollChild)
        scrollChild:SetWidth(scrollFrame:GetWidth())
        scrollChild:SetHeight(1) -- ??

        frame.content = scrollChild
    else
        frame.content = CreateFrame("frame", nil, frame, "BackdropTemplate")
        frame.content:SetPoint("TOP", frame, "TOP")
        frame.content:SetSize(options.sizeX, options.sizeY)
        frame.content:SetFrameStrata(frame:GetFrameStrata())
        frame.content:SetFrameLevel(frame:GetFrameLevel() + 1)
    end

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(frame.content, self)
    end

    self.content = frame.content
    options.frameTable[self.frameID] = self
    return frame
end

function GGUI.Frame:Show()
    self.frame:Show()
    self.frame.hookFrame:Show()
    if not self.collapsed then
        self.content:Show()
    end
end

function GGUI.Frame:Hide()
    self.frame:Hide()
    self.frame.hookFrame:Hide()
    self.content:Hide()
end

function GGUI.Frame:Raise()
    self.frame:Raise()
    self.content:Raise()
end

function GGUI.Frame:Lower()
    self.content:Lower()
    self.frame:Lower()
end

function GGUI.Frame:SetSize(x, y)
    self.frame:SetSize(x, y)
    if self.frame.scrollFrame then
        self.frame.scrollFrame:SetSize(self.frame:GetWidth(), self.frame:GetHeight())
        self.frame.scrollFrame:SetPoint("TOP", self.frame, "TOP", 0, -30)
        self.frame.scrollFrame:SetPoint("LEFT", self.frame, "LEFT", 20, 0)
        self.frame.scrollFrame:SetPoint("RIGHT", self.frame, "RIGHT", -35, 0)
        self.frame.scrollFrame:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 20)
        self.frame.scrollFrame.scrollChild:SetWidth(self.frame.scrollFrame:GetWidth())
    end
end

function GGUI.Frame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end

---@param gFrame GGUI.Frame
function GGUI:MakeFrameCollapsable(gFrame)
    local frame = gFrame.frame
    local offsetX = frame.closeButton and -43 or -23

    frame.collapseButton = GGUI.Button({
        parent = frame,
        anchorParent = frame,
        anchorA = "TOP",
        anchorB = "TOPRIGHT",
        offsetX = offsetX,
        offsetY = -10,
        label = " - ",
        sizeX = 12,
        sizeY = 20,
        adjustWidth = true,
        clickCallback = function()
            if gFrame.collapsed then
                gFrame:Decollapse()
            else
                gFrame:Collapse()
            end
        end
    })
end

function GGUI.Frame:Collapse()
    if self.collapseable and self.frame.collapseButton then
        self.collapsed = true
        -- make smaller and hide content, only show frameTitle
        self.frame:SetSize(self.originalX, 40)
        self.frame.collapseButton:SetText("+")
        self.frame.content:Hide()
        if self.frame.scrollFrame then
            self.frame.scrollFrame:Hide()
        end

        if self.onCollapseCallback then
            self.onCollapseCallback(self)
        end

        self.frameConfigTable["collapsed_" .. self.frameID] = true
    end
end

function GGUI.Frame:Decollapse()
    if self.collapseable and self.frame.collapseButton then
        -- restore
        self.collapsed = false
        self.frame.collapseButton:SetText("-")
        self.frame:SetSize(self.originalX, self.originalY)
        self.frame.content:Show()
        if self.frame.scrollFrame then
            self.frame.scrollFrame:Show()
        end

        if self.onCollapseOpenCallback then
            self.onCollapseOpenCallback(self)
        end

        self.frameConfigTable["collapsed_" .. self.frameID] = false
    end
end

function GGUI.Frame:ResetPosition()
    self.frame.hookFrame:ClearAllPoints()
    self.frame.hookFrame:SetPoint(self.originalAnchorA, self.originalAnchorParent, self.originalAnchorB,
        self.originalOffsetX, self.originalOffsetY)

    local x, y = self.frame.hookFrame:GetCenter()
    local relativeX, relativeY = self.originalAnchorParent:GetCenter()

    -- Calculate the offset between the original anchor parent and the new position
    local offsetX = x - relativeX
    local offsetY = y - relativeY

    self:SavePosition(offsetX, offsetY)
end

--- Set a list of predefined GGUI.ButtonStatus
---@param statusList GGUI.FrameStatus[]
function GGUI.Frame:SetStatusList(statusList)
    -- map statuslist to their ids
    table.foreach(statusList, function(_, status)
        if not status.statusID then
            GGUI:ThrowError("FrameStatus without statusID")
        end
        self.statusList[status.statusID] = status
    end)
end

function GGUI.Frame:SetStatus(statusID)
    local frameStatus = self.statusList[statusID]
    self.activeStatusID = statusID

    if frameStatus then
        if frameStatus.sizeX then
            self.frame:SetWidth(frameStatus.sizeX)
        end
        if frameStatus.sizeY then
            self.frame:SetHeight(frameStatus.sizeY)
        end
        if frameStatus.title then
            self.frame.title:SetText(frameStatus.title)
        end
        if frameStatus.offsetX or frameStatus.offsetY or frameStatus.anchorParent or frameStatus.anchorA or frameStatus.anchorB then
            local offsetX = frameStatus.offsetX or self.originalOffsetX
            local offsetY = frameStatus.offsetY or self.originalOffsetY
            local anchorParent = frameStatus.anchorParent or self.originalAnchorParent
            local anchorA = frameStatus.anchorA or self.originalAnchorA
            local anchorB = frameStatus.anchorB or self.originalAnchorB

            self.frame:ClearAllPoints()
            self.frame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        end
        if frameStatus.activationCallback then
            frameStatus.activationCallback(self, statusID)
        end

        -- if collapsed, restore collapse height
        if self.collapseable and self.collapsed then
            self:Collapse()
        end
    end
end

---@return string statusID
function GGUI.Frame:GetStatus()
    return tostring(self.activeStatusID)
end

function GGUI.Frame:RestoreSavedConfig(relativeTo)
    --local savedPosInfo = GGUI:GetConfig("savedPos_" .. self.frameID)
    local savedPosInfo = self.frameConfigTable["savedPos_" .. self.frameID]

    if savedPosInfo then
        relativeTo = relativeTo or UIParent
        self.frame.hookFrame:ClearAllPoints()
        self.frame.hookFrame:SetPoint("CENTER", relativeTo, "CENTER", savedPosInfo.offsetX, savedPosInfo.offsetY)
    end

    if self.collapseable then
        if self.frameConfigTable["collapsed_" .. self.frameID] then
            self:Collapse()
        end
    end
end

function GGUI.Frame:SavePosition(offsetX, offsetY)
    self.frameConfigTable["savedPos_" .. self.frameID] = {
        offsetX = offsetX,
        offsetY = offsetY,
    }
end

--- GGUI Icon

---@class GGUI.IconConstructorOptions: GGUI.ConstructorOptions
---@field parent? Frame
---@field offsetX? number
---@field offsetY? number
---@field texturePath? string | number
---@field sizeX? number
---@field sizeY? number
---@field qualityIconScale? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field anchorParent? Region
---@field hideQualityIcon? boolean
---@field isAtlas? boolean
---@field desaturate? boolean

---@class GGUI.Icon : GGUI.Widget
---@overload fun(options:GGUI.IconConstructorOptions): GGUI.Icon
GGUI.Icon = GGUI.Widget:extend()
function GGUI.Icon:new(options)
    options = options or {}
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    self.defaultTexture = options.texturePath or GGUI.CONST.EMPTY_TEXTURE
    options.sizeX = options.sizeX or 40
    options.sizeY = options.sizeY or 40
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.qualityIconScale = options.qualityIconScale or 1
    self.hideQualityIcon = options.hideQualityIcon or false
    ---@type ItemMixin?
    self.item = nil
    self.isAtlas = options.isAtlas or false
    self.desaturate = options.desaturate or false

    local newIcon = CreateFrame("Button", nil, options.parent, "GameMenuButtonTemplate")
    GGUI.Icon.super.new(self, newIcon)
    newIcon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    newIcon:SetSize(options.sizeX, options.sizeY)
    newIcon:SetNormalFontObject("GameFontNormalLarge")
    newIcon:SetHighlightFontObject("GameFontHighlightLarge")
    if self.isAtlas then
        newIcon:SetNormalAtlas(self.defaultTexture)
    else
        newIcon:SetNormalTexture(self.defaultTexture)
    end
    newIcon.qualityIcon = GGUI.QualityIcon({
        parent = self.frame,
        sizeX = options.sizeX * 0.50 * options.qualityIconScale,
        sizeY = options.sizeY * 0.50 * options.qualityIconScale,
        anchorParent = newIcon,
        anchorA = "TOPLEFT",
        anchorB = "TOPLEFT",
        offsetX = -options.sizeX * 0.10 * options.qualityIconScale,
        offsetY = options.sizeY * 0.10 * options.qualityIconScale,
    })
    newIcon.qualityIcon:Hide()
    self.qualityIcon = newIcon.qualityIcon

    self.frame:HookScript("OnClick", function()
        if IsShiftKeyDown() and self.item then
            self.item:ContinueOnItemLoad(function()
                ChatEdit_InsertLink(self.item:GetItemLink())
            end)
        end
    end)

    if self.desaturate then
        self:Desaturate()
    end
end

---@class GGUI.IconSetItemOptions
---@field tooltipOwner? Frame
---@field tooltipAnchor? TooltipAnchor
---@field overrideQuality? number

---@param idLinkOrMixin number | string | ItemMixin
---@param options GGUI.IconSetItemOptions?
function GGUI.Icon:SetItem(idLinkOrMixin, options)
    options = options or {}

    local gIcon = self
    if not idLinkOrMixin then
        gIcon.frame:SetScript("OnEnter", nil)
        gIcon.frame:SetScript("OnLeave", nil)
        gIcon.qualityIcon:Hide()
        GGUI:SetItemTooltip(gIcon.frame, nil)
        if self.isAtlas then
            gIcon.frame:SetNormalAtlas(self.defaultTexture)
        else
            gIcon.frame:SetNormalTexture(self.defaultTexture)
        end
        return
    end
    local item = nil
    if type(idLinkOrMixin) == 'number' then
        item = Item:CreateFromItemID(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'string' then
        item = Item:CreateFromItemLink(idLinkOrMixin)
    elseif type(idLinkOrMixin) == 'table' and idLinkOrMixin.ContinueOnItemLoad then -- some small test if its a mixing
        item = idLinkOrMixin
    end

    self.item = item
    item:ContinueOnItemLoad(function()
        gIcon.frame:SetNormalTexture(item:GetItemIcon())
        GGUI:SetItemTooltip(gIcon.frame, item:GetItemLink(), options.tooltipOwner or gIcon.frame,
            options.tooltipAnchor or "ANCHOR_RIGHT")

        if options.overrideQuality then
            gIcon.qualityIcon:SetQuality(options.overrideQuality)
        else
            local qualityID = GUTIL:GetQualityIDFromLink(item:GetItemLink())
            gIcon.qualityIcon:SetQuality(qualityID)
        end

        if self.hideQualityIcon then
            gIcon.qualityIcon:Hide()
        end
    end)
end

---@param qualityID number
function GGUI.Icon:SetQuality(qualityID)
    if qualityID then
        self.qualityIcon:SetQuality(qualityID)
        self.qualityIcon:Show()
    else
        self.qualityIcon:Hide()
    end
end

function GGUI.Icon:Saturate()
    local texture = self.frame:GetNormalTexture()
    if texture then
        texture:SetVertexColor(1, 1, 1)
    end
    self.desaturate = false
end

function GGUI.Icon:Desaturate()
    local texture = self.frame:GetNormalTexture()
    if texture then
        texture:SetVertexColor(0.2, 0.2, 0.2)
    end
    self.desaturate = true
end

--- GGUI.QualityIcon

---@class GGUI.QualityIconConstructorOptions : GGUI.ConstructorOptions
---@field parent Frame
---@field sizeX? number
---@field sizeY? number
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field initialQuality? number
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.QualityIcon : GGUI.Widget
---@overload fun(options:GGUI.QualityIconConstructorOptions): GGUI.QualityIcon
GGUI.QualityIcon = GGUI.Widget:extend()
function GGUI.QualityIcon:new(options)
    options = options or {}
    options.parent = options.parent or UIParent
    options.sizeX = options.sizeX or 30
    options.sizeY = options.sizeY or 30
    options.anchorParent = options.anchorParent
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.initialQuality = options.initialQuality or 1

    local icon = options.parent:CreateTexture(nil, "OVERLAY")
    GGUI.QualityIcon.super.new(self, icon)
    icon:SetSize(options.sizeX, options.sizeY)
    icon:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    icon:SetAtlas("Professions-Icon-Quality-Tier" .. options.initialQuality)
    icon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(icon, self)
    end
end

---@param qualityID number
function GGUI.QualityIcon:SetQuality(qualityID)
    if not qualityID or type(qualityID) ~= 'number' then
        self.frame:Hide()
        return
    end
    self.frame:Show()
    if qualityID > 5 then
        qualityID = 5
    elseif qualityID < 1 then
        qualityID = 1
    end
    self.frame:SetTexture("Interface\\Professions\\ProfessionsQualityIcons")
    self.frame:SetAtlas("Professions-Icon-Quality-Tier" .. qualityID)
end

--- GGUI.Dropdown

---@class GGUI.DropdownConstructorOptions : GGUI.ConstructorOptions
---@field globalName? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field label? string
---@field offsetX? number
---@field offsetY? number
---@field width? number
---@field initialData? GGUI.DropdownData[]
---@field clickCallback? fun(self:any, label:string, value:any)
---@field initialValue? any
---@field initialLabel? string

---@class GGUI.DropdownData
---@field isCategory? boolean
---@field label string
---@field value any
---@field tooltipItemLink? string
---@field tooltipConcatText? string

---@class GGUI.Dropdown : GGUI.Widget
---@overload fun(options:GGUI.DropdownConstructorOptions): GGUI.Dropdown
GGUI.Dropdown = GGUI.Widget:extend()

---@param options GGUI.DropdownConstructorOptions
function GGUI.Dropdown:new(options)
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.width = options.width or 150
    options.initialData = options.initialData or {}
    options.initialValue = options.initialValue or ""
    options.initialLabel = options.initialLabel or ""
    local dropDown = CreateFrame("Frame", options.globalName, options.parent, "UIDropDownMenuTemplate")
    GGUI.Dropdown.super.new(self, dropDown)
    self.clickCallback = options.clickCallback
    dropDown:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    UIDropDownMenu_SetWidth(dropDown, options.width)
    self.selectedValue = nil

    self:SetData({
        data = options.initialData,
        initialValue = options.initialValue,
        initialLabel = options.initialLabel
    })

    self.title = dropDown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    self.title:SetPoint("TOP", 0, 10)

    self:SetLabel(options.label)
end

function GGUI.Dropdown:SetLabel(label)
    self.title:SetText(label)
end

---@class GGUI.DropdownSetDataOptions
---@field data GGUI.DropdownData
---@field initialValue? any
---@field initialLabel? string

---@param options GGUI.DropdownSetDataOptions
function GGUI.Dropdown:SetData(options)
    options = options or {}
    options.data = options.data or {}
    options.initialValue = options.initialValue or nil
    options.initialLabel = options.initialLabel or ""

    local dropDown = self.frame
    local gDropdown = self
    local function initMainMenu(self, level, menulist)
        local info = UIDropDownMenu_CreateInfo()
        if level == 1 then
            for _, data in pairs(options.data) do
                info.text = data.label
                info.arg1 = data.value
                if not data.isCategory then
                    info.func = function(self, arg1, arg2, checked)
                        UIDropDownMenu_SetText(dropDown, data.label) -- value should contain the selected text..
                        gDropdown.selectedValue = data.value
                        if gDropdown.clickCallback then
                            gDropdown.clickCallback(self, data.label, data.value)
                        end
                    end
                end

                info.hasArrow = data.isCategory
                info.menuList = data.isCategory and data.label
                if data.tooltipItemLink then
                    local concatText = data.tooltipConcatText or ""
                    info.tooltipText = GUTIL:GetItemTooltipText(data.tooltipItemLink)
                    -- cut first line as it is the name of the item
                    info.tooltipTitle, info.tooltipText = string.match(info.tooltipText, "^(.-)\n(.*)$")
                    info.tooltipTitle = info.tooltipTitle .. "\n" .. concatText
                    info.tooltipOnButton = true
                end
                UIDropDownMenu_AddButton(info)
            end
        elseif menulist then
            for _, currentMenulist in pairs(options.data) do
                if currentMenulist.label == menulist then
                    for _, data in pairs(currentMenulist.value) do
                        info.text = data.label
                        info.arg1 = data.value
                        info.func = function(self, arg1, arg2, checked)
                            UIDropDownMenu_SetText(dropDown, self.value) -- value should contain the selected text..
                            gDropdown.selectedValue = self.value
                            if gDropdown.clickCallback then
                                gDropdown.clickCallback(self, data.label, data.value)
                            end
                            CloseDropDownMenus()
                        end

                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        end
    end


    UIDropDownMenu_Initialize(dropDown, initMainMenu, "DROPDOWN_MENU_LEVEL")
    UIDropDownMenu_SetText(dropDown, options.initialLabel)

    self.selectedValue = options.initialValue
end

function GGUI.Dropdown:SetEnabled(enabled)
    if enabled then
        UIDropDownMenu_EnableDropDown(self.frame)
    else
        UIDropDownMenu_DisableDropDown(self.frame)
    end
end

--- GGUI.CustomDropdown

---@class GGUI.CustomDropdownConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field label? string
---@field offsetX? number
---@field offsetY? number
---@field width? number
---@field buttonOptions GGUI.Button.ConstructorOptions? options to partially overwrite the default widget options
---@field selectionFrameOptions GGUI.FrameConstructorOptions? options to partially overwrite the default widget options
---@field frameListOptions GGUI.FrameListConstructorOptions? options to partially overwrite the default widget options
---@field labelOptions GGUI.TextConstructorOptions? options to partially overwrite the default widget options
---@field arrowOptions GGUI.CustomDropdown.ArrowOptions?
---@field initialData? GGUI.CustomDropdownData[]
---@field clickCallback? fun(self:GGUI.CustomDropdown, label:string, value:any)
---@field initialValue? any
---@field initialLabel? string

---@class GGUI.CustomDropdown.ArrowOptions
---@field isAtlas? boolean
---@field normal? string
---@field pushed? string
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number

---@class GGUI.CustomDropdownData
---@field label string
---@field value any
---@field tooltipOptions? GGUI.TooltipOptions
----@field isCategory? boolean

---@class GGUI.CustomDropdown : GGUI.Widget
---@overload fun(options:GGUI.CustomDropdownConstructorOptions): GGUI.CustomDropdown
GGUI.CustomDropdown = GGUI.Widget:extend()

---@param options GGUI.CustomDropdownConstructorOptions
function GGUI.CustomDropdown:new(options)
    options                                    = options or {}
    options.buttonOptions                      = options.buttonOptions or {}
    options.buttonOptions.buttonTextureOptions = options.buttonOptions.buttonTextureOptions or {}
    options.selectionFrameOptions              = options.selectionFrameOptions or {}
    options.frameListOptions                   = options.frameListOptions or {}
    options.frameListOptions.selectionOptions  = options.frameListOptions.selectionOptions or {}
    options.arrowOptions                       = options.arrowOptions or {}
    options.labelOptions                       = options.labelOptions or {}
    options.initialData                        = options.initialData or {}
    options.initialValue                       = options.initialValue or nil
    options.initialLabel                       = options.initialLabel or ""

    self.selectedValue                         = nil
    self.clickCallback                         = options.clickCallback

    ---@type GGUI.Button.ConstructorOptions
    local defaultButtonOptions                 = {
        parent = options.parent or options.buttonOptions.parent,
        anchorParent = options.anchorParent or options.buttonOptions.anchorParent,
        offsetX = options.offsetX or options.buttonOptions.offsetX,
        offsetY = options.offsetY or options.buttonOptions.offsetY,
        anchorA = options.anchorA or options.buttonOptions.anchorA,
        anchorB = options.anchorB or options.buttonOptions.anchorB,
        adjustWidth = options.buttonOptions.adjustWidth or
            options.buttonOptions.adjustWidth == nil,
        initialStatusID = options.buttonOptions.initialStatusID,
        clickCallback = function()
            if not self.selectionFrame:IsVisible() then
                self.button.button:SetButtonState("PUSHED", true)
                self.selectionFrame:Show()
                self.arrow:SetPushed(true)
            end
        end,
        scale = options.buttonOptions.scale,
        sizeX = options.buttonOptions.sizeX or options.width or 150,
        sizeY = options.buttonOptions.sizeY or 30,
        buttonTextureOptions = {
            isAtlas = options.buttonOptions.buttonTextureOptions.isAtlas or
                options.buttonOptions.buttonTextureOptions.isAtlas == nil,
            normal = options.buttonOptions.buttonTextureOptions.normal or "ClickCastList-ButtonBackground",
            highlight = options.buttonOptions.buttonTextureOptions.highlight or
                "ClickCastList-ButtonHighlight",
            pushed = options.buttonOptions.buttonTextureOptions.pushed or
                "ClickCastList-ButtonHighlight",
            disabled = options.buttonOptions.buttonTextureOptions.disabled or "ClickCastList-ButtonBackground"
        },
        fontOptions = options.buttonOptions.fontOptions
    }
    self.button                                = GGUI.Button(defaultButtonOptions)
    local fontString                           = self.button.button:GetFontString()
    fontString:SetJustifyH("LEFT")
    fontString:ClearAllPoints()
    fontString:ClearPointsOffset()
    fontString:SetPoint("LEFT", self.button.button, "LEFT")
    fontString:AdjustPointsOffset(10, 0) -- I dont know why but giving the offset above in SetPoint does not work

    GGUI.CustomDropdown.super.new(self, self.button)

    ---@class GGUI.CustomDropdown.ArrowTexture : GGUI.Texture
    self.arrow = GGUI.Texture {
        parent = self.button.button:GetParent(), anchorParent = self.button.button,
        anchorA = "RIGHT", anchorB = "RIGHT", sizeX = options.arrowOptions.sizeX or 25,
        sizeY = options.arrowOptions.sizeY or 25,
        offsetY = options.arrowOptions.offsetY or -2,
        offsetX = options.arrowOptions.offsetX or -3,
    }

    self.arrow:SetFrameLevel(self.button.button:GetFrameLevel() + 10)


    self.arrow.isAtlas = (options.arrowOptions.isAtlas ~= nil and options.arrowOptions.isAtlas) or
        options.arrowOptions.isAtlas == nil

    self.arrow.SetPushed = function(self, pushed)
        if pushed then
            if self.isAtlas then
                self:SetAtlas(options.arrowOptions.pushed or "common-dropdown-a-button-pressed")
            else
                self:SetTexture(options.arrowOptions.pushed)
            end
        else
            if self.isAtlas then
                self:SetAtlas(options.arrowOptions.normal or "common-dropdown-a-button-open")
            else
                self:SetTexture(options.arrowOptions.normal)
            end
        end
    end

    self.arrow:SetPushed(false)


    ---@type GGUI.TextConstructorOptions
    local defaultLabelOptions = {
        text = options.labelOptions.text or options.label or "",
        parent = options.labelOptions.parent or defaultButtonOptions.parent,
        anchorParent = options.labelOptions.anchorParent or self.button.frame,
        justifyOptions = options.labelOptions.justifyOptions or { type = "H", align = "LEFT" },
        anchorA = options.labelOptions.anchorA or "BOTTOMLEFT",
        anchorB = options.labelOptions.anchorB or "TOPLEFT",
        font = options.labelOptions.font,
        offsetX = options.labelOptions.offsetX,
        offsetY = options.labelOptions.offsetY,
        scale = options.labelOptions.scale,
        fixedWidth = options.labelOptions.fixedWidth,
        fontOptions = options.labelOptions.fontOptions,
        tooltipOptions = options.labelOptions.tooltipOptions,
    }
    self.label                = GGUI.Text(defaultLabelOptions)

    self.selectionFrame       = GGUI.Frame {
        parent = options.selectionFrameOptions.parent or options.parent,
        anchorParent = options.selectionFrameOptions.anchorParent or self.button.button,
        anchorA = options.selectionFrameOptions.anchorA or "TOPLEFT",
        anchorB = options.selectionFrameOptions.anchorB or "BOTTOMLEFT",
        offsetX = options.selectionFrameOptions.offsetX or 0,
        offsetY = options.selectionFrameOptions.offsetY or 0,
        closeOnClickOutside = options.selectionFrameOptions.closeOnClickOutside == nil or options.selectionFrameOptions.closeOnClickOutside,
        backdropOptions = options.selectionFrameOptions.backdropOptions or {
            borderOptions = {
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            },
            bgFile = "Interface\\Buttons\\WHITE8X8",
            tile = true,
            tileSize = 32,
            colorR = 0,
            colorG = 0,
            colorB = 0,
            colorA = 1,
        },
        scale = options.selectionFrameOptions.scale,
        sizeX = options.selectionFrameOptions.sizeX or self.button.button:GetWidth(),
        sizeY = options.selectionFrameOptions.sizeY or 100,
        title = options.selectionFrameOptions.title,
        tooltipOptions = options.selectionFrameOptions.tooltipOptions
    }

    self.selectionFrame.frame:SetFrameStrata(options.selectionFrameOptions.frameStrata or "DIALOG")

    self.selectionFrame:Hide()

    self.selectionFrame:HookScript("OnHide", function()
        self.button.button:SetButtonState("NORMAL", false)
        self.arrow:SetPushed(false)
    end)

    ---@type GGUI.FrameListConstructorOptions
    local defaultframeListOptions = {
        columnOptions = {
            {
                label = "",
                width = self.selectionFrame:GetWidth() - 10,
            }
        },
        disableScrolling = true,
        rowConstructor =
            function(columns, row)
                ---@class GGUI.CustomDropdown.SelectionRow : GGUI.FrameList.Row
                row = row
                ---@type any
                row.selectionValue = nil
                row.selectionLabel = ""
                ---@class GGUI.CustomDropdown.LabelColumn : Frame
                local labelColumn = columns[1]
                labelColumn.text = GGUI.Text {
                    parent = labelColumn, anchorParent = labelColumn,
                    justifyOptions = { type = "H", align = "LEFT" }
                }
            end,
        parent = options.frameListOptions.parent or self.selectionFrame.frame,
        anchorParent = options.frameListOptions.anchorParent or self.selectionFrame.frame,
        anchorA = options.frameListOptions.anchorA or "TOPLEFT",
        anchorB = options.frameListOptions.anchorB or "TOPLEFT",
        offsetX = options.frameListOptions.offsetX or 0,
        offsetY = options.frameListOptions.offsetY or 0,
        showBorder = options.frameListOptions.showBorder,
        hideScrollbar = options.frameListOptions.hideScrollbar == nil or options.frameListOptions.hideScrollbar,
        autoAdjustHeight = options.frameListOptions.autoAdjustHeight == nil or options.frameListOptions.autoAdjustHeight,
        autoAdjustHeightCallback = function(newHeight)
            self.selectionFrame:SetSize(self.selectionFrame:GetWidth(), newHeight)
        end,
        selectionOptions = {
            hoverRGBA = options.frameListOptions.selectionOptions.hoverRGBA or { 1, 1, 1, 0.2 },
            noSelectionColor = options.frameListOptions.selectionOptions.noSelectionColor,
            selectedRGBA = options.frameListOptions.selectionOptions.selectedRGBA or { 1, 1, 1, 0.5 },
            selectionCallback =
            ---@param row GGUI.CustomDropdown.SelectionRow
            ---@param userInput boolean
                function(row, userInput)
                    self.selectionFrame:Hide()
                    self.button:SetText(row.selectionLabel)
                    self.selectedValue = row.selectionValue
                    if options.frameListOptions.selectionOptions.selectionCallback then
                        options.frameListOptions.selectionOptions.selectionCallback(row, userInput)
                    end
                    if self.clickCallback then
                        self.clickCallback(self, row.selectionLabel, row.selectionValue)
                    end
                end
        },
    }

    self.selectionList            = GGUI.FrameList(defaultframeListOptions)

    if options.initialData then
        self:SetData({
            data = options.initialData,
            initialLabel = options.initialLabel,
            initialValue = options.initialValue,
        })
    else
        if options.initialLabel then
            self.button:SetText(options.initialLabel)
        end

        self.selectedValue = options.initialValue
    end
end

function GGUI.CustomDropdown:SetLabel(label)
    self.label:SetText(label)
end

---@class GGUI.CustomDropdownSetDataOptions
---@field data GGUI.CustomDropdownData[]
---@field sortFunc? fun(a: GGUI.CustomDropdown.SelectionRow, b: GGUI.CustomDropdown.SelectionRow):boolean
---@field initialLabel? string
---@field initialValue? any

---@param options GGUI.CustomDropdownSetDataOptions
function GGUI.CustomDropdown:SetData(options)
    self.selectionList:Remove()
    for _, customDropdownOption in ipairs(options.data) do
        self.selectionList:Add(
        ---@param row GGUI.CustomDropdown.SelectionRow
            function(row)
                local columns = row.columns
                local labelColumn = columns[1] --[[@as GGUI.CustomDropdown.LabelColumn]]

                labelColumn.text:SetText(customDropdownOption.label)
                row.selectionValue = customDropdownOption.value
                row.selectionLabel = customDropdownOption.label
                local tooltipOptions = customDropdownOption.tooltipOptions
                if tooltipOptions then
                    tooltipOptions.owner = tooltipOptions.owner or row.frame
                    tooltipOptions.anchor = tooltipOptions.anchor or "ANCHOR_CURSOR"
                    row.tooltipOptions = tooltipOptions
                else
                    row.tooltipOptions = nil
                end
            end)
    end

    self.selectedValue = self.selectedValue or options.initialValue
    if options.initialLabel then
        self.button:SetText(options.initialLabel)
    end

    self.selectionList:UpdateDisplay(options.sortFunc)
end

function GGUI.CustomDropdown:SetEnabled(enabled)
    self.button:SetEnabled(enabled)
    self.selectionFrame:Hide()
end

--- GGUI.Text

---@class GGUI.TextConstructorOptions : GGUI.ConstructorOptions
---@field text? string
---@field prefix? string
---@field anchorPoints? GGUI.AnchorPoint[]
---@field parent? Frame
---@field anchorParent? Region -- DEPRICATED: Use anchorPoints
---@field anchorA? FramePoint -- DEPRICATED: Use anchorPoints
---@field anchorB? FramePoint -- DEPRICATED: Use anchorPoints
---@field offsetX? number -- DEPRICATED: Use anchorPoints
---@field offsetY? number -- DEPRICATED: Use anchorPoints
---@field font? string
---@field scale? number
---@field justifyOptions? GGUI.JustifyOptions
---@field fixedWidth? number
---@field fontOptions? GGUI.FontOptions
---@field tooltipOptions? GGUI.TooltipOptions
---@field hide? boolean
---@field wrap? boolean

---@class GGUI.JustifyOptions
---@field type "H" | "V" | "HV"
---@field align string?
---@field alignH string?
---@field alignV string?

---@class GGUI.Text : GGUI.Widget
---@overload fun(options:GGUI.TextConstructorOptions): GGUI.Text
GGUI.Text = GGUI.Widget:extend()
---@param options GGUI.TextConstructorOptions
function GGUI.Text:new(options)
    options = options or {}
    options.text = options.text or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.font = options.font or "GameFontHighlight"
    options.scale = options.scale or 1

    self.prefix = options.prefix or ""

    GGUI:DebugPrint(options, "Debug Text " .. tostring(options.text))

    local text = options.parent:CreateFontString(nil, "OVERLAY", options.font)
    self.text = text
    GGUI.Text.super.new(self, text)
    text:SetText(self.prefix .. options.text)
    if options.anchorPoints then
        for _, anchorPoint in ipairs(options.anchorPoints) do
            GGUI:DebugPrint(options, "- Set Anchor OffsetY " .. tostring(anchorPoint.offsetY))
            self.frame:SetPoint(anchorPoint.anchorA or "CENTER", anchorPoint.anchorParent,
                anchorPoint.anchorB or "CENTER",
                anchorPoint.offsetX or 0,
                anchorPoint.offsetY or 0)
        end
    else
        text:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    end
    text:SetScale(options.scale)

    if options.hide then
        self.text:Hide()
    end

    if options.fontOptions then
        text:SetFont(options.fontOptions.fontFile or nil, options.fontOptions.height or 20,
            options.fontOptions.flags or "")
    end

    text:SetWordWrap(options.wrap == true)

    if options.fixedWidth then
        text:SetWidth(options.fixedWidth)
    end

    if options.justifyOptions then
        if options.justifyOptions.type == "V" and options.justifyOptions.align then
            -- retroactive compatible fix for 10.2.7
            options.justifyOptions.align = options.justifyOptions.align == "CENTER" and "MIDDLE" or
                options.justifyOptions.align
            text:SetJustifyV(options.justifyOptions.align)
        elseif options.justifyOptions.type == "H" and options.justifyOptions.align then
            text:SetJustifyH(options.justifyOptions.align)
        elseif options.justifyOptions.type == "HV" and options.justifyOptions.alignH and options.justifyOptions.alignV then
            text:SetJustifyH(options.justifyOptions.alignH)
            options.justifyOptions.alignV = options.justifyOptions.alignV == "CENTER" and "MIDDLE" or
                options.justifyOptions.alignV
            text:SetJustifyV(options.justifyOptions.alignV)
        end
    end

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(self.frame, self)
    end
end

function GGUI.Text:GetText()
    return self.frame:GetText() or ""
end

function GGUI.Text:SetText(text)
    self.frame:SetText(self.prefix .. text)
end

---@param color GUTIL.COLORS?
function GGUI.Text:SetColor(color)
    local text = GUTIL:StripColor(self:GetText())
    if color then
        self:SetText(GUTIL:ColorizeText(text, color))
    end
end

---@param anchorPoints GGUI.AnchorPoint[]
function GGUI.Text:SetAnchorPoints(anchorPoints)
    self.frame:ClearAllPoints()
    for _, anchorPoint in ipairs(anchorPoints) do
        self.frame:SetPoint(anchorPoint.anchorA, anchorPoint.anchorParent, anchorPoint.anchorB, anchorPoint.offsetX or 0,
            anchorPoint.offsetY or 0)
    end
end

function GGUI.Text:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end

--- GGUI.ScrollingMessageFrame

---@class GGUI.ScrollingMessageFrameConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field maxLines? number
---@field sizeX? number
---@field sizeY? number
---@field scale? number
---@field font? string
---@field fading? boolean
---@field enableScrolling? boolean
---@field justifyOptions? GGUI.JustifyOptions
---@field showScrollBar? boolean
---@field copyable? boolean

---@class GGUI.ScrollingMessageFrame
---@overload fun(options:GGUI.ScrollingMessageFrameConstructorOptions): GGUI.ScrollingMessageFrame
GGUI.ScrollingMessageFrame = GGUI.Widget:extend()
---@param options GGUI.ScrollingMessageFrameConstructorOptions
function GGUI.ScrollingMessageFrame:new(options)
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 150
    options.sizeY = options.sizeY or 100
    options.font = options.font or GameFontHighlight
    options.fading = options.fading or false
    options.enableScrolling = options.enableScrolling or false
    local scrollingFrame = CreateFrame("ScrollingMessageFrame", nil, options.parent)
    GGUI.ScrollingMessageFrame.super.new(self, scrollingFrame)
    ---@type ScrollingMessageFrame
    self.frame = self.frame
    scrollingFrame:SetSize(options.sizeX, options.sizeY)
    scrollingFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    scrollingFrame:SetFontObject(options.font)
    scrollingFrame:SetScale(options.scale or 1)
    if options.maxLines then
        scrollingFrame:SetMaxLines(options.maxLines)
    end
    scrollingFrame:SetFading(options.fading)
    if options.justifyOptions then
        if options.justifyOptions.type == "V" and options.justifyOptions.align then
            scrollingFrame:SetJustifyV(options.justifyOptions.align)
        elseif options.justifyOptions.type == "H" and options.justifyOptions.align then
            scrollingFrame:SetJustifyH(options.justifyOptions.align)
        elseif options.justifyOptions.type == "HV" and options.justifyOptions.alignH and options.justifyOptions.alignV then
            scrollingFrame:SetJustifyH(options.justifyOptions.alignH)
            scrollingFrame:SetJustifyV(options.justifyOptions.alignV)
        end
    end
    scrollingFrame:EnableMouseWheel(options.enableScrolling)

    scrollingFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then
            scrollingFrame:ScrollUp()
        elseif delta < 0 then
            scrollingFrame:ScrollDown()
        end
    end)

    scrollingFrame:SetTextCopyable(options.copyable)
    if options.copyable then
        scrollingFrame:EnableMouse(true)
    end


    if options.showScrollBar then
        self.scrollBar = CreateFrame("EventFrame", nil, self.frame, "MinimalScrollBar")
        self.scrollBar:SetPoint("TOPLEFT", self.frame, "TOPRIGHT")
        self.scrollBar:SetHeight(options.sizeY)

        ScrollUtil.InitScrollingMessageFrameWithScrollBar(self.frame, self.scrollBar, not options.enableScrolling);
    end
end

function GGUI.ScrollingMessageFrame:AddMessage(message)
    self.frame:AddMessage(message)
end

function GGUI.ScrollingMessageFrame:Clear(message)
    self.frame:Clear(message)
end

function GGUI.ScrollingMessageFrame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.frame)
end

--- GGUI.Button

---@class GGUI.ButtonStatus[]
---@field statusID string
---@field sizeX? number
---@field sizeY? number
---@field adjustWidth? boolean
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field label? string
---@field enabled? boolean
---@field activationCallback? function

---@class GGUI.Button.ConstructorOptions : GGUI.ConstructorOptions
---@field label? string
---@field labelTextureOptions? GGUI.TextureConstructorOptions
---@field parent? Frame
---@field anchorPoints? GGUI.AnchorPoint[]
---@field anchorParent? Region -- DEPRICATED Use anchorPoints
---@field anchorA? FramePoint -- DEPRICATED Use anchorPoints
---@field anchorB? FramePoint -- DEPRICATED Use anchorPoints
---@field offsetX? number -- DEPRICATED Use anchorPoints
---@field offsetY? number -- DEPRICATED Use anchorPoints
---@field sizeX? number
---@field sizeY? number
---@field adjustWidth? boolean
---@field clickCallback? fun(button: GGUI.Button, mouseButton: MouseButton)
---@field initialStatusID? string
---@field macro? boolean
---@field secure? boolean
---@field macroText? string
---@field scale? number
---@field buttonTextureOptions? GGUI.ButtonTextureOptions
---@field fontOptions? GGUI.FontOptions
---@field cleanTemplate? boolean
---@field hideBackground? boolean
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.FontOptions
---@field fontFile? string
---@field height? number
---@field flags? "MONOCHROME" | "OUTLINE" | "THICK"

---@class GGUI.ButtonTextureOptions
---@field highlight? string
---@field normal? string
---@field pushed? string
---@field disabled? string
---@field isAtlas? boolean
---@field highlightBlendmode? BlendMode

---@class GGUI.Button : GGUI.Widget
---@overload fun(options:GGUI.Button.ConstructorOptions): GGUI.Button
GGUI.Button = GGUI.Widget:extend()
---@param options GGUI.Button.ConstructorOptions
function GGUI.Button:new(options)
    self.statusList = {}
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.scale = options.scale or 1
    self.originalAnchorA = options.anchorA
    self.originalAnchorB = options.anchorB
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    self.originalOffsetX = options.offsetX
    self.originalOffsetY = options.offsetY
    options.sizeX = options.sizeX or 15
    options.sizeY = options.sizeY or 25
    self.originalX = options.sizeX
    self.originalY = options.sizeY
    self.originalText = options.label
    options.adjustWidth = options.adjustWidth or false
    self.originalParent = options.parent or UIParent
    self.originalAnchorParent = options.anchorParent or UIParent
    self.activeStatusID = options.initialStatusID
    self.macro = options.macro or false
    self.secure = options.secure or false
    self.macroText = options.macroText or ""
    self.cleanTemplate = options.cleanTemplate or false

    ---@type string?
    local templates = "UIPanelButtonTemplate" -- Note: this template is wierd with custom highlight textures..

    if self.cleanTemplate then
        templates = nil
    end

    if self.macro or self.secure then
        if self.cleanTemplate then
            templates = "InsecureActionButtonTemplate"
        else
            templates = "InsecureActionButtonTemplate, " .. templates
        end
    end

    local button = CreateFrame("Button", nil, options.parent, templates)
    GGUI.Button.super.new(self, button)
    button:SetScale(options.scale)

    if options.hideBackground then
        button.Left:Hide();
        button.Middle:Hide();
        button.Right:Hide();
    end

    if options.buttonTextureOptions then
        if options.buttonTextureOptions.isAtlas then
            button:ClearNormalTexture()
            button:ClearPushedTexture()
            button:ClearDisabledTexture()
            button:ClearHighlightTexture()
            if options.buttonTextureOptions.normal then
                button:SetNormalAtlas(options.buttonTextureOptions.normal)
            end
            if options.buttonTextureOptions.pushed then
                button:SetPushedAtlas(options.buttonTextureOptions.pushed)
            end
            if options.buttonTextureOptions.disabled then
                button:SetDisabledAtlas(options.buttonTextureOptions.disabled)
            end
            if options.buttonTextureOptions.highlight then
                button:SetHighlightAtlas(options.buttonTextureOptions.highlight,
                    options.buttonTextureOptions.highlightBlendmode or "ADD")
            end
        else
            button:ClearNormalTexture()
            button:ClearPushedTexture()
            button:ClearDisabledTexture()
            button:ClearHighlightTexture()

            if options.buttonTextureOptions.normal then
                button:SetNormalTexture(options.buttonTextureOptions.normal)
            end
            if options.buttonTextureOptions.pushed then
                button:SetPushedTexture(options.buttonTextureOptions.pushed)
            end
            if options.buttonTextureOptions.disabled then
                button:SetDisabledTexture(options.buttonTextureOptions.disabled)
            end
            if options.buttonTextureOptions.highlight then
                button:SetHighlightTexture(options.buttonTextureOptions.highlight,
                    options.buttonTextureOptions.highlightBlendmode or "ADD")
            end
        end
    end

    if options.fontOptions then
        local fontString = button:GetFontString()
        if fontString then
            fontString:SetFont(options.fontOptions.fontFile or nil, options.fontOptions.height or 12,
                options.fontOptions.flags or "")
        end
    end

    if self.macro then
        button:SetAttribute("type1", "macro")
        button:SetAttribute("macrotext", self.macroText)
        -- needs to be explicitly set for macro buttons
        button:RegisterForClicks("AnyUp", "AnyDown")
    end

    button:SetText(options.label)
    local labelTextureOptions = options.labelTextureOptions
    if labelTextureOptions then
        labelTextureOptions.parent = labelTextureOptions.parent or options.parent
        labelTextureOptions.anchorParent = labelTextureOptions.anchorParent or self.frame
        labelTextureOptions.sizeX = labelTextureOptions.sizeX or options.sizeX * 0.7
        labelTextureOptions.sizeY = labelTextureOptions.sizeY or options.sizeY * 0.7
        self.labelTexture = GGUI.Texture(labelTextureOptions)
    end

    if options.adjustWidth then
        button:SetSize(button:GetTextWidth() + options.sizeX, options.sizeY)
    else
        button:SetSize(options.sizeX, options.sizeY)
    end

    if options.anchorPoints then
        self:SetPointsByAnchorPoints(options.anchorPoints)
    else
        button:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    end

    -- to not overwrite click script if macro button
    if not self.macro then
        self.clickCallback = options.clickCallback

        button:RegisterForClicks("AnyUp", "AnyDown")

        button:SetScript("OnClick", function(_, button, down)
            if down and self.clickCallback then
                self.clickCallback(self, button)
            end
        end)
    end

    self.button = button

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(self.button, self)
    end
end

function GGUI.Button:SetVisible(visible)
    GGUI.Button.super.SetVisible(self, visible)
    if self.labelTexture then
        self.labelTexture:SetVisible(visible)
    end
end

function GGUI.Button:SetAttribute(name, value)
    self.frame:SetAttribute(name, value)
end

--- Can be used to set the macro text of the button (only available if macro option was set)
function GGUI.Button:SetMacroText(macroText)
    if not self.macro then
        GGUI:ThrowError("Trying to set a macro text on a button without macro property set to true")
    end
    self.macroText = macroText
    self:SetAttribute("macrotext", self.macroText)
end

---@param text string
---@param width? number
---@param adjustWidth? boolean
function GGUI.Button:SetText(text, width, adjustWidth)
    local fontString = self.button:GetFontString()
    fontString:SetText(text)
    if width then
        if adjustWidth then
            self.frame:SetSize(self.frame:GetTextWidth() + width, self.originalY)
        else
            self.frame:SetSize(width, self.originalY)
        end
    elseif adjustWidth then
        width = self.originalX
        self.frame:SetSize(self.frame:GetTextWidth() + width, self.originalY)
    end
end

--- Set a list of predefined GGUI.ButtonStatus
---@param statusList GGUI.ButtonStatus[]
function GGUI.Button:SetStatusList(statusList)
    -- map statuslist to their ids
    table.foreach(statusList, function(_, status)
        if not status.statusID then
            GGUI:ThrowError("ButtonStatus without statusID")
        end
        self.statusList[status.statusID] = status
    end)
end

function GGUI.Button:SetStatus(statusID)
    local buttonStatus = self.statusList[statusID]
    self.activeStatusID = statusID

    if buttonStatus then
        if buttonStatus.label then
            self.frame:SetText(buttonStatus.label)
        end
        if buttonStatus.adjustWidth then
            if buttonStatus.sizeX then
                self.frame:SetWidth(self.frame:GetTextWidth() + buttonStatus.sizeX)
            else
                self.frame:SetWidth(self.frame:GetTextWidth() + self.originalX)
            end
        elseif buttonStatus.sizeX then
            self.frame:SetWidth(buttonStatus.sizeX)
        end
        if buttonStatus.sizeY then
            self.frame:SetHeight(buttonStatus.sizeY)
        end
        if buttonStatus.enabled ~= nil then
            self.frame:SetEnabled(buttonStatus.enabled)
        end
        if buttonStatus.offsetX or buttonStatus.offsetY or buttonStatus.anchorParent or buttonStatus.anchorA or buttonStatus.anchorB then
            local offsetX = buttonStatus.offsetX or self.originalOffsetX
            local offsetY = buttonStatus.offsetY or self.originalOffsetY
            local anchorParent = buttonStatus.anchorParent or self.originalAnchorParent
            local anchorA = buttonStatus.anchorA or self.originalAnchorA
            local anchorB = buttonStatus.anchorB or self.originalAnchorB

            self.frame:ClearAllPoints()
            self.frame:SetPoint(anchorA, anchorParent, anchorB, offsetX, offsetY)
        end
        if buttonStatus.activationCallback then
            buttonStatus.activationCallback(self, statusID)
        end
    end
end

---@return string statusID
function GGUI.Button:GetStatus()
    return tostring(self.activeStatusID)
end

--- GGUI.Tab

---@class GGUI.TabConstructorOptions : GGUI.ConstructorOptions
---@field buttonOptions? GGUI.Button.ConstructorOptions
---@field canBeEnabled? boolean
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field backdropOptions? GGUI.BackdropOptions

---@class GGUI.Tab : GGUI.Widget
---@overload fun(options:GGUI.TabConstructorOptions): GGUI.Tab
GGUI.Tab = GGUI.Object:extend()
---@param options GGUI.TabConstructorOptions
function GGUI.Tab:new(options)
    options = options or {}
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 100
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.isGGUI = true

    self.button = GGUI.Button(options.buttonOptions)
    self.canBeEnabled = options.canBeEnabled or false

    self.content = CreateFrame("frame", nil, options.parent, "BackdropTemplate")
    self.content:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    self.content:SetSize(options.sizeX, options.sizeY)

    GGUI:SetBackdropByBackdropOptions(self.content, options.backdropOptions)
end

function GGUI.Tab:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.content)
end

--- GGUI.TabSystem

---@class GGUI.TabSystem : Object
---@overload fun(tabs:GGUI.Tab[]): GGUI.TabSystem
GGUI.TabSystem = GGUI.Object:extend()

---@param tabList GGUI.Tab[]
function GGUI.TabSystem:new(tabList)
    self.isGGUI = true
    self.tabs = tabList
    if #tabList == 0 then
        return
    end
    -- show first tab in list
    for _, tab in pairs(tabList) do
        tab.button.frame:SetScript("OnClick", function(self)
            for _, otherTab in pairs(tabList) do
                ---@type GGUI.Tab
                otherTab.content:Hide()
                otherTab.button:SetEnabled(otherTab.canBeEnabled)
            end
            tab.content:Show()
            tab.button:SetEnabled(false)
        end)
        tab.content:Hide()
    end
    tabList[1].content:Show()
    tabList[1].button:SetEnabled(false)
end

function GGUI.TabSystem:EnableHyperLinksForFrameAndChilds()
    table.foreach(self.tabs, function(_, tab)
        GGUI:EnableHyperLinksForFrameAndChilds(tab.content)
    end)
end

--- GGUI.Checkbox
---@class GGUI.Checkbox : GGUI.Widget
---@overload fun(options:GGUI.CheckboxConstructorOptions): GGUI.Checkbox
GGUI.Checkbox = GGUI.Widget:extend()

---@class GGUI.CheckboxConstructorOptions : GGUI.ConstructorOptions
---@field label? string
---@field labelOptions? GGUI.TextConstructorOptions
---@field tooltip? string
---@field initialValue? boolean
---@field clickCallback? fun(checkbox:GGUI.Checkbox, checked:boolean)
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number

---@param options GGUI.CheckboxConstructorOptions
function GGUI.Checkbox:new(options)
    options = options or {}
    options.label = options.label or ""
    self.label = options.label
    options.initialValue = options.initialValue or false
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    self.clickCallback = options.clickCallback

    local checkBox = CreateFrame("CheckButton", nil, options.parent, "ChatConfigCheckButtonTemplate")
    GGUI.Checkbox.super.new(self, checkBox)
    ---@type ChatConfigCheckButtonTemplate|CheckButton
    self.frame = self.frame
    checkBox:SetHitRectInsets(0, 0, 0, 0); -- see https://wowpedia.fandom.com/wiki/API_Frame_SetHitRectInsets
    checkBox:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    if not options.labelOptions then
        checkBox.Text:SetText(options.label)
    else
        ---@type GGUI.TextConstructorOptions
        local labelOptions = {
            text = options.labelOptions.text or options.label or "",
            anchorParent = options.labelOptions.anchorParent or checkBox,
            parent = options.labelOptions.parent or options.parent,
            anchorA = options.labelOptions.anchorA or "LEFT",
            anchorB = options.labelOptions.anchorB or "RIGHT",
            offsetX = options.labelOptions.offsetX or 0,
            offsetY = options.labelOptions.offsetY or 0,
            justifyOptions = options.labelOptions.justifyOptions or { type = "H", align = "LEFT" },
            font = options.labelOptions.font,
            fixedWidth = options.labelOptions.fixedWidth,
            fontOptions = options.labelOptions.fontOptions,
            scale = options.labelOptions.scale or 1,
        }
        self.labelText = GGUI.Text(labelOptions)
    end
    checkBox.tooltip = options.tooltip
    -- there already is an existing OnClick script that plays a sound, hook it
    checkBox:SetChecked(options.initialValue)
    checkBox:HookScript("OnClick", function()
        if self.clickCallback then
            self.clickCallback(self, self.frame:GetChecked())
        end
    end)
end

function GGUI.Checkbox:GetChecked()
    return self.frame:GetChecked()
end

function GGUI.Checkbox:SetChecked(value)
    return self.frame:SetChecked(value)
end

---@param label? string
function GGUI.Checkbox:SetLabel(label)
    if not self.labelText then
        self.frame.Text:SetText(label or "")
    else
        self.labelText:SetText(label or "")
    end
end

function GGUI.Checkbox:SetVisible(visible)
    GGUI.Checkbox.super.SetVisible(self, visible)
    if self.labelText then
        self.labelText:SetVisible(visible)
    end
end

--- GGUI.Slider

---@class GGUI.SliderConstructorOptions : GGUI.ConstructorOptions
---@field label? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field orientation? string
---@field minValue? number
---@field maxValue? number
---@field initialValue? number
---@field step? number
---@field globalName? string
---@field onValueChangedCallback? function

---@class GGUI.Slider : GGUI.Widget
---@overload fun(options:GGUI.SliderConstructorOptions): GGUI.Slider
GGUI.Slider = GGUI.Widget:extend()
---@param options GGUI.SliderConstructorOptions
function GGUI.Slider:new(options)
    options = options or {}
    options.label = options.label or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 150
    options.sizeY = options.sizeY or 25
    options.orientation = options.orientation or "HORIZONTAL"
    options.minValue = options.minValue or 0
    options.maxValue = options.maxValue or 1
    options.initialValue = options.initialValue or 0
    options.globalName = options.globalName or ("GGUISlider" .. (tostring(GetTimePreciseSec() * 1000)))
    self.onValueChangedCallback = options.onValueChangedCallback

    local newSlider = CreateFrame("Slider", options.globalName, options.parent, "MinimalSliderWithSteppersTemplate ")
    GGUI.Slider.super.new(self, newSlider)
    newSlider:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    newSlider:SetSize(options.sizeX, options.sizeY)

    newSlider:RegisterCallback("OnValueChanged",
        function(...)
            if self.onValueChangedCallback then
                self.onValueChangedCallback(...)
            end
        end)

    newSlider.LeftText:SetText(GUTIL:ColorizeText(options.label, GUTIL.COLORS.WHITE))
    newSlider.LeftText:Show()

    local formatters = {}
    local right = newSlider.Label.Right
    formatters[right] = CreateMinimalSliderFormatter(right,
        function(value) return GUTIL:ColorizeText(value, GUTIL.COLORS.WHITE) end);

    newSlider:Init(options.initialValue, options.minValue, options.maxValue,
        options.step and ((options.maxValue / options.step) - 1) or (options.maxValue - 1), formatters)
end

--- GGUI.HelpIcon
---@class GGUI.HelpIconConstructorOptions : GGUI.ConstructorOptions
---@field text? string
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field scale? number

---@class GGUI.HelpIcon : GGUI.Widget
---@overload fun(options:GGUI.HelpIconConstructorOptions): GGUI.HelpIcon
GGUI.HelpIcon = GGUI.Widget:extend()

---@param options GGUI.HelpIconConstructorOptions
function GGUI.HelpIcon:new(options)
    options = options or {}
    options.text = options.text or ""
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.scale = options.scale or 1

    local helpButton = CreateFrame("Button", nil, options.parent)
    GGUI.HelpIcon.super.new(self, helpButton)
    helpButton.tooltipText = options.text
    helpButton:SetNormalTexture("Interface\\common\\help-i")
    helpButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    helpButton:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    helpButton:SetSize(options.sizeX or 30, options.sizeY or 30)
    helpButton:SetScale(options.scale)

    helpButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(helpButton, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(self.tooltipText)
        GameTooltip:Show()
    end)
    helpButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function GGUI.HelpIcon:SetText(text)
    self.frame.tooltipText = text
end

--- GGUI.ScrollFrame

---@class GGUI.ScrollFrameConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field offsetTOP? number
---@field offsetLEFT? number
---@field offsetRIGHT? number
---@field offsetBOTTOM? number
---@field showBorder? boolean
---@field hideScrollbar? boolean
---@field disableScrolling? boolean

---@class GGUI.ScrollFrame : Object
---@overload fun(options:GGUI.ScrollFrameConstructorOptions): GGUI.ScrollFrame
GGUI.ScrollFrame = GGUI.Object:extend()
---@param options GGUI.ScrollFrameConstructorOptions
function GGUI.ScrollFrame:new(options)
    self.isGGUI = true
    options = options or {}
    options.offsetTOP = options.offsetTOP or 0
    options.offsetLEFT = options.offsetLEFT or 0
    options.offsetRIGHT = options.offsetRIGHT or 0
    options.offsetBOTTOM = options.offsetBOTTOM or 0
    self.hideScrollbar = options.hideScrollbar or false

    local scrollFrame = CreateFrame("ScrollFrame", nil, options.parent, "UIPanelScrollFrameTemplate, BackdropTemplate")
    local scrollBarOffsetX = 7
    self.scrollBar = CreateFrame("EventFrame", nil, scrollFrame, "MinimalScrollBar")
    self.scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", scrollBarOffsetX, 0)
    self.scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", scrollBarOffsetX, 0)

    ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, self.scrollBar);

    self.scrollBar:HookScript("OnShow", function()
        if self.hideScrollbar then
            self.scrollBar:Hide()
        end
    end)

    scrollFrame.ScrollBar:HookScript("OnShow", function()
        -- always hide default scroll bar
        scrollFrame.ScrollBar:Hide();
    end)

    if options.showBorder then
        -- border around scrollframe
        local borderFrame = CreateFrame("Frame", nil, options.parent, "BackdropTemplate")
        borderFrame:SetSize(options.parent:GetWidth(), options.parent:GetHeight())
        if self.hideScrollbar then
            borderFrame:SetPoint("TOP", options.parent, "TOP", 0, options.offsetTOP)
            borderFrame:SetPoint("LEFT", options.parent, "LEFT", options.offsetLEFT, 0)
            borderFrame:SetPoint("RIGHT", options.parent, "RIGHT", options.offsetRIGHT, 0)
            borderFrame:SetPoint("BOTTOM", options.parent, "BOTTOM", 0, options.offsetBOTTOM)
        else
            borderFrame:SetPoint("TOP", options.parent, "TOP", 0, options.offsetTOP + 5)
            borderFrame:SetPoint("LEFT", options.parent, "LEFT", options.offsetLEFT - 5, 0)
            borderFrame:SetPoint("RIGHT", options.parent, "RIGHT", options.offsetRIGHT + 26, 0)
            borderFrame:SetPoint("BOTTOM", options.parent, "BOTTOM", 0, options.offsetBOTTOM - 6)
        end
        borderFrame:SetBackdrop({
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
        })
        borderFrame:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)
    end
    scrollFrame.scrollChild = CreateFrame("frame")
    local scrollChild = scrollFrame.scrollChild
    scrollFrame:SetSize(options.parent:GetWidth(), options.parent:GetHeight())
    scrollFrame:SetPoint("TOP", options.parent, "TOP", 0, options.offsetTOP)
    scrollFrame:SetPoint("LEFT", options.parent, "LEFT", options.offsetLEFT, 0)
    scrollFrame:SetPoint("RIGHT", options.parent, "RIGHT", options.offsetRIGHT, 0)
    scrollFrame:SetPoint("BOTTOM", options.parent, "BOTTOM", 0, options.offsetBOTTOM)
    scrollFrame:SetScrollChild(scrollFrame.scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth())
    scrollChild:SetHeight(1)

    if options.disableScrolling then
        scrollFrame:EnableMouseWheel(false)
    end

    self.scrollFrame = scrollFrame
    self.content = scrollChild
end

function GGUI.ScrollFrame:ScrollDown()
    self.scrollFrame:SetVerticalScroll(self.scrollFrame:GetVerticalScrollRange())
end

function GGUI.ScrollFrame:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.content)
end

--- GGUI.TextInput

---@class GGUI.TextInputConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field initialValue? string
---@field autoFocus? boolean
---@field font? string
---@field onTextChangedCallback? function
---@field onEnterCallback? function Default: Clear Focus
---@field onEscapeCallback? function Default: Clear Focus
---@field onTabPressedCallback? fun(input: GGUI.TextInput)
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.TextInput : GGUI.Widget
---@overload fun(options:GGUI.TextInputConstructorOptions): GGUI.TextInput
GGUI.TextInput = GGUI.Widget:extend()
---@param options GGUI.TextInputConstructorOptions
function GGUI.TextInput:new(options)
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 25
    options.autoFocus = options.autoFocus or false
    options.font = options.font or "ChatFontNormal"
    options.initialValue = options.initialValue or ""
    self.onTextChangedCallback = options.onTextChangedCallback
    self.onEnterCallback = options.onEnterCallback
    self.onEscapeCallback = options.onEscapeCallback
    self.onTabPressedCallback = options.onTabPressedCallback

    local textInput = CreateFrame("EditBox", nil, options.parent, "InputBoxTemplate")
    GGUI.TextInput.super.new(self, textInput)
    textInput:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    textInput:SetSize(options.sizeX, options.sizeY)
    textInput:SetAutoFocus(options.autoFocus) -- dont automatically focus
    textInput:SetFontObject(options.font)
    textInput:SetText(options.initialValue)
    textInput:SetScript("OnEnterPressed", function()
        if self.onEnterCallback then
            self.onEnterCallback(self)
        else
            textInput:ClearFocus()
        end
    end)
    textInput:SetScript("OnEscapePressed", function()
        if self.onEscapeCallback then
            self.onEscapeCallback(self)
        else
            textInput:ClearFocus()
        end
    end)

    textInput:SetScript("OnTextChanged", function(_, userInput)
        if self.onTextChangedCallback then
            self.onTextChangedCallback(self, self:GetText(), userInput)
        end
    end)

    textInput:SetScript("OnTabPressed", function()
        if self.onTabPressedCallback then
            self.onTabPressedCallback(self)
        end
    end)

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(textInput, self)
    end
end

function GGUI.TextInput:GetText()
    return self.frame:GetText()
end

function GGUI.TextInput:SetText(text, userInput)
    self.frame:SetText(text)

    if self.onTextChangedCallback then
        self.onTextChangedCallback(self, self:GetText(), userInput)
    end
end

--- GGUI.CurrencyInput

---@class GGUI.CurrencyInputConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field initialValue? number
---@field onValueValidCallback? function
---@field onValidationChangedCallback? function
---@field showFormatHelpIcon? boolean
---@field borderAdjustWidth? number
---@field borderAdjustHeight? number
---@field borderWidth? number
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.CurrencyInput : Object
---@overload fun(options:GGUI.CurrencyInputConstructorOptions): GGUI.CurrencyInput
GGUI.CurrencyInput = GGUI.Object:extend()

---@param options GGUI.CurrencyInputConstructorOptions
function GGUI.CurrencyInput:new(options)
    self.isGGUI = true
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 25
    options.initialValue = options.initialValue or 0
    options.borderAdjustWidth = options.borderAdjustWidth or 1
    options.borderAdjustHeight = options.borderAdjustHeight or 1
    options.borderWidth = options.borderWidth or 25
    options.showFormatHelpIcon = options.showFormatHelpIcon or false

    self.onValidationChangedCallback = options.onValidationChangedCallback
    self.onValueValidCallback = options.onValueValidCallback

    local currencyInput = self

    currencyInput.isValid = true

    currencyInput.total = 0
    currencyInput.gold = 0
    currencyInput.silver = 0
    currencyInput.copper = 0

    local textInput = GGUI.TextInput({
        parent = options.parent,
        anchorParent = options.anchorParent,
        anchorA = options.anchorA,
        anchorB = options.anchorB,
        offsetX = options.offsetX,
        offsetY = options.offsetY,
        sizeX = options.sizeX,
        sizeY = options.sizeY,
        initialValue = tostring(options.initialValue),
        onTextChangedCallback = function(self, input, userInput)
            if userInput then
                -- validate and color text, and adapt save button
                input = input or ""
                -- remove colorizations
                -- input = string.gsub(input, GUTIL.COLORS.GOLD, "")
                -- input = string.gsub(input, GUTIL.COLORS.SILVER, "")
                -- input = string.gsub(input, GUTIL.COLORS.COPPER, "")
                -- input = string.gsub(input, "|r", "")
                -- input = string.gsub(input, "|c", "")
                input = GUTIL:StripColor(input)

                local valid = GUTIL:ValidateMoneyString(input)
                currencyInput.isValid = valid

                if valid then
                    local gold = tonumber(string.match(input, "(%d+)g"))
                    local silver = tonumber(string.match(input, "(%d+)s"))
                    local copper = tonumber(string.match(input, "(%d+)c"))
                    -- colorize and write
                    local gC = GUTIL:ColorizeText("g", GUTIL.COLORS.GOLD)
                    local sC = GUTIL:ColorizeText("s", GUTIL.COLORS.SILVER)
                    local cC = GUTIL:ColorizeText("c", GUTIL.COLORS.COPPER)
                    local colorizedText = ""

                    if gold then
                        colorizedText = colorizedText .. gold .. gC
                    end
                    if silver then
                        colorizedText = colorizedText .. silver .. sC
                    end
                    if copper then
                        colorizedText = colorizedText .. copper .. cC
                    end

                    currencyInput.textInput:SetText(colorizedText)

                    currencyInput.gold = gold or 0
                    currencyInput.silver = silver or 0
                    currencyInput.copper = copper or 0
                    currencyInput.total = currencyInput.gold * 10000 + currencyInput.silver * 100 + currencyInput.copper
                    if currencyInput.onValueValidCallback then
                        currencyInput.onValueValidCallback(currencyInput)
                    end
                end

                currencyInput.border:SetValid(valid)

                if currencyInput.onValidationChangedCallback then
                    currencyInput.onValidationChangedCallback(valid)
                end
            end
        end,
    })

    self.textInput = textInput

    local validationBorder = CreateFrame("Frame", nil, textInput.frame, "BackdropTemplate")
    self.border = validationBorder
    validationBorder:SetSize(textInput:GetWidth() * 1.3 * options.borderAdjustWidth,
        textInput:GetHeight() * 1.6 * options.borderAdjustHeight)
    validationBorder:SetPoint("CENTER", textInput.frame, "CENTER", -2, 0)
    validationBorder:SetBackdrop({
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = options.borderWidth,
    })
    function validationBorder:SetValid(valid)
        if valid then
            validationBorder:Hide()
        else
            validationBorder:Show()
            validationBorder:SetBackdropBorderColor(1, 0, 0, 0.5)
        end
    end

    validationBorder:Hide()
    textInput.validationBorder = validationBorder

    self:SetValue(options.initialValue)

    if options.showFormatHelpIcon then
        self.helpIcon = GGUI.HelpIcon({
            parent = options.parent,
            text = "Format: 100g10s1c",
            textInput.frame,
            anchorParent = textInput.frame,
            anchorA = "LEFT",
            anchorB = "RIGHT",
            offsetX = 5,
        })
    end

    self.tooltipOptions = options.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(self.textInput.frame, self)
    end
end

--- called by non user input
---@param total number copperValue in total
function GGUI.CurrencyInput:SetValue(total)
    local gold, silver, copper = GUTIL:GetMoneyValuesFromCopper(total)
    local gC = GUTIL:ColorizeText("g", GUTIL.COLORS.GOLD)
    local sC = GUTIL:ColorizeText("s", GUTIL.COLORS.SILVER)
    local cC = GUTIL:ColorizeText("c", GUTIL.COLORS.COPPER)
    local colorizedText = ((gold > 0 and (gold .. gC)) or "") ..
        ((silver > 0 and (silver .. sC)) or "") .. ((copper > 0 and (copper .. cC)) or "")
    if gold == 0 and silver == 0 and copper == 0 then
        colorizedText = "0" .. cC
    end
    -- print("gold: " .. tostring(gold))
    -- print("silver: " .. tostring(silver))
    -- print("copper: " .. tostring(copper))
    -- print("colorized set value: " .. tostring(colorizedText))
    self.textInput:SetText(colorizedText)

    self.gold = gold
    self.silver = silver
    self.copper = copper
    self.total = gold * 10000 + silver * 100 + copper
end

function GGUI.CurrencyInput:Show()
    self.textInput:Show()
    if self.helpIcon then
        self.helpIcon:Show()
    end
end

function GGUI.CurrencyInput:Hide()
    self.textInput:Hide()
    if self.helpIcon then
        self.helpIcon:Hide()
    end
end

--- GGUI.NumericInput

---@class GGUI.NumericInputConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Region
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field initialValue? number
---@field allowDecimals? boolean
---@field minValue? number
---@field maxValue? number
---@field autoFocus? boolean
---@field font? string
---@field onNumberValidCallback? fun(input:GGUI.NumericInput)
---@field onValidationChangedCallback? fun(valid:boolean)
---@field onTabPressedCallback? fun(input:GGUI.NumericInput)
---@field onEnterPressedCallback? fun(input:GGUI.NumericInput, value)
---@field incrementOneButtons? boolean
---@field incrementFiveButtons? boolean
---@field buttonsScale? number
---@field borderAdjustWidth? number
---@field borderAdjustHeight? number
---@field borderWidth? number
---@field tooltipOptions? GGUI.TooltipOptions
---@field labelOptions? GGUI.TextConstructorOptions

---@class GGUI.NumericInput : Object
---@overload fun(options:GGUI.NumericInputConstructorOptions): GGUI.NumericInput
GGUI.NumericInput = GGUI.Object:extend()
---@param options GGUI.NumericInputConstructorOptions
function GGUI.NumericInput:new(options)
    self.isGGUI = true
    options = options or {}
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 25
    options.initialValue = options.initialValue or 0
    options.allowDecimals = options.allowDecimals or false
    options.autoFocus = options.autoFocus or false
    options.font = options.font or "ChatFontNormal"
    options.incrementOneButtons = options.incrementOneButtons or false
    options.incrementFiveButtons = options.incrementFiveButtons or false
    options.buttonsScale = options.buttonsScale or 1
    options.borderAdjustWidth = options.borderAdjustWidth or 1
    options.borderAdjustHeight = options.borderAdjustHeight or 1
    options.borderWidth = options.borderWidth or 25
    self.onNumberValidCallback = options.onNumberValidCallback
    self.onValidationChangedCallback = options.onValidationChangedCallback
    self.onTabPressedCallback = options.onTabPressedCallback
    self.onEnterPressedCallback = options.onEnterPressedCallback
    self.allowDecimals = options.allowDecimals
    self.autoFocus = options.autoFocus
    self.minValue = options.minValue
    self.maxValue = options.maxValue
    self.currentValue = options.initialValue or 0
    local numericInput = self

    ---@type GGUI.TextInput | GGUI.Widget
    self.textInput = GGUI.TextInput({
        parent = options.parent,
        anchorParent = options.anchorParent,
        anchorA = options.anchorA,
        anchorB = options.anchorB,
        offsetX = options.offsetX,
        offsetY = options.offsetY,
        sizeX = options.sizeX,
        sizeY = options.sizeY,
        initialValue = options.initialValue,
        autoFocus = options.autoFocus,
        onEnterCallback = function(textInput)
            -- always userinput
            local input = textInput:GetText()
            local valid = GUTIL:ValidateNumberString(input, self.minValue, self.maxValue, self.allowDecimals)
            if self.onEnterPressedCallback and valid then
                numericInput.currentValue = tonumber(input)
                textInput:SetText(input)
                self.onEnterPressedCallback(self, tonumber(input))
            end
        end,
        onTextChangedCallback = function(textInput, input, userInput)
            if userInput then
                local valid = GUTIL:ValidateNumberString(input, self.minValue, self.maxValue, self.allowDecimals)
                if valid then
                    numericInput.currentValue = tonumber(input)
                    textInput:SetText(input)
                    if numericInput.onNumberValidCallback then
                        numericInput.onNumberValidCallback(numericInput)
                    end
                else
                end
                numericInput.validationBorder:SetValid(valid)
                if numericInput.onValidationChangedCallback then
                    numericInput.onValidationChangedCallback(valid)
                end
            end
        end,
        onTabPressedCallback = function()
            if self.onTabPressedCallback then
                self.onTabPressedCallback(self)
            end
        end
    })

    if options.incrementOneButtons then
        local buttonWidth = 5
        local buttonHeight = options.sizeY / 2 - 1
        local buttonOffsetX = 0
        local buttonOffsetY = -1
        self.textInput.frame.plusButton = GGUI.Button({
            parent = self.textInput.frame,
            anchorParent = self.textInput.frame,
            anchorA = "TOPLEFT",
            anchorB = "TOPRIGHT",
            offsetX = buttonOffsetX,
            offsetY = buttonOffsetY,
            label = "+",
            sizeX = buttonWidth,
            sizeY = buttonHeight,
            adjustWidth = true,
            scale = options.buttonsScale,
            clickCallback = function()
                local input = tonumber(numericInput.textInput:GetText())
                if input then
                    local valid = GUTIL:ValidateNumberString(tostring(input + 1), self.minValue, self.maxValue,
                        self.allowDecimals)

                    if valid then
                        numericInput.currentValue = input + 1
                        numericInput.textInput:SetText(input + 1)
                        if numericInput.onNumberValidCallback then
                            numericInput.onNumberValidCallback(numericInput)
                        end
                    end

                    if numericInput.onValidationChangedCallback then
                        numericInput.onValidationChangedCallback(valid)
                    end
                end
            end,
        })
        self.textInput.frame.minusButton = GGUI.Button({
            parent = self.textInput.frame,
            anchorParent = self.textInput.frame.plusButton.frame,
            anchorA = "TOP",
            anchorB = "BOTTOM",
            label = "-",
            sizeX = buttonWidth,
            sizeY = buttonHeight,
            adjustWidth = true,
            scale = options.buttonsScale,
            clickCallback = function()
                local input = tonumber(numericInput.textInput:GetText())
                if input then
                    local valid = GUTIL:ValidateNumberString(tostring(input - 1), self.minValue, self.maxValue,
                        self.allowDecimals)

                    if valid then
                        numericInput.currentValue = input - 1
                        numericInput.textInput:SetText(input - 1)
                        if numericInput.onNumberValidCallback then
                            numericInput.onNumberValidCallback(numericInput)
                        end
                    end

                    if numericInput.onValidationChangedCallback then
                        numericInput.onValidationChangedCallback(valid)
                    end
                end
            end,
        })
    end

    local validationBorder = CreateFrame("Frame", nil, self.textInput.frame, "BackdropTemplate")
    self.border = validationBorder
    validationBorder:SetSize(self.textInput.frame:GetWidth() * 1.3 * options.borderAdjustWidth,
        self.textInput.frame:GetHeight() * 1.6 * options.borderAdjustHeight)
    validationBorder:SetPoint("CENTER", self.textInput.frame, "CENTER", -2, 0)
    validationBorder:SetBackdrop({
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
        edgeSize = options.borderWidth,
    })
    function validationBorder:SetValid(valid)
        if valid then
            validationBorder:Hide()
        else
            validationBorder:Show()
            validationBorder:SetBackdropBorderColor(1, 0, 0, 0.5)
        end
    end

    validationBorder:Hide()
    self.validationBorder = validationBorder

    if options.labelOptions then
        ---@type GGUI.TextConstructorOptions
        local labelOptions = {
            parent = options.labelOptions.parent or options.parent,
            anchorParent = options.labelOptions.anchorParent or self.textInput.frame,
            anchorA = options.labelOptions.anchorA or "RIGHT",
            anchorB = options.labelOptions.anchorB or "LEFT",
            fontOptions = options.labelOptions.fontOptions,
            fixedWidth = options.labelOptions.fixedWidth,
            justifyOptions = options.labelOptions.justifyOptions or { type = "H", align = "RIGHT" },
            offsetX = options.labelOptions.offsetX or -8,
            offsetY = options.labelOptions.offsetY,
            scale = options.labelOptions.scale,
            text = options.labelOptions.text or "",
            tooltipOptions = options.labelOptions.tooltipOptions,
        }
        self.label = GGUI.Text(labelOptions)
    end

    if options.tooltipOptions then
        self.tooltipOptions = options.tooltipOptions
        GGUI:SetTooltipsByTooltipOptions(self.textInput.frame, self)
    end
end

function GGUI.NumericInput:SetVisible(visible)
    self.textInput:SetVisible(visible)
end

function GGUI.NumericInput:Hide()
    self.textInput:Hide()
end

function GGUI.NumericInput:Show()
    self.textInput:Show()
end

--- GGUI.FrameList

---@class GGUI.FrameList : GGUI.Widget
---@overload fun(options:GGUI.FrameListConstructorOptions): GGUI.FrameList
GGUI.FrameList = GGUI.Widget:extend()

---@class GGUI.FrameListConstructorOptions : GGUI.ConstructorOptions
---@field private parent? Frame
---@field rowHeight? number
---@field columnOptions GGUI.FrameList.ColumnOption[]
---@field rowConstructor fun(columns: Frame[], row: GGUI.FrameList.Row) used to construct the rows and fill the column frames with content, columns are forwarded as params (...)
---@field showBorder? boolean
---@field private anchorPoints? GGUI.AnchorPoint[]
---@field private anchorParent? Frame -- DEPRICATED Use anchorPoints
---@field private anchorA? FramePoint -- DEPRICATED Use anchorPoints
---@field private anchorB? FramePoint -- DEPRICATED Use anchorPoints
---@field private offsetX? number -- DEPRICATED Use anchorPoints
---@field private offsetY? number -- DEPRICATED Use anchorPoints
---@field sizeX? number if omitted will adjust to row width
---@field private sizeY? number will be ignored when autoAdjustHeight is set
---@field private headerOffsetX? number
---@field scale? number
---@field rowScale? number
---@field selectionOptions? GGUI.FrameList.SelectionOptions
---@field rowBackdrops? GGUI.BackdropOptions[] rows will alternate backdroplist
---@field hideScrollbar? boolean
---@field private autoAdjustHeight? boolean
---@field private autoAdjustHeightCallback? fun(newHeight: number)
---@field disableScrolling? boolean
---@field label? string

---@class GGUI.FrameList.SelectionOptions
---@field noSelectionColor boolean?
---@field hoverRGBA? table<number>
---@field selectedRGBA? table<number>
---@field selectionCallback? fun(row: GGUI.FrameList.Row, userInput:boolean)

---@class GGUI.FrameList.ColumnOption
---@field width? number
---@field label? string
---@field justifyOptions? GGUI.JustifyOptions
---@field backdropOptions? GGUI.BackdropOptions
---@field tooltipOptions? GGUI.TooltipOptions
---@field fontOptions? GGUI.FontOptions

function GGUI.FrameList:new(options)
    self.isGGUI = true
    ---@type GGUI.FrameListConstructorOptions
    options = options or {}
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.sizeY = options.sizeY or 100
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.rowHeight = options.rowHeight or 25
    options.headerOffsetX = options.headerOffsetX or 5
    options.scale = options.scale or 1
    options.rowScale = options.rowScale or 1
    self.autoAdjustHeight = options.autoAdjustHeight or false
    self.autoAdjustHeightCallback = options.autoAdjustHeightCallback
    self.maxAutoAdjustHeight = options.maxAutoAdjustHeight
    self.rowBackdrops = options.rowBackdrops
    self.rowScale = options.rowScale
    self.rowHeight = options.rowHeight
    self.selectionOptions = options.selectionOptions
    if self.selectionOptions then
        self.selectionOptions.hoverRGBA = self.selectionOptions.hoverRGBA or { 0, 1, 0, 0.3 }
        self.selectionOptions.selectedRGBA = self.selectionOptions.selectedRGBA or { 0, 1, 0, 0.6 }
        self.selectionOptions.selectionCallback = self.selectionOptions.selectionCallback or function() end
        self.selectionEnabled = true
    end
    ---@type GGUI.FrameList.Row
    self.selectedRow = nil

    if not options.columnOptions or #options.columnOptions == 0 then
        GGUI:ThrowError("FrameList needs a least one column! (columnOptions)")
    end

    if not options.rowConstructor then
        GGUI:ThrowError("FrameList needs a rowConstructor function!")
    end

    local firstColumnOffsetX = 0
    local rowWidth = firstColumnOffsetX

    table.foreach(options.columnOptions, function(_, columnOption)
        if not columnOption.width then
            GGUI:ThrowError("All Column Options need a width property!")
        end
        rowWidth = rowWidth + columnOption.width
    end)
    self.rowWidth = rowWidth
    self.columnOptions = options.columnOptions
    self.rowConstructor = options.rowConstructor

    local mainFrame = CreateFrame("Frame", nil, options.parent)
    if options.anchorPoints then
        for _, anchorPoint in ipairs(options.anchorPoints) do
            mainFrame:SetPoint(anchorPoint.anchorA, anchorPoint.anchorParent, anchorPoint.anchorB,
                anchorPoint.offsetX or 0,
                anchorPoint.offsetY or 0)
        end
    else
        mainFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    end
    mainFrame:SetSize(options.sizeX or (rowWidth + 10), options.sizeY)
    mainFrame:SetScale(options.scale)

    ---@type GGUI.ScrollFrame
    self.scrollFrame = GGUI.ScrollFrame({
        parent = mainFrame,
        offsetTOP = -5,
        offsetLEFT = 5,
        offsetRIGHT = -5,
        offsetBOTTOM = 5,
        showBorder = options.showBorder,
        hideScrollbar = options.hideScrollbar,
        disableScrolling = options.disableScrolling,
    })

    ---@type GGUI.FrameList.Row
    self.rows = {}
    ---@type GGUI.FrameList.Row
    self.activeRows = {}

    local header = CreateFrame("Frame", nil, mainFrame)
    header:SetPoint("BOTTOMLEFT", mainFrame, "TOPLEFT")
    header:SetSize(rowWidth, 25)

    local lastHeaderColumn = nil
    for index, columnOption in pairs(options.columnOptions) do
        local headerColumn = CreateFrame("Frame", nil, header)
        headerColumn:SetSize(columnOption.width, 25)

        local columnTooltipOptions = columnOption.tooltipOptions

        if columnTooltipOptions then
            columnTooltipOptions.anchor = columnTooltipOptions.anchor or "ANCHOR_CURSOR"
            columnTooltipOptions.owner = columnTooltipOptions.owner or headerColumn
        end

        headerColumn.text = GGUI.Text({
            fixedWidth = columnOption.width,
            text = columnOption.label or "",
            parent = headerColumn,
            anchorParent = headerColumn,
            justifyOptions = columnOption.justifyOptions or { type = "H", align = "LEFT" },
            fontOptions = columnOption.fontOptions,
            tooltipOptions = columnTooltipOptions,
        })

        if index == 1 then
            headerColumn:SetPoint("TOPLEFT", header, "TOPLEFT", options.headerOffsetX, 0)
        else
            headerColumn:SetPoint("LEFT", lastHeaderColumn, "RIGHT")
        end

        lastHeaderColumn = headerColumn
    end

    if options.label then
        self.label = GGUI.Text {
            parent = options.parent,
            anchorPoints = { { anchorParent = mainFrame, anchorA = "BOTTOM", anchorB = "TOP", offsetY = 5 } },
            text = options.label
        }
    end

    GGUI.FrameList.super.new(self, mainFrame)
end

---@param anchorPoints GGUI.AnchorPoint[]
function GGUI.FrameList:SetAnchorPoints(anchorPoints)
    self.frame:ClearAllPoints()
    for _, anchorPoint in ipairs(anchorPoints) do
        self.frame:SetPoint(anchorPoint.anchorA, anchorPoint.anchorParent, anchorPoint.anchorB, anchorPoint.offsetX or 0,
            anchorPoint.offsetY or 0)
    end
end

function GGUI.FrameList:SetSelectionEnabled(enabled)
    self.selectionEnabled = enabled
end

function GGUI.FrameList:ScrollDown()
    self.scrollFrame:ScrollDown()
end

--- GGUI.FrameList.Row

---@class GGUI.FrameList.Row : GGUI.Widget
---@overload fun(rowFrame: Frame, columns: Frame[], rowConstructor:fun(columns: Frame[]), frameList: GGUI.FrameList): GGUI.FrameList.Row
GGUI.FrameList.Row = GGUI.Widget:extend()

---@param rowFrame Frame
---@param columns Frame[]
---@param rowConstructor fun(columns: Frame[], row: GGUI.FrameList.Row)
---@param frameList GGUI.FrameList
function GGUI.FrameList.Row:new(rowFrame, columns, rowConstructor, frameList)
    GGUI.FrameList.Row.super.new(self, rowFrame)
    ---@type Frame
    self.frame = self.frame
    self.columns = columns
    self.active = false
    self.frameList = frameList
    ---@class GGUI.TooltipOptions?
    ---@field spellID number?
    ---@field itemID number?
    ---@field itemLink string?
    ---@field owner? Frame if omitted defaults to optionsOwner.frame
    ---@field anchor TooltipAnchor
    ---@field text string?
    ---@field textWrap? boolean
    ---@field frame? Frame
    ---@field scale? number
    ---@field frameUpdateCallback? fun(tooltipFrame: Frame) if set will be called on the given tooltip frame right before the tooltip is updated. Can be used to update the frame e.g.
    self.tooltipOptions = nil

    self.separatorLine = rowFrame:CreateLine()
    self.separatorLineRGBA = { 1, 1, 1, 1 }
    self.separatorLineThickness = 2
    self.separatorLine:SetStartPoint("BOTTOMLEFT", rowFrame)
    self.separatorLine:SetEndPoint("BOTTOMRIGHT", rowFrame)

    self.separatorLine:Hide()

    self.subFrameListEnabled = false
    ---@type GGUI.FrameList?
    self.subFrameList = nil

    ---@type function
    local onEnterSelectableRow = nil
    ---@type function
    local onLeaveSelectableRow = nil

    GGUI:SetTooltipsByTooltipOptions(rowFrame, self)

    if frameList.selectionOptions then
        self.Select = function(_, userInput)
            if self ~= frameList.selectedRow or frameList.selectionOptions.noSelectionColor then
                if not frameList.selectionOptions.noSelectionColor then
                    rowFrame:SetBackdropColor(frameList.selectionOptions.selectedRGBA[1],
                        frameList.selectionOptions.selectedRGBA[2], frameList.selectionOptions.selectedRGBA[3],
                        frameList.selectionOptions.selectedRGBA[4])
                    if frameList.selectedRow then
                        -- revert color
                        if self.originalBackdropOptions then
                            GGUI:SetBackdropByBackdropOptions(frameList.selectedRow.frame, self.originalBackdropOptions)
                        else
                            frameList.selectedRow.frame:SetBackdropColor(0, 0, 0, 0)
                        end
                    end
                end
                frameList.selectedRow = self

                frameList.selectionOptions.selectionCallback(self, userInput)
            end
        end
        rowFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8", -- You can use any texture here or a solid color
        })
        rowFrame:SetBackdropColor(0, 0, 0, 0)        -- make colorless

        onEnterSelectableRow =
            function()
                if self ~= frameList.selectedRow or frameList.selectionOptions.noSelectionColor then
                    rowFrame:SetBackdropColor(frameList.selectionOptions.hoverRGBA[1],
                        frameList.selectionOptions.hoverRGBA[2], frameList.selectionOptions.hoverRGBA[3],
                        frameList.selectionOptions.hoverRGBA[4])
                end
            end
        onLeaveSelectableRow =
            function()
                if self ~= frameList.selectedRow or frameList.selectionOptions.noSelectionColor then
                    if self.originalBackdropOptions then
                        GGUI:SetBackdropByBackdropOptions(rowFrame, self.originalBackdropOptions)
                    else
                        rowFrame:SetBackdropColor(0, 0, 0, 0)
                    end
                end
            end
    end
    -- OnMouseDown handler - Mouse click
    rowFrame:SetScript("OnMouseDown", function()
        -- subFrameList toggle has authority over selection!
        if self.subFrameListEnabled and self.subFrameList then
            self:SetSubFrameListVisible(not self.subFrameListVisible)
        elseif frameList.selectionEnabled and frameList.selectionOptions then
            self:Select(true)
        end
    end)
    rowFrame:HookScript("OnEnter", function()
        if not frameList.selectionEnabled then return end
        if onEnterSelectableRow then
            onEnterSelectableRow()
        end
    end)
    rowFrame:HookScript("OnLeave", function()
        if onLeaveSelectableRow then
            onLeaveSelectableRow()
        end
    end)
    rowConstructor(self.columns, self)
    self:Hide()
end

---@param visible boolean
---@param rgba number[]? default: white
---@param thickness number? default: 2
function GGUI.FrameList.Row:SetSeparatorLine(visible, rgba, thickness)
    rgba = rgba or self.separatorLineRGBA
    thickness = thickness or self.separatorLineThickness
    self.separatorLine:SetColorTexture(rgba[1], rgba[2], rgba[3],
        rgba[4])
    self.separatorLine:SetThickness(thickness)
    if visible then
        self.separatorLine:Show()
    else
        self.separatorLine:Hide()
    end
end

---@return number? index nil if row is not active
function GGUI.FrameList.Row:GetActiveRowIndex()
    for index, activeRow in ipairs(self.frameList.activeRows) do
        if self == activeRow then
            return index
        end
    end
    return nil
end

---@class GGUI.SubFrameListConstructorOptions : GGUI.FrameListConstructorOptions
---@field offsetX? number frameListOffsetX
---@field offsetY? number frameListOffsetY

---@param subFrameListOptions? GGUI.SubFrameListConstructorOptions
function GGUI.FrameList.Row:CreateSubFrameList(subFrameListOptions)
    subFrameListOptions = subFrameListOptions or {}
    -- set some defaults for anchoring, offsets and scale

    --self.subFrameListVisible = true

    GGUI:DebugPrint(subFrameListOptions, "Creating SubFrameList")

    if subFrameListOptions.sizeY then
        GGUI:ThrowError("Sub FrameList sizeY should not be set")
    end
    local hasLabels = table.foreach(subFrameListOptions.columnOptions, function(_, columnOption)
        if columnOption.label then
            return true
        end
    end)
    GGUI:DebugPrint(subFrameListOptions, "noLabel: " .. tostring(headerOffsetY))
    local headerOffsetY = -20
    if not hasLabels then
        headerOffsetY = 0
    end
    GGUI:DebugPrint(subFrameListOptions, "headerOffsetY: " .. tostring(headerOffsetY))
    local frameListOffsetX = (subFrameListOptions.offsetX or 0) + 10
    local frameListOffsetY = (subFrameListOptions.offsetY or 0) + -self.frameList.rowHeight + headerOffsetY
    subFrameListOptions.parent = subFrameListOptions.parent or self.frame
    subFrameListOptions.sizeY = 100
    subFrameListOptions.anchorPoints = subFrameListOptions.anchorPoints or
        { { anchorParent = self.frame, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetX = frameListOffsetX, offsetY = frameListOffsetY } }
    subFrameListOptions.autoAdjustHeight = true
    subFrameListOptions.autoAdjustHeightCallback = function(newHeight)
        if self.subFrameListVisible then
            self.frame:SetSize(self.frame:GetWidth(), self.frameList.rowHeight + newHeight + math.abs(headerOffsetY))
        end
    end


    self.subFrameList = GGUI.FrameList(subFrameListOptions)

    self.subFrameList:Hide()
end

---@param visible boolean
function GGUI.FrameList.Row:SetSubFrameListVisible(visible)
    if visible then
        self.subFrameListVisible = true
        self.subFrameList:Show()
        self.subFrameList:AdjustHeight() -- predefined adjust height callback should now resize the rowFrame accordingly
    else
        self.subFrameListVisible = false
        self.frame:SetSize(self.frame:GetWidth(), self.frameList.rowHeight)
        self.subFrameList:Hide()
    end
end

---@param index number
function GGUI.FrameList:SelectRow(index)
    if not self.selectionOptions then
        return
    end
    local row = self.activeRows[index]

    if row and row.active then
        row:Select()
    end
end

---@param predicate fun(row: GGUI.FrameList.Row): boolean
---@param defaultIndex number?
---@return number? selectedIndex
function GGUI.FrameList:SelectRowWhere(predicate, defaultIndex)
    for rowIndex, activeRow in ipairs(self.activeRows) do
        if predicate(activeRow) then
            self:SelectRow(rowIndex)
            return rowIndex
        end
    end

    if defaultIndex then
        self:SelectRow(defaultIndex)
        return defaultIndex
    end
end

function GGUI.FrameList:CreateRow()
    local rowFrame = CreateFrame("Frame", nil, self.scrollFrame.content, "BackdropTemplate")
    rowFrame:SetSize(self.rowWidth, self.rowHeight)
    rowFrame:SetScale(self.rowScale)
    if #self.rows == 0 then
        rowFrame:SetPoint("TOPLEFT", self.scrollFrame.content, "TOPLEFT")
    else
        rowFrame:SetPoint("TOPLEFT", self.rows[#self.rows].frame, "BOTTOMLEFT")
    end

    local columns = {}
    local lastColumn = nil
    for index, columnOption in pairs(self.columnOptions) do
        local columnFrame = CreateFrame("Frame", nil, rowFrame, "BackdropTemplate")
        columnFrame:SetSize(columnOption.width, self.rowHeight)

        if index == 1 then
            columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 0, 0)
        else
            columnFrame:SetPoint("LEFT", lastColumn, "RIGHT")
        end

        if columnOption.backdropOptions then
            local borderOptions = columnOption.backdropOptions.borderOptions or {}
            columnFrame:SetBackdrop({
                bgFile = columnOption.backdropOptions.bgFile,
                edgeFile = borderOptions.edgeFile,
                edgeSize = borderOptions.edgeSize,
                insets = borderOptions.insets,
                tile = columnOption.backdropOptions.tile,
                tileSize = columnOption.backdropOptions.tileSize,
            })
            columnFrame:SetBackdropColor(columnOption.backdropOptions.colorR or 0,
                columnOption.backdropOptions.colorG or 0, columnOption.backdropOptions.colorB or 0,
                columnOption.backdropOptions.colorA or 1)
            columnFrame:SetBackdropBorderColor(borderOptions.colorR or 0, borderOptions.colorG or 0,
                borderOptions.colorB or 0, borderOptions.colorA or 1)
        end

        table.insert(columns, columnFrame)

        lastColumn = columnFrame
    end

    local newRow = GGUI.FrameList.Row(rowFrame, columns, self.rowConstructor, self)

    table.insert(self.rows, newRow)

    return newRow
end

---Add row data into the list
---@param fillFunc? fun(row: GGUI.FrameList.Row, columns: Frame[]) function that receives a free row to add to the list
function GGUI.FrameList:Add(fillFunc)
    -- get an inactive row from the list of rows, call fillFunc on it
    local freeRow = GUTIL:Find(self.rows, function(row) return not row.active end)

    if not freeRow then
        -- create a new row if no row is free
        freeRow = self:CreateRow()
    end
    if fillFunc then
        fillFunc(freeRow, freeRow.columns)
    end
    freeRow.active = true
end

---@param updateFunc fun(row:GGUI.FrameList.Row)
---@param filterFunc? fun(row:GGUI.FrameList.Row)
---@param limit? number -- optional limit of max updates
function GGUI.FrameList:UpdateRows(updateFunc, filterFunc, limit)
    local count = 0
    for _, row in pairs(self.rows) do
        if row.active then
            count = count + 1
            if not filterFunc or filterFunc(row) then
                updateFunc(row)
            end

            if limit and count >= limit then
                return
            end
        end
    end
end

---@param filterFunc fun(row:GGUI.FrameList.Row)
---@return GGUI.FrameList.Row | nil row
function GGUI.FrameList:GetRow(filterFunc)
    for _, row in pairs(self.rows) do
        if row.active and filterFunc(row) then
            return row
        end
    end
end

--- removes all (up to the limit) rows where filterFunc is true from the list
---@param filterFunc? fun(row:GGUI.FrameList.Row): boolean
---@param limit? number
function GGUI.FrameList:Remove(filterFunc, limit)
    local currentRemoveCount = 0
    for _, row in pairs(self.rows) do
        if row.active then
            if (filterFunc and filterFunc(row)) or (not filterFunc) then
                row.active = false
                currentRemoveCount = currentRemoveCount + 1

                if self.selectedRow == row then
                    self.selectedRow = nil
                end

                if limit and currentRemoveCount >= limit then
                    return
                end
            end
        end
    end
end

--- Update the list display, optionally filter then show all active rows
---@param sortFunc? fun(rowA:GGUI.FrameList.Row, rowB:GGUI.FrameList.Row): boolean optional sorting before updating the display
function GGUI.FrameList:UpdateDisplay(sortFunc)
    -- filter and show active rows and hide all inactive
    -- but keep reference!!
    wipe(self.activeRows)
    tAppendAll(self.activeRows, GUTIL:Filter(self.rows, function(row)
        if row.active then
            row:Show()
            return true
        else
            row:Hide()
            return false
        end
    end))

    if #self.activeRows == 0 then
        return
    end

    if #self.activeRows > 1 and sortFunc then
        -- in place sort to keep reference!
        table.sort(self.activeRows, sortFunc)
    end

    local lastRow = nil
    for index, row in pairs(self.activeRows) do
        if index == 1 then
            row:SetPoint("TOPLEFT", self.scrollFrame.content, "TOPLEFT")
        else
            if lastRow then
                row:SetPoint("TOPLEFT", lastRow.frame, "BOTTOMLEFT")
            end
        end
        if self.rowBackdrops and #self.rowBackdrops > 0 then
            local backdropOptions = self.rowBackdrops[#self.rowBackdrops - (index % #self.rowBackdrops)]
            -- local borderOptions = backdropOptions.borderOptions or {}
            -- row.frame:SetBackdrop({
            --     bgFile = backdropOptions.bgFile,
            --     edgeFile = borderOptions.edgeFile,
            --     edgeSize = borderOptions.edgeSize,
            --     insets = borderOptions.insets,
            --     tile = backdropOptions.tile,
            --     tileSize = backdropOptions.tileSize,
            -- })
            -- row.frame:SetBackdropColor(backdropOptions.colorR or 1, backdropOptions.colorG or 1,
            --     backdropOptions.colorB or 1, backdropOptions.colorA or 1)
            -- row.frame:SetBackdropBorderColor(borderOptions.colorR or 1, borderOptions.colorG or 1,
            --     borderOptions.colorB or 1, borderOptions.colorA or 1)

            GGUI:SetBackdropByBackdropOptions(row.frame, backdropOptions)

            row.originalBackdropOptions = backdropOptions
        end
        lastRow = row
    end

    if self.autoAdjustHeight then
        self:AdjustHeight()
    end
end

function GGUI.FrameList:AdjustHeight()
    -- adjust framelist height depending on activeRow Count and call callback if existing
    local headerOffset = 10
    local newHeight = (#self.activeRows * self.rowHeight) + headerOffset

    if self.maxAutoAdjustHeight then
        -- limit to maxHeightAdjustment
        newHeight = math.min(self.maxAutoAdjustHeight, newHeight)
    end

    self.frame:SetSize(self.frame:GetWidth(), newHeight)

    if self.autoAdjustHeightCallback then
        self.autoAdjustHeightCallback(newHeight)
    end
end

---@class GGUI.ShowPopupOptions
---@field title? string
---@field text? string
---@field acceptButtonLabel? string
---@field declineButtonLabel? string
---@field okButtonLabel? string
---@field onAccept? function
---@field onDecline? function
---@field sizeX? number
---@field sizeY? number
---@field parent? Frame
---@field anchorParent? Region
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field copyText? string

local popupFrame = nil
---@param options GGUI.ShowPopupOptions
function GGUI:ShowPopup(options)
    if not popupFrame then
        GGUI:ThrowError("Popup Frame not initialized")
    end
    options.title = options.title or nil
    options.text = options.text or ""
    options.acceptButtonLabel = options.acceptButtonLabel or "Accept"
    options.declineButtonLabel = options.declineButtonLabel or "Decline"
    options.okButtonLabel = options.okButtonLabel or "Ok"
    options.width = options.width or 300
    options.height = options.height or 300
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"

    if options.title then
        popupFrame.title:SetText(options.title)
    end
    popupFrame.content.text:SetText(options.text)
    popupFrame.onAccept = options.onAccept
    popupFrame.content.acceptButton.frame:SetText(options.acceptButtonLabel)
    popupFrame.content.acceptButton.frame:SetWidth(popupFrame.content.acceptButton.frame:GetTextWidth() + 15)
    popupFrame.onDecline = options.onDecline
    popupFrame.content.declineButton.frame:SetText(options.declineButtonLabel)
    popupFrame.content.declineButton.frame:SetWidth(popupFrame.content.declineButton.frame:GetTextWidth() + 15)
    popupFrame.content.okButton.frame:SetText(options.okButtonLabel)
    popupFrame.content.okButton.frame:SetWidth(popupFrame.content.okButton.frame:GetTextWidth() + 15)

    if options.sizeX then
        popupFrame.frame:SetWidth(options.sizeX)
    end
    if options.sizeY then
        popupFrame.frame:SetHeight(options.sizeY)
    end

    popupFrame.frame:ClearAllPoints()
    popupFrame:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)

    if options.copyText then
        popupFrame.content.copyInput:Show()
        popupFrame.content.okButton:Show()
        popupFrame.content.acceptButton:Hide()
        popupFrame.content.declineButton:Hide()
        popupFrame.content.copyInput:SetText(options.copyText)
        local editBox = popupFrame.content.copyInput.frame --[[@as EditBox]]
        editBox:HighlightText()
    else
        popupFrame.content.copyInput:Hide()
        popupFrame.content.okButton:Hide()
        popupFrame.content.acceptButton:Show()
        popupFrame.content.declineButton:Show()
        popupFrame.content.copyInput:SetText("")
    end

    popupFrame:Show()
end

---@class GGUI.InitPopupOptions
---@field backdropOptions GGUI.BackdropOptions
---@field buttonTextureOptions? GGUI.ButtonTextureOptions
---@field buttonFontOptions? GGUI.FontOptions
---@field hideCloseButton? boolean
---@field title? string
---@field sizeX? number
---@field sizeY? number
---@field frameID? string

---@param options GGUI.InitPopupOptions
function GGUI:InitializePopup(options)
    ---@type GGUI.Frame | GGUI.Widget
    popupFrame = GGUI.Frame({
        backdropOptions = options.backdropOptions,
        sizeX = options.sizeX or 300,
        sizeY = options.sizeY or 300,
        moveable = true,
        frameStrata = "DIALOG",
        frameID = options.frameID,
        title = options.title or "",
        closeable = not options.hideCloseButton,
    })

    popupFrame.content.text = GGUI.Text({
        parent = popupFrame.content,
        anchorParent = popupFrame.title.frame,
        anchorA = "TOP",
        anchorB = "BOTTOM",
        offsetY = -20,
        wrap = true,
    })

    popupFrame.content.acceptButton = GGUI.Button({
        parent = popupFrame.content,
        anchorParent = popupFrame.frame,
        anchorA = "BOTTOMLEFT",
        anchorB = "BOTTOMLEFT",
        offsetX = 10,
        offsetY = 10,
        label = "Accept",
        buttonTextureOptions = options.buttonTextureOptions,
        fontOptions = options.buttonFontOptions,
        clickCallback = function()
            if popupFrame.onAccept then
                popupFrame.onAccept()
            end
            popupFrame:Hide()
        end
    })
    popupFrame.content.okButton = GGUI.Button({
        parent = popupFrame.content,
        anchorParent = popupFrame.frame,
        anchorA = "BOTTOM",
        anchorB = "BOTTOM",
        offsetX = 10,
        offsetY = 10,
        label = "Ok",
        buttonTextureOptions = options.buttonTextureOptions,
        fontOptions = options.buttonFontOptions,
        clickCallback = function()
            popupFrame:Hide()
        end
    })
    popupFrame.content.okButton:Hide()
    popupFrame.content.declineButton = GGUI.Button({
        parent = popupFrame.content,
        anchorParent = popupFrame.frame,
        anchorA = "BOTTOMRIGHT",
        anchorB = "BOTTOMRIGHT",
        offsetX = -10,
        offsetY = 10,
        label = "Decline",
        fontOptions = options.buttonFontOptions,
        buttonTextureOptions = options.buttonTextureOptions,
        clickCallback = function()
            if popupFrame.onDecline then
                popupFrame.onDecline()
            end
            popupFrame:Hide()
        end
    })

    popupFrame.content.copyInput = GGUI.TextInput {
        parent = popupFrame.content, anchorParent = popupFrame.content,
        sizeX = 150, autoFocus = true,
    }

    local editBox = popupFrame.content.copyInput.frame --[[@as EditBox]]

    popupFrame.content.copyInput:Hide()

    popupFrame:Hide()

    GGUI:EnableHyperLinksForFrameAndChilds(popupFrame.content)
end

--- GGUI.ItemSelector
---@class GGUI.ItemSelector

---@class GGUI.ItemSelectorConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorParent? Frame
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field offsetX? number
---@field offsetY? number
---@field sizeX? number
---@field sizeY? number
---@field scale? number
---@field qualityIconScale? number
---@field selectionFrameOptions? GGUI.FrameConstructorOptions
---@field label? string
---@field initialItems? ItemMixin[]
---@field initialItem? ItemMixin
---@field onSelectCallback? fun(itemSelector: GGUI.ItemSelector, selectedItem: ItemMixin)
---@field selectedItem? ItemMixin
---@field selectionFrameColumns? number
---@field emptyIcon? string
---@field isAtlas? boolean


---@class GGUI.ItemSelector : GGUI.Widget
---@overload fun(options:GGUI.ItemSelectorConstructorOptions): GGUI.ItemSelector
GGUI.ItemSelector = GGUI.Widget:extend()

---@param options GGUI.ItemSelectorConstructorOptions
function GGUI.ItemSelector:new(options)
    options = options or {}
    options.parent = options.parent or UIParent
    options.anchorParent = options.anchorParent or UIParent
    options.sizeX = options.sizeX or 50
    options.sizeY = options.sizeY or 50
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.scale = options.scale or 1
    options.qualityIconScale = options.qualityIconScale or 1
    options.selectionFrameOptions = options.selectionFrameOptions or {}
    self.selectionFrameColumns = options.selectionFrameColumns or 3
    self.onSelectCallback = options.onSelectCallback or function() end
    ---@type ItemMixin?
    self.selectedItem = nil
    self.emptyIcon = options.emptyIcon or GGUI.CONST.EMPTY_TEXTURE

    self.icon = GGUI.Icon {
        parent = options.parent, anchorParent = options.anchorParent, anchorA = options.anchorA, anchorB = options.anchorB,
        offsetX = options.offsetX, offsetY = options.offsetY, qualityIconScale = options.qualityIconScale,
        sizeX = options.sizeX, sizeY = options.sizeY, texturePath = self.emptyIcon, isAtlas = options.isAtlas
    }

    if options.label then
        GGUI.Text {
            parent = options.parent, anchorParent = self.icon.frame, anchorA = "BOTTOM", anchorB = "TOP",
            text = options.label
        }
    end

    options.selectionFrameOptions.parent = options.selectionFrameOptions.parent or options.parent
    options.selectionFrameOptions.anchorParent = options.selectionFrameOptions.anchorParent or self.icon.frame
    options.selectionFrameOptions.anchorA = options.selectionFrameOptions.anchorA or "TOPLEFT"
    options.selectionFrameOptions.anchorB = options.selectionFrameOptions.anchorB or "TOPRIGHT"
    options.selectionFrameOptions.offsetX = options.selectionFrameOptions.offsetX or 5
    options.selectionFrameOptions.offsetY = options.selectionFrameOptions.offsetY or 5
    options.selectionFrameOptions.closeOnClickOutside = true
    options.selectionFrameOptions.frameConfigTable = options.selectionFrameOptions.frameConfigTable or {}
    local numFrames = GUTIL:Count(options.selectionFrameOptions.frameTable or {}) + 1
    options.selectionFrameOptions.frameID = options.selectionFrameOptions.frameID or
        ("GGUIIconSelectorFrame " .. numFrames)
    options.selectionFrameOptions.frameStrata = options.selectionFrameOptions.frameStrata or "FULLSCREEN"
    options.selectionFrameOptions.scrollableContent = true
    options.selectionFrameOptions.title = options.selectionFrameOptions.title or ""
    options.selectionFrameOptions.sizeX = options.selectionFrameOptions.sizeX or 150
    options.selectionFrameOptions.sizeY = options.selectionFrameOptions.sizeY or 150

    ---@class GGUI.ItemSelector.SelectionFrame : GGUI.Frame
    self.selectionFrame = GGUI.Frame(options.selectionFrameOptions)
    self.selectionFrame:Hide()

    self.selectionFrame:SetFrameLevel(options.parent:GetFrameLevel() + 10)

    self.icon.frame:SetScript("OnClick", function()
        if not self.selectionFrame:IsVisible() then
            self.selectionFrame:Show()
        end
    end)

    ---@type GGUI.Icon[]
    self.selectionFrame.itemSlots = {}
    self.selectionFrame.currentRow = 1
    self.selectionFrame.currentColumn = 1

    self:AddSlotIcon(nil)

    -- add initial item data to selectionFrame
    for _, item in pairs(options.initialItems or {}) do
        self:AddSlotIcon(item)
    end

    GGUI.ItemSelector.super.new(self, self.icon)
end

---@param item ItemMixin?
---@return GGUI.Icon
function GGUI.ItemSelector:AddSlotIcon(item)
    local iconSizeX = 25
    local iconSizeY = 25

    local baseOffsetX = 0
    local baseOffsetY = 0
    local spacingX = iconSizeX + 5
    local spacingY = (iconSizeY + 5) * -1
    local offsetX = baseOffsetX + spacingX * (self.selectionFrame.currentColumn - 1)
    local offsetY = baseOffsetY + spacingY * (self.selectionFrame.currentRow - 1)

    local icon = GGUI.Icon {
        parent = self.selectionFrame.content, anchorParent = self.selectionFrame.content, anchorA = "TOPLEFT",
        anchorB = "TOPLEFT", offsetX = offsetX, offsetY = offsetY, sizeX = 25, sizeY = 25
    }

    if item then
        icon:SetItem(item)
        table.insert(self.selectionFrame.itemSlots, icon)
    end


    icon.frame:SetScript("OnClick", function()
        self.selectedItem = icon.item
        self.selectionFrame:Hide()
        self.icon:SetItem(icon.item)
        self.onSelectCallback(self, icon.item)
    end)


    self.selectionFrame.currentColumn = self.selectionFrame.currentColumn + 1

    if self.selectionFrame.currentColumn > self.selectionFrameColumns then
        self.selectionFrame.currentColumn = 1
        self.selectionFrame.currentRow = self.selectionFrame.currentRow + 1
    end

    return icon
end

---@param items? ItemMixin[]
function GGUI.ItemSelector:SetItems(items)
    items = items or {}
    local itemSlots = self.selectionFrame.itemSlots

    local maxSlots = math.max(#items, #itemSlots)
    for i = 1, maxSlots do
        local itemSlot = itemSlots[i]
        local item = items[i]
        if not itemSlot and item then
            itemSlot = self:AddSlotIcon(item)
            itemSlot:SetItem(item)
        elseif item then
            itemSlot:SetItem(item)
            itemSlot:Show()
        elseif itemSlot then
            itemSlot:Hide()
        end
    end
end

---@param item ItemMixin?
function GGUI.ItemSelector:SetSelectedItem(item)
    self.selectedItem = item
    self.icon:SetItem(item)
end

--- GGUI.CheckboxSelector
---@class GGUI.CheckboxSelector

---@class GGUI.CheckboxSelector.CheckboxItem
---@field name string
---@field selectionID any the key under what the status of the checkbox is saved in the selectedValues property of the selector
---@field savedVariableProperty? string | number
---@field initialValue? boolean
---@field tooltip? string

---@class GGUI.CheckboxSelectorConstructorOptions : GGUI.ConstructorOptions
---@field initialItems? GGUI.CheckboxSelector.CheckboxItem[]
---@field savedVariablesTable table<any, boolean>
---@field parent? Frame
---@field anchorPoints GGUI.AnchorPoint[]
---@field sizeX number
---@field sizeY number
---@field label string
---@field onSelectCallback? fun(CheckboxSelector: GGUI.CheckboxSelector, selectedItem: string, selectedValue: boolean)


---@class GGUI.CheckboxSelector : GGUI.Widget
---@overload fun(options:GGUI.CheckboxSelectorConstructorOptions): GGUI.CheckboxSelector
GGUI.CheckboxSelector = GGUI.Widget:extend()

---@param options GGUI.CheckboxSelectorConstructorOptions
function GGUI.CheckboxSelector:new(options)
    options = options or {}
    self.onSelectCallback = options.onSelectCallback or function() end
    self.savedVariablesTable = options.savedVariablesTable or {}
    local frame = CreateFrame("DropdownButton", nil, options.parent,
        "WowStyle1FilterDropdownTemplate")
    GGUI.CheckboxSelector.super.new(self, frame)
    self.frame:SetText(tostring(options.label or "Select"))
    GGUI:SetPointsByAnchorPoints(self.frame, options.anchorPoints)
    self.selectionItems = options.initialItems or {}

    self.frame:SetSize(options.sizeX, options.sizeY)
    self.frame:SetupMenu(function(_, rootDescription)
        for _, selectionItem in ipairs(self.selectionItems) do
            rootDescription:CreateCheckbox(selectionItem.name, function()
                return self.savedVariablesTable[selectionItem.savedVariableProperty]
            end, function()
                self.savedVariablesTable[selectionItem.savedVariableProperty] = not self.savedVariablesTable
                    [selectionItem.savedVariableProperty]
                self.onSelectCallback(self, selectionItem.name,
                    self.savedVariablesTable[selectionItem.savedVariableProperty])
            end)
        end
    end)
end

---@param checkboxItems? GGUI.CheckboxSelector.CheckboxItem[]
function GGUI.CheckboxSelector:SetItems(checkboxItems)
    self.selectionItems = checkboxItems or {}
end

--- GGUI.ClassIcon

---@type table<ClassFile, string>
GGUI.CONST.CLASS_ICONS = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
    PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
    ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
    PRIEST = "Interface\\Icons\\ClassIcon_Priest",
    DEATHKNIGHT = "Interface\\Icons\\ClassIcon_DeathKnight",
    SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
    MAGE = "Interface\\Icons\\ClassIcon_Mage",
    WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    MONK = "Interface\\Icons\\ClassIcon_Monk",
    DRUID = "Interface\\Icons\\ClassIcon_Druid",
    DEMONHUNTER = "Interface\\Icons\\ClassIcon_DemonHunter",
    EVOKER = "Interface\\Icons\\classicon_evoker",
}

---@class GGUI.ClassIconConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field anchorA? FramePoint DEPRICATED: use anchorPoints
---@field anchorB? FramePoint DEPRICATED: use anchorPoints
---@field anchorParent? Region DEPRICATED: use anchorPoints
---@field offsetX? number DEPRICATED: use anchorPoints
---@field offsetY? number DEPRICATED: use anchorPoints
---@field anchorPoints? GGUI.AnchorPoint[]
---@field initialClass? ClassFile
---@field initialSpecID? number
---@field sizeX? number
---@field sizeY? number
---@field enableMouse? boolean
---@field showBorder? boolean
---@field borderSize? number
---@field clickCallback? fun(GGUI.ClassIcon)
---@field desaturate? boolean
---@field showTooltip? boolean

---@class GGUI.ClassIcon : GGUI.Widget
---@overload fun(options:GGUI.ClassIconConstructorOptions): GGUI.ClassIcon
GGUI.ClassIcon = GGUI.Widget:extend()

---@param options  GGUI.ClassIconConstructorOptions
function GGUI.ClassIcon:new(options)
    options = options or {}
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 40
    options.sizeY = options.sizeY or 40
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.showBorder = options.showBorder or false
    self.desaturate = options.desaturate or false
    self.showTooltip = options.showTooltip

    self.class = options.initialClass
    self.specID = options.initialSpecID


    if self.specID then
        self.class = select(6, GetSpecializationInfoByID(self.specID))
        GGUI:DebugPrint(options, "ClassIcon For Class: " .. tostring(self.class))
    end
    ---@type GGUI.TooltipOptions?
    self.tooltipOptions = nil

    self.icon = CreateFrame("Button", nil, options.parent, "GameMenuButtonTemplate")
    GGUI.Icon.super.new(self, self.icon)
    if options.anchorPoints then
        GGUI:SetPointsByAnchorPoints(self.icon, options.anchorPoints)
    else
        self.icon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    end
    self.icon:SetSize(options.sizeX, options.sizeY)

    if options.showBorder then
        local borderSize = options.borderSize or 10
        self.borderFrame = CreateFrame("Frame", nil, options.parent, "BackdropTemplate")
        self.borderFrame:SetSize(options.sizeX + borderSize, options.sizeY + borderSize)
        self.borderFrame:SetPoint("CENTER", self.icon, "CENTER")
        self.borderFrame:SetBackdrop {
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 20,
        }
        self.borderFrame:SetFrameLevel(self.icon:GetFrameLevel() + 10)
        if self.class then
            local initialColor = C_ClassColor.GetClassColor(self.class)
            if initialColor then
                self.borderFrame:SetBackdropBorderColor(initialColor.r, initialColor.g, initialColor.b,
                    initialColor.a)
            end
        end
    end


    local texture = GGUI.CONST.CLASS_ICONS[self.class]
    if texture then
        local buttonTexture = self.icon:CreateTexture(nil, "BACKGROUND")
        buttonTexture:SetAllPoints()
        buttonTexture:SetTexture(texture)
        self.icon:SetNormalTexture(buttonTexture)

        if self.desaturate then
            self:Desaturate()
        end
    end

    if options.enableMouse ~= nil and options.enableMouse == false then
        self.icon:EnableMouse(false)
    else
        self.icon:SetScript("OnClick", function()
            if options.clickCallback then
                options.clickCallback(self)
            end
        end)
    end

    if options.showTooltip then
        GGUI:SetTooltipsByTooltipOptions(self.icon, self)

        local initialText = nil
        if self.specID then
            local specName = select(2, GetSpecializationInfoByID(self.specID))
            initialText = C_ClassColor.GetClassColor(self.class):WrapTextInColorCode(specName ..
                " " .. LOCALIZED_CLASS_NAMES_MALE
                [self.class])
        elseif self.class then
            initialText = C_ClassColor.GetClassColor(self.class):WrapTextInColorCode(LOCALIZED_CLASS_NAMES_MALE
                [self.class])
        end

        self.tooltipOptions = {
            anchor = "ANCHOR_CURSOR",
            owner = self.icon,
            text = initialText,
        }
    end
end

function GGUI.ClassIcon:Show()
    self.frame:Show()
    if self.borderFrame then
        self.borderFrame:Show()
    end
end

function GGUI.ClassIcon:Hide()
    self.frame:Hide()
    if self.borderFrame then
        self.borderFrame:Hide()
    end
end

function GGUI.ClassIcon:Desaturate()
    self.frame:GetNormalTexture():SetVertexColor(0.2, 0.2, 0.2)
    self.desaturate = true
end

---@param saturation boolean
function GGUI.ClassIcon:SetSaturation(saturation)
    if saturation then
        self:Saturate()
    else
        self:Desaturate()
    end
end

function GGUI.ClassIcon:Saturate()
    self.frame:GetNormalTexture():SetVertexColor(1, 1, 1)
    self.desaturate = false
end

---@param classOrSpec ClassFile | number | nil
function GGUI.ClassIcon:SetClass(classOrSpec)
    if not classOrSpec then
        self.class = nil
        self.specID = nil
        self.tooltipOptions.text = nil
        self.icon:ClearNormalTexture()
        if self.showBorder then
            self.borderFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end
        return
    end
    local texture
    if type(classOrSpec) == 'string' then
        texture = GGUI.CONST.CLASS_ICONS[classOrSpec]
        self.class = classOrSpec
        self.specID = nil
        if self.showTooltip then
            self.tooltipOptions.text = LOCALIZED_CLASS_NAMES_MALE[self.class]
        end
    else
        local specInfo = { GetSpecializationInfoByID(classOrSpec) }
        texture = specInfo[4]
        self.class = specInfo[6]
        self.specID = classOrSpec
        if self.showTooltip then
            self.tooltipOptions.text = C_ClassColor.GetClassColor(self.class):WrapTextInColorCode(specInfo[2] .. " " ..
                LOCALIZED_CLASS_NAMES_MALE[self.class])
        end
    end
    if texture then
        self.icon:SetNormalTexture(texture)
    end

    if self.showBorder then
        local color = C_ClassColor.GetClassColor(self.class)
        if color then
            self.borderFrame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
        end
    end
end

---@class GGUI.SpellIconConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field offsetX? number
---@field offsetY? number
---@field initialSpellID? number
---@field sizeX? number
---@field sizeY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field anchorParent? Region
---@field enableMouse? boolean
---@field clickCallback? fun(GGUI.SpellIcon)
---@field desaturate? boolean

---@class GGUI.SpellIcon : GGUI.Widget
---@overload fun(options:GGUI.SpellIconConstructorOptions): GGUI.SpellIcon
GGUI.SpellIcon = GGUI.Widget:extend()
function GGUI.SpellIcon:new(options)
    options = options or {}
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.sizeX = options.sizeX or 40
    options.sizeY = options.sizeY or 40
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.showBorder = options.showBorder or false
    self.desaturate = options.desaturate or false

    self.spellID = options.initialSpellID


    self.icon = CreateFrame("Button", nil, options.parent)
    GGUI.Icon.super.new(self, self.icon)
    self.icon:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    self.icon:SetSize(options.sizeX, options.sizeY)

    if self.spellID then
        local texture = C_Spell.GetSpellTexture(self.spellID)
        if texture then
            local buttonTexture = self.icon:CreateTexture(nil, "BACKGROUND")
            buttonTexture:SetAllPoints()
            buttonTexture:SetTexture(texture)
            self.icon:SetNormalTexture(buttonTexture)

            GGUI:SetSpellTooltip(self.frame, self.spellID, self.icon, "ANCHOR_RIGHT")

            if self.desaturate then
                self:Desaturate()
            end
        end
    end

    if options.enableMouse ~= nil and options.enableMouse == false then
        self.icon:EnableMouse(false)
    else
        self.icon:SetScript("OnClick", function()
            if options.clickCallback then
                options.clickCallback(self)
            end
        end)
    end
end

function GGUI.SpellIcon:Desaturate()
    local texture = self.frame:GetNormalTexture()
    if texture then
        texture:SetVertexColor(0.2, 0.2, 0.2)
    end
    self.desaturate = true
end

function GGUI.SpellIcon:Saturate()
    local texture = self.frame:GetNormalTexture()
    if texture then
        texture:SetVertexColor(1, 1, 1)
    end
    self.desaturate = false
end

---@param spellID number
function GGUI.SpellIcon:SetSpell(spellID)
    local texture = C_Spell.GetSpellTexture(spellID)
    self.spellID = spellID
    if texture then
        self.icon:SetNormalTexture(texture)

        GGUI:SetSpellTooltip(self.icon, spellID, self.icon, "ANCHOR_RIGHT")
    else
        GGUI:SetSpellTooltip(self.icon, nil)
    end
end

--- GGUI.BlizzardTabSystem

---@class GGUI.BlizzardTabSystem : Object
---@overload fun(tabs:GGUI.BlizzardTab[]): GGUI.BlizzardTabSystem
GGUI.BlizzardTabSystem = GGUI.Object:extend()

---@param tabList GGUI.BlizzardTab[]
function GGUI.BlizzardTabSystem:new(tabList)
    self.isGGUI = true
    self.tabs = tabList
    if #tabList == 0 then
        return
    end
    -- show first tab in list
    for _, tab in pairs(tabList) do
        tab.button:SetScript("OnClick", function(self)
            for _, otherTab in pairs(tabList) do
                ---@type GGUI.BlizzardTab
                otherTab.content:Hide()
                PanelTemplates_DeselectTab(otherTab.button)
            end
            tab.content:Show()
            PanelTemplates_SelectTab(tab.button)
        end)
        tab.content:Hide()
    end

    if GGUI_GUTIL:Count(tabList, function(tab) return tab.initialTab end) ~= 1 then
        GGUI:ThrowError("BlizzardTabSystem needs exactly one tab with property initialTab = true")
    end

    for _, tab in pairs(tabList) do
        if tab.initialTab then
            tab.content:Show()
            PanelTemplates_SelectTab(tab.button)
        else
            tab.content:Hide()
            PanelTemplates_DeselectTab(tab.button)
        end
    end
end

function GGUI.BlizzardTabSystem:EnableHyperLinksForFrameAndChilds()
    table.foreach(self.tabs, function(_, tab)
        GGUI:EnableHyperLinksForFrameAndChilds(tab.content)
    end)
end

--- GGUI.BlizzardTab

---@class GGUI.BlizzardTabButtonOptions
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field label string
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.BlizzardTabConstructorOptions : GGUI.ConstructorOptions
---@field buttonOptions GGUI.BlizzardTabButtonOptions
---@field sizeX? number
---@field sizeY? number
---@field offsetX? number
---@field offsetY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field parent? Frame
---@field anchorParent? Region
---@field initialTab? boolean
---@field top? boolean
---@field backdropOptions? GGUI.BackdropOptions

---@class GGUI.BlizzardTab : GGUI.Widget
---@overload fun(options:GGUI.BlizzardTabConstructorOptions): GGUI.BlizzardTab
GGUI.BlizzardTab = GGUI.Object:extend()
---@param options GGUI.BlizzardTabConstructorOptions
function GGUI.BlizzardTab:new(options)
    options = options or {}
    options.sizeX = options.sizeX or 100
    options.sizeY = options.sizeY or 100
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"
    self.top = options.top or false
    self.isGGUI = true
    self.initialTab = options.initialTab or false
    local buttonOptions = options.buttonOptions or {}

    if self.top then
        self.button = CreateFrame("Button", nil, options.parent, "PanelTopTabButtonTemplate")
        self.button:SetPoint(buttonOptions.anchorA or "BOTTOMLEFT", buttonOptions.anchorParent or options.parent,
            buttonOptions.anchorB or "TOPLEFT", buttonOptions.offsetX or 0, buttonOptions.offsetY or 0)
    else
        self.button = CreateFrame("Button", nil, options.parent, "PanelTabButtonTemplate")
        self.button:SetPoint(buttonOptions.anchorA or "TOPLEFT", buttonOptions.anchorParent or options.parent,
            buttonOptions.anchorB or "BOTTOMLEFT", buttonOptions.offsetX or 0, buttonOptions.offsetY or 0)
    end

    self.button:SetText(buttonOptions.label)

    self.tooltipOptions = options.buttonOptions.tooltipOptions
    if self.tooltipOptions then
        GGUI:SetTooltipsByTooltipOptions(self.button, self)
    end

    self.content = CreateFrame("Frame", nil, options.parent, "BackdropTemplate")
    self.content:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    self.content:SetSize(options.sizeX, options.sizeY)

    if options.backdropOptions then
        local borderOptions = options.backdropOptions.borderOptions or {}
        self.content:SetBackdrop({
            bgFile = options.backdropOptions.bgFile,
            edgeFile = borderOptions.edgeFile,
            edgeSize = borderOptions.edgeSize,
            insets = borderOptions.insets,
        })

        self.content:SetBackdropColor(
            options.backdropOptions.colorR or 1,
            options.backdropOptions.colorG or 1,
            options.backdropOptions.colorB or 1,
            options.backdropOptions.colorA or 1
        )

        self.content:SetBackdropBorderColor(
            borderOptions.colorR or 1,
            borderOptions.colorG or 1,
            borderOptions.colorB or 1,
            borderOptions.colorA or 1
        )
    end
end

function GGUI.BlizzardTab:EnableHyperLinksForFrameAndChilds()
    GGUI:EnableHyperLinksForFrameAndChilds(self.content)
end

--- GGUI Texture

---@class GGUI.TextureConstructorOptions : GGUI.ConstructorOptions
---@field parent? Frame
---@field offsetX? number
---@field offsetY? number
---@field texture? string
---@field atlas? string
---@field sizeX? number
---@field sizeY? number
---@field anchorA? FramePoint
---@field anchorB? FramePoint
---@field anchorParent? Region
---@field tooltipOptions? GGUI.TooltipOptions

---@class GGUI.Texture : GGUI.Widget
---@overload fun(options:GGUI.TextureConstructorOptions): GGUI.Texture
GGUI.Texture = GGUI.Widget:extend()
function GGUI.Texture:new(options)
    options = options or {}
    options.offsetX = options.offsetX or 0
    options.offsetY = options.offsetY or 0
    self.texture = options.texture
    self.atlas = options.atlas
    options.sizeX = options.sizeX or 40
    options.sizeY = options.sizeY or 40
    options.anchorA = options.anchorA or "CENTER"
    options.anchorB = options.anchorB or "CENTER"

    local textureButton = CreateFrame("Button", nil, options.parent)
    GGUI.Texture.super.new(self, textureButton)
    textureButton:SetPoint(options.anchorA, options.anchorParent, options.anchorB, options.offsetX, options.offsetY)
    textureButton:SetSize(options.sizeX, options.sizeY)
    if self.atlas then
        textureButton:SetNormalAtlas(self.atlas)
    elseif self.texture then
        textureButton:SetNormalTexture(self.texture)
    end

    if options.tooltipOptions then
        self.tooltipOptions = options.tooltipOptions
        if self.tooltipOptions then
            GGUI:SetTooltipsByTooltipOptions(textureButton, self)
        end
    else
        textureButton:EnableMouse(false)
    end
end

function GGUI.Texture:SetAtlas(atlas)
    self.atlas = atlas
    self.frame:ClearNormalTexture()
    self.frame:SetNormalAtlas(self.atlas)
end

function GGUI.Texture:SetTexture(texture)
    self.texture = texture
    self.frame:ClearNormalTexture()
    self.frame:SetNormalTexture(self.texture)
end

function GGUI.Texture:SetDesatured(desatured)
    self.frame:GetNormalTexture():SetDesaturated(desatured)
end

function GGUI.Texture:SetAlpha(alpha)
    self.frame:SetAlpha(alpha)
end

---@class GGUI.TooltipOptionsFrame.LineOption
---@field label string
---@field disabledLabel? string what will the label look like if its disabled
---@field isEnablerLine? boolean automatically sets the key of this option to 'enabled'
---@field optionsKey? any default: <label> - What will be the key of this option in the optionsTable?

--- GGUI.TooltipOptionsFrame
---@class GGUI.TooltipOptionsFrameConstructorOptions : GGUI.ConstructorOptions
---@field frameOptions? GGUI.FrameConstructorOptions
---@field lines? GGUI.TooltipOptionsFrame.LineOption[]
---@field optionsTable? table table to save enabled info

---@class GGUI.TooltipOptionsFrame : GGUI.Frame
---@overload fun(options:GGUI.TooltipOptionsFrameConstructorOptions): GGUI.TooltipOptionsFrame
GGUI.TooltipOptionsFrame = GGUI.Frame:extend()

---@param options GGUI.TooltipOptionsFrameConstructorOptions
function GGUI.TooltipOptionsFrame:new(options)
    ---@type GGUI.FrameConstructorOptions
    local frameConstructorOptions = options.frameOptions or {}

    -- default tooltip look
    frameConstructorOptions.backdropOptions = frameConstructorOptions.backdropOptions or {
        backdropInfo = {
            bgFile = "Interface/Buttons/WHITE8x8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        },
        backdropRGBA = {
            0,
            0,
            0.3,
            0.2,
        },
    }
    GGUI.TooltipOptionsFrame.super.new(self, frameConstructorOptions)
    options.optionsTable = options.optionsTable or {}
    self.optionsTable = options.optionsTable

    local frameListOffsetY = -30
    local rowWidthInsetX = -10
    ---@class GGUI.TooltipOptionsFrame.LineList : GGUI.FrameList
    self.content.lineList = GGUI.FrameList {
        columnOptions = {
            {
                -- checkboxes
                width = (frameConstructorOptions.sizeX + rowWidthInsetX) or 100,
            },
        },
        parent = self.content,
        anchorPoints = {
            {
                anchorParent = self.content, anchorA = "TOPLEFT", anchorB = "TOPLEFT", offsetY = frameListOffsetY,
            }
        },
        hideScrollbar = true,
        rowConstructor = function(columns, row)
            ---@class GGUI.TooltipOptionsFrame.LineList.Row : GGUI.FrameList.Row
            row = row
            ---@class GGUI.TooltipOptionsFrame.LineList.cbColumn : Frame
            local cbColumn = columns[1]

            cbColumn.cb = GGUI.Checkbox {
                parent = cbColumn, anchorParent = cbColumn,
                anchorA = "LEFT", anchorB = "LEFT", offsetX = 2,
                labelOptions = {
                    text = ""
                },
            }
        end,
        autoAdjustHeight = true,
        autoAdjustHeightCallback = function(newHeight)
            self:SetSize(self:GetWidth(), newHeight + -frameListOffsetY)
        end
    }

    for _, lineOption in ipairs(options.lines) do
        self.content.lineList:Add(function(row, columns)
            ---@class GGUI.TooltipOptionsFrame.LineList.Row : GGUI.FrameList.Row
            row = row
            row.isEnablerLine = lineOption.isEnablerLine == true
            ---@class GGUI.TooltipOptionsFrame.LineList.cbColumn : Frame
            local cbColumn = columns[1]


            function row:SetOptionLabelByEnabledStatus()
                local tooltipEnabled = options.optionsTable.enabled == nil or options.optionsTable.enabled
                if cbColumn.cb:GetChecked() and tooltipEnabled then
                    cbColumn.cb.labelText:SetText(lineOption.label or "")
                else
                    cbColumn.cb.labelText:SetText(lineOption.disabledLabel or lineOption.label or "")
                end
            end

            if lineOption.isEnablerLine then
                cbColumn.cb:SetChecked(self.optionsTable.enabled)
            else
                cbColumn.cb:SetChecked(self.optionsTable[lineOption.optionsKey or lineOption.label])
            end

            row:SetOptionLabelByEnabledStatus()

            cbColumn.cb.clickCallback = function(checkbox, checked)
                if lineOption.isEnablerLine then
                    self.optionsTable.enabled = checked
                else
                    self.optionsTable[lineOption.optionsKey or lineOption.label] = checked
                end

                self:FormatOptionsByEnabledStatus()
            end

            if lineOption.isEnablerLine then
                self.optionsTable.enabled = self.optionsTable.enabled == true
            else
                self.optionsTable[lineOption.optionsKey or lineOption.label] = self.optionsTable
                    [lineOption.optionsKey or lineOption.label] == true
            end
        end)
    end

    self.content.lineList:UpdateDisplay()

    function self:FormatOptionsByEnabledStatus()
        local activeRows = self.content.lineList.activeRows --[[ @as GGUI.TooltipOptionsFrame.LineList.Row[] ]]
        for _, activeRow in ipairs(activeRows) do
            activeRow:SetOptionLabelByEnabledStatus()
        end
    end
end

---@class GGUI.ToggleButtonConstructorOptions : GGUI.Button.ConstructorOptions
---@field isOn? boolean
---@field optionsTable? table
---@field optionsKey? any
---@field onToggleCallback? fun(button: GGUI.ToggleButton, newValue: boolean)
---@field labelOn? string
---@field labelOff? string

---@class GGUI.ToggleButton : GGUI.Button
---@overload fun(options:GGUI.ToggleButtonConstructorOptions): GGUI.ToggleButton
GGUI.ToggleButton = GGUI.Button:extend()

---@param options GGUI.ToggleButtonConstructorOptions
function GGUI.ToggleButton:new(options)
    -- lock states on click
    self.isOn = options.isOn == nil -- default true

    options.label = (self.isOn and options.labelOn) or options.labelOff or options.label

    self.labelOn = options.labelOn
    self.labelOff = options.labelOff
    GGUI.ToggleButton.super.new(self, options)

    self.optionsTable = options.optionsTable
    self.optionsKey = options.optionsKey
    self.onToggleCallback = options.onToggleCallback

    if self.optionsTable then
        if not self.optionsKey then
            GGUI:ThrowError("ToggleButton Options Table given without key")
        end

        -- init
        self.optionsTable[self.optionsKey] = self.isOn
    end

    self.frame:HookScript("OnClick", function()
        GGUI:DebugPrint(options, "Clicked ToggleButton")

        self:SetToggle(not self.isOn)
    end)
end

---@param toggle boolean
function GGUI.ToggleButton:SetToggle(toggle)
    self.isOn = toggle

    if self.isOn then
        self.button:DesaturateHierarchy(0)

        if self.labelTexture then
            self.labelTexture:SetDesatured(false)
        end

        if self.button:GetFontString() then
            self:SetText(self.labelOn)
        end
    else
        self.button:DesaturateHierarchy(1)

        if self.labelTexture then
            self.labelTexture:SetDesatured(true)
        end
        if self.button:GetFontString() then
            self:SetText(self.labelOff)
        end
    end

    if self.optionsTable then
        self.optionsTable[self.optionsKey] = self.isOn
    end

    if self.onToggleCallback then
        self.onToggleCallback(self, self.isOn)
    end
end

--- GGUI.FilterButton

---@class GGUI.FilterButton : GGUI.Widget
---@overload fun(options:GGUI.FilterButton.ConstructorOptions): GGUI.FilterButton
GGUI.FilterButton = GGUI.Widget:extend()

---@class GGUI.FilterButton.ConstructorOptions
---@field label? string
---@field parent? Frame
---@field anchorPoints GGUI.AnchorPoint[]
---@field sizeX? number default: 100
---@field sizeY? number default: 25
---@field scale? number default: 1
---@field menuUtilCallback fun(ownerRegion: Region, rootDescription: any)

---@param options GGUI.FilterButton.ConstructorOptions
function GGUI.FilterButton:new(options)
    local button = CreateFrame("DropdownButton", nil, options.parent,
        "WowStyle1FilterDropdownTemplate") --[[@as Button]]
    GGUI.Widget.new(self, button)
    button:SetText(options.label or "")
    button:SetSize(options.sizeX or 100, options.sizeY or 25)
    button:SetScale(options.scale or 1)
    GGUI:SetPointsByAnchorPoints(button, options.anchorPoints)

    button:SetScript("OnClick", function()
        MenuUtil.CreateContextMenu(options.parent, function(ownerRegion, rootDescription)
            options.menuUtilCallback(ownerRegion, rootDescription)
        end)
    end)
end
