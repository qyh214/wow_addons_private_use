local myname, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")

local TEMPLATE = myname .. "WorldMapDecorationPinTemplate"

local DecorationWorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin)
ns.DecorationWorldMapDataProvider = DecorationWorldMapDataProvider

-- _G.BWMDP = BackdropWorldMapDataProvider

local DecorationPinMixin = CreateFromMixins(MapCanvasPinMixin)
DecorationPinMixin.SetPassThroughButtons = function() end -- avoid potential taint from inside the map

local glows = {}
local highlights = {}
local hovered

function DecorationWorldMapDataProvider:RemoveAllData()
    if not self:GetMap() then return end

    self:GetMap():RemoveAllPinsByTemplate(TEMPLATE)
end

function DecorationWorldMapDataProvider:RefreshAllData(fromOnShow)
    if not (self:GetMap() and self:GetMap():IsShown()) then return end
    self:RemoveAllData()

    if HandyNotes.db.profile.enabledPlugins[myname:gsub("HandyNotes_", "")] == false or not HandyNotes.db.profile.enabled then
        return
    end

    local uiMapID = self:GetMap():GetMapID()
    if not uiMapID then return end
    if not ns.points[uiMapID] then return end

    self:EnsurePools()

    for coord, point in pairs(ns.points[uiMapID]) do
        -- if (point.backdrop or point.glow) and ns.should_show_point(coord, point, uiMapID, false) then
        if ns.should_show_point(coord, point, uiMapID, false) then
            self:GetMap():AcquirePin(TEMPLATE, point, uiMapID, coord)
        end
    end
end

-- This is an end-run around needing to distribute custom XML with every user of this handler
function DecorationWorldMapDataProvider:EnsurePools()
    if self:GetMap().pinPools[TEMPLATE] then return end
    self:GetMap().pinPools[TEMPLATE] = CreateFramePool("FRAME", self:GetMap():GetCanvas(), nil, function(pool, pin)
        if not pin.OnReleased then
            Mixin(pin, DecorationPinMixin)
        end
        (_G.FramePool_HideAndClearAnchors or _G.Pool_HideAndClearAnchors)(pool, pin)
        pin:OnReleased()

        pin.pinTemplate = nil
        pin.owningMap = nil
    end)
end

function DecorationWorldMapDataProvider:FindPinForPoint(point, coord)
    for pin in self:GetMap():EnumeratePinsByTemplate(TEMPLATE) do
        if pin.point == point and pin.coord == coord then
            return pin
        end
    end
end

function DecorationWorldMapDataProvider:OnMouseEnter(point, uiMapID, coord)
    hovered = point
    self:RefreshAllData()
end

function DecorationWorldMapDataProvider:OnMouseLeave(point, uiMapID, coord)
    hovered = nil
    self:RefreshAllData()
end

function DecorationWorldMapDataProvider:OnMouseClick(point, uiMapID, coord)
    highlights[point._main] = not highlights[point._main]
    if point.route and ns.points[uiMapID] and ns.points[uiMapID][point.route] then
        highlights[ns.points[uiMapID][point.route]] = highlights[point]
    end
    self:RefreshAllData()
end

function DecorationPinMixin:OnLoad()
    -- This is below normal handynotes pins, which is kind of the whole point
    self:UseFrameLevelType(ns.CLASSIC and "PIN_FRAME_LEVEL_MAP_LINK" or "PIN_FRAME_LEVEL_EVENT_OVERLAY")
    self:SetScalingLimits(1, 1.0, 1.2)

    self:SetMouseMotionEnabled(true)
    -- self:SetMouseClickEnabled(false)

    self.glow = self:CreateTexture(nil, "BACKGROUND")
    self.glow:SetAllPoints()
    -- self.glow:SetSize(SIZE, SIZE)
    -- self.glow:SetPoint("CENTER")
    self.backdrop = self:CreateTexture(nil, "BACKGROUND")
    self.backdrop:SetPoint("CENTER")
    self.border = self:CreateTexture(nil, "BORDER")
    self.border:SetPoint("CENTER")
    -- self.backdrop:SetAllPoints()
    -- self.backdrop:SetSize(SIZE, SIZE)
    self.highlight = self:CreateTexture(nil, "ARTWORK") -- HIGHLIGHT does enter/leave behavior...
    self.highlight:SetAllPoints()
    -- self.highlight:SetSize(SIZE, SIZE)
    -- self.highlight:SetPoint("CENTER")
    self.highlight:SetBlendMode("ADD")
    self.highlight:SetAlpha(0.4)
end

local default_backdrop
function DecorationPinMixin:OnAcquired(point, uiMapID, coord)
    self.point = point
    self.uiMapID = uiMapID
    self.coord = coord

    self:SetSize(30, 30)
    -- self:ApplyCurrentScale()
    self:SetPosition(HandyNotes:getXY(coord))

    -- Useful textures:
    -- worldquest-questmarker-abilityhighlight
    -- worldquest-questmarker-glow
    -- plunderstorm-glues-logo-backglow
    -- groupfinder-eye-backglow
    -- titleprestige-starglow
    -- services-ring-large-glowspin
    -- UI-QuestPoi-OuterGlow
    -- UI-QuestPoi-QuestNumber
    -- Waypoint-MapPin-Highlight
    if not default_backdrop then
        default_backdrop = ns.atlas_texture("worldquest-questmarker-epic")
    end
    local base = ns.work_out_texture(point)
    if point.backdrop then
        -- TODO: let it color-modify
        self:ApplyHandyNotesTextureSpec(self.backdrop, ns.xtype(point.backdrop) ~= "boolean" and point.backdrop or default_backdrop)
        -- self.backdrop:SetAtlas(ns.xtype(point.backdrop) == "string" and point.backdrop or "worldquest-questmarker-epic")
        self.backdrop:Show()
    end
    if point.border then
        self:ApplyHandyNotesTextureSpec(self.border, point.border)
        self.border:Show()
    end
    if point.glow or glows[point] or glows[point._main] or (hovered and (point == hovered or point._main == hovered._main)) then
        self.glow:SetAtlas(point.glow or "plunderstorm-glues-logo-backglow")
        self.glow:SetVertexColor(base.r or 1, base.g or 1, base.b or 1)
        self.glow:Show()
    end
    if point.highlight or highlights[point] or highlights[point._main] then
        self.highlight:SetAtlas(ns.xtype(point.highlight) == "string" and point.highlight or "UI-QuestPoi-QuestNumber-SuperTracked")
        self.highlight:Show()
    end

    self:Show()
end

function DecorationPinMixin:OnReleased()
    -- This will be called before onload has been called because framepools.
    -- The pin itself will have been hidden already by the base pool releaser.
    self.point = nil
    self.uiMapID = nil
    self.coord = nil
    if self.glow then
        self.glow:Hide()
        self.backdrop:Hide()
        self.border:Hide()
        self.highlight:Hide()
    end
end

function DecorationPinMixin:ApplyHandyNotesTextureSpec(texture, iconpath)
    -- This should be kept roughly in sync with HandyNotesWorldMapPinMixin:OnAcquired for my own ease of use...
    local scale, alpha = 1, 1
    if type(iconpath) == "table" then
        scale = iconpath.scale or 1
        alpha = iconpath.alpha or 1
    end

    local size = 18 * HandyNotes.db.profile.icon_scale * scale
    texture:SetSize(size, size)
    texture:SetAlpha(min(max(HandyNotes.db.profile.icon_alpha * alpha, 0), 1))

    if type(iconpath) == "table" then
        if iconpath.tCoordLeft then
            texture:SetTexCoord(iconpath.tCoordLeft, iconpath.tCoordRight, iconpath.tCoordTop, iconpath.tCoordBottom)
        else
            texture:SetTexCoord(0, 1, 0, 1)
        end
        if iconpath.r then
            texture:SetVertexColor(iconpath.r, iconpath.g, iconpath.b, iconpath.a)
        else
            texture:SetVertexColor(1, 1, 1, 1)
        end
        texture:SetTexture(iconpath.icon)
    else
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetVertexColor(1, 1, 1, 1)
        texture:SetTexture(iconpath)
    end
end
