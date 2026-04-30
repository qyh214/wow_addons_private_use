local appName, app = ...
---@class AbilityTimeline
local private = app

private.modernize = function()
    if not private.db.global.timeline_frame then
        private.db.global.timeline_frame = {}
    end
    if private.db.profile.timeline_frame then
        private.db.global.timeline_frame = private.db.profile.timeline_frame
        private.db.profile.timeline_frame = nil
    end
    if private.db.profile.bigicon_frame then
        private.db.global.bigicon_frame = private.db.profile.bigicon_frame
        private.db.profile.bigicon_frame = nil
    end
    if private.db.profile.text_highlight_frame then
        private.db.global.text_highlight_frame = private.db.profile.text_highlight_frame
        private.db.profile.text_highlight_frame = nil
    end
    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT] = {}
    end

    if not private.db.profile.reminders then
        private.db.profile.reminders = {}
    end

    if not private.db.profile.editor then
        private.db.profile.editor = {}
    end
    if not private.db.profile.editor.defaultEncounterDuration then
        private.db.profile.editor.defaultEncounterDuration = 300
    end
    if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].height then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travelSize = private.db.global.timeline_frame
            [private.ACTIVE_EDITMODE_LAYOUT].height
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].height = nil
    end
    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].otherSize then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].otherSize = private.db.global.timeline_frame
            [private.ACTIVE_EDITMODE_LAYOUT].width
    end

    if not private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction then
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].travel_direction = private.TIMELINE_DIRECTIONS
        .VERTICAL
    end

    if not private.db.profile.icon_settings then
        private.db.profile.icon_settings = {}
    end
    if not private.db.profile.icon_settings.size then
        private.db.profile.icon_settings.size = 44
    end
    if not private.db.profile.icon_settings.zoom then
        private.db.profile.icon_settings.zoom = 0.3
    end
    if not private.db.profile.icon_settings.TextOffset then
        private.db.profile.icon_settings.TextOffset = { x = 16, y = 0 }
    end
    if private.db.profile.icon_settings.border == nil then
        if private.db.profile.icon_settings.dispellBorders == true then
            private.db.profile.icon_settings.border = private.IconBorderSettings.dispell
            private.db.profile.icon_settings.dispellBorders = nil
        elseif private.db.profile.icon_settings.dispellBorders == false then
            private.db.profile.icon_settings.border = private.IconBorderSettings.none
            private.db.profile.icon_settings.dispellBorders = nil
        else
            private.db.profile.icon_settings.border = private.IconBorderSettings.dispell
        end
    end
    if private.db.profile.icon_settings.dispellIcons == nil then
        private.db.profile.icon_settings.dispellIcons = true
    end
    if private.db.profile.icon_settings.dangerIcon == nil then
        private.db.profile.icon_settings.dangerIcon = true
    end

    if private.db.profile.icon_settings.roleIcons == nil then
        private.db.profile.icon_settings.roleIcons = true
    end

    if private.db.profile.icon_settings.strata == nil then
        private.db.profile.icon_settings.strata = private.FrameStrata.FULLSCREEN
    end

    if not private.db.profile.big_icon_settings then
        private.db.profile.big_icon_settings = {}
    end

    if not private.db.profile.big_icon_settings.size then
        private.db.profile.big_icon_settings.size = 100
    end
    if not private.db.profile.big_icon_settings.zoom then
        private.db.profile.big_icon_settings.zoom = 0.3
    end
    if not private.db.profile.big_icon_settings.TextOffset then
        private.db.profile.big_icon_settings.TextOffset = { x = 0, y = 10 }
    end
    if private.db.profile.big_icon_settings.dispellBorders == nil then
        private.db.profile.big_icon_settings.dispellBorders = true
    end
    if private.db.profile.big_icon_settings.dispellIcons == nil then
        private.db.profile.big_icon_settings.dispellIcons = true
    end
    if private.db.profile.big_icon_settings.dangerIcon == nil then
        private.db.profile.big_icon_settings.dangerIcon = true
    end

    if not private.db.profile.text_settings then
        private.db.profile.text_settings = {}
    end
    if not private.db.profile.text_settings.fontSize then
        private.db.profile.text_settings.fontSize = 14
    end
    if not private.db.profile.text_settings.font then
        private.db.profile.text_settings.font = "Friz Quadrata TT"
    end

    if not private.db.profile.text_settings.fontFlag then
        private.db.profile.text_settings.fontFlag = {
            OUTLINE = true,
        }
    end
    if private.db.profile.text_settings.enableShadow == nil then
        private.db.profile.text_settings.enableShadow = true
    end
    if private.db.profile.text_settings.useBackground == nil then
        private.db.profile.text_settings.useBackground = false
    end
    if not private.db.profile.text_settings.backgroundTexture then
        private.db.profile.text_settings.backgroundTexture = "Blizzard Dialog Background"
    end

    if not private.db.profile.text_settings.defaultColor then
        private.db.profile.text_settings.defaultColor = { r = 1, g = 1, b = 1 }
    end

    if not private.db.profile.text_settings.backgroundTextureOffset then
        private.db.profile.text_settings.backgroundTextureOffset = { x = 10, y = 10 }
    end

    if not private.db.profile.text_settings.text_anchor then
        private.db.profile.text_settings.text_anchor = "LEFT"
    end

    if not private.db.profile.big_icon_text_settings then
        private.db.profile.big_icon_text_settings = {}
    end
    if not private.db.profile.big_icon_text_settings.fontSize then
        private.db.profile.big_icon_text_settings.fontSize = 20
    end
    if not private.db.profile.big_icon_text_settings.font then
        private.db.profile.big_icon_text_settings.font = "Friz Quadrata TT"
    end
    if not private.db.profile.big_icon_text_settings.fontFlag then
        private.db.profile.big_icon_text_settings.fontFlag = {
            OUTLINE = true,
        }
    end
    if private.db.profile.big_icon_text_settings.enableShadow == nil then
        private.db.profile.big_icon_text_settings.enableShadow = true
    end
    if private.db.profile.big_icon_text_settings.useBackground == nil then
        private.db.profile.big_icon_text_settings.useBackground = false
    end
    if not private.db.profile.big_icon_text_settings.backgroundTexture then
        private.db.profile.big_icon_text_settings.backgroundTexture = "Blizzard Dialog Background"
    end

    if not private.db.profile.big_icon_text_settings.defaultColor then
        private.db.profile.big_icon_text_settings.defaultColor = { r = 1, g = 1, b = 1 }
    end

    if not private.db.profile.big_icon_text_settings.backgroundTextureOffset then
        private.db.profile.big_icon_text_settings.backgroundTextureOffset = { x = 0, y = 0 }
    end

    if not private.db.profile.big_icon_text_settings.text_anchor then
        private.db.profile.big_icon_text_settings.text_anchor = "BOTTOM"
    end

    if not private.db.profile.highlight_text_settings then
        private.db.profile.highlight_text_settings = {}
    end
    if not private.db.profile.highlight_text_settings.fontSize then
        private.db.profile.highlight_text_settings.fontSize = 14
    end
    if not private.db.profile.highlight_text_settings.font then
        private.db.profile.highlight_text_settings.font = "Friz Quadrata TT"
    end
    if private.db.profile.highlight_text_settings.enableShadow == nil then
        private.db.profile.highlight_text_settings.enableShadow = true
    end
    if private.db.profile.highlight_text_settings.useBackground == nil then
        private.db.profile.highlight_text_settings.useBackground = false
    end
    if not private.db.profile.highlight_text_settings.backgroundTexture then
        private.db.profile.highlight_text_settings.backgroundTexture = "Blizzard Dialog Background"
    end

    if not private.db.profile.highlight_text_settings.defaultColor then
        private.db.profile.highlight_text_settings.defaultColor = { r = 1, g = 1, b = 1 }
    end

    if not private.db.profile.highlight_text_settings.backgroundTextureOffset then
        private.db.profile.highlight_text_settings.backgroundTextureOffset = { x = 0, y = 0 }
    end

    if private.db.profile.highlight_text_settings.dispellIcons == nil then
        private.db.profile.highlight_text_settings.dispellIcons = true
    end

    if private.db.profile.highlight_text_settings.strata == nil then
        private.db.profile.highlight_text_settings.strata = private.FrameStrata.FULLSCREEN
    end

    if private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].text_anchor then
        private.db.profile.big_icon_text_settings.text_anchor = private.db.global.timeline_frame
        [private.ACTIVE_EDITMODE_LAYOUT].text_anchor
        private.db.global.timeline_frame[private.ACTIVE_EDITMODE_LAYOUT].text_anchor = nil
    end

    if not private.db.profile.cooldown_settings then
        private.db.profile.cooldown_settings = {}
    end

    if not private.db.profile.cooldown_settings.fontSize then
        private.db.profile.cooldown_settings.fontSize = 24
    end
    if not private.db.profile.cooldown_settings.font then
        private.db.profile.cooldown_settings.font = "Friz Quadrata TT"
    end

    if not private.db.profile.cooldown_settings.cooldown_color then
        private.db.profile.cooldown_settings.cooldown_color = {
            r = 1,
            g = 1,
            b = 1,
        }
    end

    if not private.db.profile.cooldown_settings.cooldown_highlight then
        private.db.profile.cooldown_settings.cooldown_highlight = {}
    end

    if not private.db.profile.cooldown_settings.cooldown_highlight.enabled then
        private.db.profile.cooldown_settings.cooldown_highlight.enabled = true
    end

    if not private.db.profile.cooldown_settings.cooldown_highlight.highlights then
        private.db.profile.cooldown_settings.cooldown_highlight.highlights = {
            {
                time = 3,
                color = { r = 1, g = 0, b = 0 },
                useGlow = false,
                glowType = private.GlowTypes.PROC,
                glowColor = { r = 0.95, g = 0.95, b = 0.32, a = 1 },
            },
            {
                time = 5,
                color = { r = 1, g = 1, b = 0 },
                useGlow = false,
                glowType = private.GlowTypes.PROC,
                glowColor = { r = 0.95, g = 0.95, b = 0.32, a = 1 },
            },
        }
    end

    if private.db.profile.importMergeMode == nil then
        private.db.profile.importMergeMode = true
    end

    if private.db.profile.importRelevant == nil then
        private.db.profile.importRelevant = true
    end

    -- fix cooldown highlights missing essential settings
    for _, highlight in ipairs(private.db.profile.cooldown_settings.cooldown_highlight.highlights) do
        if highlight.useGlow == nil then
            highlight.useGlow = false
        end
        if highlight.glowType == nil then
            highlight.glowType = private.GlowTypes.PROC
        end
        if highlight.glowColor == nil then
            highlight.glowColor = { r = 0.95, g = 0.95, b = 0.32, a = 1 }
        end
    end

    if private.db.profile.disableBossModsBars == nil then
        private.db.profile.disableBossModsBars = true
    end

    if private.db.profile.disableBossModsEmphasisedBars == nil then
        private.db.profile.disableBossModsEmphasisedBars = true
    end

    if private.db.profile.text_settings.useEventColor == nil then
        private.db.profile.text_settings.useEventColor = true
    end

    if private.db.profile.big_icon_settings.useTooltip == nil then
        if private.db.profile.big_icon_settings.enableTooltip ~= nil then
            if private.db.profile.big_icon_settings.enableTooltip then
                private.db.profile.big_icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Default
            else
                private.db.profile.big_icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Hidden
            end
        else
            private.db.profile.big_icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Hidden
        end
    end

    if private.db.profile.icon_settings.useTooltip == nil then
        if private.db.profile.icon_settings.enableTooltip ~= nil then
            if private.db.profile.icon_settings.enableTooltip then
                private.db.profile.icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Default
            else
                private.db.profile.icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Hidden
            end
            private.db.profile.icon_settings.enableTooltip = nil
        else
            private.db.profile.icon_settings.useTooltip = Enum.EncounterEventsTooltipAnchor.Hidden
        end
    end

    if private.db.profile.dispellTextColor == nil then
        if private.db.profile.icon_settings.dispellTextColor~=nil or private.db.profile.highlight_text_settings.dispellTextColor~=nil then
            private.db.profile.dispellTextColor = private.db.profile.icon_settings.dispellTextColor or private.db.profile.highlight_text_settings.dispellTextColor
            if private.db.profile.dispellTextColor then
                private.db.profile.text_settings.useEventColor = true
            end
            private.db.profile.icon_settings.dispellTextColor = nil
            private.db.profile.highlight_text_settings.dispellTextColor = nil
        else
            private.db.profile.dispellTextColor = true
        end
    end
end
