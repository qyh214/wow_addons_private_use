---@diagnostic disable

local Preydator = _G.Preydator
local SlashCmdList = _G["SlashCmdList"]
if type(Preydator) ~= "table" then
    return
end

local EventRuntime = {}
Preydator:RegisterModule("EventRuntime", EventRuntime)

function EventRuntime:HandleEvent(event, arg1, arg2, ctx)
    if type(ctx) ~= "table" then
        return false
    end

    -- Taint safety: never propagate noisy widget payload args.
    -- UPDATE_UI_WIDGET args can carry secret-number values; addons should not
    -- read/forward them unless absolutely required.
    if event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS" then
        arg1, arg2 = nil, nil
    end

    local state = ctx.state
    local ui = ctx.ui

    if event == "ADDON_LOADED" and arg1 == ctx.addonName then
        if type(ctx.onAddonLoaded) == "function" then
            ctx.onAddonLoaded()
        end
        if type(ctx.ensureOptionsPanel) == "function" then
            ctx.ensureOptionsPanel()
        end
        if type(ctx.handleSlashCommand) == "function" and type(SlashCmdList) == "table" then
            SlashCmdList["PREYDATOR"] = ctx.handleSlashCommand
        end
        return true
    end

    -- Blizzard_UIWidgets is a delayed sub-addon. Gate the mixin suppression hook
    -- and first icon-visibility pass on its load so widget APIs are guaranteed present.
    if event == "ADDON_LOADED" and arg1 == "Blizzard_UIWidgets" then
        if type(ctx.onBlizzardWidgetsLoaded) == "function" then
            ctx.onBlizzardWidgetsLoaded()
        end
        return true
    end

    if event == "ADDON_LOADED" then
        return true
    end

    if event == "PLAYER_LOGIN"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "ZONE_CHANGED"
        or event == "ZONE_CHANGED_INDOORS"
        or event == "ZONE_CHANGED_NEW_AREA" then
        if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
            if event ~= "ZONE_CHANGED_NEW_AREA" or state.inPreyZone ~= true or state.confirmedPreyZoneMapID == nil then
                -- Hard reset on login/enter-world, or ZONE_CHANGED_NEW_AREA without a
                -- mixin-confirmed zone: mixin must re-fire before inPreyZone can be true.
                state.inPreyZone = nil
                state.confirmedPreyZoneMapID = nil
                state.zoneCacheDirty = true
            else
                -- ZONE_CHANGED_NEW_AREA fired while the mixin has confirmed the prey
                -- zone. WoW fires this event for sub-areas within the same outdoor zone
                -- (terrain sections, camps, etc.) even when the map ID has not changed.
                -- Treat it as a sub-area event and let the confirmedMapID latch in
                -- RefreshInPreyZoneStatus verify the player is still on the same map;
                -- that will clear inPreyZone if the map actually changed.
                state.zoneCacheDirty = true
            end
        elseif state.inPreyZone ~= true then
            -- Sub-zone change (ZONE_CHANGED / ZONE_CHANGED_INDOORS) while not yet
            -- confirmed: mark dirty so the check runs on next tick.
            state.zoneCacheDirty = true
        end
        -- Sub-zone changes while inPreyZone=true are intentionally ignored: moving
        -- within the same prey zone must not clear the mixin-confirmed status.
        if event == "PLAYER_ENTERING_WORLD" and ui.barFrame and type(ctx.applyBarSettings) == "function" then
            ctx.applyBarSettings()
        end
        if event == "PLAYER_ENTERING_WORLD" and type(ctx.applyAratorSilencing) == "function" then
            ctx.applyAratorSilencing()
        end
        if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN")
            and type(ctx.armQuestListenBurst) == "function" then
            -- Bootstrap a short listen window so login timing jitter on
            -- GetActivePreyQuest() cannot leave runtime events/polling idle.
            ctx.armQuestListenBurst()
        end
        if (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN") then
            local runtimeState = state or {}
            local existingToken = runtimeState.loginBootstrapToken
            if type(existingToken) ~= "number" then
                existingToken = 0
            end
            runtimeState.loginBootstrapToken = existingToken + 1
            local token = runtimeState.loginBootstrapToken

            local function RunBootstrapPass(applySettings)
                if token ~= runtimeState.loginBootstrapToken then
                    return
                end

                if type(ctx.ensureBar) == "function" then
                    ctx.ensureBar()
                end
                if applySettings == true and type(ctx.applyBarSettings) == "function" then
                    ctx.applyBarSettings()
                end
                if type(ctx.updatePreyState) == "function" then
                    ctx.updatePreyState()
                end
                if type(ctx.setPollingActive) == "function" and type(ctx.shouldUseActivePolling) == "function" then
                    ctx.setPollingActive(ctx.shouldUseActivePolling())
                end
            end

            -- Immediate pass first, then short delayed retries for login race windows.
            RunBootstrapPass(true)

            local timer = _G and _G.C_Timer
            if timer and type(timer.After) == "function" then
                for _, delay in ipairs({ 0.20, 0.75, 1.50, 3.00, 5.00 }) do
                    timer.After(delay, function()
                        RunBootstrapPass(false)
                    end)
                end
            end
        end
    end

    if event == "PLAYER_REGEN_ENABLED" and type(ctx.onPlayerRegenEnabled) == "function" then
        ctx.onPlayerRegenEnabled()
    end

    local isRestrictedInstance = type(ctx.isRestrictedInstanceForPreyBar) == "function"
        and ctx.isRestrictedInstanceForPreyBar() == true

    -- In restricted instance content, fail closed for runtime behavior.
    if isRestrictedInstance and event ~= "PLAYER_LOGIN" and event ~= "ADDON_LOADED" then
        if type(ctx.setPollingActive) == "function" then
            ctx.setPollingActive(false)
        end
        if type(ctx.updateBarDisplay) == "function" then
            ctx.updateBarDisplay()
        end
        return true
    end

    -- Gate module fanout for noisy UI widget events when no prey context exists.
    -- Keep this lazy so non-noisy events do not pay quest/cache costs.
    local isNoisyEvent = event == "UPDATE_UI_WIDGET" or event == "UPDATE_ALL_UI_WIDGETS"
    if event == "UPDATE_UI_WIDGET" and type(ctx.isRelevantWidgetUpdateEvent) == "function" then
        if ctx.isRelevantWidgetUpdateEvent(arg1, arg2) ~= true then
            return true
        end
    end

    local now
    local isPreySignalEvent = isNoisyEvent
        or event == "CHAT_MSG_SYSTEM"
        or event == "CHAT_MSG_MONSTER_SAY"
        or event == "CHAT_MSG_MONSTER_YELL"
        or event == "CHAT_MSG_MONSTER_EMOTE"
        or event == "RAID_BOSS_EMOTE"
        or event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW"
        or event == "QUEST_DETAIL"
        or event == "QUEST_ACCEPTED"
        or event == "QUEST_TURNED_IN"
        or event == "QUEST_REMOVED"

    if isNoisyEvent then
        now = type(ctx.getTime) == "function" and ctx.getTime() or 0
        local hasPreyContext = state.activeQuestID or (now < (state.killStageUntil or 0))
        local outOfZoneQuestIdle = type(ctx.isValidQuestID) == "function"
            and ctx.isValidQuestID(state.activeQuestID)
            and state.inPreyZone == false
            and not (now < (state.killStageUntil or 0))
            and not (now < (state.ambushAlertUntil or 0))
            and not (now < (state.bloodyCommandAlertUntil or 0))
        if (not isRestrictedInstance)
            and hasPreyContext
            and not outOfZoneQuestIdle
            and type(ctx.runModuleHook) == "function" then
            ctx.runModuleHook("OnEvent", event, arg1, arg2)
        end
    else
        if (not (isRestrictedInstance and isPreySignalEvent)) and type(ctx.runModuleHook) == "function" then
            ctx.runModuleHook("OnEvent", event, arg1, arg2)
        end
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        if (not isRestrictedInstance) and type(ctx.tryHandleEchoOfPredationNameplate) == "function" then
            ctx.tryHandleEchoOfPredationNameplate(arg1, event)
        end
        return true
    end

    if isRestrictedInstance and event ~= "PLAYER_LOGIN" then
        if type(ctx.setPollingActive) == "function" then
            ctx.setPollingActive(false)
        end
        if type(ctx.updateBarDisplay) == "function" then
            ctx.updateBarDisplay()
        end
        return true
    end

    if event == "PLAYER_LOGIN" then
        local custV2 = type(ctx.getCustomizationModule) == "function" and ctx.getCustomizationModule() or nil
        local barEnabled = true
        if custV2 and type(custV2.IsModuleEnabled) == "function" then
            barEnabled = custV2:IsModuleEnabled("bar") == true
        end
        if barEnabled then
            if type(ctx.ensureBar) == "function" then
                ctx.ensureBar()
            end
            if type(ctx.applyBarSettings) == "function" then
                ctx.applyBarSettings()
            end
            if type(ctx.updateBarDisplay) == "function" then
                ctx.updateBarDisplay()
            end
        end
        if type(ctx.updatePreyState) == "function" then
            ctx.updatePreyState()
        end
        if type(ctx.setPollingActive) == "function" and type(ctx.shouldUseActivePolling) == "function" then
            ctx.setPollingActive(ctx.shouldUseActivePolling())
        end
        return true
    end

    if event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL" or event == "CHAT_MSG_MONSTER_EMOTE" or event == "RAID_BOSS_EMOTE" then
        -- Alert modules (Core/Alerts.lua) own ambush and Bloody Command chat handling.
        return true
    end

    if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" or event == "QUEST_DETAIL" or event == "QUEST_ACCEPTED" then
        if type(ctx.armQuestListenBurst) == "function" then
            ctx.armQuestListenBurst()
        end
        if event == "QUEST_ACCEPTED" and type(ctx.onQuestAccepted) == "function" then
            ctx.onQuestAccepted(arg1)
        end
    end

    if event == "QUEST_TURNED_IN" and state.activeQuestID and arg1 == state.activeQuestID then
        -- Clear cached zone identity at turn-in boundary so next prey hunt
        -- always resolves a fresh map target.
        state.preyZoneName = nil
        state.preyZoneMapID = nil
        state.confirmedPreyZoneMapID = nil
        state.inPreyZone = nil
        state.zoneCacheDirty = true
        state.cachedActivePreyQuestID = nil
        state.cachedActivePreyQuestAt = 0

        state.killStageUntil = (type(ctx.getTime) == "function" and ctx.getTime() or 0) + 8
        state.progressState = ctx.preyProgressFinal
        state.progressPercent = 100
        if type(ctx.updateBarDisplay) == "function" then
            ctx.updateBarDisplay()
        end
        if type(ctx.setPollingActive) == "function" then
            ctx.setPollingActive(true)
        end
    end

    -- When a player dies and respawns before reaching Stage 4, the prey quest
    -- objective resets to 0.  The widget cache's anti-regression guard would
    -- normally keep the stale progressState, freezing the bar at the pre-death
    -- stage.  On PLAYER_ALIVE, clear the cache so the next UpdatePreyState pass
    -- reads the live (reset) widget state instead of the stale cached value.
    -- Stage 4 is exempt: at that point death no longer causes an objective reset.
    if event == "PLAYER_ALIVE" then
        if state.stage ~= nil and state.stage < 4 and type(ctx.clearPreyWidgetInfoCache) == "function" then
            ctx.clearPreyWidgetInfoCache()
        end
        if type(ctx.updatePreyState) == "function" then
            ctx.updatePreyState()
        end
        return true
    end

    if event == "QUEST_REMOVED" and state.activeQuestID and arg1 == state.activeQuestID then
        -- Abandon/removal boundary: clear prey-zone cache immediately.
        state.preyZoneName = nil
        state.preyZoneMapID = nil
        state.confirmedPreyZoneMapID = nil
        state.inPreyZone = nil
        state.zoneCacheDirty = true
        state.cachedActivePreyQuestID = nil
        state.cachedActivePreyQuestAt = 0
    end

    now = now or (type(ctx.getTime) == "function" and ctx.getTime() or 0)
    local livePreyQuestID = nil
    if type(ctx.getCurrentActivePreyQuestCached) == "function" then
        livePreyQuestID = ctx.getCurrentActivePreyQuestCached(isNoisyEvent and ctx.activePreyQuestCacheSeconds or 0)
    end

    if not (((state.killStageUntil or 0) > now)
        or ((state.ambushAlertUntil or 0) > now)
        or ((state.bloodyCommandAlertUntil or 0) > now)
        or ((state.questListenUntil or 0) > now)
        or (type(ctx.isValidQuestID) == "function" and ctx.isValidQuestID(state.activeQuestID))
        or (type(ctx.isValidQuestID) == "function" and ctx.isValidQuestID(livePreyQuestID))) then
        return true
    end

    if isNoisyEvent
        and type(ctx.isValidQuestID) == "function"
        and ctx.isValidQuestID(state.activeQuestID)
        and state.inPreyZone == false
        and not ((state.killStageUntil or 0) > now)
        and not ((state.ambushAlertUntil or 0) > now)
        and not ((state.bloodyCommandAlertUntil or 0) > now) then
        return true
    end

    if type(ctx.updatePreyState) == "function" then
        ctx.updatePreyState()
    end
    if type(ctx.setPollingActive) == "function" and type(ctx.shouldUseActivePolling) == "function" then
        ctx.setPollingActive(ctx.shouldUseActivePolling())
    end

    return true
end
