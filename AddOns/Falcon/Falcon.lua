local addonName = ... ---@type string 'Falcon'
local ns = select(2,...) ---@class (partial) namespace
---@class Falcon : Frame
---@field Center table
---@field Label table
---@field Selection table
---@field shadow Texture
---@field positionTicker TickerCallback
local Falcon = CreateFrame('Frame', 'FalconAddOnFrame', UIParent)
ns.Falcon = Falcon
local API = ns.API
local LEM = ns.LibEditMode
ns.LEM = LEM
local F = ns.Flags
local abs, min, pow, exp, floor, ceil = math.abs, math.min, math.pow, math.exp, math.floor, math.ceil

---@class FalconDatabase
---@field Settings table<string, defaultTableData>
---@field FalconGlobalSettingsEnabled boolean
FalconAddOnDB = FalconAddOnDB or {}

---@class FalconConfiguration
local Configuration = {
  updateSpeedRate = 0.0167,
  updateRate = 0.0167,
  depletionSpeed = 20,
}

---@class MutableUIStates
local MutableUIStates = {
  Width = 0.0,
  SpeedHeight = 0.0,
  ChargeHeight = 0.0,
  Padding = 0.0,
  SwapPosition = false,
  BarBehaviourFlags = 0,
}

ns.Configuration = Configuration

---@class MutableData
local MutableData = {
  elapsedSpeed = 0.0,
  elapsedChargeBarProgress = 0.0,
  elapsedUpdateChargeBarDepletion = 0.0,
  HideDisplayText = false,
  GetRidingAbroadReciprocal = 0.01,
  prevSpeed = 0,
  previousCharges = select(2, API:GetSharedInfo())
}

---@class MutableDataSharedInfo
MutableDataSharedInfo = {
  IsCharging = false,
  Charges = 0.0,
  MaxCharges = 0.0,
  ChargeStart = 0.0,
  ChargeDuration= 0.0,
  IsThrill = false,
  IsGroundSkimming = false,
}

ns.MutableData = MutableData

---@class buffAnchorPoints <string, table>
local buffAnchorPoints = {
  ['Top Left'] = {'BOTTOMLEFT', 'TOPLEFT', 0, 8},
  ['Top'] = {'BOTTOM', 'TOP', 0, 8},
  ['Top Right'] = {'BOTTOMRIGHT', 'TOPRIGHT', 0, 8},
  ['Left'] = {'RIGHT', 'LEFT', -8, 0},
  ['Right'] = {'LEFT', 'RIGHT', 8, 0},
  ['Bottom Left'] = {'TOPLEFT', 'BOTTOMLEFT', 0, -8},
  ['Bottom'] = {'TOP', 'BOTTOM', 0, -8},
  ['Bottom Right'] = {'TOPRIGHT', 'BOTTOMRIGHT', 0, -8}
}

local FrameDeltaLerp = FrameDeltaLerp

---@class Skin
local Skin = {
  Outline = {
    Inset = 1,
    SliceMargin = { left = 2, top = 2, right = 2, bottom = 2 },
    Texture = 'Interface\\AddOns\\Falcon\\Media\\Border\\PixelOutline.tga'
  },
  Shadow = {
    Inset = 7,
    SliceMargin = { left = 7, top = 7, right = 7, bottom = 7 },
    Texture = 'Interface\\AddOns\\Falcon\\Media\\Border\\FalconOutsideGlow.tga',
  },
  InsideGlow = {
    IncreaseSubLayer = true,
    SliceMargin = { left = 3, top= 3, right = 3, bottom = 3 },
    Texture = 'Interface\\AddOns\\Falcon\\Media\\Border\\FalconInsideGlow.tga',
  },
}

function Falcon:SetupSlicedTexture(frame, config, layer, subLevel)
  local tex = frame:CreateTexture(nil, layer, nil, subLevel)
  tex:SetTexture(config.Texture)
  if config.SliceMargin then
    tex:SetTextureSliceMargins(
      config.SliceMargin.left,
      config.SliceMargin.top,
      config.SliceMargin.right,
      config.SliceMargin.bottom
    )
    tex:SetTextureSliceMode(config.SliceMode or Enum.UITextureSliceMode.Stretched)
  end
  if config.IncreaseSubLayer then
    local drawLayer, subLayer = tex:GetDrawLayer()
    tex:SetDrawLayer(drawLayer, subLayer + 1)
  end
  return tex
end

---@param elapsed number
function Falcon:RefreshSpeedDisplay(elapsed)
  MutableData.elapsedSpeed = MutableData.elapsedSpeed + elapsed
  if not (MutableData.elapsedSpeed > Configuration.updateSpeedRate) then return end
  MutableData.elapsedSpeed = 0

  if not API:IsAdvFlying() then
    MutableData.prevSpeed = 0
    self:UpdateSpeedText(0)
    self.SpeedBar.tick:Hide()
    self.SpeedBar:SetValue(0)
    self.SpeedBar:SetScript('OnUpdate', nil)
  end

  local forwardSpeed = API:GetAdvFlyingForwardSpeed()
  self:UpdateSpeedText(forwardSpeed * 14.285)
  if abs(MutableData.prevSpeed - forwardSpeed) < 0.0001 then
    return
  end

  local speed = forwardSpeed * MutableData.GetRidingAbroadReciprocal
  local prevSpeed = MutableData.prevSpeed or speed

  local newSpeed = FrameDeltaLerp(prevSpeed, speed, 0.2)

  local transition = 0.6
  local V_MAX = 1.0
  local D_MAX = 1.2
  local p = 1.2

  local V_RANGE_RECIPROCAL = 2.5 -- 1.0 / (1.0 - 0.6)
  local D_RANGE = D_MAX - transition

  local scaledSpeed

  if newSpeed <= transition then
    scaledSpeed = newSpeed
  else
    local v_delta = newSpeed - transition
    local v_range = V_MAX - transition
    local clamped_delta = min(v_delta, v_range)
    local normalized_speed = clamped_delta * V_RANGE_RECIPROCAL
    local mapped_delta = D_RANGE * pow(normalized_speed, p)
    scaledSpeed = transition + mapped_delta
  end

  self.SpeedBar:SetValue(scaledSpeed)
  MutableData.prevSpeed = newSpeed
end

---@param forwardSpeed number
function Falcon:UpdateSpeedText(forwardSpeed)
  if not MutableData.HideDisplayText then
    local TextDisplay = self.TextDisplay
    if forwardSpeed <= 0 then
      if TextDisplay:IsShown() and not TextDisplay.AnimHide:IsPlaying() then
        TextDisplay.AnimHide:Play()
      end
    else
      if not TextDisplay:IsShown() and not TextDisplay.AnimShow:IsPlaying() then
        TextDisplay.AnimShow:Play()
      end
    end

    TextDisplay.Text:SetText((forwardSpeed > 0) and string.format(' %d ', forwardSpeed) or '')
  end
end

function Falcon:HideAnim()
  if not ns.LEM:IsInEditMode() and self:IsShown() and not self.AnimHide:IsPlaying() then
    self.AnimShow:Stop()
    self.AnimHide:Play()
    MutableData.IsThrill = false
  end
end

function Falcon:ShowAnim()
  if not (self:IsShown() or self.AnimShow:IsPlaying()) then
    self.SpeedBar:SetValue(0)
    self.AnimShow:Play()
  end
end

---@param elapsed number
function Falcon:UpdateChargeBarDepletion(elapsed)
  MutableData.elapsedUpdateChargeBarDepletion = MutableData.elapsedUpdateChargeBarDepletion + elapsed
  if not (MutableData.elapsedUpdateChargeBarDepletion > Configuration.updateRate) then return end
  MutableData.elapsedUpdateChargeBarDepletion = 0

  if not MutableData.isDepleting then
    self:SetScript('OnUpdate', nil)
    MutableData.LastDepletingState = nil
    return
  end

  local currentTime = GetTime()
  local info = MutableDataSharedInfo
  local targetProgress = info.Charges
  if info.IsCharging and info.ChargeDuration > 0 then
    targetProgress = info.Charges + min((currentTime - info.ChargeStart) / info.ChargeDuration, 1)
  end

  local currentDisplayProgress = MutableData.prevDepletionTotalProgress or MutableData.oldTotalProgress or 0

  local decay = Configuration.depletionSpeed
  local newProgress = targetProgress + (currentDisplayProgress - targetProgress) * exp(-decay * elapsed)

  MutableData.prevDepletionTotalProgress = newProgress

  local maxCharges = min(self.num_charges, info.MaxCharges)
  for i = 1, maxCharges do
    local chargeBar = self.ChargeBars[i]
    local value = 0
    if i <= floor(newProgress) then
      value = 1
    elseif i == ceil(newProgress) then
      value = newProgress - floor(newProgress)
    end
    chargeBar:SetValue(value)
  end

  local progressDifference = abs(newProgress - targetProgress)
  if progressDifference < 0.001 or newProgress < targetProgress then
    MutableData.isDepleting = nil
    MutableData.prevDepletionTotalProgress = nil
    MutableData.oldTotalProgress = targetProgress
    self:UpdateUI('ACTIONBAR_UPDATE_COOLDOWN')
  end
end

function Falcon:UpdateCharges()
  local info = MutableDataSharedInfo
  MutableData.maxVigorCharges = info.MaxCharges
  MutableData.IsThrill = info.IsThrill
  MutableData.IsGroundSkimming = info.IsGroundSkimming and not info.IsThrill
  MutableData.GetRidingAbroadReciprocal = API:GetRidingAbroadReciprocal()

  local startTime, duration = API:GetWhirlingSurgeInfo()
  local visibility = MutableData.BuffSettings.Visibility
  local shouldShowSurge = (visibility == 3) or (visibility == 2 and duration == 0) or (visibility == 1 and duration > 2)

  if shouldShowSurge then
    self.WhirlingSurge:Show()
    if startTime > 0 and duration > 0 then
      self.WhirlingSurge.Cooldown:SetCooldown(startTime, duration)
    end
  else
    self.WhirlingSurge:Hide()
  end

  local currentTime = GetTime()
  local currentTotalProgress = (info.Charges < info.MaxCharges and info.ChargeDuration > 0)
    and (info.Charges + min((currentTime - info.ChargeStart) / info.ChargeDuration, 1)) or info.Charges

  MutableData.oldTotalProgress = MutableData.oldTotalProgress or currentTotalProgress

  local diff = MutableData.oldTotalProgress - currentTotalProgress
  if diff > 0.5 and not MutableData.isDepleting then
    MutableData.isDepleting = true
    MutableData.prevDepletionTotalProgress = MutableData.oldTotalProgress
    MutableData.prevCooldownProgress = nil
  end

  if not MutableData.isDepleting then
    MutableData.oldTotalProgress = currentTotalProgress
    MutableData.previousCharges = info.Charges
  end

  local colors = MutableData.StatusBarColors
  local speedBarColor = info.IsThrill and colors.Thrill or (info.IsGroundSkimming and colors.GroundSkimming or colors.LowSpeed)

  if MutableData.LastSpeedBarColor ~= speedBarColor then
    self.SpeedBar:SetStatusBarColor(speedBarColor.r, speedBarColor.g, speedBarColor.b, speedBarColor.a)
    self.SpeedBar.tick:SetShown(info.IsThrill)
    MutableData.LastSpeedBarColor = speedBarColor
  end

  local _, secondWindCharges = API:GetSecondWindInfo()
  local totalFilledCharges = info.Charges + secondWindCharges
  local progressIndex = info.Charges + 1
  local chargeBarColor = MutableData.ApplySpeedBarColorsToChargeBar and speedBarColor or colors.Charge

  for i = 1, info.MaxCharges do
    local chargeBar = self.ChargeBars[i]
    local secondWindBar = self.SecondWindBars[i]
    chargeBar:SetMinMaxValues(0, 1)

    if not MutableData.isDepleting then
      if i < progressIndex then
        chargeBar:SetValue(1)
      elseif i > progressIndex then
        chargeBar:SetValue(0)
      elseif info.IsCharging then
        self.SharedChargeDurationObject:SetTimeFromStart(info.ChargeStart, info.ChargeDuration)
        chargeBar:SetTimerDuration(self.SharedChargeDurationObject, 1)
      else
        chargeBar:SetValue(0)
      end
    end

    secondWindBar:SetMinMaxValues(0, 1)
    if MutableData.secondWindMode == 1 then
      secondWindBar:SetValue((i <= totalFilledCharges) and 1 or 0, 1)
    else
      secondWindBar:SetValue(0)
    end
    chargeBar:SetStatusBarColor(chargeBarColor.r, chargeBarColor.g, chargeBarColor.b, chargeBarColor.a)
  end

  if MutableData.LastDepletingState ~= MutableData.isDepleting then
    self:SetScript('OnUpdate', MutableData.isDepleting and function(f, e) self:UpdateChargeBarDepletion(e) end or nil)
    MutableData.LastDepletingState = MutableData.isDepleting
  end
end

function Falcon:UpdateUI(e,...)
  if LEM:IsInEditMode() then return end

  if API:IsDerbyRacing() or not API:IsSkyriding() then
    MutableData.previousCharges = 6
    MutableData.prevCooldownProgress = 0
    MutableData.prevProgressChargeIndex = 0
    MutableData.isDepleting = nil
    MutableData.oldTotalProgress = 0
    self.SpeedBar:SetScript('OnUpdate', nil)
    self:SetScript('OnUpdate', nil)
    self:HideAnim()
    return
  end

  local isCharging, charges, maxCharges, chargeStart, chargeDuration, _, isThrill, isGroundSkimming = API:GetSharedInfo()
  if (not API:IsAdvFlying()) and (not isCharging) and MutableData.hideWhenGroundedAndFull then
    self:HideAnim()
    return
  end

  MutableDataSharedInfo.IsCharging = isCharging
  MutableDataSharedInfo.Charges = charges
  MutableDataSharedInfo.MaxCharges = maxCharges
  MutableDataSharedInfo.ChargeStart = chargeStart
  MutableDataSharedInfo.ChargeDuration = chargeDuration
  MutableDataSharedInfo.IsThrill = isThrill
  MutableDataSharedInfo.IsGroundSkimming = isGroundSkimming
  if e == 'ACTIONBAR_UPDATE_COOLDOWN' then
    self:UpdateCharges()
  end

  self.SpeedBar:SetScript('OnUpdate', function(_, elapsed) self:RefreshSpeedDisplay(elapsed) end)
  self:UpdateBarBehaviourVisibility(MutableUIStates.BarBehaviourFlags)
  self:ShowAnim()
end

function Falcon:SetElementVisibility(frame, isVisible)
  if isVisible then
    if frame.AnimHide:IsPlaying() then
      frame.AnimHide:Stop()
    end
    if not frame:IsShown() then
      frame:Show()
      frame.AnimShow:Play()
    elseif not frame.AnimShow:IsPlaying() and frame:GetAlpha() < 1 then
      frame.AnimShow:Play()
    end
  else
    if frame.AnimShow:IsPlaying() then
      frame.AnimShow:Stop()
    end
    if frame:IsShown() and not frame.AnimHide:IsPlaying() then
      frame.AnimHide:Play()
    end
  end
end

function Falcon:UpdateBuffAnchor(layout)
  C_Timer.After(0.05, function()
  if not layout then return end
  local swapPosition = layout.Styles[layout.CurrentStyle].SwapPositions
  local anchor = layout.BuffSettings.Anchor
  if not self.SpeedBarBG:IsShown() and not self.ChargesParent:IsShown() then
    self.WhirlingSurge:Hide()
    return
  end
  local target = self
  local isTop = anchor:find('Top')
  local isBottom = anchor:find('Bottom')
  if isTop then
    if not self.SpeedBarBG:IsShown() and not swapPosition then
      target = self.ChargesParent
    elseif not self.ChargesParent:IsShown() and swapPosition then
      target = self.SpeedBarBG
    end
  elseif isBottom then
    if not self.ChargesParent:IsShown() and not swapPosition then
      target = self.SpeedBarBG
    elseif not self.SpeedBarBG:IsShown() and swapPosition then
      target = self.ChargesParent
    end
  end
  local anchorConfig = buffAnchorPoints[anchor]
  self.WhirlingSurge:ClearAllPoints()
  self.WhirlingSurge:SetPoint(anchorConfig[1], target, anchorConfig[2], anchorConfig[3], anchorConfig[4])
  end)
end

function Falcon:UpdateBarBehaviourVisibility(flags)
  local B = F.BarBehaviour
  local isAdvFlying = API:IsAdvFlying()
  local isCharging = MutableDataSharedInfo.IsCharging

  local isGrounded = not isAdvFlying
  local isFullGrounded = isGrounded and not isCharging

  local condGrounded = FlagsUtil.IsAnySet(flags, B.HIDE_GROUNDED)
  local condFullGrounded = FlagsUtil.IsAnySet(flags, B.HIDE_FULL_GROUNDED)
  local condAlways = not (condGrounded or condFullGrounded)

  local shouldHideCharges = false
  if FlagsUtil.IsAnySet(flags, B.HIDE_CHARGES) then
    if condAlways or (condGrounded and isGrounded) or (condFullGrounded and isFullGrounded) then
      shouldHideCharges = true
    end
  end

  local shouldHideSpeed = false
  if FlagsUtil.IsAnySet(flags, B.HIDE_SPEED) then
    if condAlways or (condGrounded and isGrounded) or (condFullGrounded and isFullGrounded) then
      shouldHideSpeed = true
    end
  end

  if MutableData.LastHideCharges ~= shouldHideCharges or MutableData.LastHideSpeed ~= shouldHideSpeed then
    self:SetElementVisibility(self.SpeedBarBG, not shouldHideSpeed)
    self:SetElementVisibility(self.ChargesParent, not shouldHideCharges)
    MutableData.LastHideCharges = shouldHideCharges
    MutableData.LastHideSpeed = shouldHideSpeed
  end
  self:UpdateBuffAnchor()
  self:UpdateShadow(shouldHideCharges, shouldHideSpeed)
end

function Falcon:UpdateUISizes(new_charge_width, new_speed_height, new_charge_height, new_padding, new_swap_position, new_bar_behaviour_flags)
  local width = (new_charge_width == nil) and MutableUIStates.Width or new_charge_width
  local speedHeight = (new_speed_height == nil) and MutableUIStates.SpeedHeight or new_speed_height
  local chargeHeight = (new_charge_height == nil) and MutableUIStates.ChargeHeight or new_charge_height
  local padding = (new_padding == nil) and MutableUIStates.Padding or new_padding
  local swapPosition = (new_swap_position == nil) and MutableUIStates.SwapPosition or new_swap_position
  local flags = (new_bar_behaviour_flags == nil) and MutableUIStates.BarBehaviourFlags or new_bar_behaviour_flags

  MutableUIStates.Width = width
  MutableUIStates.SpeedHeight = speedHeight
  MutableUIStates.ChargeHeight = chargeHeight
  MutableUIStates.Padding = padding
  MutableUIStates.SwapPosition = swapPosition
  MutableUIStates.BarBehaviourFlags = flags

  self:UpdateBarBehaviourVisibility(flags)
  local uiScale = UIParent:GetScale()
  local num_charges = self.num_charges

  local effectivePadding = padding
  if effectivePadding > 0 then
    effectivePadding = effectivePadding + (Skin.Outline.Inset + 1)
  end

  local precisionPadding = PixelUtil.GetNearestPixelSize(effectivePadding, uiScale, 1)
  local precisionWidth = PixelUtil.GetNearestPixelSize(width, uiScale, 1)
  local precisionSpeedBarHeight = PixelUtil.GetNearestPixelSize(speedHeight, uiScale, 1)
  local precisionChargeBarHeight = PixelUtil.GetNearestPixelSize(chargeHeight, uiScale, 1)

  local totalWidth = PixelUtil.GetNearestPixelSize((num_charges * precisionWidth) + ((num_charges - 1) * precisionPadding), uiScale, 1)
  local mainframeHeight = PixelUtil.GetNearestPixelSize(precisionSpeedBarHeight + precisionPadding + precisionChargeBarHeight, uiScale, 1)

  self:SetSize(totalWidth, mainframeHeight)
  local iconSize = MutableData.BuffSettings.Size
  PixelUtil.SetSize(self.WhirlingSurge, iconSize, iconSize, iconSize, iconSize)

  self.SpeedBarBG:SetSize(totalWidth, precisionSpeedBarHeight)
  self.SpeedBarBG:ClearAllPoints()

  self.ChargesParent:SetSize(totalWidth, precisionChargeBarHeight)
  self.ChargesParent:ClearAllPoints()

  if swapPosition then
    self.SpeedBarBG:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT')
    self.ChargesParent:SetPoint('TOPLEFT', self.SpeedBarBG, 'TOPLEFT', 0, precisionPadding + precisionChargeBarHeight)
  else
    self.SpeedBarBG:SetPoint('TOPLEFT', self, 'TOPLEFT')
    self.ChargesParent:SetPoint('TOPLEFT', self.SpeedBarBG, 'BOTTOMLEFT', 0, -precisionPadding)
  end

  local INSET = 0
  self.SpeedBar:ClearAllPoints()
  self.SpeedBar:SetPoint('TOPLEFT', self.SpeedBarBG, 'TOPLEFT', INSET, -INSET)
  self.SpeedBar:SetPoint('BOTTOMRIGHT', self.SpeedBarBG, 'BOTTOMRIGHT', -INSET, INSET)
  self.SpeedBar.tick:SetPoint('TOPLEFT', self.SpeedBar, 'TOPLEFT', PixelUtil.GetNearestPixelSize(totalWidth/2 - 0.5, uiScale), 1)
  for i = 1, num_charges do
    local chargesBG = self.ChargeBGs[i]
    local chargeBar = self.ChargeBars[i]
    local secondWindBar = self.SecondWindBars[i]

    chargesBG:SetSize(precisionWidth, precisionChargeBarHeight)
    chargesBG:ClearAllPoints()
    if i == 1 then
      chargesBG:SetPoint('TOPLEFT', self.ChargesParent, 'TOPLEFT', 0, 0)
    else
      local previousChargesBG = self.ChargeBGs[i - 1]
      chargesBG:SetPoint('TOPLEFT', previousChargesBG, 'TOPRIGHT', precisionPadding, 0)
    end

    chargeBar:ClearAllPoints()
    chargeBar:SetPoint('TOPLEFT', chargesBG, 'TOPLEFT', INSET, -INSET)
    chargeBar:SetPoint('BOTTOMRIGHT', chargesBG, 'BOTTOMRIGHT', -INSET, INSET)

    secondWindBar:ClearAllPoints()
    secondWindBar:SetPoint('TOPLEFT', chargesBG, 'TOPLEFT', INSET, -INSET)
    secondWindBar:SetPoint('BOTTOMRIGHT', chargesBG, 'BOTTOMRIGHT', -INSET, INSET)
  end
end

function Falcon:UpdateShadow(hideCharges, hideSpeed)
  local isZeroPadding = MutableUIStates.Padding == 0
  local alpha = MutableData.FrameColors.ShadowColor.a
  self.shadow:SetAlpha(0)
  self.SpeedBarBG.shadow:SetAlpha(0)
  self.ChargesParent.shadow:SetAlpha(0)
  for i = 1, self.num_charges do
    self.ChargeBGs[i].shadow:SetAlpha(0)
  end

  if hideCharges and hideSpeed then return end

  if not hideCharges and not hideSpeed and isZeroPadding then
    self.shadow:SetAlpha(alpha or 0)
  else
    if not hideSpeed then
      self.SpeedBarBG.shadow:SetAlpha(alpha)
    end

    if not hideCharges then
      if isZeroPadding then
        self.ChargesParent.shadow:SetAlpha(alpha)
      else
        for i = 1, self.num_charges do
          self.ChargeBGs[i].shadow:SetAlpha(alpha)
        end
      end
    end
  end
end

function Falcon:AddShadow(frame)
  local shadow = self:SetupSlicedTexture(frame, Skin.Shadow, 'BACKGROUND', -1)
  shadow:SetPoint('TOPLEFT', frame, 'TOPLEFT', -Skin.Shadow.Inset, Skin.Shadow.Inset)
  shadow:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', Skin.Shadow.Inset, -Skin.Shadow.Inset)
  frame.shadow = shadow
end

function Falcon:AddInsideGlow(frame)
  local glow =  self:SetupSlicedTexture(frame, Skin.InsideGlow)
  glow:SetAllPoints()
  frame.insideGlow = glow
end

function Falcon:AddOutline(frame)
  local outline =  self:SetupSlicedTexture(frame, Skin.Outline)
  outline:SetPoint('TOPLEFT', frame, 'TOPLEFT', -Skin.Outline.Inset, Skin.Outline.Inset)
  outline:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', Skin.Outline.Inset, -Skin.Outline.Inset)
  frame.outline = outline
end

function Falcon:CreateUI()
  self.num_charges = 6
  self:AddShadow(self)
  local surge = CreateFrame('Frame', nil, self)
  self.WhirlingSurge = surge
  surge.Icon = surge:CreateTexture(nil, 'ARTWORK')
  surge.Icon:SetAllPoints()
  surge.Icon:SetTexCoord(.08, .92, .08, .92)
  local icon = C_Spell.GetSpellTexture(1227921)
  surge.Icon:SetTexture(icon)
  surge.Cooldown = CreateFrame('Cooldown', nil, surge, 'CooldownFrameTemplate') ---@diagnostic disable-line: generic-constraint-mismatch
  surge.Cooldown:SetAllPoints()
  surge.Cooldown:SetHideCountdownNumbers(false)
  surge.Cooldown:HookScript('OnCooldownDone', function() self:UpdateUI('ACTIONBAR_UPDATE_COOLDOWN') end)
  self:AddOutline(surge)
  self:AddShadow(surge)

  local speedBarBG = CreateFrame('Frame', nil, self)
  self.SpeedBarBG = speedBarBG
  self:AddOutline(speedBarBG)
  self:AddShadow(speedBarBG)

  speedBarBG.Background = speedBarBG:CreateTexture(nil, 'BACKGROUND', nil, 0)
  speedBarBG.Background:SetAllPoints(speedBarBG)

  local speedBar = CreateFrame('StatusBar', nil, speedBarBG)
  self.SpeedBar = speedBar
  self:AddInsideGlow(speedBar)
  speedBar:SetStatusBarTexture('interface\\buttons\\white8x8')
  speedBar:SetMinMaxValues(0, 1.2)
  speedBar:SetValue(0)

  speedBar.tick = speedBar:CreateTexture()
  speedBar.tick:SetDrawLayer('OVERLAY')
  speedBar.tick:SetPoint('TOP')
  speedBar.tick:SetPoint('BOTTOM')
  speedBar.tick:SetColorTexture(0, 0, 0, 1)
  speedBar.tick:Hide()

  local chargesParent = CreateFrame('Frame', nil, self)
  self.ChargesParent = chargesParent
  self:AddShadow(chargesParent)

  self.ChargeBGs = {}
  self.ChargeBars = {}
  self.SecondWindBars = {}
  for i = 1, self.num_charges do
    local chargesBG = CreateFrame('Frame', nil, chargesParent)
    self.ChargeBGs[i] = chargesBG
    self:AddOutline(chargesBG)
    self:AddShadow(chargesBG)

    chargesBG.Background = chargesBG:CreateTexture(nil, 'BACKGROUND', nil, 0)
    chargesBG.Background:SetAllPoints(chargesBG)

    local secondWindBar = CreateFrame('StatusBar', nil, chargesBG)
    self.SecondWindBars[i] = secondWindBar
    secondWindBar:SetStatusBarTexture('interface\\buttons\\white8x8')
    secondWindBar:SetMinMaxValues(0, 1.2)
    secondWindBar:SetValue(0)

    local chargeBar = CreateFrame('StatusBar', nil, chargesBG)
    self.ChargeBars[i] = chargeBar
    self:AddInsideGlow(chargeBar)
    chargeBar:SetStatusBarTexture('interface\\buttons\\white8x8')
    chargeBar:SetMinMaxValues(0, 1.2)
    chargeBar:SetValue(0)
    chargeBar:SetFrameLevel(secondWindBar:GetFrameLevel() + 1)
  end

  local textDisplay = CreateFrame('Frame', nil, speedBarBG)
  self.TextDisplay = textDisplay
  textDisplay:SetFrameLevel(speedBar:GetFrameLevel()+2)
  textDisplay:SetPoint('TOPLEFT', speedBar, 'TOPLEFT')
  textDisplay:SetPoint('BOTTOMRIGHT', speedBar, 'BOTTOMRIGHT')

  local textFontString = textDisplay:CreateFontString(nil, 'OVERLAY')
  textFontString:SetFont('Fonts\\ARIALN.TTF', 14)
  textFontString:SetShadowOffset(1,-1)
  textFontString:SetJustifyV('MIDDLE')
  textFontString:SetJustifyH('RIGHT')
  textFontString:SetWordWrap(false)
  textFontString:SetAllPoints()
  self.TextDisplay.Text = textFontString
  self:CreateAnimations()
end

function Falcon:CreateAnimations()
  self.AnimShow = API:CreateAnimationGroupFromConfig(self, {
    setToFinalAlpha = true,
    onPlay = function(self)
      local frame = self:GetParent()
      frame:Show();
    end,
    animations = {
      { type = 'Alpha', fromAlpha = 0, toAlpha = 1, duration = 0.45, smoothing = 'OUT' },
    }
  })

  self.AnimHide = API:CreateAnimationGroupFromConfig(self, {
    setToFinalAlpha = true,
    onFinished = function(self)
      local frame = self:GetParent()
      C_Timer.After(0, function()
        if LEM:IsInEditMode()then return end
        frame:Hide()
      end)
      frame:SetScript('OnUpdate', nil);
      frame.SpeedBar:SetValue(0)
    end,
    animations = {
      { type = 'Alpha', fromAlpha = 1, toAlpha = 0, duration = 0.7, smoothing = 'OUT' },
    }
  })

  self.TextDisplay.AnimShow = API:CreateAnimationGroupFromConfig(self.TextDisplay, {
    setToFinalAlpha = true,
    onPlay = function(self) self:GetParent():Show() end,
    animations = {
      { type = 'Alpha', fromAlpha = 0, toAlpha = 1, duration = 0.2, smoothing = 'IN' }
    }
  })

  self.TextDisplay.AnimHide = API:CreateAnimationGroupFromConfig(self.TextDisplay, {
    setToFinalAlpha = true,
    onFinished = function(self)
      self:GetParent():Hide();
    end,
    animations = {
      { type = 'Alpha', fromAlpha = 1, toAlpha = 0, duration = 0.2, smoothing = 'IN' }
    }
  })

  self.SpeedBarBG.AnimShow = API:CreateAnimationGroupFromConfig(self.SpeedBarBG, {
    setToFinalAlpha = true,
    onPlay = function(anim)
      anim:GetParent():Show()
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[LEM:GetActiveLayoutName()])
      end,
    animations = { { type = 'Alpha', fromAlpha = 0, toAlpha = 1, duration = 0.2, smoothing = 'OUT' } }
  })

  self.SpeedBarBG.AnimHide = API:CreateAnimationGroupFromConfig(self.SpeedBarBG, {
    setToFinalAlpha = true,
    onFinished = function(anim)
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[LEM:GetActiveLayoutName()])
      anim:GetParent():Hide()
    end,
    animations = { { type = 'Alpha', fromAlpha = 1, toAlpha = 0, duration = 0.2, smoothing = 'OUT' } }
  })

  self.ChargesParent.AnimShow = API:CreateAnimationGroupFromConfig(self.ChargesParent, {
    setToFinalAlpha = true,
    onPlay = function(anim)
      anim:GetParent():Show()
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[LEM:GetActiveLayoutName()])
      end,
    animations = { { type = 'Alpha', fromAlpha = 0, toAlpha = 1, duration = 0.2, smoothing = 'OUT' } }
  })

  self.ChargesParent.AnimHide = API:CreateAnimationGroupFromConfig(self.ChargesParent, {
    setToFinalAlpha = true,
    onFinished = function(anim)
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[LEM:GetActiveLayoutName()])
      anim:GetParent():Hide()
    end,
    animations = { { type = 'Alpha', fromAlpha = 1, toAlpha = 0, duration = 0.2, smoothing = 'OUT' } }
  })
end

function Falcon:OnEvent(e, ...)
  self:UpdateUI()
end

function Falcon:OnLoad()
  self:SetClampedToScreen(true)
  -- Set it high enough to draw over other elements
  self:SetFrameLevel(1000)
  self:CreateUI()
  self.SharedChargeDurationObject = C_DurationUtil.CreateDuration()

  self:SetScript('OnEvent', self.UpdateUI)
  self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
  self:RegisterEvent('ACTIONBAR_UPDATE_STATE')
  self:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
  self:RegisterEvent('PLAYER_CAN_GLIDE_CHANGED')
  self:RegisterEvent('PLAYER_IS_GLIDING_CHANGED')
end

Falcon:OnLoad()