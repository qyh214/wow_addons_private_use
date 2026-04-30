local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local Type = "AtTextHighlightFrame"
local Version = 1
local variables = {
    width = 300,
    height = 20,
    margin = 5,
}

private.TextHighlight = {}
private.TextHighlight.defaultPosition = {
    point = 'CENTER',
    x = 0,
    y = 0,
}

---@param self AtTextHighlightFrame
local function OnAcquire(self)
end

---@param self AtTextHighlightFrame
local function OnRelease(self)
end
local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.text_highlight_frame[layoutName] = private.db.global.text_highlight_frame[layoutName] or {}
    private.db.global.text_highlight_frame[layoutName].x = x
    private.db.global.text_highlight_frame[layoutName].y = y
    private.db.global.text_highlight_frame[layoutName].point = point

    private.TEXT_HIGHLIGHT_FRAME:SetPoint(private.db.global.text_highlight_frame[layoutName].point,
        private.db.global.text_highlight_frame[layoutName].x, private.db.global.text_highlight_frame[layoutName].y)
end

LibEditMode:RegisterCallback('layout', function(layoutName)
    -- this will be called every time the Edit Mode layout is changed (which also happens at login),
    -- use it to load the saved button position from savedvariables and position it
    if not private.db.global.text_highlight_frame then
        private.db.global.text_highlight_frame = {}
    end
    if not private.db.global.text_highlight_frame[layoutName] then
        private.db.global.text_highlight_frame[layoutName] = CopyTable(private.TextHighlight.defaultPosition)
    end
    if not private.db.global.text_highlight_enabled then
        private.db.global.text_highlight_enabled = {}
    end
    if private.db.global.text_highlight_enabled[layoutName] == nil then
        private.db.global.text_highlight_enabled[layoutName] = true
    end
    if not private.db.global.text_highlight then
        private.db.global.text_highlight = {}
    end
    if not private.db.global.text_highlight[layoutName] then
        private.db.global.text_highlight[layoutName] = {
            grow_direction = 'UP',
            margin = variables.margin,
        }
    end
    if private.TEXT_HIGHLIGHT_FRAME then
        private.TEXT_HIGHLIGHT_FRAME:ClearAllPoints()
        private.TEXT_HIGHLIGHT_FRAME:SetPoint(private.db.global.text_highlight_frame[layoutName].point,
            private.db.global.text_highlight_frame[layoutName].x, private.db.global.text_highlight_frame[layoutName].y)
    end
end)

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "AbilityTimelineTextHighlightFrame", UIParent)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetWidth(variables.width)
    frame:SetHeight(variables.height)
    frame:Show()

    LibEditMode:AddFrame(frame, onPositionChanged, private.TextHighlight.defaultPosition,
        "|TInterface\\AddOns\\AbilityTimeline\\Media\\Textures\\logo_transparent.tga:32|t Better Ability Timeline Text Highlight")

    LibEditMode:AddFrameSettings(frame, {
        {
            name = private.getLocalisation("EnableTextHighlight"),
            desc = private.getLocalisation("EnableTextHighlightDescription"),
            kind = LibEditMode.SettingType.Checkbox,
            default = true,
            get = function(layoutName)
                return private.db.global.text_highlight_enabled[layoutName]
            end,
            set = function(layoutName, value)
                private.db.global.text_highlight_enabled[layoutName] = value
            end,
        },
        {
            name = private.getLocalisation("GrowDirection"),
            desc = private.getLocalisation("TextGrowDirectionDescription"),
            kind = LibEditMode.SettingType.Dropdown,

            get = function(layoutName)
                return private.db.global.text_highlight[layoutName].grow_direction
            end,
            set = function(layoutName, value)
                private.db.global.text_highlight[layoutName].grow_direction = value
                private.evaluateTextPositions()
            end,
            default = 'UP',
            height = 100,
            values = {
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
            name = private.getLocalisation("TextHighlightMargin"),
            desc = private.getLocalisation("TextHighlightMarginDescription"),
            kind = LibEditMode.SettingType.Slider,
            default = variables.margin,
            get = function(layoutName)
                return private.db.global.text_highlight[layoutName].margin
            end,
            set = function(layoutName, value)
                private.db.global.text_highlight[layoutName].margin = value
                private.evaluateTextPositions()
            end,
            minValue = 1,
            maxValue = 50,
            valueStep = 1,
        },
    })

    local buttons = {
        {
            text = private.getLocalisation("OpenTextEditor"),
            click = function() private.openHighlightTextSettings() end
        }
    }
    LibEditMode:AddFrameSettingsButtons(frame, buttons)

    ---@class AtTextHighlightFrame : AceGUIWidget
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
