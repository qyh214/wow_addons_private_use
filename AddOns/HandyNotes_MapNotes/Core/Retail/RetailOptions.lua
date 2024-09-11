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
        --Description = {
        --  type = "header",
        --  name = CORE_ABILITIES,
        --  order = 0.1,
        --  },
        DescriptionHeaderRestore = {
          type = "header",
          name = L["Restore all deleted icons for different types of maps"],
          order = 0,
          },
        RestoreAllIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = ACHIEVEMENTFRAME_FILTER_ALL,
          desc = "|cffffff00" .. "•" .. L["Capitals"] .. " +" .. "\n" .. "•" .. MINIMAP_LABEL .. " +" .. "\n" .. "•" .. L["Continents"] .. "\n" .. "•" .. AZEROTH .. "\n" .. "•" .. CALENDAR_TYPE_DUNGEON .. "|r" .. "\n" .. "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.40,
          order = 0.1,
          func = function(info, v) ns.Addon.db.profile.RestoreAllIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_ALL?") end,
          }, 
        RestoreCapitalsDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Capitals"] .. " +",
          desc = "|cffffff00" .. L["Capitals"]  .. " - " .. MINIMAP_LABEL .."|r" .. "\n" .. "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.70,
          order = 0.2,
          func = function(info, v) ns.Addon.db.profile.RestoreCapitalsDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Capitals?") end,
          }, 
        RestoreZoneDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Zones"] .. " +",
          desc = "|cffffff00" .. MINIMAP_LABEL .. "|r" .. "\n" .. "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 0.3,
          func = function(info, v) ns.Addon.db.profile.RestoreZoneDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Zone?") end,
          }, 
        RestoreContinentDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Continents"],
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 0.4,
          func = function(info, v) ns.Addon.db.profile.RestoreContinentDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Continent?") end,
          }, 
        RestoreAzerothDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = AZEROTH,
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 0.5,
          func = function(info, v) ns.Addon.db.profile.RestoreAzerothDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Azeroth?") end,
          }, 
        RestoreDungeonDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = CALENDAR_TYPE_DUNGEON,
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.60,
          order = 0.6,
          func = function(info, v) ns.Addon.db.profile.RestoreDungeonDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show("Restore_Dungeon?") end,
          }, 
        DescriptionHeader3 = {
          type = "header",
          name = COMPACT_UNIT_FRAME_PROFILE_SUBTYPE_ALL .. " / " .. ADVANCED_OPTIONS,
          order = 1.5,
          },
        hideAddon = {
          type = "toggle",
          name = L["hide MapNotes!"],
          desc = L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"],
          order = 1.8,
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
          order = 1.9,
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
          order = 2,
          width = 1.20,
          confirm = true,
          get = function() return ns.Addon.db.profile.activate.HideWMB end,
          set = function(info, v) ns.Addon.db.profile.activate.HideWMB = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Show() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints();  else
            if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Hide() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); else
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Show() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cff00ff00" .. L["is activated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Hide() OpenWorldMap(uiMapID) LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },
        MapNotesIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = ns.COLORED_ADDON_NAME .. " " .. L["icons"],
          desc = TextIconMNL4:GetIconString() ..  " " .. TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString() .. " " .. L["Displays special MapNotes summary icons containing several different pieces of information (dungeons/raids/portals, etc.)"],
          order = 2.1,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.MapNotesIcons end,
          set = function(info, v) ns.Addon.db.profile.activate.MapNotesIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.MapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.MapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
          },
        EnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"] .. "\n" .. "\n" .. L["However, this only applies to the Azeroth & continent map. Not for Zones + & Capital + category. These have their own activation option for opposing players"],
          order = 2.2,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.EnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.EnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.EnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.EnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
         },
        ShiftWorld = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["Shift function!"],
          desc = L["When enabled, you must press Shift before left- or right-clicking to interact with MapNotes icons. But this has an advantage because there are so many icons in the game, including from other addons, so you don't accidentally click on a symbol and change the map, or mistakenly create a TomTom point."],
          order = 2.3,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.ShiftWorld end,
          set = function(info, v) ns.Addon.db.profile.activate.ShiftWorld = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ShiftWorld then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Shift function"], "|cff00ff00" .. L["is deactivated"] .. " " .. L["You can now interact with MapNotes icons without having to press Shift + Click at the same time"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ShiftWorld then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Shift function"], "|cffff0000" .. L["is activated"] .. " " .. L["You must now always press Shift + Click at the same time to interact with the MapNotes icons"]) end end end,
          },
        ClassicIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. AUCTION_HOUSE_FILTER_DROPDOWN_NONE .. " " .. L["Passages"],
          desc = INSTANCE .. " " .. L["Passage"] .. " " .. L["icons"] .. "\n" .. TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. "\n" .. "\n" .. L["Only affects passage icons to instances and not path icons to zones"] .. "\n" .. "\n" .. L["Changes all passage symbols on all maps to dungeon, raid or multiple symbols. In addition, the passage option will be disabled everywhere and the symbols will be added to the respective raids, dungeons or multiple options (The dungeon map remains unchanged from all this)"] .. "\n" .. "\n" .. L["At the same time, all icons representing additional instance inputs are removed"],
          order = 2.4,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.ClassicIcons end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", AUCTION_HOUSE_FILTER_DROPDOWN_NONE, L["Passages"], L["icons"], "|cff00ff00" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", AUCTION_HOUSE_FILTER_DROPDOWN_NONE, L["Passages"], L["icons"], "|cffff0000" .. L["is activated"]) end end end,
          },
        journal = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TextIconJournal:GetIconString() .. " " .. L["Adventure guide"],
          desc = L["Left-clicking on a MapNotes raid (green), dungeon (blue) or multiple icon (green&blue) on the map opens the corresponding dungeon or raid map in the Adventure Guide (the map must not be open in full screen)"] .. " " .. L["Left-clicking on a multiple icon will open the map where the dungeons are located"],
          order = 2.5,
          width = 1.05,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.journal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Adventure guide"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.journal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Adventure guide"], "|cffff0000" .. L["is deactivated"]) end end end,
          },    
        tomtom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TextIconTomTom:GetIconString() .. " " .. L["TomTom waypoints"],
          desc = L["Shift+right click on a raid, dungeon, multiple symbol, portal, ship, zeppelin, passage or exit from MapNotes on the continent or dungeon map creates a TomTom waypoint to this point (but the TomTom add-on must be installed for this)"],
          order = 2.6,
          width = 1.05,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.tomtom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["TomTom waypoints"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.tomtom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["TomTom waypoints"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        extraInformation = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TextIconKilledBosses:GetIconString() .. " " .. L["extra information"],
          desc = L["Displays additional information for dungeons or raids. E.g. the number of bosses already killed"],
          order = 2.7,
          width = 1.05,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.assignedID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["extra information"], "|cff00ff00" .. L["is activated"]) else 
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.assignedID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["extra information"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        graymultipleID = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TextIconLocked:GetIconString() .. " " .. TextIconMultipleM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " .. L["gray all"],
          desc = L["Colors EVERYONE! Assigned dungeons and raids also have multiple points in gray (if you have an ID)"],
          order = 2.8,
          width = 1.05,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.graymultipleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray all"], "|cff00ff00" .. L["is activated"]) else 
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.graymultipleID then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray all"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },          
        assignedgray = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.graymultipleID end,
          type = "toggle",
          name = TextIconLocked:GetIconString() .. " " .. TextIconRaid:GetIconString() .. " " .. TextIconDungeon:GetIconString() .. " " .. L["gray single"],
          desc = L["Colors only individual points of assigned dungeons and raids in gray (if you have an ID)"],
          order = 2.9,
          width = 1.05,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.assignedgray then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray single"], "|cff00ff00" .. L["is activated"]) else 
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.assignedgray then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["gray single"], "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        DescriptionHeader2 = {
          type = "header",
          name = L["chat message"],
          order = 3,
          },
        CoreChatMassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = CORE_ABILITIES,
          desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n" .. "\n" .. "• " .. GENERAL .. "\n" .. "• " .. L["Profiles"] .. "\n" .. "\n" .. "|cffff0000" .. L["An exception is the feedback in the chat from the function for deleting or restoring icons. These are always displayed!"],
          order = 3.1,
          width = 0.80,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cff00ff00" .. L["is activated"]) else 
            if not ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
          }, 
        ChatMassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = LAYOUT_STYLE_CLASSIC,
          desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n" .. "\n" .. "• " .. L["Capitals"] .. " + " .. "\n" .. "• " .. L["Zones"] .. " + " .. "\n" .. "• " .. L["Continents"] .. "\n" .. "• " .. AZEROTH .. "\n" .. "• " .. WORLDMAP_BUTTON .. "\n" .. "• " .. L["Dungeons"],
          order = 3.2,
          width = 0.60,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. LAYOUT_STYLE_CLASSIC, L["chat message"], "|cff00ff00" .. L["is activated"]) else 
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. LAYOUT_STYLE_CLASSIC, L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
          }, 
        MmbWmbChatMessage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "MMB/WMB",
          desc = "• " .. L["-> MiniMapButton <-"] .. "\n" .. "• " .. L["-> WorldMapButton <-"] .. "\n" .. "\n" .. L["Here you can enable or disable all chat messages sent by MapNotes Minimap and Worldmap buttons when you hide or show icons over them"],
          order = 3.3,
          width = 0.85,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cff00ff00" .. L["is activated"]) else 
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
          }, 
        ZoneChanged = {
          type = "toggle",
          name = L["Location"],
          desc = L["When entering a new zone, the name of the new zone will be displayed in the chat"],
          order = 3.4,
          width = 0.55,
          get = function() return ns.Addon.db.profile.ZoneChanged end,
          set = function(info, v) ns.Addon.db.profile.ZoneChanged = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"],  "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        ZoneChangedDetail = {
          disabled = function() return not ns.Addon.db.profile.ZoneChanged end,
          type = "toggle",
          name = L["Location"] .. "|cff00ccff " .. LFG_LIST_DETAILS,
          desc = L["In addition to the zone names, it also displays the names of specific locations within a zone. Disabling the Show Zone Names feature will also disable this feature"] .. "\n" .. "\n" .. L["Capital cities are excluded from this because there would be too much chat spam"],
          order = 3.5,
          width = 0.85,
          get = function() return ns.Addon.db.profile.ZoneChangedDetail end,
          set = function(info, v) ns.Addon.db.profile.ZoneChangedDetail = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cff00ff00" .. L["is activated"]) end end end,
          },
        DescriptionHeader4 = {
          type = "header",
          name = SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. BINDING_NAME_MOVIE_RECORDING_GUI,
          order = 4.0,
          },
        RemoveBlizzInstances = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = DUNGEONS .. "/" .. RAIDS,
          desc = TextIconRaid:GetIconString() .. " " .. TextIconDungeon:GetIconString() .. " " ..  L["Disables the display of all Blizzard Dungeon and Raid icons on the zone map"],
          order = 4.1,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.RemoveBlizzInstances end,
          set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 0) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DUNGEONS .. " / " .. RAIDS .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 1) print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. DUNGEONS .. " / " .. RAIDS .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] ) else
            if not ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 0) else
            if not ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzInstances then SetCVar("showDungeonEntrancesOnMap", 1) end end end end end,
          },
        RemoveBlizzPOIs = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "POIs",
          desc = L["Points of interests"] .. "\n" .. "\n" .. L["Removes the Blizzard symbols only where MapNotes symbols and Blizzard symbols overlap, thereby making the tooltip and the function of the MapNote symbols usable again on the overlapping points"],
          order = 4.2,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.RemoveBlizzPOIs end,
          set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzPOIs = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
          },
        GeneralHeaderFogofWar = {
          type = "header",
          name = L["Unexplored Areas"] .. " - " .. L["Mist of the Unexplored"],
          order = 5,
          },
        FogOfWar = {
          --disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["Unexplored Areas"],
          desc = L["Reveals unexplored areas and shows the individual areas of each zone that are actually still unexplored"],
          order = 5.1,
          width = 1.05,
          get = function() return ns.Addon.db.profile.activate.FogOfWar end,
          set = function(info, v) ns.Addon.db.profile.activate.FogOfWar = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            HandyNotes:GetModule("FogOfWarButton"):Refresh()
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.FogOfWar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Unexplored Areas"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.FogOfWar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Unexplored Areas"], "|cff00ff00" .. L["is activated"]) end end end,
          }, 
        MistOfTheUnexplored = {
          disabled = function() return not ns.Addon.db.profile.activate.FogOfWar end,          
          type = "toggle",
          name = L["Mist of the Unexplored"],
          desc = L["Leaves the unexplored areas revealed but adds a slight fog so you can still see which ones you haven't explored yet"],
          width = 1.17,
          order = 5.2,
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
          width = 0.80,
          order = 5.3,
					get = "GetFogOfWarColor",
					set = "SetFogOfWarColor",
          handler = ns.FogOfWar,
					hasAlpha = true,
          }, 
        --GeneralHeader = {
        --  type = "header",
        --  name = ADVANCED_OPTIONS,
        --  order = 5.0,
        --  },
        ClassicIconsheader = {
            type = "header",
            name = L["Old icon style"] .. " - " .. LAYOUT_STYLE_CLASSIC .. " / " .. LAYOUT_STYLE_MODERN,
            order = 8.0,
            },
        ClassicPortals = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["Portals"] .. " " .. TextIconPortalOld:GetIconString() .. "" .. TextIconHPortalOld:GetIconString() .. "" .. TextIconAPortalOld:GetIconString(),
          desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Portals"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. "\n" .. TextIconPassagePortalOld:GetIconString() .. " " .. TextIconPassageHPortalOld:GetIconString() .. " " .. TextIconPassageAPortalOld:GetIconString() .. "\n" .. "\n" .. L["Portals"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. "\n" .. TextIconPassagePortal:GetIconString() .. " " .. TextIconPassageHPortal:GetIconString() .. " " .. TextIconPassageAPortal:GetIconString(),
          width = 0.75,
          order = 8.2,
          get = function() return ns.Addon.db.profile.activate.ClassicPortals end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicPortals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cffff0000" .. L["is deactivated"]) else
              if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        ClassicShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["Ships"] .. " " .. TextIconShipOld:GetIconString() .. "" .. TextIconHShipOld:GetIconString() .. "" .. TextIconAShipOld:GetIconString(),
          desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Ships"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. "\n" .. "\n" .. L["Ships"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString(),
          width = 0.75,
          order = 8.3,
          get = function() return ns.Addon.db.profile.activate.ClassicShips end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicShips = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        ClassicZeppelin = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = L["Zeppelins"] .. " " .. TextIconZeppelinOld:GetIconString() .. "" .. TextIconHZeppelinOld:GetIconString(),
          desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Zeppelins"] .. " - " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. "\n" .. "\n" .. L["Zeppelins"] .. " - " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString(),
          width = 0.85,
          order = 8.4,
          get = function() return ns.Addon.db.profile.activate.ClassicZeppelin end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicZeppelin = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        ClassicBank = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = BANK .. " " .. TextIconBankOld:GetIconString(),
          desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. BANK .. " " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconBankOld:GetIconString() .. "\n" .. "\n" .. BANK .. " " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconBank:GetIconString(),
          width = 0.55,
          order = 8.5,
          get = function() return ns.Addon.db.profile.activate.ClassicBank end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicBank = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cff00ff00" .. L["is activated"]) end end end,
          },
        ClassicProfession = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = TRADE_SKILLS .. " " ..  TextIconProfessionOrders:GetIconString(),
          desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. TRADE_SKILLS .. " " .. LAYOUT_STYLE_CLASSIC .. "\n" .. TextIconOriginalAlchemy:GetIconString() .. " " .. TextIconOriginalBlacksmith:GetIconString() .. " " .. TextIconOriginalEngineer:GetIconString() .. " " .. TextIconOriginalSkinning:GetIconString() .. " " .. TextIconOriginalTailoring:GetIconString() .. " " .. TextIconOriginalJewelcrafting:GetIconString() .. " " .. TextIconOriginalLeatherworking:GetIconString() .. " " .. TextIconOriginalHerbalism:GetIconString() .. " " .. TextIconOriginalMining:GetIconString() .. " " .. TextIconOriginalEnchanting:GetIconString() .. " " .. TextIconOriginalInscription:GetIconString() .. " " .. TextIconOriginalArchaeology:GetIconString() .. " " .. TextIconOriginalCooking:GetIconString() .. " " .. TextIconOriginalFishing:GetIconString() .. " " ..  "\n" .. "\n" .. TRADE_SKILLS .. " " .. LAYOUT_STYLE_MODERN .. "\n" .. TextIconAlchemy:GetIconString() .. " " .. TextIconBlacksmith:GetIconString() .. " " .. TextIconEngineer:GetIconString() .. " " .. TextIconSkinning:GetIconString() .. " " .. TextIconTailoring:GetIconString() .. " " .. TextIconJewelcrafting:GetIconString() .. " " .. TextIconLeatherworking:GetIconString() .. " " .. TextIconHerbalism:GetIconString() .. " " .. TextIconMining:GetIconString() .. " " .. TextIconEnchanting:GetIconString() .. " " .. TextIconInscription:GetIconString() .. " " .. TextIconArchaeology:GetIconString() .. " " .. TextIconCooking:GetIconString() .. " " .. TextIconFishing:GetIconString(),
          width = 0.60,
          order = 8.6,
          get = function() return ns.Addon.db.profile.activate.ClassicProfession end,
          set = function(info, v) ns.Addon.db.profile.activate.ClassicProfession = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.ClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.ClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cff00ff00" .. L["is activated"]) end end end,
          },
        },
      },
    CapitalsAndCapitalsMiniMapTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Capitals"] .. " +",
      desc = "|cffffff00" .. L["Capitals"] .. " " .. MINIMAP_LABEL .. "|r" .. "\n" .. "\n" .. L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
      order = 1,
      args = {
        SyncCapitalsAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Capitals tab with the Capitals - Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Capitals - Minimap tab and is now controlled together by the Capitals tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Capitals - Minimap settings and replace them with those from Capitals tab"],
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
          desc = L["Activates the display of all possible icons on this map"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"],
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
          desc = L["Activates the display of all possible icons on this map"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"],
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
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
          order = 1,
          args = {
            Capitalstheader1 = {
              type = "header",
              name = L["Capitals"] .. " " .. L["icons"],
              order = 1.1,
              },
            CapitalsDescriptionText = {
              name = "|cffff0000" .. L["Capitals"] .. " " .. L["icons"] .. "\n" .. "\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Capital"],
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
                  name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
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
                  name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGolden:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"] .. "\n" .. TextIconWayGateGolden:GetIconString() .. " " .. L["The Timeways"] .. " " .. L["Portal"],                  order = 31.3,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
                  type = "toggle",
                  name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
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
                  name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
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
                  desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n" .. "\n" .. " " .. TextIconTransport:GetIconString() .. " " .. L["Teleporter"] .. " - " .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"] .. "\n" .. "\n" .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
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
                showCapitalsProfessionOrders = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                  desc = PLACE_CRAFTING_ORDERS,
                  width = 1.2,
                  order = 41.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showCapitalsAlchemy = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
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
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n" .. "\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"] .. "\n" .. "...",
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
                  desc = FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. " " .. L["Valdrakken"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"] ,
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
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"],              
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
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
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
                },
              },
            },
          },
        MinimapCapitalsTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "group",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL,
          desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. ORGRIMMAR .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. STORMWIND .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. EXPANSION_NAME6 .. "\n" .. L["Shrine7Stars"] .. "\n" .. L["Shrine2Moons"] .. "\n" .. L["Stormshield"] .. "\n" .. L["Warspear"] .. "\n" .. L["Dazar'alor"] .. "\n" .. L["Boralus"] .. "\n" .. L["Oribos"] .. "\n" .. L["Valdrakken"] .. "\n" .. CALENDAR_FILTER_DARKMOON,
          order = 2,
          args = {
            Capitalstheader1 = {
              disabled = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "header",
              name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["icons"],
              order = 1,
              },
            MinimapCapitalsDescriptionText = {
              name = "|cffff0000" .. L["Capitals"]  .. " " .. MINIMAP_LABEL .. " " .. L["icons"] .. "\n" .. "\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Capital"],
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
                  name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
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
                  name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGolden:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"] .. "\n" .. TextIconWayGateGolden:GetIconString() .. " " .. L["The Timeways"] .. " " .. L["Portal"],
                  order = 85,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsZeppelins = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
                  type = "toggle",
                  name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
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
                  name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
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
                  desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n" .. "\n" .. " " .. TextIconTransport:GetIconString() .. " " .. L["Teleporter"] .. " - " .. L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"] .. "\n" .. "\n" .. " " .. TextIconTransport:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
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
                  minimapcapitalprofessionheader5 = {
                  type = "header",
                  name = "",
                  order = 86.7,
                  },
                showMinimapCapitalsProfessionOrders = {
                  disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions end,
                  type = "toggle",
                  name = TextIconProfessionOrders:GetIconString() .. " " .. PROFESSIONS_CRAFTING_ORDERS_TAB_NAME,
                  desc = PLACE_CRAFTING_ORDERS,
                  width = 1.2,
                  order = 88,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsProfessionOrders then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_CRAFTING_ORDERS_TAB_NAME, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMinimapCapitalsAlchemy = {
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
                  desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n" .. "\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"] .. "\n" .. "...",
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
                  desc = FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. " " .. L["Valdrakken"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"] ,
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
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"],              
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
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
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
      desc = "|cffffff00" .. L["Zones"] .. "-" .. MINIMAP_LABEL .. "|r" .. "\n" .. "\n" .. L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 2,
      args = {
        SyncZoneAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Zones tab with the Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Minimap tab and is now controlled together by the Zones tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Minimap settings and replace them with those from Zones tab"],
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
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"] .. "\n" .. "\n" .. L["By deactivating it, the border of the zone icons of your own factions is also removed, as the displayed icons are automatically only for your own faction"],
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
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"] .. "\n" .. "\n" .. L["By deactivating it, the border of the zone icons of your own factions is also removed, as the displayed icons are automatically only for your own faction"],
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
              name = "|cffff0000" .. L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAP .. " " .. L["icons"] .. "\n" .. "\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Continent"],
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
                zonecontinentheader1 = {
                  type = "header",
                  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. CONTINENT .. " " .. L["icons"],
                  order = 0.1,
                  },
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
            ZoneInstanceTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 2,
              args = {
                zoneinstanceheader1 = {
                  type = "header",
                  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. INSTANCE .. " " .. L["icons"],
                  order = 1.1,
                  },
                zoneinstanceheader3 = {
                  type = "description",
                  name = "",
                  order = 1.3,
                  width = 0.85,
                  },   
                ZoneInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 10,
                  get = function() return ns.Addon.db.profile.activate.ZoneInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zoneinstanceheader4 = {
                  type = "description",
                  name = "\n",
                  order = 10.1,
                  },
                zoneinstanceheader5 = {
                  type = "description",
                  name = "",
                  order = 10.2,
                  width = 0.20,
                  },
                ZoneInstanceScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "range",
                  name = INSTANCE .. " " .. L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 10.3,
                  },
                zoneinstanceheader6 = {
                  type = "description",
                  name = "",
                  order = 10.4,
                  width = 0.20,
                  },
                ZoneInstanceAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "range",
                  name = INSTANCE .. " " .. L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 10.5,
                  },
                zoneinstanceheader8 = {
                  type = "header",
                  name = "",
                  order = 10.7,
                  },
                showZoneRaids = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
                  desc = L["Show icons of raids on this map"],
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneDungeons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
                  desc = L["Show icons of dungeons on this map"],
                  order = 11.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZonePassage = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or ns.Addon.db.profile.activate.ClassicIcons or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
                  desc = L["Show icons of passage to raids and dungeons on this map"],
                  order = 11.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneMultiple = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
                  desc = L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 11.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneOldVanilla = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
                  desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 11.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                showZoneLFR = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneInstances end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 11.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 "..  L["Zone map"], PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 "..  L["Zone map"], PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                },
              },
            ZoneTransportTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                zonetransportheader1 = {
                  type = "header",
                  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Transport"] .. " " .. L["icons"],
                  order = 2.1,
                  },
                zonetransportheader3 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.85,
                  },    
                ZoneTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 20,
                  get = function() return ns.Addon.db.profile.activate.ZoneTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zonetransportheader4 = {
                  type = "description",
                  name = "",
                  order = 20.1,
                  },
                zonetransportheader5 = {
                  type = "description",
                  name = "",
                  order = 20.2,
                  width = 0.20,
                  },
                ZoneTransportScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 20.3,
                  },
                zonetransportheader6 = {
                  type = "description",
                  name = "",
                  order = 20.4,
                  width = 0.20,
                  },
                ZoneTransportAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 20.5,
                  },
                zonetransportheader8 = {
                  type = "header",
                  name = "",
                  order = 20.7,
                  },
                showZonePortals = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
                  order = 21.1,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneZeppelins = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
                  desc = L["Show icons of zeppelins on this map"],
                  order = 21.2,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneShips = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
                  desc = L["Show icons of ships on this map"],
                  order = 21.3,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconCarriage:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. L["Transport"],
                  desc = "\n" .. TextIconCarriage:GetIconString() .. " " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " " .. L["Stormwind"] .. " <= => "  .. L["Ironforge"] .. "\n" .. TextIconTravelL:GetIconString() .. " " .. L["Transport"] .. "\n" .. " " .. L["Korthia"] .. " <= => " .. L["The Maw"],
                  order = 21.4,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneOgreWaygate = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"],
                  desc = GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] ,
                  order = 21.5,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ogre Waygate"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ogre Waygate"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneTeleporter = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconTransport:GetIconString() .. " " .. L["Teleporter"],
                  desc = L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"],
                  order = 21.6,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Teleporter"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Teleporter"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneToyTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconToyTransport:GetIconString() .. " " .. TOY,
                  desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconMirror:GetIconString() .. " " .. L["Ever-Shifting Mirror"] .. "\n" .. "  (" .. POSTMASTER_PIPE_OUTLAND .. " <= => " .. POSTMASTER_PIPE_DRAENOR ..")",
                  order = 21.7,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneToyTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TOY, L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneToyTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TOY, L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneTravel = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneTransporting end,
                  type = "toggle",
                  name = TextIconDwarfF:GetIconString() .. " " .. TextIconB11M:GetIconString() .. " " .. TextIconGoblinF:GetIconString() .. " " .. L["Travel"], 
                  desc = L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Nazmir"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconGilneanF:GetIconString() .. " " .. L["Zuldazar"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconKulM:GetIconString() .. " " .. L["Vol'dun"] .. " => " .. L["Boralus"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. TextIconOrcF:GetIconString() .. " " .. L["Drustvar"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconB11M:GetIconString() .. " " .. L["Tiragarde Sound"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconUndeadF:GetIconString() .. " " .. L["Stormsong Valley"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconGoblinF:GetIconString() .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " => " .. L["Zuldazar"],
                  order = 21.8,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Travel"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Travel"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            ZoneGeneralTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {
                zonegeneralheader1 = {
                  type = "header",
                  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["General"] .. " " .. L["icons"],
                  order = 3.1,
                  },
                zonegeneralheader3 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.85,
                  },              
                ZoneGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 30,
                  get = function() return ns.Addon.db.profile.activate.ZoneGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZoneGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZoneGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZoneGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zonegeneralheader4 = {
                  type = "description",
                  name = "",
                  order = 30.1,
                  },
                zonegeneralheader5 = {
                  type = "description",
                  name = "",
                  order = 30.2,
                  width = 0.20,
                  },
                ZonesGeneralScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 30.3,
                  },
                zonegeneralheader6 = {
                  type = "description",
                  name = "",
                  order = 30.4,
                  width = 0.20,
                  },
                ZonesGeneralAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 30.5,
                  },
                zonegeneralheader8 = {
                  type = "header",
                  name = "",
                  order = 30.7,
                  },
                ZoneMapNotesIcons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = ns.COLORED_ADDON_NAME .. " " .. L["icons"],
                  desc = TextIconMNL4:GetIconString() ..  " " .. TextIconHIcon:GetIconString() ..  " " .. TextIconAIcon:GetIconString() .. " " .. L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n" .. "\n" .. "Currently only possible on The War Within zones. Other areas will follow soon",
                  order = 31,
                  width = 0.80,
                  get = function() return ns.Addon.db.profile.ZoneMapNotesIcons end,
                  set = function(info, v) ns.Addon.db.profile.ZoneMapNotesIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if not ns.Addon.db.profile.ZoneMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], L["icons"], "|cffff0000" .. L["are hidden"] ) else
                        if ns.Addon.db.profile.ZoneMapNotesIcons then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. L["Zone map"], L["icons"], "|cff00ccff" .. L["are shown"] )end end end,
                  },
                showZoneInnkeeper = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconInnkeeperN:GetIconString() .. " " .. TextIconInnkeeperH:GetIconString() .. " " .. TextIconInnkeeperA:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER,
                  desc = TextIconInnkeeperN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconInnkeeperH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconInnkeeperA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.80,
                  order = 31.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneAuctioneer = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
                  desc = "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Capitals"] .. "\n" .. "\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE .. "\n" .. " "  .. REFORGE_CURRENT .. " => " .. L["Valdrakken"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.80,
                  order = 31.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneBank = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. BANK,
                  desc = "\n" .. " " .. POSTMASTER_LETTER_AREA52 .. "\n" .. " " .. POSTMASTER_LETTER_WINTERSPRING .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS  .. "\n" .. " " .. POSTMASTER_LETTER_STRANGLETHORNVALE .. "\n" .. " " .. L["Ratchet"] .. " - " .. POSTMASTER_LETTER_BARRENS_SUBTITLE .. "\n" .. " " .. L["Dustwallow Marsh"] .. " = " .. ITEM_REQ_ALLIANCE .. "\n" .. " " .. L["Capitals"],
                  width = 0.80,
                  order = 31.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneBarber = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString() .. " " .. MINIMAP_TRACKING_BARBER,
                  desc = "\n" .. POSTMASTER_LETTER_AREA52 .. "\n" .. L["Capitals"],
                  width = 0.80,
                  order = 31.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneMailbox = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconMailboxN:GetIconString() .. " " .. TextIconMailboxH:GetIconString() .. " " .. TextIconMailboxA:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
                  desc = TextIconMailboxN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconMailboxH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconMailboxA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.90,
                  order = 31.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZonePvPVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvPVendorH:GetIconString() .. " " .. TextIconPvPVendorA:GetIconString() .. " " .. TRANSMOG_SET_PVP,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n" .. "\n" .. TextIconPvPVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n" .. "\n" .. TextIconPvPVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n" .. "\n" .. TextIconPvPVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"],
                  width = 0.80,
                  order = 31.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZonePvEVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TextIconPvEVendorH:GetIconString() .. " " .. TextIconPvEVendorA:GetIconString() .. " " .. TRANSMOG_SET_PVE,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. TextIconPvEVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n" .. "\n" .. TextIconPvEVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Icecrown"] .. "\n" .. " " .. L["Townlong Steppes"] .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. TextIconPvEVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
                  width = 0.60,
                  order = 31.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneStablemaster = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " .. TextIconStablemasterA:GetIconString() .. " " .. MINIMAP_TRACKING_STABLEMASTER,
                  desc = TextIconStablemasterN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconStablemasterH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconStablemasterA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.90,
                  order = 31.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneTransmogger = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER,
                  desc = "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. L["Capitals"],
                  width = 0.90,
                  order = 31.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneItemUpgrade = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString() .. " " .. ITEM_UPGRADE,
                  desc = "",
                  width = 1.2,
                  order = 32.0,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showZoneCatalyst = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZoneGeneral end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString() .. " " .. L["Catalyst"],
                  desc = "",
                  width = 0.75,
                  order = 32.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            ZonePathTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
              type = "group",
              name = "• " .. L["Orientation"] .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                zonepathsheader1 = {
                  type = "header",
                  name = L["Zones"] .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Orientation"] .. " " .. L["icons"],
                  order = 3.1,
                  },
                zonepathsheader3 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.85,
                  },              
                ZonePaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 30,
                  get = function() return ns.Addon.db.profile.activate.ZonePaths end,
                  set = function(info, v) ns.Addon.db.profile.activate.ZonePaths = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.ZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Orientation"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.ZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Zones"], L["Orientation"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                zonepathsheader4 = {
                  type = "description",
                  name = "",
                  order = 30.1,
                  },
                zonepathsheader5 = {
                  type = "description",
                  name = "",
                  order = 30.2,
                  width = 0.20,
                  },
                ZonesPathsScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZonePaths end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 30.3,
                  },
                zonepathsheader6 = {
                  type = "description",
                  name = "",
                  order = 30.4,
                  width = 0.20,
                  },
                ZonesPathsAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZonePaths end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 30.5,
                  },
                zonepathsheader8 = {
                  type = "header",
                  name = "",
                  order = 30.7,
                  },
                showZonePaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap or not ns.Addon.db.profile.activate.ZonePaths end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
                  desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.80,
                  order = 31,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
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
              name = "|cffff0000" .. L["Zones"] .. "-" .. MINIMAP_LABEL  .. " " .. L["icons"] .. "\n" .. "\n" .. "|cffffff00" .. L["The associated settings are regulated here. \nRegardless of whether it is the display of an icon, an entire icon group or the display of the complete icons for the corresponding Continent"] .. "\n" .. L["Some instance icons cannot be hidden because they were created by Blizzard itself and not by MapNotes"],
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
                minimapcontinentheader1 = {
                  type = "header",
                  name = MINIMAP_LABEL .. " " .. CONTINENT .. " " .. L["icons"],
                  order = 0.1,
                  },
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
            MiniMapInstanceTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. INSTANCE .. " " .. L["icons"],
              desc = "",
              order = 2,
              args = {
                minimapinstanceheader1 = {
                  type = "header",
                  name = MINIMAP_LABEL .. " " .. L["icons"],
                  order = 1.1,
                  },
                minimapinstanceheader3 = {
                  type = "description",
                  name = "",
                  order = 1.3,
                  width = 0.85,
                  },   
                MiniMapInstances = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 10,
                  get = function() return ns.Addon.db.profile.activate.MiniMapInstances end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapinstanceheader4 = {
                  type = "description",
                  name = "\n",
                  order = 10.1,
                  },
                minimapinstanceheader5 = {
                  type = "description",
                  name = "",
                  order = 10.2,
                  width = 0.20,
                  },
                MiniMapInstanceScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "range",
                  name = INSTANCE .. " " .. L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 10.3,
                  },
                minimapinstanceheader6 = {
                  type = "description",
                  name = "",
                  order = 10.4,
                  width = 0.20,
                  },
                MiniMapInstanceAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "range",
                  name = INSTANCE .. " " .. L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 10.5,
                  },
                minimapinstanceheader8 = {
                  type = "header",
                  name = "",
                  order = 10.7,
                  },
                showMiniMapRaids = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
                  desc = L["Show icons of raids on this map"],
                  order = 11.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapDungeons = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
                  desc = L["Show icons of dungeons on this map"],
                  order = 11.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapPassage = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
                  desc = L["Show icons of passage to raids and dungeons on this map"],
                  order = 11.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapMultiple = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
                  desc = L["Show icons of multiple (dungeons,raids) on this map"],
                  order = 11.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapOldVanilla = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconVInstance:GetIconString() .. " " .. TextIconMultiVInstance:GetIconString() .. " " .. TextIconVKey1:GetIconString() .. " " .. L["Old Instances"],
                  desc = L["Show vanilla versions of dungeons and raids such as Naxxramas, Scholomance or Scarlet Monastery, which require achievements or other things"],
                  order = 11.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Old Instances"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapOldVanilla then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, L["Old Instances"], "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                showMiniMapLFR = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapInstances end,
                  type = "toggle",
                  name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
                  desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
                  order = 11.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
                  },
                },
              },
            MiniMapTransportTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. L["Transport"] .. " " .. L["icons"],
              desc = "",
              order = 3,
              args = {
                minimaptransportheader1 = {
                  type = "header",
                  name = MINIMAP_LABEL .. " " .. L["Transport"] .. " " .. L["icons"],
                  order = 2.1,
                  },
                minimaptransportheader3 = {
                  type = "description",
                  name = "",
                  order = 2.3,
                  width = 0.85,
                  },    
                MiniMapTransporting = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 20,
                  get = function() return ns.Addon.db.profile.activate.MiniMapTransporting end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimaptransportheader4 = {
                  type = "description",
                  name = "",
                  order = 20.1,
                  },
                minimaptransportheader5 = {
                  type = "description",
                  name = "",
                  order = 20.2,
                  width = 0.20,
                  },
                MiniMapTransportScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,  
                  order = 20.3,
                  },
                minimaptransportheader6 = {
                  type = "description",
                  name = "",
                  order = 20.4,
                  width = 0.20,
                  },
                MiniMapTransportAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 20.5,
                  },
                minimaptransportheader8 = {
                  type = "header",
                  name = "",
                  order = 20.7,
                  },
                showMiniMapPortals = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
                  desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
                  order = 21.1,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapZeppelins = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
                  desc = L["Show icons of zeppelins on this map"],
                  order = 21.2,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapShips = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
                  desc = L["Show icons of ships on this map"],
                  order = 21.3,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconCarriage:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. L["Transport"],
                  desc = "\n" .. TextIconCarriage:GetIconString() .. " " .. DUNGEON_FLOOR_DEEPRUNTRAM1 .. "\n" .. " " .. L["Stormwind"] .. " <= => "  .. L["Ironforge"] .. "\n" .. TextIconTravelL:GetIconString() .. " " .. L["Transport"] .. "\n" .. " " .. L["Korthia"] .. " <= => " .. L["The Maw"],
                  order = 21.4,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapOgreWaygate = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"],
                  desc = GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] ,
                  order = 21.5,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ogre Waygate"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapOgreWaygate then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ogre Waygate"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapTeleporter = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconTransport:GetIconString() .. " " .. L["Teleporter"],
                  desc = L["Oribos"] .. "/" .. L["Korthia"] .. "/" .. "\n" .. " " .. L["The Maw"] .. "/" .. L["Shadowlands"],
                  order = 21.6,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Teleporter"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTeleporter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Teleporter"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapToyTransport = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconToyTransport:GetIconString() .. " " .. TOY,
                  desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconMirror:GetIconString() .. " " .. L["Ever-Shifting Mirror"] .. "\n" .. "  (" .. POSTMASTER_PIPE_OUTLAND .. " <= => " .. POSTMASTER_PIPE_DRAENOR ..")",
                  order = 21.7,
                  width = 0.90,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapToyTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TOY, L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapToyTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TOY, L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapTravel = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapTransporting end,
                  type = "toggle",
                  name = TextIconDwarfF:GetIconString() .. " " .. TextIconB11M:GetIconString() .. " " .. TextIconGoblinF:GetIconString() .. " " .. L["Travel"], 
                  desc = L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Nazmir"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconGilneanF:GetIconString() .. " " .. L["Zuldazar"] .. " => " .. L["Boralus"] .. "\n" .. " " .. TextIconKulM:GetIconString() .. " " .. L["Vol'dun"] .. " => " .. L["Boralus"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. TextIconOrcF:GetIconString() .. " " .. L["Drustvar"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconB11M:GetIconString() .. " " .. L["Tiragarde Sound"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconUndeadF:GetIconString() .. " " .. L["Stormsong Valley"] .. " => " .. L["Zuldazar"] .. "\n" .. " " .. TextIconGoblinF:GetIconString() .. " " .. SPLASH_BATTLEFORAZEROTH_8_2_0_FEATURE1_TITLE .. " => " .. L["Zuldazar"],
                  order = 21.8,
                  width = 0.80,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Travel"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTravel then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Travel"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            MiniMapGeneralTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. L["General"] .. " " .. L["icons"],
              desc = "",
              order = 4,
              args = {
                minimapgeneralheader1 = {
                  type = "header",
                  name = MINIMAP_LABEL .. " " .. L["General"] .. " " .. L["icons"],
                  order = 3.1,
                  },
                minimapgeneralheader3 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.85,
                  },     
                MiniMapGeneral = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 30,
                  get = function() return ns.Addon.db.profile.activate.MiniMapGeneral end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimapgeneralheader4 = {
                  type = "description",
                  name = "",
                  order = 30.1,
                  },
                minimapgeneralheader5 = {
                  type = "description",
                  name = "",
                  order = 30.2,
                  width = 0.20,
                  },
                MiniMapGeneralScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 30.3,
                  },
                minimapgeneralheader6 = {
                  type = "description",
                  name = "",
                  order = 30.4,
                  width = 0.20,
                  },
                MiniMapGeneralAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 30.5,
                  },
                minimapgeneralheader8 = {
                  type = "header",
                  name = "",
                  order = 30.7,
                  },
                showMiniMapInnkeeper = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconInnkeeperN:GetIconString() .. " " .. TextIconInnkeeperH:GetIconString() .. " " .. TextIconInnkeeperA:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER,
                  desc = TextIconInnkeeperN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconInnkeeperH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconInnkeeperA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.80,
                  order = 31.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapAuctioneer = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconAuctioneer:GetIconString() .. " " .. TextIconBlackMarket:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
                  desc = TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconBlackMarket:GetIconString() .. " " .. BLACK_MARKET_AUCTION_HOUSE,
                  width = 0.80,
                  order = 31.2,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapAuctioneer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_AUCTIONEER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapBank = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconBank:GetIconString() .. " " .. BANK,
                  desc = "",
                  width = 0.80,
                  order = 31.3,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapBarber = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconBarber:GetIconString() .. " " .. MINIMAP_TRACKING_BARBER,
                  desc = "",
                  width = 0.80,
                  order = 31.4,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_BARBER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapBarber then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_BARBER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapMailbox = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconMailboxN:GetIconString() .. " " .. TextIconMailboxH:GetIconString() .. " " .. TextIconMailboxA:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
                  desc = TextIconMailboxN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconMailboxH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconMailboxA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.90,
                  order = 31.5,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapPvPVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvPVendorH:GetIconString() .. " " .. TextIconPvPVendorA:GetIconString() .. " " .. TRANSMOG_SET_PVP,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n" .. "\n" .. TextIconPvPVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n" .. "\n" .. TextIconPvPVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n" .. "\n" .. TextIconPvPVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"],
                  width = 0.80,
                  order = 31.6,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPvPVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVP .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapPvEVendor = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconPvEVendor:GetIconString() .. " " .. TextIconPvEVendorH:GetIconString() .. " " .. TextIconPvEVendorA:GetIconString() .. " " .. TRANSMOG_SET_PVE,
                  desc = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" .. TextIconPvEVendorH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n" .. "\n" .. TextIconPvEVendor:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Icecrown"] .. "\n" .. " " .. L["Townlong Steppes"] .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. TextIconPvEVendorA:GetIconString() .. " " .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
                  width = 0.60,
                  order = 31.7,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapStablemaster = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconStablemasterN:GetIconString() .. " " .. TextIconStablemasterH:GetIconString() .. " " ..TextIconStablemasterA:GetIconString() .. " " .. MINIMAP_TRACKING_STABLEMASTER,
                  desc = TextIconStablemasterN:GetIconString() .. " " .. FACTION_NEUTRAL .. "\n" .. TextIconStablemasterH:GetIconString() .. " " .. FACTION_HORDE .. "\n" .. TextIconStablemasterA:GetIconString() .. " " .. FACTION_ALLIANCE,
                  width = 0.90,
                  order = 31.8,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapStablemaster then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_STABLEMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapTransmogger = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconTransmogger:GetIconString() .. " " .. MINIMAP_TRACKING_TRANSMOGRIFIER,
                  desc = FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Dazar'alor"] .. "\n" .. " " .. L["Warspear"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Oribos"] .. "\n" .. " " .. L["Valdrakken"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Boralus"] .. "\n" .. " " .. L["Stormshield"] ,
                  width = 0.90,
                  order = 31.9,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTransmogger then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, MINIMAP_TRACKING_TRANSMOGRIFIER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapItemUpgrade = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconItemUpgrade:GetIconString() .. " " .. ITEM_UPGRADE,
                  desc = "",
                  width = 1.2,
                  order = 32.0,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, ITEM_UPGRADE, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapItemUpgrade then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, ITEM_UPGRADE, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                showMiniMapCatalyst = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapGeneral end,
                  type = "toggle",
                  name = TextIconCatalyst:GetIconString() .. " " .. L["Catalyst"],
                  desc = "",
                  width = 0.75,
                  order = 32.1,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Catalyst"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapCatalyst then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Catalyst"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
                  },
                },
              },
            MiniMapPathTab = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
              type = "group",
              name = "• " .. L["Orientation"] .. " " .. L["icons"],
              desc = "",
              order = 5,
              args = {
                minimappathsheader1 = {
                  type = "header",
                  name = MINIMAP_LABEL .. " " .. L["Orientation"] .. " " .. L["icons"],
                  order = 3.1,
                  },
                minimappathsheader3 = {
                  type = "description",
                  name = "",
                  order = 3.3,
                  width = 0.85,
                  },     
                MiniMapPaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap end,
                  type = "toggle",
                  name = L["Activate icons"],
                  desc = L["Enables the display of all possible icons on this map"],
                  width = 0.90,
                  order = 30,
                  get = function() return ns.Addon.db.profile.activate.MiniMapPaths end,
                  set = function(info, v) ns.Addon.db.profile.activate.MiniMapPaths = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Orientation"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL, L["Orientation"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
                  },
                minimappathsheader4 = {
                  type = "description",
                  name = "",
                  order = 30.1,
                  },
                minimappathsheader5 = {
                  type = "description",
                  name = "",
                  order = 30.2,
                  width = 0.20,
                  },
                MiniMapPathsScale = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapPaths end,
                  type = "range",
                  name = L["symbol size"],
                  desc = L["Changes the size of the icons"],
                  min = 0.5, max = 6, step = 0.1,
                  width = 1,
                  order = 30.3,
                  },
                minimappathsheader6 = {
                  type = "description",
                  name = "",
                  order = 30.4,
                  width = 0.20,
                  },
                MiniMapPathsAlpha = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapPaths end,
                  type = "range",
                  name = L["symbol visibility"],
                  desc = L["Changes the visibility of the icons"],
                  min = 0, max = 1, step = 0.1,
                  width = 1,
                  order = 30.5,
                  },
                minimappathsheader8 = {
                  type = "header",
                  name = "",
                  order = 30.7,
                  },
                showMiniMapPaths = {
                  disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or not ns.Addon.db.profile.activate.MiniMapPaths end,
                  type = "toggle",
                  name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
                  desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
                  width = 0.80,
                  order = 31,
                  set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                        if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL, L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                        if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL, L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
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
          name = CONTINENT .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Informations"],
          order = 30,
          },
        ContinentDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-clicking on a icon on this map opens the corresponding instance in the adventure guide or the map in which the portal, ship, zeppelin or special transport icon is located"],
          type = "description",
          order = 30.1,
          },   
        --Continenthdesc = {
        --  type = "description",
        --  name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Individual icons that are too close to other icons on this map are not 100% accurately placed on this map! For more precise coordinates, please use the points on the zone map"],
        --  order = 30.2,
        --},  
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
                if ns.Addon.db.profile.activate.Continent and (not ns.MapType2 and not ns.ContinentIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else 
                if not ns.Addon.db.profile.activate.Continent and (not ns.MapType2 and not ns.ContinentIDs or not WorldMapFrame:IsShown()) and self.faction == "Horde" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(12) else
                if ns.Addon.db.profile.activate.Continent and (not ns.MapType2 and not ns.ContinentIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(13) else 
                if not ns.Addon.db.profile.activate.Continent and (not ns.MapType2 and not ns.ContinentIDs or not WorldMapFrame:IsShown()) and self.faction == "Alliance" then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(13) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.Continent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.Continent then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end end end,
              },
        continentScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,  
          order = 30.7,
          },
        continentAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,
          order = 30.8,
        },
        continentheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 31.0,
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
          name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
          order = 32.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 32.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 32.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconOgreWaygate:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"],
          desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconOgreWaygate:GetIconString() .. " " .. L["Ogre Waygate"] .. " - " .. GARRISON_LOCATION_TOOLTIP .. "/" .. L["Draenor"] .. "\n" .. "\n" .. " " .. TextIconTravelL:GetIconString() .. " " .. TextIconDwarfF:GetIconString() .. " " .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
          order = 32.8,
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
          name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
          desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
          order = 33.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
          },
        showContinentPvPandPvEVendor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconPvPVendor:GetIconString() .. " " .. TextIconPvEVendor:GetIconString() .. " " .. TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE,
          desc = TRANSMOG_SET_PVP .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .."\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. POSTMASTER_LETTER_TANARIS .. "\n" .. " " ..  POSTMASTER_LETTER_AREA52 .. "\n" .. " " ..  DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " ..  L["Oribos"] .. "\n" .. "\n" .. FACTION_HORDE .. "\n" .. " " .. L["Kun-Lai Summit"] .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Warspear"] .. "\n" .. " " .. L["Zuldazar"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. L["Stormwind"] .. "\n" .. " " .. L["Valley of the Four Winds"] .. "\n" .. " " .. L["Stormshield"] .. "\n" .. " " .. L["Boralus, Tiragarde Sound"] .."\n" .. "\n" .. TRANSMOG_SET_PVE .. "\n" .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT .. " / " .. AUCTION_CREATOR .. " / " .. MERCHANT .. "\n" .. "\n" ..FACTION_HORDE .. "\n" .. " " .. ORGRIMMAR .. "\n" .. " " .. L["Undercity"] .. "\n" .. " " .. L["Shrine2Moons"] .. "\n" .. "\n" .. FACTION_NEUTRAL .. "\n" .. " " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. " " .. L["Icecrown"] .. "\n" .. " " .. L["Townlong Steppes"] .. "\n" .. " " .. L["Oribos"] .. "\n" .. "\n" .. FACTION_ALLIANCE .. "\n" .. " " .. STORMWIND .. "\n" .. " " .. L["Ironforge"] .. "\n" .. " " .. L["Shrine7Stars"],
          width = 0.80,
          order = 33.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentPvPandPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentPvPandPvEVendor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], TRANSMOG_SET_PVP .. " & " .. TRANSMOG_SET_PVE .. " " .. WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
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
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"],
          type = "description",
          order = 40.1,
          },   
        --Azerothhdesc = {
        --  type = "description",
        --  name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Individual icons that are too close to other icons on this map are not 100% accurately placed on this map! For more precise coordinates, please use the points on the zone map"],
        --  order = 40.2,
        --  },  
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
        azerothScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,  
          order = 40.7,
          },
        azerothAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,  
          order = 40.8,
          },
        Azerothheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 41
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
          name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. TextIconWayGateGreen:GetIconString().. " " .. TextIconDarkMoon:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"] .. "\n" .. "\n" .. TextIconPortal:GetIconString() .. " " .. L["Portal"].. " " ..L["icons"] .. "\n" .. TextIconHPortal:GetIconString() .. " " .. FACTION_HORDE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconAPortal:GetIconString() .. " " .. FACTION_ALLIANCE .. " " .. L["Portal"] .. " " .. L["icons"] .. "\n" .. TextIconWayGateGreen:GetIconString() .. " " .. L["Emerald Dream"] .. " " .. L["Portal"] .. "\n" .. TextIconDarkMoon:GetIconString() .. " " .. CALENDAR_FILTER_DARKMOON .. " " .. L["Portal"],
          order = 42.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 42.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zeppelins"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Azeroth map"], L["Zeppelins"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
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
          desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. L["Travel"] .. " - " .. L["Zandalar"] .. "/" .. L["Kul Tiras"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
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
          name = TextIconLFR:GetIconString() .. " " .. PLAYER_DIFFICULTY3,
          desc = L["Shows the locations of Raidbrowser applicants for old Raids"] .. "\n" .. "\n" .. EXPANSION_NAME3 .. " - " .. DUNGEON_FLOOR_TANARIS18 .. "\n" ..  "\n" .. EXPANSION_NAME4 .. " - " .. L["Vale of Eternal Blossoms"] .. "\n" .. "\n" .. EXPANSION_NAME5 .. " - " .. GARRISON_LOCATION_TOOLTIP .. "\n" .. "\n" .. EXPANSION_NAME2 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME6 .. " - " .. DUNGEON_FLOOR_DALARAN1 .. "\n" .. "\n" .. EXPANSION_NAME7 .. " - " .. L["Dazar'alor"] .. " / " .. L["Boralus"] .. "\n" .. "\n" .. EXPANSION_NAME8 .. " - " .. L["Oribos"],
          order = 43.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothLFR then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, PLAYER_DIFFICULTY3, "|cffff0000" ..  L["is deactivated"]) end end end,
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
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-clicking on a symbol on this map type opens the corresponding map in which the symbol is located"],
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
        showCosmosNorthrend = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconNorthrend:GetIconString() .. " " .. L["Northrend"],
          desc = L["Show all Northrend MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Northrend"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosNorthrend then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Northrend"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosPandaria = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconPandaria:GetIconString() .. " " .. L["Pandaria"],
          desc = L["Show all Pandaria MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Pandaria"], L["icons"],L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosPandaria then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Pandaria"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosBrokenIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconLegion:GetIconString() .. " " .. L["Broken Isles"],
          desc = L["Show all Broken Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Broken Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosBrokenIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Broken Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosZandalar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconZandalar:GetIconString() .. " " .. L["Zandalar"],
          desc = L["Show all Zandalar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Zandalar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosZandalar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Zandalar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosKulTiras = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconKT:GetIconString() .. " " .. L["Kul Tiras"],
          desc = L["Show all Kul Tiras MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kul Tiras"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosKulTiras then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Kul Tiras"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosShadowlands = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconSL:GetIconString() .. " " .. L["Shadowlands"],
          desc = L["Show all Shadowlands MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Shadowlands"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosShadowlands then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Shadowlands"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosDragonIsles = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconDF:GetIconString() .. " " .. L["Dragon Isles"],
          desc = L["Show all Dragon Isles MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Dragon Isles"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosDragonIsles then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Dragon Isles"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosKhazAlgar = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconKA:GetIconString() .. " " .. L["Khaz Algar"],
          desc = L["Show all Khaz Algar MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Khaz Algar"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosKhazAlgar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Khaz Algar"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosOutland = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconBC:GetIconString() .. " " .. L["Outland"],
          desc = L["Show all Outland MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Outland"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosOutland then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Outland"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showCosmosDraenor = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.CosmosMap end,
          type = "toggle",
          name = TextIconDraenor:GetIconString() .. " " .. L["Draenor"],
          desc = L["Show all Draenor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 54.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCosmosDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Draenor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCosmosDraenor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLDMAP_BUTTON, L["Draenor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
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
        DungeonMapheader = {
          type = "header",
          name = TRACKER_HEADER_DUNGEON .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Informations"],
          order = 60,
          },
        DungeonMapDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-click on one of these symbols on a map, the corresponding adventure guide or map of the destination will open"],
          type = "description",
          order = 60.1,
          },      
        DungeonMapheader1 = {
            type = "description",
            name = "",
            order = 60.2,
          },
        showDungeonMap = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Enables the display of all possible icons on this map"],
          order = 60.5,
          get = function() return ns.Addon.db.profile.activate.DungeonMap end,
          set = function(info, v) ns.Addon.db.profile.activate.DungeonMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.DungeonMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) else 
                if not ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.DungeonMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) else
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.DungeonMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.DungeonMap then OpenWorldMap(uiMapID) WorldMapFrame:SetMapID(190) print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Dungeon map"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end end end,
          },
        dungeonScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,  
          order = 60.6,
          },
        dungeonAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,  
          order = 60.7,
          },
        DungeonMapheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 61.0,
          },
        showDungeonExit = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconExit:GetIconString() .. " " .. L["Exits"],
          desc = L["Show icons of MapNotes dungeon exit on this map"],
          order = 62.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonExit then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Exits"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonExit then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Exits"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showDungeonPortal = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"],
          order = 62.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonPortal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonPortal then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },    
        showDungeonPassage = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. L["Passages"],
          desc = L["Show icons of passage on this map"],
          order = 62.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
          showDungeonTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.DungeonMap end,
          type = "toggle",
          name = TextIconTravelL:GetIconString() .. " " .. TextIconTransport:GetIconString() .. " " .. L["Transport"],
          desc = L["Shows special transport icons like"],
          order = 62.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showDungeonTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showDungeonTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Dungeon map"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        },
      },
    },
  }
end