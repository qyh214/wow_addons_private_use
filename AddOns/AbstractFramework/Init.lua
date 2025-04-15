---@class AbstractFramework
local AF = {}
_G.AbstractFramework = AF
AF.name = "AbstractFramework"

-- no operation
AF.noop = function() end

---------------------------------------------------------------------
-- libs
---------------------------------------------------------------------
AF.Libs = {}
AF.Libs.LSM = LibStub("LibSharedMedia-3.0")
AF.Libs.LCG = LibStub("LibCustomGlow-1.0")
AF.Libs.LibDeflate = LibStub("LibDeflate")
AF.Libs.LibSerialize = LibStub("LibSerialize")
AF.Libs.Comm = LibStub("AceComm-3.0")
AF.Libs.LibDataBroker = LibStub("LibDataBroker-1.1")
AF.Libs.LibDBIcon = LibStub("LibDBIcon-1.0")

AF.Libs.MD5 = LibStub("MD5")
---@type fun(str: string): string
AF.MD5 = AF.Libs.MD5.sumhexa

AF.Libs.SHA256 = LibStub("SHA256")
---@type fun(str: string): string
AF.SHA256 = AF.Libs.SHA256.hash

---------------------------------------------------------------------
-- game version
---------------------------------------------------------------------
AF.isAsian = LOCALE_zhCN or LOCALE_zhTW or LOCALE_koKR

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    AF.isRetail = true
    AF.flavor = "retail"
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
    AF.isCata = true
    AF.flavor = "cata"
elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
    AF.isWrath = true
    AF.flavor = "wrath"
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    AF.isVanilla = true
    AF.flavor = "vanilla"
end

---------------------------------------------------------------------
-- UIParent
---------------------------------------------------------------------
AF.UIParent = CreateFrame("Frame", "AFParent", UIParent)
AF.UIParent:SetAllPoints(UIParent)
AF.UIParent:SetFrameLevel(0)

AF.UIParent:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

-- update pixels
local function UpdatePixels()
    if InCombatLockdown() then
        AF.UIParent:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    AF.UIParent:UnregisterEvent("PLAYER_REGEN_ENABLED")
    AF.UpdatePixels()
end

local timer
local function DelayedUpdatePixels()
    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(1, UpdatePixels)
end
hooksecurefunc(UIParent, "SetScale", DelayedUpdatePixels)

AF.UIParent:RegisterEvent("FIRST_FRAME_RENDERED")

function AF.UIParent:FIRST_FRAME_RENDERED()
    AF.UIParent:UnregisterEvent("FIRST_FRAME_RENDERED")
    AF.UIParent:RegisterEvent("UI_SCALE_CHANGED")
end

function AF.UIParent:UI_SCALE_CHANGED()
    DelayedUpdatePixels()
end

-- loaded
AF.UIParent:RegisterEvent("ADDON_LOADED")
function AF.UIParent:ADDON_LOADED(addon)
    if addon == AF.name then
        AF.UIParent:UnregisterEvent("ADDON_LOADED")
        if type(AFConfig) ~= "table" then AFConfig = {} end

        -- debug
        if type(AFConfig.debugMode) ~= "boolean" then AFConfig.debugMode = false end

        -- scale
        if type(AFConfig.scale) ~= "number" then AFConfig.scale = 1 end
        AF.SetScale(AFConfig.scale)
        -- if type(AFConfig.uiScale) ~= "number" then AFConfig.uiScale = UIParent:GetScale() end
        -- UIParent:SetScale(AFConfig.uiScale)
    end
end

-- function AF.SetIgnoreParentScale(ignore)
--     AF.UIParent:SetIgnoreParentScale(ignore)
-- end

--! scale should NOT be TOO SMALL
--! or it will result in abnormal display of borders
--! since AF has changed SetSnapToPixelGrid / SetTexelSnappingBias
function AF.SetScale(scale)
    AFConfig.scale = scale
    AF.scale = scale
    AF.UIParent:SetScale(scale)
    UpdatePixels()
end

function AF.GetScale()
    return AFConfig.scale
end

function AF.SetUIParentScale(scale)
    UIParent:SetScale(scale)
    -- if not AF.UIParent:IsIgnoringParentScale() then
    --     UpdatePixels()
    -- end
end

---------------------------------------------------------------------
-- hidden parent
---------------------------------------------------------------------
AF.hiddenParent = CreateFrame("Frame", nil, UIParent)
AF.hiddenParent:SetPoint("BOTTOMLEFT")
AF.hiddenParent:SetSize(1, 1)
AF.hiddenParent:Hide()

---------------------------------------------------------------------
-- slash command
---------------------------------------------------------------------
_G["SLASH_ABSTRACTFRAMEWORK1"] = "/abstract"
_G["SLASH_ABSTRACTFRAMEWORK2"] = "/afw"
_G["SLASH_ABSTRACTFRAMEWORK3"] = "/af"
SlashCmdList.ABSTRACTFRAMEWORK = function()
    AF.ShowDemo()
end