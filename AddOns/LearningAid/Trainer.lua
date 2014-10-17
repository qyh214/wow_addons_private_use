--[[

Learning Aid is copyright © 2008-2014 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

Trainer.lua is part of Learning Aid.

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

function LA:CreateTrainAllButton()
  if not self.trainAllButton then
    local button = CreateFrame("Button", "LearningAid_TrainAllButton", ClassTrainerTrainButton, "MagicButtonTemplate")
    button:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT")
    button:SetText(self:GetText("trainAllButton"))
    button:SetScript("OnClick", function() StaticPopup_Show("LEARNING_AID_TRAINER_BUY_ALL") end)
    --button:SetScript("OnShow", function(thisButton) self:GetAvailableTrainerServices() end)
    --button:SetScript("OnHide", function() wipe(self.availableServices) end)
    button:Show()
    self.trainAllButton = button
    StaticPopupDialogs.LEARNING_AID_TRAINER_BUY_ALL = {
       text = self:GetText("trainAllPopup"), -- "Train all skills for"
       button1 = ACCEPT,
       button2 = CANCEL,
       OnAccept = function()
          self:BuyAllTrainerServices(LA.CONFIRM_TRAINER_BUY_ALL)
          button:Disable()
       end,
       OnShow = function(dialog)
         MoneyFrame_Update(dialog.moneyFrame, self.availableServices.cost)
       end,
       hasMoneyFrame = 1,
       --showAlert = 1,
       timeout = 0,
       exclusive = 1,
       hideOnEscape = 1,
       whileDead = false
    }
    hooksecurefunc("ClassTrainerFrame_Update", function() LearningAid:GetAvailableTrainerServices() end)
    return button
  end
end

function LA:GetAvailableTrainerServices()
  local copper = 0
  local services = self.availableServices
  wipe(services)
  for i = 1, GetNumTrainerServices() do
    local t = {} -- omg junk table
    --name (String), subType (String), category (String), texture (String), requiredLevel (Number), topServiceLine (Number)
    t.name, t.subType, t.category, t.texture, t.level, t.topServiceLine = GetTrainerServiceInfo(i)
    t.copper, t.isProfession = GetTrainerServiceCost(i)
    --t.skillLine = GetTrainerServiceSkillLine(i)
    t.index = i
    --t.link = GetTrainerServiceItemLink(i)
    if (t.category == "available") and not t.isProfession then
      copper = copper + t.copper
      table.insert(services, t)
    end
  end
  services.cost = copper
  --self:DebugPrint("Total cost of available services: "..GetCoinText(copper))
  if #services > 0 and copper <= GetMoney() then
    self.trainAllButton:Enable()
  else
    self.trainAllButton:Disable()
  end
  return services
end

function LA:BuyAllTrainerServices(really)
  local services = self.availableServices
  if services and really == LA.CONFIRM_TRAINER_BUY_ALL then
    self.pendingBuyCount = #services
    self:DebugPrint("Buying all "..self.pendingBuyCount.." service(s) for "..services.cost.." copper")
    for i, t in ipairs(services) do
      --if t.category == "available" then
        BuyTrainerService(t.index)
      --end
    end
    --[[
    wipe(services)
    self.learning = false
    local learned = self:FormatSpells(self.spellsLearned)
    if learned then self:SystemPrint(self:GetText("youHaveLearned", learned)) end
    wipe (self.spellsLearned)
    --]]
  end
end

