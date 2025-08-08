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
  desc = "",
  get = function(info) return ns.Addon.db.profile[info[#info]] end,
  set = function(info, v) ns.Addon.db.profile[info[#info]] = v HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") end,
  args = {  
    GeneralTab = {
      type = "group",
      name = GENERAL,
      desc = L["General settings that apply to Azeroth / Continent / Dungeon map at the same time"],
      order = 0,
      args = { 
        General = {
          type = "header",
          name = L["General"],
          order = 0.2,
          },
        hideAddon = {
          type = "toggle",
          name = "|cffff0000" .. L["hide MapNotes!"],
          desc = L["Disable MapNotes, all icons will be hidden on each map and all categories will be disabled"],
          order = 0.5,
          width = 1.10,
          get = function() return ns.Addon.db.profile.activate.HideMapNote end,
          set = function(info, v) ns.Addon.db.profile.activate.HideMapNote = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.HideMapNote then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffff0000", L["All MapNotes icons have been hidden"]) else
                if not ns.Addon.db.profile.activate.HideMapNote then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cff00ff00", L["All set icons have been restored"]) end end end,
          },  
        hideMMB = {
          type = "toggle",
          name = "|cffff0000" .. L["hide minimap button"],
          desc = L["Hide the MapNotes button on the minimap"],
          order = 0.7,
          width = 1.25,
          get = function() return ns.Addon.db.profile.activate.HideMMB end,
          set = function(info, v) ns.Addon.db.profile.activate.HideMMB = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Show("MNMiniMapButton") print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> MiniMapButton <-"], "|cff00ff00" .. L["is activated"]) else
            if ns.Addon.db.profile.activate.HideMMB then MNMMBIcon:Hide("MNMiniMapButton") print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> MiniMapButton <-"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        hideWMB = {
          type = "toggle",
          name = "|cffff0000" .. L["hide worldmap button"],
          desc = L["Hide the MapNotes button on the worldmap"],
          order = 0.8,
          width = 1.20,
          get = function() return ns.Addon.db.profile.activate.HideWMB end,
          set = function(info, v) ns.Addon.db.profile.activate.HideWMB = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Show() LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cff00ff00" .. L["is activated"]) else
            if ns.Addon.db.profile.activate.HideWMB then ns.WorldMapButton:Hide() LibStub("Krowi_WorldMapButtons-1.4").SetPoints(); print(ns.COLORED_ADDON_NAME .. "|cffffff00", L["-> WorldMapButton <-"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        DescriptionHeaderRestore = {
          type = "header",
          name = L["Restore all deleted icons for different types of maps"],
          order = 1,
          },
        RestoreCapitalsDeletedIcons = {
          disabled = function() return ns.dbChar.CapitalsDeletedIcons == nil or ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Capitals"] .. " +",
          desc = "|cffffff00" .. L["Capitals"]  .. " - " .. MINIMAP_LABEL .."|r" .. "\n" .. "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.75,
          order = 1.1,
          func = function(info, v) ns.Addon.db.profile.RestoreCapitalsDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show ("Restore_Capitals?") end,
          }, 
        RestoreZoneDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Zones"] .. " +",
          desc = "|cffffff00" .. MINIMAP_LABEL .. "|r" .. "\n" .. "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.75,
          order = 1.2,
          func = function(info, v) ns.Addon.db.profile.RestoreZoneDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show ("Restore_Zone?") end,
          }, 
        RestoreContinentDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = L["Continents"],
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.75,
          order = 1.3,
          func = function(info, v) ns.Addon.db.profile.RestoreContinentDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show ("Restore_Continent?") end,
          }, 
        RestoreAzerothDeletedIcons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "execute",
          name = AZEROTH,
          desc = "\n" .. L["Restore all deleted icons"] .. " " .. L["which you removed with the function"] .. " " .. ALT_KEY .. " + " .. KEY_BUTTON1,
          width = 0.75,
          order = 1.4,
          func = function(info, v) ns.Addon.db.profile.RestoreAzerothDeletedIcons = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            StaticPopup_Show ("Restore_Azeroth?") end,
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
            Capitalstheader1 = {
              type = "header",
              name = ADVANCED_OPTIONS,
              order = 1.0,
              },
            RemoveBlizzPOIs = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = "POIs",
              desc = L["Points of interests"] .. "\n" .. "("  .. L["Portals"] .. ", " .. L["Ships"] .. ", " .. L["Capitals"] .. ")" .. "\n" .. "\n" .. L["Removes the Blizzard symbols only where MapNotes symbols and Blizzard symbols overlap, thereby making the tooltip and the function of the MapNote symbols usable again on the overlapping points"],
              order = 1.1,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.RemoveBlizzPOIs end,
              set = function(info, v) ns.Addon.db.profile.activate.RemoveBlizzPOIs = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cffff0000" .. L["are hidden"] ) else
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.activate.RemoveBlizzPOIs then print(ns.COLORED_ADDON_NAME, "|cffffff00" .. SLASH_TEXTTOSPEECH_BLIZZARD .. " " .. L["Points of interests"] .. " " .. L["icons"], "|cff00ccff" .. L["are shown"] ) end end end
              },
            showEnemyFaction = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["enemy faction"],
              desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
              order = 1.3,
              width = 1.20,
              get = function() return ns.Addon.db.profile.activate.EnemyFaction end,
              set = function(info, v) ns.Addon.db.profile.activate.EnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.EnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["enemy faction"], "|cff00ff00" .. L["is activated"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.EnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
             },
            WayPoints = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconTomTom:GetIconString() .. " " .. L["Waypoints"],
              desc = L["Shift + Right Click on a MapNotes icon adds a waypoint to it"],
              order = 1.4,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.WayPoints then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Waypoints"], "|cff00ff00" .. L["is activated"]) else 
                    if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.WayPoints then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Waypoints"], "|cffff0000" ..  L["is deactivated"]) end end end,
              },
            DeleteIcons = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TextIconExit:GetIconString() .. " " .. CALENDAR_DELETE_EVENT,
              desc = L["With Alt + right click it is now possible to remove any MapNotes icon"] .. "\n" .. "\n" .. L["If 'Tooltip' is activated, an additional tooltip will be added to the icons, indicating how icons can be deleted"],
              order = 1.5,
              width = 1.20,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.DeleteIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CALENDAR_DELETE_EVENT, "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.DeleteIcons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CALENDAR_DELETE_EVENT, "|cffff0000" ..  L["is deactivated"]) end end end,
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
            ClassicIconsheader = {
              type = "header",
              name = L["Old icon style"] .. " - " .. LFG_LIST_LEGACY .. " / " .. NEW,
              order = 4.0,
              },
            ClassicPortals = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Portals"] .. " " .. TextIconPortalOld:GetIconString() .. "" .. TextIconHPortalOld:GetIconString() .. "" .. TextIconAPortalOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Portals"] .. " - " .. LFG_LIST_LEGACY .. "\n" .. TextIconPortalOld:GetIconString() .. " " .. TextIconHPortalOld:GetIconString() .. " " .. TextIconAPortalOld:GetIconString() .. "\n" .. TextIconPassagePortalOld:GetIconString() .. " " .. TextIconPassageHPortalOld:GetIconString() .. " " .. TextIconPassageAPortalOld:GetIconString() .. "\n" .. "\n" .. L["Portals"] .. " - " .. NEW .. "\n" .. TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. "\n" .. TextIconPassagePortal:GetIconString() .. " " .. TextIconPassageHPortal:GetIconString() .. " " .. TextIconPassageAPortal:GetIconString(),
              width = 0.85,
              order = 4.2,
              get = function() return ns.Addon.db.profile.activate.ClassicPortals end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicPortals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.activate.ClassicPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Portals"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicShips = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Ships"] .. " " .. TextIconShipOld:GetIconString() .. "" .. TextIconHShipOld:GetIconString() .. "" .. TextIconAShipOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Ships"] .. " - " .. LFG_LIST_LEGACY .. "\n" .. TextIconShipOld:GetIconString() .. " " .. TextIconHShipOld:GetIconString() .. " " .. TextIconAShipOld:GetIconString() .. "\n" .. "\n" .. L["Ships"] .. " - " .. NEW .. "\n" .. TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString(),
              width = 0.85,
              order = 4.3,
              get = function() return ns.Addon.db.profile.activate.ClassicShips end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicShips = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.activate.ClassicShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Ships"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicZeppelin = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["Zeppelins"] .. " " .. TextIconZeppelinOld:GetIconString() .. "" .. TextIconHZeppelinOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. L["Zeppelins"] .. " - " .. LFG_LIST_LEGACY .. "\n" .. TextIconZeppelinOld:GetIconString() .. " " .. TextIconHZeppelinOld:GetIconString() .. "\n" .. "\n" .. L["Zeppelins"] .. " - " .. NEW .. "\n" .. TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString(),
              width = 0.85,
              order = 4.4,
              get = function() return ns.Addon.db.profile.activate.ClassicZeppelin end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicZeppelin = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.activate.ClassicZeppelin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], L["Zeppelins"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicBank = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = BANK .. " " .. TextIconBankOld:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. BANK .. " " .. LFG_LIST_LEGACY .. "\n" .. TextIconBankOld:GetIconString() .. "\n" .. "\n" .. BANK .. " " .. NEW .. "\n" .. TextIconBank:GetIconString(),
              width = 0.85,
              order = 4.5,
              get = function() return ns.Addon.db.profile.activate.ClassicBank end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicBank = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.activate.ClassicBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], BANK, "|cff00ff00" .. L["is activated"]) end end end,
              },
            ClassicClassicProfession = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = TRADE_SKILLS .. " " ..  TextIconProfessionOrders:GetIconString(),
              desc = L["Changes the appearance of the icons. When activated, the listed icons will be changed with the previous style of these icons"] .. "\n" .. "\n" .. TRADE_SKILLS .. " " .. LFG_LIST_LEGACY .. "\n" .. TextIconClassicOriginalAlchemy:GetIconString() .. " " .. TextIconClassicOriginalBlacksmith:GetIconString() .. " " .. TextIconClassicOriginalEngineer:GetIconString() .. " " .. TextIconClassicOriginalSkinning:GetIconString() .. " " .. TextIconClassicOriginalTailoring:GetIconString() .. " " .. TextIconClassicOriginalJewelcrafting:GetIconString() .. " " .. TextIconClassicOriginalLeatherworking:GetIconString() .. " " .. TextIconClassicOriginalHerbalism:GetIconString() .. " " .. TextIconClassicOriginalMining:GetIconString() .. " " .. TextIconClassicOriginalEnchanting:GetIconString() .. " " .. TextIconClassicOriginalInscription:GetIconString() .. " " .. TextIconClassicOriginalArchaeology:GetIconString() .. " " .. TextIconClassicOriginalCooking:GetIconString() .. " " .. TextIconClassicOriginalFishing:GetIconString() .. " " ..  "\n" .. "\n" .. TRADE_SKILLS .. " " .. NEW .. "\n" .. TextIconAlchemy:GetIconString() .. " " .. TextIconBlacksmith:GetIconString() .. " " .. TextIconEngineer:GetIconString() .. " " .. TextIconSkinning:GetIconString() .. " " .. TextIconTailoring:GetIconString() .. " " .. TextIconJewelcrafting:GetIconString() .. " " .. TextIconLeatherworking:GetIconString() .. " " .. TextIconHerbalism:GetIconString() .. " " .. TextIconMining:GetIconString() .. " " .. TextIconEnchanting:GetIconString() .. " " .. TextIconInscription:GetIconString() .. " " .. TextIconArchaeology:GetIconString() .. " " .. TextIconCooking:GetIconString() .. " " .. TextIconFishing:GetIconString(),
              width = 0.85,
              order = 4.6,
              get = function() return ns.Addon.db.profile.activate.ClassicClassicProfession end,
              set = function(info, v) ns.Addon.db.profile.activate.ClassicClassicProfession = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if not ns.Addon.db.profile.activate.ClassicClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.activate.ClassicClassicProfession then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Old icon style"], TRADE_SKILLS, "|cff00ff00" .. L["is activated"]) end end end,
              },
            },
          },
        ChatMessageTab = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "group",
          name = L["chat message"],
          desc = "",
          order = 3,
          args = {
            Chatheader1 = {
              type = "header",
              name = L["chat message"],
              order = 1.0,
              },
            CreateAndCopyLinks = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK,
              desc = L["Enables you to copy links and email addresses from the chat"] .. "\n" .. "\n" .. L["Links are only generated after the feature is activated. Links or email addresses created before activation will not be recognized retroactively"] .. "\n" .. "\n" .. L["If the link or email address is colored blue in the chat, the link is ready to be copied"] .. "\n" .. "\n" .. L["Clicking a link in the chat opens a separate window"] .. "\n" .. "\n" .. L["Use CTRL + C to copy the link"] .. "\n" .. "\n" .. L["The window closes automatically after copying"] .."\n" .. "\n" .. "By activating this function, similar functions of other addons are suppressed so that multiple windows are not created",
              order = 1.1,
              width = 0.50,
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
              desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n" .. "\n" .. "• " .. GENERAL .. "\n" .. "• " .. L["Profiles"] .. "\n" .. "\n" .. "|cffff0000" .. L["An exception is the feedback in the chat from the function for deleting or restoring icons. These are always displayed!"],
              order = 2.1,
              width = 0.80,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.CoreChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. CORE_ABILITIES, L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            ChatMassage = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = L["chat message"],
              desc = L["Here you can enable or disable all chat messages sent from one of these MapNotes tabs when you change the settings"] .. "\n" .."\n" .. L["This applies to the following tabs"] .. "\n" .. "\n" .. "• " .. L["Capitals"] .. " + " .. "\n" .. "• " .. L["Zones"] .. " + " .. "\n" .. "• " .. L["Continents"] .. "\n" .. "• " .. AZEROTH .. "\n" .. "• " .. WORLDMAP_BUTTON .. "\n" .. "• " .. L["Dungeons"],
              order = 2.2,
              width = 0.60,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["chat message"], L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ChatMassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["chat message"], L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            MmbWmbChatMessage = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "toggle",
              name = "MMB/WMB",
              desc = "• " .. L["-> MiniMapButton <-"] .. "\n" .. "• " .. L["-> WorldMapButton <-"] .. "\n" .. "\n" .. L["Here you can enable or disable all chat messages sent by MapNotes Minimap and Worldmap buttons when you hide or show icons over them"],
              order = 2.3,
              width = 0.85,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.MmbWmbChatMessage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["-> MiniMapButton <-"] .. " / " .. L["-> WorldMapButton <-"], L["chat message"], "|cffff0000" .. L["is deactivated"] ) end end end,
              }, 
            ZoneChanged = {
              type = "toggle",
              name = L["Location"],
              desc = L["When entering a new zone, the name of the new zone will be displayed in the chat"],
              order = 2.4,
              width = 0.55,
              get = function() return ns.Addon.db.profile.ZoneChanged end,
              set = function(info, v) ns.Addon.db.profile.ZoneChanged = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"],  "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChanged then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], "|cff00ff00" .. L["is activated"]) end end end,
              },
            ZoneChangedDetail = {
              disabled = function() return not ns.Addon.db.profile.ZoneChanged end,
              type = "toggle",
              name = L["Location"] ..  " " .. LFG_LIST_DETAILS,
              desc = L["In addition to the zone names, it also displays the names of specific locations within a zone. Disabling the Show Zone Names feature will also disable this feature"] .. "\n" .. "\n" .. L["Capital cities are excluded from this because there would be too much chat spam"],
              order = 2.5,
              width = 0.85,
              get = function() return ns.Addon.db.profile.ZoneChangedDetail end,
              set = function(info, v) ns.Addon.db.profile.ZoneChangedDetail = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cffff0000" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.ZoneChangedDetail then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Show Zone Names"], L["Location"], LFG_LIST_DETAILS, "|cff00ff00" .. L["is activated"]) end end end,
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
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.displayCoords.showPlayerCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", PLAYER .. " " .. L["Coordinates"], "|cff00ff00" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.displayCoords.showPlayerCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", PLAYER .. " " .. L["Coordinates"], "|cffff0000" .. L["is activated"]) end end end,
              },
            PlayerCoordsSize = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = L["symbol size"],
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
              desc = HUD_EDIT_MODE_RESET_POSITION,
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
              desc = L["Creates a window for displaying the coordinates"] .. "\n" .. "\n" .. L["Only visible when the world map is open"],
              order = 1.6,
              width = 0.50,
              get = function() return ns.Addon.db.profile.displayCoords.showMouseCoords end,
              set = function(info, v) ns.Addon.db.profile.displayCoords.showMouseCoords = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.displayCoords.showMouseCoords then ns.CreateMouseCoordsFrame() end
                if not ns.Addon.db.profile.displayCoords.showMouseCoords then ns.HideMouseCoordsFrame() end
                if ns.Addon.db.profile.CoreChatMassage and not ns.Addon.db.profile.displayCoords.showMouseCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", MOUSE_LABEL .. " " .. L["Coordinates"], "|cff00ff00" .. L["is deactivated"]) else
                if ns.Addon.db.profile.CoreChatMassage and ns.Addon.db.profile.displayCoords.showMouseCoords then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", MOUSE_LABEL .. " " .. L["Coordinates"], "|cffff0000" .. L["is activated"]) end end end,
              },
            MouseCoordsSize = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
              type = "range",
              name = L["symbol size"],
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
              desc = HUD_EDIT_MODE_RESET_POSITION,
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
              desc = L["Displays the player arrow on the minimap layered above addon-created icons"] .. "\n" .. "\n" .. "|cFFFF0000" .. L["Unfortunately does not work in instances"],
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
              name = L["symbol size"],
              desc = "",
              min = 1.3, max = 3, step = 0.1,
              width = 1,
              order = 1.7,
              set = function(info, v) ns.Addon.db.profile.MinimapArrowScale = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                  local baseSize = 20
                  local size = baseSize * v
                if MMPA and MMPA.texture then MMPA:SetSize(size, size) MMPA.texture:SetSize(size, size) end end
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
              desc = L["The MapNotes player arrow disappears from the minimap for the set number of seconds when you hover over it"] .. "\n" .. "\n" .. L["This makes it easier for the player to see which other icon is currently under the player"],
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
              width = 1,
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
              name = L["Area Map"] .. " " .. SLASH_TEXTTOSPEECH_MENU,
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
            SupportTextheader = {
              type = "header",
              name = "Support",
              width = 1,
              order = 9.0,
              },
            SupportText = {
              type = "description",
              name = "|cffffd700" .. L["If you like this addon, feel free to support me via Paypal, Patreon or Ko-fi"] .. "\n" .. "\n" .. L["You can find the relevant links on:"] .. "\n" .. "\n" .. "https://www.curseforge.com/wow/addons/mapnotes" .. "\n" .. "https://www.curseforge.com/members/badboybarny".. "\n" .. "https://addons.wago.io/addons/mapnotes" .. "\n" .. "https://addons.wago.io/user/BadBoyBarny" .. "\n" .. "\n" .. L["Any support is greatly appreciated"] .. "\n" .. "\n" .. "            " .. L["Best regards"] .. "\n" .. "\n" .. "                        " .. "BadBoyBarny",
              order = 9.1,
              },
            },
          },
        },
      },
    MiniMapTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = MINIMAP_LABEL,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 1,
      args = {
        MiniMapheader = {
          type = "header",
          name = MINIMAP_LABEL .. " " .. L["Informations"],
          order = 10,
          },
        MiniMapDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Some instance icons cannot be hidden because they were created by Blizzard itself and not by MapNotes"],
          type = "description",
          order = 10.1,
          },      
        MiniMaptheader1 = {
          type = "header",
          name = "",
          order = 10.2,
          },
        showMiniMapMap = {
          disabled = function() return ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          width = 1,
          order = 10.3,
          get = function() return ns.Addon.db.profile.activate.MiniMap end,
          set = function(info, v) ns.Addon.db.profile.activate.MiniMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.MiniMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.MiniMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL, "|cffff0000" .. L["is deactivated"]) end end end,
          },
        SyncZoneAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Zones tab with the Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Minimap tab and is now controlled together by the Zones tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Minimap settings and replace them with those from Zones tab"],
          width = 2.5,
          order = 10.4,
          get = function() return ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncZoneAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " ..  MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        minimapScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,
          order = 10.8,
          },
        minimapAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,
          order = 10.9,
          },
        MiniMapheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 11.0,
          },
        showMiniMapRaids = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 12.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Raids"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapDungeons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 12.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Dungeons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapMultiple = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple (dungeons,raids) on this map"],
          order = 12.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Multiple"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 12.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Zeppelins"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 12.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Ships"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconTransport:GetIconString() .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"],
          desc = "",
          order = 12.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapFP = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
          desc = "",
          order = 12.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapGhost = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconGhost:GetIconString() .. " " .. SPIRIT_HEALER_RELEASE_RED,
          desc = "",
          order = 13.0,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapPaths = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
          desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
          width = 0.80,
          order = 13.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapPaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        MiniMapheader4 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 14.1,
          },
        showMiniMapKalimdor= {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 14.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showMiniMapEasternKingdom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MiniMap or ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 14.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMiniMapEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMiniMapEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        },
      },
    AzerothTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = WORLD_MAP,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 3,
      args = {
        Azerothheader = {
          type = "header",
          name = WORLD_MAP .. " " .. L["Informations"],
          order = 30,
          },
        AzerothDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-clicking on a icon on this map opens the corresponding instance in the adventure guide or the map in which the portal, ship, zeppelin or special transport icon is located"],
          type = "description",
          order = 30.1,
          },   
        Azerothheader1 = {
          type = "header",
          name = "",
          order = 30.5,
          },
        showAzeroth = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          order = 30.6,
          get = function() return ns.Addon.db.profile.activate.Azeroth end,
          set = function(info, v) ns.Addon.db.profile.activate.Azeroth = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.activate.Azeroth then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. WORLD_MAP, "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.Azeroth then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. WORLD_MAP, "|cffff0000" .. L["is deactivated"]) end end end,
          },
        azerothScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 1.25,  
          order = 30.7,
          },
        azerothAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 1.25,  
          order = 30.8,
          },
        Azerothheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 31
          },
        showAzerothRaids = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 32.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Raids"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Raids"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothDungeons = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 32.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
            if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Dungeons"], "|cff00ff00" .. L["are shown"]) else 
            if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Dungeons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothMultiple = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple on this map"],
          order = 32.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Multiple"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.howAzerothMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Multiple"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothZeppelins = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 32.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Zeppelins"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Zeppelins"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothShips = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 32.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Ships"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Ships"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothTransport = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconCarriage:GetIconString() .. " " .. L["Transport"],
          desc = "",
          order = 32.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothFP = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
          desc = "",
          order = 32.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        Azerothheader3 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 34
          },
        showAzerothKalimdor = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 34.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showAzerothEasternKingdom = {
          disabled = function() return not ns.Addon.db.profile.activate.Azeroth end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 34.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showAzerothEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showAzerothEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. WORLD_MAP, L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        }
      },
    ContinentTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Continent map"],
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 4,
      args = {
        continentheader = {
          type = "header",
          name = CONTINENT .. "-" .. BRAWL_TOOLTIP_MAPS .. " " .. L["Informations"],
          order = 40,
          },
        ContinentDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-clicking on a icon on this map opens the corresponding instance in the adventure guide or the map in which the portal, ship, zeppelin or special transport icon is located"],
          type = "description",
          order = 40.1,
          },   
        continentheader1 = {
          type = "header",
          name = "",
          order = 40.5,
          },
        showContinent = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          order = 40.6,
          get = function() return ns.Addon.db.profile.activate.Continent end,
          set = function(info, v) ns.Addon.db.profile.activate.Continent = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.Continent and not WorldMapFrame:IsShown() then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.Continent and not WorldMapFrame:IsShown() then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Continent map"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        continentScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "range",
          name = L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.80,  
          order = 40.7,
          },
        continentAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "range",
          name = L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.80,
          order = 40.8,
        },
        continentheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 41.0,
          },
        showContinentRaids = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 42.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Raids"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Raids"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentDungeons = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 42.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dungeons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Dungeons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentMultiple = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple (dungeons,raids) on this map"],
          order = 42.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Multiple"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Multiple"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentZeppelins = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 42.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Zeppelins"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentShips = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 42.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Ships"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentTransport = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconCarriage:GetIconString() .. " " .. L["Transport"],
          desc = "",
          order = 42.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentFP = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
          desc = "",
          order = 42.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        continentheader4 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 43.1
          },
        showContinentKalimdor= {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 43.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showContinentEasternKingdom = {
          disabled = function() return not ns.Addon.db.profile.activate.Continent end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 43.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showContinentEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showContinentEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Continent map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        },
      },
    ZoneTab = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Zone map"],
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"],
      order = 5,
      args = {
        zoneheader = {
          type = "header",
          name = L["Zone map"] .. " " .. L["Informations"],
          order = 50,
          },
        ZoneDescriptionText = {
          name = "|cffff0000" .. "======> " .. "|cffffff00" .. L["Left-click on one of these symbols on a map, the corresponding adventure guide or map of the destination will open"],
          type = "description",
          order = 50.1,
          },
        zonetheader1 = {
            type = "header",
            name = "",
            order = 50.3,
          },
        showZoneMap = {
          type = "toggle",
          name = L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"],
          width = 0.90,
          order = 50.4,
          get = function() return ns.Addon.db.profile.activate.ZoneMap end,
          set = function(info, v) ns.Addon.db.profile.activate.ZoneMap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.ZoneMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.ZoneMap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Zone map"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        SyncZoneAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Zones tab with the Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Minimap tab and is now controlled together by the Zones tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Minimap settings and replace them with those from Zones tab"],
          width = 2.5,
          order = 50.5,
          get = function() return ns.Addon.db.profile.activate.SyncZoneAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncZoneAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " ..  MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncZoneAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Zones"] .. " & " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        zoneScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "range",
          name = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE .. " " .. L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.90,  
          order = 50.6,
          },
        zoneAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "range",
          name = COMMUNITIES_ROSTER_COLUMN_TITLE_ZONE .. " " .. L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.90,  
          order = 50.7,
          },
        instanceScale = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "range",
          name = BATTLEGROUND_INSTANCE .. " " .. L["symbol size"],
          desc = L["Changes the size of the icons"],
          min = 0.5, max = 6, step = 0.1,
          width = 0.90,  
          order = 50.8,
          },
        instanceAlpha = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "range",
          name = BATTLEGROUND_INSTANCE .. " " .. L["symbol visibility"],
          desc = L["Changes the visibility of the icons"],
          min = 0, max = 1, step = 0.1,
          width = 0.90,  
          order = 50.9,
          },
        zoneheader2 = {
          type = "header",
          name = L["Show individual icons"],
          order = 51.0,
          },
        showZoneRaids = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconRaid:GetIconString() .. " " .. L["Raids"],
          desc = L["Show icons of raids on this map"],
          order = 52.1,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneRaids then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Raids"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneDungeons = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
          desc = L["Show icons of dungeons on this map"],
          order = 52.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Dungeons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneMultiple = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconMultipleM:GetIconString() .. " " .. TextIconMultipleR:GetIconString() .. " " .. TextIconMultipleD:GetIconString() .. " " .. L["Multiple"],
          desc = L["Show icons of multiple (dungeons,raids) on this map"],
          order = 52.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneMultiple then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Multiple"], "|cffff0000" .. L["are hidden"])end end end,
          },
         showZonePortals = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. L["Portals"],
          desc = L["Show icons of portals on this map"],
          order = 52.4,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Portals"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneZeppelins = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconZeppelin:GetIconString() .. " " .. TextIconHZeppelin:GetIconString() .. " " .. L["Zeppelins"],
          desc = L["Show icons of zeppelins on this map"],
          order = 52.5,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneZeppelins then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Zeppelins"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneShips = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconShip:GetIconString() .. " " .. TextIconHShip:GetIconString() .. " " .. TextIconAShip:GetIconString() .. " " .. L["Ships"],
          desc = L["Show icons of ships on this map"],
          order = 52.6,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneShips then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Ships"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneTransport = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconTransport:GetIconString() .. " " .. TextIconCarriage:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. L["Transport"],
          desc = "",
          order = 52.7,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneFP = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
          desc = "",
          order = 52.8,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneGhost = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconGhost:GetIconString() .. " " .. SPIRIT_HEALER_RELEASE_RED,
          desc = "",
          order = 52.9,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Transport"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZonePaths = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconPathO:GetIconString() .. " " .. TextIconPathR:GetIconString() .. " " .. TextIconPathU:GetIconString() .. " " .. TextIconPathL:GetIconString() .. " " .. L["Paths"],
          desc = L["Exit"] ..  " / " .. L["Entrance"] .. " / " .. L["Path"],
          width = 0.80,
          order = 53,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZonePaths then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Zone map"], L["Paths"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        zoneheader4 = {
          type = "header",
          name = L["Show all MapNotes for a specific map"],
          order = 53.1,
          },
        showZoneKalimdor= {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconKalimdor:GetIconString() .. " " .. L["Kalimdor"],
          desc = L["Show all Kalimdor MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.2,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kalimdor"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneKalimdor then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Kalimdor"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },
        showZoneEasternKingdom = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.ZoneMap end,
          type = "toggle",
          name = TextIconEK:GetIconString() .. " " .. L["Eastern Kingdom"],
          desc = L["Show all Eastern Kingdom MapNotes dungeon, raid, portal, zeppelin and ship icons on this map"],
          order = 53.3,
          set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showZoneEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Eastern Kingdom"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showZoneEasternKingdom then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Zone map"], L["Eastern Kingdom"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
          },  
        },
      },
    Capitals = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Capitals"],
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. L["Stormwind"] .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1,
      order = 7,
      args = {
        Capitalstheader1 = {
          type = "header",
          name = L["Capitals"] .. " " .. L["icons"],
          order = 70,
          },
        SyncCapitalsAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Capitals tab with the Capitals - Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Capitals - Minimap tab and is now controlled together by the Capitals tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Capitals - Minimap settings and replace them with those from Capitals tab"],
          width = 2.5,
          order = 70.1,
          get = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncCapitalsAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        showCapitals = {
          type = "toggle",
          name = L["Capitals"] .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. L["Stormwind"] .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND,
          width = 1.8,
          order = 70.2,
          get = function() return ns.Addon.db.profile.activate.Capitals end,
          set = function(info, v) ns.Addon.db.profile.activate.Capitals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.Capitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.Capitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        CapitalEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
          type = "toggle",
          name = L["Capitals"] .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 70.3,
          width = 1.8,
          get = function() return ns.Addon.db.profile.activate.CapitalsEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.CapitalsEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.CapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.CapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
         },
        CapitalsTab = {
          type = "group",
          name = "• " .. L["Capitals"],
          desc = L["Enables the display of icons for a specific capital city"],
          order = 70.4,
          args = {
            Capitalsheader6 = {
              type = "header",
              name = FACTION_HORDE,
              order = 70.5,
              },
            showCapitalsOrgrimmar = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote and not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = TextIconOrgrimmar:GetIconString() .. " " .. DUNGEON_FLOOR_ORGRIMMAR0,
              desc = "",
              width = 0.80,
              order = 70.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_ORGRIMMAR0, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], DUNGEON_FLOOR_ORGRIMMAR0, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsThunderBluff = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = TextIconThunderBluff:GetIconString() .. " " .. L["Thunder Bluff"],
              desc = "",
              width = 0.80,
              order = 70.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsUndercity = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = TextIconUndercity:GetIconString() .. " " .. L["Undercity"],
              desc = "",
              width = 0.80,
              order = 70.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Undercity"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Undercity"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            Capitalsheader7 = {
              type = "header",
              name = FACTION_ALLIANCE,
              order = 72,
              },
            showCapitalsStormwind = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = TextIconStormwind:GetIconString() .. " " .. L["Stormwind"],
              desc = "",
              width = 0.80,
              order = 72.1,
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
              order = 72.2,
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
              order = 72.3,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Darnassus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  L["Capitals"], L["Darnassus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        InstanceTab = {
          type = "group",
          name = "• " .. BATTLEGROUND_INSTANCE .. " " .. L["icons"],
          desc = "",
          order = 72,
          args = {
            CapitalsInstances = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Activates the display of all possible icons on this map"],
              width = 0.90,
              order = 72.1,
              get = function() return ns.Addon.db.profile.activate.CapitalsInstances end,
              set = function(info, v) ns.Addon.db.profile.activate.CapitalsInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.CapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. BATTLEGROUND_INSTANCE .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.CapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. BATTLEGROUND_INSTANCE .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            CapitalsInstanceScale = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80,  
              order = 72.3,
              },
            CapitalsInstanceAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80,
              order = 72.4,
              },
            Capitalsheader2 = {
              type = "description",
              name = "",
              order = 73.0,
              },
            showCapitalsInstancePassage = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
              type = "toggle",
              name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
              desc = L["Show icons of passage to raids and dungeons on this map"],
              order = 73.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsInstancePassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
              showCapitalsDungeons = {
                disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsInstances end,
              type = "toggle",
              name = TextIconDungeon:GetIconString() .. " " .. L["Dungeons"],
              desc = L["Show icons of dungeons on this map"],
              order = 73.5,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dungeons"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsDungeons then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Dungeons"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        Transportab = {
          type = "group",
          name = "• " .. L["Transport"] .. " " .. L["icons"],
          desc = "",
          order = 74,
          args = {
            CapitalsTransporting = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 74.1,
              get = function() return ns.Addon.db.profile.activate.CapitalsTransporting end,
              set = function(info, v) ns.Addon.db.profile.activate.CapitalsTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.CapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " ..  L["Transport"] .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.CapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " ..  L["Transport"] .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            CapitalsTransportScale = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80,  
              order = 74.1,
              },
            CapitalsTransportAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80,
              order = 74.2,
              },
            Capitalsheader3 = {
              type = "description",
              name = "",
              order = 74.5,
              },
            showCapitalsPortals = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
              type = "toggle",
              name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. L["Portals"],
              desc = L["Show icons of portals on this map"],
              order = 74.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsTransport = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
              type = "toggle",
              name = TextIconCarriage:GetIconString() .. " " .. L["Transport"],
              desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
              order = 74.9,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsFP = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsTransporting end,
              type = "toggle",
              name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
              desc = "",
              order = 75,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        ProfessionTab = {
          type = "group",
          name = "• " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. L["icons"],
          desc = "",
          order = 76,
          args = {
            CapitalsProfessions = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 76.1,
              get = function() return ns.Addon.db.profile.activate.CapitalsProfessions end,
              set = function(info, v) ns.Addon.db.profile.activate.CapitalsProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.CapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.CapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            CapitalsProfessionsScale = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80, 
              order = 76.2,
              },
            CapitalsProfessionsAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80, 
              order = 76.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 76.4,
              },
            showCapitalsProfessionDetection = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions end,
              type = "toggle",
              name = L["Profession detection"],
              desc = L["Automatically detects your professions and activates the corresponding professions icons on this map"],
              width = 1.2, 
              order = 76.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    ns.AutomaticProfessionDetection()
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsProfessionDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Profession detection"], GUILD_ROSTER_DROPDOWN_PROFESSION, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            Capitalsheader5 = {
              type = "description",
              name = "",
              order = 76.9,
              },
            showCapitalsAlchemy = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
              desc = "",
              width = 1.2, 
              order = 77,
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
              order = 77.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsBlacksmith = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
              desc = "",
              width = 1.2, 
              order = 77.4,
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
              order = 77.5,
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
              order = 77.6,
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
              order = 77.7,
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
              order = 77.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsFishing = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
              desc = "",
              width = 1.2, 
              order = 78,
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
              order = 78.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsEnchanting = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
              desc = "",
              width = 1.2, 
              order = 78.3,
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
              order = 78.4,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsFirstAid = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsProfessions or ns.Addon.db.profile.showCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconFirstAid:GetIconString() .. " " .. PROFESSIONS_FIRST_AID,
              desc = "",
              width = 1.2, 
              order = 78.5,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsFirstAid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_FIRST_AID, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsFirstAid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. TUTORIAL_TITLE38, PROFESSIONS_FIRST_AID, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        GeneralCapitalTab = {
          type = "group",
          name = "• " .. L["General"] .. " " .. L["icons"],
          desc = "",
          order = 79,
          args = {
            CapitalsGeneral = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Activates the display of all possible icons on this map"],
              width = 0.90,
              order = 79.1,
              get = function() return ns.Addon.db.profile.activate.CapitalsGeneral end,
              set = function(info, v) ns.Addon.db.profile.activate.CapitalsGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.CapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["General"] .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.CapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["General"] .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            CapitalsGeneralScale = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80, 
              order = 79.2,
              },
            CapitalsGeneralAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80, 
              order = 79.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 79.4,
              },
            showCapitalsMapNotes = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "toggle",
              name = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME,
              desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n" .. "\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"],
              width = 0.80,
              order = 79.5,
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
              order = 79.6,
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
              order = 79.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsAuctioneer = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "toggle",
              name = TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
              desc = "",
              width = 0.80,
              order = 79.8,
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
              order = 79.9,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsMailbox = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "toggle",
              name = TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
              desc = "",
              width = 0.80,
              order = 80.0,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsGhost = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "toggle",
              name = TextIconGhost:GetIconString() .. " " .. SPIRIT_HEALER_RELEASE_RED,
              desc = "",
              width = 0.80,
              order = 80.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], SPIRIT_HEALER_RELEASE_RED, "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], SPIRIT_HEALER_RELEASE_RED, "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsWeaponMasters = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsGeneral end,
              type = "toggle",
              name = TextIconPvPVendor:GetIconString() .. " " .. L["Weapon Master"],
              desc = "",
              width = 0.80,
              order = 80.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsWeaponMasters then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Weapon Master"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsWeaponMasters then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Weapon Master"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        ClassesTrainerTab = {
          type = "group",
          name = "• " .. MINIMAP_TRACKING_TRAINER_CLASS .. " " .. L["icons"],
          desc = "",
          order = 90,
          args = {
            CapitalsClasses = {
              disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.Capitals end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 90.1,
              get = function() return ns.Addon.db.profile.activate.CapitalsClasses end,
              set = function(info, v) ns.Addon.db.profile.activate.CapitalsClasses = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.CapitalsClasses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. TALENT_TRAINER .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.CapitalsClasses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Capitals"] .. " " .. TALENT_TRAINER .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            CapitalsClassesScale = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80, 
              order = 90.2,
              },
            CapitalsClassesAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80, 
              order = 90.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 90.4,
              },
            showCapitalsClassDetection = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses end,
              type = "toggle",
              name = L["Class detection"],
              desc = L["Automatically detects your class and activates the corresponding class trainer icons on this map"],
              width = 1.2, 
              order = 90.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    ns.AutomaticClassDetectionCapital()
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Class detection"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Class detection"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            Capitalsheader5 = {
              type = "description",
              name = "",
              order = 90.9,
              },
            showCapitalsClassDruid = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassDruid:GetIconString() .. " " .. L["Druid"],
              desc = "",
              width = 1.2, 
              order = 91,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassDruid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Druid"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassDruid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Druid"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassHunter = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassHunter:GetIconString() .. " " .. L["Hunter"],
              desc = "",
              width = 1.2, 
              order = 91.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassHunter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Hunter"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassHunter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Hunter"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassMage = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassMage:GetIconString() .. " " .. L["Mage"],
              desc = "",
              width = 1.2, 
              order = 91.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassMage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Mage"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassMage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Mage"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassPaladin = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassPaladin:GetIconString() .. " " .. L["Paladin"],
              desc = "",
              width = 1.2, 
              order = 91.3,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassPaladin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Paladin"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassPaladin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Paladin"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassPriest = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassPriest:GetIconString() .. " " .. L["Priest"],
              desc = "",
              width = 1.2, 
              order = 91.4,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassPriest then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Priest"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassPriest then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Priest"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassRogue = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassRogue:GetIconString() .. " " .. L["Rogue"],
              desc = "",
              width = 1.2, 
              order = 91.5,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassRogue then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Rogue"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassRogue then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Rogue"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassShaman = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassShaman:GetIconString() .. " " .. L["Shaman"],
              desc = "",
              width = 1.2, 
              order = 91.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassShaman then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shaman"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassShaman then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Shaman"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassWarlock = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassWarlock:GetIconString() .. " " .. L["Warlock"],
              desc = "",
              width = 1.2, 
              order = 91.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassWarlock then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warlock"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassWarlock then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warlock"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showCapitalsClassWarrior = {
              disabled = function() return not ns.Addon.db.profile.activate.Capitals or not ns.Addon.db.profile.activate.CapitalsClasses or ns.Addon.db.profile.showCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassWarrior:GetIconString() .. " " .. L["Warrior"],
              desc = "",
              width = 1.2, 
              order = 91.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showCapitalsClassWarrior then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warrior"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showCapitalsClassWarrior then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Warrior"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        },
      },
    MinimapCapitals = {
      disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
      type = "group",
      name = L["Capitals"] .. " - " .. MINIMAP_LABEL,
      desc = L["Certain icons can be displayed or not displayed. If the option (Activate icons) has been activated in this category"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. L["Stormwind"] .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND,
      order = 8,
      args = {
        Capitalstheader1 = {
          type = "header",
          name = L["Capitals"] .. " " .. L["icons"],
          order = 80,
          },
        SyncCapitalsAndMinimap = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote end,
          type = "toggle",
          name = "|cffff0000" .. L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"],
          desc = "\n" .. L["Synchronizes the Capitals tab with the Capitals - Minimap tab"] .. "\n" .. "\n" .. L["Which deactivates the functions from the Capitals - Minimap tab and is now controlled together by the Capitals tab"] .. "\n" .. "\n" .. "|cffff0000" .. L["This will delete all Capitals - Minimap settings and replace them with those from Capitals tab"],
          width = 2.5,
          order = 80.1,
          get = function() return ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          set = function(info, v) ns.Addon.db.profile.activate.SyncCapitalsAndMinimap = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
            if not ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) else
            if ns.Addon.db.profile.activate.SyncCapitalsAndMinimap then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["synchronizes"] .. " " .. L["Capitals"] .. " & " ..  L["Capitals"] .. " - " .. MINIMAP_LABEL .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) end end end,
          },
        MinimapCapitals = {
          type = "toggle",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["Activate icons"],
          desc = L["Activates the display of all possible icons on this map"] .. "\n" .. "\n" .. L["Capitals"] .. ":" .. "\n" .. "\n" .. DUNGEON_FLOOR_ORGRIMMAR0 .. "\n" .. L["Thunder Bluff"] .. "\n" .. L["Silvermoon City"] .. "\n" .. L["Undercity"] .. "\n" .. L["Stormwind"] .. "\n" .. L["Ironforge"] .. "\n" .. L["Darnassus"] .. "\n" .. L["Exodar"] .. "\n" .. L["Shattrath City"] .. "\n" .. DUNGEON_FLOOR_DALARAN1 .. " - " .. POSTMASTER_PIPE_NORTHREND,
          width = 1.8,
          order = 80.2,
          get = function() return ns.Addon.db.profile.activate.MinimapCapitals end,
          set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitals = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.activate.MinimapCapitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if not ns.Addon.db.profile.activate.MinimapCapitals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
          },
        MinimapCapitalsEnemyFaction = {
          disabled = function() return ns.Addon.db.profile.activate.HideMapNote or not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
          type = "toggle",
          name = L["Capitals"] .. " " .. MINIMAP_LABEL .. " " .. L["enemy faction"],
          desc = TextIconHorde:GetIconString() ..  " " .. TextIconAlliance:GetIconString() .. " " .. L["Shows enemy faction (horde/alliance) icons"],
          order = 80.3,
          width = 1.8,
          get = function() return ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction end,
          set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.activate.MinimapCapitalsEnemyFaction then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. L["Capitals"] .. " " .. L["enemy faction"], "|cffff0000" ..  L["is deactivated"]) end end end,
         },
        MinimapCapitalsTab = {
          type = "group",
          name = "• " .. L["Capitals"],
          desc = L["Enables the display of icons for a specific capital city"],
          order = 80.4,
          args = {
            Capitalsheader6 = {
              type = "header",
              name = FACTION_HORDE,
              order = 80.5,
              },
            showMinimapCapitalsOrgrimmar = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconOrgrimmar:GetIconString() .. " " .. DUNGEON_FLOOR_ORGRIMMAR0,
              desc = "",
              width = 0.80,
              order = 80.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_ORGRIMMAR0, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsOrgrimmar then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], DUNGEON_FLOOR_ORGRIMMAR0, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsThunderBluff = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconThunderBluff:GetIconString() .. " " .. L["Thunder Bluff"],
              desc = "",
              width = 0.80,
              order = 80.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsThunderBluff then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Thunder Bluff"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsUndercity = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconUndercity:GetIconString() .. " " .. L["Undercity"],
              desc = "",
              width = 0.80,
              order = 80.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Undercity"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsUndercity then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Undercity"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            Capitalsheader7 = {
              type = "header",
              name = FACTION_ALLIANCE,
              order = 82,
              },
            showMinimapCapitalsStormwind = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
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
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconDarnassus:GetIconString() .. " " .. L["Darnassus"],
              desc = "",
              width = 0.80,
              order = 82.3,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Darnassus"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsDarnassus then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], L["Darnassus"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        InstanceMinimapTab = {
          type = "group",
          name = "• " .. BATTLEGROUND_INSTANCE .. " " .. L["icons"],
          desc = "",
          order = 82,
          args = {
            MinimapCapitalsInstances = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Activates the display of all possible icons on this map"],
              width = 0.90,
              order = 82.1,
              get = function() return ns.Addon.db.profile.activate.MinimapCapitalsInstances end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsInstances = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.MinimapCapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"],INSTANCE, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.MinimapCapitalsInstances then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00 ".. MINIMAP_LABEL .. " " .. L["Capitals"],INSTANCE, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            MinimapCapitalsInstanceScale = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80,  
              order = 82.3,
              },
            MinimapCapitalsInstanceAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80,
              order = 82.4,
              },
            Capitalsheader2 = {
              type = "description",
              name = "",
              order = 83.0,
              },
            showMinimapCapitalsPassage = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsInstances or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconPassageRaidM:GetIconString() .. " " .. TextIconPassageDungeonM:GetIconString() .. " " .. TextIconPassageRaidMultiM:GetIconString() .. " " .. TextIconPassageDungeonMultiM:GetIconString() .. " " ..L["Passages"],
              desc = L["Show icons of passage to raids and dungeons on this map"],
              order = 83.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Passages"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPassage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Passages"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
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
            },
          },
        TransportMinimapTab = {
          type = "group",
          name = "• " .. L["Transport"] .. " " .. L["icons"],
          desc = "",
          order = 84,
          args = {
            MinimapCapitalsTransporting = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 84.1,
              get = function() return ns.Addon.db.profile.activate.MinimapCapitalsTransporting end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsTransporting = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.MinimapCapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.MinimapCapitalsTransporting then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            MinimapCapitalsTransportScale = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"] .. "\n" .. "|cffffff00" .. L["Icon size 2.0 would be the default size of Blizzard's own instance icons on the zone map"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80,  
              order = 84.1,
              },
            MinimapCapitalsTransportAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80,
              order = 84.2,
              },
            Capitalsheader3 = {
              type = "description",
              name = "",
              order = 84.5,
              },
            showMinimapCapitalsPortals = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconPortal:GetIconString() .. " " .. TextIconHPortal:GetIconString() .. " " .. TextIconAPortal:GetIconString() .. " " .. L["Portals"],
              desc = L["Show icons of portals on this map"],
              order = 84.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsPortals then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Portals"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsTransport = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconCarriage:GetIconString() .. " " .. L["Transport"],
              desc = L["Shows special transport icons like"] .. "\n" .. "\n" .. " " .. TextIconCarriage:GetIconString() .. " " .. L["Transport"] .. " - " .. DUNGEON_FLOOR_DEEPRUNTRAM1,
              order = 84.9,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsTransport then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Transport"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsFP = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsTransporting or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconTravel:GetIconString() .. " " .. TextIconTravelH:GetIconString() .. " " .. TextIconTravelA:GetIconString() .. " " .. TextIconTravelL:GetIconString() .. " " .. MINIMAP_TRACKING_FLIGHTMASTER,
              desc = "",
              order = 85,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsFP then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " ..L["Capitals"], MINIMAP_TRACKING_FLIGHTMASTER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        ProfessionMinimapTab = {
          type = "group",
          name = "• " .. MINIMAP_TRACKING_TRAINER_PROFESSION .. " " .. L["icons"],
          desc = "",
          order = 86,
          args = {
            MinimapCapitalsProfessions = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 86.1,
              get = function() return ns.Addon.db.profile.activate.MinimapCapitalsProfessions end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsProfessions = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.MinimapCapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRAINER_PROFESSION, L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.MinimapCapitalsProfessions then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_TRAINER_PROFESSION, L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            MinimapCapitalsProfessionsScale = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80,   
              order = 86.2,
              },
            MinimapCapitalsProfessionsAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80,  
              order = 86.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 86.4,
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
            Capitalsheader5 = {
              type = "description",
              name = "",
              order = 86.9,
              },
            showMinimapCapitalsAlchemy = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconAlchemy:GetIconString() .. " " .. L["Alchemy"],
              desc = "",
              width = 1.2, 
              order = 87,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsAlchemy then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Alchemy"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsEngineer = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,              type = "toggle",
              name = TextIconEngineer:GetIconString() .. " " .. L["Engineer"],
              desc = "",
              width = 1.2, 
              order = 87.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsEngineer then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Engineer"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsBlacksmith = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconBlacksmith:GetIconString() .. " " .. L["Blacksmithing"],
              desc = "",
              width = 1.2, 
              order = 87.4,
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
              order = 87.5,
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
              order = 87.6,
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
              order = 87.7,
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
              order = 87.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsHerbalism then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Herbalism"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsFishing = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconFishing:GetIconString() .. " " .. PROFESSIONS_FISHING,
              desc = "",
              width = 1.2, 
              order = 88,
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
              order = 88.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsCooking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_COOKING, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsEnchanting = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconEnchanting:GetIconString() .. " " .. L["Enchanting"],
              desc = "",
              width = 1.2, 
              order = 88.3,
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
              order = 88.4,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsLeatherworking then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, L["Leatherworking"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsFirstAid = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsProfessions or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsProfessionDetection end,
              type = "toggle",
              name = TextIconFirstAid:GetIconString() .. " " .. PROFESSIONS_FIRST_AID,
              desc = "",
              width = 1.2, 
              order = 88.5,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsFirstAid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_FIRST_AID, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsFirstAid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. TUTORIAL_TITLE38, PROFESSIONS_FIRST_AID, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        GeneralMinimapCapitalTab = {
          type = "group",
          name = "• " .. L["General"] .. " " .. L["icons"],
          desc = "",
          order = 89,
          args = {
            MinimapCapitalsGeneral = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Activates the display of all possible icons on this map"],
              width = 0.90,
              order = 89.1,
              get = function() return ns.Addon.db.profile.activate.MinimapCapitalsGeneral end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsGeneral = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.MinimapCapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["General"], L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.MinimapCapitalsGeneral then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"], L["General"], L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            MinimapCapitalsGeneralScale = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80, 
              order = 89.2,
              },
            MinimapCapitalsGeneralAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80, 
              order = 89.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 89.4,
              },
            showMinimapCapitalsMapNotes = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME,
              desc = L["This MapNotes icons shows various icons that are too close to each other together"] .. "\n" .. "\n" .. TextIconBank:GetIconString() .. " " .. BANK .. "\n" .. TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER .. "\n" .. TextIconInnkeeper:GetIconString() .. " " .. MINIMAP_TRACKING_INNKEEPER .. "\n" .. TextIconPassageup:GetIconString() .. " " .. TextIconPassagedown:GetIconString() .. " " .. TextIconPassageleft:GetIconString() .. " " .. TextIconPassageright:GetIconString() .. " " .. L["Paths"],
              width = 0.80,
              order = 89.5,
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
              order = 89.6,
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
              order = 89.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsInnkeeper then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_INNKEEPER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsAuctioneer = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconAuctioneer:GetIconString() .. " " .. MINIMAP_TRACKING_AUCTIONEER,
              desc = "",
              width = 0.80,
              order = 89.8,
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
              order = 89.9,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], BANK, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsBank then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" ..  MINIMAP_LABEL .. " " .. L["Capitals"], BANK, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsMailbox = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconMailbox:GetIconString() .. " " .. MINIMAP_TRACKING_MAILBOX,
              desc = "",
              width = 0.80,
              order = 90.0,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsMailbox then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], MINIMAP_TRACKING_MAILBOX, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsGhost = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconGhost:GetIconString() .. " " .. SPIRIT_HEALER_RELEASE_RED,
              desc = "",
              width = 0.80,
              order = 90.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], SPIRIT_HEALER_RELEASE_RED, "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsGhost then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], SPIRIT_HEALER_RELEASE_RED, "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsWeaponMasters = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsGeneral or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = TextIconPvPVendor:GetIconString() .. " " .. L["Weapon Master"],
              desc = "",
              width = 0.80,
              order = 90.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsWeaponMasters then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Weapon Master"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsWeaponMasters then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL .. " " .. L["Capitals"], L["Weapon Master"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        ClassesMinimapTrainerTab = {
          type = "group",
          name = "• " .. MINIMAP_TRACKING_TRAINER_CLASS .. " " .. L["icons"],
          desc = "",
          order = 90,
          args = {
            MinimapCapitalsClasses = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = L["Activate icons"],
              desc = L["Enables the display of all possible icons on this map"],
              width = 0.90,
              order = 90.1,
              get = function() return ns.Addon.db.profile.activate.MinimapCapitalsClasses end,
              set = function(info, v) ns.Addon.db.profile.activate.MinimapCapitalsClasses = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
                    if ns.Addon.db.profile.activate.MinimapCapitalsClasses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"] .. " " .. TALENT_TRAINER .. " " .. L["icons"], "|cff00ff00" .. L["is activated"]) else 
                    if not ns.Addon.db.profile.activate.MinimapCapitalsClasses then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. MINIMAP_LABEL .. " " .. L["Capitals"] .. " " .. TALENT_TRAINER .. " " .. L["icons"], "|cffff0000" .. L["is deactivated"]) end end end,
              },
            MinimapCapitalsClassesScale = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol size"],
              desc = L["Changes the size of the icons"],
              min = 0.5, max = 6, step = 0.1,
              width = 0.80, 
              order = 90.2,
              },
            MinimapCapitalsClassesAlpha = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "range",
              name = L["symbol visibility"],
              desc = L["Changes the visibility of the icons"],
              min = 0, max = 1, step = 0.1,
              width = 0.80, 
              order = 90.3,
              },
            Capitalsheader4 = {
              type = "description",
              name = "",
              order = 90.4,
              },
            showMinimapCapitalsClassDetection = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap end,
              type = "toggle",
              name = MINIMAP_LABEL .. " " .. L["Class detection"],
              desc = L["Automatically detects your class and activates the corresponding class trainer icons on this map"],
              width = 1.2, 
              order = 90.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    ns.AutomaticClassDetectionCapital()
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Class detection"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassDetection then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Capitals"], L["Class detection"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            Capitalsheader5 = {
              type = "description",
              name = "",
              order = 90.9,
              },
            showMinimapCapitalsClassDruid = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassDruid:GetIconString() .. " " .. L["Druid"],
              desc = "",
              width = 1.2, 
              order = 91,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassDruid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], TALENT_TRAINER, L["Druid"], L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassDruid then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], TALENT_TRAINER, L["Druid"], L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassHunter = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassHunter:GetIconString() .. " " .. L["Hunter"],
              desc = "",
              width = 1.2, 
              order = 91.1,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassHunter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Hunter"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassHunter then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Hunter"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassMage = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassMage:GetIconString() .. " " .. L["Mage"],
              desc = "",
              width = 1.2, 
              order = 91.2,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassMage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Mage"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassMage then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Mage"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassPaladin = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassPaladin:GetIconString() .. " " .. L["Paladin"],
              desc = "",
              width = 1.2, 
              order = 91.3,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassPaladin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Paladin"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassPaladin then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Paladin"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassPriest = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassPriest:GetIconString() .. " " .. L["Priest"],
              desc = "",
              width = 1.2, 
              order = 91.4,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassPriest then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Priest"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassPriest then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Priest"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassRogue = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassRogue:GetIconString() .. " " .. L["Rogue"],
              desc = "",
              width = 1.2, 
              order = 91.5,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassRogue then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Rogue"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassRogue then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Rogue"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassShaman = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassShaman:GetIconString() .. " " .. L["Shaman"],
              desc = "",
              width = 1.2, 
              order = 91.6,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassShaman then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Shaman"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassShaman then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Shaman"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassWarlock = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassWarlock:GetIconString() .. " " .. L["Warlock"],
              desc = "",
              width = 1.2, 
              order = 91.7,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassWarlock then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Warlock"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassWarlock then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Warlock"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            showMinimapCapitalsClassWarrior = {
              disabled = function() return not ns.Addon.db.profile.activate.MinimapCapitals or not ns.Addon.db.profile.activate.MinimapCapitalsClasses or ns.Addon.db.profile.activate.SyncCapitalsAndMinimap or ns.Addon.db.profile.showMinimapCapitalsClassDetection end,
              type = "toggle",
              name = TextIconClassWarrior:GetIconString() .. " " .. L["Warrior"],
              desc = "",
              width = 1.2, 
              order = 91.8,
              set = function(info, v) ns.Addon.db.profile[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes") 
                    if ns.Addon.db.profile.ChatMassage and ns.Addon.db.profile.showMinimapCapitalsClassWarrior then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Warrior"], TALENT_TRAINER, L["icons"], "|cff00ff00" .. L["are shown"]) else 
                    if ns.Addon.db.profile.ChatMassage and not ns.Addon.db.profile.showMinimapCapitalsClassWarrior then print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. MINIMAP_LABEL, L["Capitals"], L["Warrior"], TALENT_TRAINER, L["icons"], "|cffff0000" .. L["are hidden"])end end end,
              },
            },
          },
        },
      },
  }
}
end