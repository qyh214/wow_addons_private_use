local env                      = select(2, ...)

local LazyTimer                = env.WPM:Import("wpm_modules/lazy-timer")
local UIKit_Renderer_Processor = env.WPM:Import("wpm_modules/ui-kit/renderer/processor")

local band                     = bit.band
local bor                      = bit.bor

local Processor_SizeStatic     = UIKit_Renderer_Processor.SizeStatic
local Processor_SizeFit        = UIKit_Renderer_Processor.SizeFit
local Processor_SizeFill       = UIKit_Renderer_Processor.SizeFill
local Processor_PositionOffset = UIKit_Renderer_Processor.PositionOffset
local Processor_Anchor         = UIKit_Renderer_Processor.Anchor
local Processor_Point          = UIKit_Renderer_Processor.Point
local Processor_Layout         = UIKit_Renderer_Processor.Layout
local Processor_ScrollBar      = UIKit_Renderer_Processor.ScrollBar

local UIKit_Renderer_Cleaner   = env.WPM:New("wpm_modules/ui-kit/renderer/cleaner")


-- Shared
--------------------------------

UIKit_Renderer_Cleaner.onCooldown = false
UIKit_Renderer_Cleaner.requiresDependencyPass = false


local dirty                                   = {}
local dirtyCount                              = 0
local waitingForWash                          = false
local hasBackwardActions                      = false
local batchDepth                              = 0

local FIELD_ACTIONS                           = "__cleaner_actions"

-- Bitmask action flags (powers of 2 for bitwise OR)
local ACTION_SIZE_STATIC                      = 1
local ACTION_SIZE_FIT                         = 2
local ACTION_SIZE_FILL                        = 4
local ACTION_POSITION_OFFSET                  = 8
local ACTION_ANCHOR                           = 16
local ACTION_POINT                            = 32
local ACTION_LAYOUT                           = 64
local ACTION_SCROLLBAR                        = 128

-- Mask for backward pass actions
local BACKWARD_MASK                           = ACTION_SIZE_FIT + ACTION_LAYOUT

UIKit_Renderer_Cleaner.ACTION_SIZE_STATIC     = ACTION_SIZE_STATIC
UIKit_Renderer_Cleaner.ACTION_SIZE_FIT        = ACTION_SIZE_FIT
UIKit_Renderer_Cleaner.ACTION_SIZE_FILL       = ACTION_SIZE_FILL
UIKit_Renderer_Cleaner.ACTION_POSITION_OFFSET = ACTION_POSITION_OFFSET
UIKit_Renderer_Cleaner.ACTION_ANCHOR          = ACTION_ANCHOR
UIKit_Renderer_Cleaner.ACTION_POINT           = ACTION_POINT
UIKit_Renderer_Cleaner.ACTION_LAYOUT          = ACTION_LAYOUT
UIKit_Renderer_Cleaner.ACTION_SCROLLBAR       = ACTION_SCROLLBAR


-- Timers
--------------------------------

local washTimer = LazyTimer.New()
local cooldownTimer = LazyTimer.New()
washTimer:SetAction(function() UIKit_Renderer_Cleaner.Wash() end)
cooldownTimer:SetAction(function() UIKit_Renderer_Cleaner.onCooldown = false end)


-- API
--------------------------------

function UIKit_Renderer_Cleaner.AddDirty(actionId, frame)
    local actions = frame[FIELD_ACTIONS] or 0
    if actions == 0 then
        dirtyCount = dirtyCount + 1
        dirty[dirtyCount] = frame
    end

    frame[FIELD_ACTIONS] = bor(actions, actionId)

    if band(actionId, BACKWARD_MASK) ~= 0 then
        hasBackwardActions = true
        UIKit_Renderer_Cleaner.requiresDependencyPass = true
    end

    if batchDepth > 0 then return end

    if not waitingForWash then
        waitingForWash = true
        washTimer:Start(0)
    end
end

function UIKit_Renderer_Cleaner.BeginBatch()
    batchDepth = batchDepth + 1
end

function UIKit_Renderer_Cleaner.EndBatch()
    batchDepth = batchDepth - 1
    if batchDepth < 0 then batchDepth = 0 end

    if batchDepth == 0 and dirtyCount > 0 and not waitingForWash then
        waitingForWash = true
        washTimer:Start(0)
    end
end

function UIKit_Renderer_Cleaner.IsBatching()
    return batchDepth > 0
end

local function processForwardPass(frame, actions)
    if band(actions, ACTION_SIZE_STATIC) ~= 0 then Processor_SizeStatic(frame) end
    if band(actions, ACTION_SIZE_FILL) ~= 0 then Processor_SizeFill(frame) end
    if band(actions, ACTION_POSITION_OFFSET) ~= 0 then Processor_PositionOffset(frame) end
    if band(actions, ACTION_ANCHOR) ~= 0 then Processor_Anchor(frame) end
    if band(actions, ACTION_POINT) ~= 0 then Processor_Point(frame) end
end

local function processBackwardPass(frame, actions)
    if band(actions, ACTION_SIZE_FIT) ~= 0 then Processor_SizeFit(frame) end
    if band(actions, ACTION_LAYOUT) ~= 0 then Processor_Layout(frame) end
end


function UIKit_Renderer_Cleaner.Wash()
    if UIKit_Renderer_Cleaner.onCooldown or dirtyCount == 0 then return end

    UIKit_Renderer_Cleaner.onCooldown = true
    cooldownTimer:Start(0)
    waitingForWash = false

    local requiresDependencyPass = UIKit_Renderer_Cleaner.requiresDependencyPass
    local needsBackward = hasBackwardActions

    -- PASS 1: Forward (top-down)
    for i = 1, dirtyCount do
        local frame = dirty[i]
        processForwardPass(frame, frame[FIELD_ACTIONS])
    end

    -- PASS 1: Backward (bottom-up) - only if needed
    if needsBackward then
        for i = dirtyCount, 1, -1 do
            local frame = dirty[i]
            processBackwardPass(frame, frame[FIELD_ACTIONS])
        end
    end

    -- PASS 2: Dependency resolution - only if needed
    if requiresDependencyPass then
        for i = 1, dirtyCount do
            local frame = dirty[i]
            processForwardPass(frame, frame[FIELD_ACTIONS])
        end

        for i = dirtyCount, 1, -1 do
            local frame = dirty[i]
            processBackwardPass(frame, frame[FIELD_ACTIONS])
        end
    end

    -- FINAL PASS: ScrollBar updates and cleanup
    for i = 1, dirtyCount do
        local frame = dirty[i]
        local actions = frame[FIELD_ACTIONS]

        if band(actions, ACTION_SCROLLBAR) ~= 0 then
            Processor_ScrollBar(frame)
        end

        frame[FIELD_ACTIONS] = nil
        dirty[i] = nil
    end

    dirtyCount = 0
    hasBackwardActions = false
    UIKit_Renderer_Cleaner.requiresDependencyPass = false
end
