local addonName, DF = ...

-- ============================================================
-- DandersFrames Click-Casting Module - Core
-- ============================================================
-- Entry point and module initialization
-- ============================================================

-- Create module namespace
DF.ClickCast = DF.ClickCast or {}
local CC = DF.ClickCast

-- CRITICAL: Create ClickCastFrames global IMMEDIATELY if it doesn't exist
-- This allows other addons (like Unhalted, NephUI, etc.) to register their frames
-- even if they load before our full initialization completes
if not ClickCastFrames then
    ClickCastFrames = {}
end

-- Module will be initialized when all files are loaded
-- See Frames.lua for CC:Initialize() which is called from the event handler
