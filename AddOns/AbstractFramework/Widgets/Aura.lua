---@class AbstractFramework
local AF = _G.AbstractFramework
local LCG = AF.Libs.LCG

---------------------------------------------------------------------
-- recalc texcoords
---------------------------------------------------------------------
---@param aura AF_AuraButton
---@param width number
---@param height number
function AF.ReCalcTexCoordForAura(aura, width, height)
    aura.icon:SetTexCoord(AF.Unpack8(AF.CalcTexCoordPreCrop(0.12, width / height)))
end

---------------------------------------------------------------------
-- SetCooldown
---------------------------------------------------------------------
local GetTime = GetTime

local function UpdateDurationText(aura)
    if aura._remain > 86400 then
        aura.duration:SetFormattedText("%dd", aura._remain / 86400)
    elseif aura._remain > 3600 then
        aura.duration:SetFormattedText("%dh", aura._remain / 3600)
    elseif aura._remain > 60 then
        aura.duration:SetFormattedText("%dm", aura._remain / 60)
    elseif aura._remain < 5 then
        aura.duration:SetFormattedText("%.1f%s", aura._remain, aura.showSecondsUnit and "s" or "")
    else
        aura.duration:SetFormattedText("%d%s", aura._remain, aura.showSecondsUnit and "s" or "")
    end
end

local function UpdateDuration_ColorByPercentSeconds(aura, elapsed)
    if aura._elapsed >= 0.1 then
        aura._remain = aura._duration - (GetTime() - aura._start)
        if aura._remain < 0 then aura._remain = 0 end

        -- color = {
        --     normal = AF.GetColorTable("white"), -- normal
        --     percent = {enabled = false, value = 0.5, rgb = AF.GetColorTable("aura_percent")}, -- less than 50%
        --     seconds = {enabled = true, value = 5, rgb = AF.GetColorTable("aura_seconds")}, -- less than 5sec
        -- }

        if aura.durationColor.seconds.enabled and aura._remain < aura.durationColor.seconds.value then
            aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor.seconds.rgb))
        elseif aura.durationColor.percent.enabled and aura._remain < (aura.durationColor.percent.value * aura._duration) then
            aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor.percent.rgb))
        else
            aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor.normal))
        end

        UpdateDurationText(aura)
        aura._elapsed = 0
    else
        aura._elapsed = aura._elapsed + elapsed
    end
end

-- local function UpdateDuration_ColorByExpiring(aura, elapsed)
--     if aura._elapsed >= 0.1 then
--         aura._remain = aura._duration - (GetTime() - aura._start)
--         if aura._remain < 0 then aura._remain = 0 end

--         -- color = {
--         --     AF.GetColorTable("white"), -- normal
--         --     AF.GetColorTable("aura_seconds"), -- expiring
--         -- },
--         if aura._remain < 5 then
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[2]))
--         else
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[1]))
--         end

--         UpdateDurationText(aura)
--         aura._elapsed = 0
--     else
--         aura._elapsed = aura._elapsed + elapsed
--     end
-- end

-- local function UpdateDuration_ColorByUnit(aura, elapsed)
--     if aura._elapsed >= 0.1 then
--         aura._remain = aura._duration - (GetTime() - aura._start)
--         if aura._remain < 0 then aura._remain = 0 end

--         -- color
--         if aura.durationColor[6][1] and aura._remain < 5 then
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[6][2]))
--         elseif aura.durationColor[5][1] and aura._remain < 60 then -- second
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[5][2]))
--         elseif aura.durationColor[4][1] and aura._remain < 3600 then -- minute
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[4][2]))
--         elseif aura.durationColor[3][1] and aura._remain < 86400 then -- hour
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[3][2]))
--         elseif aura.durationColor[2][1] and aura._remain < 86400 then -- hour
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[2][2]))
--         else -- day
--             aura.duration:SetTextColor(AF.UnpackColor(aura.durationColor[1]))
--         end

--         UpdateDurationText(aura)
--         aura._elapsed = 0
--     else
--         aura._elapsed = aura._elapsed + elapsed
--     end
-- end

-- local function UpdateDuration_NoColor(aura, elapsed)
--     if aura._elapsed >= 0.1 then
--         aura._remain = aura._duration - (GetTime() - aura._start)
--         if aura._remain < 0 then aura._remain = 0 end

--         UpdateDurationText(aura)
--         aura._elapsed = 0
--     else
--         aura._elapsed = aura._elapsed + elapsed
--     end
-- end

---@param aura AF_AuraButton
---@param start number
---@param duration number
---@param count number
---@param icon number
---@param auraType string
---@param desaturated boolean
---@param glow boolean
---@param r number backdrop color
---@param g number backdrop color
---@param b number backdrop color
---@param a number backdrop color
function AF.SetAuraCooldown(aura, start, duration, count, icon, auraType, desaturated, glow, r, g, b, a)
    if duration == 0 then
        if aura.cooldown then aura.cooldown:Hide() end
        aura.duration:SetText("")
        aura.stack:SetParent(aura)
        aura:SetScript("OnUpdate", nil)
        aura._start = nil
        aura._duration = nil
        aura._remain = nil
        aura._elapsed = nil
    else
        if aura.cooldown then
            -- NOTE: the "nil" is to make it compatible with Cooldown:SetCooldown(start, duration [, modRate])
            aura.cooldown:ShowCooldown(start, duration, nil, icon, auraType)
            aura.duration:SetParent(aura.cooldown)
            aura.stack:SetParent(aura.cooldown)
        else
            aura.duration:SetParent(aura)
            aura.stack:SetParent(aura)
        end
        aura._start = start
        aura._duration = duration
        aura._elapsed = 0.1
        aura:SetScript("OnUpdate", aura.UpdateDuration)
    end

    -- TODO: change to glowType string
    if glow then
        LCG.ButtonGlow_Start(aura, nil, nil, 0)
        AF.ShowCalloutGlow(aura, true)
    else
        AF.HideCalloutGlow(aura)
        LCG.ButtonGlow_Stop(aura)
    end

    if r then
        aura:SetBackdropColor(r, g, b, a)
    else
        aura:SetBackdropColor(0, 0, 0, 1)
    end

    aura:SetDesaturated(desaturated)
    aura:SetBackdropBorderColor(AF.GetAuraTypeColor(auraType))
    aura.stack:SetText((count == 0 or count == 1) and "" or count)
    aura.icon:SetTexture(icon)

    if not aura:IsProtected() then
        aura:Show()
    end
end

---------------------------------------------------------------------
-- SetAuraDesaturated
---------------------------------------------------------------------
function AF.SetAuraDesaturated(aura, desaturated)
    aura.icon:SetDesaturated(desaturated)
end

---------------------------------------------------------------------
-- SetupAuraStackText
---------------------------------------------------------------------
function AF.SetupAuraStackText(aura, config)
    aura.stack:SetShown(config.enabled)
    AF.LoadWidgetPosition(aura.stack, config.position, aura)
    AF.SetFont(aura.stack, unpack(config.font))
    aura.stack:SetTextColor(unpack(config.color))
end

---------------------------------------------------------------------
-- SetupAuraDurationText
---------------------------------------------------------------------
function AF.SetupAuraDurationText(aura, config)
    aura.duration:SetShown(config.enabled)
    AF.LoadWidgetPosition(aura.duration, config.position, aura)
    AF.SetFont(aura.duration, unpack(config.font))

    aura.showSecondsUnit = config.showSecondsUnit
    aura.durationColor = config.color

    if config.enabled then
        aura.UpdateDuration = UpdateDuration_ColorByPercentSeconds
    else
        aura.UpdateDuration = AF.noop
    end
end

---------------------------------------------------------------------
-- AF_AuraButtonMixin
---------------------------------------------------------------------
---@class AF_AuraButton:Frame
local AF_AuraButtonMixin = {}


---------------------------------------------------------------------
-- cooldown style: vertical progress
---------------------------------------------------------------------
local function VerticalCooldown_OnUpdate(cooldown, elapsed)
    cooldown.elapsed = cooldown.elapsed + elapsed
    if cooldown.elapsed >= 0.1 then
        cooldown:SetValue(cooldown:GetValue() + cooldown.elapsed)
        cooldown.elapsed = 0
    end
end

-- for LCG.ButtonGlow_Start
local function VerticalCooldown_GetCooldownDuration()
    return 0
end

local function VerticalCooldown_ShowCooldown(cooldown, start, duration, _, icon, auraType)
    if auraType then
        cooldown.spark:SetColorTexture(AF.GetAuraTypeColor(auraType))
    else
        cooldown.spark:SetColorTexture(0.5, 0.5, 0.5, 1)
    end
    if cooldown.icon then
        cooldown.icon:SetTexture(icon)
    end

    cooldown.elapsed = 0.1 -- update immediately
    cooldown:SetMinMaxValues(0, duration)
    cooldown:SetValue(GetTime() - start)
    cooldown:Show()
end

local function CreateCooldown_Vertical(aura, hasIcon)
    local cooldown = CreateFrame("StatusBar", nil, aura)
    aura.cooldown = cooldown
    cooldown:Hide()

    cooldown.GetCooldownDuration = VerticalCooldown_GetCooldownDuration
    cooldown.ShowCooldown = VerticalCooldown_ShowCooldown
    cooldown:SetScript("OnUpdate", VerticalCooldown_OnUpdate)

    AF.SetPoint(cooldown, "TOPLEFT", aura.icon)
    AF.SetPoint(cooldown, "BOTTOMRIGHT", aura.icon, "BOTTOMRIGHT", 0, 1)
    cooldown:SetOrientation("VERTICAL")
    cooldown:SetReverseFill(true)
    cooldown:SetStatusBarTexture(AF.GetPlainTexture())

    local texture = cooldown:GetStatusBarTexture()

    local spark = cooldown:CreateTexture(nil, "BORDER")
    cooldown.spark = spark
    AF.SetHeight(spark, 1)
    spark:SetBlendMode("ADD")
    spark:SetPoint("TOPLEFT", texture, "BOTTOMLEFT")
    spark:SetPoint("TOPRIGHT", texture, "BOTTOMRIGHT")

    if hasIcon then
        texture:SetAlpha(0)

        local mask = cooldown:CreateMaskTexture()
        mask:SetTexture(AF.GetPlainTexture(), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
        mask:SetPoint("TOPLEFT")
        mask:SetPoint("BOTTOMRIGHT", texture)

        local icon = cooldown:CreateTexture(nil, "ARTWORK")
        cooldown.icon = icon
        -- icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
        icon:SetDesaturated(true)
        icon:SetAllPoints(aura.icon)
        icon:SetVertexColor(0.5, 0.5, 0.5, 1)
        icon:AddMaskTexture(mask)
        cooldown:SetScript("OnSizeChanged", AF.ReCalcTexCoordForAura)
    else
        texture:SetVertexColor(0, 0, 0, 0.8)
    end
end


---------------------------------------------------------------------
-- cooldown style: clock (w/ or w/o leading edge)
---------------------------------------------------------------------
local function CreateCooldown_Clock(aura, drawEdge)
    local cooldown = CreateFrame("Cooldown", nil, aura, "AFCooldownFrameTemplate")
    aura.cooldown = cooldown
    cooldown:Hide()

    cooldown:SetAllPoints(aura.icon)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(drawEdge)

    -- NOTE: shit, why this EDGE not work, but xml does?
    -- cooldown:SetSwipeTexture(AF.GetPlainTexture())
    -- cooldown:SetSwipeColor(0, 0, 0, 0.8)
    -- cooldown:SetEdgeTexture([[Interface\Cooldown\UI-HUD-ActionBar-SecondaryCooldown]], 1, 1, 0, 1)

    -- cooldown text
    cooldown:SetHideCountdownNumbers(true)
    -- disable omnicc
    cooldown.noCooldownCount = true
    -- prevent some dirty addons from adding cooldown text
    cooldown.ShowCooldown = cooldown.SetCooldown
    cooldown.SetCooldown = nil
end


---------------------------------------------------------------------
-- cooldown
---------------------------------------------------------------------
---@param style string vertical, block_vertical, clock(_with_leading_edge), block_clock(_with_leading_edge)
function AF_AuraButtonMixin:SetCooldownStyle(style)
    if self.style == style then return end

    if self.cooldown then
        -- self.cooldown:SetParent(nil)
        self.cooldown:Hide()
        self.cooldown = nil
    end

    self.style = style
    if style == "vertical" then
        CreateCooldown_Vertical(self, true)
    elseif style == "block_vertical" then
        CreateCooldown_Vertical(self, false)
    elseif strfind(style, "^clock") or strfind(style, "^block_clock") then
        -- clock, clock_with_leading_edge
        -- block_clock, block_clock_with_leading_edge
        CreateCooldown_Clock(self, strfind(style, "edge$") and true or false)
    end

    if strfind(style, "^block") then
        self.icon:Hide()
    else
        self.icon:Show()
    end
end

---@param start number
---@param duration number
---@param count number
---@param icon number
---@param auraType string
---@param desaturated boolean
---@param glow boolean
---@param r number backdrop color
---@param g number backdrop color
---@param b number backdrop color
---@param a number backdrop color
function AF_AuraButtonMixin:SetCooldown(start, duration, count, icon, auraType, desaturated, glow, r, g, b, a)
    AF.SetAuraCooldown(self, start, duration, count, icon, auraType, desaturated, glow, r, g, b, a)
end

---------------------------------------------------------------------
-- tooltip
---------------------------------------------------------------------
local function Aura_SetTooltipPosition(aura)
    if aura.tooltip.anchorTo == "self" then
        GameTooltip:SetOwner(aura, "ANCHOR_NONE")
        GameTooltip:SetPoint(aura.tooltip.position[1], aura, aura.tooltip.position[2], aura.tooltip.position[3], aura.tooltip.position[4])
    else -- default
        GameTooltip_SetDefaultAnchor(GameTooltip, aura)
    end
end

local function Aura_ShowBuffTooltip(aura)
    Aura_SetTooltipPosition(aura)
    GameTooltip:SetUnitBuffByAuraInstanceID(aura.root.unit, aura.auraInstanceID)
end

local function Aura_ShowDebuffTooltip(aura)
    Aura_SetTooltipPosition(aura)
    GameTooltip:SetUnitDebuffByAuraInstanceID(aura.root.unit, aura.auraInstanceID)
end

local function Aura_HideTooltips()
    GameTooltip:Hide()
end

---@param config table {enabled = boolean, anchorTo = string, position = {string, string, number, number}}
---@param isHelpful boolean
function AF_AuraButtonMixin:EnableTooltip(config, isHelpful)
    if config.enabled then
        self.tooltip = config
        self:SetScript("OnEnter", isHelpful and Aura_ShowBuffTooltip or Aura_ShowDebuffTooltip)
        self:SetScript("OnLeave", Aura_HideTooltips)
    else
        self.tooltip = nil
        self:SetScript("OnEnter", nil)
        self:SetScript("OnLeave", nil)
        self:EnableMouse(false)
    end
end

---------------------------------------------------------------------
-- desaturated
---------------------------------------------------------------------
---@param desaturated boolean
function AF_AuraButtonMixin:SetDesaturated(desaturated)
    AF.SetAuraDesaturated(self, desaturated)
end

---------------------------------------------------------------------
-- stack
---------------------------------------------------------------------
---@param config table
function AF_AuraButtonMixin:SetupStackText(config)
    AF.SetupAuraStackText(self, config)
end

---------------------------------------------------------------------
-- duration
---------------------------------------------------------------------
---@param config table
function AF_AuraButtonMixin:SetupDurationText(config)
    AF.SetupAuraDurationText(self, config)
end

---------------------------------------------------------------------
-- pixels
---------------------------------------------------------------------
function AF_AuraButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.icon)
    if self.cooldown then
        AF.RePoint(self.cooldown)
    end
end

---------------------------------------------------------------------
-- OnHide
---------------------------------------------------------------------
local function Aura_OnHide(aura)
    LCG.ButtonGlow_Stop(aura)
    AF.HideCalloutGlow(aura)
end

---------------------------------------------------------------------
-- create aura
---------------------------------------------------------------------
---@param parent Frame
---@param noPixelUpdates boolean
---@return AF_AuraButton aura
function AF.CreateAura(parent, noPixelUpdates)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:Hide()

    Mixin(frame, AF_AuraButtonMixin)

    AF.ApplyDefaultBackdrop(frame)
    frame:SetBackdropColor(AF.GetColorRGB("black"))

    frame:SetScript("OnHide", Aura_OnHide)

    -- icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon = icon
    AF.SetOnePixelInside(icon, frame)
    -- icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
    frame:SetScript("OnSizeChanged", AF.ReCalcTexCoordForAura)

    -- texts
    frame.stack = frame:CreateFontString(nil, "OVERLAY")
    frame.duration = frame:CreateFontString(nil, "OVERLAY")

    -- pixels
    if not noPixelUpdates then
        AF.AddToPixelUpdater_Auto(frame)
    end

    return frame
end