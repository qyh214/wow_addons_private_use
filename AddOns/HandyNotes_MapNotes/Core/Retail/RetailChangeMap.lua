local ADDON_NAME, ns = ...

ns.CombatLocked = (ns.LOCALE_COMBAT_LOCKED and (ns.LOCALE_COMBAT_LOCKED[ns.locale] or ns.LOCALE_COMBAT_LOCKED.enUS)) or "Map switching is blocked during combat"
ns.AfterCombatAllowed = (ns.LOCALE_AFTER_COMBAT_ALLOWED and (ns.LOCALE_AFTER_COMBAT_ALLOWED[ns.locale] or ns.LOCALE_AFTER_COMBAT_ALLOWED.enUS)) or "Map switching blocked in combat – will be executed after combat"
ns.OpenAfterCombat = (ns.LOCALE_OPEN_AFTER_COMBAT and (ns.LOCALE_OPEN_AFTER_COMBAT[ns.locale] or ns.LOCALE_OPEN_AFTER_COMBAT.enUS)) or "> Map switching executed after combat <"

function ns.MapNotesOpenMap(mapID)
  if not mapID then return end

  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act or not act.ToggleMap then return end

  ns.SafeOpenWorldMap(mapID)
end

local pendingMapOpen
function ns.SafeOpenWorldMap(mapID)
  if not mapID then return end

  local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
  if not act or not act.ToggleMap then return end

  if InCombatLockdown() then
    if act.ToggleMapAfterCombat then
      pendingMapOpen = mapID

      if act.InfoBlockedInCombat then
        if UIErrorsFrame then
          UIErrorsFrame:AddMessage( ns.COLORED_ADDON_NAME .. "\n" .. ns.AfterCombatAllowed, 1, 0.82, 0 )
        else
          print(ns.COLORED_ADDON_NAME .. "\n" .. ns.AfterCombatAllowed)
        end
      end
    else
      if act.InfoBlockedInCombat then
        if UIErrorsFrame then
          UIErrorsFrame:AddMessage( ns.COLORED_ADDON_NAME .. "\n" .. ns.CombatLocked, 1, 0.82, 0 )
        else
          print(ns.COLORED_ADDON_NAME .. "\n" .. ns.CombatLocked)
        end
      end
    end
    return
  end

  C_Map.OpenWorldMap(mapID)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function()
  if pendingMapOpen then
    C_Map.OpenWorldMap(pendingMapOpen)
    pendingMapOpen = nil

    local act = ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.activate
    if act and act.InfoBlockedInCombat then
      if UIErrorsFrame then
        UIErrorsFrame:AddMessage(
          ns.COLORED_ADDON_NAME .. "\n" .. ns.OpenAfterCombat,
          1, 0.82, 0
        )
      else
        print(ns.COLORED_ADDON_NAME .. "\n" .. ns.OpenAfterCombat)
      end
    end
  end
end)