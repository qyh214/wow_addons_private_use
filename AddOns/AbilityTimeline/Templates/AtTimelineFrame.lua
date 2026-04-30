local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI                = LibStub("AceGUI-3.0")
local LibEditMode           = LibStub("LibEditMode")
local SharedMedia           = LibStub("LibSharedMedia-3.0")
local Type                  = "AtTimelineFrame"
local Version               = 1
local variables             = {
    otherSize = 50,
    travelSize = 500,
    inverse_travel_direction = false,
    ticks_enabled = true,
    timelineTexture = "Blizzard Dialog Background",
    position = {
        point = 'CENTER',
        y = 110,
        x = 410,
    },
    timelineTextureColor = CreateColor(1, 1, 1, 1),
    IconMargin = 5,
}
private.TIMELINE_DIRECTIONS = {
    VERTICAL = "VERTICAL",
    HORIZONTAL = "HORIZONTAL"
}
private.TimelineFrame       = {}

---@param self AtTimelineFrame
local function OnAcquire(self)
end

---@param self AtTimelineFrame
local function OnRelease(self)
end
local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.timeline_frame[layoutName] = private.db.global.timeline_frame[layoutName] or {}
    private.db.global.timeline_frame[layoutName].x = x
    private.db.global.timeline_frame[layoutName].y = y
    private.db.global.timeline_frame[layoutName].point = point

    private.TIMELINE_FRAME:SetPoint(private.db.global.timeline_frame[layoutName].point,
        private.db.global.timeline_frame[layoutName].x, private.db.global.timeline_frame[layoutName].y)
end

local function HandleTickVisibility(layoutName)
    for _, tick in ipairs(private.TIMELINE_FRAME.frame.Ticks) do
        if private.db.global.timeline_frame[layoutName].ticks_enabled then
            tick:SetTick(private.TIMELINE_FRAME.frame, tick.tick, private.TIMELINE_FRAME:GetMoveSize(),
                private.AT_THRESHHOLD_TIME,
                private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction ==
                private.TIMELINE_DIRECTIONS.HORIZONTAL)
            tick.frame:Show()
        else
            tick.frame:Hide()
        end
    end
end

local function SetFrameSize(self, width, height)
    self:SetWidth(width)
    self:SetHeight(height)
end

LibEditMode:RegisterCallback('layout', function(layoutName)
    -- this will be called every time the Edit Mode layout is changed (which also happens at login),
    -- use it to load the saved button position from savedvariables and position it
    if not private.db.global.timeline_frame then
        private.db.global.timeline_frame = {}
    end
    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].point then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].point = variables.position.point
    end
    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].x then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].x = variables.position.x
    end
    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].y then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].y = variables.position.y
    end
    if private.db.global.timeline_frame[layoutName].ticks_enabled == nil then
        private.db.global.timeline_frame[layoutName].ticks_enabled = variables.ticks_enabled
    end
    if not private.db.global.timeline_frame[layoutName].otherSize then
        private.db.global.timeline_frame[layoutName].otherSize = variables.otherSize
    end
    if not private.db.global.timeline_frame[layoutName].travelSize then
        private.db.global.timeline_frame[layoutName].travelSize = variables.travelSize
    end
    if not private.db.global.timeline_frame[layoutName].inverse_travel_direction then
        private.db.global.timeline_frame[layoutName].inverse_travel_direction = variables.inverse_travel_direction
    end
    if not private.db.global.timeline_frame[layoutName].horizontal then
        private.db.global.timeline_frame[layoutName].horizontal = false
    end
    if not private.db.global.timeline_frame[layoutName].timeline_texture then
        private.db.global.timeline_frame[layoutName].timeline_texture = variables.timelineTexture
    end

    if not private.db.global.timeline_frame[layoutName].timeline_texture_color then
        private.db.global.timeline_frame[layoutName].timeline_texture_color = variables.timelineTextureColor
    end

    if not private.db.global.timeline_frame[layoutName].iconMargin then
        private.db.global.timeline_frame[layoutName].iconMargin = variables.IconMargin
    end


    if private.TIMELINE_FRAME then
        private.TIMELINE_FRAME:ClearAllPoints()
        private.TIMELINE_FRAME:SetPoint(private.db.global.timeline_frame[layoutName].point,
            private.db.global.timeline_frame[layoutName].x, private.db.global.timeline_frame[layoutName].y)
        local width, height
        if private.db.global.timeline_frame[layoutName].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
            width = private.db.global.timeline_frame[layoutName].travelSize
            height = private.db.global.timeline_frame[layoutName].otherSize
        else
            width = private.db.global.timeline_frame[layoutName].otherSize
            height = private.db.global.timeline_frame[layoutName].travelSize
        end
        SetFrameSize(private.TIMELINE_FRAME, width, height)
        private.TIMELINE_FRAME:HandleTicks()
        HandleTickVisibility(layoutName)
        private.TIMELINE_FRAME.SetBackDrop(private.TIMELINE_FRAME.frame)
    end
end)


local function HandleTicks(self)
    for i = 1, #self.frame.Ticks do
        self.frame.Ticks[i].frame:Hide()
        self.frame.Ticks[i]:Release()
    end
    for i, tick in ipairs(private.TIMELINE_TICKS) do
        local widget = AceGUI:Create("AtTimelineTicks")
        self.frame.Ticks[i] = widget
        widget:SetTick(self.frame, tick, self:GetMoveSize(), private.AT_THRESHHOLD_TIME,
            private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction ==
            private.TIMELINE_DIRECTIONS.HORIZONTAL)
        widget.frame:Show()
    end
end
local function HandleSizeChanges(self)
    local layoutName = private.ACTIVE_EDITMODE_LAYOUT
    local width, height
    if private.db.global.timeline_frame[layoutName].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
        width = private.db.global.timeline_frame[layoutName].travelSize
        height = private.db.global.timeline_frame[layoutName].otherSize
    else
        width = private.db.global.timeline_frame[layoutName].otherSize
        height = private.db.global.timeline_frame[layoutName].travelSize
    end
    SetFrameSize(self, width, height)
end

local function SetBackDrop(frame)
    local texture = SharedMedia:Fetch("background",
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].timeline_texture)
    local color = private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].timeline_texture_color
    frame:SetBackdrop({
        bgFile = texture,
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetBackdropColor(color.r, color.g, color.b, color.a)
end


local function GetMoveSize(self)
    if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction == private.TIMELINE_DIRECTIONS.HORIZONTAL then
        return self.frame:GetWidth()
    end
    return self.frame:GetHeight()
end

local function SetupEditModeSettings(frame)
    LibEditMode:AddFrame(frame, onPositionChanged, variables.position,
        "|TInterface\\AddOns\\AbilityTimeline\\Media\\Textures\\logo_transparent.tga:32|t Better Ability Timeline")

    local areTravelSettingsExpanded = false
    local areVisualSettingsExpanded = false
    LibEditMode:AddFrameSettings(frame, {
        {
            name = private.getLocalisation("ExpandTravelSettings"),
            expandedLabel = private.getLocalisation("CollapseTravelSettings"),
            collapsedLabel = private.getLocalisation("ExpandTravelSettings"),
            desc = private.getLocalisation("TravelSettingsDescription"),
            kind = LibEditMode.SettingType.Expander,
            default = areTravelSettingsExpanded,
            get = function()
                return areTravelSettingsExpanded
            end,
            set = function(_, value)
                areTravelSettingsExpanded = value
            end,
        },
        {
            name = private.getLocalisation("InverseTravelDirection"),
            desc = private.getLocalisation("InverseTravelDirectionDescription"),
            kind = LibEditMode.SettingType.Checkbox,
            default = false,
            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].inverse_travel_direction
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].inverse_travel_direction = value
                HandleTickVisibility(layoutName)
            end,
            hidden = function()
                return not areTravelSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("TravelDirection"),
            desc = private.getLocalisation("TravelDirectionDescription"),
            kind = LibEditMode.SettingType.Dropdown,

            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].travel_direction
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].travel_direction = value
                HandleSizeChanges(private.TIMELINE_FRAME)
                HandleTickVisibility(layoutName)
            end,
            default = private.TIMELINE_DIRECTIONS.VERTICAL,
            height = 100,
            values = {
                {
                    text = private.getLocalisation("TravelDirectionVertical"),
                    value = private.TIMELINE_DIRECTIONS.VERTICAL,
                    isRadio = true,
                },
                {
                    text = private.getLocalisation("TravelDirectionHorizontal"),
                    value = private.TIMELINE_DIRECTIONS.HORIZONTAL,
                    isRadio = true,
                },
            },
            hidden = function()
                return not areTravelSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("ExpandVisualSettings"),
            expandedLabel = private.getLocalisation("CollapseVisualSettings"),
            collapsedLabel = private.getLocalisation("ExpandVisualSettings"),
            desc = private.getLocalisation("VisualSettingsDescription"),
            kind = LibEditMode.SettingType.Expander,
            default = areVisualSettingsExpanded,
            get = function()
                return areVisualSettingsExpanded
            end,
            set = function(_, value)
                areVisualSettingsExpanded = value
            end,
        },
        {
            name = private.getLocalisation("EnableTicks"),
            desc = private.getLocalisation("EnableTicksDescription"),
            kind = LibEditMode.SettingType.Checkbox,
            default = true,
            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].ticks_enabled
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].ticks_enabled = value
                HandleTickVisibility(layoutName)
            end,
             hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("TimelineTexture"),
            desc = private.getLocalisation("TimelineTextureDescription"),
            kind = LibEditMode.SettingType.Dropdown,

            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].timeline_texture
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].timeline_texture = value
                SetBackDrop(private.TIMELINE_FRAME.frame)
            end,
            default = variables.timelineTexture,
            height = 300,
            values = function()
                local Textures = {}
                for _, texName in ipairs(SharedMedia:List("background")) do
                    local texPath = SharedMedia:Fetch("background", texName) or ""
                    local display = ("|T%s:16:128|t %s"):format(tostring(texPath), texName)
                    table.insert(Textures, {
                        text = display,
                        value = texName,
                        isRadio = false,
                    })
                end
                return Textures
            end,
            hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("TimelineTextureColor"),
            desc = private.getLocalisation("TimelineTextureColorDescription"),
            kind = LibEditMode.SettingType.ColorPicker,
            hasOpacity = true,
            get = function(layoutName)
                local color = private.db.global.timeline_frame[layoutName].timeline_texture_color
                return CreateColor(color.r, color.g, color.b, color.a)
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].timeline_texture_color = value
                SetBackDrop(private.TIMELINE_FRAME.frame)
            end,
            default = variables.timelineTextureColor,
            hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("TimelineOtherSize"),
            desc = private.getLocalisation("TimelineOtherSizeDescription"),
            kind = LibEditMode.SettingType.Slider,
            default = variables.otherSize,
            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].otherSize
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].otherSize = value
                HandleSizeChanges(private.TIMELINE_FRAME)
                HandleTicks(private.TIMELINE_FRAME)
                HandleTickVisibility(layoutName)
            end,
            minValue = 1,
            maxValue = 200,
            valueStep = 1,
            hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("TimelineTravelSize"),
            desc = private.getLocalisation("TimelineTravelSizeDescription"),
            kind = LibEditMode.SettingType.Slider,
            default = variables.travelSize,
            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].travelSize
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].travelSize = value
                HandleSizeChanges(private.TIMELINE_FRAME)
                HandleTicks(private.TIMELINE_FRAME)
                HandleTickVisibility(layoutName)
            end,
            minValue = 1,
            maxValue = 1000,
            valueStep = 1,
            hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = private.getLocalisation("IconMargin"),
            desc = private.getLocalisation("IconMarginDescription"),
            kind = LibEditMode.SettingType.Slider,
            default = variables.iconMargin,
            get = function(layoutName)
                return private.db.global.timeline_frame[layoutName].iconMargin
            end,
            set = function(layoutName, value)
                private.db.global.timeline_frame[layoutName].iconMargin = value
            end,
            minValue = 0,
            maxValue = 50,
            valueStep = 1,
            hidden = function()
                return not areVisualSettingsExpanded
            end,
        },
        {
            name = COMBAT_WARNINGS_HIDE_QUEUED_COUNTDOWNS_LABEL,
            desc = COMBAT_WARNINGS_HIDE_QUEUED_COUNTDOWNS_TOOLTIP,
            kind = LibEditMode.SettingType.Checkbox,
            default = false,
            get = function(layoutName)
                return C_CVar.GetCVar("encounterTimelineHideQueuedCountdowns") == "1" and true or false
            end,
            set = function(layoutName, value)
                C_CVar.SetCVar("encounterTimelineHideQueuedCountdowns", value and "1" or "0")
            end,
        },
        -- {
        --     name = 'Style',
        --     kind = LibEditMode.SettingType.Dropdown,

        --     get = function(layoutName)
        --         return private.db.global.timeline_frame[layoutName].style
        --     end,
        --     set = function(layoutName, value)
        --         private.db.global.timeline_frame[layoutName].style = value
        --     end,
        --     height = 500,
        --     values = {
        --         {
        --             text = 'Default',
        --             value = 'default',
        --         },
        --         {
        --             text = 'Compact',
        --             value = 'compact',
        --         },
        --         {
        --             text = 'Expanded',
        --             value = 'expanded',
        --         },
        --     },
        -- }
    })

    local buttons = {
        {
            text = private.getLocalisation("OpenIconEditor"),
            click = function() private.openSpellIconSettings() end
        }
    }
    LibEditMode:AddFrameSettingsButtons(frame, buttons)
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "AbilityTimelineFrame", UIParent, "BackdropTemplate")
    frame:SetWidth(variables.otherSize)
    frame:SetHeight(variables.travelSize)

    frame:SetFrameStrata("BACKGROUND")
    SetupEditModeSettings(frame)
    SetBackDrop(frame)
    frame.Ticks = {}
    frame:Hide()

    ---@class AtTimelineFrame : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        HandleTicks = HandleTicks,
        GetMoveSize = GetMoveSize,
        SetBackDrop = SetBackDrop,
        HandleSizeChanges = HandleSizeChanges,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
