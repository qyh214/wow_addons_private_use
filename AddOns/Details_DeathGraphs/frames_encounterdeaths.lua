
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details_DeathGraphs")
local _

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local unpack = unpack
local wipe = table.wipe

local CONST_MAX_DEATH_EVENTS = 29
local CONST_MAX_DEATH_PLAYERS = 25
local CONST_MIN_HEALINGDONE_DEATHLOG = 100
local CONST_COORDS_NO_BORDER = {5/64, 59/64, 5/64, 59/64}
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

function advancedDeathLogs.mainFrame.BuildEncounterDeathsFrames() --called at the end of the frames.lua
    local adlObject = advancedDeathLogs.pluginObject
    local pluginFrame = advancedDeathLogs.mainFrame

    --pre create the current frame
    local currentFrame = CreateFrame("frame", "DeathGraphsCurrentFrameDeaths", pluginFrame, "BackdropTemplate")
    currentFrame:SetPoint("topleft", 10, -50)
    currentFrame:SetSize(800, 400)
    adlObject.currentFrame = currentFrame

    local MAX_SUMMARY_SPELLS =  5
    local BUTTON_TEXT_SIZE = 10
    local BUTTON_TEXT_COLOR = {.9, .9, .9, 1}
    local BUTTON_TEXT_HIGHLIGHT = "white"
    local BUTTON_TEXT_PRESSED = "orange"
    local BUTTON_BACKGROUND_COLOR = {.2, .2, .2, .75}
    local BUTTON_BACKGROUND_COLORHIGHLIGHT = {.5, .5, .5, .8}

    local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

    pluginFrame.CurrentDeathFrame = currentFrame

    local onSelectEncounter = function(_, _, index)
        currentFrame.Refresh(index)
    end

    local buildSegmentsMenu = function()
        local resultTable = {}
        local db = advancedDeathLogs.dataBase.deathsPerSegment

        for i, thisEncounterDeathInfo in ipairs(db) do
            table.insert(resultTable, {
                value = i,
                label = "#" .. i .. " " .. thisEncounterDeathInfo.bossname,
                onclick = onSelectEncounter,
                icon = thisEncounterDeathInfo.bossicon[5],
                iconsize = advancedDeathLogs.dropdownIconSize,
                texcoord = {
                    thisEncounterDeathInfo.bossicon[1],
                    thisEncounterDeathInfo.bossicon[2],
                    thisEncounterDeathInfo.bossicon[3],
                    thisEncounterDeathInfo.bossicon[4] - 0.01}
                })
        end

        return resultTable
    end

    local segmentsDropdown = detailsFramework:NewDropDown(currentFrame, nil, "$parentSegmentDropdown", "SegmentDropdown", advancedDeathLogs.dropdownWidth + 40, 20, buildSegmentsMenu, 1, options_dropdown_template)
    segmentsDropdown:SetPoint("topleft", currentFrame, "topleft", -7, 1)

    --create the player frame to host buttons
    local playerListFrame = CreateFrame("frame", "DeathGraphsCurrentFrameDeathsPlayerList", currentFrame, "BackdropTemplate")
    playerListFrame:SetPoint("topleft", currentFrame, "topleft", -11, -29)
    playerListFrame:SetSize(170, 516)

    --create the panel to show the death timeline
    local deathPanel = CreateFrame("frame", "DeathGraphsCurrentFrameDeathsDeathTimeline", currentFrame, "BackdropTemplate")
    deathPanel:SetPoint("topleft", playerListFrame, "topright", 2, -29)
    deathPanel:SetSize(750, 490)

    --colunms:
    local deathColumns = {}
    local summaryColumns = {}

    local column_OnEnter = function(self)
        --show the tooltip for this spell
        local spellid = self.spellid
        if (spellid) then
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            if (spellid == 1) then
                GameTooltip:SetSpellByID(6603)
            else
                GameTooltip:SetSpellByID(spellid)
            end
            GameTooltip:Show()
        end
        local r, g, b = self:GetBackdropColor()
        self:SetBackdropColor(r, g, b, 1)
    end

    local columnOnLeave = function(self)
        --hide the spell tooltip
        GameTooltip:Hide()
        --set back the backdrop alpha
        local r, g, b = self:GetBackdropColor()
        self:SetBackdropColor(r, g, b, self.backdropAlpha)
    end

    --create the lines for the death log
    for i = 1, CONST_MAX_DEATH_EVENTS do
        local columnFrame = CreateFrame("frame", nil, deathPanel, "BackdropTemplate")
        --time before death
        columnFrame.hitTime = detailsFramework:CreateLabel(columnFrame, "-10s", nil, "white", "GameFontHighlightSmall")

        --hit strength
        columnFrame.hitStrength = detailsFramework:CreateLabel(columnFrame, "100k", nil, "white", "GameFontHighlightSmall")

        --spell
        columnFrame.hitSpell = detailsFramework:CreateLabel(columnFrame, "[Melee]", nil, "white", "GameFontHighlightSmall")
        columnFrame.hitSpellIcon = detailsFramework:CreateImage(columnFrame, nil, 12, 12, "overlay")

        --source
        columnFrame.hitSource = detailsFramework:CreateLabel(columnFrame, "Sargeras", nil, "white", "GameFontHighlightSmall")

        --hp bar
        columnFrame.healthBarBackground = detailsFramework:CreateImage(columnFrame, nil, 150, 12, "artwork")
        columnFrame.healthBarBackground:SetColorTexture(0, 0, 0, 0.5)
        columnFrame.healthBar = detailsFramework:CreateImage(columnFrame, nil, 150, 12, "overlay")
        columnFrame.healthBar:SetColorTexture(.8, .8, .8, 0.7)

        --set points, height and script
        columnFrame:SetPoint("topleft", deathPanel, "topleft", 0,(i-1)*16*-1)
        columnFrame:SetPoint("topright", deathPanel, "topright", 0,(i-1)*16*-1)
        columnFrame:SetHeight(16)
        columnFrame:SetScript("OnEnter", column_OnEnter)
        columnFrame:SetScript("OnLeave", columnOnLeave)

        --set the point off all widgets
        columnFrame.hitTime:SetPoint("left", columnFrame, "left", 2, 0)
        columnFrame.hitStrength:SetPoint("left", columnFrame, "left", 100, 0)

        columnFrame.hitSpellIcon:SetPoint("left", columnFrame, "left", 176, 0)
        columnFrame.hitSpell:SetPoint("left", columnFrame, "left", 190, 0)

        columnFrame.hitSource:SetPoint("left", columnFrame, "left", 355, 0)

        columnFrame.healthBar:SetPoint("left", columnFrame, "left", 520, 0)
        columnFrame.healthBarBackground:SetPoint("left", columnFrame, "left", 520, 0)

        --column backdrop
        columnFrame:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})

        table.insert(deathColumns, columnFrame)

        columnFrame:Hide()
    end

    local summaryOnenter = function(self)
        --show the tooltip for this spell
        local spellid = self.spellid
        if (spellid) then
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            if (spellid == 1) then
                GameTooltip:SetSpellByID(6603)
            else
                GameTooltip:SetSpellByID(spellid)
            end
            GameTooltip:Show()
        end
        self:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLORHIGHLIGHT))
    end

    local summaryOnleave = function(self)
        GameTooltip:Hide()
        self:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLOR))
    end

    --create the summary blocks
    for i = 1, MAX_SUMMARY_SPELLS do
        local summaryFrame = CreateFrame("frame", nil, deathPanel, "BackdropTemplate")

        summaryFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
        summaryFrame:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLOR))

        --set points, height and script
        summaryFrame:SetPoint("bottomleft", deathPanel, "topleft",(i-1) * 142, 10)
        summaryFrame:SetWidth(140)
        summaryFrame:SetHeight(20)
        summaryFrame:SetScript("OnEnter", summaryOnenter)
        summaryFrame:SetScript("OnLeave", summaryOnleave)

        --create icon, spellname and amount widges
        summaryFrame.spellIcon = detailsFramework:CreateImage(summaryFrame, nil, 20, 20, "overlay")
        summaryFrame.spellName = detailsFramework:CreateLabel(summaryFrame, "place holder string", nil, "white", "GameFontHighlightSmall")
        summaryFrame.spellAmount = detailsFramework:CreateLabel(summaryFrame, "place holder string", nil, "white", "GameFontHighlightSmall")
        --set theirs points
        summaryFrame.spellIcon:SetPoint("left", summaryFrame, "left", 2, 0)
        summaryFrame.spellName:SetPoint("left",summaryFrame.spellIcon, "right", 2, 0)
        summaryFrame.spellAmount:SetPoint("left", summaryFrame.spellName, "right", 2, 0)

        --add to the container
        table.insert(summaryColumns, summaryFrame)
        summaryFrame:Hide()
    end

    local temp_summary_table = {}

    function deathPanel.ShowPlayerScaleByDamage(index)
        local encounter = currentFrame.current_encounter
        if (encounter) then
            local deaths = encounter.deaths
            local player = deaths[index]
            if (player) then
                local events = player.events
                local total_damage = 0
                local total_time = 0
                local max_health = player.maxhealth
                local time_death = player.time

                for _, event in ipairs(player.events) do
                    total_time = total_time +(event[4] - time_death)
                    total_damage = total_damage + event[3]
                end

                local damage_per_second = total_damage / total_time
                damage_per_second = math.floor(damage_per_second)

                return damage_per_second
            end
        end
    end

    --build the death events for the selected player
    function deathPanel.ShowPlayerDeath(index)
        deathPanel.HidePlayerDeathEvents()
        deathPanel.HideDeathEventsSummary()

        local encounter = currentFrame.current_encounter
        if (encounter) then
            local deaths = encounter.deaths
            local player = deaths[index]
            if (player) then
                local events = player.events

                --death parser
                local maxhealth = player.maxhealth
                local time = player.time or events[1][4]

                local added = 1
                local number_format_func = Details:GetCurrentToKFunction()
                --local NumOfEvents = min(#events, CONST_MAX_DEATH_EVENTS)

                wipe(temp_summary_table)
                --local eventIndex = min(#events - NumOfEvents) + 1

                local eventsToShow = {}
                for i = #events, 1, -1 do --~refresh

                    local ev = events[i]
                    local evType = ev and ev[1]

                    if (type(evType) == "boolean" and evType) then
                        --damage
                        table.insert(eventsToShow, {"damage", ev})

                    elseif (type(evType) == "boolean" and not evType) then
                        --healing
                        if (ev[3] > CONST_MIN_HEALINGDONE_DEATHLOG) then
                            table.insert(eventsToShow, {"healing", ev})
                        end

                    elseif (type(evType) == "number" and evType == 4) then
                        --debuff applied on the player
                        table.insert(eventsToShow, {"debuff", ev})
                    end
                end

                for i = CONST_MAX_DEATH_EVENTS+1, #eventsToShow do
                    table.remove(eventsToShow, CONST_MAX_DEATH_EVENTS+1)
                end

                local eventsList = Details.table.reverse(eventsToShow)

                for i = 1, #eventsList do
                    local t = eventsList[i]
                    local evtype_string = t[1]
                    local ev = t[2]

                    local column = deathColumns[i]

                    local spellid = ev[2] --spellid
                    local amount = ev[3] --amount healed or damaged
                    local clock = ev[4] --time
                    local healthPercent = ev[5] --health percent
                    local sourceName = ev[6] --source

                    column.hitTime.text = "-" .. string.format("%.1f", time - clock)

                    if (evtype_string == "damage") then
                        column.hitStrength.text = "-" .. number_format_func(_, amount)
                        column.hitStrength.textcolor = "white"
                        column.hitStrength.textsize = 11
                        column:SetBackdropColor(1, 0, 0, 1)
                        column.backdropAlpha = 0.7
                        column:SetAlpha(1)
                        temp_summary_table[spellid] = (temp_summary_table[spellid] or 0) + amount

                    elseif (evtype_string == "healing") then
                        column.hitStrength.text = "+" .. number_format_func(_, amount)
                        column.hitStrength.textcolor = {0.8, 1, 0.8, 0.9}
                        column.hitStrength.textsize = 10
                        column.backdropAlpha = 0.25
                        column:SetBackdropColor(.2, 1, .2, column.backdropAlpha)
                        column:SetAlpha(.75)

                    elseif (evtype_string == "debuff") then
                        column.hitStrength.text = "x" .. amount
                        column.hitStrength.textcolor = "silver"
                        column.hitStrength.textsize = 10
                        column:SetBackdropColor(.8, .2, .8, 1)
                        column.backdropAlpha = 0.7
                        column:SetAlpha(1)
                    end

                    --set the spellname with the link
                    local spelllink = adlObject:GetSpellLink(spellid)
                    local _, _, spellicon = adlObject.GetSpellInfo(spellid)
                    column.hitSpell.text = spelllink
                    column.hitSpellIcon.texture = spellicon
                    column.hitSpellIcon.texcoord = CONST_COORDS_NO_BORDER

                    --the source name
                    sourceName = detailsFramework:CleanUpName(sourceName)
                    column.hitSource.text = sourceName

                    --set the life statusbar
                    column.healthBar.width = healthPercent * 100 * 1.5

                    --set the spell id
                    column.spellid = spellid

                    column:Show()
                end

                --set the summary widgets
                local t = {}
                for spellid, amount in pairs(temp_summary_table) do
                    table.insert(t, {spellid, amount})
                end

                table.sort(t, Details.Sort2)

                for i = 1, math.min(#t, 5) do
                    --get the data from the table
                    local spellid, amount = unpack(t[i])
                    --get the summary widget
                    local summaryColumn = summaryColumns[i]
                    --get the icon and the spell name
                    local spellname, _, spellicon = adlObject.GetSpellInfo(spellid)
                    summaryColumn.spellName.text = spellname

                    for o = 1, 20 do
                        if (summaryColumn.spellName:GetStringWidth() > 80) then
                            spellname = string.sub(spellname, 1, #spellname-1)
                            summaryColumn.spellName.text = spellname
                        else
                            break
                        end
                    end

                    summaryColumn.spellName.text = summaryColumn.spellName.text .. ":"
                    summaryColumn.spellIcon.texture = spellicon
                    summaryColumn.spellIcon.texcoord = CONST_COORDS_NO_BORDER
                    --set the hit amount
                    summaryColumn.spellAmount.text = number_format_func(_, amount)
                    --show the widget
                    summaryColumn.spellid = spellid
                    summaryColumn:Show()
                end

                wipe(t)
            end
        end
    end

    --clear the death events and the summary widgets
    function deathPanel.HidePlayerDeathEvents()
        for index, column in ipairs(deathColumns) do
            column:Hide()
            column.spellid = nil
        end
    end

    function deathPanel.HideDeathEventsSummary()
        for index, column in ipairs(summaryColumns) do
            column:Hide()
            column.spellid = nil
        end
    end

    --hold all player buttons
    local playerButtons = {}

    --button on enter and on leave
    local buttonOnEnter = function(self, capsule)
        if (not currentFrame.locked_on_player) then
            deathPanel.ShowPlayerDeath(capsule.player_index)
        end
        --change the text color
        capsule.textcolor = BUTTON_TEXT_HIGHLIGHT
        self:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLORHIGHLIGHT))
    end

    local buttonOnLeave = function(self, capsule)
        if (not currentFrame.locked_on_player) then
            deathPanel.HidePlayerDeathEvents()
            deathPanel.HideDeathEventsSummary()
        end

        --change the text color
        if (not currentFrame.locked_on_player or currentFrame.locked_on_player ~= capsule.player_index) then
            capsule.textcolor = BUTTON_TEXT_COLOR
        else
            capsule.textcolor = BUTTON_TEXT_PRESSED
        end

        self:SetBackdropColor(unpack(BUTTON_BACKGROUND_COLOR))
    end

    --remove the orange color from a button
    function deathPanel.UnpressButton()
        local oldbutton = currentFrame.locked_on_player
        if (oldbutton) then
            oldbutton = playerButtons[oldbutton]
            if (oldbutton) then
                oldbutton.textcolor = BUTTON_TEXT_COLOR
            end
        end
    end

    --button is pressed
    local playerSelected = function(self, button, index)
        deathPanel.UnpressButton()

        if (not currentFrame.locked_on_player or currentFrame.locked_on_player ~= index) then
            currentFrame.locked_on_player = index
            deathPanel.ShowPlayerDeath(index)
        else
            currentFrame.locked_on_player = nil
        end
    end

    --create player selection buttons
    for i = 1, CONST_MAX_DEATH_PLAYERS do --~create
        local button = detailsFramework:CreateButton(playerListFrame, playerSelected, 140, 18, "", i, nil, nil, nil, nil, 1)
        button:SetPoint(5, (i-1) * 19 * -1)
        button.textcolor = BUTTON_TEXT_COLOR
        button.textsize = BUTTON_TEXT_SIZE

        --class icon
        local classIcon = detailsFramework:CreateImage(button, nil, 18, 18, "ARTWORK", nil, nil, nil, nil, nil, 1)
        local classIconBackground = detailsFramework:NewImage(button, nil, 14, 14, "border", nil, "iconBackground")
        classIconBackground:SetColorTexture(0.1, 0.1, 0.1, .93)
        classIconBackground:SetAllPoints(classIcon.widget)

        --label to show the time of death in the format mm:ss
        local timeText = detailsFramework:CreateLabel(button, "", 10, "white", nil, nil, nil, nil, nil, 1)

        --label to show the player name
        local playerNameText = detailsFramework:CreateLabel(button, "", 10, "white", nil, nil, nil, nil, nil, 1)

        --se the points of the widgets created above
        classIcon:SetPoint("left", button, "left", 0, 0)
        timeText:SetPoint("left", classIcon, "right", 3, 0)
        playerNameText:SetPoint("left", button, "left", 58, 0)

        button.classIcon = classIcon
        button.timeText = timeText
        button.playerNameText = playerNameText

        --on enter leave scripts
        button:SetHook("OnEnter", buttonOnEnter)
        button:SetHook("OnLeave",  buttonOnLeave)

        button:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
        button:SetBackdropColor(.3, .3, .3, .75)

        --add to the table
        table.insert(playerButtons, button)
    end

    --hide all player buttons
    function deathPanel.HideAllPlayerButtons()
        for i = 1, CONST_MAX_DEATH_PLAYERS do
            local button = playerButtons[i]
            button:Hide()
        end
    end

    local formatTime = function(v) return "" .. string.format("%02.f", math.floor(v/60)) .. ":" .. string.format("%02.f", v%60) end

    function playerListFrame.RefreshPlayers() --~refresh ~refreshplayers
        --hide all buttons
        deathPanel.HideAllPlayerButtons()

        --get all deaths
        local encounter = currentFrame.current_encounter
        local deaths = encounter.deaths

        --get the list of players of this segment and add them to the buttons
        for i = 1, math.min(CONST_MAX_DEATH_PLAYERS, #deaths) do
            local player = deaths[i]
            local button = playerButtons[i]

            local playerName = player.name
            playerName = detailsFramework:RemoveRealmName(playerName)

            local formattedTimeOfDeath = formatTime(player.timeofdeath)
            local color = RAID_CLASS_COLORS[player.class]

            if (color) then
                playerName = "|c" .. color.colorStr .. playerName .. "|r"
            end

            local _, l, r, t, b = adlObject:GetClassIcon(player.class)

            button.classIcon.texture = [[Interface\AddOns\Details\images\classes_small_alpha]]
            button.classIcon.texcoord = {l, r, t, b}
            button.timeText.text = formattedTimeOfDeath
            button.playerNameText.text = playerName
            button.timeText.textsize = 10
            button.playerNameText.textsize = 10

            button.player_index = i

            button:Show()
        end
    end

    function currentFrame.OnResetAllData()
        deathPanel.HidePlayerDeathEvents()
        deathPanel.HideDeathEventsSummary()
        deathPanel.HideAllPlayerButtons()
    end

    --refresh the panel
    function currentFrame.Refresh(index)
        deathPanel.UnpressButton()

        local encounter = advancedDeathLogs.dataBase.deathsPerSegment[index]
        if (encounter) then
            --encounter found
            currentFrame.current_encounter = encounter

            --refresh the list of players
            playerListFrame.RefreshPlayers()
            --clear the graphic(if any)
            deathPanel.HidePlayerDeathEvents()
            deathPanel.HideDeathEventsSummary()

            --clear player selection
            currentFrame.locked_on_player = nil
        else
            --encounter doesn't exist
            segmentsDropdown:Refresh()
        end
    end

    currentFrame:SetScript("OnShow", function(self)
        segmentsDropdown:Refresh()
        segmentsDropdown:Select(1, true)
        onSelectEncounter(_, _, 1)
    end)
end