local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MNMMBIcon = LibStub("LibDBIcon-1.0", true)

function ns.LoadOptions(self)

ns.options = {
  type = "group",
  name = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString(),
  childGroups = "tab",
  desc = L["Shows locations of raids, dungeons, portals ,ship and zeppelins icons on different maps"],
  get = function(info) return ns.Addon.db.profile[info[#info]] end,
  set = function(info, v) ns.Addon.db.profile[info[#info]] = v HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") end,
  args = {  
    GeneralTab = {
      type = "group",
      name = GENERAL,
      desc = L["General settings that apply to Azeroth / Continent / Dungeon map at the same time"],
      order = 0,
      args = {
        Description = {
          type = "header",
          name = CORE_ABILITIES,
          order = 0.1,
          },
        hideAddon = {
          type = "toggle",
          name = ns.COLORED_ADDON_NAME .. " " .. DISABLE,
          desc = L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"],
          order = 0.2,
          width = 1.05,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.HideMapNote end,
          set = function(info, v) ns.Addon.db.profile.activate.HideMapNote = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideMapNote then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"]) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideMapNote then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cff00ff00", L["All set icons have been restored"]) end end end,
          },  
        hideMMB = {
          type = "toggle",
          name = L["hide minimap button"],
          desc = L["Hide the MapNotes button on the minimap"],
          order = 0.3,
          width = 1.20,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.HideMMB end,
          set = function(info, v) ns.Addon.db.profile.activate.HideMMB = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Show("MNMiniMapButton") else
            if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Hide("MNMiniMapButton") else
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Show("MNMiniMapButton") print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> MiniMapButton <-"], "|cff00ff00" .. L["is activated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Hide("MNMiniMapButton") print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> MiniMapButton <-"], "|cffff0000" .. L["is deactivated"])  end end end end end, 
          },
        hideWMB = {
          type = "toggle",
          name = L["hide worldmap button"],
          desc = L["Hide the MapNotes button on the worldmap"],
          order = 0.4,
          width = 1.20,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.HideWMB end,
          set = function(info, v) ns.Addon.db.profile.activate.HideWMB = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Show() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints();  else
            if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Hide() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); else
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Show() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cff00ff00" .. L["is activated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Hide() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },
        DescriptionHeaderRestore = {
          type = "header",
          name = L["Restore all deleted icons for different types of maps"],
          order = 1,
          },
        RestoreAllIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = ACHIEVEMENTFRAME_FILTER_ALL,
          desc = "|cffffff00" .. "•" .. L["Capitals"] .. " +" .. "\n" .. "•" .. MINIMAP_LABEL .. " +" .. "\n" .. "•" .. L["Continents"] .. "\n" .. "•" .. AZEROTH .. "\n" .. "•" .. CALENDAR_TYPE_DUNGEON .. "|r" .. "\n\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.40,
          order = 1.1,
          func = function(info, v) ns.Addon.db.profile.RestoreAllIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_ALL?") end,
          }, 
        RestoreCapitalsDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Capitals"] .. " +",
          desc = "|cffffff00" .. L["Capitals"]  .. " - " .. MINIMAP_LABEL .."|r" .. "\n\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.70,
          order = 1.2,
          func = function(info, v) ns.Addon.db.profile.RestoreCapitalsDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Capitals?") end,
          }, 
        RestoreZoneDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Zones"] .. " +",
          desc = "|cffffff00" .. MINIMAP_LABEL .. "|r" .. "\n\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 1.3,
          func = function(info, v) ns.Addon.db.profile.RestoreZoneDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Zone?") end,
          }, 
        RestoreContinentDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Continents"],
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 1.4,
          func = function(info, v) ns.Addon.db.profile.RestoreContinentDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Continent?") end,
          }, 
        RestoreAzerothDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = AZEROTH,
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 1.5,
          func = function(info, v) ns.Addon.db.profile.RestoreAzerothDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Azeroth?") end,
          }, 
        RestoreDungeonDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = CALENDAR_TYPE_DUNGEON,
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 1.6,
          func = function(info, v) ns.Addon.db.profile.RestoreDungeonDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Dungeon?") end,
          }, 
        DescriptionOptions = {
          type = "header",
          name = SETTINGS_TITLE,
          order = 2,
          },
        AdvancedOptionsTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = ADVANCED_OPTIONS,
          desc = "",
          order = 2,
          args = {
            --Capitalstheader1 = {
            --  type = "header",
            --  name = ADVANCED_OPTIONS,
            --  order = 1.0,
            --  },
            SwapButtons = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = MOUSE_LABEL .. " " .. KEY_BINDING,
              desc = function ()
                  if ns.Addon.db.profile.WayPointsShift then
                    return L["When enabled, the function of the left and right mouse buttons is swapped"] .. "\n\n" .. "|cff00ff00" .. SLASH_TEXTTOSPEECH_ENABLED .. ":|r" .. "\n\n" .. "|cffffff00" .. SHIFT_KEY .. " + " .. KEY_BUTTON1 .. ":|r" .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" .. "|cffffff00" .. KEY_BUTTON2 .. ":|r" .. "\n" .. L["Opens the adventure guide of the corresponding instance"] .. "\n" .. L["Opens the map where the destination is"] .. "\n\n" .. "|cffff0000" .. SLASH_TEXTTOSPEECH_DISABLED .. ":|r" .. "\n\n" .. "|cffffff00" .. KEY_BUTTON1 .. ":|r" .. "\n" .. L["Opens the adventure guide of the corresponding instance"] .. "\n" .. L["Opens the map where the destination is"] .. "\n\n" .. "|cffffff00" .. SHIFT_KEY .. " + " .. KEY_BUTTON2 .. ":|r" .. "\n" ..  L["Sets a waypoint on a MapNotes icon"]
                  else
                    return L["When enabled, the function of the left and right mouse buttons is swapped"] .. "\n\n" .. "|cff00ff00" .. SLASH_TEXTTOSPEECH_ENABLED .. ":|r" .. "\n\n" .. "|cffffff00" .. KEY_BUTTON1 .. ":|r" .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" .. "|cffffff00" .. KEY_BUTTON2 .. ":|r" .. "\n" .. L["Opens the adventure guide of the corresponding instance"] .. "\n" .. L["Opens the map where the destination is"] .. "\n\n" .. "|cffff0000" .. SLASH_TEXTTOSPEECH_DISABLED .. ":|r" .. "\n\n" .. "|cffffff00" .. KEY_BUTTON1 .. ":|r" .. "\n" .. L["Opens the adventure guide of the corresponding instance"] .. "\n" .. L["Opens the map where the destination is"] .. "\n\n" .. "|cffffff00" .. KEY_BUTTON2 .. ":|r" .. "\n" ..  L["Sets a waypoint on a MapNotes icon"]
                  end
                end,
              order = 1.2,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.SwapButtons end,
              set = function(info, v) ns.Addon.db.profile.activate.SwapButtons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.SwapButtons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", MOUSE_LABEL .. " " .. KEY_BINDING, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.SwapButtons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00",MOUSE_LABEL .. " " .. KEY_BINDING, "|cff00ff00" .. L["is activated"]) end end end,
              },
            showRacesIconsDiscovered = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = RACES .. " +",
              desc = L["Normally, special race icons are automatically hidden after being discovered. They are only visible once in the game and disappear after you interact with them"] .. "\n\n" .. L["This will redisplay the previously discovered icons of the race category on all maps"] .. "\n\n" .. L["The icons are only visible if you belong to the corresponding race"] .. "\n\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
              order = 1.3,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.showRacesIconsDiscovered end,
              set = function(info, v) ns.Addon.db.profile.activate.showRacesIconsDiscovered = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.showRacesIconsDiscovered then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", RACES .. " +", "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.showRacesIconsDiscovered then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", RACES .. " +", "|cff00ff00" .. L["is activated"]) end end end,
              },
            WayPoints = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconTomTom:GetIconString() .. " " .. TextIconWayPoint:GetIconString() .. " ".. L["Waypoints"],
              desc = function()
                  if ns.Addon.db.profile.WayPointsShift then
                    if ns.Addon.db.profile.activate.SwapButtons then
                      return SHIFT_KEY .. "+ " .. KEY_BUTTON1 .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" ..  L["If TomTom is installed, a TomTom waypoint is created. If TomTom is not installed, a waypoint is created using the Blizzard waypoint system"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                    else
                      return SHIFT_KEY .. "+ " .. KEY_BUTTON2 .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" .. L["If TomTom is installed, a TomTom waypoint is created. If TomTom is not installed, a waypoint is created using the Blizzard waypoint system"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                    end
                  else
                    if ns.Addon.db.profile.activate.SwapButtons then
                      return KEY_BUTTON1 .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" .. L["If TomTom is installed, a TomTom waypoint is created. If TomTom is not installed, a waypoint is created using the Blizzard waypoint system"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                    else
                      return KEY_BUTTON2 .. "\n" .. L["Sets a waypoint on a MapNotes icon"] .. "\n\n" .. L["If TomTom is installed, a TomTom waypoint is created. If TomTom is not installed, a waypoint is created using the Blizzard waypoint system"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                    end
                  end
                end,
              order = 2.1,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.WayPoints then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Waypoints"], "|cff00ff00" .. L["is activated"]) else 
                    if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.WayPoints then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Waypoints"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            WayPointsShift = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.WayPoints end,
              type = "toggle",
              name = TextIconTomTom:GetIconString() .. " " .. TextIconWayPoint:GetIconString() .. " ".. L["Waypoints"] .. " Shift",
              desc = function ()
                  if ns.Addon.db.profile.activate.SwapButtons then
                    return L["In addition to the Left mouse button, the shift key must now also be pressed to set a waypoint"]
                  else
                    return L["In addition to the Right mouse button, the shift key must now also be pressed to set a waypoint"]
                  end
                end,
              order = 2.2,
              width = 1.20,
              get = function() return ns.Addon.db.profile.WayPointsShift end,
              set = function(info, v) ns.Addon.db.profile.WayPointsShift = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.WayPointsShift then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Waypoints"] .. " +", "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.WayPointsShift then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Waypoints"] .. " +", "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicIcons = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = AUCTION_HOUSE_FILTER_DROPDOWN_NONE .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. L["Passages"],
              desc = INSTANCE .. " " .. L["Passage"] .. " " .. L["icons"] .. "\n" .. TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. "\n\n" .. L["Only affects passage icons to instances and not path icons to zones"] .. "\n\n" .. L["Changes all passage symbols on all maps to dungeon, raid or multiple symbols. In addition, the passage option will be disabled everywhere and the symbols will be added to the respective raids, dungeons or multiple options (The dungeon map remains unchanged from all this)"] .. "\n\n" .. L["At the same time, all icons representing additional instance inputs are removed"],
              order = 2.3,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.ClassicIcons end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", AUCTION_HOUSE_FILTER_DROPDOWN_NONE, L["Passages"], L["icons"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", AUCTION_HOUSE_FILTER_DROPDOWN_NONE, L["Passages"], L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            DeleteIcons = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconExit:GetIconString() .. " " .. CALENDAR_DELETE_EVENT,
              desc = L["With Alt + right click it is now possible to remove any MapNotes icon"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons, indicating how icons can be deleted"],
              order = 2.4,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.DeleteIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CALENDAR_DELETE_EVENT, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.DeleteIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CALENDAR_DELETE_EVENT, "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            TooltipInformations = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconInfo:GetIconString() .. " " .. L["Tooltip"],
              desc = L["Adds an additional tooltip to icons, which lists the functions of the icons"] .. "\n\n" .. L["If the world map is open, these are also displayed on the minimap icons, but if the world map is closed, these are no longer displayed on the minimap"],
              order = 2.5,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.TooltipInformations then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Tooltip"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.TooltipInformations then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Tooltip"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            journal = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconJournal:GetIconString() .. " " .. L["Adventure guide"],
              desc = function() if ns.Addon.db.profile.activate.SwapButtons then -- Swapbuttons
                    return L["Right-clicking on a MapNotes raid (green), dungeon (blue) or multiple icon (green&blue) on the map opens the corresponding dungeon or raid map in the Adventure Guide"] .. "\n\n" .. L["Right-clicking on a multiple icon will open the map where the dungeons are located"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                  else -- Original Buttons
                    return L["Left-clicking on a MapNotes raid (green), dungeon (blue) or multiple icon (green&blue) on the map opens the corresponding dungeon or raid map in the Adventure Guide"] .. "\n\n" .. L["Left-clicking on a multiple icon will open the map where the dungeons are located"] .. "\n\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons showing how to interact with this feature"]
                  end
                end,
              order = 2.6,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.journal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Adventure guide"], "|cff00ff00" .. L["is activated"]) else 
                    if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.journal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Adventure guide"], "|cffff0000" .. L["is deactivated"]) end end end,
              },  
            grayMultipleID = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconLocked:GetIconString() .. " " .. TextIconMultipleM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " .. L["gray all"],
              desc = L["Colors EVERYONE! Assigned dungeons and raids also have multiple points in gray (if you have an ID)"],
              order = 2.7,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.grayMultipleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray all"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.grayMultipleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray all"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },          
            graySingleID = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.grayMultipleID end,
              type = "toggle",
              name = TextIconLocked:GetIconString() .. " " .. TextIconRaid:GetIconString() .. " " .. TextIconDungeon:GetIconString() .. " " .. L["gray single"],
              desc = L["Colors only individual points of assigned dungeons and raids in gray (if you have an ID)"],
              order = 2.8,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.graySingleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray single"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.graySingleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray single"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            BossNames = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconBosses:GetIconString() .. " " .. L["Boss names"],
              desc = L["Show boss names on the dungeon or raid icon"],
              order = 2.9,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.BossNames then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Boss names"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.BossNames then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Boss names"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            KilledBosses = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconBosses:GetIconString() .. " " .. L["Killed bosses"],
              desc = L["Shows already defeated bosses on dungeon or raid icons"],
              order = 3.0,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.KilledBosses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Killed bosses"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.KilledBosses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Killed bosses"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            NpcNameTargeting = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconTarget:GetIconString() .. " " .. L["NPC targeting"],
              desc = "\n" .. "|cffffff00" .. SHIFT_KEY_TEXT .. " + " .. KEY_BUTTON3 .. ":|r" .. "\n\n" .. L["Clicking on a MapNotes symbol with an NPC name opens a confirmation window, which automatically targets this NPC after confirmation and marks it with an X"] .. "\n\n" .. "|cffffff00" .. LFG_LIST_REQUIRE .. ":\n\n" .. "(" .. RESTRICT_CHAT_CONFIG_HYPERLINK .. " • " .. L["NPC targeting"] .. ")\n\n|r" .. L["If you are not within range, you will receive the message in the chat"] .. ":\n\n" .. ns.COLORED_ADDON_NAME .. " " .. SPELL_FAILED_CUSTOM_ERROR_216,
              order = 3.1,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.NpcNameTargeting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["NPC targeting"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.NpcNameTargeting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["NPC targeting"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            AdvancedHeader2 = {
              type = "header",
              name = BATTLENET_OPTIONS_LABEL .. " " .. DISABLE,
              order = 4.0,
              },
            RemoveBlizzPOIs = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = "POIs",
              desc = L["Points of interests"] .. "\n" .. "("  .. L["Portals"] .. ", " .. L["Ships"] .. ", " .. L["Capitals"] .. ")" .. "\n\n" .. L["Removes the Blizzard symbols only where MapNotes symbols and Blizzard symbols overlap, thereby making the tooltip and the function of the MapNote symbols usable again on the overlapping points"],
              order = 4.1,
              width = 0.60,
              get = function() return ns.Addon.db.profile.activate.RemoveBlizzPOIs end,
              set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzPOIs = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] ) end end end
              },
            RemoveBlizzPOIsZidormi = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Zidormi"],
              desc = L["Points of interests"] .. "\n" .. "("  .. L["Zidormi"] .. ")" .. "\n\n" .. L["Removes the Blizzard symbols only where MapNotes symbols and Blizzard symbols overlap, thereby making the tooltip and the function of the MapNote symbols usable again on the overlapping points"],
              order = 4.2,
              width = 0.60,
              get = function() return ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi end,
              set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                ns.RemoveBlizzPOIs()
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["Zidormi"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["Zidormi"] .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
              },
            RemoveBlizzInstances = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = INSTANCE,
              desc = TextIconRaid:GetIconString() .. " " .. TextIconDungeon:GetIconString() .. " " ..  L["Disables the display of all Blizzard Dungeon and Raid icons on the zone map"],
              order = 4.3,
              width = 0.60,
              get = function() return ns.Addon.db.profile.activate.RemoveBlizzInstances end,
              set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 0) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DUNGEONS .. " / " .. RAIDS .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 1) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DUNGEONS .. " / " .. RAIDS .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] ) else
                if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 0) else
                if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 1) end end end end end,
              },
            ShowBlizzDelves = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = DELVES_LABEL,
              desc = TextIconDelves:GetIconString().. " " .. L["Disables the display of all Blizzard Delves entrances on the zone map"] .. "\n\n" .. L["It is recommended not to activate this function if you generally want to see these symbols on the zone map. Since MapNotes didn't place its own Delve icons on the zone map, instead we attached our functions to the Blizzard Delve icons"],
              order = 4.4,
              width = 0.60,
              get = function() return ns.Addon.db.profile.activate.ShowBlizzDelves end,
              set = function(info, v) ns.Addon.db.profile.activate.ShowBlizzDelves = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ShowBlizzDelves then SetCVar("showDelveEntrancesOnMap", 0) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DELVES_LABEL .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ShowBlizzDelves then SetCVar("showDelveEntrancesOnMap", 1) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DELVES_LABEL .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] ) else
                if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ShowBlizzDelves then SetCVar("showDelveEntrancesOnMap", 0) else
                if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ShowBlizzDelves then SetCVar("showDelveEntrancesOnMap", 1) end end end end end,
              },
            },
          },
        IconsOptionTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = EMBLEM_SYMBOL .. " " .. OPTIONS,
          desc = "",
          order = 2,
          args = {
            Capitalstheader1 = {
              type = "header",
              name = L["Old icon style"] .. " - " .. LAYOUT_STYLE_CLASSIC .. " / " .. LAYOUT_STYLE_MODERN,
              order = 3.0,
              },
            ClassicPortals = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Portals"] .. " " .. TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n\n" .. L["Portals"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. "\n" .. TextIconPassagePortalOld:GetIconString() .. " " .. TextIconPassageHPortalOld:GetIconString() .. " " .. TextIconPassageAPortalOld:GetIconString() .. "\n\n" .. L["Portals"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconPortal:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. "\n" .. TextIconPassagePortal:GetIconString() .. " " .. TextIconPassageHPortal:GetIconString() .. " " .. TextIconPassageAPortal:GetIconString(),
              width = 0.80,
              order = 3.2,
              get = function() return ns.Addon.db.profile.activate.ClassicPortals end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicPortals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cffff0000" .. L["is deactivated"]) else
                  if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicShips = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Ships"] .. " " .. TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n\n" .. L["Ships"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. "\n\n" .. L["Ships"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString(),
              width = 0.80,
              order = 3.3,
              get = function() return ns.Addon.db.profile.activate.ClassicShips end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicShips = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicZeppelin = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Zeppelins"] .. " " .. TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n\n" .. L["Zeppelins"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. "\n\n" .. L["Zeppelins"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString(),
              width = 0.80,
              order = 3.4,
              get = function() return ns.Addon.db.profile.activate.ClassicZeppelin end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicZeppelin = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicBank = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = BANK .. " " .. TextIconBankOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n\n" .. BANK .. " " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconBankOld:GetIconString() .. "\n\n" .. BANK .. " " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconBank:GetIconString(),
              width = 0.80,
              order = 3.5,
              get = function() return ns.Addon.db.profile.activate.ClassicBank end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicBank = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicProfession = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TRADE_SKILLS .. " " ..  TextIconProfessionOrders:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n\n" .. TRADE_SKILLS .. " " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconOriginalAlchemy:GetIconString() .. " " .. TextIconOriginalBlacksmith:GetIconString() .. " " .. TextIconOriginalEngineer:GetIconString() .. " " .. TextIconOriginalSkinning:GetIconString() .. " " .. TextIconOriginalTailoring:GetIconString() .. " " .. TextIconOriginalJewelcrafting:GetIconString() .. " " .. TextIconOriginalLeatherworking:GetIconString() .. " " .. TextIconOriginalHerbalism:GetIconString() .. " " .. TextIconOriginalMining:GetIconString() .. " " .. TextIconOriginalEnchanting:GetIconString() .. " " .. TextIconOriginalInscription:GetIconString() .. " " .. TextIconOriginalArchaeology:GetIconString() .. " " .. TextIconOriginalCooking:GetIconString() .. " " .. TextIconOriginalFishing:GetIconString() .. " " ..  "\n\n" .. TRADE_SKILLS .. " " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconAlchemy:GetIconString() .. " " .. TextIconBlacksmith:GetIconString() .. " " .. TextIconEngineer:GetIconString() .. " " .. TextIconSkinning:GetIconString() .. " " .. TextIconTailoring:GetIconString() .. " " .. TextIconJewelcrafting:GetIconString() .. " " .. TextIconLeatherworking:GetIconString() .. " " .. TextIconHerbalism:GetIconString() .. " " .. TextIconMining:GetIconString() .. " " .. TextIconEnchanting:GetIconString() .. " " .. TextIconInscription:GetIconString() .. " " .. TextIconArchaeology:GetIconString() .. " " .. TextIconCooking:GetIconString() .. " " .. TextIconFishing:GetIconString(),
              width = 0.80,
              order = 3.6,
              get = function() return ns.Addon.db.profile.activate.ClassicProfession end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicProfession = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cff00ff00" .. L["is activated"]) end end end,
              },
            },
          },
        ChatMessageTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = CHAT_OPTIONS_LABEL,
          desc = "",
          order = 3,
          args = {
            Chatheader1 = {
              type = "header",
              name = CHAT_OPTIONS_LABEL,
              order = 1.0,
              },
            CreateAndCopyLinks = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK,
              desc = L["Enables you to copy links and email addresses from the chat"] .. "\n\n" .. L["Links are only generated after the feature is activated. Links or email addresses created before activation will not be recognized retroactively"] .. "\n\n" .. L["If the link or email address is colored blue in the chat, the link is ready to be copied"] .. "\n\n" .. L["Clicking a link in the chat opens a separate window"] .. "\n\n" .. L["Use CTRL + C to copy the link"] .. "\n\n" .. L["The window closes automatically after copying"],
              order = 1.1,
              width = 1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                ns.ToggleCreateAndCopyLink()
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.CreateAndCopyLinks then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.CreateAndCopyLinks then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            Chatheader2 = {
              type = "header",
              name = L["chat message"],
              order = 2.0,
              },
            CoreChatMassage = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = CORE_ABILITIES,
              desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n\n" .. "• " .. GENERAL .. "\n" .. "• " .. L["Profiles"] .. "\n\n" .. "|cffff0000" .. L["An exception is the feedback in the chat from the function for deleting or restoring icons. These are always displayed!"],
              order = 2.1,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            ChatMassage = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = LAYOUT_STYLE_CLASSIC,
              desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n\n" .. "• " .. L["Capitals"] .. " + " .. "\n" .. "• " .. L["Zones"] .. " + " .. "\n" .. "• " .. L["Continents"] .. "\n" .. "• " .. AZEROTH .. "\n" .. "• " .. WORLDMAP_BUTTON .. "\n" .. "• " .. L["Dungeons"],
              order = 2.2,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. LAYOUT_STYLE_CLASSIC, L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. LAYOUT_STYLE_CLASSIC, L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            MmbWmbChatMessage = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = "MMB/WMB",
              desc = "• " .. L["-> MiniMapButton <-"] .. "\n" .. "• " .. L["-> WorldMapButton <-"] .. "\n\n" .. L["Here you can enable or disable all chat messages sent by MapNotes Minimap and Worldmap buttons when you hide or show icons over them"],
              order = 2.3,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            ZoneChanged = {
              type = "toggle",
              name = L["Location"],
              desc = L["When entering a new zone, the name of the new zone will be displayed in the chat"],
              order = 2.4,
              width = 1.20,
              get = function() return ns.Addon.db.profile.ZoneChanged end,
              set = function(info, v) ns.Addon.db.profile.ZoneChanged = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"],  "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ZoneChangedDetail = {
              disabled = function() return not ns.Addon.db.profile.ZoneChanged end,
              type = "toggle",
              name = L["Location"] ..  " " .. LFG_LIST_DETAILS,
              desc = L["In addition to the zone names, it also displays the names of specific locations within a zone. Disabling the Show Zone Names feature will also disable this feature"] .. "\n\n" .. L["Capital cities are excluded from this because there would be too much chat spam"],
              order = 2.5,
              width = 1.20,
              get = function() return ns.Addon.db.profile.ZoneChangedDetail end,
              set = function(info, v) ns.Addon.db.profile.ZoneChangedDetail = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cff00ff00" .. L["is activated"]) end end end,
              },
            NpcNameTargetingChatText = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["NPC targeting"],
              desc = "\n" .. CHAT .. " " .. ERRORS .. " " .. STATUSTEXT_LABEL .. ":\n" .. ns.COLORED_ADDON_NAME .. " " .. SPELL_FAILED_CUSTOM_ERROR_216,
              order = 2.6,
              width = 1.20,
              get = function() return ns.Addon.db.profile.NpcNameTargetingChatText end,
              set = function(info, v) ns.Addon.db.profile.NpcNameTargetingChatText = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.NpcNameTargetingChatText then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["NPC targeting"], CHAT, STATUSTEXT_LABEL .. " |cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.NpcNameTargetingChatText then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["NPC targeting"], CHAT, STATUSTEXT_LABEL .. " |cff00ff00" .. L["is activated"]) end end end,
              },
            },
          },
        UnexploredAreasTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["Unexplored Areas"],
          desc = "",
          order = 4,
          args = {
            Capitalstheader1 = {
              type = "header",
              name = L["Unexplored Areas"],
              order = 1.0,
              },
            FogOfWar = {
              --disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Unexplored Areas"],
              desc = L["Reveals unexplored areas and shows the individual areas of each zone that are actually still unexplored"],
              order = 1.1,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.FogOfWar end,
              set = function(info, v) ns.Addon.db.profile.activate.FogOfWar = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                HandyNotes:GetModule("FogOfWarButton"):Refresh()
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.FogOfWar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Unexplored Areas"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.FogOfWar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Unexplored Areas"], "|cff00ff00" .. L["is activated"]) end end end,
              }, 
            Unexploredheader2 = {
              type = "header",
              name = L["Mist of the Unexplored"],
              order = 2.0,
              },
            MistOfTheUnexplored = {
              disabled = function() return not ns.Addon.db.profile.activate.FogOfWar end,          
              type = "toggle",
              name = L["Mist of the Unexplored"],
              desc = L["Leaves the unexplored areas revealed but adds a slight fog so you can still see which ones you haven't explored yet"],
              width = 1.2,
              order = 2.1,
              get = function() return ns.Addon.db.profile.activate.MistOfTheUnexplored end,
              set = function(info, v) ns.Addon.db.profile.activate.MistOfTheUnexplored = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                HandyNotes:GetModule("FogOfWarButton"):Refresh()
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.MistOfTheUnexplored then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Fog"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.MistOfTheUnexplored then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Fog"], "|cff00ff00" .. L["is activated"]) end end end,
              }, 
            FogOfWarColor = {
              disabled = function() return not ns.Addon.db.profile.activate.FogOfWar or not ns.Addon.db.profile.activate.MistOfTheUnexplored end,
              type = "color",
              name = L["Fog"] .. " - " .. COLOR,
              desc = L["Leaves the unexplored areas revealed but adds a slight fog so you can still see which ones you haven't explored yet"],
              width = 1,
              order = 2.2,
              get = "GetFogOfWarColor",
              set = "SetFogOfWarColor",
              handler = ns.FogOfWar,
              hasAlpha = true,
              }, 
            },
          },
        CoordinatesTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["Coordinates"],
          desc = "",
          order = 5,
          args = {
            Coordinatesheader = {
              type = "header",
              name = L["Coordinates"],
              order = 1.0,
              },
            showPlayerCoords = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = PLAYER,
              desc = L["Creates a window for displaying the coordinates"],
              order = 1.1,
              width = 0.50,
              get = function() return ns.Addon.db.profile.displayCoords.showPlayerCoords end,
              set = function(info, v) ns.Addon.db.profile.displayCoords.showPlayerCoords = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.displayCoords.showPlayerCoords then ns.CreatePlayerCoordsFrame() end
                if not ns.Addon.db.profile.displayCoords.showPlayerCoords then ns.HidePlayerCoordsFrame() end
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.displayCoords.showPlayerCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", PLAYER .. " " .. L["Coordinates"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.displayCoords.showPlayerCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", PLAYER .. " " .. L["Coordinates"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            PlayerCoordsSize = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = HUD_EDIT_MODE_SETTING_BAGS_SIZE,
              desc = "",
              min = 0.5, max = 2, step = 0.1,
              width = 0.70,
              order = 1.2,
              get = function() return ns.Addon.db.profile.displayCoords.PlayerCoordsSize or 1 end,
              set = function(info, v) ns.Addon.db.profile.displayCoords.PlayerCoordsSize = v if PlayerCoordsFrame then PlayerCoordsFrame:SetScale(v) end end,
              },
            PlayerCoordsAlpha = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = OPACITY,
              desc = CINEMATIC_SUBTITLES_BACKGROUND_OPACITY_OPTION_LABEL,
              min = 0.0, max = 1, step = 0.1,
              width = 0.70,
              order = 1.3,
              get = function() return ns.Addon.db.profile.displayCoords.PlayerCoordsAlpha or 1 end,
              set = function(info, v)
                ns.Addon.db.profile.displayCoords.PlayerCoordsAlpha = v
                if PlayerCoordsFrame then
                  if PlayerCoordsFrame.background then
                    PlayerCoordsFrame.background:SetColorTexture(0, 0, 0, v)
                  end
                  if PlayerCoordsFrame.border then
                    PlayerCoordsFrame.border:SetAlpha(v)
                  end
                end
              end,
              },
            showPlayerReset = {
              disabled = function() return ns.Addon.db.profile.displayCoords.HideMapNote end,
              type = "execute",
              name = RESET_POSITION,
              desc = ADDON_LIST_RESET_TO_DEFAULT,
              order = 1.4,
              width = 0.70,
              func = function()
                ns.DefaultPlayerAlpha()
                ns.DefaultPlayerCoords()
              end
              },
            Coordinatesheader2 = {
              type = "description",
              name = "",
              order = 1.5,
              },
            showMouseCoords = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = MOUSE_LABEL,
              desc = L["Creates a window for displaying the coordinates"] .. "\n\n" .. L["Only visible when the world map is open"],
              order = 1.6,
              width = 0.50,
              get = function() return ns.Addon.db.profile.displayCoords.showMouseCoords end,
              set = function(info, v) ns.Addon.db.profile.displayCoords.showMouseCoords = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.displayCoords.showMouseCoords then ns.CreateMouseCoordsFrame() end
                if not ns.Addon.db.profile.displayCoords.showMouseCoords then ns.HideMouseCoordsFrame() end
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.displayCoords.showMouseCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", MOUSE_LABEL .. " " .. L["Coordinates"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.displayCoords.showMouseCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", MOUSE_LABEL .. " " .. L["Coordinates"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            MouseCoordsSize = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = HUD_EDIT_MODE_SETTING_BAGS_SIZE,
              desc = "",
              min = 0.5, max = 1.5, step = 0.1,
              width = 0.70,
              order = 1.7,
              get = function() return ns.Addon.db.profile.displayCoords.MouseCoordsSize or 1 end,
              set = function(info, v) ns.Addon.db.profile.displayCoords.MouseCoordsSize = v if MouseCoordsFrame then MouseCoordsFrame:SetScale(v) end end,
              },
            MouseCoordsAlpha = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = OPACITY,
              desc = CINEMATIC_SUBTITLES_BACKGROUND_OPACITY_OPTION_LABEL,
              min = 0.0, max = 1, step = 0.1,
              width = 0.70,
              order = 1.8,
              get = function() return ns.Addon.db.profile.displayCoords.MouseCoordsAlpha or 1 end,
              set = function(info, v)
                ns.Addon.db.profile.displayCoords.MouseCoordsAlpha = v
                if MouseCoordsFrame then
                  if MouseCoordsFrame.background then
                    MouseCoordsFrame.background:SetColorTexture(0, 0, 0, v)
                  end
                  if MouseCoordsFrame.border then
                    MouseCoordsFrame.border:SetAlpha(v)
                  end
                end
              end,
              },
            MouseReset = {
              disabled = function() return ns.Addon.db.profile.displayCoords.HideMapNote end,
              type = "execute",
              name = RESET_POSITION,
              desc = ADDON_LIST_RESET_TO_DEFAULT,
              order = 1.9,
              width = 0.70,
              func = function()
                ns.DefaultMouseAlpha()
                ns.DefaultMouseCoords()
              end
              },
            },
          },
        MiniMapPlus = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = MINIMAP_LABEL .. " +",
          desc = "",
          order = 6,
          args = {
            AdvancedHeader3 = {
              type = "header",
              name = MINIMAP_LABEL,
              order = 1.5,
              },    
            MinimapArrow = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Minimap player arrow"],
              desc = L["Displays the player arrow on the minimap layered above addon-created icons"] .. "\n\n" .. "|cFFFF0000" .. L["Unfortunately does not work in instances"],
              order = 1.6,
              width = 1,
              get = function() return ns.Addon.db.profile.activate.MinimapArrow end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapArrow = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.MiniMapPlayerArrow then if ns.Addon.db.profile.activate.MinimapArrow then ns.MiniMapPlayerArrow():Show() else ns.MiniMapPlayerArrow():Hide() end end
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.MinimapArrow then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Minimap player arrow"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.MinimapArrow then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Minimap player arrow"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            MinimapArrowScale = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = HUD_EDIT_MODE_SETTING_BAGS_SIZE,
              desc = "",
              min = 0.8, max = 2, step = 0.1,
              width = 0.70,
              order = 1.7,
              set = function(info, v) ns.Addon.db.profile.MinimapArrowScale = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if MMPA and MMPA.texture then MMPA.texture:SetScale(ns.Addon.db.profile.MinimapArrowScale) end end
              },
            AdvancedHeader4 = {
              type = "description",
              name = "",
              order = 1.8,
              },    
            MinimapArrowOnEnter = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = ADVANCED_OPTIONS,
              desc = L["The MapNotes player arrow disappears from the minimap for the set number of seconds when you hover over it"] .. "\n\n" .. L["This makes it easier for the player to see which other icon is currently under the player"],
              order = 1.9,
              width = 1,
              get = function() return ns.Addon.db.profile.activate.MinimapArrowOnEnter end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapArrowOnEnter = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.MinimapArrowOnEnter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Minimap player arrow"], ADVANCED_OPTIONS .. " " .. "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.MinimapArrowOnEnter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Minimap player arrow"], ADVANCED_OPTIONS .. " " .. "|cff00ff00" .. L["is activated"]) end end end,
              },
            MinimapArrowOnEnterTime = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = SECONDS,
              desc = "",
              order = 2.0,
              min = 1, max = 10, step = 1,
              width = 0.70,
              get = function() return ns.Addon.db.profile.activate.MinimapArrowOnEnterTime end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapArrowOnEnterTime = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") end
              },
            },
          },
        AreaMapTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["Area Map"],
          desc = "",
          order = 7,
          args = {
            AreaMapheader1 = {
              type = "header",
              name = L["Area Map"],
              order = 1.0,
              },
            showAreaMapDropDownMenu = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Area Map"] .. " " .. HUD_EDIT_MODE_MICRO_MENU_LABEL,
              desc = "",
              order = 1.1,
              width = 1,
              get = function() return ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu end,
              set = function(info, val) ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu = val ns.showAreaMapDropDownMenu = val ns.SetAreaMapMenuVisibility(val)        
                ns.showAreaMapDropDownMenuSettingsforOptionsFile(val)
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Area Map"] .. " " .. HUD_EDIT_MODE_MICRO_MENU_LABEL, "|cffff0000".. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Area Map"] .. " " .. HUD_EDIT_MODE_MICRO_MENU_LABEL, "|cff00ff00"  .. L["is activated"]) end end end,
              },
            },
          },
        About = {
          type = "group",
          name = L["About MapNotes"],
          desc = "",
          order = 9,
          args = {
            --AreaMapheader1 = {
            --  type = "header",
            --  name = L["About MapNotes"],
            --  order = 1.0,
            --  },
            MNNpcScanmid = {
              type = "description",
              name = "",
              width = 0.30,
              order = 1.1,
              },
            MNNpcScan = {
              type = "execute",
              name = UPDATE .. " NPC " .. INFO,
              desc = "Update NPC name database",
              width = 2,
              order = 1.2,
              func = function(info, v) self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                ns._manualScanActive = true
                ns.PrimeNpcNameCache()
                ns._manualScanActive = false
              end,
            },
            NewLineNpc = {
              type = "description",
              name = "",
              width = "full",
              order = 1.3,
            },
            MNChangeLogmid1 = {
              type = "description",
              name = "",
              width = 0.30,
              order = 1.4,
              },
            MNChangeLog = {
              type = "execute",
              name = L["Changelog"] .. " " .. SHOW,
              desc = L["Show MapNotes Changelog again"],
              width = 2,
              order = 1.5,
              func = function(info, v) self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                ns.ShowChangelogWindowMenu() 
                LibStub("AceConfigDialog-3.0"):Close("MapNotes")
                end,
              },
            SupportTextheader = {
              type = "header",
              name = PING_TYPE_ASSIST,
              width = 1,
              order = 9.0,
              },
            SupportText = {
              type = "description",
              name = "|cffffd700" .. L["If you like this addon, feel free to support me via Paypal, Patreon or Ko-fi"] .. "\n\n" .. L["You can find the relevant links on:"] .. "\n\n" .. "https://www.curseforge.com/wow/addons/mapnotes" .. "\n" .. "https://www.curseforge.com/members/badboybarny".. "\n" .. "https://addons.wago.io/addons/mapnotes" .. "\n" .. "https://addons.wago.io/user/BadBoyBarny" .. "\n\n" .. L["Any support is greatly appreciated"] .. "\n\n" .. "            " .. L["Best regards"] .. "\n\n" .. "                        " .. "BadBoyBarny",
              order = 9.1,
              },
            },
          },
        },
      },
    CapitalsAndCapitalsMiniMapTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Capitals"] .. " +",
      desc = "|cffffff00" .. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|r" .. "\n\n" .. L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n\n" .. L["Capitals"] .. ":" .. "\n\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
      order = 1,
      args = {
        SyncCapitalsAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Capitals tab with the Capitals - Minimap tab"] .. "\n\n" .. L["Which deactivates the functions from the Capitals - Minimap tab and is now controlled together by the Capitals tab"] .. "\n\n" .. "|cffff0000" .. L["This will delete all Capitals - Minimap settings and replace them with those from Capitals tab"],
          width = 2.5,
          order = 10.1,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncCapitalsAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        Capitalstheader2 = {
          type = "header",
          name = L["Capitals"] .. " " .. L["icons"],
          order = 10.2,
          },
        showCapitals = {
          type = "toggle",
          name = L["Capitals"] .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"] .. "\n\n" .. L["Capitals"] .. ":" .. "\n\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"],
          width = 1.8,
          order = 10.3,
          get = function() return ns.Addon.db.profile.activate.Capitals end,
          set = function(info, v) ns.Addon.db.profile.activate.Capitals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.Capitals and (not ns.NeutralCapitalIDs and not ns.HordeCapitalsIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(85) else 
                if not ns.Addon.db.profile.activate.Capitals and (not ns.NeutralCapitalIDs and not ns.HordeCapitalsIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(85) else
                if ns.Addon.db.profile.activate.Capitals and (not ns.NeutralCapitalIDs and not ns.AllianceCapitalIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(84) else 
                if not ns.Addon.db.profile.activate.Capitals and (not ns.NeutralCapitalIDs and not ns.AllianceCapitalIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(84) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.Capitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.Capitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end end end,
          },
        CapitalEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
          type = "toggle",
          name = L["Capitals"] .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 10.4,
          width = 1.8,
          get = function() return ns.Addon.db.profile.activate.CapitalsEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.CapitalsEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.CapitalsEnemyFaction and (not ns.NeutralCapitalIDs and not ns.AllianceCapitalIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(84) else 
                if not ns.Addon.db.profile.activate.CapitalsEnemyFaction and (not ns.NeutralCapitalIDs and not ns.AllianceCapitalIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(84) else
                if ns.Addon.db.profile.activate.CapitalsEnemyFaction and (not ns.NeutralCapitalIDs and not ns.HordeCapitalsIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(85) else 
                if not ns.Addon.db.profile.activate.CapitalsEnemyFaction and (not ns.NeutralCapitalIDs and not ns.HordeCapitalsIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(85) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end end end end end,
           },
        Capitalstheader1 = {
          disabled = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "header",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["icons"],
          order = 10.5,
          },
        showMinimapCapitals = {
          disabled = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "toggle",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"] .. "\n\n" .. L["Capitals"] .. ":" .. "\n\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"],
          width = 1.8,
          order = 10.6,
          get = function() return ns.Addon.db.profile.activate.MinimapCapitals end,
          set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        MinimapCapitalsEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "toggle",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 10.7,
          width = 1.8,
          get = function() return ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        CapitalsTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["Capitals"] .. " " .. L["Zones"],
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n\n" .. L["Capitals"] .. ":" .. "\n\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
          order = 1,
          args = {
            Capitalstheader1 = {
              type = "header",
              name = L["Capitals"] .. " " .. L["icons"],
              order = 1.1,
              },
            CapitalsDescriptionText = {
              name = "|cffff0000" .. L["Capitals"] .. " " .. L["icons"] .. "\n\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Capital"],
              type = "description",
              order = 1.2,
              },
            CapitalsCapitalsTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "group",
              name = "• " .. L["Capitals"],
              desc = L["Enables the display of icons for a specific capital city"],
              order = 1,
              args = {
                Capitalsheader6 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. FACTION_HORDE,
                  order = 10.4,
                  },
                showCapitalsOrgrimmar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconOrgrimmar:GetIconString() .. " " .. ORGRIMMAR,
                  desc = "",
                  width = 0.80,
                  order = 10.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ORGRIMMAR, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ORGRIMMAR, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsThunderBluff = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconThunderBluff:GetIconString() .. " " .. L["Thunder Bluff"],
                  desc = "",
                  width = 0.80,
                  order = 10.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsSilvermoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconSilvermoon:GetIconString() .. " " .. L["Silvermoon City"],
                  desc = "",
                  width = 0.80,
                  order = 10.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsSilvermoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Silvermoon City"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsSilvermoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Silvermoon City"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsUndercity = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconUndercity:GetIconString() .. " " .. L["Undercity"],
                  desc = "",
                  width = 0.80,
                  order = 10.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Undercity"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Undercity"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDazarAlor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDazarAlor:GetIconString() .. " " .. L["Dazar'alor"],
                  desc = "",
                  width = 0.80,
                  order = 10.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDazarAlor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dazar'alor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDazarAlor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dazar'alor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsSot2M = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconSot2M:GetIconString() .. " " .. L["Shrine2Moons"],
                  desc = EXPANSION_NAME4,
                  width = 0.90,
                  order = 11,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsSot2M then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shrine2Moons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsSot2M then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shrine2Moons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsWarspear = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconWarspear:GetIconString() .. " " .. L["Warspear"] .. " / " .. GARRISON_LOCATION_TOOLTIP,
                  desc = "",
                  width = 1.40,
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsWarspear then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warspear"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsWarspear then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warspear"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader7 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. FACTION_ALLIANCE,
                  order = 12,
                  },
                showCapitalsStormwind = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconStormwind:GetIconString() .. " " .. L["Stormwind"],
                  desc = "",
                  width = 0.80,
                  order = 12.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsStormwind then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Stormwind"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsStormwind then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Stormwind"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsIronforge = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconIronforge:GetIconString() .. " " .. L["Ironforge"],
                  desc = "",
                  width = 0.80,
                  order = 12.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsIronforge then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Ironforge"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsIronforge then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Ironforge"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDarnassus = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDarnassus:GetIconString() .. " " .. L["Darnassus"],
                  desc = "",
                  width = 0.80,
                  order = 12.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Darnassus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Capitals"], L["Darnassus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsExodar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconExodar:GetIconString() .. " " .. L["Exodar"],
                  desc = "",
                  width = 0.80,
                  order = 12.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsExodar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Exodar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsExodar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Exodar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsBoralus = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconBoralus:GetIconString() .. " " .. L["Boralus"],
                  desc = "",
                  width = 0.80,
                  order = 12.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBoralus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Boralus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBoralus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Boralus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsSot7S = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconSot7S:GetIconString() .. " " .. L["Shrine7Stars"],
                  desc = EXPANSION_NAME4,
                  width = 0.90,
                  order = 12.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsSot7S then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shrine7Stars"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsSot7S then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shrine7Stars"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsStormshield = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconStormshield:GetIconString() .. " " .. L["Stormshield"] .. " / " .. GARRISON_LOCATION_TOOLTIP,
                  desc = "",
                  width = 1.40,
                  order = 12.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsStormshield then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Stormshield"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsStormshield then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Stormshield"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader8 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. FACTION_NEUTRAL,
                  order = 14.,
                  },
                showCapitalsShattrath = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconShattrath:GetIconString() .. " " .. L["Shattrath City"],
                  desc = "",
                  width = 0.80,
                  order = 14.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsShattrath then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shattrath City"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsShattrath then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shattrath City"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDalaranNorthrend = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDalaranNorthrend:GetIconString() .. " " .. DUNGEON_FLOOR_DALARAN1,
                  desc = DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND,
                  width = 0.80,
                  order = 14.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDalaranNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDalaranNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDalaranLegion = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDalaranLegion:GetIconString() .. " " .. DUNGEON_FLOOR_DALARAN1,
                  desc = DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6,
                  width = 0.80,
                  order = 14.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDalaranLegion then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDalaranLegion then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsOribos = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconOribos:GetIconString() .. " " .. L["Oribos"],
                  desc = "",
                  width = 0.80,
                  order = 14.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsOribos then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Oribos"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsOribos then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Oribos"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsValdrakken = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconValdrakken:GetIconString() .. " " .. L["Valdrakken"],
                  desc = "",
                  width = 0.80,
                  order = 14.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsValdrakken then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Valdrakken"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsValdrakken then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Valdrakken"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDornogal = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDornogal:GetIconString() .. " " .. L["Dornogal"],
                  desc = EXPANSION_NAME10,
                  width = 0.80,
                  order = 14.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDornogal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"],L["Dornogal"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDornogal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dornogal"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDarkmoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON,
                  desc = L["Starting on the first Sunday of each month for one week"],
                  width = 1.2,
                  order = 14.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            CapitalsInstanceTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 2,
              args = {
                capitalsinstanceheader1 = {
                  type = "description",
                  name = "",
                  order = 20,
                  width = 0.85,
                  },  
                CapitalsInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Activates the display of all possible icons on this map"],
                  width = 0.90,
                  order = 20.4,
                  get = function() return ns.Addon.db.profile.activate.CapitalsInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.CapitalsInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsInstances then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. INSTANCE .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsInstances then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. INSTANCE .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                capitalsinstanceheader2 = {
                  type = "description",
                  name = "",
                  order = 20.5,
                  },  
                capitalsinstanceheader3 = {
                  type = "description",
                  name = "",
                  order =20.6,
                  width = 0.20,
                  },  
                CapitalsInstanceScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 20.7,
                  },
                capitalsinstanceheader4 = {
                  type = "description",
                  name = "",
                  order = 20.8,
                  width = 0.20,
                  },
                CapitalsInstanceAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 20.9,
                  },
                capitalsinstanceheader5 = {
                  type = "header",
                  name = "",
                  order = 22.1,
                  },
                showCapitalsRaids = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
                  desc = L["Show icons of raids on this map"],
                  order = 22.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsInstancePassage = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances or ns.Addon.db.profile.activate.ClassicIcons end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
                  desc = L["Show icons of passage to raids and dungeons on this map"],
                  order = 22.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], INSTANCE, L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], INSTANCE, L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsMultiple = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
                  desc = L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 22.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
                  desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 22.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                  showCapitalsDungeons = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
                  desc = L["Show icons of dungeons on this map"],
                  order = 22.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsLFR = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 22.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                },
              },
            CapitalsTransportab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                capitalstransportheader1 = {
                  type = "description",
                  name = "",
                  order = 30,
                  width = 0.85,
                  },  
                CapitalsTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 30.4,
                  get = function() return ns.Addon.db.profile.activate.CapitalsTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.CapitalsTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " ..  L["Transport"] .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " ..  L["Transport"] .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                capitalstransportheader2 = {
                  type = "description",
                  name = "",
                  order = 30.5,
                  },  
                capitalstransportheader3 = {
                  type = "description",
                  name = "",
                  order = 30.6,
                  width = 0.20,
                  },  
                CapitalsTransportScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 30.7,
                  },
                capitalstransportheader4 = {
                  type = "description",
                  name = "",
                  order = 30.8,
                  width = 0.20,
                  },
                CapitalsTransportAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 30.9,
                  },
                capitalstransportheader5 = {
                  type = "header",
                  name = "",
                  order = 31.1,
                  },
                showCapitalsPortals = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. " " .. TextIconWayGateGolden:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"] .. "\n" .. TextIconWayGateGolden:GetIconString() .. " " .. L["The Timeways"] .. " " .. L["Portal"],                  order = 31.3,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. " " .. L["Zeppelins"],
                  desc = L["Show icons of zeppelins on this map"],
                  order = 31.4,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsShips = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconShipOld:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. " " .. L["Ships"],
                  desc = L["Show icons of ships on this map"],
                  order = 31.5,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsTransport = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " ".. TextIconCarriage:GetIconString() .. " " .. L["Transport"],
                  desc = L["Shows special transport icons like"] .. "\n\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n\n" .. " " .. TextIconTransport:GetIconString() .. " " .. L["Teleporter"] .. " - " .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"] .. "\n\n" .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
                  order = 31.6,
                  width = 1.20,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsFP = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconTravelL:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
                  desc = "",
                  order = 31.7,
                  width = 1.20,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsRaces = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconMoleMachine:GetIconString() .. " " .. RACES,
                  desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
                  order = 31.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], RACES, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], RACES, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            CapitalsProfessionTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "group",
              name = "• " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {       
                capitalsprofessionsheader1 = {
                  type = "description",
                  name = "",
                  order = 40,
                  width = 0.85,
                  },  
                CapitalsProfessions = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 40.2,
                  get = function() return ns.Addon.db.profile.activate.CapitalsProfessions end,
                  set = function(info, v) ns.Addon.db.profile.activate.CapitalsProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                capitalsprofessionsheader2 = {
                  type = "description",
                  name = "",
                  order = 40.3,
                  },  
                capitalsprofessionsheader3 = {
                  type = "description",
                  name = "",
                  order = 40.4,
                  width = 0.20,
                  },  
                CapitalsProfessionsScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1, 
                  order = 40.5,
                  },
                capitalsgeneralheader2 = {
                  type = "description",
                  name = "",
                  order = 40.6,
                  width = 0.20,
                  },
                CapitalsProfessionsAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1, 
                  order = 40.7,
                  },
                capitalsgeneralheader3 = {
                  type = "header",
                  name = "",
                  order = 40.8,
                  },
                showCapitalsProfessionDetection = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "toggle",
                  name = L["Profession detection"],
                  desc = L["Automatically detects your professions and activates the corresponding professions icons on this map"],
                  width = 1.2, 
                  order = 40.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        ns.AutomaticProfessionDetection()
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader5 = {
                  type = "description",
                  name = "",
                  order = 41.0,
                  },
                showCapitalsProfessionsMixed = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionsMixed:GetIconString() .. " " .. PROFESSIONS_BUTTON .. " +",
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"],
                  width = 1.2,
                  order = 41.7,
                  get = function() return ns.Addon.db.profile.showCapitalsProfessionsMixed end,
                  set = function(info, v) ns.Addon.db.profile.showCapitalsProfessionsMixed = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. TUTORIAL_TITLE38 .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. TUTORIAL_TITLE38 .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cffff0000" .. L["are hidden"]) end end end,
                  },
                showCapitalsProfessionOrders = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                  desc = PLACE_CRAFTING_ORDERS,
                  width = 1.2,
                  order = 41.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader6 = {
                  type = "header",
                  name = "",
                  order = 41.9,
                  },
                showCapitalsAlchemy = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
                  desc = "",
                  width = 1.2,
                  order = 42,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsEngineer = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconEngineer:GetIconString() .. " " .. L["Engineer"],
                  desc = "",
                  width = 1.2,
                  order = 42.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsJewelcrafting = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"],
                  desc = "",
                  width = 1.2,
                  order = 42.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Jewelcrafting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Jewelcrafting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsBlacksmith = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
                  desc = "",
                  width = 1.2,
                  order = 42.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Blacksmithing"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Blacksmithing"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsTailoring = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconTailoring:GetIconString() .. " " .. L["Tailoring"],
                  desc = "",
                  width = 1.2,
                  order = 42.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Tailoring"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Tailoring"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsSkinning = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconSkinning:GetIconString() .. " " .. L["Skinning"],
                  desc = "",
                  width = 1.2,
                  order = 42.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Skinning"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Skinning"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsMining = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconMining:GetIconString() .. " " .. L["Mining"],
                  desc = "",
                  width = 1.2,
                  order = 42.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Mining"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Mining"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsHerbalism = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"],
                  desc = "",
                  width = 1.2,
                  order = 42.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsInscription = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconInscription:GetIconString() .. " " .. INSCRIPTION,
                  desc = "",
                  width = 1.2,
                  order = 42.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, INSCRIPTION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, INSCRIPTION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsFishing = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
                  desc = "",
                  width = 1.2,
                  order = 43,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_FISHING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38,PROFESSIONS_FISHING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsCooking = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING,
                  desc = "",
                  width = 1.2,
                  order = 43.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsArchaeology = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY,
                  desc = "",
                  width = 1.2,
                  order = 43.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsEnchanting = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
                  desc = "",
                  width = 1.2,
                  order = 43.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Enchanting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Enchanting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsLeatherworking = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"],
                  desc = "",
                  width = 1.2,
                  order = 43.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            CapitalsGeneralTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                capitalsgeneralheader1 = {
                  type = "description",
                  name = "",
                  order = 50,
                  width = 0.85,
                  },  
                CapitalsGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Activates the display of all possible icons on this map"],
                  width = 0.90,
                  order = 50.4,
                  get = function() return ns.Addon.db.profile.activate.CapitalsGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.CapitalsGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsGeneral then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["General"] .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsGeneral then OpenWorldMap(uiMapID) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["General"] .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                capitalsgeneralheader2 = {
                  type = "description",
                  name = "",
                  order = 50.5,
                  },
                capitalsgeneralheader3 = {
                  type = "description",
                  name = "",
                  order = 50.6,
                  width = 0.20,
                  },
                CapitalsGeneralScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1, 
                  order = 50.8,
                  },
                capitalsgeneralheader4 = {
                  type = "description",
                  name = "",
                  order = 50.9,
                  width = 0.20,
                  },
                CapitalsGeneralAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1, 
                  order = 51,
                  },
                capitalsgeneralheader5 = {
                  type = "header",
                  name = "",
                  order = 51.2,
                  },
                showCapitalsMapNotes = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME,
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"] .. "\n" .. "...",
                  width = 0.80,
                  order = 52.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ns.COLORED_ADDON_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ns.COLORED_ADDON_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsPaths = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
                  desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.80,
                  order = 52.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER,
                  desc = "",
                  width = 0.80,
                  order = 52.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
                  desc = TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE,
                  width = 0.80,
                  order = 52.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsBank = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. BANK,
                  desc = "",
                  width = 0.80,
                  order = 52.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsBarber = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString() .. " " .. MINIMAP_TRACKING_BARBER,
                  desc = ORGRIMMAR .. "\n" .. L["Undercity"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. L["Dazar'alor"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Boralus"],
                  width = 0.80,
                  order = 53,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsMailbox = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
                  desc = "",
                  width = 0.80,
                  order = 53.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString() .. " " .. L["Catalyst"],
                  desc = L["Dornogal"],
                  width = 0.75,
                  order = 53.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " ..TextIconStablemasterA:GetIconString() .. " " .. MINIMAP_TRACKING_STABLEMASTER,
                  desc = "",
                  width = 0.90,
                  order = 53.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsDragonFlyTransmog = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconDragonFlyTransmog:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING,
                  desc = L["Valdrakken"],
                  width = 1.5,
                  order = 53.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDragonFlyTransmog then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDragonFlyTransmog then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER,
                  desc = FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. " " .. L["Valdrakken"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"] ,
                  width = 1,
                  order = 53.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString() .. " " .. ITEM_UPGRADE,
                  desc = L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. L["Dornogal"],
                  width = 1.2,
                  order = 53.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsPvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TRANSMOG_SET_PVP,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"],              
                  width = 0.50,
                  order = 53.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBattlemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBattlemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsPvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TRANSMOG_SET_PVE,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
                  width = 0.50,
                  order = 53.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBattlemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBattlemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsTradingPost = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconTradingPost:GetIconString() .. " " .. BATTLE_PET_SOURCE_12,
                  desc = "",
                  width = 1,
                  order = 53.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsTradingPost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BATTLE_PET_SOURCE_12, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsTradingPost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BATTLE_PET_SOURCE_12, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsMountMerchent = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
                  type = "toggle",
                  name = TextIconMountMerchant:GetIconString() .. " " .. PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT,
                  desc = "",
                  width = 1,
                  order = 54.0,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMountMerchent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMountMerchent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            },
          },
        MinimapCapitalsTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "group",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL,
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n\n" .. L["Capitals"] .. ":" .. "\n\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
          order = 2,
          args = {
            Capitalstheader1 = {
              disabled = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "header",
              name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["icons"],
              order = 1,
              },
            MinimapCapitalsDescriptionText = {
              name = "|cffff0000" .. L["Capitals"]  .. " " .. MINIMAP_LABEL .. " " .. L["icons"] .. "\n\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Capital"],
              type = "description",
              order = 1.1,
              },
            CapitalsMinimapTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "group",
              name = "• " .. L["Capitals"],
              desc = L["Enables the display of icons for a specific capital city"],
              order = 2,
              args = {
                MinimapCapitalsheader1 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. FACTION_HORDE,
                  order = 80.4,
                  },
                showMinimapCapitalsOrgrimmar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconOrgrimmar:GetIconString() .. " " .. ORGRIMMAR,
                  desc = "",
                  width = 0.80,
                  order = 80.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], ORGRIMMAR, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], ORGRIMMAR, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsThunderBluff = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconThunderBluff:GetIconString() .. " " .. L["Thunder Bluff"],
                  desc = "",
                  width = 0.80,
                  order = 80.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsSilvermoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconSilvermoon:GetIconString() .. " " .. L["Silvermoon City"],
                  desc = "",
                  width = 0.80,
                  order = 80.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapSilvermoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Silvermoon City"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapSilvermoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Silvermoon City"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsUndercity = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconUndercity:GetIconString() .. " " .. L["Undercity"],
                  desc = "",
                  width = 0.80,
                  order = 80.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Undercity"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Undercity"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDazarAlor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDazarAlor:GetIconString() .. " " .. L["Dazar'alor"],
                  desc = "",
                  width = 0.80,
                  order = 80.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDazarAlor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dazar'alor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDazarAlor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dazar'alor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsSot2M = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconSot2M:GetIconString() .. " " .. L["Shrine2Moons"],
                  desc = EXPANSION_NAME4,
                  width = 0.90,
                  order = 81,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsSot2M then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shrine2Moons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsSot2M then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shrine2Moons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsWarspear = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconWarspear:GetIconString() .. " " .. L["Warspear"] .. " / " .. GARRISON_LOCATION_TOOLTIP,
                  desc = "",
                  width = 1.40,
                  order = 81.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsWarspear then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Warspear"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsWarspear then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Warspear"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader7 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. FACTION_ALLIANCE,
                  order = 82,
                  },
                showMinimapCapitalsStormwind = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconStormwind:GetIconString() .. " " .. L["Stormwind"],
                  desc = "",
                  width = 0.80,
                  order = 82.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsStormwind then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Stormwind"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsStormwind then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Stormwind"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsIronforge = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconIronforge:GetIconString() .. " " .. L["Ironforge"],
                  desc = "",
                  width = 0.80,
                  order = 82.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsIronforge then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Ironforge"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsIronforge then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Ironforge"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDarnassus = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDarnassus:GetIconString() .. " " .. L["Darnassus"],
                  desc = "",
                  width = 0.80,
                  order = 82.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Darnassus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], L["Darnassus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsExodar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconExodar:GetIconString() .. " " .. L["Exodar"],
                  desc = "",
                  width = 0.80,
                  order = 82.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsExodar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Exodar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsExodar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], L["Exodar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsBoralus = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconBoralus:GetIconString() .. " " .. L["Boralus"],
                  desc = "",
                  width = 0.80,
                  order = 82.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsBoralus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Boralus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsBoralus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Boralus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsSot7S = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconSot7S:GetIconString() .. " " .. L["Shrine7Stars"],
                  desc = EXPANSION_NAME4,
                  width = 0.90,
                  order = 82.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsSot7S then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shrine7Stars"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsSot7S then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shrine7Stars"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsStormshield = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconStormshield:GetIconString() .. " " .. L["Stormshield"] .. " / " .. GARRISON_LOCATION_TOOLTIP,
                  desc = "",
                  width = 1.40,
                  order = 82.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsStormshield then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Stormshield"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsStormshield then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Stormshield"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader8 = {
                  type = "header",
                  name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. FACTION_NEUTRAL,
                  order = 83,
                  },
                showMinimapCapitalsShattrath = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconShattrath:GetIconString() .. " " .. L["Shattrath City"],
                  desc = "",
                  width = 0.80,
                  order = 83.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsShattrath then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shattrath City"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsShattrath then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Shattrath City"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDalaranNorthrend = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDalaranNorthrend:GetIconString() .. " " .. DUNGEON_FLOOR_DALARAN1,
                  desc = DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND,
                  width = 0.80,
                  order = 83.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDalaranNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDalaranNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. POSTMASTER_PIPE_NORTHREND, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDalaranLegion = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDalaranLegion:GetIconString() .. " " .. DUNGEON_FLOOR_DALARAN1,
                  desc = DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6,
                  width = 0.80,
                  order = 83.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDalaranLegion then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDalaranLegion then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_DALARAN1 .. "-" .. EXPANSION_NAME6, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsOribos = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconOribos:GetIconString() .. " " .. L["Oribos"],
                  desc = "",
                  width = 0.80,
                  order = 83.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsOribos then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Oribos"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsOribos then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Oribos"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsValdrakken = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconValdrakken:GetIconString() .. " " .. L["Valdrakken"],
                  desc = "",
                  width = 0.80,
                  order = 83.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsValdrakken then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Valdrakken"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsValdrakken then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Valdrakken"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDornogal = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDornogal:GetIconString() .. " " .. L["Dornogal"],
                  desc = EXPANSION_NAME10,
                  width = 0.80,
                  order = 83.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDornogal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dornogal"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDornogal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dornogal"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDarkmoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON,
                  desc = L["Starting on the first Sunday of each month for one week"],
                  width = 1.2,
                  order = 83.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            InstanceMinimapTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                minimapcapitalinstanceheader1 = {
                  type = "description",
                  name = "",
                  order = 82,
                  width = 0.85,
                  },     
                MinimapCapitalsInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Activates the display of all possible icons on this map"],
                  width = 0.90,
                  order = 82.1,
                  get = function() return ns.Addon.db.profile.activate.MinimapCapitalsInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"],INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"],INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapcapitalinstanceheader2 = {
                  type = "description",
                  name = "",
                  order = 82.2,
                  },
                minimapcapitalinstanceheader3 = {
                  type = "description",
                  name = "",
                  order = 82.3,
                  width = 0.20,
                  },
                MinimapCapitalsInstanceScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 82.4,
                  },
                minimapcapitalinstanceheader4 = {
                  type = "description",
                  name = "",
                  order = 82.5,
                  width = 0.20,
                  },
                MinimapCapitalsInstanceAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 82.6,
                  },
                minimapcapitalinstanceheader5 = {
                  type = "header",
                  name = "",
                  order = 83,
                  },
                showMinimapCapitalsRaids = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
                  desc = L["Show icons of raids on this map"],
                  order = 83.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsInstancePassage = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.activate.ClassicIcons end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
                  desc = L["Show icons of passage to raids and dungeons on this map"],
                  order = 83.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], INSTANCE, L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], INSTANCE, L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsMultiple = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
                  desc = L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 83.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
                  desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 83.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                  showMinimapCapitalsDungeons = {
                    disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
                  desc = L["Show icons of dungeons on this map"],
                  order = 83.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsLFR = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 83.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                },
              },
            TransportMinimapTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {
                minimapcapitaltransportheader1 = {
                  type = "description",
                  name = "",
                  order = 84,
                  width = 0.85,
                  },     
                MinimapCapitalsTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 84.1,
                  get = function() return ns.Addon.db.profile.activate.MinimapCapitalsTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapcapitaltransportheader2 = {
                  type = "description",
                  name = "",
                  order = 84.2,
                  },
                minimapcapitaltransportheader3 = {
                  type = "description",
                  name = "",
                  order = 84.3,
                  width = 0.20,
                  },
                MinimapCapitalsTransportScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 84.4,
                  },
                minimapcapitaltransportheader4 = {
                  type = "description",
                  name = "",
                  order = 84.5,
                  width = 0.20,
                  },
                MinimapCapitalsTransportAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 84.6,
                  },
                minimapcapitaltransportheader5 = {
                  type = "header",
                  name = "",
                  order = 84.7,
                  },
                showMinimapCapitalsPortals = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. " " .. TextIconWayGateGolden:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"] .. "\n" .. TextIconWayGateGolden:GetIconString() .. " " .. L["The Timeways"] .. " " .. L["Portal"],
                  order = 85,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. " " .. L["Zeppelins"],
                  desc = L["Show icons of zeppelins on this map"],
                  order = 85.1,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsShips = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. " " .. L["Ships"],
                  desc = L["Show icons of ships on this map"],
                  order = 85.2,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsTransport = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " ".. TextIconCarriage:GetIconString() .. " " .. L["Transport"],
                  desc = L["Shows special transport icons like"] .. "\n\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n\n" .. " " .. TextIconTransport:GetIconString() .. " " .. L["Teleporter"] .. " - " .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"] .. "\n\n" .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
                  order = 85.3,
                  width = 1.20,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsFP = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconTravelL:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
                  desc = "",
                  order = 85.4,
                  width = 1.20,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " ..L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsRaces = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconMoleMachine:GetIconString() .. " " .. RACES,
                  desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
                  order = 85.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, RACES, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, RACES, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            ProfessionMinimapTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "group",
              name = "• " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                minimapcapitalprofessionheader1 = {
                  type = "description",
                  name = "",
                  order = 86,
                  width = 0.85,
                  },     
                MinimapCapitalsProfessions = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 86.1,
                  get = function() return ns.Addon.db.profile.activate.MinimapCapitalsProfessions end,
                  set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapcapitalprofessionheader2 = {
                  type = "description",
                  name = "",
                  order = 86.2,
                  },
                minimapcapitalprofessionheader3 = {
                  type = "description",
                  name = "",
                  order = 86.3,
                  width = 0.20,
                  },
                MinimapCapitalsProfessionsScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,   
                  order = 86.4,
                  },
                minimapcapitalprofessionheader4 = {
                  type = "description",
                  name = "",
                  order = 86.5,
                  width = 0.20,
                  },
                MinimapCapitalsProfessionsAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,  
                  order = 86.6,
                  },
                Capitalsheader5 = {
                  type = "header",
                  name = "",
                  order = 86.7,
                  },                  
                showMinimapCapitalsProfessionDetection = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = MINIMAP_LABEL .. " " .. L["Profession detection"],
                  desc = L["Automatically detects your professions and activates the corresponding professions icons on this map"],
                  width = 1.2, 
                  order = 86.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        ns.AutomaticProfessionDetection()
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                Capitalsheader6 = {
                  type = "description",
                  name = "",
                  order = 86.9,
                  },       
                showMinimapCapitalsProfessionsMixed = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionsMixed:GetIconString() .. " " .. PROFESSIONS_BUTTON .. " +",
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"],
                  width = 1.2,
                  order = 87.7,
                  get = function() return ns.Addon.db.profile.showMinimapCapitalsProfessionsMixed end,
                  set = function(info, v) ns.Addon.db.profile.showMinimapCapitalsProfessionsMixed = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38 .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38 .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cffff0000" .. L["are hidden"]) end end end,
                  },
                showMinimapCapitalsProfessionOrders = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                  desc = PLACE_CRAFTING_ORDERS,
                  width = 1.2,
                  order = 87.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                minimapcapitalprofessionheader5 = {
                  type = "header",
                  name = "",
                  order = 87.9,
                  },
                showMinimapCapitalsAlchemy = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
                  desc = "",
                  width = 1.2,
                  order = 88.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsEngineer = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconEngineer:GetIconString() .. " " .. L["Engineer"],
                  desc = "",
                  width = 1.2,
                  order = 88.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsJewelcrafting = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"],
                  desc = "",
                  width = 1.2,
                  order = 88.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Jewelcrafting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Jewelcrafting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsBlacksmith = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
                  desc = "",
                  width = 1.2,
                  order = 88.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Blacksmithing"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Blacksmithing"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsTailoring = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconTailoring:GetIconString() .. " " .. L["Tailoring"],
                  desc = "",
                  width = 1.2,
                  order = 88.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Tailoring"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Tailoring"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsSkinning = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconSkinning:GetIconString() .. " " .. L["Skinning"],
                  desc = "",
                  width = 1.2,
                  order = 88.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Skinning"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Skinning"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsMining = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconMining:GetIconString() .. " " .. L["Mining"],
                  desc = "",
                  width = 1.2,
                  order = 88.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Mining"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Mining"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsHerbalism = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"],
                  desc = "",
                  width = 1.2,
                  order = 88.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsInscription = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconInscription:GetIconString() .. " " .. INSCRIPTION,
                  desc = "",
                  width = 1.2,
                  order = 88.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, INSCRIPTION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, INSCRIPTION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsFishing = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
                  desc = "",
                  width = 1.2,
                  order = 89,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_FISHING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38,PROFESSIONS_FISHING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsCooking = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING,
                  desc = "",
                  width = 1.2,
                  order = 89.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsArchaeology = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY,
                  desc = "",
                  width = 1.2,
                  order = 89.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsEnchanting = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
                  desc = "",
                  width = 1.2,
                  order = 89.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Enchanting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Enchanting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsLeatherworking = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
                  type = "toggle",
                  name = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"],
                  desc = "",
                  width = 1.2,
                  order = 89.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            GeneralMinimapCapitalTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 6,
              args = {
                minimapcapitalgeneralheader1 = {
                  type = "description",
                  name = "",
                  order = 89,
                  width = 0.85,
                  },   
                MinimapCapitalsGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Activates the display of all possible icons on this map"],
                  width = 0.90,
                  order = 89.1,
                  get = function() return ns.Addon.db.profile.activate.MinimapCapitalsGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapcapitalgeneralheader2 = {
                  type = "description",
                  name = "",
                  order = 89.2,
                  },
                minimapcapitalgeneralheader3 = {
                  type = "description",
                  name = "",
                  order = 89.3,
                  width = 0.20,
                  },
                MinimapCapitalsGeneralScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1, 
                  order = 89.4,
                  },
                 minimapcapitalgeneralheader4 = {
                  type = "description",
                  name = "",
                  order = 89.5,
                  width = 0.20,
                  },
                MinimapCapitalsGeneralAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1, 
                  order = 89.6,
                  },
                minimapcapitalgeneralheader5 = {
                  type = "header",
                  name = "",
                  order = 89.7,
                  },
                showMinimapCapitalsMapNotes = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME,
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"] .. "\n" .. "...",
                  width = 0.80,
                  order = 90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], ns.COLORED_ADDON_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], ns.COLORED_ADDON_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsPaths = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
                  desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.80,
                  order = 90.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER,
                  desc = "",
                  width = 0.80,
                  order = 90.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
                  desc = TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE,
                  width = 0.80,
                  order = 90.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsBank = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. BANK,
                  desc = "",
                  width = 0.80,
                  order = 90.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsBarber = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString() .. " " .. MINIMAP_TRACKING_BARBER,
                  desc = ORGRIMMAR .. "\n" .. L["Undercity"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. L["Dazar'alor"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Boralus"],
                  width = 0.80,
                  order = 90.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsMailbox = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
                  desc = "",
                  width = 0.80,
                  order = 90.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString() .. " " .. L["Catalyst"],
                  desc = L["Dornogal"],
                  width = 0.75,
                  order = 90.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " ..TextIconStablemasterA:GetIconString() .. " " .. MINIMAP_TRACKING_STABLEMASTER,
                  desc = "",
                  width = 0.90,
                  order = 90.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsDragonFlyTransmog = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconDragonFlyTransmog:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING,
                  desc = L["Valdrakken"] .. "\n" .. L["Dornogal"],
                  width = 1.5,
                  order = 90.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDragonFlyTransmog then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDragonFlyTransmog then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER .. " " .. MOUNT_JOURNAL_FILTER_DRAGONRIDING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER,
                  desc = FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. " " .. L["Valdrakken"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"] ,
                  width = 1,
                  order = 91,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString() .. " " .. ITEM_UPGRADE,
                  desc = L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. L["Dornogal"],
                  width = 1.2,
                  order = 91.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsPvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TRANSMOG_SET_PVP,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"],              
                  width = 0.50,
                  order = 91.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsPvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TRANSMOG_SET_PVE,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
                  width = 0.50,
                  order = 91.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsTradingPost = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconTradingPost:GetIconString() .. " " .. BATTLE_PET_SOURCE_12,
                  desc = "",
                  width = 1,
                  order = 91.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsTradingPost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], BATTLE_PET_SOURCE_12, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsTradingPost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], BATTLE_PET_SOURCE_12, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsMountMerchent = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconMountMerchant:GetIconString() .. " " .. PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT,
                  desc = "",
                  width = 1,
                  order = 91.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMountMerchent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMountMerchent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PERKS_VENDOR_CATEGORY_MOUNT .. " " .. MERCHANT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            },
          },
        },
      },
    ZoneAndMiniMapTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Zones"] .. " +",
      desc = "|cffffff00" .. L["Zones"] .. "-" .. MINIMAP_LABEL .. "|r" .. "\n\n" .. L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 2,
      args = {
        SyncZoneAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Zones tab with the Minimap tab"] .. "\n\n" .. L["Which deactivates the functions from the Minimap tab and is now controlled together by the Zones tab"] .. "\n\n" .. "|cffff0000" .. L["This will delete all Minimap settings and replace them with those from Zones tab"],
          width = 2.5,
          order = 20.3,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncZoneAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " ..  MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        zoneheader1 = {
          type = "header",
          name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["icons"],
          order = 21,
          },
        showZoneMap = {
          type = "toggle",
          name = L["Zones"] .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          width = 1.80,
          order = 21.1,
          get = function() return ns.Addon.db.profile.activate.ZoneMap end,
          set = function(info, v) ns.Addon.db.profile.activate.ZoneMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.ZoneMap and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(1) else 
                if not ns.Addon.db.profile.activate.ZoneMap and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(1) else
                if ns.Addon.db.profile.activate.ZoneMap and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(37) else 
                if not ns.Addon.db.profile.activate.ZoneMap and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(37) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end end end,
              },
        ZoneEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = L["Zone map"] .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"] .. "\n\n" .. L["By deactivating it, the border of the zone icons of your own factions is also removed, as the displayed icons are automatically only for your own faction"],
          order = 21.2,
          width = 1.5,
          get = function() return ns.Addon.db.profile.activate.ZoneEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.ZoneEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.ZoneEnemyFaction and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(1) else 
                if not ns.Addon.db.profile.activate.ZoneEnemyFaction and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(1) else
                if ns.Addon.db.profile.activate.ZoneEnemyFaction and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(37) else 
                if not ns.Addon.db.profile.activate.ZoneEnemyFaction and (not ns.AllZoneIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(37) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"] .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end end end end end,
              },
        zoneheader2 = {
          type = "header",
          name = MINIMAP_LABEL .. " " .. L["Zones"] .. " " .. L["icons"],
          order = 21.3,
          },
        showMiniMapMap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = MINIMAP_LABEL .. " " .. L["Zones"] .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          width = 1.80,
          order = 21.4,
          get = function() return ns.Addon.db.profile.activate.MiniMap end,
          set = function(info, v) ns.Addon.db.profile.activate.MiniMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        MiniMapEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.activate.SyncZoneAndMinimap or not ns.Addon.db.profile.activate.MiniMap end,
          type = "toggle",
          name = L["Zones"] .. "-" .. MINIMAP_LABEL .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"] .. "\n\n" .. L["By deactivating it, the border of the zone icons of your own factions is also removed, as the displayed icons are automatically only for your own faction"],
          order = 21.5,
          width = 1.8,
          get = function() return ns.Addon.db.profile.activate.MiniMapEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.MiniMapEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        ZoneMapTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAP,
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
          order = 1,
          args = {
            ZoneDescriptionText = {
              name = "|cffff0000" .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAP .. " " .. L["icons"] .. "\n\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Continent"],
              type = "description",
              order = 10.1,
              },
            ZoneContinentTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. CONTINENT .. " " .. BRAWL_TOOLTIP_MAPS,
              desc = "",
              order = 1,
              args = {
                --zonecontinentheader1 = {
                --  type = "header",
                --  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. CONTINENT .. " " .. L["icons"],
                --  order = 0.1,
                --  },
                zonecontinentheader3 = {
                  type = "header",
                  name = L["Displays zone icons on a specific continent"],
                  order = 0.3,
                  },
                zonecontinentheader4 = {
                  type = "description",
                  name = "\n",
                  order = 0.4,
                  },     
                showZoneKalimdor= {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
                  desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneEasternKingdom = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
                  desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneOutland = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconBC:GetIconString() .. " " .. L["Outland"],
                  desc = L["Show all Outland MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneNorthrend = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
                  desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZonePandaria = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
                  desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Pandaria"], L["icons"],L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneDraenor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconDraenor:GetIconString() .. " " .. L["Draenor"],
                  desc = L["Show all Draenor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneBrokenIsles = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
                  desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneZandalar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
                  desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneKulTiras = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
                  desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneShadowlands = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconSL:GetIconString() .. " " .. L["Shadowlands"],
                  desc = L["Show all Shadowlands MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneDragonIsles = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
                  desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },   
                showZoneKhazAlgar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
                  desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },   
                },
              },
            ZoneProfessionTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"],
              desc = " • " .. EXPANSION_NAME4 .. "\n" .. " • " .. EXPANSION_NAME10 .. " ( " .. L["City of Threads"] .. " )",
              order = 2,
              args = {       
                Zoneprofessionsheader1 = {
                  type = "description",
                  name = "",
                  order = 40,
                  width = 0.85,
                  },  
                ZoneProfessions = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 40.1,
                  get = function() return ns.Addon.db.profile.activate.ZoneProfessions end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"] .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"] .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                Zoneprofessionsheader2 = {
                  type = "description",
                  name = "",
                  order = 40.3,
                  },  
                Zoneprofessionsheader3 = {
                  type = "description",
                  name = "",
                  order = 40.4,
                  width = 0.20,
                  },  
                ZoneProfessionsScale = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1, 
                  order = 40.5,
                  },
                Zonegeneralheader2 = {
                  type = "description",
                  name = "",
                  order = 40.6,
                  width = 0.20,
                  },
                ZoneProfessionsAlpha = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1, 
                  order = 40.7,
                  },
                Zonegeneralheader3 = {
                  type = "header",
                  name = "",
                  order = 40.8,
                  },
                showZoneProfessionDetection = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions end,
                  type = "toggle",
                  name = L["Profession detection"],
                  desc = L["Automatically detects your professions and activates the corresponding professions icons on this map"],
                  width = 1.2, 
                  order = 40.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        ns.AutomaticProfessionDetection()
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                --showZoneProfessionOrders = {
                --  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions end,
                --  type = "toggle",
                --  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                --  desc = PLACE_CRAFTING_ORDERS,
                --  width = 1.2,
                --  order = 41.2,
                --  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                --        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                --        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                --  },
                ZoneProfessionsMixed = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions end,
                  type = "toggle",
                  name = TextIconProfessionsMixed:GetIconString() .. " " .. PROFESSIONS_BUTTON .. " +",
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"],
                  width = 1.2,
                  order = 41.3,
                  get = function() return ns.Addon.db.profile.ZoneProfessionsMixed end,
                  set = function(info, v) ns.Addon.db.profile.ZoneProfessionsMixed = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.ZoneProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"] .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.ZoneProfessionsMixed then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"] .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                Zoneheader4 = {
                  type = "header",
                  name = "",
                  order = 41.4,
                  },
                showZoneAlchemy = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
                  desc = "",
                  width = 1.2,
                  order = 42,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Alchemy"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Alchemy"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneEngineer = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconEngineer:GetIconString() .. " " .. L["Engineer"],
                  desc = "",
                  width = 1.2,
                  order = 42.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneJewelcrafting = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"],
                  desc = "",
                  width = 1.2,
                  order = 42.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Jewelcrafting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Jewelcrafting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneBlacksmith = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
                  desc = "",
                  width = 1.2,
                  order = 42.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Blacksmithing"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Blacksmithing"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneTailoring = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconTailoring:GetIconString() .. " " .. L["Tailoring"],
                  desc = "",
                  width = 1.2,
                  order = 42.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Tailoring"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Tailoring"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneSkinning = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconSkinning:GetIconString() .. " " .. L["Skinning"],
                  desc = "",
                  width = 1.2,
                  order = 42.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Skinning"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Skinning"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneMining = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconMining:GetIconString() .. " " .. L["Mining"],
                  desc = "",
                  width = 1.2,
                  order = 42.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Mining"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Mining"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneHerbalism = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"],
                  desc = "",
                  width = 1.2,
                  order = 42.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneInscription = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconInscription:GetIconString() .. " " .. INSCRIPTION,
                  desc = "",
                  width = 1.2,
                  order = 42.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], INSCRIPTION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], INSCRIPTION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneFishing = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
                  desc = "",
                  width = 1.2,
                  order = 43,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_FISHING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"],PROFESSIONS_FISHING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneCooking = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING,
                  desc = "",
                  width = 1.2,
                  order = 43.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneArchaeology = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY,
                  desc = "",
                  width = 1.2,
                  order = 43.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneEnchanting = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
                  desc = "",
                  width = 1.2,
                  order = 43.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Enchanting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Enchanting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneLeatherworking = {
                  disabled = function() return not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneProfessions or ns.Addon.db.profile.showZoneProfessionDetection end,
                  type = "toggle",
                  name = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"],
                  desc = "",
                  width = 1.2,
                  order = 43.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zones"], L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            ZoneInstanceTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                --zoneinstanceheader1 = {
                --  type = "header",
                --  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. INSTANCE .. " " .. L["icons"],
                --  order = 1.1,
                --  },
                zoneinstanceheader3 = {
                  type = "description",
                  name = "",
                  order = 1.0,
                  width = 0.45,
                  },   
                ZoneInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 1.2,
                  get = function() return ns.Addon.db.profile.activate.ZoneInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                ZoneInstanceSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. INSTANCE .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 1.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], INSTANCE, L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], INSTANCE, L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                ZoneSyncHeader1 = {
                  type = "description",
                  name = "",
                  order = 1.5,
                  },
                zoneinstanceheader5 = {
                  type = "description",
                  name = "",
                  order = 1.6,
                  width = 0.25,
                  },
                ZoneInstanceScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or not ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 1.7,
                  },
                zoneinstanceheader6 = {
                  type = "description",
                  name = "",
                  order = 1.8,
                  width = 0.10,
                  },
                ZoneInstanceAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or not ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 1.9,
                  },
                zoneinstanceheader8 = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 2.0,
                  },
                showZoneRaids = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString(),
                  desc = L["Raids"],
                  order = 2.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleRaids = {
                  disabled = function() return not ns.Addon.db.profile.showZoneRaids or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                zoneHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                ZoneAlphaRaids = {
                  disabled = function() return not ns.Addon.db.profile.showZoneRaids or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                zoneiraidsheader9 = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showZoneDungeons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString(),
                  desc = L["Dungeons"],
                  order = 3.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                 ZoneScaleDungeons = {
                  disabled = function() return not ns.Addon.db.profile.showZoneDungeons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                zoneHeaderScaleAlpha1 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                ZoneAlphaDungeons = {
                  disabled = function() return not ns.Addon.db.profile.showZoneDungeons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                zoneDungeonsHeader = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showZonePassage = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or ns.Addon.db.profile.activate.ClassicIcons or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconDelvesPassage:GetIconString(),
                  desc = L["Passages"] .. "\n\n" .. L["Show icons of passage to raids and dungeons on this map"],
                  order = 4.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScalePassage = {
                  disabled = function() return not ns.Addon.db.profile.showZonePassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                zoneHeaderScaleAlpha2 = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                ZoneAlphaPassage = {
                  disabled = function() return not ns.Addon.db.profile.showZonePassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4
                  },
                zonePassageHeader = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showZoneMultiple = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString(),
                  desc = L["Multiple"] .. "\n\n" .. " " ..L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 5.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleMultiple = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMultiple or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                zoneHeaderScaleAlpha6 = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                ZoneAlphaMultiple = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMultiple or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                zoneMultipleHeader = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showZoneOldVanilla = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString(),
                  desc = L["Old Instances"] .. "\n\n" .. " " .. L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 6.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                ZoneScaleOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.showZoneOldVanilla or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                zoneHeaderScaleAlpha7 = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                ZoneAlphaOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.showZoneOldVanilla or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                zoneOldVanillaHeader = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showZoneLFR = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString(),
                  desc = PLAYER_DIFFICULTY3 .. "\n\n" .. " " .. L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 7.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 "..  L["Zone map"], PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 "..  L["Zone map"], PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                ZoneScaleLFR = {
                  disabled = function() return not ns.Addon.db.profile.showZoneLFR or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                zoneHeaderScaleAlpha8 = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                ZoneAlphaLFR = {
                  disabled = function() return not ns.Addon.db.profile.showZoneLFR or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances or ns.Addon.db.profile.activate.ZoneInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                zoneLFRHeader = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                },
              },
            ZoneTransportTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {
                --zonetransportheader1 = {
                --  type = "header",
                --  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Transport"] .. " " .. L["icons"],
                --  order = 2.1,
                --  },
                zonetransportheader3 = {
                  type = "description",
                  name = "",
                  order = 1.0,
                  width = 0.45,
                  },    
                ZoneTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 1.2,
                  get = function() return ns.Addon.db.profile.activate.ZoneTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                ZoneTransportSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Transport"] .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 1.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], L["Transport"], L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], L["Transport"], L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zonetransportheader4 = {
                  type = "description",
                  name = "",
                  order = 1.4,
                  },
                zonetransportheader5 = {
                  type = "description",
                  name = "",
                  order = 1.5,
                  width = 0.25,
                  },
                ZoneTransportScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or not ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 1.6,
                  },
                zonetransportheader6 = {
                  type = "description",
                  name = "",
                  order = 1.7,
                  width = 0.10,
                  },
                ZoneTransportAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or not ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 1.8,
                  },
                zonetransportheader1 = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 1.9,
                  },
                showZonePortals = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconPortalOld:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString() .. " " .. TextIconTorghastUp:GetIconString(),
                  desc = L["Portals"] .. "\n" .."\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconTorghastUp:GetIconString() .. " " .. L["Torghast"] .. " " .. L["Portal"],
                  order = 2.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScalePortals = {
                  disabled = function() return not ns.Addon.db.profile.showZonePortals or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                zoneHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                ZoneAlphaPortals = {
                  disabled = function() return not ns.Addon.db.profile.showZonePortals or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                zonetransportheader2 = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showZoneZeppelins = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString(),
                  desc = L["Zeppelins"],
                  order = 3.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.showZoneZeppelins or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                zoneHeaderScaleAlphaZeppelins = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                ZoneAlphaZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.showZoneZeppelins or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                zonetransportheader9 = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showZoneShips = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString(),
                  desc = L["Ships"],
                  order = 4.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleShips = {
                  disabled = function() return not ns.Addon.db.profile.showZoneShips or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                zoneHeaderScaleAlphaShips = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                ZoneAlphaShips = {
                  disabled = function() return not ns.Addon.db.profile.showZoneShips or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4,
                  },
                zonetransportheaderShips = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showZoneTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconCarriage:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconMoleMachine:GetIconString() .. " " .. TextIconRocketDrill:GetIconString(),
                  desc = L["Transport"] .. " " .. "\n" .."\n" .. TextIconCarriage:GetIconString() .. " " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " " .. L["Stormwind"] .. " <= => "  .. L["Ironforge"] .. "\n" .. TextIconTravelL:GetIconString() .. " " .. L["Transport"] .. "\n" .. " " .. L["Korthia"] .. " <= => " .. L["The Maw"] .. "\n" .. TextIconMoleMachine:GetIconString() .. " - " .. TextIconRocketDrill:GetIconString() .. " " .. L["Mole Machine"] .. "\n" .. " (" .. EXPANSION_NAME10 .. ")",
                  order = 5.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleTransport = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                zoneHeaderScaleAlphaTransport = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                ZoneAlphaTransport = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                zonetransportheaderOgreWaygate = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showZoneOgreWaygate = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString(),
                  desc = L["Ogre Waygate"] .. "\n" .."\n" .. " " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] ,
                  order = 6.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ogre Waygate"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ogre Waygate"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleOgreWaygate = {
                  disabled = function() return not ns.Addon.db.profile.showZoneOgreWaygate or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                zoneHeaderScaleAlphaOgreWaygate = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                ZoneAlphaOgreWaygate = {
                  disabled = function() return not ns.Addon.db.profile.showZoneOgreWaygate or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                zonetransportheaderTeleporter = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showZoneTeleporter = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconTransport:GetIconString(),
                  desc = L["Teleporter"] .. "\n\n" .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"],
                  order = 7.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Teleporter"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Teleporter"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleTeleporter = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTeleporter or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                zoneHeaderScaleAlphaTeleporter = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                ZoneAlphaTeleporter = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTeleporter or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                zonetransportheaderTeleporter4 = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                showZoneMirror = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconMirror:GetIconString(),  
                  desc = L["Ever-Shifting Mirror"] .. " (" .. TOY .. ")" .. "\n" .."\n" .. " " .. POSTMASTER_PIPE_OUTLAND .. " <= => " .. POSTMASTER_PIPE_DRAENOR,
                  order = 8.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMirror then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ever-Shifting Mirror"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMirror then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ever-Shifting Mirror"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleMirror = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMirror or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 8.2,
                  },
                zoneHeaderScaleAlphaMirror = {
                  type = "description",
                  name = "",
                  order = 8.3,
                  width = 0.10,
                  },
                ZoneAlphaMirror = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMirror or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 8.4,
                  },
                zonetransportheaderMirror = {
                  type = "description",
                  name = "",
                  order = 9.0,
                  },
                showZoneTravel = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconDwarfF:GetIconString() .. " " .. TextIconB11M:GetIconString() .. " " .. TextIconGoblinF:GetIconString(), 
                  desc = L["Travel"] .. "\n\n" .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Nazmir"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconGilneanF:GetIconString() .. " " .. L["Zuldazar"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconKulM:GetIconString() .. " " .. L["Vol'dun"] .. " => " .. L["Boralus"] .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. TextIconOrcF:GetIconString() .. " " .. L["Drustvar"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconB11M:GetIconString() .. " " .. L["Tiragarde Sound"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconUndeadF:GetIconString() .. " " .. L["Stormsong Valley"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconGoblinF:GetIconString() .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " => " .. L["Zuldazar"],
                  order = 9.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Travel"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Travel"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleTravel = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTravel or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 9.2,
                  },
                zoneHeaderScaleAlphaTravel = {
                  type = "description",
                  name = "",
                  order = 9.3,
                  width = 0.10,
                  },
                ZoneAlphaTravel = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTravel or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 9.4,
                  },
                zoneDarkmoonheader1 = {
                  type = "description",
                  name = "",
                  order = 10.0,
                  },
                showZoneDarkmoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconDarkMoon:GetIconString(),
                  desc = CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
                  order = 10.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDarkmoon then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], CALENDAR_FILTER_DARKMOON, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleDarkmoon = {
                  disabled = function() return not ns.Addon.db.profile.showZoneDarkmoon or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 10.2,
                  },
                zoneHeaderScaleAlphaDarkmoon = {
                  type = "description",
                  name = "",
                  order = 10.3,
                  width = 0.10,
                  },
                ZoneAlphaDarkmoon = {
                  disabled = function() return not ns.Addon.db.profile.showZoneDarkmoon or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 10.4,
                  },
                zoneRacesHeader = {
                  type = "description",
                  name = "",
                  order = 11.0,
                  },
                showZoneRaces = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = RACES,
                  desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
                  width = 0.50,
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], RACES, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], RACES, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleRaces = {
                  disabled = function() return not ns.Addon.db.profile.showZoneRaces or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 11.2,
                  },
                zoneHeaderScaleAlpha15 = {
                  type = "description",
                  name = "",
                  order = 11.3,
                  width = 0.10,
                  },
                ZoneAlphaRaces = {
                  disabled = function() return not ns.Addon.db.profile.showZoneRaces or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting or ns.Addon.db.profile.activate.ZoneTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 11.4,
                  },
                },
              },
            ZoneGeneralTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                --zonegeneralheader1 = {
                --  type = "header",
                --  name = L["General"] .. " " .. L["symbol size"] .. " - " .. L["symbol visibility"],
                --  order = 1.1,
                --  },  
                ZoneGeneralHeader1 = {
                  type = "description",
                  name = "",
                  order = 0.1,
                  width = 0.45,
                  },            
                ZoneGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 0.2,
                  get = function() return ns.Addon.db.profile.activate.ZoneGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                ZoneGeneralSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["General"] .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 0.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], L["General"], L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Zones"], L["General"], L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zoneSyncHeader1 = {
                  type = "description",
                  name = "",
                  order = 0.5,
                  },
                zoneSyncHeader2 = {
                  type = "description",
                  name = "",
                  order = 0.6,
                  width = 0.25,
                  },
                ZoneGeneralScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or not ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 0.7,
                  },
                zonegeneralheader6 = {
                  type = "description",
                  name = "",
                  order = 0.8,
                  width = 0.10,
                  },
                ZoneGeneralAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or not ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 0.9,
                  },
                zoneMNHeader = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 1.0,
                  },
                showZoneMapNotesIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconMNL4:GetIconString(),
                  desc = ns.COLORED_ADDON_NAME .. " " .. L["icons"] .. "\n\n" .. TextIconMNL4:GetIconString() .. " " .. L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n\n" .. "Currently only possible on Khaz Algar and Pandaria Zones. More areas will follow later",
                  order = 1.1,
                  width = 0.50,
                  get = function() return ns.Addon.db.profile.showZoneMapNotesIcons end,
                  set = function(info, v) ns.Addon.db.profile.showZoneMapNotesIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if not ns.Addon.db.profile.showZoneMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], L["icons"], "|cffff0000" .. L["are hidden"] ) else
                        if ns.Addon.db.profile.showZoneMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
                  },
                ZoneScaleMapNotesIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha or not ns.Addon.db.profile.showZoneMapNotesIcons end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 1.2,
                  },
                zoneHeaderScaleAlpha1 = {
                  type = "description",
                  name = "",
                  order = 1.3,
                  width = 0.10,
                  },
                ZoneAlphaMapNotesIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha or not ns.Addon.db.profile.showZoneMapNotesIcons end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 1.4,
                  },
                zoneHAHeader = {
                  type = "description",
                  name = "",
                  order = 2.0,
                  },
                showZoneHordeAllyIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString(),
                  desc = FACTION_HORDE .. " / " .. FACTION_ALLIANCE .. " " .. "\n\n" .. L["Displays Horde and Alliance capitals icons with additional information"],
                  order = 2.1,
                  width = 0.50,
                  get = function() return ns.Addon.db.profile.showZoneHordeAllyIcons end,
                  set = function(info, v) ns.Addon.db.profile.showZoneHordeAllyIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if not ns.Addon.db.profile.showZoneHordeAllyIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], FACTION_HORDE .. " / " .. FACTION_ALLIANCE, L["icons"], "|cffff0000" .. L["are hidden"] ) else
                        if ns.Addon.db.profile.showZoneHordeAllyIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], FACTION_HORDE .. " / " .. FACTION_ALLIANCE, L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
                  },
                ZoneScaleHordeAllyIcons = {
                  disabled = function() return not ns.Addon.db.profile.showZoneHordeAllyIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                zoneHeaderScaleAlpha17 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                ZoneAlphaHordeAllyIcons = {
                  disabled = function() return not ns.Addon.db.profile.showZoneHordeAllyIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                zonePathsHeader = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showZonePaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString(),
                  desc = L["Paths"] .. "\n\n" .. L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.50,
                  order = 3.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScalePaths = {
                  disabled = function() return not ns.Addon.db.profile.showZonePaths or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                zoneHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                ZoneAlphaPaths = {
                  disabled = function() return not ns.Addon.db.profile.showZonePaths or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                zoneInnkeeperHeader = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showZoneInnkeeper = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconInnkeeperN:GetIconString() .. " " .. TextIconInnkeeperH:GetIconString() .. " " .. TextIconInnkeeperA:GetIconString(),
                  desc = MINIMAP_TRACKING_INNKEEPER .. "\n\n" .. TextIconInnkeeperN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconInnkeeperH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconInnkeeperA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 4.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.showZoneInnkeeper or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                zoneHeaderScaleAlpha2 = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                ZoneAlphaInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.showZoneInnkeeper or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4
                  },
                zoneMailboxHeader = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showZoneMailbox = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconMailboxN:GetIconString() .. " " .. TextIconMailboxH:GetIconString() .. " " .. TextIconMailboxA:GetIconString(),
                  desc = MINIMAP_TRACKING_MAILBOX .. "\n\n" .. TextIconMailboxN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconMailboxH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconMailboxA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 5.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleMailbox = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMailbox or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                zoneHeaderScaleAlpha6 = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                ZoneAlphaMailbox = {
                  disabled = function() return not ns.Addon.db.profile.showZoneMailbox or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                zonePvPVendorHeader = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showZonePvPVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvPVendorH:GetIconString() .. " " .. TextIconPvPVendorA:GetIconString(),
                  desc = TRANSMOG_SET_PVP .. "\n\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n\n" .. TextIconPvPVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n\n" .. TextIconPvPVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n\n" .. TextIconPvPVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"],
                  width = 0.50,
                  order = 6.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScalePvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.showZonePvPVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                zoneHeaderScaleAlpha7 = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                ZoneAlphaPvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.showZonePvPVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                zonePvEVendorHeader = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showZonePvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.ZoneScalePvPVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TextIconPvEVendorH:GetIconString() .. " " .. TextIconPvEVendorA:GetIconString(),
                  desc = TRANSMOG_SET_PVE .. "\n\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT,
                  width = 0.50,
                  order = 7.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScalePvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.showZonePvEVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                zoneHeaderScaleAlpha8 = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                ZoneAlphaPvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.showZonePvEVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                zoneStablemasterHeader = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                showZoneStablemaster = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " .. TextIconStablemasterA:GetIconString(),
                  desc = MINIMAP_TRACKING_STABLEMASTER .. "\n\n" .. TextIconStablemasterN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconStablemasterH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconStablemasterA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 8.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.showZoneStablemaster or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 8.2,
                  },
                zoneHeaderScaleAlpha9 = {
                  type = "description",
                  name = "",
                  order = 8.3,
                  width = 0.10,
                  },
                ZoneAlphaStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.showZoneStablemaster or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 8.4,
                  },
                zoneAuctioneerHeader = {
                  type = "description",
                  name = "",
                  order = 9.0,
                  },
                showZoneAuctioneer = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString(),
                  desc = MINIMAP_TRACKING_AUCTIONEER .. "\n\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Capitals"] .. "\n\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE .. "\n" .. " "  .. REFORGE_CURRENT .. " => " .. L["Valdrakken"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 9.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.showZoneAuctioneer or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 9.2,
                  },
                zoneHeaderScaleAlpha3 = {
                  type = "description",
                  name = "",
                  order = 9.3,
                  width = 0.10,
                  },
                ZoneAlphaAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.showZoneAuctioneer or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 9.4,
                  },
                zoneBankHeader = {
                  type = "description",
                  name = "",
                  order = 10.0,
                  },
                showZoneBank = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. TextIconBankOld:GetIconString(),
                  desc = BANK .. "\n\n" .. " " .. POSTMASTER_LETTER_AREA52 .. "\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Ratchet"] .. " - " .. POSTMASTER_LETTER_BARRENS_SUBTITLE .. "\n" .. " " .. L["Dustwallow Marsh"] .. " = " .. ITEM_REQ_ALLIANCE .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 10.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleBank = {
                  disabled = function() return not ns.Addon.db.profile.showZoneBank or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 10.2,
                  },
                zoneHeaderScaleAlpha4 = {
                  type = "description",
                  name = "",
                  order = 10.3,
                  width = 0.10,
                  },
                ZoneAlphaBank = {
                  disabled = function() return not ns.Addon.db.profile.showZoneBank or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 10.4
                  },
                zoneBarberHeader = {
                  type = "description",
                  name = "",
                  order = 11.0,
                  },
                showZoneBarber = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString(),
                  desc = MINIMAP_TRACKING_BARBER .. "\n\n" .. POSTMASTER_LETTER_AREA52 .. "\n" .. L["Capitals"],
                  width = 0.50,
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleBarber = {
                  disabled = function() return not ns.Addon.db.profile.showZoneBarber or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 11.2,
                  },
                zoneHeaderScaleAlpha5 = {
                  type = "description",
                  name = "",
                  order = 11.3,
                  width = 0.10,
                  },
                ZoneAlphaBarber = {
                  disabled = function() return not ns.Addon.db.profile.showZoneBarber or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 11.4,
                  },
                zoneCatalystHeader = {
                  type = "description",
                  name = "",
                  order = 12.0,
                  },
                showZoneCatalyst = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString(),
                  desc = L["Catalyst"],
                  width = 0.50,
                  order = 12.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.showZoneCatalyst or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 12.2,
                  },
                zoneHeaderScaleAlpha10 = {
                  type = "description",
                  name = "",
                  order = 12.3,
                  width = 0.10,
                  },
                ZoneAlphaCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.showZoneCatalyst or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 12.4,
                  },
                zoneZidormiHeader = {
                  type = "description",
                  name = "",
                  order = 13.0,
                  },
                showZoneZidormi = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconZidormi:GetIconString(),
                  desc = L["Zidormi"] .. "\n\n" .. " " .. L["Tirisfal Glades"] .. "\n" .. " " .. L["Blasted Lands"] .. "\n" .. " " .. L["Uldum"] .. "\n" .. " " .. L["Silithus"] .. "\n" .. " " .. L["Arathi Highlands"] .. "\n" .. " " .. L["Arathi Highlands"] .. "\n" .. " " .. L["Darkshore"],
                  width = 0.50,
                  order = 13.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneZidormi then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zidormi"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneZidormi then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zidormi"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleZidormi = {
                  disabled = function() return not ns.Addon.db.profile.showZoneZidormi or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 13.2,
                  },
                zoneHeaderScaleAlpha11 = {
                  type = "description",
                  name = "",
                  order = 13.3,
                  width = 0.10,
                  },
                ZoneAlphaZidormi = {
                  disabled = function() return not ns.Addon.db.profile.showZoneZidormi or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 13.4,
                  },
                zoneTransmoggerHeader = {
                  type = "description",
                  name = "",
                  order = 14.0,
                  },
                showZoneTransmogger = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString(),
                  desc = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 14.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTransmogger or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 14.2,
                  },
                zoneHeaderScaleAlpha12 = {
                  type = "description",
                  name = "",
                  order = 14.3,
                  width = 0.10,
                  },
                ZoneAlphaTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.showZoneTransmogger or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 14.4,
                  },
                zoneItemUpgradeHeader = {
                  type = "description",
                  name = "",
                  order = 15.0,
                  },
                showZoneItemUpgrade = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral  end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString(),
                  desc =  ITEM_UPGRADE .. "\n\n" .. " " .. L["Nazjatar"] .. "\n" .. " " .. L["Korthia"] .. "\n" .. " " .. "...",
                  width = 0.50,
                  order = 15.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                ZoneScaleItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.showZoneItemUpgrade or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 15.2,
                  },
                zoneHeaderScaleAlpha13 = {
                  type = "description",
                  name = "",
                  order = 15.3,
                  width = 0.10,
                  },
                ZoneAlphaItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.showZoneItemUpgrade or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral or ns.Addon.db.profile.activate.ZoneGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 15.4,
                  },
                },
              },
            },
          },
        MiniMapTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "group",
          name =  MINIMAP_LABEL .. "-" .. L["Zones"],
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
          order = 2,
          args = {
            MiniMapDescriptionText = {
              name = "|cffff0000" .. L["Zones"] .. "-" .. MINIMAP_LABEL  .. " " .. L["icons"] .. "\n\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Continent"] .. "\n" .. L["Some instance icons cannot be hidden because they were created by Blizzard itself and not by MapNotes"],
              type = "description",
              order = 20.1,
              },
            MiniMapContinentTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. CONTINENT .. " " .. BRAWL_TOOLTIP_MAPS,
              desc = "",
              order = 1,
              args = {
                --minimapcontinentheader1 = {
                --  type = "header",
                --  name = MINIMAP_LABEL .. " " .. CONTINENT .. " " .. L["icons"],
                --  order = 0.1,
                --  },
                minimapcontinentheader3 = {
                  type = "header",
                  name = L["Displays zone icons on a specific continent"],
                  order = 0.3,
                  },
                minimapcontinentheader4 = {
                  type = "description",
                  name = "\n",
                  order = 0.4,
                  },     
                showMiniMapKalimdor= {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
                  desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapEasternKingdom = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
                  desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapOutland = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconBC:GetIconString() .. " " .. L["Outland"],
                  desc = L["Show all Outland MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapNorthrend = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
                  desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapPandaria = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
                  desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 0.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Pandaria"], L["icons"],L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapDraenor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconDraenor:GetIconString() .. " " .. L["Draenor"],
                  desc = L["Show all Draenor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapBrokenIsles = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
                  desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapZandalar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
                  desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapKulTiras = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
                  desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapShadowlands = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconSL:GetIconString() .. " " .. L["Shadowlands"],
                  desc = L["Show all Shadowlands MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapDragonIsles = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
                  desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  }, 
                showMiniMapKhazAlgar = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
                  desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
                  order = 1.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  }, 
                },
              },
            MiniMapProfessionTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"],
              desc = "",
              order = 2,
              args = {       
                MiniMapprofessionsheader1 = {
                  type = "description",
                  name = "",
                  order = 40,
                  width = 0.85,
                  },  
                MiniMapProfessions = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 40.2,
                  get = function() return ns.Addon.db.profile.activate.MiniMapProfessions end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. GUILD_ROSTER_DROPDOWN_PROFESSION .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                MiniMapprofessionsheader2 = {
                  type = "description",
                  name = "",
                  order = 40.3,
                  },  
                MiniMapprofessionsheader3 = {
                  type = "description",
                  name = "",
                  order = 40.4,
                  width = 0.20,
                  },  
                MiniMapProfessionsScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1, 
                  order = 40.5,
                  },
                MiniMapgeneralheader2 = {
                  type = "description",
                  name = "",
                  order = 40.6,
                  width = 0.20,
                  },
                MiniMapProfessionsAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1, 
                  order = 40.7,
                  },
                MiniMapgeneralheader3 = {
                  type = "header",
                  name = "",
                  order = 40.8,
                  },
                showMiniMapProfessionDetection = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions end,
                  type = "toggle",
                  name = L["Profession detection"],
                  desc = L["Automatically detects your professions and activates the corresponding professions icons on this map"],
                  width = 1.2, 
                  order = 40.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        ns.AutomaticProfessionDetection()
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapheader5 = {
                  type = "header",
                  name = "",
                  order = 41.0,
                  },
                --showMiniMapProfessionOrders = {
                --  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions end,
                --  type = "toggle",
                --  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                --  desc = PLACE_CRAFTING_ORDERS,
                --  width = 1.2,
                --  order = 41.9,
                --  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                --        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                --        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                --  },
                showMiniMapAlchemy = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
                  desc = "",
                  width = 1.2,
                  order = 42,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Alchemy"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Alchemy"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapEngineer = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconEngineer:GetIconString() .. " " .. L["Engineer"],
                  desc = "",
                  width = 1.2,
                  order = 42.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapJewelcrafting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconJewelcrafting:GetIconString() .. " " .. L["Jewelcrafting"],
                  desc = "",
                  width = 1.2,
                  order = 42.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Jewelcrafting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapJewelcrafting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Jewelcrafting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapBlacksmith = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
                  desc = "",
                  width = 1.2,
                  order = 42.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Blacksmithing"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBlacksmith then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Blacksmithing"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapTailoring = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconTailoring:GetIconString() .. " " .. L["Tailoring"],
                  desc = "",
                  width = 1.2,
                  order = 42.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Tailoring"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTailoring then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Tailoring"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapSkinning = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconSkinning:GetIconString() .. " " .. L["Skinning"],
                  desc = "",
                  width = 1.2,
                  order = 42.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Skinning"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapSkinning then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Skinning"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapMining = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconMining:GetIconString() .. " " .. L["Mining"],
                  desc = "",
                  width = 1.2,
                  order = 42.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Mining"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMining then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Mining"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapHerbalism = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconHerbalism:GetIconString() .. " " .. L["Herbalism"],
                  desc = "",
                  width = 1.2,
                  order = 42.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapInscription = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconInscription:GetIconString() .. " " .. INSCRIPTION,
                  desc = "",
                  width = 1.2,
                  order = 42.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, INSCRIPTION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapInscription then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, INSCRIPTION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapFishing = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
                  desc = "",
                  width = 1.2,
                  order = 43,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_FISHING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapFishing then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL,PROFESSIONS_FISHING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapCooking = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconCooking:GetIconString() .. " " .. PROFESSIONS_COOKING,
                  desc = "",
                  width = 1.2,
                  order = 43.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapArchaeology = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconArchaeology:GetIconString() .. " " .. PROFESSIONS_ARCHAEOLOGY,
                  desc = "",
                  width = 1.2,
                  order = 43.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapArchaeology then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, PROFESSIONS_ARCHAEOLOGY, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapEnchanting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
                  desc = "",
                  width = 1.2,
                  order = 43.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Enchanting"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapEnchanting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Enchanting"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapLeatherworking = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapProfessions or ns.Addon.db.profile.showMiniMapProfessionDetection end,
                  type = "toggle",
                  name = TextIconLeatherworking:GetIconString() .. " " .. L["Leatherworking"],
                  desc = "",
                  width = 1.2,
                  order = 43.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            MiniMapInstanceTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                --minimapinstanceheader1 = {
                --  type = "header",
                --  name = MINIMAP_LABEL .. " " .. L["icons"],
                --  order = 1.1,
                --  },
                minimapinstanceheader3 = {
                  type = "description",
                  name = "",
                  order = 1.0,
                  width = 0.45,
                  },   
                MiniMapInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 1.2,
                  get = function() return ns.Addon.db.profile.activate.MiniMapInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                MiniMapInstanceSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = MINIMAP_LABEL .. " " .. INSTANCE .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 1.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, INSTANCE, L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, INSTANCE, L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                MiniMapSyncHeader1 = {
                  type = "description",
                  name = "",
                  order = 1.5,
                  },
                minimapinstanceheader5 = {
                  type = "description",
                  name = "",
                  order = 1.6,
                  width = 0.25,
                  },
                MiniMapInstanceScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or not ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 1.7,
                  },
                minimapinstanceheader6 = {
                  type = "description",
                  name = "",
                  order = 1.8,
                  width = 0.10,
                  },
                MiniMapInstanceAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or not ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 1.9,
                  },
                minimapinstanceheader8 = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 2.0,
                  },
                showMiniMapRaids = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString(),
                  desc = L["Raids"],
                  order = 2.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleRaids = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapRaids or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                minimapHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                MiniMapAlphaRaids = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapRaids or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                minimapraidsheader9 = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showMiniMapDungeons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString(),
                  desc = L["Dungeons"],
                  order = 3.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleDungeons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapDungeons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                minimapHeaderScaleAlpha1 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                MiniMapAlphaDungeons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapDungeons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                minimapDungeonsHeader = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showMiniMapPassage = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconDelvesPassage:GetIconString(),
                  desc = L["Passages"] .. "\n\n" .. L["Show icons of passage to raids and dungeons on this map"] .. "\n\n" .. " " .. TextIconPassageRaidM:GetIconString() .. " " .. L["Raids"] .. "\n" .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. L["Dungeons"] .. "\n" .. " " .. TextIconDelvesPassage:GetIconString() .. " " .. DELVES_LABEL,
                  order = 4.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScalePassage = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                minimapHeaderScaleAlpha2 = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                MiniMapAlphaPassage = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4
                  },
                minimapPassageHeader = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showMiniMapMultiple = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString(),
                  desc = L["Multiple"] .. "\n\n" .. " " ..L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 5.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleMultiple = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMultiple or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                minimapHeaderScaleAlpha6 = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                MiniMapAlphaMultiple = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMultiple or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                minimapMultipleHeader = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showMiniMapOldVanilla = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString(),
                  desc = L["Old Instances"] .. "\n\n" .. " " .. L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 6.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                MiniMapScaleOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapOldVanilla or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                minimapHeaderScaleAlpha7 = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                MiniMapAlphaOldVanilla = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapOldVanilla or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                minimapOldVanillaHeader = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showMiniMapLFR = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString(),
                  desc = PLAYER_DIFFICULTY3 .. "\n\n" .. " " .. L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 7.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                MiniMapScaleLFR = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapLFR or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                minimapHeaderScaleAlpha8 = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                MiniMapAlphaLFR = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapLFR or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances or ns.Addon.db.profile.activate.MiniMapInstanceSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                minimapLFRHeader = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                },
              },
            MiniMapTransportTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {
                --minimaptransportheader1 = {
                --  type = "header",
                --  name = MINIMAP_LABEL .. " " .. L["Transport"] .. " " .. L["icons"],
                --  order = 2.1,
                --  },
                minimaptransportheader3 = {
                  type = "description",
                  name = "",
                  order = 1.0,
                  width = 0.45,
                  },    
                MiniMapTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 1.2,
                  get = function() return ns.Addon.db.profile.activate.MiniMapTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                MiniMapTransportSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = MINIMAP_LABEL .. " " .. L["Transport"] .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 1.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, L["Transport"], L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, L["Transport"], L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimaptransportheader4 = {
                  type = "description",
                  name = "",
                  order = 1.4,
                  },
                minimaptransportheader5 = {
                  type = "description",
                  name = "",
                  order = 1.5,
                  width = 0.25,
                  },
                MiniMapTransportScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or not ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 1.6,
                  },
                minimaptransportheader6 = {
                  type = "description",
                  name = "",
                  order = 1.7,
                  width = 0.10,
                  },
                MiniMapTransportAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or not ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 1.8,
                  },
                minimaptransportheader8 = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 1.9,
                  },
                showMiniMapPortals = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconPortalOld:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString() .. " " .. TextIconTorghastUp:GetIconString(),
                  desc = L["Portals"] .. "\n" .."\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconTorghastUp:GetIconString() .. " " .. L["Torghast"] .. " " .. L["Portal"],
                  order = 2.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScalePortals = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPortals or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                minimapHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                MiniMapAlphaPortals = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPortals or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                minimaptransportheader2 = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showMiniMapZeppelins = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString(),
                  desc = L["Zeppelins"],
                  order = 3.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapZeppelins or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                minimapHeaderScaleAlphaZeppelins = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                MiniMapAlphaZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapZeppelins or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                minimaptransportheader9 = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showMiniMapShips = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString(),
                  desc = L["Ships"],
                  order = 4.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleShips = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapShips or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                minimapHeaderScaleAlphaShips = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                MiniMapAlphaShips = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapShips or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4,
                  },
                minimaptransportheaderShips = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showMiniMapTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconCarriage:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconMoleMachine:GetIconString() .. " " .. TextIconRocketDrill:GetIconString(),
                  desc = L["Transport"] .. " " .. "\n" .."\n" .. TextIconCarriage:GetIconString() .. " " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " " .. L["Stormwind"] .. " <= => "  .. L["Ironforge"] .. "\n" .. TextIconTravelL:GetIconString() .. " " .. L["Transport"] .. "\n" .. " " .. L["Korthia"] .. " <= => " .. L["The Maw"] .. "\n" .. TextIconMoleMachine:GetIconString() .. " - " .. TextIconRocketDrill:GetIconString() .. " " .. L["Mole Machine"] .. "\n" .. " (" .. EXPANSION_NAME10 .. ")",
                  order = 5.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleTransport = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                minimapHeaderScaleAlphaTransport = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                MiniMapAlphaTransport = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                zonetransportheaderOgreWaygate = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showMiniMapOgreWaygate = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString(),
                  desc = L["Ogre Waygate"] .. "\n" .."\n" .. " " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] ,
                  order = 6.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ogre Waygate"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ogre Waygate"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleOgreWaygate = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapOgreWaygate or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                minimapHeaderScaleAlphaOgreWaygate = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                MiniMapAlphaOgreWaygate = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapOgreWaygate or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                minimaptransportheaderTeleporter = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showMiniMapTeleporter = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconTransport:GetIconString(),
                  desc = L["Teleporter"] .. "\n\n" .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"],
                  order = 7.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Teleporter"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Teleporter"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleTeleporter = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTeleporter or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                minimapHeaderScaleAlphaTeleporter = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                MiniMapAlphaTeleporter = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTeleporter or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                minimaptransportheaderTeleporter4 = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                showMiniMapMirror = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconMirror:GetIconString(),  
                  desc = L["Ever-Shifting Mirror"] .. " (" .. TOY .. ")" .. "\n" .."\n" .. " " .. POSTMASTER_PIPE_OUTLAND .. " <= => " .. POSTMASTER_PIPE_DRAENOR,
                  order = 8.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMirror then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ever-Shifting Mirror"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMirror then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ever-Shifting Mirror"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleMirror = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMirror or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 8.2,
                  },
                minimapHeaderScaleAlphaMirror = {
                  type = "description",
                  name = "",
                  order = 8.3,
                  width = 0.10,
                  },
                MiniMapAlphaMirror = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMirror or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 8.4,
                  },
                minimaptransportheaderMirror = {
                  type = "description",
                  name = "",
                  order = 9.0,
                  },
                showMiniMapTravel = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconDwarfF:GetIconString() .. " " .. TextIconB11M:GetIconString() .. " " .. TextIconGoblinF:GetIconString(), 
                  desc = L["Travel"] .. "\n\n" .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Nazmir"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconGilneanF:GetIconString() .. " " .. L["Zuldazar"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconKulM:GetIconString() .. " " .. L["Vol'dun"] .. " => " .. L["Boralus"] .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. TextIconOrcF:GetIconString() .. " " .. L["Drustvar"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconB11M:GetIconString() .. " " .. L["Tiragarde Sound"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconUndeadF:GetIconString() .. " " .. L["Stormsong Valley"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconGoblinF:GetIconString() .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " => " .. L["Zuldazar"],
                  order = 9.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Travel"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Travel"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleTravel = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTravel or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 9.2,
                  },
                minimapHeaderScaleAlphaTravel = {
                  type = "description",
                  name = "",
                  order = 9.3,
                  width = 0.10,
                  },
                MiniMapAlphaTravel = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTravel or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 9.4,
                  },
                minimaptDarkmoonheader8 = {
                  type = "description",
                  name = "",
                  order = 10.0,
                  },
                showMiniMapDarkmoon = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconDarkMoon:GetIconString(),
                  desc = CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
                  order = 10.1,
                  width = 0.50,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, CALENDAR_FILTER_DARKMOON, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, CALENDAR_FILTER_DARKMOON, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleDarkmoon = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapDarkmoon or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 10.2,
                  },
                minimapHeaderScaleAlphaDarkmoon = {
                  type = "description",
                  name = "",
                  order = 10.3,
                  width = 0.10,
                  },
                MiniMapAlphaDarkmoon = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapDarkmoon or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 10.4,
                  },
                minimapRacesHeader = {
                  type = "description",
                  name = "",
                  order = 11.0,
                  },
                showMiniMapRaces = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = RACES,
                  desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
                  width = 0.50,
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, RACES, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, RACES, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleRaces = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapRaces or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 11.2,
                  },
                minimapHeaderScaleAlpha15 = {
                  type = "description",
                  name = "",
                  order = 11.3,
                  width = 0.10,
                  },
                MiniMapAlphaRaces = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapRaces or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting or ns.Addon.db.profile.activate.MiniMapTransportSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 11.4,
                  },
                },
              },
            MiniMapGeneralTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                --minimapgeneralheader1 = {
                --  type = "header",
                --  name = MINIMAP_LABEL .. " " .. L["General"] .. " " .. L["icons"],
                --  order = 3.1,
                --  },
                MiniMapGeneralHeader1 = {
                  type = "description",
                  name = "",
                  order = 0.1,
                  width = 0.45,
                  },       
                MiniMapGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 0.2,
                  get = function() return ns.Addon.db.profile.activate.MiniMapGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                MiniMapGeneralSyncScaleAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = L["Synchronize"],
                  desc = MINIMAP_LABEL .. " " .. L["General"] .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
                  width = 0.80,
                  order = 0.3,
                  confirm = true,
                  get = function() return ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, L["General"], L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. MINIMAP_LABEL, L["General"], L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapSyncHeader1 = {
                  type = "description",
                  name = "",
                  order = 0.5,
                  },
                minimapSyncHeader2 = {
                  type = "description",
                  name = "",
                  order = 0.6,
                  width = 0.25,
                  },
                MiniMapGeneralScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or not ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 0.7,
                  },
                minimapgeneralheader6 = {
                  type = "description",
                  name = "",
                  order = 0.8,
                  width = 0.10,
                  },
                MiniMapGeneralAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or not ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 0.9,
                  },
                minimapHAHeader = {
                  type = "header",
                  name = L["Show individual icons"],
                  order = 1.0,
                  },
                showMiniMapMapNotesIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconMNL4:GetIconString(),
                  desc = ns.COLORED_ADDON_NAME .. " " .. L["icons"] .. "\n\n" .. TextIconMNL4:GetIconString() .. " " .. L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n\n" .. "Currently only possible on Khaz Algar and Pandaria Zones. More areas will follow later",
                  order = 1.1,
                  width = 0.50,
                  get = function() return ns.Addon.db.profile.showMiniMapMapNotesIcons end,
                  set = function(info, v) ns.Addon.db.profile.showMiniMapMapNotesIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if not ns.Addon.db.profile.showMiniMapMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. MINIMAP_LABEL, L["icons"], "|cffff0000" .. L["are hidden"] ) else
                        if ns.Addon.db.profile.showMiniMapMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. MINIMAP_LABEL, L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
                  },
                MiniMapScaleMapNotesIcons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMapNotesIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 1.2,
                  },
                minimapHeaderScaleAlpha1 = {
                  type = "description",
                  name = "",
                  order = 1.3,
                  width = 0.10,
                  },
                MiniMapAlphaMapNotesIcons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMapNotesIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 1.4,
                  },
                minimapHAHeader74 = {
                  type = "description",
                  name = "",
                  order = 2.0,
                  },
                showMiniMapHordeAllyIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString(),
                  desc = FACTION_HORDE .. " / " .. FACTION_ALLIANCE .. " " .. "\n\n" .. L["Displays Horde and Alliance capitals icons with additional information"],
                  order = 2.1,
                  width = 0.50,
                  get = function() return ns.Addon.db.profile.showMiniMapHordeAllyIcons end,
                  set = function(info, v) ns.Addon.db.profile.showMiniMapHordeAllyIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if not ns.Addon.db.profile.showMiniMapHordeAllyIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. MINIMAP_LABEL, FACTION_HORDE .. " / " .. FACTION_ALLIANCE, L["icons"], "|cffff0000" .. L["are hidden"] ) else
                        if ns.Addon.db.profile.showMiniMapHordeAllyIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. MINIMAP_LABEL, FACTION_HORDE .. " / " .. FACTION_ALLIANCE, L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
                  },
                MiniMapScaleHordeAllyIcons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapHordeAllyIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 2.2,
                  },
                minimapHeaderScaleAlpha187 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.10,
                  },
                MiniMapAlphaHordeAllyIcons = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapHordeAllyIcons or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 2.4,
                  },
                minimapPathsHeader = {
                  type = "description",
                  name = "",
                  order = 3.0,
                  },
                showMiniMapPaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString(),
                  desc = L["Paths"] .. "\n\n" .. L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.50,
                  order = 3.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL, L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL, L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScalePaths = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPaths or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 3.2,
                  },
                minimapHeaderScaleAlpha14 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.10,
                  },
                MiniMapAlphaPaths = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPaths or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 3.4,
                  },
                minimapInnkeeperHeader = {
                  type = "description",
                  name = "",
                  order = 4.0,
                  },
                showMiniMapInnkeeper = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconInnkeeperN:GetIconString() .. " " .. TextIconInnkeeperH:GetIconString() .. " " .. TextIconInnkeeperA:GetIconString(),
                  desc = MINIMAP_TRACKING_INNKEEPER .. "\n\n" .. TextIconInnkeeperN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconInnkeeperH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconInnkeeperA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 4.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapInnkeeper or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 4.2,
                  },
                minimapHeaderScaleAlpha2 = {
                  type = "description",
                  name = "",
                  order = 4.3,
                  width = 0.10,
                  },
                MiniMapAlphaInnkeeper = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapInnkeeper or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 4.4
                  },
                minimapMailboxHeader = {
                  type = "description",
                  name = "",
                  order = 5.0,
                  },
                showMiniMapMailbox = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconMailboxN:GetIconString() .. " " .. TextIconMailboxH:GetIconString() .. " " .. TextIconMailboxA:GetIconString(),
                  desc = MINIMAP_TRACKING_MAILBOX .. "\n\n" .. TextIconMailboxN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconMailboxH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconMailboxA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 5.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleMailbox = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMailbox or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 5.2,
                  },
                minimapHeaderScaleAlpha6 = {
                  type = "description",
                  name = "",
                  order = 5.3,
                  width = 0.10,
                  },
                MiniMapAlphaMailbox = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapMailbox or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 5.4,
                  },
                minimapPvPVendorHeader = {
                  type = "description",
                  name = "",
                  order = 6.0,
                  },
                showMiniMapPvPVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvPVendorH:GetIconString() .. " " .. TextIconPvPVendorA:GetIconString(),
                  desc = TRANSMOG_SET_PVP .. "\n\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n\n" .. TextIconPvPVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n\n" .. TextIconPvPVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n\n" .. TextIconPvPVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"],
                  width = 0.50,
                  order = 6.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScalePvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPvPVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 6.2,
                  },
                minimapHeaderScaleAlpha7 = {
                  type = "description",
                  name = "",
                  order = 6.3,
                  width = 0.10,
                  },
                MiniMapAlphaPvPVendor = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPvPVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 6.4,
                  },
                minimapPvEVendorHeader = {
                  type = "description",
                  name = "",
                  order = 7.0,
                  },
                showMiniMapPvEVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TextIconPvEVendorH:GetIconString() .. " " .. TextIconPvEVendorA:GetIconString(),
                  desc = TRANSMOG_SET_PVE .. "\n\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT,
                  width = 0.50,
                  order = 7.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScalePvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPvEVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 7.2,
                  },
                minimapHeaderScaleAlpha8 = {
                  type = "description",
                  name = "",
                  order = 7.3,
                  width = 0.10,
                  },
                MiniMapAlphaPvEVendor = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapPvEVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 7.4,
                  },
                minimapStablemasterHeader = {
                  type = "description",
                  name = "",
                  order = 8.0,
                  },
                showMiniMapStablemaster = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " .. TextIconStablemasterA:GetIconString(),
                  desc = MINIMAP_TRACKING_STABLEMASTER .. "\n\n" .. TextIconStablemasterN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconStablemasterH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconStablemasterA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.50,
                  order = 8.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapStablemaster or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 8.2,
                  },
                minimapHeaderScaleAlpha9 = {
                  type = "description",
                  name = "",
                  order = 8.3,
                  width = 0.10,
                  },
                MiniMapAlphaStablemaster = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapStablemaster or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 8.4,
                  },
                minimapAuctioneerHeader = {
                  type = "description",
                  name = "",
                  order = 9.0,
                  },
                showMiniMapAuctioneer = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString(),
                  desc = MINIMAP_TRACKING_AUCTIONEER .. "\n\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Capitals"] .. "\n\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE .. "\n" .. " "  .. REFORGE_CURRENT .. " => " .. L["Valdrakken"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 9.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapAuctioneer or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 9.2,
                  },
                minimapHeaderScaleAlpha3 = {
                  type = "description",
                  name = "",
                  order = 9.3,
                  width = 0.10,
                  },
                MiniMapAlphaAuctioneer = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapAuctioneer or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 9.4,
                  },
                minimapBankHeader = {
                  type = "description",
                  name = "",
                  order = 10.0,
                  },
                showMiniMapBank = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. TextIconBankOld:GetIconString(),
                  desc = BANK .. "\n\n" .. " " .. POSTMASTER_LETTER_AREA52 .. "\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Ratchet"] .. " - " .. POSTMASTER_LETTER_BARRENS_SUBTITLE .. "\n" .. " " .. L["Dustwallow Marsh"] .. " = " .. ITEM_REQ_ALLIANCE .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 10.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleBank = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapBank or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 10.2,
                  },
                minimapHeaderScaleAlpha4 = {
                  type = "description",
                  name = "",
                  order = 10.3,
                  width = 0.10,
                  },
                MiniMapAlphaBank = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapBank or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 10.4
                  },
                minimapBarberHeader = {
                  type = "description",
                  name = "",
                  order = 11.0,
                  },
                showMiniMapBarber = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString(),
                  desc = MINIMAP_TRACKING_BARBER .. "\n\n" .. POSTMASTER_LETTER_AREA52 .. "\n" .. L["Capitals"],
                  width = 0.50,
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleBarber = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapBarber or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 11.2,
                  },
                minimapHeaderScaleAlpha5 = {
                  type = "description",
                  name = "",
                  order = 11.3,
                  width = 0.10,
                  },
                MiniMapAlphaBarber = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapBarber or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 11.4,
                  },
                minimapCatalystHeader = {
                  type = "description",
                  name = "",
                  order = 12.0,
                  },
                showMiniMapCatalyst = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString(),
                  desc = L["Catalyst"],
                  width = 0.50,
                  order = 12.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapCatalyst or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 12.2,
                  },
                minimapHeaderScaleAlpha10 = {
                  type = "description",
                  name = "",
                  order = 12.3,
                  width = 0.10,
                  },
                MiniMapAlphaCatalyst = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapCatalyst or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 12.4,
                  },
                minimapZidormiHeader = {
                  type = "description",
                  name = "",
                  order = 13.0,
                  },
                showMiniMapZidormi = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconZidormi:GetIconString(),
                  desc = L["Zidormi"] .. "\n\n" .. " " .. L["Tirisfal Glades"] .. "\n" .. " " .. L["Blasted Lands"] .. "\n" .. " " .. L["Uldum"] .. "\n" .. " " .. L["Silithus"] .. "\n" .. " " .. L["Arathi Highlands"] .. "\n" .. " " .. L["Arathi Highlands"] .. "\n" .. " " .. L["Darkshore"],
                  width = 0.50,
                  order = 13.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapZidormi then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zidormi"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapZidormi then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zidormi"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleZidormi = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapZidormi or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 13.2,
                  },
                minimapHeaderScaleAlpha11 = {
                  type = "description",
                  name = "",
                  order = 12.3,
                  width = 0.10,
                  },
                MiniMapAlphaZidormi = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapZidormi or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 13.4,
                  },
                minimapTransmoggerHeader = {
                  type = "description",
                  name = "",
                  order = 14.0,
                  },
                showMiniMapTransmogger = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString(),
                  desc = MINIMAP_TRACKING_TRANSMOGRIFIER .. "\n\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.50,
                  order = 14.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTransmogger or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 14.2,
                  },
                minimapHeaderScaleAlpha12 = {
                  type = "description",
                  name = "",
                  order = 14.3,
                  width = 0.10,
                  },
                MiniMapAlphaTransmogger = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapTransmogger or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 14.4,
                  },
                minimapItemUpgradeHeader = {
                  type = "description",
                  name = "",
                  order = 15.0,
                  },
                showMiniMapItemUpgrade = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString(),
                  desc =  ITEM_UPGRADE .. "\n\n" .. " " .. L["Nazjatar"] .. "\n" .. " " .. L["Korthia"] .. "\n" .. " " .. "...",
                  width = 0.50,
                  order = 15.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                MiniMapScaleItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapItemUpgrade or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 0.80,
                  order = 15.2,
                  },
                minimapHeaderScaleAlpha13 = {
                  type = "description",
                  name = "",
                  order = 15.3,
                  width = 0.10,
                  },
                MiniMapAlphaItemUpgrade = {
                  disabled = function() return not ns.Addon.db.profile.showMiniMapItemUpgrade or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral or ns.Addon.db.profile.activate.MiniMapGeneralSyncScaleAlpha end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 0.80,
                  order = 15.4,
                  },
                },
              },
            }
          },
        },
      },
    ContinentTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Continents"],
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 3,
      args = {
        continentheader = {
          type = "header",
          name = CONTINENT .. "-" .. BRAWL_TOOLTIP_MAPS,
          order = 30,
          },
        ContinentDescriptionText = {
          name = function()
              if ns.Addon.db.profile.activate.SwapButtons then
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Right-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              else
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Left-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              end
            end,          type = "description",
          order = 30.1,
          },   
        continentheader1 = {
          type = "description",
          name = "",
          order = 30.5,
          },
        showContinent = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          order = 30.6,
          get = function() return ns.Addon.db.profile.activate.Continent end,
          set = function(info, v) ns.Addon.db.profile.activate.Continent = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if (ns.Addon.db.profile.activate.Continent and self.faction == "Horde") and not WorldMapFrame:IsShown() or not (WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 101 or WorldMapFrame:GetMapID() == 113 or WorldMapFrame:GetMapID() == 424 or WorldMapFrame:GetMapID() == 619
                or WorldMapFrame:GetMapID() == 875 or WorldMapFrame:GetMapID() == 876 or WorldMapFrame:GetMapID() == 905 or WorldMapFrame:GetMapID() == 1978 or WorldMapFrame:GetMapID() == 1550 or WorldMapFrame:GetMapID() == 572
                or WorldMapFrame:GetMapID() == 2274 or WorldMapFrame:GetMapID() == 948) then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else 
                if (not ns.Addon.db.profile.activate.Continent and self.faction == "Horde") and not WorldMapFrame:IsShown() or not (WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 101 or WorldMapFrame:GetMapID() == 113 or WorldMapFrame:GetMapID() == 424 or WorldMapFrame:GetMapID() == 619
                or WorldMapFrame:GetMapID() == 875 or WorldMapFrame:GetMapID() == 876 or WorldMapFrame:GetMapID() == 905 or WorldMapFrame:GetMapID() == 1978 or WorldMapFrame:GetMapID() == 1550 or WorldMapFrame:GetMapID() == 572
                or WorldMapFrame:GetMapID() == 2274 or WorldMapFrame:GetMapID() == 948) then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else
                if (ns.Addon.db.profile.activate.Continent and self.faction == "Alliance") and not WorldMapFrame:IsShown() or not (WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 101 or WorldMapFrame:GetMapID() == 113 or WorldMapFrame:GetMapID() == 424 or WorldMapFrame:GetMapID() == 619
                or WorldMapFrame:GetMapID() == 875 or WorldMapFrame:GetMapID() == 876 or WorldMapFrame:GetMapID() == 905 or WorldMapFrame:GetMapID() == 1978 or WorldMapFrame:GetMapID() == 1550 or WorldMapFrame:GetMapID() == 572
                or WorldMapFrame:GetMapID() == 2274 or WorldMapFrame:GetMapID() == 948) then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else 
                if (not ns.Addon.db.profile.activate.Continent and self.faction == "Alliance") and not WorldMapFrame:IsShown() or not (WorldMapFrame:GetMapID() == 12 or WorldMapFrame:GetMapID() == 13 or WorldMapFrame:GetMapID() == 101 or WorldMapFrame:GetMapID() == 113 or WorldMapFrame:GetMapID() == 424 or WorldMapFrame:GetMapID() == 619
                or WorldMapFrame:GetMapID() == 875 or WorldMapFrame:GetMapID() == 876 or WorldMapFrame:GetMapID() == 905 or WorldMapFrame:GetMapID() == 1978 or WorldMapFrame:GetMapID() == 1550 or WorldMapFrame:GetMapID() == 572
                or WorldMapFrame:GetMapID() == 2274 or WorldMapFrame:GetMapID() == 948) then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.Continent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.Continent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end end end,
              },
        ContinentEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 30.7,
          width = 0.90,
          get = function() return ns.Addon.db.profile.activate.ContinentEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.ContinentEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CONTINENT .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CONTINENT .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
        continentScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,  
          order = 30.8,
          },
        continentAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 30.9,
        },
        continentheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 31.0,
          },
        showContinentMapNotes = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString() .. " " .. L["Capitals"],
          desc = FACTION_HORDE .. " / " .. FACTION_ALLIANCE .. " " .. "\n\n" .. L["Displays Horde and Alliance capitals icons with additional information"],
          order = 32.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentRaids = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 32.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentDungeons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 32.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentPassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent or ns.Addon.db.profile.activate.ClassicIcons end,
          type = "toggle",
          name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " .. L["Passages"],
          desc = L["Show icons of passage to raids and dungeons on this map"],
          order = 32.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
            if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentMultiple = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple (dungeons,raids) on this map"],
          order = 32.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentPortals = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"] .. "\n\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
          order = 32.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 32.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 32.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconOgreWaygate:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. TextIconCarriage:GetIconString() .. " " .. TextIconMoleMachine:GetIconString() .. " " .. TextIconRocketDrill:GetIconString() .. " " .. L["Transport"],
          desc = L["Shows special transport icons like"] .. "\n\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n\n" .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " - " .. TextIconRocketDrill:GetIconString() .. " " .. L["Mole Machine"] .. "\n" .. " (" .. EXPANSION_NAME10 .. ")",
          order = 32.8,
          width = 1.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentOldVanilla = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
          desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
          order = 32.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showContinentLFR = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
          desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
          order = 33.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showContinentPvPandPvEVendor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvEVendor:GetIconString() .. " " .. TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE,
          desc = TRANSMOG_SET_PVP .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n\n" .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"] .."\n\n" .. TRANSMOG_SET_PVE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n\n" ..FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Icecrown"] .. "\n" .. " " .. L["Townlong Steppes"] .. "\n" .. " " .. L["Oribos"] .. "\n\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
          order = 33.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPvPandPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPvPandPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentProfessions = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconProfessionsMixed:GetIconString() .. " " .. PROFESSIONS_BUTTON,
          desc = EXPANSION_NAME4,
          order = 33.2,
          get = function() return ns.Addon.db.profile.showContinentProfessions end,
          set = function(info, v) ns.Addon.db.profile.showContinentProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Continent map"] .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Continent map"] .. " " .. PROFESSIONS_BUTTON .. " +" .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        showContinentDelves = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconDelves:GetIconString() .. " " .. DELVES_LABEL,
          desc = EXPANSION_NAME10 .. "\n" .. L["Entrance"],
          order = 33.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if WorldMapFrame:IsShown() and WorldMapFrame:GetMapID() == 2274 then WorldMapFrame:Hide() OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(2274) end
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentDelves then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], DELVES_LABEL, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentDelves then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], DELVES_LABEL, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showContinentPaths = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconPassageCaveUp:GetIconString() .. " " .. TextIconPassageCaveDown:GetIconString() .. " " .. L["Path"],
          desc = EXPANSION_NAME10 .. "\n" .. L["Passages"],
          order = 33.4,
          width = 1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Path"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["Path"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showContinentRaces = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconMoleMachine:GetIconString() .. " " .. RACES,
          desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
          order = 33.5,
          width = 0.60,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], RACES, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], RACES, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        continentheader4 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 35.1
          },
        showContinentKalimdor= {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentEasternKingdom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentOutland = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconBC:GetIconString() .. " " .. L["Outland"],
          desc = L["Show all Outland MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentNorthrend = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
          desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentPandaria = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
          desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Pandaria"], L["icons"],L["icons"], "|cff00ff00" .. L["are shown"]) else 
                  if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentDraenor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconDraenor:GetIconString() .. " " .. L["Draenor"],
          desc = L["Show all Draenor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentBrokenIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
          desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentZandalar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
          desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 35.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentKulTiras = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
          desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 36,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentShadowlands = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconSL:GetIconString() .. " " .. L["Shadowlands"],
          desc = L["Show all Shadowlands MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 36.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentDragonIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
          desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 36.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentKhazAlgar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
          desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 36.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        },
      },
    AzerothTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = AZEROTH,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 4,
      args = {
        Azerothheader = {
          type = "header",
          name = L["Azeroth map"] .. " " .. L["Informations"],
          order = 40,
          },
        AzerothDescriptionText = {
          name = function()
              if ns.Addon.db.profile.activate.SwapButtons then
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Right-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              else
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Left-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              end
            end,
          type = "description",
          order = 40.1,
          },   
        Azerothheader1 = {
          type = "description",
          name = "",
          order = 40.5,
          },
        showAzeroth = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          order = 40.6,
          get = function() return ns.Addon.db.profile.activate.Azeroth end,
          set = function(info, v) ns.Addon.db.profile.activate.Azeroth = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if not ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.Azeroth then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(947) else 
                if not ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.Azeroth then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(947)  else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.Azeroth then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(947) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.Azeroth then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(947) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },
        AzerothEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 40.7,
          width = 0.90,
          get = function() return ns.Addon.db.profile.activate.AzerothEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.AzerothEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.AzerothEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"] .. " " .. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.AzerothEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
        azerothScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,  
          order = 40.8,
          },
        azerothAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,  
          order = 40.9,
          },
        Azerothheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 41
          },
        showAzerothMapNotes = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString() .. " " .. L["Capitals"],
          desc = FACTION_HORDE .. " / " .. FACTION_ALLIANCE .. " " .. "\n\n" .. L["Displays Horde and Alliance capitals icons with additional information"],
          order = 42.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Capitals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothMapNotes then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Capitals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothRaids = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 42.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothDungeons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 42.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
            if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothPassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth or ns.Addon.db.profile.activate.ClassicIcons end,
          type = "toggle",
          name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
          desc = L["Show icons of passage to raids and dungeons on this map"],
          order = 42.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
            if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothMultiple = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple on this map"],
          order = 42.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.howAzerothMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothPortals = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"] .. "\n\n" .. TextIconPortalOld:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortalOld:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortalOld:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
          order = 42.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 42.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 42.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconDwarfF:GetIconString() .. " " .. TextIconUndeadF:GetIconString() .. " " .. TextIconGoblinF:GetIconString() .. " " .. TextIconGilneanF:GetIconString() .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"],
          desc = L["Shows special transport icons like"] .. "\n\n" .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
          order = 42.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothOldVanilla = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
          desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
          order = 42.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showAzerothLFR = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconLFR:GetIconString() .. " " .. TextIconPassageLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
          desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
          order = 43.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showAzerothDelves = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconDelves:GetIconString() .. " " .. DELVES_LABEL,
          desc = EXPANSION_NAME10,
          order = 43.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothDelves then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], DELVES_LABEL, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothDelves then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], DELVES_LABEL, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showAzerothRaces = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconMoleMachine:GetIconString() .. " " .. RACES,
          desc = L["The icons are only visible if you belong to the corresponding race"] .. "\n" .. L["Otherwise, the icons in this category are not visible to you"] .. "\n\n" .. L["These icons disappear from the map after discovery"] .. "\n\n" .. L["However, they can be displayed again in the General tab under Advanced Options using the 'Races +' option"] .. "\n\n" .. L["Icons that have already been discovered will be marked with the suffix 'already learned'"] .. "\n\n" .. L["Icons that have not yet been discovered will be marked with the suffix 'not yet unlocked'"] .. "\n\n" .. TextIconMoleMachine:GetIconString() .. " " .. L["Mole Machine"] .. " " .. "(" .. C_CreatureInfo.GetRaceInfo(34).raceName .. ")",
          order = 43.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], RACES, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothRaces then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Azeroth map"], RACES, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        Azerothheader3 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 44
          },
        showAzerothKalimdor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothEasternKingdom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothNorthrend = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
          desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Northrend"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Northrend"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothPandaria = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
          desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Pandaria"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Pandaria"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothBrokenIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
          desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Broken Isles"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Broken Isles"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },  
        showAzerothZandalar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
          desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zandalar"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zandalar"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothKulTiras = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
          desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Kul Tiras"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Kul Tiras"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothDragonIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
          desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Dragon Isles"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Dragon Isles"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothKhazAlgar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
          desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 44.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Khaz Algar"], L["icons"],  L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Khaz Algar"], L["icons"],  L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        }
      },
    CosmosTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = WORLDMAP_BUTTON,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 5,
      args = {
        Cosmosheader = {
          type = "header",
          name = WORLDMAP_BUTTON .. " " .. L["Informations"],
          order = 50,
          },
        CosmosDescriptionText = {
          name = function()
              if ns.Addon.db.profile.activate.SwapButtons then
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Right-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              else
                return "|cffff0000" .. TextIconInfo:GetIconString() .. " " .. "|cffffff00" .. L["Left-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"]
              end
            end,
          type = "description",
          order = 50.1,
          },      
        Cosmostheader1 = {
          type = "description",
          name = "",
          order = 50.3,
          },
        showCosmos = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          order = 50.6,
          width = 1,
          get = function() return ns.Addon.db.profile.activate.CosmosMap end,
          set = function(info, v) ns.Addon.db.profile.activate.CosmosMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CosmosMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(946) else
                if not ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CosmosMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(946) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CosmosMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(946) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cff00ff00" .. L["is activated"]) else
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CosmosMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(946) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", WORLDMAP_BUTTON, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },  
        cosmosScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,
          order = 50.8,
          },
        cosmosAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,
          order = 50.9,
          },
        Cosmosheader4 = {
            type = "header",
            name = L["Show all MapNotes for a specific map"],
            order = 53.1,
            },
        showCosmosKalimdor= {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosEasternKingdom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosOutland = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconBC:GetIconString() .. " " .. L["Outland"],
          desc = L["Show all Outland MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosNorthrend = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
          desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosPandaria = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
          desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Pandaria"], L["icons"],L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosDraenor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconDraenor:GetIconString() .. " " .. L["Draenor"],
          desc = L["Show all Draenor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosBrokenIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
          desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosZandalar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
          desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosKulTiras = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
          desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosShadowlands = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconSL:GetIconString() .. " " .. L["Shadowlands"],
          desc = L["Show all Shadowlands MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosDragonIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
          desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosKhazAlgar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
          desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        },
      },
    DungeonMapTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = DUNGEONS,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 6,
      args = {    
        DungeonMapHeader1 = {
          type = "description",
          name = "",
          order = 1.0,
          width = 1,
          },    
        showDungeonMap = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Enables the display of all possible icons on this map"],
          order = 1.3,
          get = function() return ns.Addon.db.profile.activate.DungeonMap end,
          set = function(info, v) ns.Addon.db.profile.activate.DungeonMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.DungeonMap and not WorldMapFrame:IsShown() then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) else 
                if not ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.DungeonMap and not WorldMapFrame:IsShown() then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.DungeonMap and not WorldMapFrame:IsShown()then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.DungeonMap and not WorldMapFrame:IsShown() then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },
        DungeonMapSyncScaleAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = L["Synchronize"],
          desc = L["Dungeon map"] .. " " .. L["icons"] .. "\n\n" .. L["Synchronizes size and visibility of all individual symbols"] .. "\n\n" .. L["This disables the individual icon size and visibility sliders"] .. " " .. L["At the same time, all preset size and visibility settings of the individual symbols are replaced by the values set by these two sliders"],
          width = 0.80,
          order = 1.4,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          set = function(info, v) ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Dungeon map"], L["symbol size"], L["symbol visibility"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["synchronizes"] .. " " .. L["Dungeon map"], L["symbol size"], L["symbol visibility"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        DungeonHeader2 = {
          type = "description",
          name = "",
          order = 1.5,
          },
        DungeonHeader3 = {
          type = "description",
          name = "",
          order = 1.6,
          width = 0.60,
          },
        dungeonScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or not ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,  
          order = 1.7,
          },
        dungeonAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or not ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,  
          order = 1.8,
          },
        DungeonMapheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 2.0,
          },
        showDungeonExit = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconExit:GetIconString(),
          desc = L["Exits"] .. "\n\n" .. L["Show icons of MapNotes dungeon exit on this map"],
          order = 2.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonExit then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Exits"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonExit then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Exits"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        DungeonMapScaleExit = {
          disabled = function() return not ns.Addon.db.profile.showDungeonExit or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,
          order = 2.2,
          },
        DungeonMapHeaderScaleAlphaExit = {
          type = "description",
          name = "",
          order = 2.3,
          width = 0.10,
          },
        DungeonMapAlphaExit = {
          disabled = function() return not ns.Addon.db.profile.showDungeonExit or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 2.4,
          },
        DungeonMapPortalHeader = {
          type = "description",
          name = "",
          order = 3.0,
          },
        showDungeonPortal = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString(),
          desc =  L["Portals"] .. "\n\n" .. L["Show icons of portals on this map"],
          order = 3.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonPortal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonPortal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        DungeonMapScalePortal = {
          disabled = function() return not ns.Addon.db.profile.showDungeonPortal or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,
          order = 3.2,
          },
        DungeonMapHeaderScaleAlphaPortal = {
          type = "description",
          name = "",
          order = 3.3,
          width = 0.10,
          },
        DungeonMapAlphaPortal = {
          disabled = function() return not ns.Addon.db.profile.showDungeonPortal or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 3.4,
          },
        DungeonMapPassageHeader = {
          type = "description",
          name = "",
          order = 4.0,
          },
        showDungeonPassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. TextIconPassageleft:GetIconString(),
          desc = L["Passages"] .. "\n\n" .. L["Show icons of passage on this map"],
          order = 4.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        DungeonMapScalePassage = {
          disabled = function() return not ns.Addon.db.profile.showDungeonPassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,
          order = 4.2,
          },
        DungeonMapHeaderScaleAlphaPassage = {
          type = "description",
          name = "",
          order = 4.3,
          width = 0.10,
          },
        DungeonMapAlphaPassage = {
          disabled = function() return not ns.Addon.db.profile.showDungeonPassage or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 4.4,
          },
        DungeonMapTransportHeader = {
          type = "description",
          name = "",
          order = 5.0,
          },
        showDungeonTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconTravelL:GetIconString() .. " " .. TextIconTransport:GetIconString(),
          desc = L["Transport"] .. "\n\n" .. L["Shows special transport icons like"] .. "\n" .. TextIconTravelL:GetIconString() .. "\n" .. TextIconTransport:GetIconString(),
          order = 5.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        DungeonMapScaleTransport = {
          disabled = function() return not ns.Addon.db.profile.showDungeonTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,
          order = 5.2,
          },
        DungeonMapHeaderScaleAlphaTransport = {
          type = "description",
          name = "",
          order = 5.3,
          width = 0.10,
          },
        DungeonMapAlphaTransport = {
          disabled = function() return not ns.Addon.db.profile.showDungeonTransport or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 5.4,
          },
        DungeonMapVendorHeader = {
          type = "description",
          name = "",
          order = 6.0,
          },
        showDungeonVendor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconPvEVendor:GetIconString() .. " " .. TextIconPvPVendor:GetIconString(),
          desc =  L["Transport"] .. "\n\n" .. L["Shows special transport icons like"] .. "\n" .. TextIconPvEVendor:GetIconString() .. "\n" .. TextIconPvPVendor:GetIconString(),
          order = 6.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], MERCHANT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], MERCHANT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        DungeonMapScaleVendor = {
          disabled = function() return not ns.Addon.db.profile.showDungeonVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,
          order = 6.2,
          },
        DungeonMapHeaderScaleAlphaVendor = {
          type = "description",
          name = "",
          order = 6.3,
          width = 0.10,
          },
        DungeonMapAlphaVendor = {
          disabled = function() return not ns.Addon.db.profile.showDungeonVendor or ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap or ns.Addon.db.profile.activate.DungeonMapSyncScaleAlpha end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 6.4,
          },
        },
      },
    },
  }
end