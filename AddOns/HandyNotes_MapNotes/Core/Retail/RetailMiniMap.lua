local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local MMPA
function ns.MiniMapPlayerArrow()
    if MMPA then return MMPA end

    MMPA = CreateFrame("Frame", "MMPA", Minimap)
    MMPA:SetFrameStrata("MEDIUM")
    MMPA:SetPoint("CENTER")
    MMPA:SetSize(10, 10)
    MMPA.texture = MMPA:CreateTexture(nil, "OVERLAY")
    MMPA.texture:SetAtlas("UI-HUD-Minimap-Arrow-Player", true)
    MMPA.texture:SetScale((ns.Addon.db.profile.activate.MinimapArrowScale or 1) * 0.9)
    MMPA.texture:SetPoint("CENTER")
    MMPA.texture:SetTexelSnappingBias(0)
    MMPA.texture:SetSnapToPixelGrid(false)
    MMPA.elapsed = 0

    MMPA:SetScript("OnEnter", function(self)
      if ns.Addon.db.profile.activate.MinimapArrowOnEnter and ns.Addon.db.profile.activate.MinimapArrow then
        self:Hide()
      end
    end)

    MMPA:SetScript("OnLeave", function(self)
      if ns.Addon.db.profile.activate.MinimapArrowOnEnter and ns.Addon.db.profile.activate.MinimapArrow  then
        C_Timer.After(ns.Addon.db.profile.activate.MinimapArrowOnEnterTime, function()
          self:Show()
        end)
      end
    end)

    MMPA:SetScript("OnUpdate", function(self, elapsed)
      self.elapsed = self.elapsed + elapsed
      if self.elapsed < 0.05 then return end
      self.elapsed = 0

      if GetCVar("rotateMinimap") == "1" then
        self.texture:SetRotation(0)
        self.texture:Show()
        return
      end

      local facing = GetPlayerFacing()
      if not facing then
        self.texture:Hide()
        return
      end

      self.texture:Show()
      if facing ~= self.facing then
        self.facing = facing
        self.texture:SetRotation(facing)
      end

    end)

    if ns.Addon.db.profile.activate.MinimapArrow then
      MMPA:Show()
    else
      MMPA:Hide()
    end

    return MMPA
end

function ns.UpdateMinimapArrow()

  local MiniMapFrame = ns.MiniMapPlayerArrow()
  if ns.Addon.db.profile.activate.HideMapNote then
    if MiniMapFrame then MiniMapFrame:Hide() end
    return
  end

  local frame = ns.MiniMapPlayerArrow()
  if not (frame and frame.texture) then return end
  if MMPA and MMPA.texture then
    MMPA.texture:SetScale((ns.Addon.db.profile.activate.MinimapArrowScale or 1) * 0.9)
    if ns.Addon.db.profile.activate.MinimapArrow then
      MMPA:Show()
    else
      MMPA:Hide()
    end
  end
end