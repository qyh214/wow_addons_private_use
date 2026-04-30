local appName, app = ...
---@class AbilityTimeline
local private = app

private.FrameStrata = {
    PARENT = "PARENT",
    BACKGROUND = "BACKGROUND",
    LOW = "LOW",
    MEDIUM = "MEDIUM",
    HIGH = "HIGH",
    DIALOG = "DIALOG",
    FULLSCREEN = "FULLSCREEN",
    FULLSCREEN_DIALOG = "FULLSCREEN_DIALOG",
    TOOLTIP = "TOOLTIP",
}

private.FrameStrataOrder = {
    private.FrameStrata.PARENT,
    private.FrameStrata.BACKGROUND,
    private.FrameStrata.LOW,
    private.FrameStrata.MEDIUM,
    private.FrameStrata.HIGH,
    private.FrameStrata.DIALOG,
    private.FrameStrata.FULLSCREEN,
    private.FrameStrata.FULLSCREEN_DIALOG,
    private.FrameStrata.TOOLTIP,

}
