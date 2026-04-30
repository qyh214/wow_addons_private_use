local appName, app = ...
---@class AbilityTimeline
local private = app
---@type AceConfigOptionsTable
private.options = {
  name = private.getLocalisation("addonOptions"),
  type = "group",
  args = {
    reminderBrowser = {
      name = private.getLocalisation("reminderBrowser"),
      desc = private.getLocalisation("reminderBrowserDescription"),
      type = "group",
      order = 10,
      args = {
        recent_encounters = {
          name = private.getLocalisation("CreatedReminders"),
          desc = private.getLocalisation("CreatedRemindersDescription"),
          type = "select",
          order = 21,
          values = function()
            local out = {}
            if private.db and private.db.profile and private.db.profile.reminders then
              for id, stored in pairs(private.db.profile.reminders) do
                local first = stored[1]
                if first then
                  local encName = EJ_GetEncounterInfo(first.journalEncounterID)
                  local instName = EJ_GetInstanceInfo(first.journalInstanceID)
                  local display = string.format("%s — %s", instName, encName)
                  out[tostring(id)] = display
                end
              end
            end
            return out
          end,
          set = function(info, val) private._recentSelected = tonumber(val) end,
          get = function(info) return tostring(private._recentSelected or "") end,
          width = "full",
        },
        open_recent = {
          name = private.getLocalisation("OpenSelectedReminderEditor"),
          desc = private.getLocalisation("OpenSelectedReminderEditorDescription"),
          type = "execute",
          order = 22,
          disabled = function() return not private._recentSelected end,
          func = function()
            local sel = private._recentSelected
            -- Open the selected saved encounter (keyed by dungeonEncounterID)
            private.RegisterEncounter(sel, nil, false)
            local stored = private.db.profile.reminders[sel]
            local first = stored[1]
            if first then
              local params = {
                journalEncounterID = first.journalEncounterID,
                journalInstanceID = first.journalInstanceID,
                dungeonEncounterID =
                    tonumber(sel)
              }
              private.openTimingsEditor(params)
            end
          end,
        },
      },
    },
    debugMode = {
      name = private.getLocalisation("debugMode"),
      desc = private.getLocalisation("debugModeDescription"),
      order = 30,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.debugMode = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .debugMode --Sets value of toggles depending on SavedVariables
      end,
    },
    disableLoginMessage = {
      name = private.getLocalisation("disableLoginMessage"),
      desc = private.getLocalisation("disableLoginMessageDescription"),
      order = 31,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.disableLoginMessage = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile.disableLoginMessage                             --Sets value of toggles depending on SavedVariables
      end,
    },
    disableReadyCheck = {
      name = private.getLocalisation("disableReadyCheck"),
      desc = private.getLocalisation("disableReadyCheckDescription"),
      order = 33,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.disableReadyCheck = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile.disableReadyCheck                             --Sets value of toggles depending on SavedVariables
      end,
    },
    disableBossModsBars = {
      name = private.getLocalisation("disableBossModsBars"),
      desc = private.getLocalisation("disableBossModsBarsDescription"),
      order = 34,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.disableBossModsBars = val
        if private.initDbmSkin then
          private.initDbmSkin()
        end
      end,                                            --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile.disableBossModsBars --Sets value of toggles depending on SavedVariables
      end,
    },
    disableBossModsEmphasisedBars = {
      name = private.getLocalisation("disableBossModsEmphasisedBars"),
      desc = private.getLocalisation("disableBossModsEmphasisedBarsDescription"),
      order = 35,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.disableBossModsEmphasisedBars = val
        if private.initDbmSkin then
          private.initDbmSkin()
        end
      end,                                                      --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile.disableBossModsEmphasisedBars --Sets value of toggles depending on SavedVariables
      end,
    },
    disableAllOnEncounterEnd = {
      name = private.getLocalisation("disableAllOnEncounterEnd"),
      desc = private.getLocalisation("disableAllOnEncounterEndDescription"),
      order = 35,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.disableAllOnEncounterEnd = val end,
      get = function(info)
        return private.db.profile.disableAllOnEncounterEnd
      end,
    },
    useAudioCountdowns = {
      name = private.getLocalisation("useAudioCountdowns"),
      desc = private.getLocalisation("useAudioCountdownsDescription"),
      order = 40,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.useAudioCountdowns = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .useAudioCountdowns --Sets value of toggles depending on SavedVariables
      end,
    },
    enableKeyRerollTimer = {
      name = private.getLocalisation("enableKeyRerollTimer"),
      desc = private.getLocalisation("enableKeyRerollTimerDescription"),
      order = 40,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.enableKeyRerollTimer = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .enableKeyRerollTimer --Sets value of toggles depending on SavedVariables
      end,
    },
    enableDNDMessage = {
      name = private.getLocalisation("enableDNDMessage"),
      desc = private.getLocalisation("enableDNDMessageDescription"),
      order = 40,
      width = "full",
      type = "toggle",
      set = function(info, val) private.db.profile.enableDNDMessage = val end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .enableDNDMessage --Sets value of toggles depending on SavedVariables
      end,
    },
    encounterOptions = {
      name = private.getLocalisation("reminderOptions"),
      desc = private.getLocalisation("reminderOptionsDescription"),
      type = "group",
      args = {

      },
    },

  }
}
OPTIONS_INITIALIZED = false
private.buildInstanceOptions = function()
  if OPTIONS_INITIALIZED then return end
  for dungeonId, dungeonValue in pairs(private.Instances) do
    EJ_SelectInstance(dungeonId)
    local Instancename, Instancedescription, _, InstanceImage, _, _, _, _, _ = EJ_GetInstanceInfo()
    private.options.args.encounterOptions.args["dungeon" .. dungeonId] = {
      name = Instancename,
      -- description = Instancedescription,
      -- image = InstanceImage,
      type = "group",
      order = dungeonId,
      args = {}
    }
    for encounterNumber, encounterID in pairs(dungeonValue.encounters) do
      local EncounterName, Encounterdescription, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID =
          EJ_GetEncounterInfoByIndex(encounterNumber, dungeonId)
      private.options.args.encounterOptions.args["dungeon" .. dungeonId].args["encounter" .. encounterNumber] = {
        name = EncounterName,
        -- description = Encounterdescription,
        -- image = InstanceImage,
        type = "group",
        order = encounterNumber,
        args = {
          OptionsButton = {
            name = private.getLocalisation("EditTimingsForEncounter") .. ": " .. EncounterName,
            type = "execute",
            order = 0,
            func = function()
              local params = {
                journalEncounterID = journalEncounterID,
                journalInstanceID = journalInstanceID,
                dungeonEncounterID =
                    dungeonEncounterID,
                name = EncounterName
              }
              private.openTimingsEditor(params)
            end
          },
        }
      }
    end
  end
  OPTIONS_INITIALIZED = true
end
