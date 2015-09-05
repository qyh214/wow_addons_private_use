--[[

Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

SpellButton.lua is part of Learning Aid.

  Learning Aid is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  Learning Aid is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with Learning Aid.  If not, see
  <http://www.gnu.org/licenses/>.

To download the latest official version of Learning Aid, please visit 
either Curse or WowInterface at one of the following URLs: 

http://wow.curse.com/downloads/wow-addons/details/learningaid.aspx

http://www.wowinterface.com/downloads/info10622-LearningAid.html

Other sites that host Learning Aid are not official and may contain 
outdated or modified versions. If you have obtained Learning Aid from 
any other source, I strongly encourage you to use Curse or WoWInterface 
for updates in the future. 

]]

local addonName, private = ...
local LA = private.LA
local function hideButton(spellButton, mouseButton, down)
  if not InCombatLockdown() then
    LA:ClearButtonIndex(spellButton.index)
  end
end
local function linkSpell(spellButton, ...)
  if "SPELL" == spellButton.item.Status then
    LA:SpellButton_OnModifiedClick(spellButton, ...)
  end
end
local function toggleIgnore(spellButton, mouseButton, down)
  if "SPELL" == spellButton.item.Status then
    LA:ToggleIgnore(spellButton.item)
    LA:UpdateButton(spellButton)
  end
end
local function toggleFlyout(spellButton, mouseButton, down)
  if not InCombatLockdown() then
  -- SpellFlyout:Toggle(flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip)
    SpellFlyout:Toggle(spellButton.item.ID, spellButton, "LEFT", 1, false);
    SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
  end
end
function LA:CreateButton()
  --[[ if self.state.retalenting then -- DEBUG FIXME
    print("CreateButton called during retalenting!") -- DEBUG FIXME
  end ]]-- DEBUG FIXME
  local buttons = self.buttons
  local count = #buttons
  -- button global variable names start with "SpellButton" to work around an
  -- issue with the Blizzard Feedback Tool used in beta and on the PTR
  local name = "SpellButton_LearningAid_"..(count + 1)
  local button = CreateFrame("CheckButton", name, self.frame, "LearningAidSpellButtonTemplate")
  local background = _G[name.."Background"]
  background:Hide()
  local subSpellName = _G[name.."SubSpellName"]
  subSpellName:SetTextColor(NORMAL_FONT_COLOR.r - 0.1, NORMAL_FONT_COLOR.g - 0.1, NORMAL_FONT_COLOR.b - 0.1)
  buttons[count + 1] = button
  button.index = count + 1
  button:SetAttribute("type3", "hideButton")
  button:SetAttribute("alt-type*", "hideButton")
  button:SetAttribute("shift-type1", "linkSpell")
  button:SetAttribute("ctrl-type*", "toggleIgnore")
  button.hideButton = hideButton
  button.linkSpell = linkSpell
  button.toggleIgnore = toggleIgnore
  button.toggleFlyout = toggleFlyout
  button.iconTexture = _G[name.."IconTexture"]
  button.cooldown = _G[name.."Cooldown"]
  button.spellName = _G[name.."SpellName"]
  button.subSpellName = subSpellName
  return button
end
function LA:AddButton(item)
  assert(item)
  --[[ if self.state.retalenting then -- DEBUG FIXME
    print("AddButton called during retalenting!") -- DEBUG FIXME
  end ]]-- DEBUG FIXME
  -- print("AddButton: "..item.Name) -- DEBUG FIXME
  -- local thing = self.Spell.Global[id] -- could be spell or flyout
  local itemType = strlower(item.Status) -- SPELL or FLYOUT
  assert("spell" == itemType or "flyout" == itemType, "Attempt to add invalid item "..item.ID.." of type "..itemType)
  local buttons = self.buttons
  local visible = self:GetVisible()
  for i = 1, visible do
    if buttons[i].item == item then -- already exists, no action needed
      return
    end
  end
  local button
  -- if bar is full
  if visible == #buttons then
    button = self:CreateButton()
    self:DebugPrint("Adding "..item.Status.." button with id "..item.ID.." to index "..button.index)
  else
  -- if bar has free buttons
    button = buttons[self:GetVisible() + 1]
    self:DebugPrint("Changing button index "..(self:GetVisible() + 1).." from "..button.item.Status.." "..button.item.ID.." to "..item.Status.." "..item.ID)
    button:Show()
  end
  
  button.item = item
  button:SetAttribute("spell*", item.ID)
  
  if "flyout" == itemType then
    button:SetAttribute("flyout*", item.ID)
    button:SetAttribute("type*", "toggleFlyout")
  else
    button:SetAttribute("type*", itemType)
  end
  
  self:SetVisible(visible + 1)
  button:SetChecked(false)
  
  if "spell" == itemType and item.Selected then
    button:SetChecked(true)
  end
  --[[ MOP
  elseif kind == "MOUNT" or kind == "CRITTER" then
    -- button.Companion = name
    local creatureID, creatureName, creatureSpellID, icon, isSummoned = GetCompanionInfo(kind, id)
    if isSummoned then
      button:SetChecked(true)
    end

  else
    self:DebugPrint("AddButton(): Invalid button type "..kind)
  end
  ]]
  self:UpdateButton(button)
  self:AutoSetMaxHeight()
  self.frame:Show()
end
function LA:ClearButtonID(item)
  local buttons = self.buttons
  local i = 1
  -- not using a for loop because self.visible may change during the loop execution
  while i <= self:GetVisible() do
    if buttons[i].item == item then -- buttons[i].kind == kind and 
      self:DebugPrint("Clearing button "..i.." with item "..buttons[i].item.Name)
      self:ClearButtonIndex(i)
    else
      --self:DebugPrint("Button "..i.." has id "..buttons[i]:GetID().." which does not match "..id)
      i = i + 1
    end
  end
end
function LA:SetMaxHeight(newMaxHeight) -- in buttons, not pixels
  self.maxHeight = newMaxHeight
  self:ReshapeFrame()
end
function LA:GetMaxHeight()
  return self.maxHeight
end
function LA:AutoSetMaxHeight()
  local screenHeight = UIParent:GetHeight()
  self:DebugPrint("Screen Height = ".. screenHeight)
  local newMaxHeight = math.floor((UIParent:GetHeight()-self.titleHeight)/(self.buttonSize+self.verticalSpacing) - 3)
  self:DebugPrint("Setting MaxHeight to " .. newMaxHeight)
  self:SetMaxHeight(newMaxHeight)
  return newMaxHeight
end
function LA:ReshapeFrame()
  local newHeight
  local newWidth
  local maxHeight = self.maxHeight
  local visible = self:GetVisible()
  if visible > maxHeight then
    newHeight = maxHeight
    newWidth = math.ceil(visible / maxHeight)
  else
    newHeight = visible
    newWidth = 1
  end
  local frame = self.frame
  frame:SetHeight(self.titleHeight + self.framePadding + (self.buttonSize + self.verticalSpacing) * newHeight)
  frame:SetWidth(self.framePadding + (self.buttonSize + self.horizontalSpacing) * newWidth)
  self.height = newHeight
  self.width = newWidth
  self:ParentButtons()
end
function LA:ParentButtons()
  local buttons = self.buttons
  local visible = self:GetVisible()
  if visible >= 1 then
    buttons[1]:SetPoint("TOPLEFT", self.titleBar, "BOTTOMLEFT", 16, 0)
  end
  for i = 2, visible do
    if i <= self.height then
      buttons[i]:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, -self.verticalSpacing)
    else
      buttons[i]:SetPoint("TOPLEFT", buttons[i-self.height], "TOPRIGHT", self.horizontalSpacing, 0)
    end
  end
end
function LA:ClearButtonIndex(index)
-- I have buttons 1 2 3 (4 5)
-- I remove button 2
-- I want 1 3 (3 4 5)
-- before, visible = 3
-- after, visible = 2
  local frame = self.frame
  local buttons = self.buttons
  local visible = self:GetVisible()
  for i = index, visible - 1 do
    local button = buttons[i]
    local nextButton = buttons[i + 1]
    button.item = nextButton.item
    button:SetAttribute("type*", nextButton:GetAttribute("type*"))
    button:SetChecked(nextButton:GetChecked())
    button.iconTexture:SetVertexColor(nextButton.iconTexture:GetVertexColor())
    local cooldown = button.cooldown
    local nextCooldown = nextButton.cooldown
    cooldown.start = nextCooldown.start
    cooldown.duration = nextCooldown.duration
    cooldown.enable = nextCooldown.enable
    if cooldown.start and cooldown.duration and cooldown.enable then 
      CooldownFrame_SetTimer(cooldown, cooldown.start, cooldown.duration, cooldown.enable)
    else
      cooldown:Hide()
    end
    --if buttons[i]:IsShown() then
    self:UpdateButton(button)
    --end
  end
  buttons[visible]:Hide()
  self:SetVisible(visible - 1)
  self:ReshapeFrame()
end
function LA:SetVisible(visible)
  local frame = self.frame
  self.visible = visible
  local top, left = frame:GetTop(), frame:GetLeft()
  frame:SetHeight(self.titleHeight + 10 + (self.buttonSize + self.verticalSpacing) * visible)
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
  if visible == 0 then
    frame:Hide()
  end
end
function LA:GetVisible()
  return self.visible
end
function LA:Hide()
  if not InCombatLockdown() then
    for i = 1, self:GetVisible() do
      self.buttons[i]:SetChecked(false)
      self.buttons[i]:Hide()
    end
    self:SetVisible(0)
  else
    table.insert(self.queue, { kind = "HIDE" })
  end
end

-- Adapted from SpellBookFrame.lua
function LA:UpdateButton(button)
  --local id = button:GetID()
  local item = button.item
  local name = button:GetName()
  local id = item.ID
  local iconTexture = _G[name.."IconTexture"]
  local spellString = _G[name.."SpellName"]
  local subSpellString = _G[name.."SubSpellName"]
  local cooldown = _G[name.."Cooldown"]
  local autoCastableTexture = _G[name.."AutoCastable"]
  local highlightTexture = _G[name.."Highlight"]
  -- CATA -- local normalTexture = _G[name.."NormalTexture"]
  if not InCombatLockdown() then
    button:Enable()
  end


  local texture = GetSpellBookItemTexture(item.Slot, BOOKTYPE_SPELL);

  -- If no spell, hide everything and return
  if ( not texture or (strlen(texture) == 0) ) then
    iconTexture:Hide()
    spellString:Hide()
    subSpellString:Hide()
    cooldown:Hide()
    autoCastableTexture:Hide()
    SpellBook_ReleaseAutoCastShine(button.shine)
    button.shine = nil
    highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    button:SetChecked(false)
    -- CATA -- normalTexture:SetVertexColor(1.0, 1.0, 1.0)
    return;
  end

  local spellName = item.Name
  local subSpellName = item.SubName

  if "SPELL" == item.Status then
    spellName = item.SpecName
    subSpellName = item.SpecSubName
    local start, duration, enable = GetSpellCooldown(id)
    CooldownFrame_SetTimer(cooldown, start, duration, enable)
    cooldown.start = start
    cooldown.duration = duration
    cooldown.enable = enable
    if ( enable == 1 ) then
      iconTexture:SetVertexColor(1.0, 1.0, 1.0)
    else
      iconTexture:SetVertexColor(0.4, 0.4, 0.4)
    end
  end
  
  -- MOP -- local globalID = select(2, GetSpellBookItemInfo(id, BOOKTYPE_SPELL))

  -- CATA -- normalTexture:SetVertexColor(1.0, 1.0, 1.0)
  highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
  spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

  --Set Secure Action Button attribute
  --if not InCombatLockdown()then
  --  local itemType = strlower(item.Status)
  --  button:SetAttribute(itemType.."*", id) -- spell* or flyout*
  --end

  iconTexture:SetTexture(texture)
  spellString:SetText(spellName)
  subSpellString:SetText(subSpellName)
  if ( spellSubName ~= "" ) then
    spellString:SetPoint("LEFT", button, "RIGHT", 4, 4)
  else
    spellString:SetPoint("LEFT", button, "RIGHT", 4, 2)
  end
  if self:IsIgnored(item) then
    iconTexture:SetVertexColor(0.8, 0.1, 0.1) -- red color cribbed from Bartender4
  end
  iconTexture:Show()
  spellString:Show()
  subSpellString:Show()
  --SpellButton_UpdateSelection(self)
end
function LA:SpellButton_OnDrag(button)
  if not InCombatLockdown() then
    button.item:Pickup()
  end
end
function LA._SpellButton_OnEnter(button)
  LA:SpellButton_OnEnter(button)
end
-- Adapted from SpellBookFrame.lua
function LA:SpellButton_OnEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    if GameTooltip:SetSpellBookItem(button.item.Slot, BOOKTYPE_SPELL) then
      button.UpdateTooltip = LA._SpellButton_OnEnter
    else
      button.UpdateTooltip = nil
    end
    GameTooltip:AddLine("dummy")
    _G["GameTooltipTextLeft"..GameTooltip:NumLines()]:SetText(self:GetText("ctrlToIgnore"))
    GameTooltip:Show()
end
-- Adapted from SpellBookFrame.lua
function LA:SpellButton_UpdateSelection(button)
  if IsSelectedSpellBookItem(button.item.Slot, "BOOKTYPE_SPELL") then
    button:SetChecked(true)
  else
    button:SetChecked(false)
  end
end
-- Adapted from SpellBookFrame.lua and heavily modified
function LA:SpellButton_OnModifiedClick(spellButton, mouseButton)
  local item = spellButton.item
  local itemName = item.SpecName
  local itemSubName = item.SpecSubName
  if IsModifiedClick("CHATLINK") and "SPELL" == spellButton.item.Status then
    if MacroFrame and MacroFrame:IsShown() then
      if not item.Passive then
        if strlen(itemSubName) > 0 then
          ChatEdit_InsertLink(itemName.."("..itemSubName..")")
        else
          ChatEdit_InsertLink(itemName)
        end
      end
    else
      local link = item.SpecLink
      if link then
        ChatEdit_InsertLink(link)
      end
    end
  elseif IsModifiedClick("PICKUPACTION") then
    item:Pickup()
  end
end

function LA:SpellButton_OnHide(button)
  self:DebugPrint("Hiding button "..button.index)
  button:SetChecked(false)
  button.iconTexture:SetVertexColor(1, 1, 1)
  button.cooldown:Hide()
end
function LA:UpdateButtons()
  for i = 1, self:GetVisible() do
    self:UpdateButton(self.buttons[i])
  end
end