local ns = select(2,...) ---@class (partial) namespace
---@class SkyAPI
local API = {}
ns.API = API

---@class AdvFlying
---@field Enabled boolean
---@field IsFlying boolean
---@field ForwardSpeed number
---@field IsRacing boolean
local AdvFlying = {
  Enabled = false,
  IsFlying = false,
  ForwardSpeed = 0.0,
  IsRacing = false,
}

---@type table<integer, boolean>
local instances = {
  [2444] = true, -- Dragon Isles
  [2454] = true, -- Zaralek Cavern
  [2516] = true, -- Nokhud Offensive
  [2522] = true, -- Vault of the Incarnates
  [2548] = true, -- Emerald Dream
  [2569] = true, -- Aberrus, the Shadowed Crucible
}

local GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

local function RefreshGlidingInfo()
  local isGliding, canGlide, forwardSpeed = GetGlidingInfo()
  AdvFlying.Enabled = canGlide
  AdvFlying.IsFlying = isGliding
  AdvFlying.ForwardSpeed = forwardSpeed
end

---@return boolean IsCharging
---@return number currentCharges
---@return number maxCharges
---@return number cooldownStartTime
---@return number cooldownDuration
---@return number chargeModRate
---@return boolean IsThrill
---@return boolean IsGroundSkimming
function API:GetSharedInfo()
  local data = C_Spell.GetSpellCharges(372608)
  if not data then return false, 0, 0, 0, 0, 0, false, false end
  return  data.currentCharges < data.maxCharges,
          data.currentCharges,
          data.maxCharges,
          data.cooldownStartTime,
          data.cooldownDuration,
          data.chargeModRate,
          data.cooldownDuration <= 6.003, -- 10.35 base -42%
          data.cooldownDuration == 8.28
end

---@return boolean IsCharging
---@return number currentCharges
---@return number maxCharges
---@return number cooldownStartTime
---@return number cooldownDuration
---@return number chargeModRate
function API:GetSecondWindInfo()
  local data = C_Spell.GetSpellCharges(425782)
  if not data then return false, 0, 0, 0, 0, 0 end
  return  data.currentCharges < data.maxCharges,
          data.currentCharges,
          data.maxCharges,
          data.cooldownStartTime,
          data.cooldownDuration,
          data.chargeModRate
end

---@return number startTime
---@return number duration
---@return boolean isEnabled
---@return number modRate
---@return number? activeCategory
function API:GetWhirlingSurgeInfo()
  local data = C_Spell.GetSpellCooldown(361584)
  if not data then return 0, 0, false, 0, nil end
  return  data.startTime,
          data.duration,
          data.isEnabled,
          data.modRate,
          data.activeCategory
end

---@return boolean Enabled
function API:IsAdvFlyingEnabled()
  RefreshGlidingInfo()
  return AdvFlying.Enabled
end

---@return boolean IsFlying
function API:IsAdvFlying()
  RefreshGlidingInfo()
  return AdvFlying.IsFlying
end

---@return number ForwardSpeed
function API:GetAdvFlyingForwardSpeed()
  RefreshGlidingInfo()
  return AdvFlying.ForwardSpeed
end

---@return boolean
function API:IsSkyriding()
  -- Works for everything that uses the bar, but not 'special' integrations that do not use this bar like Derby racing.
  local hasSkyridingBar = (GetBonusBarIndex() == 11 and GetBonusBarOffset() == 5)
  if hasSkyridingBar then
    return true
  else
    -- 650 is Derby racing
    local powerBarID = UnitPowerBarID('player')
    return hasSkyridingBar or (self:IsAdvFlyingEnabled() and powerBarID ~= 0);
  end
end

---@return boolean
function API:IsDerbyRacing()
  return UnitPowerBarID('player') == 650
end

---@return boolean IsRacing
function API:IsRacing()
  return AdvFlying.IsRacing
end

---@return number Reciporal
function API:GetRidingAbroadReciprocal()
  -- Dragonriding Races, but do not apply to Derby Racing
  if AdvFlying.IsRacing then
    return 0.01
  end

  local instanceID = select(8, GetInstanceInfo())
  if instanceID and instances[instanceID] then
    return 0.01
  else
    return 0.011764
  end
end

---@return boolean
function API:HasRaceQuest()
  -- There might be situations where Bronze Timetoken is 'bugged' and remains in your inventory,
  -- so we need to check quest too, but never iterate quests to find attached item if no token found.
  if C_Item.GetItemCount(191140) == 0 then return false end

  local numEntries = C_QuestLog.GetNumQuestLogEntries()
  for i = 1, numEntries do
    local info = C_QuestLog.GetInfo(i)
    if info and not info.isHeader then
      local questLogIndex = i
      local link = GetQuestLogSpecialItemInfo(questLogIndex)
      if link then
        if C_Item.GetItemIDForItemInfo(link) == 191140 then
          return true
        end
      end
    end
  end
  return false
end

do
  local eventFrame = CreateFrame('frame')
  function eventFrame:OnEvent(e, ...)
    local hasRaceQuest = API:HasRaceQuest()
    if hasRaceQuest then
      AdvFlying.IsRacing = true
    else
      AdvFlying.IsRacing = false
    end
  end

  eventFrame:SetScript('OnEvent', eventFrame.OnEvent)
  eventFrame:RegisterEvent('PLAYER_LOGIN')
  eventFrame:RegisterEvent('CLIENT_SCENE_OPENED')
  eventFrame:RegisterEvent('CLIENT_SCENE_CLOSED')
end

local function NormalizePosition(frame)
  -- from LibWindow-1.1
  local parent = frame:GetParent()
  if not parent then
    return
  end

  local scale = frame:GetScale()
  if not scale then
    return
  end

  local left = frame:GetLeft() * scale
  local top = frame:GetTop() * scale
  local right = frame:GetRight() * scale
  local bottom = frame:GetBottom() * scale

  local parentWidth, parentHeight = parent:GetSize()

  local x, y, point
  if left < (parentWidth - right) and left < math.abs((left + right) / 2 - parentWidth / 2) then
    x = left
    point = 'LEFT'
  elseif (parentWidth - right) < math.abs((left + right) / 2 - parentWidth / 2) then
    x = right - parentWidth
    point = 'RIGHT'
  else
    x = (left + right) / 2 - parentWidth / 2
    point = ''
  end

  if bottom < (parentHeight - top) and bottom < math.abs((bottom + top) / 2 - parentHeight / 2) then
    y = bottom
    point = 'BOTTOM' .. point
  elseif (parentHeight - top) < math.abs((bottom + top) / 2 - parentHeight / 2) then
    y = top - parentHeight
    point = 'TOP' .. point
  else
    y = (bottom + top) / 2 - parentHeight / 2
    point = '' .. point
  end

  if point == '' then
    point = 'CENTER'
  end

  return point, x / scale, y / scale
end

function API:FixPosition(frame)
  local scale = frame:GetScale()
  local uiScale = UIParent:GetScale()
  local x = frame:GetLeft()
  local y = frame:GetTop()
  local point = 'TOPLEFT'
  y = -((UIParent:GetHeight() - y * scale) / scale);
  frame:ClearAllPoints()
  frame:SetPoint(point, UIParent, point, PixelUtil.GetNearestPixelSize(x, uiScale) , PixelUtil.GetNearestPixelSize(y, uiScale))
  point, x, y = NormalizePosition(frame)
  frame:ClearAllPoints()
  frame:SetPoint(point, UIParent, point, x, y)
  return point, x, y
end

-- Animations
---@alias APIAnimationType 'Alpha' | 'Scale'

---@class AnimationConfig
---@field type APIAnimationType
---@field duration? number
---@field smoothing? SmoothingType
---@field order? number
---@field childKey? string
---@field endDelay? number
---@field startDelay? number
---@field fromAlpha? number
---@field toAlpha? number
---@field fromScaleX? number
---@field fromScaleY? number
---@field toScaleX? number
---@field toScaleY? number

---@class AnimationGroupConfig
---@field looping? LoopType
---@field onFinished? function
---@field onPlay? function
---@field onStop? function
---@field onUpdate? function
---@field setToFinalAlpha? boolean
---@field animations? AnimationConfig[]

---@param anim Animation
---@param config AnimationConfig
local function ApplyAnimationProperties(anim, config)
  if config.type == 'Alpha' then
    ---@cast anim Alpha
    if config.fromAlpha ~= nil then anim:SetFromAlpha(config.fromAlpha) end
    if config.toAlpha ~= nil then anim:SetToAlpha(config.toAlpha) end
  elseif config.type == 'Scale' then
    ---@cast anim Scale
    if config.fromScaleX ~= nil and config.fromScaleY ~= nil then anim:SetScaleFrom(config.fromScaleX, config.fromScaleY) end
    if config.toScaleX ~= nil and config.toScaleY ~= nil then anim:SetScaleTo(config.toScaleX, config.toScaleY) end
  end

  if config.duration then
    anim:SetDuration(config.duration)
  end

  if config.smoothing then
    anim:SetSmoothing(config.smoothing)
  end

  if config.order then
    anim:SetOrder(config.order)
  end

  if config.childKey then
    anim:SetChildKey(config.childKey)
  end

  if config.endDelay then
    anim:SetEndDelay(config.endDelay)
  end

  if config.startDelay then
    anim:SetStartDelay(config.startDelay)
  end
end

---@param parentFrame Frame|SimpleTexture
---@param config AnimationGroupConfig
---@return SimpleAnimGroup
function API:CreateAnimationGroupFromConfig(parentFrame, config)
  ---@type AnimationGroup
  local animGroup = parentFrame:CreateAnimationGroup()

  if config.looping then
    animGroup:SetLooping(config.looping)
  end

  if config.onFinished then
    animGroup:SetScript('OnFinished', config.onFinished)
  end

  if config.onPlay then
    animGroup:SetScript('OnPlay', config.onPlay)
  end

  if config.onStop then
    animGroup:SetScript('OnStop', config.onStop)
  end

  if config.onUpdate then
    animGroup:SetScript('OnUpdate', config.onUpdate)
  end

  if config.setToFinalAlpha ~= nil then
    animGroup:SetToFinalAlpha(config.setToFinalAlpha)
  end

  for _, animConfig in ipairs(config.animations or {}) do
    local anim = animGroup:CreateAnimation(animConfig.type)
    ApplyAnimationProperties(anim, animConfig)
  end

  return animGroup
end