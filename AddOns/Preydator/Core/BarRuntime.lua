local Preydator = _G.Preydator
if type(Preydator) ~= "table" then
    return
end

local api = Preydator.API
if type(api) ~= "table" or type(api.GetBarRuntimeContext) ~= "function" then
    return
end

local function ResolveContext()
    local ctx = api.GetBarRuntimeContext()
    if type(ctx) ~= "table" then
        return nil
    end

    if type(ctx.settings) ~= "table" or type(ctx.state) ~= "table" or type(ctx.UI) ~= "table" then
        return nil
    end

    return ctx
end

local function ResolveLocaleSafeFont(fallbackFont)
    local locale = _G.GetLocale and _G.GetLocale()
    local standardTextFont = rawget(_G, "STANDARD_TEXT_FONT")
    if (locale == "ruRU" or locale == "koKR" or locale == "zhCN" or locale == "zhTW")
        and type(standardTextFont) == "string" and standardTextFont ~= ""
    then
        return standardTextFont
    end

    return fallbackFont
end

local function ApplyVerticalLabelRotation(fontString, enabled, side)
    if not fontString or not fontString.SetRotation then
        return
    end

    if enabled then
        if side == "left" then
            fontString:SetRotation(math.pi / 2)
        else
            fontString:SetRotation(-math.pi / 2)
        end
    else
        fontString:SetRotation(0)
    end
end

local function ResolveVerticalLabelJustifyH(side, anchorPoint)
    if anchorPoint == "CENTER" then
        return "CENTER"
    end

    local isTop = type(anchorPoint) == "string" and string.sub(anchorPoint, 1, 3) == "TOP"
    local isBottom = type(anchorPoint) == "string" and string.sub(anchorPoint, 1, 6) == "BOTTOM"

    if side == "left" then
        if isTop then
            return "RIGHT"
        end
        if isBottom then
            return "LEFT"
        end
        return "LEFT"
    end

    if isTop then
        return "LEFT"
    end
    if isBottom then
        return "RIGHT"
    end
    return "RIGHT"
end

local function ToVerticalText(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    local chars = {}
    for ch in text:gmatch(".") do
        chars[#chars + 1] = ch
    end

    return table.concat(chars, "\n")
end

local function ApplyBarSettings()
    local ctx = ResolveContext()
    if not ctx then
        return
    end

    local UI = ctx.UI
    local settings = ctx.settings
    local defaults = ctx.defaults
    local constants = ctx.constants
    local fillInset = ctx.fillInset
    local maxTickMarks = ctx.maxTickMarks
    local clamp = ctx.clamp
    local round = ctx.round

    if not UI.barFrame then
        return
    end

    settings.point = settings.point or {}
    local point = settings.point
    local anchor = string.upper(tostring(point.anchor or defaults.point.anchor))
    local relativePoint = string.upper(tostring(point.relativePoint or defaults.point.relativePoint))
    local orientation = settings.orientation or constants.ORIENTATION_HORIZONTAL
    local frameScale = 1
    if orientation == constants.ORIENTATION_VERTICAL then
        frameScale = clamp(tonumber(settings.verticalScale) or defaults.verticalScale, 0.5, 2)
    else
        frameScale = clamp(tonumber(settings.scale) or defaults.scale, 0.5, 2)
    end

    local baseWidth = 1
    local baseHeight = 1
    if orientation == constants.ORIENTATION_VERTICAL then
        baseWidth = clamp(math.floor((tonumber(settings.verticalWidth) or defaults.verticalWidth) + 0.5), 10, 60)
        baseHeight = clamp(math.floor((tonumber(settings.verticalHeight) or defaults.verticalHeight) + 0.5), 100, 350)
        settings.verticalWidth = baseWidth
        settings.verticalHeight = baseHeight
    else
        baseWidth = clamp(math.floor((tonumber(settings.horizontalWidth) or defaults.horizontalWidth) + 0.5), 100, 350)
        baseHeight = clamp(math.floor((tonumber(settings.horizontalHeight) or defaults.horizontalHeight) + 0.5), 10, 60)
        settings.horizontalWidth = baseWidth
        settings.horizontalHeight = baseHeight
    end

    settings.width = baseWidth
    settings.height = baseHeight

    local scaledWidth = math.max(1, round(baseWidth * frameScale))
    local scaledHeight = math.max(1, round(baseHeight * frameScale))
    if anchor ~= "CENTER" then
        anchor = "CENTER"
    end

    if relativePoint ~= "CENTER" then
        relativePoint = "CENTER"
    end

    local barPositionUtil = ctx.barPositionUtil
    if point.x == nil or point.y == nil then
        point.x, point.y = barPositionUtil.GetDefaultPoint(scaledWidth, scaledHeight)
    end

    local clampedX, clampedY = barPositionUtil.ClampToScreen(point.x, point.y, scaledWidth, scaledHeight)
    point.anchor = anchor
    point.relativePoint = relativePoint

    if orientation == constants.ORIENTATION_VERTICAL then
        settings.verticalScale = frameScale
    else
        settings.scale = frameScale
    end

    UI.barFrame:SetSize(scaledWidth, scaledHeight)
    UI.barFrame:SetScale(1)
    UI.barFrame:SetFrameStrata("MEDIUM")
    UI.barFrame:SetFrameLevel(5)
    UI.barFrame:ClearAllPoints()
    UI.barFrame:SetPoint("CENTER", _G.UIParent, "CENTER", clampedX, clampedY)

    if UI.barFill then
        local fill = settings.fillColor
        UI.barFill:ClearAllPoints()
        UI.barFill:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, fillInset)
        UI.barFill:SetSize(0, math.max(1, scaledHeight - 2 * fillInset))
        UI.barFill:SetTexture(constants.TEXTURE_PRESETS[settings.textureKey] or constants.TEXTURE_PRESETS.default)
        UI.barFill:SetVertexColor(fill[1], fill[2], fill[3], fill[4])
        UI.barFill:SetDrawLayer("ARTWORK", 0)

        if UI.barBorder and UI.barBorder.SetBackdropBorderColor then
            if settings.borderColorLinked == false and settings.borderColor then
                local borderColor = settings.borderColor
                UI.barBorder:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 0.85)
            else
                UI.barBorder:SetBackdropBorderColor(fill[1], fill[2], fill[3], math.max(0.65, fill[4] or 0.85))
            end
        end
    end

    if UI.barSpark then
        local spark = settings.sparkColor or defaults.sparkColor
        UI.barSpark:SetColorTexture(spark[1], spark[2], spark[3], spark[4] or 0.9)
        if orientation == constants.ORIENTATION_VERTICAL then
            UI.barSpark:SetSize(math.max(1, scaledWidth - 2 * fillInset), 2)
        else
            UI.barSpark:SetSize(2, math.max(1, scaledHeight - 2 * fillInset))
        end
        UI.barSpark:SetDrawLayer("OVERLAY", 3)
        if not settings.showSparkLine then
            UI.barSpark:Hide()
        end
    end

    if UI.barFrame.BackgroundTexture then
        local bg = settings.bgColor
        UI.barFrame.BackgroundTexture:ClearAllPoints()
        UI.barFrame.BackgroundTexture:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, fillInset)
        UI.barFrame.BackgroundTexture:SetPoint("TOPRIGHT", UI.barFrame, "TOPRIGHT", -fillInset, -fillInset)
        UI.barFrame.BackgroundTexture:SetColorTexture(bg[1], bg[2], bg[3], bg[4])
    end

    local labelRow = settings.labelRowPosition or constants.LABEL_ROW_ABOVE
    local verticalTextSide = settings.verticalTextSide or "right"
    local verticalPercentSide = settings.verticalPercentSide or "center"
    local percentDisplayMode = settings.percentDisplay or constants.PERCENT_DISPLAY_INSIDE
    if orientation == constants.ORIENTATION_VERTICAL then
        percentDisplayMode = settings.verticalPercentDisplay or settings.percentDisplay or constants.PERCENT_DISPLAY_INSIDE
    end
    local verticalTextOffset = clamp(math.floor((tonumber(settings.verticalTextOffset) or 10) + 0.5), 2, 60)
    local verticalPercentOffset = clamp(math.floor((tonumber(settings.verticalPercentOffset) or 10) + 0.5), 2, 60)
    local verticalTextAlign = settings.verticalTextAlign or "separate"

    if UI.stageText then
        local _, _, flags = UI.stageText:GetFont()
        local titleFont = ResolveLocaleSafeFont(constants.FONT_PRESETS[settings.titleFontKey] or constants.FONT_PRESETS.frizqt)

        UI.stageText:SetFont(titleFont, math.max(8, round((tonumber(settings.fontSize) or defaults.fontSize) * frameScale)), flags)
        local titleColor = settings.titleColor or defaults.titleColor
        UI.stageText:SetTextColor(titleColor[1], titleColor[2], titleColor[3], titleColor[4] or 1)

        local labelMode = settings.stageLabelMode or constants.LABEL_MODE_CENTER
        UI.stageText:ClearAllPoints()
        if orientation == constants.ORIENTATION_VERTICAL then
            local anchorPoint
            local relativeAnchor
            local xOffset
            local yOffset
            if verticalTextAlign == "middle" then
                anchorPoint = "CENTER"
                relativeAnchor = (verticalTextSide == "left") and "LEFT" or "RIGHT"
                xOffset = (verticalTextSide == "left") and -(verticalTextOffset + fillInset) or (verticalTextOffset + fillInset)
                yOffset = -6
            elseif verticalTextAlign == "top" then
                local useSuffixBoundary = verticalTextSide == "left"
                anchorPoint, relativeAnchor, xOffset, yOffset = Preydator.ResolveVerticalTextAnchor(verticalTextSide, verticalTextAlign, verticalTextOffset, useSuffixBoundary)
            elseif verticalTextAlign == "bottom" then
                local useSuffixBoundary = verticalTextSide == "right"
                anchorPoint, relativeAnchor, xOffset, yOffset = Preydator.ResolveVerticalTextAnchor(verticalTextSide, verticalTextAlign, verticalTextOffset, useSuffixBoundary)
            else
                anchorPoint, relativeAnchor, xOffset, yOffset = Preydator.ResolveVerticalTextAnchor(verticalTextSide, verticalTextAlign, verticalTextOffset, false)
            end

            UI.stageText:SetPoint(anchorPoint, UI.barFrame, relativeAnchor, xOffset, yOffset)
            UI.stageText:SetJustifyH(ResolveVerticalLabelJustifyH(verticalTextSide, anchorPoint))
            UI.stageText:SetJustifyV("MIDDLE")
            ApplyVerticalLabelRotation(UI.stageText, true, verticalTextSide)
        elseif labelMode == constants.LABEL_MODE_LEFT
            or labelMode == constants.LABEL_MODE_LEFT_COMBINED
            or labelMode == constants.LABEL_MODE_LEFT_SUFFIX
            or labelMode == constants.LABEL_MODE_SEPARATE
        then
            if labelRow == constants.LABEL_ROW_BELOW then
                UI.stageText:SetPoint("TOPLEFT", UI.barFrame, "BOTTOMLEFT", 2, -4)
            else
                UI.stageText:SetPoint("BOTTOMLEFT", UI.barFrame, "TOPLEFT", 2, 4)
            end
            UI.stageText:SetJustifyH("LEFT")
            ApplyVerticalLabelRotation(UI.stageText, false, verticalTextSide)
        elseif labelMode == constants.LABEL_MODE_NONE then
            if labelRow == constants.LABEL_ROW_BELOW then
                UI.stageText:SetPoint("TOP", UI.barFrame, "BOTTOM", 0, -4)
            else
                UI.stageText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, 4)
            end
            ApplyVerticalLabelRotation(UI.stageText, false, verticalTextSide)
        else
            if labelRow == constants.LABEL_ROW_BELOW then
                UI.stageText:SetPoint("TOP", UI.barFrame, "BOTTOM", 0, -4)
            else
                UI.stageText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, 4)
            end
            UI.stageText:SetJustifyH("CENTER")
            ApplyVerticalLabelRotation(UI.stageText, false, verticalTextSide)
        end
    end

    if UI.stageSuffixText then
        local _, _, flags = UI.stageSuffixText:GetFont()
        local titleFont = ResolveLocaleSafeFont(constants.FONT_PRESETS[settings.titleFontKey] or constants.FONT_PRESETS.frizqt)
        UI.stageSuffixText:SetFont(titleFont, math.max(8, round((tonumber(settings.fontSize) or defaults.fontSize) * frameScale)), flags)
        local titleColor = settings.titleColor or defaults.titleColor
        UI.stageSuffixText:SetTextColor(titleColor[1], titleColor[2], titleColor[3], titleColor[4] or 1)
        UI.stageSuffixText:ClearAllPoints()
        if orientation == constants.ORIENTATION_VERTICAL then
            local anchorPoint, relativeAnchor, xOffset, yOffset = Preydator.ResolveVerticalTextAnchor(verticalTextSide, verticalTextAlign, verticalTextOffset, true)
            UI.stageSuffixText:SetPoint(anchorPoint, UI.barFrame, relativeAnchor, xOffset, yOffset)
            UI.stageSuffixText:SetJustifyH(ResolveVerticalLabelJustifyH(verticalTextSide, anchorPoint))
            UI.stageSuffixText:SetJustifyV("MIDDLE")
            ApplyVerticalLabelRotation(UI.stageSuffixText, true, verticalTextSide)
        else
            if labelRow == constants.LABEL_ROW_BELOW then
                UI.stageSuffixText:SetPoint("TOPRIGHT", UI.barFrame, "BOTTOMRIGHT", -2, -4)
            else
                UI.stageSuffixText:SetPoint("BOTTOMRIGHT", UI.barFrame, "TOPRIGHT", -2, 4)
            end
            UI.stageSuffixText:SetJustifyH("RIGHT")
            ApplyVerticalLabelRotation(UI.stageSuffixText, false, verticalTextSide)
        end
    end

    if UI.barText then
        local _, _, flags = UI.barText:GetFont()
        local percentFont = ResolveLocaleSafeFont(constants.FONT_PRESETS[settings.percentFontKey] or constants.FONT_PRESETS.frizqt)
        UI.barText:SetFont(percentFont, math.max(8, round(((tonumber(settings.fontSize) or defaults.fontSize) - 1) * frameScale)), flags)
        local percentColor = settings.percentColor or defaults.percentColor
        UI.barText:SetTextColor(percentColor[1], percentColor[2], percentColor[3], percentColor[4] or 1)
        local percentLayer, percentSubLevel = ctx.getPercentTextLayerSettings()
        UI.barText:SetDrawLayer(percentLayer, percentSubLevel)
    end

    local tickPercents = ctx.getProgressTickPercents()
    for index, tickLabel in ipairs(UI.barTickLabels) do
        local hasTick = tickPercents[index] ~= nil
        if tickLabel then
            local _, _, flags = tickLabel:GetFont()
            local percentFont = ResolveLocaleSafeFont(constants.FONT_PRESETS[settings.percentFontKey] or constants.FONT_PRESETS.frizqt)
            tickLabel:SetFont(percentFont, math.max(7, round(((tonumber(settings.fontSize) or defaults.fontSize) - 4) * frameScale)), flags)
            local percentColor = settings.percentColor or defaults.percentColor
            tickLabel:SetTextColor(percentColor[1], percentColor[2], percentColor[3], 0.9)
            if orientation ~= constants.ORIENTATION_VERTICAL then
                tickLabel:SetShown(hasTick and settings.showTicks and (
                    percentDisplayMode == constants.PERCENT_DISPLAY_UNDER_TICKS
                    or percentDisplayMode == constants.PERCENT_DISPLAY_ABOVE_TICKS
                ))
            end
        end

        local tickMark = UI.barTickMarks[index]
        if tickMark then
            local tickColor = settings.tickColor or defaults.tickColor
            tickMark:SetColorTexture(tickColor[1], tickColor[2], tickColor[3], tickColor[4] or 0.35)
            local tickLayer, tickSubLevel = ctx.getTickLayerSettings()
            tickMark:SetDrawLayer(tickLayer, tickSubLevel)
            tickMark:SetShown(hasTick and settings.showTicks)
        end
    end

    local barWidth = scaledWidth
    local barHeight = scaledHeight
    if UI.barAlignmentDot then
        UI.barAlignmentDot:ClearAllPoints()
        UI.barAlignmentDot:SetPoint("CENTER", UI.barFrame, "CENTER", 0, 0)
        UI.barAlignmentDot:Hide()
    end

    local innerTickWidth = math.max(0, barWidth - (2 * fillInset))
    local innerTickHeight = math.max(1, barHeight - (2 * fillInset))
    local tickWidth = 1
    for index = 1, maxTickMarks do
        local pct = tickPercents[index]
        local x
        local y
        if pct then
            local renderPct = (orientation == constants.ORIENTATION_VERTICAL)
                and Preydator.GetRenderedVerticalPercent(pct, settings.verticalFillDirection)
                or pct
            if orientation == constants.ORIENTATION_VERTICAL then
                y = fillInset + math.floor((innerTickHeight * (renderPct / 100)) + 0.5)
                y = math.floor((y / tickWidth) + 0.5) * tickWidth
            else
                x = fillInset + math.floor((innerTickWidth * (pct / 100)) + 0.5)
                x = math.floor((x / tickWidth) + 0.5) * tickWidth
            end
        end

        local tickMark = UI.barTickMarks[index]
        if tickMark then
            if pct then
                tickMark:ClearAllPoints()
                if orientation == constants.ORIENTATION_VERTICAL then
                    local renderPct = Preydator.GetRenderedVerticalPercent(pct, settings.verticalFillDirection)
                    if renderPct == 100 then
                        tickMark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, barHeight - fillInset - tickWidth)
                    else
                        tickMark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, y)
                    end
                    tickMark:SetSize(innerTickWidth, tickWidth)
                else
                    if pct == 100 then
                        tickMark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", barWidth - fillInset - tickWidth, fillInset)
                    else
                        tickMark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", x, fillInset)
                    end
                    tickMark:SetSize(tickWidth, innerTickHeight)
                end
            else
                tickMark:Hide()
            end
        end

        local tickLabel = UI.barTickLabels[index]
        if tickLabel then
            if pct then
                tickLabel:ClearAllPoints()
                if orientation == constants.ORIENTATION_VERTICAL then
                    local renderPct = Preydator.GetRenderedVerticalPercent(pct, settings.verticalFillDirection)
                    local percentEdgeOffset = verticalPercentOffset + fillInset
                    local showTickPct = settings.showVerticalTickPercent == true
                        and percentDisplayMode ~= constants.PERCENT_DISPLAY_OFF
                    if not showTickPct then
                        tickLabel:SetText("")
                        tickLabel:Hide()
                    elseif verticalPercentSide == "center" then
                        if settings.verticalFillDirection == constants.FILL_DIRECTION_DOWN then
                            tickLabel:SetPoint("BOTTOM", UI.barFrame, "BOTTOM", 0, (y or fillInset) + 2)
                        else
                            tickLabel:SetPoint("TOP", UI.barFrame, "BOTTOM", 0, (y or fillInset) - 2)
                        end
                    elseif renderPct == 100 then
                        if verticalPercentSide == "left" then
                            tickLabel:SetPoint("RIGHT", UI.barFrame, "BOTTOMLEFT", -percentEdgeOffset, barHeight - fillInset)
                        else
                            tickLabel:SetPoint("LEFT", UI.barFrame, "BOTTOMRIGHT", percentEdgeOffset, barHeight - fillInset)
                        end
                    else
                        if verticalPercentSide == "left" then
                            tickLabel:SetPoint("RIGHT", UI.barFrame, "BOTTOMLEFT", -percentEdgeOffset, y)
                        else
                            tickLabel:SetPoint("LEFT", UI.barFrame, "BOTTOMRIGHT", percentEdgeOffset, y)
                        end
                    end
                elseif percentDisplayMode == constants.PERCENT_DISPLAY_ABOVE_TICKS then
                    if pct == 0 then
                        tickLabel:SetPoint("BOTTOMLEFT", UI.barFrame, "TOPLEFT", 0, 1)
                    elseif pct == 100 then
                        tickLabel:SetPoint("BOTTOMRIGHT", UI.barFrame, "TOPRIGHT", 0, 1)
                    else
                        tickLabel:SetPoint("BOTTOM", UI.barFrame, "BOTTOMLEFT", x, barHeight + 1)
                    end
                elseif pct == 0 then
                    tickLabel:SetPoint("TOPLEFT", UI.barFrame, "BOTTOMLEFT", 0, -1)
                elseif pct == 100 then
                    tickLabel:SetPoint("TOPRIGHT", UI.barFrame, "BOTTOMRIGHT", 0, -1)
                else
                    tickLabel:SetPoint("TOP", UI.barFrame, "BOTTOMLEFT", x, -1)
                end
                tickLabel:SetText(tostring(pct))
                tickLabel:SetDrawLayer("OVERLAY", 7)
                if orientation == constants.ORIENTATION_VERTICAL then
                    local showTickPct = settings.showVerticalTickPercent == true
                        and percentDisplayMode ~= constants.PERCENT_DISPLAY_OFF
                    tickLabel:SetShown(showTickPct)
                else
                    tickLabel:SetShown(settings.showTicks and (
                        percentDisplayMode == constants.PERCENT_DISPLAY_UNDER_TICKS
                        or percentDisplayMode == constants.PERCENT_DISPLAY_ABOVE_TICKS
                    ))
                end
            else
                tickLabel:SetText("")
                tickLabel:Hide()
            end
        end
    end

    local verticalTicksReplacePercent = orientation == constants.ORIENTATION_VERTICAL
        and settings.showVerticalTickPercent == true
        and percentDisplayMode ~= constants.PERCENT_DISPLAY_OFF

    if UI.barText then
        if verticalTicksReplacePercent then
            UI.barText:Hide()
        elseif percentDisplayMode == constants.PERCENT_DISPLAY_OFF then
            UI.barText:Hide()
        elseif percentDisplayMode == constants.PERCENT_DISPLAY_ABOVE_BAR then
            UI.barText:Show()
            UI.barText:ClearAllPoints()
            if orientation == constants.ORIENTATION_VERTICAL then
                UI.barText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, math.max(2, verticalPercentOffset))
            else
                UI.barText:SetPoint("BOTTOM", UI.barFrame, "TOP", 0, 4)
            end
        elseif percentDisplayMode == constants.PERCENT_DISPLAY_ABOVE_TICKS then
            UI.barText:Hide()
        elseif percentDisplayMode == constants.PERCENT_DISPLAY_BELOW_BAR then
            UI.barText:Show()
            UI.barText:ClearAllPoints()
            if orientation == constants.ORIENTATION_VERTICAL then
                UI.barText:SetPoint("TOP", UI.barFrame, "BOTTOM", 0, -math.max(2, verticalPercentOffset))
            else
                UI.barText:SetPoint("TOP", UI.barFrame, "BOTTOM", 0, -14)
            end
        elseif percentDisplayMode == constants.PERCENT_DISPLAY_UNDER_TICKS then
            UI.barText:Hide()
        else
            UI.barText:Show()
            UI.barText:ClearAllPoints()
            if orientation == constants.ORIENTATION_VERTICAL then
                UI.barText:SetPoint("CENTER", UI.barFrame, "CENTER", 0, 0)
                UI.barText:SetDrawLayer("OVERLAY", 7)
            else
                UI.barText:SetPoint("center", UI.barFrame, "center", 0, 0)
            end
        end
    end

    UI.barFrame:SetMovable(true)
end

local function UpdateBarDisplay()
    local ctx = ResolveContext()
    if not ctx then
        return
    end

    local UI = ctx.UI
    local settings = ctx.settings
    local state = ctx.state
    local constants = ctx.constants
    local fillInset = ctx.fillInset
    local getTime = ctx.getTime

    local customizationV2 = ctx.getModule("CustomizationStateV2")
    local barEnabled = true
    if customizationV2 and type(customizationV2.IsModuleEnabled) == "function" then
        barEnabled = customizationV2:IsModuleEnabled("bar") == true
    end
    if not barEnabled then
        if UI.barFrame then
            UI.barFrame:Hide()
        end
        ctx.runModuleHook("OnAfterUpdateBarDisplay", {
            shouldShowBar = false,
            forceAmbushAlert = false,
            forceKillStage = false,
            hasActiveQuest = false,
            displayPercent = 0,
            stage = state.stage,
        })
        return
    end

    ctx.ensureBar()
    ctx.applyDefaultPreyIconVisibility()

    local now = getTime()
    local hasActiveQuest = state.activeQuestID ~= nil
    local forceKillStage = now < (state.killStageUntil or 0)
    local forceAmbushAlert = now < (state.ambushAlertUntil or 0)
    local forceBloodyCommandAlert = now < (state.bloodyCommandAlertUntil or 0)
    -- Treat only explicit false as out-of-zone. Nil means unknown/not yet resolved,
    -- and should not hard-hide or zero-out active hunt display.
    local isOutOfPreyZone = hasActiveQuest and state.inPreyZone == false
    local onlyShowInPreyZone = settings.onlyShowInPreyZone == true
    local preyWidgetVisible = type(ctx.isAnyTrackedPreyWidgetShown) == "function"
        and ctx.isAnyTrackedPreyWidgetShown() == true
    local hasResolvedPreyZoneEvidence = state.preyZoneMapID ~= nil or state.confirmedPreyZoneMapID ~= nil
    local hasCertifiedWidgetZoneSignal = state.inPreyZone == nil
        and preyWidgetVisible
        and hasResolvedPreyZoneEvidence
    local inStageFourInZone = (state.stage == constants.MAX_STAGE)
        and (state.inPreyZone == true or hasCertifiedWidgetZoneSignal)
    local function IsEditModePreviewEnabled()
        if settings.showInEditMode ~= true then
            return false
        end

        local active = ctx.isEditModePreviewActive and ctx.isEditModePreviewActive()
        return active and true or false
    end

    local editModePreview = IsEditModePreviewEnabled()
    local isRestrictedInstance = (ctx.isRestrictedInstanceForPreyBar() == true)
    local shouldShow = false

    if isRestrictedInstance and not editModePreview then
        shouldShow = false
    elseif state.forceShowBar or forceKillStage or forceAmbushAlert or forceBloodyCommandAlert or editModePreview then
        shouldShow = true
    elseif onlyShowInPreyZone then
        local inZoneSignal = state.inPreyZone == true or hasCertifiedWidgetZoneSignal
        shouldShow = (hasActiveQuest and inZoneSignal) or inStageFourInZone
    else
        shouldShow = true
    end

    if not shouldShow then
        UI.barFrame:Hide()
        ctx.runModuleHook("OnAfterUpdateBarDisplay", {
            shouldShowBar = false,
            forceAmbushAlert = forceAmbushAlert,
            forceBloodyCommandAlert = forceBloodyCommandAlert,
            forceKillStage = forceKillStage,
            hasActiveQuest = hasActiveQuest,
            displayPercent = 0,
            stage = state.stage,
        })
        return
    end

    UI.barFrame:Show()

    local stage = forceKillStage and constants.MAX_STAGE or ctx.getStageFromState(state.progressState)
    local pct = 0.0
    local displayReason = "default"
    if forceKillStage then
        pct = 100
        displayReason = "killStage"
    elseif not hasActiveQuest then
        pct = 0
        if editModePreview then
            displayReason = "editModePreview"
        else
            displayReason = "noActiveQuest"
        end
    elseif isOutOfPreyZone then
        pct = 0
        displayReason = "outOfPreyZone"
    else
        if stage == constants.MAX_STAGE then
            pct = 100
            if state.lastPercentSource == "none" then
                state.lastPercentSource = "final"
            end
        else
            pct = state.progressPercent
            local stageCeiling = tonumber(ctx.getStageFallbackPercent(stage)) or 0
            if pct ~= nil and stage >= 1 and stageCeiling > 0 then
                pct = math.min(pct, stageCeiling)
            end
            local shouldUseStageFallback = (pct == nil) or (stage >= 1 and pct <= 0)

            if shouldUseStageFallback then
                pct = ctx.getStageFallbackPercent(stage)
                if state.lastPercentSource == "none" then
                    state.lastPercentSource = "stage"
                end
            end
        end
        displayReason = "activeQuest"
    end

    local label = ctx.getStageLabel(stage)
    local barWidth = (UI.barFrame and UI.barFrame.GetWidth and UI.barFrame:GetWidth()) or settings.width
    local barHeight = (UI.barFrame and UI.barFrame.GetHeight and UI.barFrame:GetHeight()) or settings.height
    local innerFillWidth = math.max(0, barWidth - 2 * fillInset)
    local innerFillHeight = math.max(0, barHeight - 2 * fillInset)
    local isVertical = settings.orientation == constants.ORIENTATION_VERTICAL

    if UI.barFill then
        local width = innerFillWidth * (pct / 100)
        local height = innerFillHeight * (pct / 100)
        local shouldHideFill = (pct <= 0) or (not hasActiveQuest and not forceKillStage and not forceAmbushAlert and not forceBloodyCommandAlert)
        if shouldHideFill then
            UI.barFill:SetWidth(0)
            UI.barFill:SetHeight(0)
            UI.barFill:Hide()
            if UI.barSpark then
                UI.barSpark:Hide()
            end
        else
            UI.barFill:ClearAllPoints()
            if isVertical then
                UI.barFill:SetWidth(innerFillWidth)
                UI.barFill:SetHeight(math.max(1, height))
                if settings.verticalFillDirection == constants.FILL_DIRECTION_DOWN then
                    UI.barFill:SetPoint("TOPLEFT", UI.barFrame, "TOPLEFT", fillInset, -fillInset)
                else
                    UI.barFill:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, fillInset)
                end
            else
                UI.barFill:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, fillInset)
                UI.barFill:SetWidth(math.max(1, width))
                UI.barFill:SetHeight(innerFillHeight)
            end
            UI.barFill:Show()
            if UI.barSpark and settings.showSparkLine then
                local sparkWidth = 2
                UI.barSpark:ClearAllPoints()
                if isVertical then
                    local sparkY
                    if settings.verticalFillDirection == constants.FILL_DIRECTION_DOWN then
                        sparkY = barHeight - fillInset - math.max(1, height)
                    else
                        sparkY = fillInset + math.max(0, height - sparkWidth)
                    end
                    if pct >= 100 and settings.verticalFillDirection == constants.FILL_DIRECTION_DOWN then
                        sparkY = fillInset
                    elseif pct >= 100 then
                        sparkY = barHeight - fillInset - sparkWidth
                    end
                    UI.barSpark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", fillInset, sparkY)
                else
                    local sparkX = fillInset + math.max(0, width - sparkWidth)
                    if pct >= 100 then
                        sparkX = barWidth - fillInset - sparkWidth
                    end
                    UI.barSpark:SetPoint("BOTTOMLEFT", UI.barFrame, "BOTTOMLEFT", sparkX, fillInset)
                end
                UI.barSpark:Show()
            elseif UI.barSpark then
                UI.barSpark:Hide()
            end
        end
    end

    state.lastDisplayPct = pct
    state.lastDisplayReason = displayReason

    state.stage = stage

    local allowBarDrag = settings and not settings.locked
    local allowEditModeClickOpen = ctx.isEditModePreviewActive()
    local allowStageFourMapClickFallback = settings
        and settings.disableDefaultPreyIcon == true
        and stage == constants.MAX_STAGE
    if UI.barFrame and UI.barFrame.EnableMouse then
        UI.barFrame:EnableMouse((allowBarDrag and true or false) or (allowStageFourMapClickFallback and true or false) or (allowEditModeClickOpen and true or false))
    end

    local prefixText = ""
    local suffixText = ""
    if forceBloodyCommandAlert then
        prefixText = (settings and settings.bloodyCommandPrefix) or ""
        local suffixSetting = (settings and settings.bloodyCommandSuffix) or "bloodyCommandSourceName"

        -- If suffix exactly matches the variable name, use dynamic value.
        if suffixSetting == "bloodyCommandSourceName" then
            if type(state.bloodyCommandSourceName) == "string" and state.bloodyCommandSourceName ~= "" then
                suffixText = state.bloodyCommandSourceName
            else
                suffixText = "bloodyCommandSourceName"
            end
        -- Otherwise use as literal text.
        elseif type(suffixSetting) == "string" and suffixSetting ~= "" then
            suffixText = tostring(suffixSetting)
        else
            suffixText = ""
        end

        if prefixText == "" and suffixText == "" then
            suffixText = label
        end
    elseif forceAmbushAlert then
        prefixText = (settings and settings.ambushPrefix) or ""
        local suffixSetting = (settings and settings.ambushSuffix) or "preyTargetName"

        -- If suffix exactly matches the variable name, use dynamic value.
        if suffixSetting == "preyTargetName" then
            if type(state.preyTargetName) == "string" and state.preyTargetName ~= "" then
                suffixText = state.preyTargetName
            elseif type(state.ambushSourceName) == "string" and state.ambushSourceName ~= "" then
                suffixText = state.ambushSourceName
            else
                suffixText = "preyTargetName"
            end
        -- Otherwise use as literal text.
        elseif type(suffixSetting) == "string" and suffixSetting ~= "" then
            suffixText = tostring(suffixSetting)
        else
            suffixText = ""
        end

        if prefixText == "" and suffixText == "" then
            suffixText = label
        end
    elseif isOutOfPreyZone and not forceKillStage then
        prefixText = (settings and settings.outOfZonePrefix) or ""
        suffixText = settings.outOfZoneLabel or constants.DEFAULT_OUT_OF_ZONE_LABEL
    elseif not hasActiveQuest and not forceKillStage then
        if editModePreview then
            suffixText = "Preydator (Edit Mode Preview)"
        else
            local zoneName = (_G.GetZoneText and _G.GetZoneText()) or "Unknown Zone"
            suffixText = tostring(zoneName)
        end
    else
        prefixText = (settings.stageSuffixLabels and settings.stageSuffixLabels[stage]) or ""
        suffixText = label
    end

    local verticalAlignMode = nil
    local verticalTextSide = settings.verticalTextSide or "right"
    if isVertical then
        verticalAlignMode = settings.verticalTextAlign or "separate"
        if verticalAlignMode == "top_suffix_only" or verticalAlignMode == "bottom_suffix_only" then
            prefixText = ""
        elseif verticalAlignMode == "top_prefix_only" or verticalAlignMode == "bottom_prefix_only" then
            suffixText = ""
        end
    end

    local centeredText = suffixText
    if prefixText ~= "" and suffixText ~= "" then
        centeredText = prefixText .. " " .. suffixText
    elseif prefixText ~= "" then
        centeredText = prefixText
    end

    local labelMode = settings.stageLabelMode or constants.LABEL_MODE_CENTER
    if settings.orientation == constants.ORIENTATION_VERTICAL then
        labelMode = constants.LABEL_MODE_SEPARATE
    end

    local function LabelOut(text)
        if settings.orientation == constants.ORIENTATION_VERTICAL and not (UI.stageText and UI.stageText.SetRotation) then
            return ToVerticalText(text)
        end
        return text
    end

    if labelMode == constants.LABEL_MODE_NONE then
        UI.stageText:SetText("")
        UI.stageText:Hide()
        if UI.stageSuffixText then
            UI.stageSuffixText:SetText("")
            UI.stageSuffixText:Hide()
        end
    elseif labelMode == constants.LABEL_MODE_SEPARATE then
        local boundaryVerticalMode = isVertical
            and (verticalTextSide == "left" or verticalTextSide == "right")
            and (verticalAlignMode == "top" or verticalAlignMode == "middle" or verticalAlignMode == "bottom")
        local boundaryVerticalText = nil
        if boundaryVerticalMode then
            if prefixText ~= "" and suffixText ~= "" then
                boundaryVerticalText = centeredText
            elseif prefixText ~= "" then
                boundaryVerticalText = prefixText
            elseif suffixText ~= "" then
                boundaryVerticalText = suffixText
            end
        end

        if boundaryVerticalMode then
            if boundaryVerticalText ~= nil and boundaryVerticalText ~= "" then
                UI.stageText:SetText(LabelOut(boundaryVerticalText))
                UI.stageText:Show()
            else
                UI.stageText:SetText("")
                UI.stageText:Hide()
            end
            if UI.stageSuffixText then
                UI.stageSuffixText:SetText("")
                UI.stageSuffixText:Hide()
            end
        else
            if prefixText ~= "" then
                UI.stageText:SetText(LabelOut(prefixText))
                UI.stageText:Show()
            else
                UI.stageText:SetText("")
                UI.stageText:Hide()
            end
            if UI.stageSuffixText then
                if suffixText ~= "" then
                    UI.stageSuffixText:SetText(LabelOut(suffixText))
                    UI.stageSuffixText:Show()
                else
                    UI.stageSuffixText:SetText("")
                    UI.stageSuffixText:Hide()
                end
            end
        end
    elseif labelMode == constants.LABEL_MODE_LEFT then
        if prefixText ~= "" then
            UI.stageText:SetText(LabelOut(prefixText))
            UI.stageText:Show()
        else
            UI.stageText:SetText("")
            UI.stageText:Hide()
        end
        if UI.stageSuffixText then
            UI.stageSuffixText:SetText("")
            UI.stageSuffixText:Hide()
        end
    elseif labelMode == constants.LABEL_MODE_LEFT_COMBINED then
        if centeredText ~= "" then
            UI.stageText:SetText(LabelOut(centeredText))
            UI.stageText:Show()
        else
            UI.stageText:SetText("")
            UI.stageText:Hide()
        end
        if UI.stageSuffixText then
            UI.stageSuffixText:SetText("")
            UI.stageSuffixText:Hide()
        end
    elseif labelMode == constants.LABEL_MODE_LEFT_SUFFIX then
        if suffixText ~= "" then
            UI.stageText:SetText(LabelOut(suffixText))
            UI.stageText:Show()
        else
            UI.stageText:SetText("")
            UI.stageText:Hide()
        end
        if UI.stageSuffixText then
            UI.stageSuffixText:SetText("")
            UI.stageSuffixText:Hide()
        end
    elseif labelMode == constants.LABEL_MODE_RIGHT then
        UI.stageText:SetText("")
        UI.stageText:Hide()
        if UI.stageSuffixText then
            if suffixText ~= "" then
                UI.stageSuffixText:SetText(LabelOut(suffixText))
                UI.stageSuffixText:Show()
            else
                UI.stageSuffixText:SetText("")
                UI.stageSuffixText:Hide()
            end
        end
    elseif labelMode == constants.LABEL_MODE_RIGHT_COMBINED then
        UI.stageText:SetText("")
        UI.stageText:Hide()
        if UI.stageSuffixText then
            if centeredText ~= "" then
                UI.stageSuffixText:SetText(LabelOut(centeredText))
                UI.stageSuffixText:Show()
            else
                UI.stageSuffixText:SetText("")
                UI.stageSuffixText:Hide()
            end
        end
    elseif labelMode == constants.LABEL_MODE_RIGHT_PREFIX then
        UI.stageText:SetText("")
        UI.stageText:Hide()
        if UI.stageSuffixText then
            if prefixText ~= "" then
                UI.stageSuffixText:SetText(LabelOut(prefixText))
                UI.stageSuffixText:Show()
            else
                UI.stageSuffixText:SetText("")
                UI.stageSuffixText:Hide()
            end
        end
    else
        if centeredText ~= "" then
            UI.stageText:SetText(LabelOut(centeredText))
            UI.stageText:Show()
        else
            UI.stageText:SetText("")
            UI.stageText:Hide()
        end
        if UI.stageSuffixText then
            UI.stageSuffixText:SetText("")
            UI.stageSuffixText:Hide()
        end
    end

    UI.barText:SetText(string.format("%d%%", pct))

    ctx.runModuleHook("OnAfterUpdateBarDisplay", {
        shouldShowBar = true,
        forceAmbushAlert = forceAmbushAlert,
        forceBloodyCommandAlert = forceBloodyCommandAlert,
        forceKillStage = forceKillStage,
        hasActiveQuest = hasActiveQuest,
        displayPercent = pct,
        stage = stage,
    })
end

api.SetBarRuntimeHandlers({
    ApplyBarSettings = ApplyBarSettings,
    UpdateBarDisplay = UpdateBarDisplay,
})
