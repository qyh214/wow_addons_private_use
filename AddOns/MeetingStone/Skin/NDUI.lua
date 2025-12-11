BuildEnv(...)

local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

local once = true
local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
local function eventHandler(self, event, addOnName)
  -- local useWindSkin = Profile:GetUseWindSkin()
  if once and IsAddOnLoaded("NDui") and IsAddOnLoaded("MeetingStone") and NDui --[[and useWindSkin]] then
    C_Timer.After(1.0, function()
      local B, C = NDui[1], NDui[2]
      local function reskinStretchButton(bu)
          bu:SetHeight(28)
          B.Reskin(bu)
          bu.styled = true
      end
      local function reskinGridView(self)
        for _, button in pairs(self.sortButtons) do
          B.StripTextures(button, 0)
          button.Arrow:SetAlpha(1)
          local bg = B.CreateBDFrame(button, .25)
          bg:SetPoint("TOPLEFT", C.mult, C.mult)
          bg:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
        end
      
        local scrollBar = self.GetScrollBar and self:GetScrollBar()
        if scrollBar then
          B.ReskinScroll(scrollBar)
        end
      end

      local NetEaseEnv = LibStub("NetEaseEnv-1.0")
      local NetEaseGUI = LibStub("NetEaseGUI-2.0")
      local MTSAddon = LibStub("AceAddon-3.0"):GetAddon("MeetingStone")
      local MSEnv = NetEaseEnv._NSList[MTSAddon.baseName]
      local BrowsePanel = MSEnv.BrowsePanel

      if BrowsePanel then
        local ExSearchButton = BrowsePanel.ExSearchButton
        if ExSearchButton then
          reskinStretchButton(ExSearchButton)
        end

        local ExSearchPanel = BrowsePanel.ExSearchPanel
        if ExSearchPanel then
          ExSearchPanel:SetPoint("TOPLEFT", MSEnv.MainPanel, "TOPRIGHT", 3, 0)

          for _, child in pairs {ExSearchPanel:GetChildren()} do
            if child:GetObjectType() == "Button" then
              if child:GetText() then
                B.Reskin(child)
              else
                B.ReskinClose(child)
              end
            end
          end
          for _, child in pairs {ExSearchPanel.Inset:GetChildren()} do
            if child.MinBox and child.MinBox:GetObjectType() == 'EditBox' then
              for _, layer in next, {child.MinBox:GetRegions()} do
                if layer:GetObjectType() == "Texture" then
                  layer:SetAlpha(0);
                end
              end
              B.Reskin(child.MinBox)
            end
            if child.MaxBox and child.MaxBox:GetObjectType() == 'EditBox' then
              for _, layer in next, {child.MaxBox:GetRegions()} do
                if layer:GetObjectType() == "Texture" then
                  layer:SetAlpha(0);
                end
              end
              B.Reskin(child.MaxBox)
            end
          end
        end

        local dungeons = BrowsePanel.MD
        if dungeons then
          for _, box in ipairs(dungeons) do
            B.ReskinCheck(box.Check)
          end
        end

        local AdvFilterPanel = BrowsePanel.AdvFilterPanel
        if AdvFilterPanel then
          for _, child in pairs {AdvFilterPanel:GetChildren()} do
            if child:IsObjectType("Button") then
              if child:GetText() then
                B.Reskin(child)
              else
                B.ReskinClose(child)
              end
            end
          end
        end
    
      end

      local IgnoreListPanel = MTSAddon:GetModule("IgnoreListPanel", true)
      if IgnoreListPanel then
        local IgnoreList = IgnoreListPanel.IgnoreList
        if IgnoreList then
          reskinGridView(IgnoreList)
        end

        for _, child in pairs {IgnoreListPanel:GetChildren()} do
          if child:GetObjectType() == "Button" and child.Text then
            B.Reskin(child)
          end
        end
      end
    end)
    once = false
  end
end
frame:SetScript("OnEvent", eventHandler)

