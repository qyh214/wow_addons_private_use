--[[

Learning Aid version 1.12 Beta 1
Compatible with World of Warcraft version 6.0.2
Learning Aid is copyright © 2008-2014 Jamash (Kil'jaeden US Horde)
Email: jamashkj@gmail.com

LearningAid.lua is part of Learning Aid.

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

private.debug = 0
private.debugCount = 0
private.debugLimit = 10000 -- how many lines of log to keep before deleting earliest line
private.logAllEvents = false
private.shadow = { }
private.wrappers = { }
private.debugFlags = { }
private.tokenCount = { }
private.noLog = { -- do not log calls to these functions even when call logging is enabled
  GetVisible = true,
  GetText = true,
  ListJoin = true,
  --SpellInfo = true,
  --SpellBookInfo = true,
  -- MOP -- PLAYER_GUILD_UPDATE = true,
  -- MOP -- UpdateGuild = true,
  -- PANDARIA -- COMPANION_UPDATE = true
}

local LA = { 
  version = GetAddOnMetadata(addonName, "Version"),
  dataVersion = 1,
  name = addonName,
  titleHeight = 40, -- pixels
  frameWidth = 200, -- pixels
  framePadding = 10, -- pixels
  verticalSpacing = 5, -- pixels
  horizontalSpacing = 153, -- pixels
  buttonSize = 37, -- pixels
  width = 1, -- button columns
  height = 0, -- button rows
  visible = 0, -- buttons
  strings = { },
  FILTER_SHOW_ALL  = 0,
  FILTER_SUMMARIZE = 1, -- default
  FILTER_SHOW_NONE = 2,
  CONFIRM_TRAINER_BUY_ALL = 732297, -- magic number to prevent users from accidentally spending hundreds of gold at a trainer
  patterns = {
    learnAbility    = ERR_LEARN_ABILITY_S,
    learnSpell      = ERR_LEARN_SPELL_S,
    unlearnSpell    = ERR_SPELL_UNLEARNED_S,
    petLearnAbility = ERR_PET_LEARN_ABILITY_S,
    petLearnSpell   = ERR_PET_LEARN_SPELL_S,
    petUnlearnSpell = ERR_PET_SPELL_UNLEARNED_S,
    -- MoP 5.0.4 pre-patch added "You have learned a new passive effect: %s"
    learnPassive    = ERR_LEARN_PASSIVE_S
    -- add tradeskill learning stuff here
  },
  defaults = { -- default savedvariables contents
    macros = true,
    totem = true,
    enabled = true,
    restoreActions = true,
    filterSpam = 1, -- FILTER_SUMMARIZE
    debugFlags = { },
    ignore = { }
  },
  menuHideDelay = 5, -- seconds
  pendingBuyCount = 0,
  state = {
    --inCombat = false, -- InCombatLockdown() made this obsolete
    retalenting = false,
    untalenting = false,
    learning = false
  },
--  petLearning = false,
  activatePrimarySpec = 63645, -- global spellID
  activateSecondarySpec = 63644, -- global spellID
  racialSpell = 20549, -- War Stomp (Tauren)
  racialPassiveSpell = 20550, -- Endurance (Tauren)
  ridingSpells = {
    [33388] = true,  -- Apprentice (60% ground speed)
    [33391] = true,  -- Journeyman (100% ground speed)
    [34090] = true,  -- Expert (150% flying speed)
    [34091] = true,  -- Artisan (280% flying speed)
    [90265] = true,  -- Master (310% flying speed)
    [90267] = true,  -- Flight Master's License (EK, Kalimdor, Deepholm)
    [54197] = true,  -- Cold Weather Flying (Northrend)
    [115913] = true, -- Wisdom of the Four Winds (Pandaria)
    [130487] = true  -- Cloud Serpent Riding (Pandaria)
  },
  origin = {
    profession = "profession",
    class = "class",
    guild = "guild",
    riding = "riding",
    race = "race"
  },
  numProfessions = 6,
  buttons = { },
  queue = { },
  availableServices = { },
  petLearned = { },
  petUnlearned = { },
  --[[ PANDARIA
  companionCache = {
    MOUNT = { },
    CRITTER = { }
  },
  ]]
  ignore = { },
  --[[ SPELL API
  spellBookCache = { },
  oldSpellBookCache = { },
  spellInfoCache = { },
  ]]
  spellsLearned  = { },
  spellsUnlearned = { },
  flyoutCache = { },
  numSpells = 0,
  guildSpells = { },
  knownSpells = { },
  oldKnownSpells = { },
  specToGlobal = { }, -- keys are spec spell IDs, values are global spell IDs
  globalToSpec = { }, -- keys are global spell IDs, values are spec spell IDs
  nameToGlobal = { }, -- keys are spell names (lowercased), values are global spell IDs
  backdrop = {
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",
    tile = false, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  }
}

private.LA = LA
_G[addonName] = LA

LibStub("AceConsole-3.0"):Embed(LA)

function private.onEvent(frame, event, ...)
  LA:DebugPrint("EVENT", event, ...)
  if LA[event] then
    LA[event](LA, ...)
  end
end

LA.frame = CreateFrame("Frame", nil, UIParent)
LA.frame:SetScript("OnEvent", private.onEvent)

LA.frame:RegisterEvent("ADDON_LOADED")

for name, pattern in pairs(LA.patterns) do
  LA.patterns[name] = string.gsub(pattern, "%%s", "(.+)")
end

function LA:Init()
  --self:DebugPrint("Initialize()")
  self.localClass, self.enClass = UnitClass("player")
  self.tocVersion = select(4, GetBuildInfo())
  self.locale = GetLocale()
  self:SetDefaultSettings()
  if private.logAllEvents then
    self:Debug("CALL", true)
    self.frame:RegisterAllEvents()
  end
  --  Collect a list of guild perk spells so that LearningAid doesn't
  -- spam them onscreen when they jump into and out of the spellbook,
  -- which they have been known to do
  --  The second return value of GetGuildPerkInfo is the global spellID
  -- of the perk, as it appears in the spellbook
  for perk = 1, GetNumGuildPerks() do
    self.guildSpells[select(2, GetGuildPerkInfo(perk))] = perk
  end
  -- set up main frame
  local frame = self.frame
  frame:Hide()
  frame:SetClampedToScreen(true)
  frame:SetWidth(self.frameWidth)
  frame:SetHeight(self.titleHeight)
  frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -200)
  frame:SetMovable(true)
  frame:SetScript("OnShow", function () self:OnShow() end)
  frame:SetScript("OnHide", function () self:OnHide() end)
  frame:SetBackdrop(self.backdrop)

  -- create title bar
  local titleBar = CreateFrame("Frame", nil, frame)
  self.titleBar = titleBar
  titleBar:SetPoint("TOPLEFT")
  titleBar:SetPoint("TOPRIGHT")
  titleBar:SetHeight(self.titleHeight)
  titleBar:RegisterForDrag("LeftButton")
  titleBar:EnableMouse()
  titleBar.text = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleBar.text:SetText(self:GetText("title"))
  titleBar.text:SetPoint("CENTER", titleBar, "CENTER", 0, 0)

  -- create close button in the upper right corner of the frame
  local closeButton = CreateFrame("Button", nil, titleBar)
  self.closeButton = closeButton
  closeButton:SetWidth(32)
  closeButton:SetHeight(32)
  closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -2, 0)
  closeButton:SetNormalTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Up")
  closeButton:SetPushedTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Down")
  closeButton:SetDisabledTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Disabled")
  closeButton:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight")
  closeButton:SetScript("OnClick", function () self:Hide() end)

  -- create lock button in the upper left corner of the frame
  local lockButton = CreateFrame("Button", nil, titleBar)
  self.lockButton = lockButton
  lockButton:SetWidth(20)
  lockButton:SetHeight(20)
  lockButton:SetPoint("LEFT", titleBar, "LEFT", 15, 0)
  lockButton:SetNormalTexture("Interface/LFGFrame/UI-LFG-ICON-LOCK")
  lockButton:SetScript("OnClick", function() if self.saved.locked then self:Unlock() else self:Lock() end end)
  
  -- initialize right-click menu
  self.menuTable = {
    { text = self:GetText("lockPosition"), 
      func = function () self:ToggleLock() end }--,
--    { text = self:GetText("close"),
--      func = function () self:Hide() end }
  }

  local menu = CreateFrame("Frame", "LearningAid_Menu", titleBar, "UIDropDownMenuTemplate")

  -- set drag and click handlers for the title bar
  titleBar:SetScript(
    "OnDragStart",
    function (bar, button)
      if not self.saved.locked then
        bar:GetParent():StartMoving()
      end
    end
  )

  titleBar:SetScript(
    "OnDragStop",
    function (bar)
      local parent = bar:GetParent()
      parent:StopMovingOrSizing()
      self.saved.x = parent:GetLeft()
      self.saved.y = parent:GetTop()
    end
  )

  titleBar:SetScript(
    "OnMouseUp",
    function (bar, button)
      if button == "MiddleButton" then
        self:Hide()
      elseif button == "RightButton" then
        EasyMenu(self.menuTable, menu, "cursor", 0, 8, "MENU", self.menuHideDelay)
      end
    end
  )

  self.options = {
    handler = self,
    type = "group",
    args = {
      lock = {
        name = self:GetText("lockWindow"),
        desc = self:GetText("lockWindowHelp"),
        type = "toggle",
        set = function(info, val) if val then self:Lock() else self:Unlock() end end,
        get = function(info) return self.saved.locked end,
        width = "full",
        order = 1
      },
      restoreactions = {
        name = self:GetText("restoreActions"),
        desc = self:GetText("restoreActionsHelp"),
        type = "toggle",
        set = function(info, val) self.saved.restoreActions = val end,
        get = function(info) return self.saved.restoreActions end,
        width = "full",
        order = 2
      },
      filter = {
        name = self:GetText("showLearnSpam"),
        desc = self:GetText("showLearnSpamHelp"),
        type = "select",
        values = {
          [self.FILTER_SHOW_ALL ] = self:GetText("showAll"),
          [self.FILTER_SUMMARIZE] = self:GetText("summarize"),
          [self.FILTER_SHOW_NONE] = self:GetText("showNone")
        },
        set = function(info, val)
          local old = self.saved.filterSpam
          if old ~= val then
            self.saved.filterSpam = val
            if val == self.FILTER_SHOW_ALL then
              self:DebugPrint("Removing chat filter for CHAT_MSG_SYSTEM")
              ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", private.spellSpamFilter)
            elseif old == self.FILTER_SHOW_ALL then
              self:DebugPrint("Adding chat filter for CHAT_MSG_SYSTEM")
              ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", private.spellSpamFilter)
            end
          end
        end,
        get = function(info) return self.saved.filterSpam end,
        order = 3
      },
      reset = {
        name = self:GetText("resetPosition"),
        desc = self:GetText("resetPositionHelp"),
        type = "execute",
        func = "ResetFramePosition",
        --width = "full",
        order = 4
      },
      missing = {
        type = "group",
        inline = true,
        name = self:GetText("findMissingAbilities"),
        order = 10,
        args = {
          search = {
            name = self:GetText("searchMissing"),
            desc = self:GetText("searchMissingHelp"),
            type = "execute",
            func = "FindMissingActions",
            -- width = "full",
            order = 1
          },
          shapeshift = {
            name = self:GetText("findShapeshift"),
            desc = self:GetText("findShapeshiftHelp"),
            type = "toggle",
            set = function(info, val) self.saved.shapeshift = val end,
            get = function(info) return self.saved.shapeshift end,
            width = "full",
            order = 3
          },
          macros = {
            name = self:GetText("searchInsideMacros"),
            desc = self:GetText("searchInsideMacrosHelp"),
            type = "toggle",
            set = function(info, val) self.saved.macros = val end,
            get = function(info) return self.saved.macros end,
            width = "full",
            order = 4
          },
          ignore = {
            name = self:GetText("ignore"),
            desc = self:GetText("ignoreHelp"),
            type = "input",
            guiHidden = true,
            set = "ChatCommandIgnore"
          },
          unignore = {
            name = self:GetText("unignore"),
            desc = self:GetText("unignoreHelp"),
            type = "input",
            guiHidden = true,
            set = "ChatCommandUnignore"
          },
          unignoreall = {
            order = 5,
            name = self:GetText("unignoreAll"),
            desc = self:GetText("unignoreAllHelp"),
            type = "execute",
            -- width = "full",
            func = "UnignoreAll"
          }
        }
      },
      unlock = {
        name = self:GetText("unlockWindow"),
        desc = self:GetText("unlockWindowHelp"),
        type = "execute",
        guiHidden = true,
        func = "Unlock"
      },
      config = {
        name = self:GetText("configure"),
        desc = self:GetText("configureHelp"),
        type = "execute",
        func = function() InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) end,
        guiHidden = true
      },
      advanced = {
        type = "group",
        name = self:GetText("advanced"),
        args = {
          framestrata = {
            name = self:GetText("frameStrata"),
            desc = self:GetText("frameStrataHelp"),
            type = "select",
            values = {
              -- PARENT = "Parent",
              BACKGROUND = "Background",
              LOW = "Low",
              MEDIUM = "Medium",
              HIGH = "High",
              DIALOG = "Dialog",
              FULLSCREEN = "Fullscreen",
              FULLSCREEN_DIALOG = "Fullscreen Dialog",
              TOOLTIP = "Tooltip"
            },
            set = function(info, val)
              self.saved.frameStrata = val
              self.frame:SetFrameStrata(val)
            end,
            get = function(info) return self.frame:GetFrameStrata() end,
            order = 1
          },
          -- only display debugging options if debugging is enabled
          debug = {
            name = self:GetText("debugOutput"),
            desc = self:GetText("debugOutputHelp"),
            values = { SET = "Assignment", GET = "Access", CALL = "Function Calls" },
            type = "multiselect",
            set = function(info, key, val) self:Debug(key, val) end,
            get = function(info, key) return self:Debug(key) end,
            width = "full",
            order = 99,
            guiHidden = (0 == private.debug)
          } or nil
        }
      },
      test = {
        type = "group",
        name = "Test",
        desc = "Perform various tests with Learning Aid.",
        hidden = true,
        guiHidden = true,
        args = {
          add = {
            type = "group",
            name = "Add",
            desc = "Add a button to the Learning Aid window.",
            args = {
              spell = {
                type = "input",
                name = "Spell",
                pattern = "^%d+$",
                set = function(info, val)
                  self:AddButton(self.Spell.Book[tonumber(val)])
                end
              },
              all = {
                name = "All",
                desc = "The Kitchen Sink",
                type = "execute",
                func = function ()
                  local i = 1
                  local spellName, spellRank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                  while spellName do
                    self:AddButton(self.Spell.Book[i])
                    i = i + 1
                    spellName, spellRank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                  end
                end
              }
            }
          },
          remove = {
            type = "group",
            name = "Remove",
            desc = "Remove a button from the Learning Aid window.",
            args = {
              spell = {
                type = "input",
                name = "Spell",
                pattern = "^%d+$",
                set = function(info, val)
                  self:ClearButtonID(BOOKTYPE_SPELL, tonumber(val))
                end
              },
              button = {
                type = "input",
                name = "Button",
                pattern = "^%d+$",
                set = function(info, val)
                  self:ClearButtonIndex(tonumber(val))
                end
              }
            }
          }
        }
      }
    }
  }
  if self.enClass == "SHAMAN" then
    self.options.args.missing.args.totem = {
      name = self:GetText("findTotem"),
      desc = self:GetText("findTotemHelp"),
      type = "toggle",
      set = function(info, val) self.saved.totem = val end,
      get = function(info) return self.saved.totem end,
      width = "full",
      order = 4
    }
  end
  LibStub("AceConfig-3.0"):RegisterOptionsTable("LearningAidConfig", self.options, {"la", "learningaid"})
  self:DebugPrint("Registering with AceConfig under '"..self:GetText("title").." "..self.version.."'")
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("LearningAidConfig", self:GetText("title").." "..self.version)
  hooksecurefunc("ConfirmTalentWipe", function()
    self:DebugPrint("ConfirmTalentWipe")
    self:SaveActionBars()
    self.state.untalenting = true
    --self.spellsUnlearned = {}
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "OnEvent")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnEvent")
    -- self:RegisterEvent("UI_ERROR_MESSAGE", "OnEvent")
  end)
  --[[ PANDARIA
  hooksecurefunc("LearnPreviewTalents", function(pet)
    self:DebugPrint("LearnPreviewTalents", pet)
    if pet then
--      self.petLearning = true
    else
      self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnEvent")
      --wipe(self.spellsLearned)
      --wipe(self.spellsUnlearned)
      self.state.learning = true
    end
  end)
  ]]
  hooksecurefunc("SetCVar", function (cvar, value)
    if cvar == nil then cvar = "" end
    if value == nil then value = "" end
    cvarLower = string.lower(cvar)
    self:DebugPrint("SetCVar("..cvar..", "..value..")")
    if cvarLower == "uiscale" or cvarLower == "useuiscale" then
      self:AutoSetMaxHeight()
    end      
  end)
  --self.LearnTalent = LearnTalent
  self.pendingTalents = {}
  self.pendingTalentCount = 0
  --[[-- TODO FIXME Rewrite entire talent handling code FIXME TODO --
  hooksecurefunc("LearnTalent", function(tab, talent, pet, group, ...)
    self:DebugPrint("LearnTalent", tab, talent, pet, group, ...)
    local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, unknown1, unknown2 = GetTalentInfo(tab, talent, false, pet, group)
    self:DebugPrint("GetTalentInfo", name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, unknown1, unknown2)
    --self.LearnTalent(tab, talent, pet, group, ...)
    if rank < maxRank and meetsPrereq and not pet then
      --wipe(self.spellsLearned)
      --self.state.learning = true
      if self.pendingTalentCount == 0 then wipe(self.pendingTalents) end
      self:RegisterEvent("PLAYER_TALENT_UPDATE")
      local id = (group or GetActiveSpecGroup()).."."..tab.."."..talent.."."..rank
      if not self.pendingTalents[id] then
        self.pendingTalents[id] = true
        self.pendingTalentCount = self.pendingTalentCount + 1
      end
      --self:DebugPrint(GetTalentInfo(tab, talent, false, pet, group))
    end
  end)
  ]]-- TODO FIXME Rewrite entire talent handling code FIXME TODO --
  self:RegisterChatCommand("la", "AceSlashCommand")
  self:RegisterChatCommand("learningaid", "AceSlashCommand")
  --self:SetEnabledState(self.saved.enabled)
  --self.saved.enabled = true
  --self:DebugPrint("OnEnable()")
  local baseEvents = {
    "ACTIVE_TALENT_GROUP_CHANGED",
    "ADDON_LOADED",
    "CHAT_MSG_SYSTEM",
    -- PANDARIA -- "COMPANION_LEARNED",
    -- PANDARIA -- "COMPANION_UPDATE",
    "PET_TALENT_UPDATE",
    "PLAYER_LEAVING_WORLD",
    "PLAYER_LEVEL_UP",
    "PLAYER_LOGIN",
    "PLAYER_LOGOUT",
-- MOP --    "PLAYER_GUILD_UPDATE",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
--    "SPELLS_CHANGED", -- wait until PLAYER_LOGIN
    "UNIT_SPELLCAST_START",
    "UI_SCALE_CHANGED",
--    "UPDATE_BINDINGS", -- PANDARIA -- not needed because of companion/mount removal
    "VARIABLES_LOADED"
--[[
    "CURRENT_SPELL_CAST_CHANGED",
    "SPELL_UPDATE_COOLDOWN",
    "TRADE_SKILL_CLOSE",
    "TRADE_SKILL_SHOW",
    "UNIT_SPELLCAST_SUCCEEDED"
--]]
  }
  --if private.logAllEvents then
  --  self.frame:RegisterAllEvents()
  --else
    for i, event in ipairs(baseEvents) do
      self:RegisterEvent(event, "OnEvent")
    end
  --end
  --self:UpdateSpellBook()
  --PANDARIA
  --self:UpdateCompanions()
  self:DiffActionBars()
  self:SaveActionBars()
  if self.saved.filterSpam ~= LA.FILTER_SHOW_ALL then
    self:DebugPrint("Initially adding chat filter for CHAT_MSG_SYSTEM")
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", private.spellSpamFilter)
  end
  if self.saved.locked then
    self.menuTable[1].text = self:GetText("unlockPosition")
  else
    self.saved.locked = false
  end
  if self.saved.frameStrata then
    self.frame:SetFrameStrata(self.saved.frameStrata)
  end
end

-- this is a function
function private.spellSpamFilter(...) return LA:spellSpamFilter(...) end

-- this is a method
function LA:spellSpamFilter(chatFrame, event, message, ...)
  local spell
  local patterns = self.patterns
  if (self.saved.filterSpam ~= self.FILTER_SHOW_ALL) and (
    (
      self.state.untalenting or
      self.state.retalenting or
     (self.pendingTalentCount > 0) or
     (self.saved.filterSpam == self.FILTER_SHOW_NONE) or
      self.state.learning or
--      self.petLearning or
      (self.pendingBuyCount > 0)
    ) and (
      string.match(message, patterns.learnSpell) or 
      string.match(message, patterns.learnAbility) or
      string.match(message, patterns.learnPassive) or
      string.match(message, patterns.unlearnSpell)
--    )
  ) or
    string.match(message, patterns.petLearnAbility) or
    string.match(message, patterns.petLearnSpell) or
    string.match(message, patterns.petUnlearnSpell)
  ) then
    self:DebugPrint("Suppressing message")
    return true -- do not display the message
  else
    self:DebugPrint("Allowing message")
    return false, message, ... -- pass the message along
  end
end

function LA:GetText(id, ...)
  if not id then
    if self.DebugPrint then
      self:DebugPrint("Nil supplied to GetText()")
    end
    return "Nil"
  end
  local result = "Invalid String ID '" .. id .. "'"
  if self.strings[self.locale] and self.strings[self.locale][id] then
    result = self.strings[self.locale][id]
  elseif self.strings.enUS[id] then
    result = self.strings.enUS[id]
  else
    self:DebugPrint(result)
  end
  return format(result, ...)
end

function LA:SetDefaultSettings()
  LearningAid_Saved = LearningAid_Saved or {}
  LearningAid_Character = LearningAid_Character or {}
  self.saved = LearningAid_Saved
  self.character = LearningAid_Character
  self.saved.version = self.version
  self.character.version = self.version
  self.saved.dataVersion = self.dataVersion
  self.character.dataVersion = self.dataVersion

  for key, value in pairs(self.defaults) do
    if self.saved[key] == nil then
      self.saved[key] = value
    end
  end
  self.saved.ignore[self.enClass] = self.saved.ignore[self.enClass] or { }
  self.saved.ignore.profession    = self.saved.ignore.profession or { }
  self.saved.ignore.guild         = self.saved.ignore.guild or { }
  self.saved.ignore.race          = self.saved.ignore.race or { }
  self.ignore.class      = self.saved.ignore[self.enClass]
  self.ignore.profession = self.saved.ignore.profession
  self.ignore.guild      = self.saved.ignore.guild
  self.ignore.race       = self.saved.ignore.race
  -- update with new debug option format as of 1.11
  if self.saved.debug ~= nil then
    if self.saved.debug then
      self.saved.debugFlags = { SET = true, GET = true, CALL = true }
    end
    self.saved.debug = nil
  end
  for k, v in pairs(self.saved.debugFlags) do
    if v then
      self:Debug()
      break
    end
  end
end
function LA:RegisterEvent(event)
  self.frame:RegisterEvent(event)
--  self.events[event] = true -- EVENT DEBUGGING
end
function LA:UnregisterEvent(event)
  self.frame:UnregisterEvent(event)
--  self.events[event] = false -- EVENT DEBUGGING
end
function LA:UpgradeIgnoreList()
  local ignore = self.saved.ignore
  if ignore[self.localClass] then
    local oldIgnore = ignore[self.localClass]
    for spellLower, spellName in pairs(oldIgnore) do
      if type(spellLower) == "string" then -- old-style ignore list
        if self:ChatCommandIgnore(nil, spellName) then -- successfully converted format
          oldIgnore[spellLower] = nil
        end
      end
    end
    if self.localClass ~= self.enClass and not next(oldIgnore) then -- converted all old entries
      ignore[self.localClass] = nil
    end
  end
end
function LA:Ignore(spell)
  if "SPELL" == spell.status then
    self.ignore[spell.ID] = true
  end
  -- FIXME FIXME FIXME -- do something with flyouts
--[[
  --local bookItem = self.spellBookCache[globalID]
  --local spell = self.Spell.Global[globalID]
  if spell and not spell.Passive then -- self.ignore[bookItem.origin] and
    --if bookItem.origin == self.origin.profession then
      self.ignore[bookItem.origin][bookItem.info.name] = true
    else
      self.ignore[bookItem.origin][globalID] = true
    end
    self:UpdateButtons()
    return true
  end
  return false
  ]]
end
function LA:ChatCommandIgnore(info, str)
  str = strtrim(str)
  if #str == 0 then
    -- print ignore list to the chat frame
    for origin, t in pairs(self.ignore) do
      for globalID, v in pairs(t) do
        DEFAULT_CHAT_FRAME:AddMessage(self:GetText("title")..": ".. self:GetText("listIgnored", GetSpellLink(globalID)))
      end
    end
  else
    local status, globalID = GetSpellBookItemInfo(str, BOOKTYPE_SPELL)
    -- globalID = globalID or select(2, self:UnlinkSpell(str)) -- redundant
    if "SPELL" == status then
      return self:Ignore(self.Spell.Global[globalID])
    end
  end
end
function LA:ChatCommandUnignore(info, str)
  local status, globalID = GetSpellBookItemInfo(str:trim(), BOOKTYPE_SPELL)
  -- globalID = globalID or select(2, self:UnlinkSpell(str))
  if "SPELL" == status then
    self:Unignore(self.Spell.Global[globalID])
  end
end
function LA:Unignore(spell)
-- local spell = self.Spell.Book[globalID]
--  if bookItem and self.ignore[bookItem.origin] then
--    if bookItem.origin == self.origin.profession then
--      self.ignore[bookItem.origin][bookItem.info.name] = nil
    self.ignore[spell.ID] = nil
--    elseif self.ignore[bookItem.origin][globalID] then
--      self.ignore[bookItem.origin][globalID] = nil
--    end
    self:UpdateButtons()
--    return true
--  end
--  return false
end
function LA:IsIgnored(spell)
  --local bookItem = self.spellBookCache[globalID]
  --if bookItem and self.ignore[bookItem.origin] then
  --  if bookItem.origin == self.origin.profession then
  --    return self.ignore[bookItem.origin][bookItem.info.name]
  --  else
  --    return self.ignore[bookItem.origin][globalID]
  return self.ignore[spell.ID]
  --  end
  --end
end
function LA:ToggleIgnore(spell)
  if self:IsIgnored(spell.ID) then
    self:Unignore(spell.ID)
  else
    self:Ignore(spell.ID)
  end
end
function LA:UnignoreAll()
  --for kind, list in pairs(self.ignore) do
  --  wipe(list)
  wipe(self.ignore)
  --end
end
function LA:ResetFramePosition()
  local frame = self.frame
  frame:ClearAllPoints()
  frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -200)
  self.saved.x = frame:GetLeft()
  self.saved.y = frame:GetTop()
end
function LA:AceSlashCommand(msg)
  LibStub("AceConfigCmd-3.0").HandleCommand(LearningAid, "la", "LearningAidConfig", msg)
end
function LA:SystemPrint(message)
  local systemInfo = ChatTypeInfo["SYSTEM"]
  DEFAULT_CHAT_FRAME:AddMessage(LA:GetText("title")..": "..message, systemInfo.r, systemInfo.g, systemInfo.b, systemInfo.id)
end

function LA:ProcessQueue()
  if InCombatLockdown() then
    self:DebugPrint("ProcessQueue(): Cannot process action queue during combat.")
  else
    self.queue = self.queue or { }
    local queue = self.queue
    for index = 1, #queue do
      local item = queue[index]
      if item.action == "SHOW" then
        self:AddButton(self.Spell.Global[item.id])
      elseif item.action == "CLEAR" then
        self:ClearButtonID(item.id)
      -- elseif item.kind == BOOKTYPE_SPELL then
        if item.action == "LEARN" then
          self:AddSpell(item.id)
        elseif item.action == "FORGET" then
          self:RemoveSpell(item.id)
        else
          self:DebugPrint("ProcessQueue(): Invalid action type " .. item.action)
        end
      --[[ PANDARIA
      elseif item.kind == "CRITTER" or item.kind == "MOUNT" then
        if item.action == "LEARN" then
          self:AddCompanion(item.kind, item.id)
        else
          self:DebugPrint("ProcessQueue(): Invalid action type " .. item.action)
        end 
      ]]
      elseif item.action == "HIDE" then
        self:Hide()
      else
        self:DebugPrint("ProcessQueue(): Invalid entry type " .. item.action)
      end
    end
    wipe(self.queue)
  end
end
function LA:FormatSpells(t)
  local str = ""
  for i, spell in ipairs(t) do
    str = str .. ("|T%s:0|t"):format(spell.SpecTexture) .. spell.SpecLink .. ", "
  end
  if #t > 0 then
    return string.sub(str, 1, -3) -- trim off final ", "
  else
    return nil
  end
end
local function spellCompare (a,b)
  return a.SpecName < b.SpecName
end
function LA:PrintPending()
  local learned = self.spellsLearned
  local unlearned = self.spellsUnlearned
  if self.saved.filterSpam == self.FILTER_SUMMARIZE then
    -- lots of work just to remove stuff that's unlearned and then immediately relearned
    if #learned > 0 and #unlearned > 0 then
      local spells = { }
      local learnedDupes = { }
      local unlearnedDupes = { }
      local name
      for index, spell in ipairs(learned) do
        spells[spell.SpecName] = index
      end
      for index, spell in ipairs(unlearned) do
        name = spell.SpecName
        if spells[name] then
          tinsert(learnedDupes, spells[name])
          tinsert(unlearnedDupes, index) -- do not disturb the table while traversing it
        end
      end
      table.sort(learnedDupes)
      for i = #learnedDupes, 1, -1 do -- go backwards so later indices don't change when removing earlier elements
        tremove(learned, learnedDupes[i])
      end
      table.sort(unlearnedDupes)
      for i = #unlearnedDupes, 1, -1 do
        tremove(unlearned, unlearnedDupes[i])
      end
      -- phew!
    end
    table.sort(learned, spellCompare)
    table.sort(unlearned, spellCompare)
    local learnedString = self:FormatSpells(learned)
    self:DebugPrint("learned", learnedString)
    local unlearnedString = self:FormatSpells(unlearned)
    self:DebugPrint("unlearned", unlearnedString)
    if unlearnedString then self:SystemPrint(self:GetText("youHaveUnlearned", unlearnedString)) end
    if learnedString then self:SystemPrint(self:GetText("youHaveLearned", learnedString)) end

    if #self.petUnlearned > 0 then
      table.sort(self.petUnlearned)
      self:SystemPrint(self:GetText("yourPetHasUnlearned", self:ListJoin(self.petUnlearned)))
    end
    if #self.petLearned > 0 then
      table.sort(self.petLearned)
      self:SystemPrint(self:GetText("yourPetHasLearned", self:ListJoin(self.petLearned)))
    end
  end
  wipe(self.petLearned)
  wipe(self.petUnlearned)
  wipe(self.spellsLearned)
  wipe(self.spellsUnlearned)
  wipe(self.pendingTalents)
end


function LA:OnShow()
  -- PANDARIA -- self:RegisterEvent("COMPANION_UPDATE", "OnEvent")
  self:RegisterEvent("TRADE_SKILL_SHOW", "OnEvent")
  self:RegisterEvent("TRADE_SKILL_CLOSE", "OnEvent")
  self:RegisterEvent("SPELL_UPDATE_COOLDOWN", "OnEvent")
  self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", "OnEvent")
end
function LA:OnHide()
  -- PANDARIA -- self:UnregisterEvent("COMPANION_UPDATE")
  self:UnregisterEvent("TRADE_SKILL_SHOW")
  self:UnregisterEvent("TRADE_SKILL_CLOSE")
  self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
  self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED")
end
function LA:Lock()
    self.saved.locked = true
    self.menuTable[1].text = self:GetText("unlockPosition")
end
function LA:Unlock()
    self.saved.locked = false
    self.menuTable[1].text = self:GetText("lockPosition")
end
function LA:ToggleLock()
  if self.saved.locked then
    self:Unlock()
  else
    self:Lock()
  end
end

function LA:PurgeConfig()
  wipe(self.saved)
  wipe(self.character)
  self:SetDefaultSettings()
end