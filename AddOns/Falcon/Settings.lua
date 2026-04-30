local addonName = ... ---@type string 'Falcon'
local ns = select(2,...) ---@class (partial) namespace
local F = ns.Flags
---@type Falcon
local Falcon = ns.Falcon
---@class FalconSettings : Frame
local FalconSettings = CreateFrame('frame')

local API = ns.API
local LEM = ns.LEM
local MutableData = ns.MutableData

---@class FalconColor
---@field r number
---@field g number
---@field b number
---@field a number

---@class FalconTexture
---@field Name string
---@field Texture string

---@class FontSettings
---@field Hide boolean
---@field Name string
---@field Size number
---@field Flags string
---@field Position { Justify: 'LEFT'|'CENTER'|'RIGHT' }

---@class StyleSettings
---@field ChargeHeight number
---@field Padding number
---@field SpeedHeight number
---@field SwapPositions boolean
---@field Width number

---@class BuffSettings
---@field Visibility integer
---@field Anchor 'Top Left' | 'Top' | 'Top Right' | 'Left' | 'Right' | 'Bottom Left' | 'Bottom' | 'Bottom Right'
---@field Size integer

---@class GeneralSettings
---@field ApplySpeedBarColorsToChargeBar boolean

---@class defaultTableData
---@field Position { x: number, y: number, point: FramePoint, scale: number }
---@field Version number
---@field FrameColors table<string, FalconColor>
---@field StatusBarColors table<string, FalconColor>
---@field FontSettings FontSettings
---@field BuffSettings BuffSettings
---@field CurrentStyle string
---@field CurrentTexture FalconTexture
---@field DefaultTexture FalconTexture
---@field hideWhenGroundedAndFull boolean
---@field mutedSoundsBitfield integer
---@field secondWindMode number
---@field BarBehaviourFlags integer
---@field Styles table<string, StyleSettings>
---@field General GeneralSettings
local defaultTableData = {
  Position = {
    x = 0.5,
    y = 200,
    point = 'BOTTOM',
    scale = 1
  },
  Version = 2,
  FrameColors = {
    InsideGlowColor = { r = 1, g = 1, b = 1, a = 0},
    BackgroundColor = { r = 0.2, g = 0.2, b = 0.2, a = 1},
    BorderColor = { r = 0, g = 0, b = 0, a = 1},
    ShadowColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.4 },
  },
  StatusBarColors = {
    Charge = { r = 0.0, g = 0.67, b = 0.98, a = 1 },
    GroundSkimming = { r = 0.88, g = 0.77, b = 0.25, a = 1.0 },
    LowSpeed = { r = 0.86, g = 0.32, b = 0.39, a = 1.0 },
    SecondWind = { r = 0.0, g = 0.45, b = 0.65, a = 1 },
    Thrill = { r = 0.5490, g = 0.8118, b = 0.3882, a = 1 },
  },
  General = {
    ApplySpeedBarColorsToChargeBar = false,
  },
  FontSettings = {
    Flags = '',
    Hide = false,
    Name = 'ARIALN',
    Position = {
      Justify = 'RIGHT',
    },
    Size = 14,
  },
  BuffSettings = {
    Anchor = 'Right',
    Size = 28,
    Visibility = 1,
  },
  CurrentStyle = 'Clean',
  CurrentTexture = { Name = 'Falcon Smooth', Texture = 'Interface\\AddOns\\Falcon\\Media\\Statusbar\\FalconSmooth.tga' },
  DefaultTexture = { Name = 'Falcon Smooth', Texture = 'Interface\\AddOns\\Falcon\\Media\\Statusbar\\FalconSmooth.tga' },
  hideWhenGroundedAndFull = false,
  mutedSoundsBitfield = 0,
  secondWindMode = 1,
  BarBehaviourFlags = 0,
  Styles = {
    Clean = {
      ChargeHeight = 14,
      Padding = 0,
      SpeedHeight = 14,
      SwapPositions = false,
      Width = 36,
    }
  }
}

ns.defaultTableData = defaultTableData

---@class defaultPosition
local defaultPosition = CopyTable(defaultTableData.Position)

local LibSharedMedia = LibStub('LibSharedMedia-3.0')

ns.SharedMediaTextures = {
  { Name = 'Falcon Light', Texture = 'Interface\\AddOns\\Falcon\\Media\\Statusbar\\FalconLight.tga' },
  { Name = 'Falcon Shaded', Texture = 'Interface\\AddOns\\Falcon\\Media\\Statusbar\\FalconShaded.tga' },
  { Name = 'Falcon Smooth', Texture = 'Interface\\AddOns\\Falcon\\Media\\Statusbar\\FalconSmooth.tga' },
}

ns.MediaNames = {}
if LibSharedMedia then
  for _, v in ipairs(ns.SharedMediaTextures) do
    ns.MediaNames[v.Name] = true
    LibSharedMedia:Register('statusbar', v.Name, v.Texture)
  end
end

local SECOND_WIND_OPTIONS_LIST = {
  { id = 0, state = 'Disabled' },
  { id = 1, state = 'Integrated' },
}

local barBehaviourRequirementMask = bit.bor(F.BarBehaviour.HIDE_CHARGES, F.BarBehaviour.HIDE_SPEED)

local BARBEHAVIOUR_OPTION_LIST = {
  { id = F.BarBehaviour.HIDE_CHARGES, state = 'Hide Charges' },
  { id = F.BarBehaviour.HIDE_SPEED, state = 'Hide Speed' },
  { id = F.BarBehaviour.HIDE_GROUNDED, state = 'Hide when grounded', requirementMask = barBehaviourRequirementMask },
  { id = F.BarBehaviour.HIDE_FULL_GROUNDED, state = 'Hide when fully charged and grounded', requirementMask = barBehaviourRequirementMask },
}

-- To be added
local WHIRLING_SURGE_OPTIONS_SHOWNSTATE_LIST = {
  { id = 0, state = 'Disabled' },
  { id = 1, state = 'Show on Cooldown' },
  { id = 2, state = 'Hide on Cooldown' },
  { id = 3, state = 'Always Show' }
}

local sounds = {
  ['groundSkimming'] = { 1695571 },
  ['fastFlying'] =     { 1841696 },
  ['landingStomp'] = {
    1489050, 1489051, 1489052, 1489053,
  },
  ['skywardAscent'] = {
    840091, 840093, 840095, 840097, 840099, 840101, 840103, 564163
  },
  ['surgeForward'] = { 1378204 }, -- 1378204 is also Lift Off
  ['mountedWind'] = { 2066599 },
  ['flapping'] = { 564161, 564163, 564164, 564165, 564166, 564167, 564168, 564169, 564170, 564173},

  -- mounts
  ['renewedProtoDrake'] = {
    4634942, 4634944, 4634946,
  },
  ['windborneVelocidrake'] = {
    4663454, 4663456, 4663458, 4663460, 4663462, 4663464, 4663466,
  },
  ['highlandDrake'] = {
    4633280, 4633282, 4633284, 4633286, 4633288, 4633290,
    4641087, 4641089, 4641091, 4641093, 4641095, 4641097,
    4641099, 4633316, 4634009, 4634011, 4634013, 4634015,
    4634017, 4634019, 4634021,
  },
  ['windingSlitherdrake'] = {
    5163128, 5163130, 5163132, 5163134, 5163136, 5163138, 5163140,
  },
  ['algarianStormrider'] = {
    5357752, 5357769, 5357771, 5357773, 5357775, 5356559,
    5356561, 5356563, 5356565, 5356567, 5356569, 5356571,
    5356837, 5356839, 5356841, 5356843, 5356845, 5356847,
    5356849,
  },
  ['anurelosFlamesGuidance'] = {
    4683513, 4683515, 4683517, 4683519, 4683521, 4683523,
    4683525, 4683527, 4683529, 4683531, 4683533, 4683535,
    4683537, 4683539, 4683541, 4683543, 4683545, 4683547,
    4683549, 4683551, 5482244, 5482246, 5482248, 5482250,
    5482335, 5482337, 5482339, 5482341, 5482343, 5482345,
    5482347, 5482373, 5482375, 5482377, 5482379, 5482381,
    5482383, 5482385, 5482177, 5482179, 5482181,
  },
  ['grottoNetherwingDrake'] = {
    4633370, 4633372, 4633374, 4633376, 4633378, 4633380, 4633382,
  },
}

local SOUND_OPTIONS = {
  -- Order matters for Dropdown.
  { id = 2, name = 'Ground Skimming',              key = 'groundSkimming' },
  { id = 3, name = 'Surge Forward/Lift Off',       key = 'surgeForward' },
  { id = 4, name = 'Skyward Ascent',               key = 'skywardAscent' },
  { id = 5, name = 'Ground Landing Stomp',         key = 'landingStomp' },

  { id = 20, name = 'Algarian Stormrider', key = 'algarianStormrider', mountID = 1792},
  { id = 21, name = "Anu'relos, Flame's Guidance", key = 'anurelosFlamesGuidance', mountID = 1818 },
  { id = 22, name = 'Grotto Netherwing Drake', key = 'grottoNetherwingDrake', mountID = 1744 },
  { id = 23, name = 'Highland Drake', key = 'highlandDrake', mountID = 1563 },
  { id = 24, name = 'Renewed Proto-Drake', key = 'renewedProtoDrake', mountID = 1589 },
  { id = 25, name = 'Windborne Velocidrake', key = 'windborneVelocidrake', mountID = 1590 },
  { id = 26, name = 'Winding Slitherdrake', key = 'windingSlitherdrake', mountID = 1588 },
}

function FalconSettings:IsSoundChecked(id)
  local mask = bit.lshift(1, id - 1)
  return bit.band(FalconAddOnDB.Settings['FalconGlobalSettings'].mutedSoundsBitfield, mask) ~= 0
end

function FalconSettings:SetSoundChecked(id)
  local mask = bit.lshift(1, id - 1)
  local settings = FalconAddOnDB.Settings['FalconGlobalSettings']
  if self:IsSoundChecked(id) then
    settings.mutedSoundsBitfield = bit.bxor(settings.mutedSoundsBitfield, mask)
  else
    settings.mutedSoundsBitfield = bit.bor(settings.mutedSoundsBitfield, mask)
  end
  FalconSettings:ApplyMutedSoundsState()
end

function FalconSettings:ResetSounds()
  FalconAddOnDB.Settings['FalconGlobalSettings'].mutedSoundsBitfield = 0
  self:ApplyMutedSoundsState()
  FalconSettings.SoundsDropdown:GenerateMenu()
end

function FalconSettings:ApplyMutedSoundsState()
  for i, option in ipairs(SOUND_OPTIONS) do
    local soundKey = option.key
    if soundKey then
      local soundIDs = sounds[soundKey]

      if self:IsSoundChecked(option.id) then
        for _, soundID in ipairs(soundIDs) do
          MuteSoundFile(soundID)
        end
      else
        for _, soundID in ipairs(soundIDs) do
          UnmuteSoundFile(soundID)
        end
      end
    end
  end
end

---@param layoutName string
---@return string
function FalconSettings:GetCurrentLayoutName(layoutName, forceGlobal)
  if FalconAddOnDB.FalconGlobalSettingsEnabled or forceGlobal then
    return 'FalconGlobalSettings'
  end
  return layoutName
end

local function CancelPositionTicker()
  if Falcon.positionTicker then
    Falcon.positionTicker:Cancel()
  end
end

local function StartFixPosition()
  CancelPositionTicker()
  Falcon.positionTicker = C_Timer.NewTicker(0.1, function()
    API:FixPosition(Falcon)
  end, 1)
end

---@param target table
---@param default table
local function UpdateTable(target, default)
  for k, v in pairs(default) do
    if type(v) == 'table' then
      if type(target[k]) == 'table' then
        UpdateTable(target[k], v)
      else
        target[k] = v
      end
    elseif target[k] == nil then
      target[k] = v
    end
  end
end

---@param targetDB table
---@param key string
---@return table
local function EnsureSettings(targetDB, key)
  targetDB[key] = targetDB[key] or {}
  UpdateTable(targetDB[key], defaultTableData)
  return targetDB[key]
end

function FalconSettings:MigrateSettings(layout)
  if layout.Version == 1 then
    layout.Version = 2
    layout.Position.point = layout.point or layout.Position.point ---@diagnostic disable-line: undefined-field
    layout.Position.x = layout.x or layout.Position.x ---@diagnostic disable-line: undefined-field
    layout.Position.y = layout.y or layout.Position.y ---@diagnostic disable-line: undefined-field
    layout.point = nil
    layout.x = nil
    layout.y = nil
    layout.StatusBarColors.Thrill = layout.SpeedColor or layout.StatusBarColors.Thrill ---@diagnostic disable-line: undefined-field
    layout.SpeedColor = nil
    layout.StatusBarColors.Charge = layout.ChargeColor or layout.StatusBarColors.Charge ---@diagnostic disable-line: undefined-field
    layout.ChargeColor = nil
    layout.StatusBarColors.SecondWind = layout.SecondWindColor or layout.StatusBarColors.SecondWind ---@diagnostic disable-line: undefined-field
    layout.SecondWindColor = nil
    layout.FontSettings.Hide = layout.noDisplayText or layout.FontSettings.Hide ---@diagnostic disable-line: undefined-field
    layout.noDisplayText = nil
    layout.textPosition = nil
    layout.TextPosition = nil
    layout.BuffSettings.Visibility = layout.whirlingSurgeState or layout.BuffSettings.Visibility
    layout.whirlingSurgeState = nil
    local config = layout.Styles[layout.CurrentStyle]
    layout.CurrentTexture = layout.CurrentTexture or config.CurrentTexture or defaultTableData.DefaultTexture ---@diagnostic disable-line: undefined-field
    config.CurrentTexture = nil
    layout.FrameColors.InsideGlowColor = layout.InsideGlowColor or layout.FrameColors.InsideGlowColor
    layout.FrameColors.ShadowColor = layout.ShadowColor or layout.FrameColors.ShadowColor
    layout.FrameColors.BorderColor = layout.BorderColor or layout.FrameColors.BorderColor
    layout.FrameColors.BackgroundColor = layout.BackgroundColor or layout.FrameColors.BackgroundColor
    layout.InsideGlowColor = nil
    layout.ShadowColor = nil
    layout.BorderColor = nil
    layout.BackgroundColor = nil
  end
end

---@param layoutName string
function FalconSettings:SetupLayout(layoutName)
  FalconAddOnDB = FalconAddOnDB or {} ---@diagnostic disable-line
  FalconAddOnDB.Settings = FalconAddOnDB.Settings or {} ---@diagnostic disable-line
  FalconAddOnDB.FalconGlobalSettingsEnabled = FalconAddOnDB.FalconGlobalSettingsEnabled or false
  layoutName = self:GetCurrentLayoutName(layoutName)
  FalconAddOnDB.Settings[layoutName] = EnsureSettings(FalconAddOnDB.Settings, layoutName)
  FalconAddOnDB.Settings['FalconGlobalSettings'] = EnsureSettings(FalconAddOnDB.Settings, 'FalconGlobalSettings')
  ---@type defaultTableData
  local layout = FalconAddOnDB.Settings[layoutName]
  local styleConfig = layout.Styles[layout.CurrentStyle]
  self:MigrateSettings(layout)

  Falcon:ClearAllPoints()
  Falcon:SetPoint(layout.Position.point, layout.Position.x, layout.Position.y)
  local texture = LibSharedMedia:Fetch('statusbar', layout.CurrentTexture.Name, true) or defaultTableData.DefaultTexture.Texture

  Falcon.TextDisplay.Text:SetJustifyH(layout.FontSettings.Position.Justify)
  local font = LibSharedMedia:Fetch('font', layout.FontSettings.Name, true) or LibSharedMedia:Fetch('font', defaultTableData.FontSettings.Name)
  Falcon.TextDisplay.Text:SetFont(font, layout.FontSettings.Size, layout.FontSettings.Flags)
  Falcon.SpeedBar:SetStatusBarTexture(texture)
  Falcon.SpeedBar:SetStatusBarColor(layout.StatusBarColors.Thrill.r, layout.StatusBarColors.Thrill.g, layout.StatusBarColors.Thrill.b, layout.StatusBarColors.Thrill.a)
  Falcon.SpeedBar.insideGlow:SetVertexColor(layout.FrameColors.InsideGlowColor.r, layout.FrameColors.InsideGlowColor.g, layout.FrameColors.InsideGlowColor.b, layout.FrameColors.InsideGlowColor.a)
  Falcon.SpeedBar.tick:SetColorTexture(layout.FrameColors.BorderColor.r, layout.FrameColors.BorderColor.g, layout.FrameColors.BorderColor.b, layout.FrameColors.BorderColor.a)
  Falcon.SpeedBarBG.outline:SetVertexColor(layout.FrameColors.BorderColor.r, layout.FrameColors.BorderColor.g, layout.FrameColors.BorderColor.b, layout.FrameColors.BorderColor.a)
  Falcon.SpeedBarBG.Background:SetTexture(texture)
  Falcon.SpeedBarBG.Background:SetVertexColor(layout.FrameColors.BackgroundColor.r, layout.FrameColors.BackgroundColor.g, layout.FrameColors.BackgroundColor.b, layout.FrameColors.BackgroundColor.a)
  Falcon.SpeedBarBG.shadow:SetVertexColor(layout.FrameColors.ShadowColor.r, layout.FrameColors.ShadowColor.g, layout.FrameColors.ShadowColor.b, layout.FrameColors.ShadowColor.a)
  Falcon.shadow:SetVertexColor(layout.FrameColors.ShadowColor.r, layout.FrameColors.ShadowColor.g, layout.FrameColors.ShadowColor.b, layout.FrameColors.ShadowColor.a)
  Falcon.ChargesParent.shadow:SetVertexColor(layout.FrameColors.ShadowColor.r, layout.FrameColors.ShadowColor.g, layout.FrameColors.ShadowColor.b, 0)
  Falcon.WhirlingSurge.outline:SetVertexColor(layout.FrameColors.BorderColor.r, layout.FrameColors.BorderColor.g, layout.FrameColors.BorderColor.b, layout.FrameColors.BorderColor.a)
  Falcon.WhirlingSurge.shadow:SetVertexColor(layout.FrameColors.ShadowColor.r, layout.FrameColors.ShadowColor.g, layout.FrameColors.ShadowColor.b, layout.FrameColors.ShadowColor.a)

  for i = 1, Falcon.num_charges do
    ---@class ChargeBar : StatusBar
    ---@field insideGlow Texture
    local chargeBar = Falcon.ChargeBars[i]
    ---@class ChargeBarBG
    ---@field outline Texture
    ---@field Background Texture
    ---@field shadow Texture
    local chargesBG = Falcon.ChargeBGs[i]
    local secondWindBar = Falcon.SecondWindBars[i]
    chargesBG.outline:SetVertexColor(layout.FrameColors.BorderColor.r, layout.FrameColors.BorderColor.g, layout.FrameColors.BorderColor.b, layout.FrameColors.BorderColor.a)
    chargesBG.Background:SetTexture(texture)
    chargesBG.Background:SetVertexColor(layout.FrameColors.BackgroundColor.r, layout.FrameColors.BackgroundColor.g, layout.FrameColors.BackgroundColor.b, layout.FrameColors.BackgroundColor.a)
    chargesBG.shadow:SetVertexColor(layout.FrameColors.ShadowColor.r, layout.FrameColors.ShadowColor.g, layout.FrameColors.ShadowColor.b, layout.FrameColors.ShadowColor.a)
    chargeBar:SetStatusBarColor(layout.StatusBarColors.Charge.r, layout.StatusBarColors.Charge.g, layout.StatusBarColors.Charge.b, layout.StatusBarColors.Charge.a)
    chargeBar:SetStatusBarTexture(texture)
    chargeBar.insideGlow:SetVertexColor(layout.FrameColors.InsideGlowColor.r, layout.FrameColors.InsideGlowColor.g, layout.FrameColors.InsideGlowColor.b, layout.FrameColors.InsideGlowColor.a)
    secondWindBar:SetStatusBarColor(layout.StatusBarColors.SecondWind.r, layout.StatusBarColors.SecondWind.g, layout.StatusBarColors.SecondWind.b, layout.StatusBarColors.SecondWind.a)
    secondWindBar:SetStatusBarTexture(texture)
  end

  MutableData.hideWhenGroundedAndFull = layout.hideWhenGroundedAndFull
  MutableData.HideDisplayText = layout.FontSettings.Hide
  MutableData.secondWindMode = FalconAddOnDB.Settings['FalconGlobalSettings'].secondWindMode
  MutableData.StatusBarColors = layout.StatusBarColors
  MutableData.FrameColors = layout.FrameColors
  MutableData.BuffSettings = layout.BuffSettings
  MutableData.ChargeBarColor = layout.StatusBarColors.Charge
  MutableData.ApplySpeedBarColorsToChargeBar = layout.General.ApplySpeedBarColorsToChargeBar

  Falcon:UpdateUISizes(styleConfig.Width, styleConfig.SpeedHeight, styleConfig.ChargeHeight, styleConfig.Padding, styleConfig.SwapPositions, layout.BarBehaviourFlags)
  Falcon:UpdateBuffAnchor(layout)
  self:ApplyMutedSoundsState()
end

local function OnPositionChanged(frame, layoutName, point, x, y)
  layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
  point, x, y = API:FixPosition(frame)
  FalconAddOnDB.Settings[layoutName].Position.point = point
  FalconAddOnDB.Settings[layoutName].Position.x = x
  FalconAddOnDB.Settings[layoutName].Position.y = y
end

local FalconMenuUtil = {}

function FalconMenuUtil:AddColorSwatch(rootDescription, layoutName, name, key, colorData, onUpdate)
  local function OnClick()
    local info = {
      r = colorData.r,
      g = colorData.g,
      b = colorData.b,
      opacity = colorData.a,
      hasOpacity = true,
      swatchFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
        local newColor = { r = r, g = g, b = b, a = a }
        if onUpdate then
          onUpdate(newColor)
        end
      end,
      cancelFunc = function()
        if onUpdate then
          onUpdate(colorData)
        end
      end,
    }
    ColorPickerFrame:SetupColorPickerAndShow(info)
  end

  local elementDescription = rootDescription:CreateButton(name, OnClick)
  elementDescription:SetResponse(MenuResponse.Open)
  elementDescription:AddInitializer(function(button, description, menu)
    local bg = button:AttachTexture(nil, 'BACKGROUND')
    bg:SetTexture('Interface\\Buttons\\WHITE8X8')
    bg:SetSize(14, 14)
    bg:SetPoint('RIGHT', -6, 0)
    bg:SetVertexColor(1, 1, 1, 1)

    local inner = button:AttachTexture(nil, 'BORDER')
    inner:SetTexture('Interface\\Buttons\\WHITE8X8')
    inner:SetSize(12, 12)
    inner:SetPoint('CENTER', bg)
    inner:SetVertexColor(0, 0, 0, 1)

    local colorTex = button:AttachTexture(nil, 'ARTWORK')
    colorTex:SetTexture('Interface\\Buttons\\WHITE8X8')
    colorTex:SetSize(10, 10)
    colorTex:SetPoint('CENTER', bg)
    colorTex:SetVertexColor(colorData.r, colorData.g, colorData.b, colorData.a)

    local width = button.fontString:GetUnboundedStringWidth() + 40
    return width, 22
  end)

  return elementDescription
end

function FalconMenuUtil:RemoveDefaultText(owner)
  TextureLoadingGroupMixin.RemoveTexture({textures = owner}, 'defaultText') ---@diagnostic disable-line
end

function FalconSettings:GetActiveLayout()
  return FalconSettings:GetCurrentLayoutName(LEM:GetActiveLayoutName())
end

Falcon.editModeName = 'Falcon'
LEM:AddFrame(Falcon, OnPositionChanged, defaultPosition)
LEM:AddFrameSettings(Falcon, {
  {
    name = 'Use Global Settings',
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function()
      return FalconAddOnDB.FalconGlobalSettingsEnabled
    end,
    set = function(layoutName, value, fromReset)
      if fromReset then
        layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
        FalconSettings:SetupLayout(layoutName)
        Falcon:UpdateUI()
        LEM:RefreshFrameSettings(Falcon)
      else
        FalconAddOnDB.FalconGlobalSettingsEnabled = value
        layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
        FalconSettings:SetupLayout(layoutName)
        Falcon:UpdateUI()
        LEM:RefreshFrameSettings(Falcon)
      end
    end,
  },
  {
    name = 'Texture',
    kind = LEM.SettingType.Dropdown,
    default = defaultTableData.DefaultTexture.Texture,
    set = function()
      local texture = defaultTableData.DefaultTexture.Texture
      Falcon.SpeedBar:SetStatusBarTexture(texture)
      Falcon.SpeedBarBG.Background:SetTexture(texture)
      for i = 1, Falcon.num_charges do
        local chargeBarBG = Falcon.ChargeBGs[i]
        local chargeBar = Falcon.ChargeBars[i]
        local secondWindBar = Falcon.SecondWindBars[i]
        chargeBarBG.Background:SetTexture(texture) ---@diagnostic disable-line: undefined-field
        secondWindBar:SetStatusBarTexture(texture)
        chargeBar:SetStatusBarTexture(texture)
      end
      FalconAddOnDB.Settings[FalconSettings:GetActiveLayout()].CurrentTexture = { Name = defaultTableData.DefaultTexture.Name, Texture = defaultTableData.DefaultTexture.Texture }
    end,
    generator = function(owner, rootDescription)
      FalconSettings.SoundsDropdown = owner
      owner.ShouldShowTooltip = nop
      local layoutName = FalconSettings:GetActiveLayout()
      local getFunc = function(value)
        return FalconAddOnDB.Settings[layoutName].CurrentTexture.Name == value
      end
      local setFunc = function(value)
        local texture = LibSharedMedia:Fetch('statusbar', value)
        if texture then
          Falcon.SpeedBar:SetStatusBarTexture(texture)
          Falcon.SpeedBarBG.Background:SetTexture(texture)
          for i = 1, Falcon.num_charges do
            local chargeBarBG = Falcon.ChargeBGs[i]
            local chargeBar = Falcon.ChargeBars[i]
            local secondWindBar = Falcon.SecondWindBars[i]
            chargeBarBG.Background:SetTexture(texture) ---@diagnostic disable-line: undefined-field
            secondWindBar:SetStatusBarTexture(texture)
            chargeBar:SetStatusBarTexture(texture)
          end
          FalconAddOnDB.Settings[layoutName].CurrentTexture = { Name = value, Texture = texture }
        end
      end
      rootDescription:SetScrollMode(400)
      rootDescription:CreateTitle('Included');
      for _, key in ipairs(ns.SharedMediaTextures) do
        if key.Name == 'Falcon Smooth' then
          rootDescription:CreateCheckbox('Falcon Smooth (Default)', getFunc, setFunc, key.Name)
        else
          rootDescription:CreateCheckbox(key.Name, getFunc, setFunc, key.Name)
        end
      end
      rootDescription:CreateSpacer();
      rootDescription:CreateTitle('Shared Media');
      for _, name in ipairs(LibSharedMedia:List('statusbar')) do
        if not ns.MediaNames[name] then
          rootDescription:CreateCheckbox(name, getFunc, setFunc, name)
        end
      end
    end,
  },
  {
  name = 'Statusbar Colors',
  kind = LEM.SettingType.Dropdown,
  default = false,
  set = function(layoutName, value, fromReset)
    layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
    for key, defaultColor in pairs(defaultTableData.StatusBarColors) do
      FalconAddOnDB.Settings[layoutName].StatusBarColors[key] = {
        r = defaultColor.r,
        g = defaultColor.g,
        b = defaultColor.b,
        a = defaultColor.a
      }
      MutableData.StatusBarColors[key] = FalconAddOnDB.Settings[layoutName].StatusBarColors[key]
    end
  end,
  generator = function(owner, rootDescription, data)
    owner.ShouldShowTooltip = nop
    local layoutName = FalconSettings:GetActiveLayout()
    owner:SetDefaultText('Pick Colors')
    rootDescription:CreateTitle('Colors')

    local options = {
      { name = 'Charges', key = 'Charge' },
      { name = 'Second Wind', key = 'SecondWind' },
      { name = 'Low Speed', key = 'LowSpeed' },
      { name = 'Ground Skimming', key = 'GroundSkimming' },
      { name = 'Thrill', key = 'Thrill' }
    }

    for _, option in ipairs(options) do
      local colorData = FalconAddOnDB.Settings[layoutName].StatusBarColors[option.key]
      FalconMenuUtil:AddColorSwatch(rootDescription, layoutName, option.name, option.key, colorData,
        function(color)
          colorData = color
          MutableData.StatusBarColors[option.key] = color
          if option.key == 'Charge' or option.key == 'SecondWind' then
            for i = 1, Falcon.num_charges do
              if option.key == 'Charge' then
                local chargeBar = Falcon.ChargeBars[i]
                chargeBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
                MutableData.ChargeBarColor = color
              elseif option.key == 'SecondWind' then
                local secondWindBar = Falcon.SecondWindBars[i]
                secondWindBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
              end
            end
          else
            Falcon.SpeedBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
          end
        end)
    end
  end,
  },
  {
    name = 'Inside Color',
    kind = LEM.SettingType.ColorPicker,
    default = CreateColor(defaultTableData.FrameColors.InsideGlowColor.r, defaultTableData.FrameColors.InsideGlowColor.g, defaultTableData.FrameColors.InsideGlowColor.b, defaultTableData.FrameColors.InsideGlowColor.a),
    hasOpacity = true,
    get = function(layoutName)
      return CreateColor(MutableData.FrameColors.InsideGlowColor.r, MutableData.FrameColors.InsideGlowColor.g, MutableData.FrameColors.InsideGlowColor.b, MutableData.FrameColors.InsideGlowColor.a)
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local r, g, b, a = value:GetRGBA()
      MutableData.FrameColors.InsideGlowColor = { r = r, g = g, b = b, a = a}
      FalconAddOnDB.Settings[layoutName].FrameColors.InsideGlowColor = MutableData.FrameColors.InsideGlowColor
      Falcon.SpeedBar.insideGlow:SetVertexColor(r, g, b ,a)
      for i = 1, 6 do
        local charges = Falcon.ChargeBars[i]
        charges.insideGlow:SetVertexColor(r, g, b ,a) ---@diagnostic disable-line: undefined-field
      end
    end,
  },
  {
    name = 'Border Color',
    kind = LEM.SettingType.ColorPicker,
    default = CreateColor(defaultTableData.FrameColors.BorderColor.r, defaultTableData.FrameColors.BorderColor.g, defaultTableData.FrameColors.BorderColor.b, defaultTableData.FrameColors.BorderColor.a),
    hasOpacity = true,
    get = function(layoutName)
      return CreateColor(MutableData.FrameColors.BorderColor.r, MutableData.FrameColors.BorderColor.g, MutableData.FrameColors.BorderColor.b, MutableData.FrameColors.BorderColor.a)
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local r, g, b, a = value:GetRGBA()
      MutableData.FrameColors.BorderColor = { r = r, g = g, b = b, a = a}
      FalconAddOnDB.Settings[layoutName].FrameColors.BorderColor = MutableData.FrameColors.BorderColor
      Falcon.SpeedBarBG.outline:SetVertexColor(r, g, b, a)
      Falcon.SpeedBar.tick:SetColorTexture(r, g, b, a)
      Falcon.WhirlingSurge.outline:SetVertexColor(r, g, b, a)
      for i = 1, Falcon.num_charges do
        local chargesBG = Falcon.ChargeBGs[i]
        chargesBG.outline:SetVertexColor(r, g, b, a) ---@diagnostic disable-line
      end
    end,
  },
  {
    name = 'Shadow Color',
    kind = LEM.SettingType.ColorPicker,
    default = CreateColor(defaultTableData.FrameColors.ShadowColor.r, defaultTableData.FrameColors.ShadowColor.g, defaultTableData.FrameColors.ShadowColor.b, defaultTableData.FrameColors.ShadowColor.a),
    hasOpacity = true,
    get = function(layoutName)
      return CreateColor(MutableData.FrameColors.ShadowColor.r, MutableData.FrameColors.ShadowColor.g, MutableData.FrameColors.ShadowColor.b, MutableData.FrameColors.ShadowColor.a)
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local r, g, b, a = value:GetRGBA()
      MutableData.FrameColors.ShadowColor = { r = r, g = g, b = b, a = a}
      FalconAddOnDB.Settings[layoutName].FrameColors.ShadowColor = MutableData.FrameColors.ShadowColor
      Falcon.SpeedBarBG.shadow:SetVertexColor(r, g, b, a)
      Falcon.shadow:SetVertexColor(r, g, b, a)
      Falcon.ChargesParent.shadow:SetVertexColor(r, g, b, a)
      Falcon.WhirlingSurge.shadow:SetVertexColor(r, g, b, a)
      for i = 1, 6 do
        local chargesBG = Falcon.ChargeBGs[i]
        chargesBG.shadow:SetVertexColor(r, g, b, a) ---@diagnostic disable-line: undefined-field
      end
      Falcon:UpdateShadow()
    end,
  },
  {
    name = 'Background Color',
    kind = LEM.SettingType.ColorPicker,
    default = CreateColor(defaultTableData.FrameColors.BackgroundColor.r, defaultTableData.FrameColors.BackgroundColor.g, defaultTableData.FrameColors.BackgroundColor.b, defaultTableData.FrameColors.BackgroundColor.a),
    hasOpacity = true,
    get = function(layoutName)
      return CreateColor(MutableData.FrameColors.BackgroundColor.r, MutableData.FrameColors.BackgroundColor.g, MutableData.FrameColors.BackgroundColor.b, MutableData.FrameColors.BackgroundColor.a)
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local r, g, b, a = value:GetRGBA()
      MutableData.FrameColors.BackgroundColor = { r = r, g = g, b = b, a = a}
      FalconAddOnDB.Settings[layoutName].FrameColors.BackgroundColor = MutableData.FrameColors.BackgroundColor
      Falcon.SpeedBarBG.Background:SetVertexColor(r, g, b, a)
      for i = 1, Falcon.num_charges do
        local chargesBG = Falcon.ChargeBGs[i]
        chargesBG.Background:SetVertexColor(r, g, b, a) ---@diagnostic disable-line: undefined-field
      end
    end,
  },
  {
    name = 'Swap Positions',
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      local layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      return FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].SwapPositions ---@diagnostic disable-line: undefined-field
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].SwapPositions = value
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[layoutName])
      Falcon:UpdateUISizes(nil, nil, nil, nil, value)
    end,
  },
  {
    name = 'Cell Width',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.Styles.Clean.Width,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      ---@diagnostic disable-next-line: undefined-field
      return FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].Width
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].Width = value
      Falcon:UpdateUISizes(value)
      StartFixPosition()
    end,
    minValue = 10,
    maxValue = 100,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
    name = 'Speed Height',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.Styles.Clean.SpeedHeight,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      return FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].SpeedHeight ---@diagnostic disable-line: undefined-field
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].SpeedHeight = value
      Falcon:UpdateUISizes(nil, value)
      StartFixPosition()
    end,
    minValue = 6,
    maxValue = 50,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
    name = 'Charge Height',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.Styles.Clean.ChargeHeight,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      return FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].ChargeHeight ---@diagnostic disable-line: undefined-field
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].ChargeHeight = value
      Falcon:UpdateUISizes(nil, nil, value)
      StartFixPosition()
    end,
    minValue = 6,
    maxValue = 50,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
    name = 'Padding',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.Styles.Clean.Padding,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      return FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].Padding
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local CurrentStyle = FalconAddOnDB.Settings[layoutName].CurrentStyle
      FalconAddOnDB.Settings[layoutName].Styles[CurrentStyle].Padding = value
      Falcon:UpdateUISizes(nil, nil, nil, value)
      StartFixPosition()
    end,
    minValue = 0,
    maxValue = 40,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
    name = 'Font Size',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.FontSettings.Size,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      return FalconAddOnDB.Settings[layoutName].FontSettings.Size
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      FalconAddOnDB.Settings[layoutName].FontSettings.Size = value
      Falcon.TextDisplay.Text:SetFontHeight(value)
    end,
    minValue = 6,
    maxValue = 24,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
  name = 'Font Settings',
  kind = LEM.SettingType.Dropdown,
  default = '',
  set = function(layoutName, value, fromReset)
    if fromReset then
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      local defaults = defaultTableData.FontSettings
      MutableData.HideDisplayText = defaults.Hide
      Falcon.TextDisplay:Show()
      FalconAddOnDB.Settings[layoutName].FontSettings = {
        Hide = defaults.Hide,
        Name = defaults.Name,
        Size = defaults.Size,
        Flags = defaults.Flags,
        Position = {
          Justify = defaults.Position.Justify
        }
      }

      if defaults.Position.Justify == 'RIGHT' then
        Falcon.TextDisplay.Text:SetJustifyH('RIGHT')
      elseif defaults.Position.Justify == 'LEFT' then
        Falcon.TextDisplay.Text:SetJustifyH('LEFT')
      else
        Falcon.TextDisplay.Text:SetJustifyH('CENTER')
      end
      FalconSettings:SetupLayout(layoutName)
    end
  end,
  generator = function(owner, rootDescription)
    owner.ShouldShowTooltip = nop
    local layoutName = FalconSettings:GetActiveLayout()
    local fontSettings = FalconAddOnDB.Settings[layoutName].FontSettings
    local fallbackPath = LibSharedMedia:Fetch('font', defaultTableData.FontSettings.Name)

    rootDescription:CreateTitle('General')

    rootDescription:CreateCheckbox('Hide speed text',
      function() return fontSettings.Hide end,
      function()
        local newValue = not fontSettings.Hide
        fontSettings.Hide = newValue
        MutableData.HideDisplayText = newValue
        if newValue then
          Falcon.TextDisplay:Hide()
        else
          Falcon.TextDisplay:Show()
        end
      end
    )

    rootDescription:CreateSpacer()
    rootDescription:CreateTitle('Justify Position')

    local justifyOptions = { 'LEFT', 'CENTER', 'RIGHT' }
    for _, justification in ipairs(justifyOptions) do
      rootDescription:CreateCheckbox(justification:sub(1, 1) .. justification:sub(2):lower(),
        function()
        return fontSettings.Position.Justify == justification end,
        function()
          fontSettings.Position.Justify = justification
          Falcon.TextDisplay.Text:SetJustifyH(justification)
        end
      )
    end

    rootDescription:CreateSpacer()
    rootDescription:CreateTitle('Appearance')

    local function GetFlagsString(bitfield)
      local flags = {}
      if bit.band(bitfield, F.Font.MONOCHROME) ~= 0 then table.insert(flags, 'MONOCHROME') end
      if bit.band(bitfield, F.Font.OUTLINE) ~= 0 then table.insert(flags, 'OUTLINE') end
      if bit.band(bitfield, F.Font.THICKOUTLINE) ~= 0 then table.insert(flags, 'THICKOUTLINE') end
      if bit.band(bitfield, F.Font.SLUG) ~= 0 then table.insert(flags, 'SLUG') end
      return table.concat(flags, ', ')
    end

    local function GetBitfieldFromString(str)
      local field = 0
      if not str or str == '' then return field end
      for flag in str:gmatch('([^,%s]+)') do
        local upper = flag:upper()
        if F.Font[upper] then
          field = bit.bor(field, F.Font[upper])
        end
      end
      return field
    end

    local currentBitfield = GetBitfieldFromString(fontSettings.Flags)

    local flagOrder = {
      { label = 'Monochrome', mask = F.Font.MONOCHROME },
      { label = 'Outline', mask = F.Font.OUTLINE, exclude = F.Font.THICKOUTLINE },
      { label = 'Thick Outline', mask = F.Font.THICKOUTLINE, exclude = F.Font.OUTLINE },
      { label = 'Slug', mask = F.Font.SLUG },
    }

    for _, opt in ipairs(flagOrder) do
      rootDescription:CreateCheckbox(opt.label,
        function() return bit.band(currentBitfield, opt.mask) ~= 0 end,
        function()
          if bit.band(currentBitfield, opt.mask) ~= 0 then
            currentBitfield = bit.band(currentBitfield, bit.bnot(opt.mask))
          else
            currentBitfield = bit.bor(currentBitfield, opt.mask)
            if opt.exclude then
              currentBitfield = bit.band(currentBitfield, bit.bnot(opt.exclude))
            end
          end
          fontSettings.Flags = GetFlagsString(currentBitfield)
          MutableData.Flags = fontSettings.Flags
          local fontPath = LibSharedMedia:Fetch('font', fontSettings.Name, true) or fallbackPath
          Falcon.TextDisplay.Text:SetFont(fontPath, fontSettings.Size, fontSettings.Flags)
        end
      )
    end

    rootDescription:CreateSpacer()
    rootDescription:CreateTitle('Fonts')
    rootDescription:SetScrollMode(400)

    for _, fontName in ipairs(LibSharedMedia:List('font')) do
      local fontDesc = rootDescription:CreateCheckbox(fontName,
        function() return fontSettings.Name == fontName end,
        function()
          fontSettings.Name = fontName
          MutableData.Name = fontName
          local fontPath = LibSharedMedia:Fetch('font', fontName, true) or fallbackPath
          Falcon.TextDisplay.Text:SetFont(fontPath, fontSettings.Size, fontSettings.Flags)
        end
      )

      fontDesc:AddInitializer(function(button)
        local fs = button.fontString or button.Text
        local fontPath = LibSharedMedia:Fetch('font', fontName, true) or fallbackPath
        if fontPath and fs then
          local objName = 'FalconFont_' .. fontName:gsub('%s+', '')
          local obj = _G[objName] or CreateFont(objName)
          obj:SetFont(fontPath, 12, '')
          fs:SetFontObject(obj)
        end
      end)
    end
  end,
  },
  {
  name = 'Bar Settings',
  kind = LEM.SettingType.Dropdown,
  default = 0,
  set = function(layoutName, value)
    local activeLayout = FalconSettings:GetActiveLayout()
    FalconAddOnDB.Settings[activeLayout].BarBehaviourFlags = value
    FalconAddOnDB.Settings[activeLayout].General.ApplySpeedBarColorsToChargeBar = false
    FalconSettings.BarBehaviourFlagsDropdown:GenerateMenu()
    Falcon:UpdateUI()
  end,
  generator = function(owner, rootDescription)
    FalconSettings.BarBehaviourFlagsDropdown = owner
    owner.ShouldShowTooltip = nop
    local activeLayout = FalconSettings:GetActiveLayout()
    FalconMenuUtil:RemoveDefaultText(owner)

    rootDescription:CreateTitle('General')
    rootDescription:CreateCheckbox('Apply Speed Bar Colors to Charges',
      function()
        return FalconAddOnDB.Settings[activeLayout].General.ApplySpeedBarColorsToChargeBar
      end,
      function()
        local newValue = not FalconAddOnDB.Settings[activeLayout].General.ApplySpeedBarColorsToChargeBar
        FalconAddOnDB.Settings[FalconSettings:GetActiveLayout()].General.ApplySpeedBarColorsToChargeBar = newValue
        MutableData.ApplySpeedBarColorsToChargeBar = newValue
        for i = 1, math.max(1, Falcon.num_charges) do
          local color
          if i >= Falcon.num_charges - 1 then
            color = MutableData.StatusBarColors.SecondWind
          elseif i <= Falcon.num_charges / 2 then
            color = MutableData.ApplySpeedBarColorsToChargeBar and MutableData.StatusBarColors.Thrill or MutableData.StatusBarColors.Charge
          else
            color = MutableData.StatusBarColors.Charge
          end
          Falcon.ChargeBars[i]:SetStatusBarColor(color.r, color.g, color.b, color.a)
        end
        Falcon:UpdateUI()
      end
    )

    local getFunc = function(mask)
      local currentFlags = FalconAddOnDB.Settings[activeLayout].BarBehaviourFlags
      return FlagsUtil.IsAnySet(currentFlags, mask)
    end

    local function updateFlags(current, mask, groupMask)
      if bit.band(current, mask) ~= 0 then
        return bit.band(current, bit.bnot(mask))
      end
      return bit.bor(bit.band(current, bit.bnot(groupMask)), mask)
    end

    local setFunc = function(mask)
      local settings = FalconAddOnDB.Settings[activeLayout]
      local current = settings.BarBehaviourFlags

      local visMask = bit.bor(F.BarBehaviour.HIDE_CHARGES, F.BarBehaviour.HIDE_SPEED)
      local condMask = bit.bor(F.BarBehaviour.HIDE_GROUNDED, F.BarBehaviour.HIDE_FULL_GROUNDED)

      if bit.band(mask, visMask) ~= 0 then
        settings.BarBehaviourFlags = updateFlags(current, mask, mask)
      else
        settings.BarBehaviourFlags = updateFlags(current, mask, condMask)
      end
      Falcon:UpdateUISizes(nil, nil, nil, nil, nil, settings.BarBehaviourFlags)
    end

    rootDescription:CreateSpacer()
    rootDescription:CreateTitle('Visibility')
    for i, option in ipairs(BARBEHAVIOUR_OPTION_LIST) do
      if i == 3 then
        rootDescription:CreateSpacer()
        rootDescription:CreateTitle('Conditional')
      end

      local checkbox = rootDescription:CreateCheckbox(option.state, getFunc, setFunc, option.id)

      if option.requirementMask then
        checkbox:SetEnabled(function(self)
          local isEnabled = getFunc(option.requirementMask)
          return isEnabled
        end)
      end
    end
  end,
  },
  {
    name = 'Mute Sounds',
    kind = LEM.SettingType.Dropdown,
    default = 0,
    set = function()
      FalconSettings:ResetSounds()
    end,
    generator = function(owner, rootDescription)
      FalconSettings.SoundsDropdown = owner
      owner.ShouldShowTooltip = nop
      FalconMenuUtil:RemoveDefaultText(owner)
      local getFunc = function(value)
        return FalconSettings:IsSoundChecked(value)
      end
      local setFunc = function(value)
        FalconSettings:SetSoundChecked(value)
      end

      rootDescription:CreateTitle('Skyriding Sounds');
      for i, option in ipairs(SOUND_OPTIONS) do
        if option.key and not option.mountID then
          rootDescription:CreateCheckbox(option.name, getFunc, setFunc, option.id)
        end
      end
      local dividerAndTitleCreated = false
      local function CreateDividerAndTitle()
        if not dividerAndTitleCreated then
          rootDescription:CreateSpacer();
          rootDescription:CreateTitle('Mount Sounds');
          dividerAndTitleCreated = true
        end
      end
        for i, option in ipairs(SOUND_OPTIONS) do
          if option.key and option.mountID then
            local isCollected = select(11,C_MountJournal.GetMountInfoByID(option.mountID))
            if isCollected then
              CreateDividerAndTitle()
              rootDescription:CreateCheckbox(option.name, getFunc, setFunc, option.id)
            end
          end
        end
    end,
  },
  {
    name = 'Second Wind',
    kind = LEM.SettingType.Dropdown,
    default = 1,
    set = function(layoutName, value)
      FalconAddOnDB.Settings['FalconGlobalSettings'].secondWindMode = value
      MutableData.secondWindMode = value
      FalconSettings.SecondWindDropdown:GenerateMenu()
      Falcon:UpdateUI()
    end,
    generator = function(owner, rootDescription)
      FalconSettings.SecondWindDropdown = owner
      owner.ShouldShowTooltip = nop
      local getFunc = function(value)
          return FalconAddOnDB.Settings['FalconGlobalSettings'].secondWindMode == value
      end
      local setFunc = function(value)
        FalconAddOnDB.Settings['FalconGlobalSettings'].secondWindMode = value
        MutableData.secondWindMode = value
        Falcon:UpdateUI()
      end

      for _, option in ipairs(SECOND_WIND_OPTIONS_LIST) do
        if option.state then
          rootDescription:CreateCheckbox(option.state, getFunc, setFunc, option.id)
        end
      end
    end,
  },
  {
    name = 'Whirling Surge',
    kind = LEM.SettingType.Dropdown,
    default = 1,
    set = function(layoutName, value)
      local layoutName = FalconSettings:GetActiveLayout()
      FalconAddOnDB.Settings[layoutName].BuffSettings.Visibility = defaultTableData.BuffSettings.Visibility
      MutableData.BuffVisibility = defaultTableData.BuffSettings.Visibility

      FalconAddOnDB.Settings[layoutName].BuffSettings.Anchor = defaultTableData.BuffSettings.Anchor
      Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[layoutName])
    end,
    generator = function(owner, rootDescription)
      FalconSettings.WhirlingSurgeDropdown = owner
      owner.ShouldShowTooltip = nop

      local getFuncState = function(value)
        local layoutName = FalconSettings:GetActiveLayout()
        return FalconAddOnDB.Settings[layoutName].BuffSettings.Visibility == value
      end

      local setFuncState = function(value)
        local layoutName = FalconSettings:GetActiveLayout()
        FalconAddOnDB.Settings[layoutName].BuffSettings.Visibility = value
        MutableData.BuffVisibility = value
        if value == 3 then
          Falcon.WhirlingSurge:Hide()
        else
          Falcon.WhirlingSurge:Show()
        end
      end

      rootDescription:CreateTitle('Visibility')
      for _, option in ipairs(WHIRLING_SURGE_OPTIONS_SHOWNSTATE_LIST) do
        if option.state then
          rootDescription:CreateCheckbox(option.state, getFuncState, setFuncState, option.id)
        end
      end
      rootDescription:CreateSpacer()
      rootDescription:CreateTitle('Anchor')

      local getFuncAnchor = function(pointName)
        local layoutName = FalconSettings:GetActiveLayout()
        return FalconAddOnDB.Settings[layoutName].BuffSettings.Anchor == pointName
      end

      local setFuncAnchor = function(pointName)
        local layoutName = FalconSettings:GetActiveLayout()
        FalconAddOnDB.Settings[layoutName].BuffSettings.Anchor = pointName
        MutableData.BuffAnchor = pointName
        Falcon:UpdateBuffAnchor(FalconAddOnDB.Settings[layoutName])
      end

      local anchorOrder = {
        'Top Left', 'Top', 'Top Right',
        'Left', 'Right',
        'Bottom Left', 'Bottom', 'Bottom Right'
      }

      for _, pointName in ipairs(anchorOrder) do
        rootDescription:CreateCheckbox(pointName, getFuncAnchor, setFuncAnchor, pointName)
      end
    end,
  },
    {
    name = 'Whirling Surge Size',
    kind = LEM.SettingType.Slider,
    default = defaultTableData.BuffSettings.Size,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      return FalconAddOnDB.Settings[layoutName].BuffSettings.Size
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      FalconAddOnDB.Settings[layoutName].BuffSettings.Size = value
      MutableData.BuffSettings.Size = value
      Falcon:UpdateUISizes()
    end,
    minValue = 12,
    maxValue = 128,
    valueStep = 1,
    formatter = function(value)
      return value
    end,
  },
  {
    name = 'Hide when grounded and fully charged',
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      return FalconAddOnDB.Settings[layoutName].hideWhenGroundedAndFull
    end,
    set = function(layoutName, value)
      layoutName = FalconSettings:GetCurrentLayoutName(layoutName)
      FalconAddOnDB.Settings[layoutName].hideWhenGroundedAndFull = value
      MutableData.hideWhenGroundedAndFull = value
    end,
  },
  {
    name = 'Disable Skyriding game effects',
    kind = LEM.SettingType.Checkbox,
    default = false,
    get = function(layoutName)
      return not C_CVar.GetCVarBool('AdvFlyingDynamicFOVEnabled') and not C_CVar.GetCVarBool('DriveDynamicFOVEnabled')
    end,
    set = function(layoutName, value)
      SetCVar('AdvFlyingDynamicFOVEnabled', not value)
      SetCVar('DriveDynamicFOVEnabled', not value)

      local settingEffects = Settings.GetSetting('DisableAdvancedFlyingFullScreenEffects')
      if settingEffects then
        settingEffects:ApplyValue(not value)
      end

      local settingVFX = Settings.GetSetting('DisableAdvancedFlyingVelocityVFX')
      if settingVFX then
        settingVFX:ApplyValue(not value)
      end
    end,
  },
})

local function SetEditModeSelectionState(alpha, isLabelVisible)
  Falcon.Selection.Center:SetAlpha(alpha)
  if isLabelVisible then
    Falcon.Selection.Label:Show()
  else
    Falcon.Selection.Label:Hide()
  end
end

Falcon.Selection:HookScript('OnLeave', function(self)
  if self.isSelected then
    SetEditModeSelectionState(0, false)
  else
    SetEditModeSelectionState(1, false)
  end
end)

LEM.internal.dialog:HookScript('OnHide', function(self)
  if not Falcon.Selection.isSelected then
    SetEditModeSelectionState(1, false)
  end
end)

LEM:RegisterCallback('enter', function()
  local settings = FalconAddOnDB.Settings[FalconSettings:GetActiveLayout()]
  Falcon.AnimHide:Stop()
  Falcon.SpeedBar:SetScript('OnUpdate', nil)
  Falcon:SetScript('OnUpdate', nil)
  Falcon.SpeedBar:SetValue(0.65)
  Falcon.SpeedBar:SetAlpha(1)
  Falcon.SpeedBar.tick:Show()
  Falcon.TextDisplay.AnimShow:Play()
  Falcon.TextDisplay.Text:SetText(' 456 ')
  if FalconAddOnDB.Settings[FalconSettings:GetActiveLayout()].BuffSettings.Visibility == 3 then
    Falcon.WhirlingSurge:Hide()
  else
    Falcon.WhirlingSurge:Show()
  end

  local colors = MutableData.StatusBarColors
  local speedBarColor

  if MutableData.IsThrill then
    speedBarColor = colors.Thrill
  elseif MutableData.IsGroundSkimming then
    speedBarColor = colors.GroundSkimming
  else
    speedBarColor = colors.LowSpeed
  end

  local chargeBarColor = MutableData.ApplySpeedBarColorsToChargeBar and speedBarColor or colors.Charge
  Falcon.SpeedBar:SetStatusBarColor(speedBarColor.r, speedBarColor.g, speedBarColor.b, speedBarColor.a)

  local num = Falcon.num_charges
  local maxIndex = math.max(1, num)

  for i = 1, maxIndex do
    local color = colors.Charge
    local chargeVal = 0
    local secondWindVal = 0
    if i == num then
      chargeVal = 0
      secondWindVal = 0
    elseif i == num - 1 or i == num - 2 then
      color = colors.SecondWind
      chargeVal = 0
      secondWindVal = 1
    elseif i <= num / 2 then
      color = chargeBarColor
      chargeVal = 1
      secondWindVal = 0
    else
      chargeVal = 1
      secondWindVal = 0
    end

    local bar = Falcon.ChargeBars[i]
    bar:SetMinMaxValues(0, 1)
    bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    bar:SetValue(chargeVal)
    Falcon.SecondWindBars[i]:SetValue(secondWindVal)
  end

  Falcon.Selection:ClearAllPoints()
  Falcon.Selection:SetPoint('TOPLEFT', Falcon, 'TOPLEFT', -5, 5)
	Falcon.Selection:SetPoint('BOTTOMRIGHT', Falcon, 'BOTTOMRIGHT', 5, -5)
  Falcon:SetAlpha(1)
  Falcon:Show()
end)

LEM:RegisterCallback('exit', function()
  if not API:IsSkyriding() or ((C_Secrets and C_Secrets.ShouldSpellAuraBeSecret(369968))) then
    Falcon:SetAlpha(0)
    Falcon:Hide()
  end
  Falcon.TextDisplay.AnimHide:Play()
  Falcon.TextDisplay.Text:SetText('')
  Falcon.SpeedBar:SetValue(0)
  Falcon.SpeedBar.tick:Hide()
  Falcon:UpdateUI('ACTIONBAR_UPDATE_COOLDOWN')
  API:FixPosition(Falcon)
end)

LEM:RegisterCallback('create', function(layoutName, _, sourceLayoutName)
  if sourceLayoutName and FalconAddOnDB.Settings[sourceLayoutName] then
    FalconAddOnDB.Settings[layoutName] = CopyTable(FalconAddOnDB.Settings[sourceLayoutName])
  end
end)

LEM:RegisterCallback('layout', function(layoutName)
  FalconSettings:SetupLayout(layoutName)
end)

LEM:RegisterCallback('rename', function(layoutName, newLayoutName)
  FalconAddOnDB.Settings[newLayoutName] = CopyTable(FalconAddOnDB.Settings[layoutName])
  FalconAddOnDB.Settings[layoutName] = nil
  FalconSettings:SetupLayout(newLayoutName)
end)

LEM:RegisterCallback('delete', function(layoutName)
  FalconAddOnDB.Settings[layoutName] = nil
end)

hooksecurefunc(UIParent, 'SetScale', function()
  -- ElvUI and and whatever other addons may not trigger UI_SCALE_CHANGED when changing scale
  Falcon:UpdateUISizes()
  API:FixPosition(Falcon)
end)

function FalconSettings:OnEvent(e, ...)
  if e == 'PLAYER_LOGIN' then
    self:RegisterEvent('DISPLAY_SIZE_CHANGED')
  end
  Falcon:UpdateUISizes()
  StartFixPosition()
end

function FalconSettings:OnLoad()
  self:SetScript('OnEvent', self.OnEvent)
  self:RegisterEvent('PLAYER_LOGIN')
end

FalconSettings:OnLoad()

SLASH_FALCON1 = '/FALCON'
function SlashCmdList.FALCON(msg)
  print('To access Falcon setting press Escape and click on Edit Mode, then click on the Falcon UI')
end

---@class FalconPublicAPI
FalconPublicAPI = {}

---@param profileKey string
function FalconPublicAPI:Export(profileKey)
  if not FalconAddOnDB.Settings[profileKey] then return end
  local data = {
    FalconGlobalSettingsEnabled = FalconAddOnDB.FalconGlobalSettingsEnabled,
    profile = FalconAddOnDB.Settings[profileKey]
  }
  local profileString = C_EncodingUtil.EncodeBase64(C_EncodingUtil.SerializeCBOR(data))
  return profileString
end

---@param importString string
---@param profileKey string
function FalconPublicAPI:Import(importString, profileKey)
  local data = C_EncodingUtil.DeserializeCBOR(C_EncodingUtil.DecodeBase64(importString))
  if not data and data.profile then return end
  if profileKey == 'FalconGlobalSettings' then
    FalconAddOnDB.FalconGlobalSettingsEnabled = data.FalconGlobalSettingsEnabled
  end
  local layoutName = FalconSettings:GetActiveLayout()
  UpdateTable(data.profile, defaultTableData)
  FalconAddOnDB.Settings[layoutName] = data.profile
  FalconSettings:SetupLayout(layoutName)
  LEM:RefreshFrameSettings(Falcon)
end