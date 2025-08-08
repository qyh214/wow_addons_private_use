
---@type details
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil

local activity = private.addon.activityTimeline

activity.markers = {}
activity.timeSections = {}
activity.maxEvents = 256

function activity.UpdateTimeSections(activityFrame, totalRuntime, multiplier)
    for i = 1, #activity.timeSections do
        activity.timeSections[i]:Hide()
    end

    if (not addon.profile.show_time_sections) then
        return
    end

    -- aim to have 4~6 section markers
    local length = 300
    local step = 300

    for _ = 1, 10 do
        local division = totalRuntime / length
        if (division < 4) then
            if (length > step) then
                length = length - step
            end
            break
        else
            length = length + step
        end
    end

    for i = 1, math.ceil(totalRuntime / length) do
        local section = activity.timeSections[i]
        if (not section) then
            section = addon.CreateTimeSection(activityFrame, i)
            activity.timeSections[i] = section
        end

        local time = (i - 1) * length

        section:Show()
        section:ClearAllPoints()
        section:SetPoint("topleft", activityFrame, "bottomleft", time * multiplier, 0)
        section:SetFrameLevel(5000 + i)
        section.TimeText:SetText(detailsFramework:IntegerToTimer(time))
    end
end

---boss widgets showing the kill time of each boss
---@param runData runinfo
function activity.UpdateBossWidgets(activityFrame, runData, multiplier)
    for i = 1, #activityFrame.bossWidgets do
        activityFrame.bossWidgets[i]:Hide()
    end

    local bossWidgetIndex = 1
    for i = 1, #runData.encounters do
        local encounter = runData.encounters[i]
        if (encounter.defeated) then
            local bossWidget = activityFrame.bossWidgets[bossWidgetIndex]
            if (not bossWidget) then
                bossWidget = addon.CreateBossPortraitTexture(activityFrame, bossWidgetIndex)
                activityFrame.bossWidgets[bossWidgetIndex] = bossWidget
            end
            bossWidgetIndex = bossWidgetIndex + 1

            local killTimeRelativeToStart = encounter.endTime - runData.startTime
            local xPosition = killTimeRelativeToStart * multiplier

            bossWidget:Show()
            bossWidget:ClearAllPoints()
            bossWidget:SetPoint("bottomright", activityFrame, "bottomleft", xPosition, 4)
            bossWidget:SetFrameLevel(5000 + i)

            bossWidget.TimeText:SetText(detailsFramework:IntegerToTimer(killTimeRelativeToStart))
            local encounterInfo = Details:GetEncounterInfo(encounter.dungeonEncounterId)
            if (encounterInfo and encounterInfo.creatureIcon) then
                bossWidget.EncounterInfo = encounterInfo
                bossWidget.EncounterData = encounter
                bossWidget.AvatarTexture:SetTexture(encounterInfo.creatureIcon)
                bossWidget.AvatarTexture:SetSize(64, 32)
                bossWidget.AvatarTexture:SetAlpha(1)
            else
                bossWidget.EncounterInfo = nil
                bossWidget.EncounterData = nil
                -- the following 3 lines and the SetSize/SetAlpha above can be removed when a proper fallback image is available
                bossWidget.AvatarTexture:SetAtlas("BossBanner-SkullCircle")
                bossWidget.AvatarTexture:SetSize(36, 36)
                bossWidget.AvatarTexture:SetAlpha(0.6)
            end
        end
    end
end

function activity.UpdateBloodlustWidgets(activityFrame, runData, multiplier)
    -- todo: implement into runData
end

--return a texture to be used as a segment of the activity bar
function activity.GetSegmentTexture(activityFrame)
    local currentIndex = activityFrame.nextTextureIndex
    activityFrame.nextTextureIndex = currentIndex + 1

    if (activityFrame.segmentTextures[currentIndex]) then
        return activityFrame.segmentTextures[currentIndex]
    end

    local texture = activityFrame:CreateTexture("$parentSegmentTexture" .. currentIndex, "artwork")
    texture:SetColorTexture(1, 1, 1, 0.5)
    texture:SetHeight(4)
    texture:ClearAllPoints()

    activityFrame.segmentTextures[currentIndex] = texture

    return texture
end

--reset the next index of texture to use and hide all existing textures
function activity.ResetSegmentTextures(activityFrame)
    activityFrame.nextTextureIndex = 1
    --iterate among all textures and hide them
    for i = 1, #activityFrame.segmentTextures do
        activityFrame.segmentTextures[i]:Hide()
    end
end

function activity.RenderDeathMarker(frame, event, marker, runData)
    local preferUp = false
    local playerPortrait = marker.SubFrames.playerPortrait
    ---@cast playerPortrait playerportrait
    if (not marker.SubFrames.playerPortrait) then
        --player portrait
        playerPortrait = Details:CreatePlayerPortrait(marker, "$parentPortrait")
        ---@cast playerPortrait playerportrait
        playerPortrait:ClearAllPoints()
        playerPortrait:SetPoint("center", marker, "center", 0, 0)
        local size = addon.templates.activityTimeline.deathMarker_Size
        playerPortrait.Portrait:SetSize(size, size)
        playerPortrait:SetSize(size, size)
        playerPortrait.RoleIcon:SetSize(size * addon.templates.activityTimeline.deathMarker_RoleIconScale, size * addon.templates.activityTimeline.deathMarker_RoleIconScale)
        playerPortrait.RoleIcon:ClearAllPoints()
        playerPortrait.RoleIcon:SetPoint("bottomleft", playerPortrait.Portrait, "bottomright", -9, -2)

        playerPortrait.Portrait:SetDesaturation(addon.templates.activityTimeline.deathMarker_PortraitDesaturation)
        playerPortrait.RoleIcon:SetDesaturation(addon.templates.activityTimeline.deathMarker_RoleIconDesaturation)

        marker.SubFrames.playerPortrait = playerPortrait
    end

    --tooltip showing the latest 3 spells to kill the player
    marker.OnEnter = function(self)
        self.originalFrameLevel = self:GetFrameLevel()
        self:SetFrameLevel(self.originalFrameLevel + 6000)

        ---@type playerinfo
        local playerInfo = event.arguments.playerData
        local deathReason = addon.GetPlayerDeathReason(runData, playerInfo.name, event.arguments.index)
        if (deathReason) then
            GameCooltip:Preset(2)

            local relativeTimestamp = math.floor(event.timestamp - runData.startTime)
            local classColor = RAID_CLASS_COLORS[playerInfo.class]
            GameCooltip:AddLine(addon.PreparePlayerName(playerInfo.name), detailsFramework:IntegerToTimer(relativeTimestamp), nil, classColor.r, classColor.g, classColor.b, 1, "darkorange")

            --get the class icon
            local left, right, top, bottom, classIcon = detailsFramework:GetClassTCoordsAndTexture(playerInfo.class)
            GameCooltip:AddIcon(classIcon, 1, 1, 18, 18, left, right, top, bottom)
            GameCooltip:AddIcon([[Interface\AddOns\Details\images\end_of_mplus.png]], 1, 2, 14, 14, 172/512, 235/512, 84/512, 150/512)

            GameCooltip:AddLine("")

            for i = #deathReason, 1, -1 do --first index is the spell that killed the player
                local thisDeathReason = deathReason[i]
                local spellName, _, spellIcon = Details.GetSpellInfo(thisDeathReason.spellId)
                GameCooltip:AddLine(i .. ". " .. spellName, Details:Format(thisDeathReason.totalDamage))
                GameCooltip:AddIcon(spellIcon, 1, 1, 18, 18, 0.1, 0.9, 0.1, 0.9)

                local side = nil
                local value = 100
                local useSpark = false

                if (i == 1) then
                    local statusBarColor = {0.5, 0.1, 0.1, 0.3}
                    Details:AddTooltipBackgroundStatusbar(side, value, useSpark, statusBarColor)
                    GameCooltip:AddIcon("poi-graveyard-neutral", 1, 2, 12, 16)
                else
                    local statusBarColor = {0.1, 0.1, 0.1, 0.2}
                    Details:AddTooltipBackgroundStatusbar(side, value, useSpark, statusBarColor)
                end
            end

            GameCooltip:SetOption("TextSize", Details.tooltip.fontsize)
            GameCooltip:SetOption("TextFont",  Details.tooltip.fontface)
            GameCooltip:SetOption("LeftPadding", -3)
            GameCooltip:SetOption("RightPadding", 2)
            GameCooltip:SetOption("LinePadding", -2)
            GameCooltip:SetOption("LineYOffset", 0)
            GameCooltip:SetOption("FixedWidth", addon.templates.activityTimeline.deathMarker_TooltipWidth)
            GameCooltip:SetOption("StatusBarTexture", Details.death_tooltip_texture)
            GameCooltip:SetOption("UseTrilinearRight", true) --cooltip version 31 /dump _G.GameCooltip2.version

            GameCooltip:SetOwner(self)
            GameCooltip:Show()
        end
    end

    marker.OnLeave = function (self)
        self:SetFrameLevel(self.originalFrameLevel)
        GameCooltip:Hide()
    end

    SetPortraitTexture(playerPortrait.Portrait, event.arguments.playerData.unitId)
    local portraitTexture = playerPortrait.Portrait:GetTexture()
    playerPortrait.Portrait:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
    if (not portraitTexture) then
        local class = event.arguments.playerData.class
        playerPortrait.Portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        playerPortrait.Portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
    end

    local role = event.arguments.playerData.role
    if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
        playerPortrait.RoleIcon:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize)
        playerPortrait.RoleIcon:Show()
    else
        playerPortrait.RoleIcon:Hide()
    end

    playerPortrait:SetFrameLevel(playerPortrait:GetParent():GetFrameLevel() - 2)
    playerPortrait:Show()
    playerPortrait.Portrait:Show()

    detailsFramework:SetFontSize(marker.TimestampLabel, 12)
    detailsFramework:SetFontColor(marker.TimestampLabel, 1, 0, 0)

    return {
        preferUp = preferUp,
        forceDirection = nil,
    }
end

function activity.RenderKeyFinishedMarker(frame, event, marker, runData)
    local icon = marker.SubFrames.icon
    if (not icon) then
        icon = marker:CreateTexture("$parentIcon", "artwork")
        marker.SubFrames.icon = icon
    end

    if (event.arguments.timeLostToDeaths and event.arguments.timeLostToDeaths > 0) then
        local formatted = detailsFramework:IntegerToTimer(event.timestamp - runData.startTime)
        marker.TimestampLabel:SetText(formatted .. " (+" .. detailsFramework:IntegerToTimer(event.arguments.timeLostToDeaths) .. ")")
    end

    detailsFramework:SetFontSize(marker.TimestampLabel, 12)
    if (event.arguments.onTime) then
        icon:SetAtlas("gficon-chest-evergreen-greatvault-collect")
        detailsFramework:SetFontColor(marker.TimestampLabel, 0.2, 0.8, 0.2)
    else
        icon:SetAtlas("gficon-chest-evergreen-greatvault-complete")
        detailsFramework:SetFontColor(marker.TimestampLabel, 0.8, 0.2, 0.2)
    end

    icon:SetSize(257*0.2, 226*0.2)
    icon:ClearAllPoints()
    icon:SetPoint("center", marker, "center", 0, 5)
    icon:Show()

    return {
        preferUp = nil,
        forceDirection = "up",
    }
end

function activity.PrepareEventFrames(frame, events)
    local i = 0
    local eventCount = #events
    local markerCount = #activity.markers
    local function iterator()
        i = i + 1
        if (i > eventCount or i > activity.maxEvents) then
            -- hide all other markers and frames
            if (i <= markerCount) then
                for j = i, markerCount do
                    activity.markers[j]:Hide()
                    for _, subFrame in pairs(activity.markers[j].SubFrames) do
                        subFrame:Hide()
                    end
                end
            end
            return
        end

        ---@type activitytimeline_marker
        local marker = activity.markers[i]
        if (not activity.markers[i]) then
            local frameLevel = 10 + 5 * i
            activity.markers[i] = CreateFrame("frame", "$parentEventMarker" .. i, frame, "BackdropTemplate")
            marker = activity.markers[i]
            marker:SetFrameLevel(frameLevel)
            marker.SubFrames = {} -- used to track sub frames that can then all be hidden
            marker:EnableMouse(true)
            marker:SetSize(32, 32)
            marker:SetScript("OnEnter", function (self)
                if (self.OnEnter) then
                    self.OnEnter(self)
                end
            end)
            marker:SetScript("OnLeave", function (self)
                if (self.OnLeave) then
                    self.OnLeave(self)
                end
            end)

            local timestampLabel = marker:CreateFontString("$parentTimestampLabel", "overlay", "GameFontNormal")
            timestampLabel:SetJustifyH("center")
            timestampLabel:Hide()
            marker.TimestampLabel = timestampLabel

            local timestampBackground = detailsFramework:CreateImage(marker, "", 30, 12, "artwork")
            timestampBackground:SetColorTexture(0, 0, 0, 0.4)
            timestampBackground:SetPoint("topleft", timestampLabel, "topleft", -2, 2)
            timestampBackground:SetPoint("bottomright", timestampLabel, "bottomright", 2, -2)
            timestampBackground:Hide()
            marker.TimestampBackground = timestampBackground

            local line = marker:CreateTexture("$parentMarkerLineTexture", "border")
            line:SetColorTexture(1, 1, 1, 0.5)
            line:SetWidth(1)
            marker.LineTexture = line
        end

        -- (re)set default mouseover behavior
        marker.OnEnter = function (self)
            self.originalFrameLevel = self:GetFrameLevel()
            self:SetFrameLevel(self.originalFrameLevel + 6000)
            self.TimestampLabel:Show()
            self.TimestampBackground:Show()
        end

        marker.OnLeave = function (self)
            self:SetFrameLevel(self.originalFrameLevel)
            self.TimestampLabel:Hide()
            self.TimestampBackground:Hide()
        end

        marker:ClearAllPoints()
        marker:Hide()
        for _, subFrame in pairs(marker.SubFrames) do
            subFrame:Hide()
        end

        return events[i], marker
    end

    return iterator
end
