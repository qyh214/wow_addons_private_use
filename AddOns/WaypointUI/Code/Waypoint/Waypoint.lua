local env = select(2, ...)
local L = env.L
local Config = env.Config
local Sound = env.modules:Import("packages\\sound")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local Utils_Formatting = env.modules:Import("packages\\utils\\formatting")
local UIAnim = env.modules:Import("packages\\ui-anim")
local SharedUtil = env.modules:Import("@\\SharedUtil")
local MapPin = env.modules:Import("@\\MapPin")
local Waypoint_Director = env.modules:Import("@\\Waypoint\\Director")
local Waypoint_ArrivalTime = env.modules:Import("@\\Waypoint\\ArrivalTime")
local Waypoint_Enum = env.modules:Import("@\\Waypoint\\Enum")
local Waypoint_Cache = env.modules:Import("@\\Waypoint\\Cache")
local Waypoint = env.modules:New("@\\Waypoint")

local CreateVector2D = CreateVector2D
local Vector2D_CalculateAngleBetween = Vector2D_CalculateAngleBetween
local GetCameraZoom = GetCameraZoom
local abs = math.abs
local sqrt = math.sqrt
local pi = math.pi


local WaypointMixin = {}

local BASE_SCALE_DISTANCE = 2000
local BASE_SCALE = 0.25

local function GetScaleForDistance(distance, baseScaleDistance, baseScale, minScale, maxScale, exponent)
    exponent = exponent or 1

    if distance <= 0 then return maxScale end
    local rawScale = baseScale * (baseScaleDistance / distance) ^ exponent
    if rawScale < minScale then
        return minScale
    elseif rawScale > maxScale then
        return maxScale
    else
        return rawScale
    end
end

function WaypointMixin:OnLoad()
    self.lastScale = nil

    self:SetScript("OnUpdate", self.OnUpdate)
    local footerTextCallbackKeys = { "WaypointDistanceTextFontFlags", "WaypointDistanceTextType", "WaypointDistanceTextAlpha", "WaypointDistanceSubtextAlpha", "WaypointDistanceTextScale" }
    for _, event in ipairs(footerTextCallbackKeys) do
        SavedVariables.OnChange("WaypointDB_Global", event, function() self:SetFooterTextAppearance() end)
    end
    SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceText", function() self:UpdateFooter() end)
    SavedVariables.OnChange("WaypointDB_Global", "WaypointBeam", function() self:UpdateBeam() end)
    SavedVariables.OnChange("WaypointDB_Global", "WaypointBeamAlpha", function() self:UpdateBeam() end)
    SavedVariables.OnChange("WaypointDB_Global", "WaypointAlpha", function() self:UpdateOpacity() end)
    CallbackRegistry.Add("Preload.DatabaseReady", function()
        self:UpdateFooter()
        self:UpdateBeam()
        self:UpdateOpacity()
    end)
end

function WaypointMixin:OnUpdate()
    local distance = Waypoint_Cache.Get("distance")
    if not distance then return end

    local scale = Config.DBGlobal:GetVariable("WaypointScale") or 1
    local min = Config.DBGlobal:GetVariable("WaypointScaleMin")
    local max = Config.DBGlobal:GetVariable("WaypointScaleMax")
    local newScale = (min == max) and max or GetScaleForDistance(distance, BASE_SCALE_DISTANCE, BASE_SCALE, min, max)
    newScale = newScale * scale

    if not self.lastScale or abs(self.lastScale - newScale) > 0.0025 then
        self.lastScale = newScale
        WUIWaypointFrame:SetScale(newScale)
    end
end

function WaypointMixin:UpdateText()
    local waypointDistanceText = Config.DBGlobal:GetVariable("WaypointDistanceText")
    local waypointDistanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
    if not waypointDistanceText then return end

    local showInfoText = (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.DestinationName) or (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
    if not showInfoText then return end

    local pinName = Waypoint_Cache.Get("pinName")
    local redirectInfo = Waypoint_Cache.Get("redirectInfo")
    local pinType = Waypoint_Cache.Get("pinType")

    local newText = nil
    local oldText = self.Footer.InfoText:GetText()

    if redirectInfo and redirectInfo.valid then
        newText = redirectInfo.text or nil
    elseif pinType == Enum.SuperTrackingType.Quest then
        local questName = Waypoint_Cache.Get("questName")
        newText = questName or nil
    elseif pinName then
        newText = pinName
    end

    local hasText = (newText ~= nil and #newText >= 1)

    self.Footer.InfoText:SetShown(hasText)
    if self.Footer.InfoText:IsShown() and oldText ~= newText then
        self.Footer.InfoText:SetText(newText)
    end

    self.Footer:_Render()
end

function WaypointMixin:ShowArrivalTimeText()
    self.Footer.ArrivalTimeText.isVisible = true
    self.Footer.ArrivalTimeText:Show()
    self.AnimGroup_ArrivalTimeText:Play(self.Footer.ArrivalTimeText, "FADE_IN")
end

function WaypointMixin:HideArrivalTimeText()
    self.AnimGroup_ArrivalTimeText:Play(self.Footer.ArrivalTimeText, "FADE_OUT"):onFinish(function()
        self.Footer.ArrivalTimeText.isVisible = false
        self.Footer.ArrivalTimeText:Hide()
    end)
end

function WaypointMixin:UpdateDistanceText()
    local waypointDistanceText = Config.DBGlobal:GetVariable("WaypointDistanceText")
    local waypointDistanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
    if not waypointDistanceText then return end

    local isDistance = (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.Distance) or (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
    local isArrivalTime = (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.ArrivalTime) or (waypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)

    if isDistance then
        local distance = Waypoint_Cache.Get("distance")
        local oldText = self.Footer.DistanceText:GetText()
        local newText = tostring(SharedUtil:FormatDistance(distance))

        if oldText ~= newText then
            self.Footer.DistanceText:SetText(newText)
        end
    end

    local isValidArrivalTime = (Waypoint_ArrivalTime:GetSeconds() > 0)
    if isArrivalTime and isValidArrivalTime then
        local _, _, _, h, m, s = Utils_Formatting.FormatTime(Waypoint_ArrivalTime:GetSeconds())
        self.Footer.ArrivalTimeText:SetText(h .. m .. s)
        if not self.Footer.ArrivalTimeText.isVisible then
            self:ShowArrivalTimeText()
            self.Footer:_Render()
        end
    else
        if self.Footer.ArrivalTimeText.isVisible then
            self:HideArrivalTimeText()
        end
    end
end

function WaypointMixin:UpdateFooter()
    local distanceTextEnabled = Config.DBGlobal:GetVariable("WaypointDistanceText")

    self.Footer:SetShown(distanceTextEnabled)
    if not distanceTextEnabled then return end

    local distanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
    local showInfoText = (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.DestinationName) or (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
    local showDistanceText = (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.Distance) or (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
    local showArrivalTime = (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.ArrivalTime) or (distanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)

    self:SetFooterTextAppearance()
    self.Footer.InfoText:SetShown(showInfoText)
    self.Footer.DistanceText:SetShown(showDistanceText)
    self.Footer.ArrivalTimeText:SetShown(showArrivalTime)
    self.Footer:_Render()
end

function WaypointMixin:UpdateBeam()
    self.Beam:SetShown(Config.DBGlobal:GetVariable("WaypointBeam"))
    self.Beam:SetAlpha(Config.DBGlobal:GetVariable("WaypointBeamAlpha"))
end

function WaypointMixin:UpdateOpacity()
    self.Container:SetAlpha(Config.DBGlobal:GetVariable("WaypointAlpha") or 1)
end

function WaypointMixin:SetIcon(UIContextIconTexture)
    self.ContextIcon:SetData(UIContextIconTexture)
end

function WaypointMixin:SetIconOpacity(opacity)
    self.ContextIcon:SetOpacity(opacity)
end

function WaypointMixin:SetIconRecolor(shouldRecolor)
    if shouldRecolor then
        self.ContextIcon:Recolor()
    else
        self.ContextIcon:Decolor()
    end
end

function WaypointMixin:SetTint(color)
    self.ContextIcon:SetTint(color)
    self.Beam.BackgroundTexture:SetColor(color)
    self.Footer.InfoText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
    self.Footer.DistanceText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
    self.Footer.ArrivalTimeText:SetTextColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
end

function WaypointMixin:SetBeam(shown, opacity)
    self.Beam:SetShown(shown)
    if shown then self.Beam.Background:SetAlpha(opacity) end
end

function WaypointMixin:SetFooterTextAppearance()
    local alpha = Config.DBGlobal:GetVariable("WaypointDistanceTextAlpha")
    local scale = Config.DBGlobal:GetVariable("WaypointDistanceTextScale")
    local subtextAlpha = Config.DBGlobal:GetVariable("WaypointDistanceSubtextAlpha")
    self.Footer:SetAlpha(alpha)
    self.Footer:SetScale(scale)
    self.Footer.ArrivalTimeText:SetAlpha(subtextAlpha)
    self.Footer.DistanceText:SetAlpha(subtextAlpha)
end

WaypointMixin.AnimGroup = UIAnim.New()
do
    local function ApplyDefaultState(frame)
        frame.ContextIcon:SetScale(1)
        frame.Beam.Mask:SetScale(50)
        frame.AnimGroup_Beam:Play("NORMAL", frame.Beam.FXMask)
    end

    WaypointMixin.AnimGroup:State("INSTANT", function(frame)
        frame:SetAlpha(1)
        ApplyDefaultState(frame)
    end)

    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(1)
    WaypointMixin.AnimGroup:State("FADE_IN", function(frame)
        FadeIn:Play(frame)
        ApplyDefaultState(frame)
    end)

    local FadeOut = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(0)
    WaypointMixin.AnimGroup:State("FADE_OUT", function(frame)
        FadeOut:Play(frame)
    end)

    local IntroFade = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(1):from(0):to(1)
    local IntroContextIconScale = UIAnim.Animate():property(UIAnim.Enum.Property.Scale):easing(UIAnim.Enum.Easing.ExpoIn):duration(0.5):from(2.25):to(1)
    local IntroBeamMaskScale = UIAnim.Animate():wait(0.175):property(UIAnim.Enum.Property.Scale):easing(UIAnim.Enum.Easing.ExpoIn):duration(0.5):from(1):to(50)
    WaypointMixin.AnimGroup:State("INTRO", function(frame)
        frame:SetAlpha(0)
        frame.Beam.Mask:SetScale(1)

        IntroFade:Play(frame)
        IntroContextIconScale:Play(frame.ContextIcon)
        IntroBeamMaskScale:Play(frame.Beam.Mask)
        frame.AnimGroup_Beam:Play("NORMAL", frame.Beam.FXMask)
    end)

    local OutroFade = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.25):to(0)
    local OutroBeamMaskScale = UIAnim.Animate():property(UIAnim.Enum.Property.Scale):easing(UIAnim.Enum.Easing.ExpoIn):duration(0.5):to(1)
    WaypointMixin.AnimGroup:State("OUTRO", function(frame)
        OutroFade:Play(frame)
        OutroBeamMaskScale:Play(frame.Beam.Mask)
        frame.AnimGroup_Beam:Stop()
    end)
end

WaypointMixin.AnimGroup_Hover = UIAnim.New()
do
    local Enabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(0.25)
    local Disabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(1)

    WaypointMixin.AnimGroup_Hover:State("ENABLED", function(frame)
        Enabled:Play(frame.AnimationFrame)
    end)

    WaypointMixin.AnimGroup_Hover:State("DISABLED", function(frame)
        Disabled:Play(frame.AnimationFrame)
    end)
end

WaypointMixin.AnimGroup_Beam = UIAnim.New()
do
    local Translate = UIAnim.Animate()
        :property(UIAnim.Enum.Property.PosY)
        :easing(UIAnim.Enum.Easing.Linear)
        :duration(5)
        :loop(UIAnim.Enum.Looping.Reset)
        :from(-250)
        :to(500)

    WaypointMixin.AnimGroup_Beam:State("NORMAL", function(frame)
        Translate:Play(frame)
    end)
end

WaypointMixin.AnimGroup_ArrivalTimeText = UIAnim.New()
do
    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(function() return Config.DBGlobal:GetVariable("WaypointDistanceSubtextAlpha") end)
    WaypointMixin.AnimGroup_ArrivalTimeText:State("FADE_IN", function(frame)
        FadeIn:Play(frame)
    end)

    local FadeOut = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(0)
    WaypointMixin.AnimGroup_ArrivalTimeText:State("FADE_OUT", function(frame)
        FadeOut:Play(frame)
    end)
end

Mixin(WUIWaypointFrame, WaypointMixin)
WUIWaypointFrame:OnLoad()


local PinpointMixin = {}

function PinpointMixin:OnLoad()
    SavedVariables.OnChange("WaypointDB_Global", "PinpointScale", function() self:UpdateSize() end)
    SavedVariables.OnChange("WaypointDB_Global", "PinpointAlpha", function() self:UpdateOpacity() end)
    CallbackRegistry.Add("Preload.DatabaseReady", function()
        self:UpdateSize()
        self:UpdateOpacity()
    end)
end

function PinpointMixin:UpdateText()
    local pinpointInfo = Config.DBGlobal:GetVariable("PinpointInfo")
    local pinpointExtendedInfo = Config.DBGlobal:GetVariable("PinpointInfoExtended")

    local pinType = Waypoint_Cache.Get("pinType")
    local redirectInfo = Waypoint_Cache.Get("redirectInfo")
    local pinName = Waypoint_Cache.Get("pinName")
    local pinDescription = Waypoint_Cache.Get("pinDescription")

    -- Build text based on pinpoint info settings
    local oldText = self.Foreground.Content:GetText()
    local newText = ""
    local opacity = 0.5

    if pinpointInfo then
        if redirectInfo.valid then -- Redirect
            newText = redirectInfo.text
        elseif pinType == Enum.SuperTrackingType.Quest then -- Quest
            local questComplete = Waypoint_Cache.Get("questComplete")
            local questName = Waypoint_Cache.Get("questName")

            if questComplete then
                local questCompletionText = Waypoint_Cache.Get("questCompletionText") or L["WAYPOINTSYSTEM_PINPOINT_QUEST_COMPLETE"]

                if pinpointExtendedInfo then
                    newText = questName .. "\n" .. GenericEnum.ColorHEX.GRAY_FONT_COLOR .. questCompletionText .. "|r"
                else
                    newText = questCompletionText
                end
            else
                local questObjectiveInfo = Waypoint_Cache.Get("questObjectiveInfo")
                if questObjectiveInfo then
                    local allObjectives = questObjectiveInfo.objectives

                    local numObjectives = #allObjectives
                    local objectivesAdded = 1
                    for i = 1, numObjectives do
                        if allObjectives[i].text and not allObjectives[i].finished then
                            local newLine = objectivesAdded > 1 and "\n" or ""
                            newText = newText .. newLine .. allObjectives[i].text
                            objectivesAdded = objectivesAdded + 1
                        end
                    end
                end
            end
        elseif pinName then
            if pinpointExtendedInfo then
                local description = ""
                local newLine = pinName and #pinName > 0 and "\n" or ""
                if pinDescription and #pinDescription > 0 then description = newLine .. GenericEnum.ColorHEX.GRAY_FONT_COLOR .. pinDescription .. "|r" end

                newText = pinName .. description
            else
                newText = pinName
            end
        end
    else
        newText = ""
    end

    self.Foreground.Background:SetShown(#newText > 1)
    if #newText <= 1 then
        opacity = 1
    end

    if oldText ~= newText then
        self.Foreground.Content:SetText(newText)
        self:SetIconOpacity(opacity)
    end
end

function PinpointMixin:UpdateSize()
    local scale = Config.DBGlobal:GetVariable("PinpointScale")
    self:SetScale(scale or 1)
    self:_Render()
end

function PinpointMixin:UpdateOpacity()
    self.Container:SetAlpha(Config.DBGlobal:GetVariable("PinpointAlpha") or 1)
end

function PinpointMixin:SetIcon(UIContextIconTexture)
    self.Background.ContextIcon:SetData(UIContextIconTexture)
end

function PinpointMixin:SetIconOpacity(opacity)
    self.Background.ContextIcon:SetAlpha(opacity)
end

function PinpointMixin:SetIconRecolor(shouldRecolor)
    if shouldRecolor then
        self.Background.ContextIcon:Recolor()
    else
        self.Background.ContextIcon:Decolor()
    end
end

function PinpointMixin:SetTint(color)
    self.Background.ContextIcon:SetTint(color)
    self.Background.Arrow:SetTint(color)
    self.Foreground.BackgroundTexture:SetColor(color)
    self.Foreground.Content:SetTextColor(color.r, color.g, color.b, color.a or 1)
end

PinpointMixin.AnimGroup = UIAnim.New()
do
    local function ApplyDefaultState(frame)
        frame:SetAlpha(1)
        frame.Background.Arrow:Play()
    end

    PinpointMixin.AnimGroup:State("INSTANT", function(frame)
        frame:SetAlpha(1)
        ApplyDefaultState(frame)
    end)

    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):from(0):to(1)
    PinpointMixin.AnimGroup:State("FADE_IN", function(frame)
        FadeIn:Play(frame)
        ApplyDefaultState(frame)
    end)

    local FadeOut = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(0)
    PinpointMixin.AnimGroup:State("FADE_OUT", function(frame)
        FadeOut:Play(frame)
        frame.Background.Arrow:Stop()
    end)

    local Intro = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.5):to(1)
    local IntroTranslate = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):easing(UIAnim.Enum.Easing.ExpoInOut):duration(1):from(-57.5):to(0)
    PinpointMixin.AnimGroup:State("INTRO", function(frame)
        frame:SetAlpha(0)
        Intro:Play(frame)
        IntroTranslate:Play(frame.Container)
        frame.Background.Arrow:Play()
    end)

    local OutroAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.25):to(0)
    local OutroY = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):easing(UIAnim.Enum.Easing.ExpoInOut):duration(0.25):to(-12.5)
    PinpointMixin.AnimGroup:State("OUTRO", function(frame)
        OutroAlpha:Play(frame)
        OutroY:Play(frame.Container)
        frame.Background.Arrow:Stop()
    end)
end

PinpointMixin.AnimGroup_Hover = UIAnim.New()
do
    local Enabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(0.25)

    local Disabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(1)

    PinpointMixin.AnimGroup_Hover:State("ENABLED", function(frame)
        Enabled:Play(frame.AnimationFrame)
    end)

    PinpointMixin.AnimGroup_Hover:State("DISABLED", function(frame)
        Disabled:Play(frame.AnimationFrame)
    end)
end

Mixin(WUIPinpointFrame, PinpointMixin)
WUIPinpointFrame:OnLoad()


local NavigatorMixin = {}

local UP_VECTOR = CreateVector2D(0, 1)
local MIN_ZOOM = 12
local ROTATION_THRESHOLD = 0.01
local POSITION_THRESHOLD = 1

local function GetCenterScreenPoint()
    local centerX, centerY = WorldFrame:GetCenter()
    local scale = UIParent:GetEffectiveScale() or 1
    return centerX / scale, centerY / scale
end

function NavigatorMixin:OnLoad()
    self.savedZoom = nil
    self.savedDistance = nil
    self.savedArrowVector = CreateVector2D(0, 0)
    self.savedMajorAxisSquared = nil
    self.savedMinorAxisSquared = nil
    self.savedAxesMultiplied = nil
    self.centerScreenX = 0
    self.centerScreenY = 0
    self.lastNavX = nil
    self.lastNavY = nil
    self.isUpdateNeeded = false
    self.targetPositionX = 0
    self.targetPositionY = 0
    self.currentPositionX = 0
    self.currentPositionY = 0
    self.targetAngle = 0
    self.currentAngle = 0

    self:SetScript("OnUpdate", self.OnUpdate)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorDistance", function() self:Update(true) end)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorDynamicDistance", function() self:Update(true) end)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorScale", function() self:UpdateSize() end)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorAlpha", function() self:UpdateOpacity() end)
    CallbackRegistry.Add("Preload.DatabaseReady", function()
        self:UpdateSize(); self:UpdateOpacity()
    end)
end

function NavigatorMixin:OnUpdate()
    if not Waypoint.navFrame then return end
    self:Update()
end

function NavigatorMixin:Update(forceUpdate)
    self:UpdateInfo()
    if self.isUpdateNeeded or forceUpdate then
        local needPositionUpdate = self:UpdatePosition()
        local needRotationUpdate = self:UpdateArrow()
        self.isUpdateNeeded = (needPositionUpdate or needRotationUpdate)
    end
end

function NavigatorMixin:UpdatePosition()
    if not Waypoint.navFrame then return false end

    local navX, navY = Waypoint.navFrame:GetCenter()
    local posX = navX - self.centerScreenX
    local posY = navY - self.centerScreenY
    local denominator = sqrt(self.savedMajorAxisSquared * posY * posY + self.savedMinorAxisSquared * posX * posX)

    if denominator == 0 then return false end

    local ratio = self.savedAxesMultiplied / denominator
    self.targetPositionX = posX * ratio
    self.targetPositionY = posY * ratio

    -- Initialize position on first run to prevent origin snap
    if self.currentPositionX == 0 and self.currentPositionY == 0 then
        self.currentPositionX = self.targetPositionX
        self.currentPositionY = self.targetPositionY
    else
        -- Interpolate
        self.currentPositionX = self.currentPositionX + (self.targetPositionX - self.currentPositionX) / 3
        self.currentPositionY = self.currentPositionY + (self.targetPositionY - self.currentPositionY) / 3
    end

    self:ClearAllPoints()
    self:SetPoint("CENTER", WorldFrame, "CENTER", self.currentPositionX, self.currentPositionY)

    local deltaX = self.targetPositionX - self.currentPositionX
    local deltaY = self.targetPositionY - self.currentPositionY
    return (abs(deltaX) > POSITION_THRESHOLD) or (abs(deltaY) > POSITION_THRESHOLD)
end

function NavigatorMixin:UpdateArrow()
    if not Waypoint.navFrame then return false end

    local navX, navY = Waypoint.navFrame:GetCenter()
    self.savedArrowVector:SetXY(navX - self.centerScreenX, navY - self.centerScreenY)

    local targetAngle = -Vector2D_CalculateAngleBetween(self.savedArrowVector.x, self.savedArrowVector.y, UP_VECTOR.x, UP_VECTOR.y)
    local angleDiff = (targetAngle - self.currentAngle + pi) % (2 * pi) - pi

    if abs(angleDiff) > ROTATION_THRESHOLD then
        self.currentAngle = self.currentAngle + angleDiff / 2
    else
        self.currentAngle = targetAngle
    end

    self.ArrowTexture:SetRotation(self.currentAngle)
    return abs((targetAngle - self.currentAngle + pi) % (2 * pi) - pi) > ROTATION_THRESHOLD
end

function NavigatorMixin:UpdateInfo()
    local Settings_NavigatorDistance = Config.DBGlobal:GetVariable("NavigatorDistance")
    local Settings_NavigatorDynamicDistance = Config.DBGlobal:GetVariable("NavigatorDynamicDistance")

    local zoom = Settings_NavigatorDynamicDistance and math.max(MIN_ZOOM, GetCameraZoom()) or 39
    if zoom ~= self.savedZoom or Settings_NavigatorDistance ~= self.savedDistance then
        local baseZoom = 35
        local baseMajor, baseMinor = 200, 100
        local major, minor = math.min(baseMajor * (baseZoom / zoom), 500), math.min(baseMinor * (baseZoom / zoom), 500)
        major = major * (Settings_NavigatorDistance or 1)
        minor = minor * (Settings_NavigatorDistance or 1)

        self.savedZoom = zoom
        self.savedDistance = Settings_NavigatorDistance
        self:SetEllipticalRadii(major, minor)
    end

    self.centerScreenX, self.centerScreenY = GetCenterScreenPoint()

    if Waypoint.navFrame then
        local navX, navY = Waypoint.navFrame:GetCenter()
        if navX ~= self.lastNavX or navY ~= self.lastNavY then
            self.lastNavX = navX
            self.lastNavY = navY
            self.isUpdateNeeded = true
        end
    end
end

function NavigatorMixin:UpdateSize()
    local scale = Config.DBGlobal:GetVariable("NavigatorScale")
    self:SetScale(scale or 1)
end

function NavigatorMixin:UpdateOpacity()
    self.Container:SetAlpha(Config.DBGlobal:GetVariable("NavigatorAlpha") or 1)
end

function NavigatorMixin:SetIcon(UIContextIconTexture)
    self.ContextIcon:SetData(UIContextIconTexture)
end

function NavigatorMixin:SetIconRecolor(shouldRecolor)
    if shouldRecolor then
        self.ContextIcon:Recolor()
    else
        self.ContextIcon:Decolor()
    end
end

function NavigatorMixin:SetTint(color)
    self.ContextIcon:SetTint(color)
    self.ArrowTexture:SetColor(color)
end

function NavigatorMixin:SetEllipticalRadii(major, minor)
    self.savedMajorAxisSquared = major * major
    self.savedMinorAxisSquared = minor * minor
    self.savedAxesMultiplied = major * minor
end

NavigatorMixin.AnimGroup = UIAnim.New()
do
    NavigatorMixin.AnimGroup:State("INSTANT", function(frame)
        frame:SetAlpha(1)
    end)

    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(1)
    NavigatorMixin.AnimGroup:State("FADE_IN", function(frame)
        FadeIn:Play(frame.AnimationFrame)
    end)

    local FadeOut = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):easing(UIAnim.Enum.Easing.Linear):duration(0.175):to(0)
    NavigatorMixin.AnimGroup:State("FADE_OUT", function(frame)
        FadeOut:Play(frame.AnimationFrame)
    end)
end

NavigatorMixin.AnimGroup_Hover = UIAnim.New()
do
    local Enabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(0.25)

    local Disabled = UIAnim.Animate()
        :property(UIAnim.Enum.Property.Alpha)
        :easing(UIAnim.Enum.Easing.QuartInOut)
        :duration(0.375)
        :to(1)

    NavigatorMixin.AnimGroup_Hover:State("ENABLED", function(frame)
        Enabled:Play(frame)
    end)

    NavigatorMixin.AnimGroup_Hover:State("DISABLED", function(frame)
        Disabled:Play(frame)
    end)
end

Mixin(WUINavigatorFrame, NavigatorMixin)
WUINavigatorFrame:OnLoad()


local DBGlobal = nil
CallbackRegistry.Add("Preload.DatabaseReady", function() DBGlobal = Config.DBGlobal end)

Waypoint.navFrame = nil
Waypoint.cachedMode = nil
Waypoint.cachedContextIcon = nil

local function ResolveColorIntegrity(color)
    if not color then return false end
    if type(color) == "table" and color.r and color.g and color.b then return color end
    return false
end

function Waypoint.GetTintColorInfo(ContextIconTexture)
    if not DBGlobal then return end

    local useCustomColor = (DBGlobal:GetVariable("CustomColor") == true)

    local questIncomplete = (useCustomColor and ResolveColorIntegrity(DBGlobal:GetVariable("CustomColorQuestIncomplete"))) or (env.Enum.ColorRGB01.IncompleteQuest)
    local questComplete = (useCustomColor and ResolveColorIntegrity(DBGlobal:GetVariable("CustomColorQuestComplete"))) or (env.Enum.ColorRGB01.NormalQuest)
    local questCompleteRecurring = (useCustomColor and ResolveColorIntegrity(DBGlobal:GetVariable("CustomColorQuestCompleteRepeatable"))) or (env.Enum.ColorRGB01.RepeatableQuest)
    local questCompleteImportant = (useCustomColor and ResolveColorIntegrity(DBGlobal:GetVariable("CustomColorQuestCompleteImportant"))) or (env.Enum.ColorRGB01.ImportantQuest)
    local other = (useCustomColor and ResolveColorIntegrity(DBGlobal:GetVariable("CustomColorOther"))) or (env.Enum.ColorRGB01.Other)

    local recolorQuestIncomplete = (useCustomColor and DBGlobal:GetVariable("CustomColorQuestIncompleteTint")) or (not useCustomColor and false)
    local recolorQuestComplete = (useCustomColor and DBGlobal:GetVariable("CustomColorQuestCompleteTint")) or (not useCustomColor and false)
    local recolorQuestCompleteRecurring = (useCustomColor and DBGlobal:GetVariable("CustomColorQuestCompleteRepeatableTint")) or (not useCustomColor and false)
    local recolorQuestCompleteImportant = (useCustomColor and DBGlobal:GetVariable("CustomColorQuestCompleteImportantTint")) or (not useCustomColor and false)
    local recolorOther = (useCustomColor and DBGlobal:GetVariable("CustomColorOtherTint")) or (not useCustomColor and false)


    local color = nil
    local recolor = nil
    local requestRecolor = ContextIconTexture and ContextIconTexture.requestRecolor or false
    local trackingType = Waypoint_Cache.Get("trackingType")
    local pinType = Waypoint_Cache.Get("pinType")
    local isUserNavigationTracked = MapPin.IsUserNavigationTracked()
    local userNavigation = MapPin.GetUserNavigation()

    if isUserNavigationTracked and userNavigation and userNavigation.r and userNavigation.g and userNavigation.b then
        color = {
            r = userNavigation.r,
            g = userNavigation.g,
            b = userNavigation.b,
            a = 1
        }
        recolor = requestRecolor or true
    elseif pinType == Enum.SuperTrackingType.Corpse then
        color = {
            r = GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r,
            g = GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g,
            b = GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b,
            a = 1
        }
        recolor = requestRecolor or false
    elseif trackingType == Waypoint_Enum.TrackingType.CompleteQuest then
        color = questComplete
        recolor = requestRecolor or recolorQuestComplete
    elseif trackingType == Waypoint_Enum.TrackingType.CompleteRepeatableQuest then
        color = questCompleteRecurring
        recolor = requestRecolor or recolorQuestCompleteRecurring
    elseif trackingType == Waypoint_Enum.TrackingType.CompleteImportantQuest then
        color = questCompleteImportant
        recolor = requestRecolor or recolorQuestCompleteImportant
    elseif trackingType == Waypoint_Enum.TrackingType.IncompleteQuest then
        color = questIncomplete
        recolor = requestRecolor or recolorQuestIncomplete
    else
        color = other
        recolor = requestRecolor or recolorOther
    end

    return color, recolor
end

function Waypoint.UpdateColor()
    if not Waypoint.cachedContextIcon then return end

    local tintColor, recolor = Waypoint.GetTintColorInfo(Waypoint.cachedContextIcon)
    WUIWaypointFrame:SetTint(tintColor)
    WUIWaypointFrame:SetIconRecolor(recolor)
    WUIPinpointFrame:SetTint(tintColor)
    WUIPinpointFrame:SetIconRecolor(recolor)
    WUINavigatorFrame:SetTint(tintColor)
    WUINavigatorFrame:SetIconRecolor(recolor)
end

SavedVariables.OnChange("WaypointDB_Global", "CustomColor", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestIncomplete", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestComplete", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteRepeatable", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteImportant", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorOther", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestIncompleteTint", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteTint", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteRepeatableTint", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteImportantTint", Waypoint.UpdateColor)
SavedVariables.OnChange("WaypointDB_Global", "CustomColorOtherTint", Waypoint.UpdateColor)

function Waypoint.UpdateAnchors()
    local navFrame = Waypoint_Cache.navFrame
    Waypoint.navFrame = navFrame
    if not navFrame then return end

    WUIWaypointFrame:ClearAllPoints()
    WUIWaypointFrame:SetPoint("CENTER", navFrame)
    WUIPinpointFrame:ClearAllPoints()
    WUIPinpointFrame:SetPoint("BOTTOM", navFrame, "TOP", 0, 75)
end

function Waypoint.HideAllFrames()
    WUIWaypointFrame:Hide()
    WUIPinpointFrame:Hide()
    WUINavigatorFrame:Hide()
end

function Waypoint.HideMainFrame()
    WUIFrame:Hide()
end

function Waypoint.ShowMainFrame()
    WUIFrame:Show()

    -- Replay animations to avoid freezes.
    if WUIWaypointFrame:IsShown() then
        CallbackRegistry.Trigger("WaypointAnimation.WaypointShow")
    end
    if WUIPinpointFrame:IsShown() then
        CallbackRegistry.Trigger("WaypointAnimation.PinpointShow")
    end
    if WUINavigatorFrame:IsShown() then
        CallbackRegistry.Trigger("WaypointAnimation.NavigatorShow")
    end
end

function Waypoint.UpdateFrameVisibility(event, mode)
    local showNavigator = Config.DBGlobal:GetVariable("NavigatorShow")
    Waypoint.cachedMode = mode

    if mode == Waypoint_Enum.NavigationMode.Waypoint then
        CallbackRegistry.Trigger("WaypointAnimation.WaypointShow")
        CallbackRegistry.Trigger("WaypointAnimation.PinpointHide")
        CallbackRegistry.Trigger("WaypointAnimation.NavigatorHide")
    elseif mode == Waypoint_Enum.NavigationMode.Pinpoint then
        CallbackRegistry.Trigger("WaypointAnimation.WaypointHide")
        CallbackRegistry.Trigger("WaypointAnimation.PinpointShow")
        CallbackRegistry.Trigger("WaypointAnimation.NavigatorHide")
    elseif mode == Waypoint_Enum.NavigationMode.Navigator and showNavigator then
        CallbackRegistry.Trigger("WaypointAnimation.WaypointHide")
        CallbackRegistry.Trigger("WaypointAnimation.PinpointHide")
        CallbackRegistry.Trigger("WaypointAnimation.NavigatorShow")
    else
        CallbackRegistry.Trigger("WaypointAnimation.WaypointHide")
        CallbackRegistry.Trigger("WaypointAnimation.PinpointHide")
        CallbackRegistry.Trigger("WaypointAnimation.NavigatorHide")
    end

    Waypoint.UnblockTransition()
end

function Waypoint.UpdateRealtime()
    if Waypoint.cachedMode == Waypoint_Enum.NavigationMode.Waypoint then
        WUIWaypointFrame:UpdateDistanceText()
    end
end

function Waypoint.UpdateContext()
    local redirectInfo = Waypoint_Cache.Get("redirectInfo")
    local pinType = Waypoint_Cache.Get("pinType")
    if redirectInfo and redirectInfo.valid then
        Waypoint.cachedContextIcon = Waypoint_Cache.Get("redirectContextIcon")
    elseif pinType == Enum.SuperTrackingType.Quest and not Waypoint_Cache.Get("questIsWorldQuest") then
        Waypoint.cachedContextIcon = Waypoint_Cache.Get("questContextIcon")
    else
        Waypoint.cachedContextIcon = Waypoint_Cache.Get("pinContextIcon")
    end
    if not Waypoint.cachedContextIcon then return end

    WUIWaypointFrame:SetIcon(Waypoint.cachedContextIcon)
    WUIPinpointFrame:SetIcon(Waypoint.cachedContextIcon)
    WUINavigatorFrame:SetIcon(Waypoint.cachedContextIcon)

    Waypoint.UpdateColor()
    WUIWaypointFrame:UpdateText()
    WUIPinpointFrame:UpdateText()
end

CallbackRegistry.Add("Waypoint_DataProvider.NavFrameObtained", Waypoint.UpdateAnchors, 10)
CallbackRegistry.Add("Waypoint_DataProvider.CacheRealtime", Waypoint.UpdateRealtime)
CallbackRegistry.Add("Waypoint.HideAllFrames", Waypoint.HideAllFrames)
CallbackRegistry.Add("Waypoint.NavigationModeChanged", Waypoint.UpdateFrameVisibility)
CallbackRegistry.Add("Waypoint.ContextUpdate", Waypoint.UpdateContext, 10)
SavedVariables.OnChange("WaypointDB_Global", "NavigatorShow", function() Waypoint.UpdateFrameVisibility(Waypoint_Director:GetNavigationMode()) end)
SavedVariables.OnChange("WaypointDB_Global", "PinpointInfo", Waypoint.UpdateContext)
SavedVariables.OnChange("WaypointDB_Global", "PinpointInfoExtended", Waypoint.UpdateContext)
SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceTextType", Waypoint.UpdateContext)

local function PlayWaypointShowAudio()
    local Settings_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.WaypointShow

    if Settings_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomShowWaypoint")
        end
    end

    Sound.PlaySound("Main", soundID)
end

local function PlayPinpointShowAudio()
    local Settings_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.PinpointShow

    if Settings_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomShowPinpoint")
        end
    end

    Sound.PlaySound("Main", soundID)
end

do --Animation
    local function HideWaypoint() WUIWaypointFrame:Hide() end
    local function HidePinpoint() WUIPinpointFrame:Hide() end
    local function HideNavigator() WUINavigatorFrame:Hide() end

    local function Play(frameObj, state, onFinish)
        local handle = frameObj.AnimGroup:Play(frameObj, state)
        if handle and onFinish then handle:onFinish(onFinish) end
    end

    local blockTransitionChange = false
    local waypointAwaitIntro = false
    local waypointAwaitOutro = false
    local pinpointAwaitIntro = false
    local pinpointAwaitOutro = false

    function Waypoint.BlockTransition()
        blockTransitionChange = true
    end

    function Waypoint.UnblockTransition()
        blockTransitionChange = false
    end

    function Waypoint.ShowWaypoint()
        WUIWaypointFrame:Show()
        if waypointAwaitIntro then
            waypointAwaitIntro = false
            PlayWaypointShowAudio()
            Play(WUIWaypointFrame, "INTRO")
        else
            Play(WUIWaypointFrame, "FADE_IN")
        end
    end
    CallbackRegistry.Add("WaypointAnimation.WaypointShow", Waypoint.ShowWaypoint)

    function Waypoint.HideWaypoint()
        if waypointAwaitOutro then
            waypointAwaitOutro = false
            Play(WUIWaypointFrame, "OUTRO", HideWaypoint)
        else
            Play(WUIWaypointFrame, "FADE_OUT", HideWaypoint)
        end
    end
    CallbackRegistry.Add("WaypointAnimation.WaypointHide", Waypoint.HideWaypoint)

    function Waypoint.ShowPinpoint()
        WUIPinpointFrame:Show()
        if pinpointAwaitIntro then
            pinpointAwaitIntro = false
            PlayPinpointShowAudio()
            Play(WUIPinpointFrame, "INTRO")
        else
            Play(WUIPinpointFrame, "FADE_IN")
        end
    end
    CallbackRegistry.Add("WaypointAnimation.PinpointShow", Waypoint.ShowPinpoint)

    function Waypoint.HidePinpoint()
        if pinpointAwaitOutro then
            pinpointAwaitOutro = false
            Play(WUIPinpointFrame, "OUTRO", HidePinpoint)
        else
            Play(WUIPinpointFrame, "FADE_OUT", HidePinpoint)
        end
    end
    CallbackRegistry.Add("WaypointAnimation.PinpointHide", Waypoint.HidePinpoint)

    function Waypoint.ShowNavigator()
        WUINavigatorFrame:Show()
        Play(WUINavigatorFrame, "FADE_IN")
    end
    CallbackRegistry.Add("WaypointAnimation.NavigatorShow", Waypoint.ShowNavigator)

    function Waypoint.HideNavigator()
        Play(WUINavigatorFrame, "FADE_OUT", HideNavigator)
    end
    CallbackRegistry.Add("WaypointAnimation.NavigatorHide", Waypoint.HideNavigator)

    function Waypoint.TransitionWaypointToPinpoint()
        if blockTransitionChange then return end
        waypointAwaitIntro = false
        waypointAwaitOutro = true
        pinpointAwaitIntro = true
        pinpointAwaitOutro = false
    end
    CallbackRegistry.Add("WaypointAnimation.WaypointToPinpoint", Waypoint.TransitionWaypointToPinpoint)

    function Waypoint.TransitionPinpointToWaypoint()
        if blockTransitionChange then return end
        waypointAwaitIntro = true
        waypointAwaitOutro = false
        pinpointAwaitIntro = false
        pinpointAwaitOutro = true
    end
    CallbackRegistry.Add("WaypointAnimation.PinpointToWaypoint", Waypoint.TransitionPinpointToWaypoint)

    function Waypoint.New()
        Waypoint.BlockTransition()
        Waypoint.HideAllFrames()

        waypointAwaitIntro = true
        waypointAwaitOutro = false
        pinpointAwaitIntro = true
        pinpointAwaitOutro = false

        Waypoint.UpdateFrameVisibility(Waypoint_Director:GetNavigationMode())
    end
    CallbackRegistry.Add("WaypointAnimation.New", Waypoint.New)
end

do -- Hide SuperTrackedFrame while waypoint is active
    local function HideSuperTrackedFrame()
        if not Waypoint_Director.isActive then return end
        SuperTrackedFrame:Hide()
    end

    CallbackRegistry.Add("Waypoint.ActiveChanged", HideSuperTrackedFrame)
    hooksecurefunc(SuperTrackedFrame, "SetShown", HideSuperTrackedFrame)
    hooksecurefunc(SuperTrackedFrame, "Show", HideSuperTrackedFrame)
end

do -- Right-click WUI frames to clear tracking
    local useRightClickToClear = nil
    local frames = { WUIWaypointFrame, WUIPinpointFrame, WUINavigatorFrame }

    local function UpdateMouseEvents()
        local propagate = (not useRightClickToClear)
        for _, f in ipairs(frames) do
            f:AwaitSetPropagateMouseClicks(propagate)
        end
    end

    local function UpdateInfo()
        useRightClickToClear = Config.DBGlobal:GetVariable("RightClickToClear")
        UpdateMouseEvents()
    end

    SavedVariables.OnChange("WaypointDB_Global", "RightClickToClear", UpdateInfo)
    CallbackRegistry.Add("Preload.DatabaseReady", UpdateInfo)

    local function BindRightClickClear(f)
        f:SetScript("OnMouseDown", function(_, button)
            if useRightClickToClear and button == "RightButton" then
                MapPin:ClearDestination()
            end
        end)
    end
    for _, f in ipairs(frames) do BindRightClickClear(f) end
end

do -- Background Preview
    local useBackgroundPreview = false
    local frames = { WUIWaypointFrame, WUIPinpointFrame, WUINavigatorFrame }

    local function UpdateVariables()
        useBackgroundPreview = Config.DBGlobal:GetVariable("BackgroundPreview")
    end
    SavedVariables.OnChange("WaypointDB_Global", "BackgroundPreview", UpdateVariables)
    CallbackRegistry.Add("Preload.DatabaseReady", UpdateVariables)

    local function PlayHoverAnimation(frameObj)
        if not useBackgroundPreview then return end
        frameObj.AnimGroup_Hover:Play("ENABLED", frameObj)
    end
    local function StopHoverAnimation(frameObj)
        if not useBackgroundPreview then return end
        frameObj.AnimGroup_Hover:Play(frameObj, "DISABLED")
    end

    do -- Fade WUI frame when over player
        local THRESHOLD = 75
        local wasOverPlayer = false

        local function VerifyAndFadeWaypointWhenOverPlayer()
            if not useBackgroundPreview then return end
            if not Waypoint.navFrame then return end

            local distance = SharedUtil:GetFrameDistanceFromScreenCenter(Waypoint.navFrame)
            local isOverPlayer = (distance <= THRESHOLD)
            if isOverPlayer == wasOverPlayer then return end

            if WUIWaypointFrame:IsShown() then
                if isOverPlayer then
                    PlayHoverAnimation(WUIWaypointFrame)
                else
                    StopHoverAnimation(WUIWaypointFrame)
                end
            end

            wasOverPlayer = isOverPlayer
        end

        CallbackRegistry.Add("Waypoint.SlowUpdate", VerifyAndFadeWaypointWhenOverPlayer)
    end

    do -- Mouse over
        for _, f in ipairs(frames) do
            f:HookScript("OnEnter", PlayHoverAnimation)
            f:HookScript("OnLeave", StopHoverAnimation)
            f:HookScript("OnShow", StopHoverAnimation)
        end
    end
end

do -- Hide main frame during cinematics or when UI is hidden
    local f = CreateFrame("Frame")
    f:RegisterEvent("CINEMATIC_START")
    f:RegisterEvent("CINEMATIC_STOP")
    f:RegisterEvent("PLAY_MOVIE")
    f:RegisterEvent("STOP_MOVIE")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
            Waypoint.HideMainFrame()
        else
            Waypoint.ShowMainFrame()
        end
    end)

    hooksecurefunc("SetUIVisibility", function(visible)
        local useAlwaysShow = Config.DBGlobal:GetVariable("AlwaysShow")
        if visible or useAlwaysShow then Waypoint.ShowMainFrame() else Waypoint.HideMainFrame() end
    end)
end

do -- Re-render on UI scale change
    local frames = { WUIWaypointFrame, WUIPinpointFrame, WUINavigatorFrame }
    CallbackRegistry.Add("WoWClient.OnUIScaleChanged", function()
        for _, f in ipairs(frames) do
            if f:IsVisible() then
                f:_Render()
            end
        end
    end)
end

do -- Re-render on font change
    local frames = { WUIWaypointFrame, WUIPinpointFrame, WUINavigatorFrame }
    local function OnFontChanged()
        for _, f in ipairs(frames) do if f:IsVisible() then f:_Render() end end
    end

    SavedVariables.OnChange("WaypointDB_Global", "fontPath", OnFontChanged, 10)
end

Waypoint.HideAllFrames()
