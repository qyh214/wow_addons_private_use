local env                                    = select(2, ...)
local L                                      = env.L
local Config                                 = env.Config

local CreateVector2D                         = CreateVector2D
local Vector2D_CalculateAngleBetween         = Vector2D_CalculateAngleBetween
local GetCameraZoom                          = GetCameraZoom
local abs                                    = math.abs
local sqrt                                   = math.sqrt
local pi                                     = math.pi
local WorldFrame                             = WorldFrame
local UIParent                               = UIParent
local WUIFrame                               = WUIFrame
local WUIWaypointFrame                       = WUIWaypointFrame
local WUIWaypointFrame_Beam                  = WUIWaypointFrame.Beam
local WUIWaypointFrame_Footer                = WUIWaypointFrame.Footer
local WUIWaypointFrame_Footer_InfoText       = WUIWaypointFrame.Footer.InfoText
local WUIWaypointFrame_Footer_DistanceText   = WUIWaypointFrame.Footer.DistanceText
local WUIWaypointFrame_Footer_ArrivalTimeText = WUIWaypointFrame.Footer.ArrivalTimeText
local WUIPinpointFrame                       = WUIPinpointFrame
local WUIPinpointFrame_Foreground_Background = WUIPinpointFrame.Foreground.Background
local WUIPinpointFrame_Foreground_Content    = WUIPinpointFrame.Foreground.Content
local WUINavigatorFrame                      = WUINavigatorFrame
local WUINavigatorFrame_ArrowTexture         = WUINavigatorFrame.ArrowTexture

local Sound                                  = env.WPM:Import("wpm_modules/sound")
local CallbackRegistry                       = env.WPM:Import("wpm_modules/callback-registry")
local GenericEnum                            = env.WPM:Import("wpm_modules/generic-enum")
local SavedVariables                         = env.WPM:Import("wpm_modules/saved-variables")
local Utils_Formatting                       = env.WPM:Import("wpm_modules/utils/formatting")
local LocalUtil                              = env.WPM:Import("@/LocalUtil")
local MapPin                                 = env.WPM:Import("@/MapPin")
local Waypoint_Director                      = env.WPM:Import("@/Waypoint/Director")
local Waypoint_ArrivalTime                   = env.WPM:Import("@/Waypoint/ArrivalTime")
local Waypoint_Enum                          = env.WPM:Import("@/Waypoint/Enum")
local Waypoint_Cache                         = env.WPM:Import("@/Waypoint/Cache")
local Waypoint_Logic                         = env.WPM:New("@/Waypoint/Logic")


-- Shared
--------------------------------

local Setting = nil
local cachedMode = nil
local cachedNavFrame = nil
local cachedContextIcon = nil


-- Position
--------------------------------

do -- Waypoint / Pinpoint
    local function refreshWUIFrameAnchors()
        local navFrame = Waypoint_Cache.navFrame
        cachedNavFrame = navFrame
        if not navFrame then return end

        WUIWaypointFrame:ClearAllPoints()
        WUIWaypointFrame:SetPoint("CENTER", navFrame)

        WUIPinpointFrame:ClearAllPoints()
        WUIPinpointFrame:SetPoint("BOTTOM", navFrame, "TOP", 0, 75)
    end
    CallbackRegistry:Add("Waypoint_DataProvider.NavFrameObtained", refreshWUIFrameAnchors, 10)
end

do -- Navigator
    local UP_VECTOR                          = CreateVector2D(0, 1)
    local MIN_ZOOM                           = 12

    local savedZoom                          = nil
    local savedDistance                      = nil
    local savedArrowVector                   = CreateVector2D(0, 0)
    local savedMajorAxisSquared              = nil
    local savedMinorAxisSquared              = nil
    local savedAxesMultiplied                = nil
    local centerScreenX, centerScreenY       = 0, 0
    local lastNavX, lastNavY                 = nil, nil
    local isUpdateNeeded                     = false

    local targetPositionX, targetPositionY   = 0, 0
    local currentPositionX, currentPositionY = 0, 0
    local targetAngle                        = 0
    local currentAngle                       = 0
    local ROTATION_THRESHOLD                 = 0.01
    local POSITION_THRESHOLD                 = 1

    local function getCenterScreenPoint()
        local centerX, centerY = WorldFrame:GetCenter()
        local scale = UIParent:GetEffectiveScale() or 1
        return centerX / scale, centerY / scale
    end

    local function updatePosition()
        if not cachedNavFrame then return false end

        local navX, navY = cachedNavFrame:GetCenter()
        local posX = navX - centerScreenX
        local posY = navY - centerScreenY
        local denominator = sqrt(savedMajorAxisSquared * posY * posY + savedMinorAxisSquared * posX * posX)

        if denominator == 0 then return false end

        local ratio = savedAxesMultiplied / denominator
        targetPositionX = posX * ratio
        targetPositionY = posY * ratio

        -- Initialize current position on first run to avoid snapping from origin (0,0)
        if currentPositionX == 0 and currentPositionY == 0 then
            currentPositionX = targetPositionX
            currentPositionY = targetPositionY
        else
            -- Interpolate
            currentPositionX = currentPositionX + (targetPositionX - currentPositionX) / 2
            currentPositionY = currentPositionY + (targetPositionY - currentPositionY) / 2
        end

        WUINavigatorFrame:ClearAllPoints()
        WUINavigatorFrame:SetPoint("CENTER", WorldFrame, "CENTER", currentPositionX, currentPositionY)

        local deltaX = targetPositionX - currentPositionX
        local deltaY = targetPositionY - currentPositionY
        return (abs(deltaX) > POSITION_THRESHOLD) or (abs(deltaY) > POSITION_THRESHOLD)
    end

    local function updateArrow()
        if not cachedNavFrame then return false end

        local navX, navY = cachedNavFrame:GetCenter()
        savedArrowVector:SetXY(navX - centerScreenX, navY - centerScreenY)

        -- Calculate the target angle
        targetAngle = -Vector2D_CalculateAngleBetween(savedArrowVector.x, savedArrowVector.y, UP_VECTOR.x, UP_VECTOR.y)
        local angleDiff = (targetAngle - currentAngle + pi) % (2 * pi) - pi

        -- Check if the difference is large enough and apply smooth interpolating rotation
        if abs(angleDiff) > ROTATION_THRESHOLD then
            currentAngle = currentAngle + angleDiff / 2
        else
            currentAngle = targetAngle
        end

        -- Apply the rotation
        WUINavigatorFrame_ArrowTexture:SetRotation(currentAngle)
        return abs((targetAngle - currentAngle + pi) % (2 * pi) - pi) > ROTATION_THRESHOLD
    end

    local function setInfo(major, minor)
        savedMajorAxisSquared = major * major
        savedMinorAxisSquared = minor * minor
        savedAxesMultiplied = major * minor
    end

    local function updateVariables()
        local Setting_NavigatorDistance = Config.DBGlobal:GetVariable("NavigatorDistance")
        local Setting_NavigatorDynamicDistance = Config.DBGlobal:GetVariable("NavigatorDynamicDistance")

        local zoom = Setting_NavigatorDynamicDistance and math.max(MIN_ZOOM, GetCameraZoom()) or 39

        if zoom ~= savedZoom or Setting_NavigatorDistance ~= savedDistance then
            local baseZoom = 35
            local baseMajor, baseMinor = 200, 100
            local major, minor = math.min(baseMajor * (baseZoom / zoom), 500), math.min(baseMinor * (baseZoom / zoom), 500)
            major = major * (Setting_NavigatorDistance or 1)
            minor = minor * (Setting_NavigatorDistance or 1)

            savedZoom = zoom
            savedDistance = Setting_NavigatorDistance
            setInfo(major, minor)
        end

        centerScreenX, centerScreenY = getCenterScreenPoint()

        if cachedNavFrame then
            local navX, navY = cachedNavFrame:GetCenter()

            if navX ~= lastNavX or navY ~= lastNavY then
                lastNavX, lastNavY = navX, navY
                isUpdateNeeded = true
            end
        end
    end

    local function ForceUpdate()
        updateVariables()

        local needPositionUpdate = updatePosition()
        local needRotationUpdate = updateArrow()
        isUpdateNeeded = (needPositionUpdate or needRotationUpdate)
    end
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorDistance", ForceUpdate)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorDynamicDistance", ForceUpdate)

    local function OnUpdate()
        if not cachedNavFrame then return end

        updateVariables()

        if isUpdateNeeded then
            local needPositionUpdate = updatePosition()
            local needRotationUpdate = updateArrow()
            isUpdateNeeded = (needPositionUpdate or needRotationUpdate)
        end
    end
    WUINavigatorFrame:SetScript("OnUpdate", OnUpdate)
end


-- Appearance
--------------------------------

do -- Size
    do -- Waypoint
        local REFERENCE_DISTANCE = 2000
        local REFERENCE_SCALE = .25
        local SCALE, SCALE_MIN, SCALE_MAX

        local function updateVariables()
            SCALE = Config.DBGlobal:GetVariable("WaypointScale")
            SCALE_MIN = Config.DBGlobal:GetVariable("WaypointScaleMin")
            SCALE_MAX = Config.DBGlobal:GetVariable("WaypointScaleMax")
        end

        SavedVariables.OnChange("WaypointDB_Global", "WaypointScale", updateVariables)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointScaleMin", updateVariables)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointScaleMax", updateVariables)
        CallbackRegistry:Add("Preload.DatabaseReady", updateVariables)



        local function getScaleForDistance(distance, referenceDistance, referenceScale, minScale, maxScale, exponent)
            exponent = exponent or 1

            if distance <= 0 then return maxScale end
            local rawScale = referenceScale * (referenceDistance / distance) ^ exponent
            if rawScale < minScale then
                return minScale
            elseif rawScale > maxScale then
                return maxScale
            else
                return rawScale
            end
        end



        local lastScale = nil

        WUIWaypointFrame:SetScript("OnUpdate", function()
            local distance = Waypoint_Cache.Get("distance")
            if not distance then return end

            local scale = nil
            if SCALE_MIN == SCALE_MAX then scale = SCALE_MAX else scale = (getScaleForDistance(distance, REFERENCE_DISTANCE, REFERENCE_SCALE, SCALE_MIN, SCALE_MAX)) end
            scale = scale * (SCALE or 1)

            if not lastScale or abs(lastScale - scale) > .0025 then
                lastScale = scale
                WUIWaypointFrame:SetScale(scale)
            end
        end)
    end

    do -- Pinpoint
        local function updatePinpointScale()
            local scale = Config.DBGlobal:GetVariable("PinpointScale")
            WUIPinpointFrame:SetScale(scale or 1)
            WUIPinpointFrame:_Render()
        end

        SavedVariables.OnChange("WaypointDB_Global", "PinpointScale", updatePinpointScale)
        CallbackRegistry:Add("Preload.DatabaseReady", updatePinpointScale)
    end

    do -- Navigator
        local function updateNavigatorScale()
            local scale = Config.DBGlobal:GetVariable("NavigatorScale")
            WUINavigatorFrame:SetScale(scale or 1)
        end

        SavedVariables.OnChange("WaypointDB_Global", "NavigatorScale", updateNavigatorScale)
        CallbackRegistry:Add("Preload.DatabaseReady", updateNavigatorScale)
    end
end

do -- Color
    local function resolveColorIntegrity(color)
        if not color then return false end
        if type(color) == "table" and color.r and color.g and color.b then return color end
        return false
    end

    -- Returns tint color and recolor flag
    ---@param ContextIconTexture? table used to determine whether to apply recolor for specific context icon
    ---@return table|nil color
    ---@return boolean|nil recolor
    function Waypoint_Logic.GetTintColorInfo(ContextIconTexture)
        if not Setting then return end

        local Setting_CustomColor           = (Setting:GetVariable("CustomColor") == true)

        local ColorQuestIncomplete          = (Setting_CustomColor and resolveColorIntegrity(Setting:GetVariable("CustomColorQuestIncomplete"))) or (env.Enum.ColorRGB.QuestIncomplete)
        local ColorQuestComplete            = (Setting_CustomColor and resolveColorIntegrity(Setting:GetVariable("CustomColorQuestComplete"))) or (env.Enum.ColorRGB.QuestNormal)
        local ColorQuestCompleteRecurring   = (Setting_CustomColor and resolveColorIntegrity(Setting:GetVariable("CustomColorQuestCompleteRepeatable"))) or (env.Enum.ColorRGB.QuestRepeatable)
        local ColorQuestCompleteImportant   = (Setting_CustomColor and resolveColorIntegrity(Setting:GetVariable("CustomColorQuestCompleteImportant"))) or (env.Enum.ColorRGB.QuestImportant)
        local ColorOther                    = (Setting_CustomColor and resolveColorIntegrity(Setting:GetVariable("CustomColorOther"))) or (env.Enum.ColorRGB.Other)

        local RecolorQuestIncomplete        = (Setting_CustomColor and Setting:GetVariable("CustomColorQuestIncompleteTint")) or (not Setting_CustomColor and false)
        local RecolorQuestComplete          = (Setting_CustomColor and Setting:GetVariable("CustomColorQuestCompleteTint")) or (not Setting_CustomColor and false)
        local RecolorQuestCompleteRecurring = (Setting_CustomColor and Setting:GetVariable("CustomColorQuestCompleteRepeatableTint")) or (not Setting_CustomColor and false)
        local RecolorQuestCompleteImportant = (Setting_CustomColor and Setting:GetVariable("CustomColorQuestCompleteImportantTint")) or (not Setting_CustomColor and false)
        local RecolorOther                  = (Setting_CustomColor and Setting:GetVariable("CustomColorOtherTint")) or (not Setting_CustomColor and false)




        local color = nil
        local recolor = nil

        local requestRecolor = ContextIconTexture and ContextIconTexture.requestRecolor or false
        local trackingType = Waypoint_Cache.Get("trackingType")
        local pinType = Waypoint_Cache.Get("pinType")

        if pinType == Enum.SuperTrackingType.Corpse then
            color = {
                r = GenericEnum.ColorRGB.White.r,
                g = GenericEnum.ColorRGB.White.g,
                b = GenericEnum.ColorRGB.White.b,
                a = 1
            }
            recolor = requestRecolor or false
        elseif trackingType == Waypoint_Enum.TrackingType.QuestComplete then
            color = ColorQuestComplete
            recolor = requestRecolor or RecolorQuestComplete
        elseif trackingType == Waypoint_Enum.TrackingType.QuestCompleteRecurring then
            color = ColorQuestCompleteRecurring
            recolor = requestRecolor or RecolorQuestCompleteRecurring
        elseif trackingType == Waypoint_Enum.TrackingType.QuestCompleteImportant then
            color = ColorQuestCompleteImportant
            recolor = requestRecolor or RecolorQuestCompleteImportant
        elseif trackingType == Waypoint_Enum.TrackingType.QuestIncomplete then
            color = ColorQuestIncomplete
            recolor = requestRecolor or RecolorQuestIncomplete
        else
            color = ColorOther
            recolor = requestRecolor or RecolorOther
        end

        return color, recolor
    end

    function Waypoint_Logic.UpdateColor()
        if not cachedContextIcon then return end

        -- Set icon and tint
        local tintColor, recolor = Waypoint_Logic.GetTintColorInfo(cachedContextIcon)

        WUIWaypointFrame:Appearance_SetTint(tintColor)
        WUIWaypointFrame:Appearance_SetRecolor(recolor)
        WUIPinpointFrame:Appearance_SetTint(tintColor)
        WUIPinpointFrame:Appearance_SetRecolor(recolor)
        WUINavigatorFrame:Appearance_SetTint(tintColor)
        WUINavigatorFrame:Appearance_SetRecolor(recolor)
    end

    SavedVariables.OnChange("WaypointDB_Global", "CustomColor", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestIncomplete", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestComplete", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteRepeatable", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteImportant", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorOther", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestIncompleteTint", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteTint", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteRepeatableTint", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorQuestCompleteImportantTint", Waypoint_Logic.UpdateColor)
    SavedVariables.OnChange("WaypointDB_Global", "CustomColorOtherTint", Waypoint_Logic.UpdateColor)
end

do -- Other
    do -- Waypoint
        local function updateWaypointBeam()
            WUIWaypointFrame_Beam:SetShown(Config.DBGlobal:GetVariable("WaypointBeam"))
            WUIWaypointFrame_Beam:SetAlpha(Config.DBGlobal:GetVariable("WaypointBeamAlpha"))
        end

        SavedVariables.OnChange("WaypointDB_Global", "WaypointBeam", updateWaypointBeam)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointBeamAlpha", updateWaypointBeam)
        CallbackRegistry:Add("Preload.DatabaseReady", updateWaypointBeam)



        local function updateWaypointFooterAppearance()
            local Setting_DistanceTextEnabled = Config.DBGlobal:GetVariable("WaypointDistanceText")


            -- Footer visibility
            WUIWaypointFrame_Footer:SetShown(Setting_DistanceTextEnabled)
            if not Setting_DistanceTextEnabled then return end



            -- Footer alpha / scale
            local Setting_DistanceTextAlpha = Config.DBGlobal:GetVariable("WaypointDistanceTextAlpha")
            local Setting_DistanceTextScale = Config.DBGlobal:GetVariable("WaypointDistanceTextScale")

            WUIWaypointFrame_Footer:SetAlpha(Setting_DistanceTextAlpha)
            WUIWaypointFrame_Footer:SetScale(Setting_DistanceTextScale)


            -- Text visibility based on type
            local Setting_DistanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
            local showInfoText = (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.DestinationName) or (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
            local showDistanceText = (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.Distance) or (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
            local showArrivalTime = (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.ArrivalTime) or (Setting_DistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)

            WUIWaypointFrame_Footer_InfoText:SetShown(showInfoText)
            WUIWaypointFrame_Footer_DistanceText:SetShown(showDistanceText)
            WUIWaypointFrame_Footer_ArrivalTimeText:SetShown(showArrivalTime)
            WUIWaypointFrame_Footer:_Render()
        end

        SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceText", updateWaypointFooterAppearance)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceTextType", updateWaypointFooterAppearance)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceTextAlpha", updateWaypointFooterAppearance)
        SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceTextScale", updateWaypointFooterAppearance)
        CallbackRegistry:Add("Preload.DatabaseReady", updateWaypointFooterAppearance)
    end

    do -- Navigator
        local function updateNavigatorAlpha()
            WUINavigatorFrame:SetAlpha(Config.DBGlobal:GetVariable("NavigatorAlpha") or 1)
        end

        SavedVariables.OnChange("WaypointDB_Global", "NavigatorAlpha", updateNavigatorAlpha)
        CallbackRegistry:Add("Preload.DatabaseReady", updateNavigatorAlpha)
    end
end


-- Interface
--------------------------------

--[[
    Callback Events:
        Waypoint.ContextUpdate
        Waypoint.SuperTrackingChanged
        Waypoint.QuestBlobChanged
        Waypoint.ActiveChanged
        Waypoint.NavigationModeChanged
]]

local function hideWaypoint() WUIWaypointFrame:Hide() end
local function showWaypoint() WUIWaypointFrame:Show() end
local function hidePinpoint() WUIPinpointFrame:Hide() end
local function showPinpoint() WUIPinpointFrame:Show() end
local function hideNavigator() WUINavigatorFrame:Hide() end
local function showNavigator() WUINavigatorFrame:Show() end

function Waypoint_Logic.HideAllFrames()
    WUIWaypointFrame:Hide()
    WUIPinpointFrame:Hide()
    WUINavigatorFrame:Hide()
end
CallbackRegistry:Add("Waypoint.HideAllFrames", Waypoint_Logic.HideAllFrames)

function Waypoint_Logic.HideMainFrame()
    WUIFrame:Hide()
end

function Waypoint_Logic.ShowMainFrame()
    WUIFrame:Show()

    -- Replay animations to address animation freezes
    if WUIWaypointFrame:IsShown() then
        CallbackRegistry:Trigger("WaypointAnimation.WaypointShow")
    end

    if WUIPinpointFrame:IsShown() then
        CallbackRegistry:Trigger("WaypointAnimation.PinpointShow")
    end

    if WUINavigatorFrame:IsShown() then
        CallbackRegistry:Trigger("WaypointAnimation.NavigatorShow")
    end
end


do -- Update
    function Waypoint_Logic.Waypoint_UpdateInfoText()
        local Setting_WaypointDistanceText = Config.DBGlobal:GetVariable("WaypointDistanceText")
        if not Setting_WaypointDistanceText then return end

        local Setting_WaypointDistanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
        local showInfoText = (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.DestinationName) or (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
        if not showInfoText then return end

        local PinName = Waypoint_Cache.Get("pinName")
        local RedirectInfo = Waypoint_Cache.Get("redirectInfo")
        local PinType = Waypoint_Cache.Get("pinType")

        local newText = nil

        if RedirectInfo and RedirectInfo.valid then
            newText = RedirectInfo.text or nil
        elseif PinType == Enum.SuperTrackingType.Quest then
            local questName = Waypoint_Cache.Get("questName")
            newText = questName or nil
        elseif PinName then
            newText = PinName
        end

        local oldText = WUIWaypointFrame_Footer_InfoText:GetText()
        WUIWaypointFrame_Footer_InfoText:SetShown(newText ~= nil)
        if WUIWaypointFrame_Footer_InfoText:IsShown() and oldText ~= newText then
            WUIWaypointFrame_Footer_InfoText:SetText(newText)
        end

        WUIWaypointFrame_Footer:_Render()
    end

    function Waypoint_Logic.Waypoint_UpdateDistanceText()
        local Setting_WaypointDistanceText = Config.DBGlobal:GetVariable("WaypointDistanceText")
        if not Setting_WaypointDistanceText then return end

        local Setting_WaypointDistanceTextType = Config.DBGlobal:GetVariable("WaypointDistanceTextType")
        local isDistance = (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.Distance) or (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)
        local isArrivalTime = (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.ArrivalTime) or (Setting_WaypointDistanceTextType == Waypoint_Enum.WaypointDistanceTextType.All)


        -- Distance
        --------------------------------

        if isDistance then
            local distance = Waypoint_Cache.Get("distance")
            local oldText = WUIWaypointFrame_Footer_DistanceText:GetText()
            local newText = tostring(LocalUtil:FormatDistance(distance))

            if oldText ~= newText then
                WUIWaypointFrame_Footer_DistanceText:SetText(newText)
            end
        end


        -- Arrival Time
        --------------------------------

        local isValidArrivalTime = (Waypoint_ArrivalTime:GetSeconds() > 0)

        if isArrivalTime and isValidArrivalTime then
            local _, _, _, h, m, s = Utils_Formatting.FormatTime(Waypoint_ArrivalTime:GetSeconds())
            WUIWaypointFrame_Footer_ArrivalTimeText:SetText(h .. m .. s)
        else
            WUIWaypointFrame_Footer_ArrivalTimeText:SetText("")
        end
    end

    function Waypoint_Logic.Pinpoint_UpdateText()
        local Setting_PinpointInfo = Config.DBGlobal:GetVariable("PinpointInfo")
        local Setting_PinpointExtendedInfo = Config.DBGlobal:GetVariable("PinpointInfoExtended")


        local PinType = Waypoint_Cache.Get("pinType")
        local RedirectInfo = Waypoint_Cache.Get("redirectInfo")
        local PinName = Waypoint_Cache.Get("pinName")
        local PinDescription = Waypoint_Cache.Get("pinDescription")

        -- If pinpoint info is disabled, clear text and return
        local oldText = WUIPinpointFrame_Foreground_Content:GetText()
        local newText = ""
        local opacity = .5

        if Setting_PinpointInfo then
            if RedirectInfo.valid then -- Redirect
                newText = RedirectInfo.text
            elseif PinType == Enum.SuperTrackingType.Quest then -- Quest
                local questComplete = Waypoint_Cache.Get("questComplete")
                local questName = Waypoint_Cache.Get("questName")

                if questComplete then
                    local questCompletionText = Waypoint_Cache.Get("questCompletionText") or L["WaypointSystem - Pinpoint - Quest - Complete"]

                    if Setting_PinpointExtendedInfo then
                        newText = questName .. "\n" .. GenericEnum.ColorHEX.Gray .. questCompletionText .. "|r"
                    else
                        newText = questCompletionText
                    end
                else
                    --[[
                    Blizzard `QuestObjectiveInfo[]` https://warcraft.wiki.gg/wiki/API_C_QuestLog.GetQuestObjectives
                        text: string            The text displayed in the quest log and the quest tracker
                        type: string            monster", "item", etc.
                        finished: boolean       true if the objective has been completed
                        numFulfilled: number    number of partial objectives fulfilled
                        numRequired: number     number of partial objectives required
                        objectiveType: QuestObjectiveType?
                ]]

                    local allObjectives = Waypoint_Cache.Get("questObjectiveInfo").objectives

                    -- Gather objective info and display incomplete tasks
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
            elseif PinName then
                if Setting_PinpointExtendedInfo then
                    local description = ""
                    local newLine = PinName and #PinName > 0 and "\n" or ""
                    if PinDescription and #PinDescription > 0 then description = newLine .. GenericEnum.ColorHEX.Gray .. PinDescription .. "|r" end

                    newText = PinName .. description
                else
                    newText = PinName
                end
            end
        else
            newText = ""
        end

        WUIPinpointFrame_Foreground_Background:SetShown(#newText > 1)
        if #newText <= 1 then
            opacity = 1
        end

        if oldText ~= newText then
            WUIPinpointFrame_Foreground_Content:SetText(newText)
            WUIPinpointFrame:Appearance_SetIconOpacity(opacity)
        end
    end
end

do -- Events
    function Waypoint_Logic.UpdateFrameVisibility(event, mode)
        local Setting_NavigatorShow = Config.DBGlobal:GetVariable("NavigatorShow")

        cachedMode = mode

        if mode == Waypoint_Enum.NavigationMode.Waypoint then
            CallbackRegistry:Trigger("WaypointAnimation.WaypointShow")
            CallbackRegistry:Trigger("WaypointAnimation.PinpointHide")
            CallbackRegistry:Trigger("WaypointAnimation.NavigatorHide")
        elseif mode == Waypoint_Enum.NavigationMode.Pinpoint then
            CallbackRegistry:Trigger("WaypointAnimation.WaypointHide")
            CallbackRegistry:Trigger("WaypointAnimation.PinpointShow")
            CallbackRegistry:Trigger("WaypointAnimation.NavigatorHide")
        elseif mode == Waypoint_Enum.NavigationMode.Navigator and Setting_NavigatorShow then
            CallbackRegistry:Trigger("WaypointAnimation.WaypointHide")
            CallbackRegistry:Trigger("WaypointAnimation.PinpointHide")
            CallbackRegistry:Trigger("WaypointAnimation.NavigatorShow")
        else
            CallbackRegistry:Trigger("WaypointAnimation.WaypointHide")
            CallbackRegistry:Trigger("WaypointAnimation.PinpointHide")
            CallbackRegistry:Trigger("WaypointAnimation.NavigatorHide")
        end

        Waypoint_Logic.UnblockTransition()
    end
    CallbackRegistry:Add("Waypoint.NavigationModeChanged", Waypoint_Logic.UpdateFrameVisibility)
    SavedVariables.OnChange("WaypointDB_Global", "NavigatorShow", function() Waypoint_Logic.UpdateFrameVisibility(Waypoint_Director:GetNavigationMode()) end)

    function Waypoint_Logic.UpdateRealtime()
        if cachedMode == Waypoint_Enum.NavigationMode.Waypoint then
            Waypoint_Logic.Waypoint_UpdateDistanceText()
        end
    end
    CallbackRegistry:Add("Waypoint_DataProvider.CacheRealtime", Waypoint_Logic.UpdateRealtime)

    function Waypoint_Logic.UpdateContext()
        -- Obtain the current context icon; Redirect, Quest, Pin
        local redirectInfo = Waypoint_Cache.Get("redirectInfo")
        local pinType = Waypoint_Cache.Get("pinType")
        if redirectInfo and redirectInfo.valid then
            cachedContextIcon = Waypoint_Cache.Get("redirectContextIcon")
        elseif pinType == Enum.SuperTrackingType.Quest and not Waypoint_Cache.Get("questIsWorldQuest") then
            cachedContextIcon = Waypoint_Cache.Get("questContextIcon")
        else
            cachedContextIcon = Waypoint_Cache.Get("pinContextIcon")
        end
        if not cachedContextIcon then return end

        -- Set icon
        WUIWaypointFrame:Appearance_SetIcon(cachedContextIcon)
        WUIPinpointFrame:Appearance_SetIcon(cachedContextIcon)
        WUINavigatorFrame:Appearance_SetIcon(cachedContextIcon)

        -- Apply color
        Waypoint_Logic.UpdateColor()

        -- Set pinpoint info text
        Waypoint_Logic.Pinpoint_UpdateText()

        -- Set waypoint info text
        Waypoint_Logic.Waypoint_UpdateInfoText()

    end
    CallbackRegistry:Add("Waypoint.ContextUpdate", Waypoint_Logic.UpdateContext, 10)
    SavedVariables.OnChange("WaypointDB_Global", "PinpointInfo", Waypoint_Logic.UpdateContext)
    SavedVariables.OnChange("WaypointDB_Global", "PinpointInfoExtended", Waypoint_Logic.UpdateContext)
    SavedVariables.OnChange("WaypointDB_Global", "WaypointDistanceTextType", Waypoint_Logic.UpdateContext)
end


-- Audio
--------------------------------

local function playWaypointShowAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.WaypointShow

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomShowWaypoint")
        end
    end

    Sound.PlaySound("Main", soundID)
end

local function playPinpointShowAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.PinpointShow

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomShowPinpoint")
        end
    end

    Sound.PlaySound("Main", soundID)
end


-- Animation
--------------------------------

local blockTransitionChange = false
local waypointAwaitIntro = false
local waypointAwaitOutro = false
local pinpointAwaitIntro = false
local pinpointAwaitOutro = false

function Waypoint_Logic.BlockTransition()
    blockTransitionChange = true
end

function Waypoint_Logic.UnblockTransition()
    blockTransitionChange = false
end

function Waypoint_Logic.ShowWaypoint()
    showWaypoint()

    if waypointAwaitIntro then
        waypointAwaitIntro = false
        playWaypointShowAudio()
        WUIWaypointFrame.Animation:Play(WUIWaypointFrame, "INTRO")
    else
        WUIWaypointFrame.Animation:Play(WUIWaypointFrame, "FADE_IN")
    end
end
CallbackRegistry:Add("WaypointAnimation.WaypointShow", Waypoint_Logic.ShowWaypoint)

function Waypoint_Logic.HideWaypoint()
    if waypointAwaitOutro then
        waypointAwaitOutro = false
        WUIWaypointFrame.Animation:Play(WUIWaypointFrame, "OUTRO").onFinish(hideWaypoint)
    else
        WUIWaypointFrame.Animation:Play(WUIWaypointFrame, "FADE_OUT").onFinish(hideWaypoint)
    end
end
CallbackRegistry:Add("WaypointAnimation.WaypointHide", Waypoint_Logic.HideWaypoint)

function Waypoint_Logic.ShowPinpoint()
    showPinpoint()

    if pinpointAwaitIntro then
        pinpointAwaitIntro = false
        playPinpointShowAudio()
        WUIPinpointFrame.Animation:Play(WUIPinpointFrame, "INTRO")
    else
        WUIPinpointFrame.Animation:Play(WUIPinpointFrame, "FADE_IN")
    end
end
CallbackRegistry:Add("WaypointAnimation.PinpointShow", Waypoint_Logic.ShowPinpoint)

function Waypoint_Logic.HidePinpoint()
    if pinpointAwaitOutro then
        pinpointAwaitOutro = false
        WUIPinpointFrame.Animation:Play(WUIPinpointFrame, "OUTRO").onFinish(hidePinpoint)
    else
        WUIPinpointFrame.Animation:Play(WUIPinpointFrame, "FADE_OUT").onFinish(hidePinpoint)
    end
end
CallbackRegistry:Add("WaypointAnimation.PinpointHide", Waypoint_Logic.HidePinpoint)

function Waypoint_Logic.ShowNavigator()
    showNavigator()
    WUINavigatorFrame.Animation:Play(WUINavigatorFrame, "FADE_IN")
end
CallbackRegistry:Add("WaypointAnimation.NavigatorShow", Waypoint_Logic.ShowNavigator)

function Waypoint_Logic.HideNavigator()
    WUINavigatorFrame.Animation:Play(WUINavigatorFrame, "FADE_OUT").onFinish(hideNavigator)
end
CallbackRegistry:Add("WaypointAnimation.NavigatorHide", Waypoint_Logic.HideNavigator)

function Waypoint_Logic.TransitionWaypointToPinpoint()
    if blockTransitionChange then return end

    waypointAwaitIntro = false
    waypointAwaitOutro = true
    pinpointAwaitIntro = true
    pinpointAwaitOutro = false
end
CallbackRegistry:Add("WaypointAnimation.WaypointToPinpoint", Waypoint_Logic.TransitionWaypointToPinpoint)

function Waypoint_Logic.TransitionPinpointToWaypoint()
    if blockTransitionChange then return end

    waypointAwaitIntro = true
    waypointAwaitOutro = false
    pinpointAwaitIntro = false
    pinpointAwaitOutro = true
end
CallbackRegistry:Add("WaypointAnimation.PinpointToWaypoint", Waypoint_Logic.TransitionPinpointToWaypoint)

function Waypoint_Logic.New()
    Waypoint_Logic.BlockTransition()
    Waypoint_Logic.HideAllFrames()

    waypointAwaitIntro = true
    waypointAwaitOutro = false
    pinpointAwaitIntro = true
    pinpointAwaitOutro = false

    Waypoint_Logic.UpdateFrameVisibility(Waypoint_Director:GetNavigationMode())
end
CallbackRegistry:Add("WaypointAnimation.New", Waypoint_Logic.New)


-- Additional Features
--------------------------------

do -- Hide SuperTrackedFrame while Waypoint is active
    local function hideSuperTrackedFrame()
        if not Waypoint_Director.isActive then return end
        SuperTrackedFrame:Hide()
    end

    CallbackRegistry:Add("Waypoint.ActiveChanged", hideSuperTrackedFrame)
    hooksecurefunc(SuperTrackedFrame, "SetShown", hideSuperTrackedFrame)
    hooksecurefunc(SuperTrackedFrame, "Show", hideSuperTrackedFrame)
end

do -- Right cick WUI frames to untrack
    local Setting_RightClickToClear = nil


    local function updateMouseEvents()
        local propagate = (not Setting_RightClickToClear)
        WUIWaypointFrame:AwaitSetPropagateMouseClicks(propagate)
        WUIPinpointFrame:AwaitSetPropagateMouseClicks(propagate)
        WUINavigatorFrame:AwaitSetPropagateMouseClicks(propagate)
    end

    local function updateVariables()
        Setting_RightClickToClear = Config.DBGlobal:GetVariable("RightClickToClear")
        updateMouseEvents()
    end
    SavedVariables.OnChange("WaypointDB_Global", "RightClickToClear", updateVariables)
    CallbackRegistry:Add("Preload.DatabaseReady", updateVariables)



    WUIWaypointFrame:SetScript("OnMouseDown", function(_, button)
        if Setting_RightClickToClear and button == "RightButton" then
            MapPin:ClearDestination()
        end
    end)
    WUIPinpointFrame:SetScript("OnMouseDown", function(_, button)
        if Setting_RightClickToClear and button == "RightButton" then
            MapPin:ClearDestination()
        end
    end)
    WUINavigatorFrame:SetScript("OnMouseDown", function(_, button)
        if Setting_RightClickToClear and button == "RightButton" then
            MapPin:ClearDestination()
        end
    end)
end

do -- Background Preview
    local Setting_BackgroundPreview = false


    local function updateVariables()
        Setting_BackgroundPreview = Config.DBGlobal:GetVariable("BackgroundPreview")
    end
    SavedVariables.OnChange("WaypointDB_Global", "BackgroundPreview", updateVariables)
    CallbackRegistry:Add("Preload.DatabaseReady", updateVariables)



    local function playHoverAnimation(frame)
        if not Setting_BackgroundPreview then return end; frame.Animation_Hover:Play(frame, "ENABLED")
    end
    local function stopHoverAnimation(frame)
        if not Setting_BackgroundPreview then return end; frame.Animation_Hover:Play(frame, "DISABLED")
    end



    do -- Fade out WUI frame while over player
        local THRESHOLD = 75
        local wasOverPlayer = false

        local function verifyAndFadeWaypointWhenOverPlayer()
            if not Setting_BackgroundPreview then return end

            if not cachedNavFrame then return end
            local distance = LocalUtil:GetFrameDistanceFromScreenCenter(cachedNavFrame)
            local isOverPlayer = (distance <= THRESHOLD)

            if isOverPlayer == wasOverPlayer then return end

            if WUIWaypointFrame:IsShown() then
                if isOverPlayer then
                    playHoverAnimation(WUIWaypointFrame)
                else
                    stopHoverAnimation(WUIWaypointFrame)
                end
            end

            wasOverPlayer = isOverPlayer
        end

        CallbackRegistry:Add("Waypoint.SlowUpdate", verifyAndFadeWaypointWhenOverPlayer)
    end

    do -- Mouse over
        WUIWaypointFrame:HookScript("OnEnter", playHoverAnimation)
        WUIWaypointFrame:HookScript("OnLeave", stopHoverAnimation)
        WUIWaypointFrame:HookScript("OnShow", stopHoverAnimation)

        WUIPinpointFrame:HookScript("OnEnter", playHoverAnimation)
        WUIPinpointFrame:HookScript("OnLeave", stopHoverAnimation)
        WUIPinpointFrame:HookScript("OnShow", stopHoverAnimation)

        WUINavigatorFrame:HookScript("OnEnter", playHoverAnimation)
        WUINavigatorFrame:HookScript("OnLeave", stopHoverAnimation)
        WUINavigatorFrame:HookScript("OnShow", stopHoverAnimation)
    end
end

do -- Hide main WUI frame during cinematic or UI parent hidden
    local EL = CreateFrame("Frame")
    EL:RegisterEvent("CINEMATIC_START")
    EL:RegisterEvent("CINEMATIC_STOP")
    EL:RegisterEvent("PLAY_MOVIE")
    EL:RegisterEvent("STOP_MOVIE")
    EL:SetScript("OnEvent", function(self, event, ...)
        if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
            Waypoint_Logic.HideMainFrame()
        else
            Waypoint_Logic.ShowMainFrame()
        end
    end)

    hooksecurefunc("SetUIVisibility", function(visible)
        local Setting_AlwaysShow = Config.DBGlobal:GetVariable("AlwaysShow")

        if visible or Setting_AlwaysShow then
            Waypoint_Logic.ShowMainFrame()
        else
            Waypoint_Logic.HideMainFrame()
        end
    end)
end

do -- Resize when UI scale changes
    local function OnUIScaleChanged()
        if WUIWaypointFrame:IsVisible() then
            WUIWaypointFrame:_Render()
        end

        if WUIPinpointFrame:IsVisible() then
            WUIPinpointFrame:_Render()
        end

        if WUINavigatorFrame:IsVisible() then
            WUINavigatorFrame:_Render()
        end
    end

    local EL = CreateFrame("Frame")
    EL:RegisterEvent("UI_SCALE_CHANGED")
    EL:SetScript("OnEvent", OnUIScaleChanged)
end

do -- Resize when font changes
    local function OnFontChanged()
        WUIPinpointFrame:_Render()
    end

    SavedVariables.OnChange("WaypointDB_Global", "PrefFont", OnFontChanged, 10)
end


-- Setup
--------------------------------

Waypoint_Logic:HideAllFrames()

local function OnDatabaseLoaded()
    Setting = Config.DBGlobal
end
CallbackRegistry:Add("Preload.DatabaseReady", OnDatabaseLoaded)
