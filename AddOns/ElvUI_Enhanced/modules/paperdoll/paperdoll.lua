local E, L, V, P, G = unpack(ElvUI); 
local PD = E:NewModule('PaperDoll', 'AceEvent-3.0', 'AceTimer-3.0');

local find = string.find
local initialized = false
local originalInspectFrameUpdateTabs
local updateTimer

local slots = {
  ["HeadSlot"] = { true, true },
  ["NeckSlot"] = { true, false },
  ["ShoulderSlot"] = { true, true },
  ["BackSlot"] = { true, false },
  ["ChestSlot"] = { true, true },
  ["WristSlot"] = { true, true },
  ["MainHandSlot"] = { true, true },
  ["SecondaryHandSlot"] = { true, true },
  ["HandsSlot"] = { true, true },
  ["WaistSlot"] = { true, true },
  ["LegsSlot"] = { true, true },
  ["FeetSlot"] = { true, true },
  ["Finger0Slot"] = { true, false },
  ["Finger1Slot"] = { true, false },
  ["Trinket0Slot"] = { true, false },
  ["Trinket1Slot"] = { true, false },
}

local levelColors = {
  [0] = "|cffff0000",
  [1] = "|cff00ff00",
  [2] = "|cffffff88",
}

-- From http://www.wowhead.com/items?filter=qu=7;sl=16:18:5:8:11:10:1:23:7:21:2:22:13:24:15:28:14:4:3:19:25:12:17:6:9;minle=1;maxle=1;cr=166;crs=3;crv=0
local heirlooms = {
  [80] = {
    44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,
    50255,44103,44107,44095,44098,44097,44105,42951,48683,48685,
    42949,48687,42984,44100,44101,44092,48718,44091,42952,48689,
    44099,42991,42985,48691,44094,44093,42945,48716
  },
  ["90h"] = {105689,105683,105686,105687,105688,105685,105690,105691,105684,105692,105693},
  ["90n"] = {104399,104400,104401,104402,104403,104404,104405,104406,104407,104408,104409},
  ["90f"] = {105675,105670,105672,105671,105674,105673,105676,105677,105678,105679,105680},

}

function PD:UpdatePaperDoll(inspect)
  if not initialized then return end

  if InCombatLockdown() then
    PD:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdatePaperDoll", inspect)
    return
  else
    PD:UnregisterEvent("PLAYER_REGEN_ENABLED")
  end

  local unit = (inspect and InspectFrame) and InspectFrame.unit or "player"
  if not unit then return end
  if unit and not CanInspect(unit, false) then return end

  local frame, slot, current, maximum, r, g, b
  local baseName = inspect and "Inspect" or "Character"
  local itemLink, itemLevel, itemLevelMax
  local avgItemLevel, avgEquipItemLevel = GetAverageItemLevel()

  for k, info in pairs(slots) do
    frame = _G[("%s%s"):format(baseName, k)]
    slot = GetInventorySlotInfo(k)
    if info[1] then
      frame.ItemLevel:SetText()
      if E.db.eel.paperdoll.itemlevel.enable and info[1] then
        itemLink = GetInventoryItemLink(unit, slot)

        if itemLink then
          if ((slot == 16 or slot == 17) and GetInventoryItemQuality(unit, slot) == LE_ITEM_QUALITY_ARTIFACT) then
            local itemLevelMainHand = 0
            local itemLevelOffHand = 0
            local itemLinkMainHand = GetInventoryItemLink(unit, 16)
            local itemLinkOffhand = GetInventoryItemLink(unit, 17)
            if itemLinkMainHand then itemLevelMainHand = self:GetItemLevel(unit, 16 or 0) end
            if itemLinkOffhand then itemLevelOffHand = self:GetItemLevel(unit, 17 or 0) end
            itemLevel = math.max(itemLevelMainHand or 0, itemLevelOffHand or 0)
          else
            itemLevel = self:GetItemLevel(unit, slot)
          end
          if itemLevel and avgEquipItemLevel then
            frame.ItemLevel:SetFormattedText("%s%d|r", levelColors[(itemLevel < avgEquipItemLevel-10 and 0 or (itemLevel > avgEquipItemLevel + 10 and 1 or (2)))], itemLevel)
          end
        end
      end
    end

    if not inspect and info[2] then
      frame.DurabilityInfo:SetText()
      if  E.db.eel.paperdoll.durability.enable then
        current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and (not E.db.eel.paperdoll.durability.onlydamaged or current < maximum) then
          r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
          frame.DurabilityInfo:SetFormattedText("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100)
        end
      end
    end
  end
end

function PD:DelayUpdateInfo(inspect)
  if (updateTimer == 0 or PD:TimeLeft(updateTimer) == 0) then
  	updateTimer = PD:ScheduleTimer("UpdatePaperDoll", .5, inspect)
  end
end

-- from http://www.wowinterface.com/forums/showthread.php?p=284771 by PhanX
-- Construct your saarch pattern based on the existing global string:
--  local S_UPGRADE_LEVEL   = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")
local S_ITEM_LEVEL      = "^" .. gsub(ITEM_LEVEL, "%%d", "(%%d+)")

-- Create the tooltip:
local scantip = CreateFrame("GameTooltip", "MyScanningTooltip", WorldFrame, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

local function GetSlotItemLevel(unit, slot)
  scantip:ClearLines()
  scantip:SetInventoryItem(unit, slot)
  -- Scan the tooltip:
  for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
    local text = _G["MyScanningTooltipTextLeft"..i]:GetText()
    if text and text ~= "" then
      local currentLevel = strmatch(text, S_ITEM_LEVEL)
      if currentLevel then
        return tonumber(currentLevel)
      end
    end
  end
end

local function GetRealItemLevel(itemLink)
  -- Pass the item link to the tooltip:
  scantip:ClearLines()
  scantip:SetHyperlink(itemLink)
  -- Scan the tooltip:
  for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
    local text = _G["MyScanningTooltipTextLeft"..i]:GetText()
    if text and text ~= "" then
      local currentLevel = strmatch(text, S_ITEM_LEVEL)
      if currentLevel then
        return currentLevel
      end
    end
  end
end

function PD:GetItemLevel(unit, slot)
  local itemLink = GetInventoryItemLink(unit, slot)
  local rarity, itemLevel = select(3, GetItemInfo(itemLink))
  if rarity == 7 then -- heirloom adjust
    itemLevel = self:HeirLoomLevel(unit, itemLink)
  end
  itemlevel = GetSlotItemLevel(unit, slot)
  if itemlevel then
    return itemlevel
  else
    itemLevel = GetRealItemLevel(itemLink)
    itemLevel = tonumber(itemLevel)
    return itemLevel
  end
end


function PD:HeirLoomLevel(unit, itemLink)
  local level = UnitLevel(unit)

  if level > 85 then
    local _, _, _, _, itemId = find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
    --print(itemId)
    itemId = tonumber(itemId);
    for _, id in pairs(heirlooms["90h"]) do
      if id == itemId then
        level = 582
        break
      end
    end
    for _, id in pairs(heirlooms["90n"]) do
      if id == itemId then
        level = 569
        break
      end
    end
    for _, id in pairs(heirlooms["90f"]) do
      if id == itemId then
        level = 548
        break
      end
    end

  elseif level > 80 then
    local _, _, _, _, itemId = find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
    --print(itemId)
    itemId = tonumber(itemId);
    for _, id in pairs(heirlooms[80]) do
      if id == itemId then
        level = 80
        break
      end
    end
  end

  if level > 85 then return level
  elseif level > 80 then -- CAT heirloom scaling kicks in at 81
    return (( level - 81) * 12.2) + 272;
  elseif level > 67 then -- WLK heirloom scaling kicks in at 68
    return (( level - 68) * 6) + 130;
  elseif level > 59 then -- TBC heirloom scaling kicks in at 60
    return (( level - 60) * 3) + 85;
  else
    return level
  end
end

function PD:InspectFrame_UpdateTabsComplete()
  originalInspectFrameUpdateTabs()
  PD:DelayUpdateInfo(true)
end

function PD:InitialUpdatePaperDoll()
  self:BuildInfoText("Character")
  PD:ScheduleTimer("UpdatePaperDoll", 2, false)
  initialized = true
  if IsAddOnLoaded("Blizzard_InspectUI") then 
	self:OnAddonLoaded(_, "Blizzard_InspectUI") 
  end
  PD:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function PD:BuildInfoText(name)
  for k, info in pairs(slots) do
    frame = _G[("%s%s"):format(name, k)]

    if info[1] then
      frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
      frame.ItemLevel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
      frame.ItemLevel:FontTemplate(E.media.font, 12, "THINOUTLINE")
    end

    if name == "Character" and info[2] then
      frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
      frame.DurabilityInfo:SetPoint("TOP", frame, "TOP", 0, -4)
      frame.DurabilityInfo:FontTemplate(E.media.font, 12, "THINOUTLINE")
    end
  end
end

function PD:OnAddonLoaded(event, name)
  if ((name ~= "Blizzard_InspectUI") or not initialized) then return end

  self:BuildInfoText("Inspect")

  -- hook to inspect frame update
  originalInspectFrameUpdateTabs = _G.InspectFrame_UpdateTabs
  _G.InspectFrame_UpdateTabs = PD.InspectFrame_UpdateTabsComplete
  
  -- update player info
  PD:DelayUpdateInfo(true)
  PD:UnregisterEvent("ADDON_LOADED")
  
end

function PD:Initialize()
  local frame

  PD:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdatePaperDoll", false)
  PD:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdatePaperDoll", false)
  PD:RegisterEvent("SOCKET_INFO_UPDATE", "UpdatePaperDoll", false)
  PD:RegisterEvent("PLAYER_ENTERING_WORLD", "InitialUpdatePaperDoll")
end

E:RegisterModule(PD:GetName())
