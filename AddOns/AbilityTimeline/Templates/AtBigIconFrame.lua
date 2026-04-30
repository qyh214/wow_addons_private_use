local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local Type = "AtBigIconFrame"
local Version = 1
local variables = {
    offset = {
        x = 30,
        y = -10,
    },
    size = 100,
    margin = 10,
}
private.BigIcon = {}
private.BigIcon.defaultPosition = {
    point = 'CENTER',
    y = -200,
    x = 410,
}

---@param self AtBigIconFrame
local function OnAcquire(self)
end

---@param self AtBigIconFrame
local function OnRelease(self)
end
local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.bigicon_frame[layoutName] = private.db.global.bigicon_frame[layoutName] or {}
    private.db.global.bigicon_frame[layoutName].x = x
    private.db.global.bigicon_frame[layoutName].y = y
    private.db.global.bigicon_frame[layoutName].point = point

    private.BIGICON_FRAME:SetPoint(private.db.global.bigicon_frame[layoutName].point,
        private.db.global.bigicon_frame[layoutName].x, private.db.global.bigicon_frame[layoutName].y)
end

LibEditMode:RegisterCallback('layout', function(layoutName)
    -- this will be called every time the Edit Mode layout is changed (which also happens at login),
    -- use it to load the saved button position from savedvariables and position it
    if not private.db.global.bigicon_frame then
        private.db.global.bigicon_frame = {}
    end
    if not private.db.global.bigicon_frame[layoutName] then
        private.db.global.bigicon_frame[layoutName] = CopyTable(private.BigIcon.defaultPosition)
    end
    if not private.db.global.bigicon_enabled then
        private.db.global.bigicon_enabled = {}
    end
    if private.db.global.bigicon_enabled[layoutName] == nil then
        private.db.global.bigicon_enabled[layoutName] = true
    end
    if not private.db.global.bigicon then
        private.db.global.bigicon = {}
    end
    if not private.db.global.bigicon[layoutName] then
        private.db.global.bigicon[layoutName] = {
            grow_direction = 'RIGHT',
        }
    end
    if private.BIGICON_FRAME then
        private.BIGICON_FRAME:ClearAllPoints()
        private.BIGICON_FRAME:SetPoint(private.db.global.bigicon_frame[layoutName].point,
            private.db.global.bigicon_frame[layoutName].x, private.db.global.bigicon_frame[layoutName].y)
    end
    if not private.db.global.bigicon then
        private.db.global.bigicon = {}
    end

    if not private.db.global.bigicon[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.bigicon[private.ACTIVE_EDITMODE_LAYOUT] = {}
    end

    if not private.db.global.bigicon[private.ACTIVE_EDITMODE_LAYOUT].margin then
        private.db.global.bigicon[private.ACTIVE_EDITMODE_LAYOUT].margin = variables.margin
    end
end)

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "AbilityTimelineBigIconFrame", UIParent)
    local size = private.db and private.db.profile.big_icon_settings and private.db.profile.big_icon_settings.size or
    variables.size
    frame:SetWidth(size)
    frame:SetHeight(size)
    frame:Show()
    private.Debug(frame, "AT_BIGICON_FRAME_BASE")

    LibEditMode:AddFrame(frame, onPositionChanged, private.BigIcon.defaultPosition,
        "|TInterface\\AddOns\\AbilityTimeline\\Media\\Textures\\logo_transparent.tga:32|t Better Ability Timeline Big Icon")
    LibEditMode:AddFrameSettings(frame, {
        {
            name = private.getLocalisation("EnableBigIcon"),
            desc = private.getLocalisation("EnableBigIconDescription"),
            kind = LibEditMode.SettingType.Checkbox,
            default = true,
            get = function(layoutName)
                return private.db.global.bigicon_enabled[layoutName]
            end,
            set = function(layoutName, value)
                private.db.global.bigicon_enabled[layoutName] = value
            end,
        },
        {
            name = private.getLocalisation("GrowDirection"),
            desc = private.getLocalisation("IconGrowDirectionDescription"),
            kind = LibEditMode.SettingType.Dropdown,

            get = function(layoutName)
                return private.db.global.bigicon[layoutName].grow_direction
            end,
            set = function(layoutName, value)
                private.db.global.bigicon[layoutName].grow_direction = value
                private.evaluateBigIconPositions()
            end,
            default = 'RIGHT',
            height = 100,
            values = {
                {
                    text = private.getLocalisation("GrowDirectionRight"),
                    value = 'RIGHT',
                    isRadio = true,
                },
                {
                    text = private.getLocalisation("GrowDirectionLeft"),
                    value = 'LEFT',
                    isRadio = true,
                },
                {
                    text = private.getLocalisation("GrowDirectionUp"),
                    value = 'UP',
                    isRadio = true,
                },
                {
                    text = private.getLocalisation("GrowDirectionDown"),
                    value = 'DOWN',
                    isRadio = true,
                },
            },
        },
        {
            name = private.getLocalisation("BigIconMargin"),
            desc = private.getLocalisation("BigIconMarginDescription"),
            kind = LibEditMode.SettingType.Slider,
            default = variables.margin,
            get = function(layoutName)
                return private.db.global.bigicon[layoutName].margin
            end,
            set = function(layoutName, value)
                private.db.global.bigicon[layoutName].margin = value
                private.evaluateBigIconPositions()
            end,
            minValue = 1,
            maxValue = 50,
            valueStep = 1,
        },
    })

    local buttons = {
        {
            text = private.getLocalisation("OpenIconEditor"),
            click = function() private.openBigIconSettings() end
        }
    }
    LibEditMode:AddFrameSettingsButtons(frame, buttons)

    ---@class AtBigIconFrame : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
