
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local _

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local unpack = unpack
local getUnixTime = time

local CONST_TIMELINE_WIGHT = 905
local CONST_TIMELINE_HEIGHT = 505
local mode_buttons_height = 20
local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

local currentBossHash

function advancedDeathLogs.mainFrame.BuildTimelineFrames() --called at the end of the frames.lua
    local adlObject = advancedDeathLogs.pluginObject
    local pluginFrame = advancedDeathLogs.mainFrame

    local formatTime = function(v) return "" .. string.format("%02.f", math.floor(v / 60)) .. ":" .. string.format("%02.f", v % 60) end

    local timelineFrame = CreateFrame("frame", "ADLTimelineFrame", pluginFrame, "BackdropTemplate")
    timelineFrame:SetPoint("topleft", 10, -50)
    timelineFrame:SetSize(CONST_TIMELINE_WIGHT, CONST_TIMELINE_HEIGHT)
    pluginFrame.timelineFrame = timelineFrame

    --dropdown
    local OnSelectBossEncounter = function(_, _, type)
        --selected the segment
        timelineFrame.Refresh(type)
    end

    local buildBossMenu = function()
        --the table which will be returned
        local resultTable = {}
        local encounterInfo = advancedDeathLogs.dataBase.encounterInfo

        local segmentsTable = Details:GetCombatSegments()
        for segmentId = 1, #segmentsTable do
            ---@type combat
            local combatObject = segmentsTable[segmentId]
            local bossInfo = combatObject:GetBossInfo()

            if (bossInfo and combatObject.instance_type == "raid") then
                local encounterId, bossDiff = bossInfo.id, bossInfo.diff
                local thisEncounterInfo = encounterInfo[encounterId]
                local difficultyName = adlObject:GetDifficultyName(bossDiff)
                local bossHash = encounterId .. "-" .. bossDiff

                local dataEnemySpellCasts = advancedDeathLogs.dataBase.enemySpellCasts
                local bossTable = dataEnemySpellCasts[bossHash]

                if (bossTable and difficultyName and thisEncounterInfo) then
                    local encounterName = thisEncounterInfo.encounterName
                    local encounterIcon = thisEncounterInfo.bossIcon

                    table.insert(resultTable, {
                        value = bossHash,
                        label = encounterName .. " (" .. difficultyName .. ")",
                        onclick = OnSelectBossEncounter,
                        icon = encounterIcon,
                        iconsize = advancedDeathLogs.dropdownIconSize,
                        texcoord = advancedDeathLogs.dropdownIconCoords,
                    })
                end
            end
        end

        return resultTable
    end

    local segmentsDropdown = detailsFramework:NewDropDown(timelineFrame, nil, "$parentBossDropdown", "BossDropdown", advancedDeathLogs.dropdownWidth + 40, 20, buildBossMenu, 1, options_dropdown_template)
    segmentsDropdown:SetPoint("topleft", timelineFrame, "topleft", -7, 1)

    function segmentsDropdown:SelectLastEncounter()
        local currentCombat = Details:GetCurrentCombat()
        if (currentCombat) then
            if (currentCombat.is_boss) then
                --get the map index
                local mapID = currentCombat.is_boss.mapid
                --get the boss index within the raid
                local bossIndex = Details:GetBossIndex(mapID, currentCombat.is_boss.id, nil, currentCombat.is_boss.name)
                if (bossIndex) then
                    --get the EJID
                    local EJID = Details.EncounterInformation[mapID] and Details.EncounterInformation[mapID].encounter_ids[bossIndex]
                    if (EJID) then
                        --if the EJID exists build the hash
                        local bossDificulty = currentCombat.is_boss.diff
                        local hash = tostring(EJID) .. tostring(bossDificulty)
                        if (hash) then
                            segmentsDropdown:Select(hash)
                        end
                    end
                end
            end
        end
    end

    --graph frame:
    local graphFrame = CreateFrame("frame", "ADLTimelineFrame_graphFrame", timelineFrame, "BackdropTemplate")
    graphFrame.verticalDeathLines = {}
    graphFrame.Width = 738
    graphFrame.Height = 516
    graphFrame.LineHeight = 440 --how hight the death bars goes
    graphFrame.LineWidth = 900 --width of spellbars
    graphFrame.MaxSpellLines = 25 --max os spell lines, they auto resize the height according to the amount shown
    graphFrame.SpellBlockAlpha = 0.3 --the alpha of the little red spell blocks
    graphFrame.SpellLineBackground = {.5, .5, .5, .3} --spell line default color
    graphFrame.SpellLineBackgroundHighlight = {.5, .5, .5, .8} --color when hover over a spell line

    graphFrame:SetPoint("topleft", timelineFrame, "topleft", 170, 0)
    graphFrame:SetSize(graphFrame.Width, graphFrame.Height)
    graphFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
    graphFrame:SetBackdropColor(0, 0, 0, 0)

    --death lines
    local deathLinesFrame = CreateFrame("frame", "ADLTimelineFrame_deathLinesFrame", graphFrame, "BackdropTemplate")
    deathLinesFrame:SetFrameLevel(graphFrame:GetFrameLevel()+4)

    --spells lines
    local spellLinesFrame = CreateFrame("frame", "ADLTimelineFrame_spellLinesFrame", graphFrame, "BackdropTemplate")
    spellLinesFrame:SetPoint("topright", graphFrame, "topleft")
    spellLinesFrame:SetPoint("bottomright", graphFrame, "bottomleft")
    spellLinesFrame:SetWidth(160)
    spellLinesFrame:SetFrameLevel(graphFrame:GetFrameLevel()+1)

    --tutorial text
    local whiteLine = graphFrame:CreateTexture(nil, "overlay")
    whiteLine:SetColorTexture(1, 1, 1, .7)
    whiteLine:SetSize(6, 20)
    whiteLine:SetPoint("topleft", timelineFrame, "topleft", -5, -32)
    whiteLine:SetAlpha(0.6)

    local tutorialLabel1 = detailsFramework:CreateLabel(graphFrame)
    tutorialLabel1:SetPoint("left", whiteLine, "right", 4, 1)
    tutorialLabel1.text = "White vertical lines\nare occurences of deaths\nduring tries"
    tutorialLabel1.textsize = advancedDeathLogs.tutorialTextSize
    tutorialLabel1:SetAlpha(0.6)

    local redBlock = graphFrame:CreateTexture(nil, "overlay")
    redBlock:SetColorTexture(1, .2, .2, .7)
    redBlock:SetSize(6, 20)
    redBlock:SetPoint("topleft", whiteLine, "bottomleft", 0, -10)
    redBlock:SetAlpha(0.6)

    local tutorialLabel2 = detailsFramework:CreateLabel(graphFrame)
    tutorialLabel2:SetPoint("left", redBlock, "right", 4, 1)
    tutorialLabel2.text = "Red squares are occurences\nof enemy spells"
    tutorialLabel2.textsize = advancedDeathLogs.tutorialTextSize
    tutorialLabel2:SetAlpha(0.6)

    local y = -100
    graphFrame.SpellsLines = {}

    local spellLineOnEnter = function(self)
        --show the spell tooltip when hover over the line
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetSpellByID(self.spellid)
        self:SetBackdropColor(unpack(graphFrame.SpellLineBackgroundHighlight))
        GameTooltip:Show()
    end

    local spellLineOnLeave = function(self)
        self:SetBackdropColor(unpack(graphFrame.SpellLineBackground))
        GameTooltip:Hide()
    end

    --get a spell block for the giving line spell
    local getSpellBlock = function(self)
        --get an already existing block
        local block = self.SpellBlocks[self.NextSpellBlock]
        if (block) then
            self.NextSpellBlock = self.NextSpellBlock + 1
            return block
        end

        --create a new block
        block = self:CreateTexture(nil, "overlay")
        block:SetColorTexture(1, 0, 0, graphFrame.SpellBlockAlpha)
        self.SpellBlocks[self.NextSpellBlock] = block
        self.NextSpellBlock = self.NextSpellBlock + 1
        return block
    end

    local setSpellBlockPosition = function(self, block, time)
        local startTime = graphFrame.currentStartTime
        local endTime = graphFrame.currentEndTime

        --get the position
        time = time - startTime
        local pixelSize = graphFrame.pixelPerSecond
        local where = time * pixelSize

        --how large is the block
        local blockWidth = graphFrame.spellBlockWidth

        block:SetPoint("topleft", self, "topleft", 170 + where, 0)
        block:SetPoint("bottomright", self, "bottomleft", 170 + where + blockWidth, 0)
        block:Show()
    end

    --reset the spell block counter and hide all spell blocks
    local resetSpellBlocks = function(self)
        for i = 1, #self.SpellBlocks do
            self.SpellBlocks[i]:Hide()
        end
        self.icon.texture = ""
        self.label.text = ""
        self.NextSpellBlock = 1
    end

    --set the spell name and icon
    local texcoord = {5/64, 59/64, 5/64, 59/64}
    local setIconAndSpell = function(self)
        --spellid is a member .spellid
        local spellname, _, icon = adlObject.GetSpellInfo(self.spellid)
        self.icon.texture = icon
        self.icon.texcoord = texcoord
        self.label.text = spellname
    end

    function graphFrame.ResetAllSpellLines()
        for i = 1, #graphFrame.SpellsLines do
            local line = graphFrame.SpellsLines[i]
            line:ResetSpell()
            line:Hide()
        end
    end

    --create the spell labels on the left side of the frame
    for i = 1, graphFrame.MaxSpellLines do
        local line = CreateFrame("frame", nil, spellLinesFrame, "BackdropTemplate")
        line:SetSize(graphFrame.LineWidth, 25)

        line:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
        line:SetBackdropColor(unpack(graphFrame.SpellLineBackground))

        line:SetScript("OnEnter", spellLineOnEnter)
        line:SetScript("OnLeave", spellLineOnLeave)

        line.ResetSpell = resetSpellBlocks
        line.GetSpellBlock = getSpellBlock
        line.SetIconAndSpellName = setIconAndSpell
        line.SetSpellBlockPositionInTime = setSpellBlockPosition

        line.NextSpellBlock = 1
        line.spellid = 1
        line.SpellBlocks = {}

        local label = detailsFramework:CreateLabel(line)
        local icon = detailsFramework:CreateImage(line, nil, 22, 22)
        icon:SetPoint("left", line, "left", 2, 0)
        label:SetPoint("left", icon, "right", 2, 0)
        line.icon = icon
        line.label = label

        line:Hide()
        table.insert(graphFrame.SpellsLines, line)
    end

    --time line
    local timeLineFrame = CreateFrame("frame", nil, graphFrame, "BackdropTemplate")
    timeLineFrame:SetPoint("bottomleft", pluginFrame, "bottomleft", 165, 21)
    timeLineFrame:SetPoint("bottomright", pluginFrame, "bottomright", 0, 21)
    timeLineFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
    timeLineFrame:SetBackdropColor(0, 0, 0, .4)
    timeLineFrame:SetHeight(20)

    local totalTimeLineWidth = timeLineFrame:GetWidth()
    local spaceBetweenLabels = totalTimeLineWidth / 16 --16 amount of labels in the time line

    --build timeline labels
    timeLineFrame.Labels = {}
    timeLineFrame.xOffset = 0

    for i = 1, 16 do
        local label = detailsFramework:CreateLabel(timeLineFrame)
        label.fontsize = 10
        label.fontcolor = "white"
        label.alpha = 0.834
        table.insert(timeLineFrame.Labels, label)
        label:SetPoint("bottomleft", timeLineFrame, "bottomleft", timeLineFrame.xOffset + (i-1) * spaceBetweenLabels, 4)
        label.text = "00:00"

        local littleVerticalLine = graphFrame:CreateTexture(nil, "overlay")
        if (i == 1) then
            littleVerticalLine:SetSize(1, graphFrame:GetHeight() + 12)
            littleVerticalLine:SetColorTexture(.2, .2, .2, 0.634)
            littleVerticalLine:SetPoint("bottomleft", label.widget, "bottomleft", -2, -4)
        else
            littleVerticalLine:SetSize(1, 22)
            littleVerticalLine:SetColorTexture(1, 1, 1, 0.1)
            littleVerticalLine:SetPoint("bottomleft", label.widget, "bottomleft", -2, -4)
        end
    end

    --cut off events by time
    local OnSelectTimeCutOff = function(_, _, time)
        adlObject.db.timeline_cutoff_time = time
        if (timelineFrame.LastBoss) then
            timelineFrame.Refresh(timelineFrame.LastBoss)
        end
    end

    local timeCutOffMenu = {
        {value = 1, label = "Last 30 Minutes", onclick = OnSelectTimeCutOff},
        {value = 2, label = "Last 1 Hours", onclick = OnSelectTimeCutOff},
        {value = 3, label = "Last 2 Hours", onclick = OnSelectTimeCutOff},
        {value = 4, label = "Last 3 Hours", onclick = OnSelectTimeCutOff},
        {value = 5, label = "Last 4 Hours", onclick = OnSelectTimeCutOff},
        {value = 6, label = "Last 5 Hours", onclick = OnSelectTimeCutOff},
        {value = 7, label = "Everything", onclick = OnSelectTimeCutOff},
    }

    local buildEventsByTimeMenu = function()
        return timeCutOffMenu
    end

    local eventsByTimeLabel = detailsFramework:NewLabel(deathLinesFrame, nil, "$parentEventsByTimeLabel", nil, "Time Sample:", "GameFontNormal")
    eventsByTimeLabel:SetPoint("left", segmentsDropdown, "right", 35, 0)
    eventsByTimeLabel.textsize = advancedDeathLogs.defaultTextSize

    local eventsByTimeDropdown = detailsFramework:NewDropDown(deathLinesFrame, nil, "$parentEventsByTimeDropdown", "EventsByTimeDropdown", 150, 20, buildEventsByTimeMenu, 1, options_dropdown_template)
    eventsByTimeDropdown:SetPoint("left", eventsByTimeLabel, "right", 2, 0)

    --set the default value from the database
    eventsByTimeDropdown:Select(adlObject.db.timeline_cutoff_time, true)

    --erase events by time
    local OnSelectEraseTimeCutOff = function(_, _, time)
        adlObject.db.timeline_cutoff_delete_time = time
    end

    local eraseTimeCutOffMenu = {
        {value = 1, label = "Older Than 30 Minutes", onclick = OnSelectEraseTimeCutOff},
        {value = 2, label = "Older Than 1 Hours", onclick = OnSelectEraseTimeCutOff},
        {value = 3, label = "Older Than 2 Hour", onclick = OnSelectEraseTimeCutOff},
        {value = 4, label = "Older Than 3 Hour", onclick = OnSelectEraseTimeCutOff},
        {value = 5, label = "Older Than 4 Hour", onclick = OnSelectEraseTimeCutOff},
        {value = 6, label = "Older Than 5 Hour", onclick = OnSelectEraseTimeCutOff},
        {value = 7, label = "Everything", onclick = OnSelectEraseTimeCutOff},
    }

    local buildEraseEventsByTimeMenu = function()
        return eraseTimeCutOffMenu
    end

    local eraseByTime = function()
        timelineFrame.EraseByTime(adlObject.db.timeline_cutoff_delete_time)
    end

    local confirmEraseButton = detailsFramework:NewButton(timelineFrame, _, "$parentEraseEventsByTimeButton", "EraseEventsByTimeButton", 70, mode_buttons_height, eraseByTime, nil, nil, nil, "Erase", 1, detailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
    confirmEraseButton:SetPoint("topright", pluginFrame.ResetButton, "bottomright", 0, -3)

    local eraseEventsByTimeDropdown = detailsFramework:NewDropDown(deathLinesFrame, nil, "$parentErase_EventsByTimeDropdown", "Erase_EventsByTimeDropdown", 170, 20, buildEraseEventsByTimeMenu, 1, options_dropdown_template)
    eraseEventsByTimeDropdown:SetPoint("right", confirmEraseButton, "left", -2, 0)

    local eraseEventsByTimeLabel = detailsFramework:NewLabel(deathLinesFrame, nil, "$parentErase_EventsByTimeLabel", nil, "Erase Samples:", "GameFontNormal")
    eraseEventsByTimeLabel:SetPoint("right", eraseEventsByTimeDropdown, "left", -2, 0)
    eraseEventsByTimeLabel.textsize = advancedDeathLogs.defaultTextSize

    --set the default value
    eraseEventsByTimeDropdown:Select(adlObject.db.timeline_cutoff_delete_time, true)

    function timeLineFrame.ResetTimeline()
        for i = 1, #timeLineFrame.Labels do
            local label = timeLineFrame.Labels[i]
            label.text = "00:00"
        end

        for i = 1, #graphFrame.verticalDeathLines do
            local line = graphFrame.verticalDeathLines[i]
            line:Hide()
        end
    end

    --update the bottom time elapsed timeline
    function timeLineFrame.UpdateTimers(length)
        if (length <= 0) then
            timeLineFrame.ResetTimeline()
            return
        end

        local timelineStartTime = math.floor(graphFrame.currentStartTime)
        local timelineEndTime = math.floor(graphFrame.currentEndTime)

        local totalTime = timelineEndTime - timelineStartTime
        local interval = totalTime / #timeLineFrame.Labels

        local firstLabel = timeLineFrame.Labels[1]
        firstLabel.text = formatTime(timelineStartTime)
        local lastLabel = timeLineFrame.Labels[#timeLineFrame.Labels]
        lastLabel.text = formatTime(timelineEndTime - math.floor(interval))

        for i = 2, #timeLineFrame.Labels-1 do
            local thisTime = math.floor(interval * (i-1) + timelineStartTime)
            local label = timeLineFrame.Labels[i]
            label.text = formatTime(thisTime)
        end
    end

    --update the graphic lines to fit in the time of the encounter
    function graphFrame.SetTimePeriod()

    end

    --get the time to filter events
    function timelineFrame.GetTimeToCutOff(cutoff_override)
        local now = getUnixTime()
        local time_cutoff = cutoff_override or adlObject.db.timeline_cutoff_time
        local cutoff

        if (time_cutoff == 1) then --30m
            cutoff = now - 1800
        elseif (time_cutoff == 2) then --1h
            cutoff = now - 3600
        elseif (time_cutoff == 3) then --2h
            cutoff = now - (3600 * 2)
        elseif (time_cutoff == 4) then --3h
            cutoff = now - (3600 * 3)
        elseif (time_cutoff == 5) then --4h
            cutoff = now - (3600 * 4)
        elseif (time_cutoff == 6) then --5h
            cutoff = now - (3600 * 5)
        elseif (time_cutoff == 7) then --everything
            cutoff = 0
        end

        return cutoff
    end

    function timelineFrame.EraseByTime(t)
        if (currentBossHash) then
            local cutoffTime = timelineFrame.GetTimeToCutOff(t)
            if (t == 7) then
                cutoffTime = getUnixTime()
            end

            for second, deaths in pairs(advancedDeathLogs.dataBase.deathsOccurrences[currentBossHash]) do
                for i = #deaths, 1, -1 do
                    local deathTime = deaths[i]
                    if (deathTime < cutoffTime) then
                        table.remove(deaths, i)
                    end
                end
            end

            if (timelineFrame.LastBoss) then
                timelineFrame.Refresh(timelineFrame.LastBoss)
            end
        end
    end

    --build the graphic
    function timelineFrame.BuildGraph(bossHash)
        local enemyCasts = advancedDeathLogs.dataBase.enemySpellCasts[bossHash]
        local dataSpellIds = advancedDeathLogs.dataBase.spellIdCache
        local dataDeathLogs = advancedDeathLogs.dataBase.deathsOccurrences[bossHash]
        currentBossHash = bossHash

        local startTime, endTime = 9999, 0
        local highestDeathStack = 0

        local cutoffTime = timelineFrame.GetTimeToCutOff()

        --get the start and end time
        for second, deaths in pairs(dataDeathLogs) do
            local validStackOfDeaths = 0
            for i, deathTime in ipairs(deaths) do
                if (deathTime > cutoffTime) then
                    validStackOfDeaths = validStackOfDeaths + 1
                end
            end

            if (validStackOfDeaths > 0) then
                --check if the time of this death is lower than all other deaths
                if (second < startTime) then
                    startTime = second
                end

                --check if the time of this death is higher than all other deaths
                if (second > endTime) then
                    endTime = second
                end

                --check if this 'second' has more deaths
                local deathStack = validStackOfDeaths
                if (highestDeathStack < deathStack) then
                    highestDeathStack = deathStack
                end
            end
        end

        --startTimeDiff is the size of the space added before startTime, saving this value to be able to get the line of the death second.
        local startTimeDiff
        if (startTime > 20) then
            startTime = startTime - 20
            startTimeDiff = 20
        else
            startTimeDiff = startTime - 1
            startTime = 1
        end

        --add a little of space after the last death
        endTime = endTime + 20

        --save the start and end time state inte the graph
        graphFrame.currentStartTime = startTime
        graphFrame.currentStartTimeDiff = startTimeDiff
        graphFrame.currentEndTime = endTime

        local length = endTime - startTime
        --update the bottom time elapsed bar (timeline)
        timeLineFrame.UpdateTimers(length)
        local timePeriod = math.floor(length)
        graphFrame.timePeriod = timePeriod

        --calculate how much in time value one pixel
        graphFrame.pixelPerSecond = timeLineFrame:GetWidth() / timePeriod
        local pixelPerSecond = graphFrame.pixelPerSecond

        --calculate the width of each spell block
        local spellBlockWidth = timeLineFrame:GetWidth() / timePeriod * 3.5
        graphFrame.spellBlockWidth = spellBlockWidth

        --build the spells and set them into the spells frame
        local spellFrameIndex = 1
        graphFrame.ResetAllSpellLines()

        for spellName, indexSpellTable in pairs(enemyCasts) do
            --get the next available spellLine
            local spellId = dataSpellIds[spellName]
            local spellLine = graphFrame.SpellsLines[spellFrameIndex]

            --set the spellid for internal functions
            spellLine.spellid = spellId

            --hide all block, clear name and icon
            spellLine:ResetSpell()

            --set the name and icon from the spellLine.spellid
            spellLine:SetIconAndSpellName()

            --show the spell block timers in the line
            for index, spellTable in ipairs(indexSpellTable) do
                local combatTime, time = unpack(spellTable)
                if (time > cutoffTime) then
                    --cut off all spells casted before the first death and after the last death
                    if (combatTime >= startTime and combatTime <= endTime-10) then
                        --get the next available block
                        local spellBlock = spellLine:GetSpellBlock()
                        --set it's position in the graph
                        spellLine:SetSpellBlockPositionInTime(spellBlock, combatTime)
                    end
                end
            end

            spellLine:Show()

            --limit the shown spells in - graphFrame.MaxSpellLines(default 20)
            spellFrameIndex = spellFrameIndex + 1
            if (spellFrameIndex > graphFrame.MaxSpellLines) then
                break
            end
        end

        --total of spell lines shown is
        local totalOfSpellLinesShown = spellFrameIndex - 1

        local spellLinesY = -22
        local lineHeight = 17

        --build the spellLines height
        for i = 1, totalOfSpellLinesShown do
            local spellLine = graphFrame.SpellsLines[i]
            spellLine:SetPoint("bottomleft", timelineFrame, "bottomleft", -9, spellLinesY)
            spellLine:SetPoint("bottomright", timelineFrame, "bottomright", 9, spellLinesY)
            spellLine:SetHeight(lineHeight)
            spellLine.icon:SetSize(lineHeight, lineHeight)
            spellLinesY = spellLinesY + lineHeight + 1
        end

        local verticalDeathLineIndex = 1

        local getOrCreateVerticalDeathLineIndicator = function(verticalDeathLineIndex)
            if (graphFrame.verticalDeathLines[verticalDeathLineIndex]) then
                return graphFrame.verticalDeathLines[verticalDeathLineIndex]
            end

            local newLine = deathLinesFrame:CreateTexture(nil, "overlay")
            newLine:SetColorTexture(.7, .7, .7, 0.834)
            graphFrame.verticalDeathLines[#graphFrame.verticalDeathLines + 1] = newLine
            return newLine
        end

        --build the death lines height
        for second, deaths in pairs(dataDeathLogs) do
            ---@cast second number
            ---@cast deaths unixtime[]

            local verticalLineDeathIndicatorTexture =  getOrCreateVerticalDeathLineIndicator(verticalDeathLineIndex)
            verticalDeathLineIndex = verticalDeathLineIndex + 1

            verticalLineDeathIndicatorTexture:ClearAllPoints()
            verticalLineDeathIndicatorTexture:SetPoint("bottomleft", timeLineFrame, "bottomleft", (second - startTime) * pixelPerSecond, 22)
            verticalLineDeathIndicatorTexture:SetWidth(2)
            verticalLineDeathIndicatorTexture:Show(2)

            local amountOfDeathsInthisSecond = 0
            for i, deathTime in ipairs(deaths) do
                if (deathTime > cutoffTime) then
                    amountOfDeathsInthisSecond = amountOfDeathsInthisSecond + 1
                end
            end

            if (amountOfDeathsInthisSecond > 0) then
                --percent comparent within the highest deaths on a single second
                local percent = amountOfDeathsInthisSecond / highestDeathStack
                --set the line height
                verticalLineDeathIndicatorTexture:SetHeight(graphFrame.LineHeight * percent)
                verticalLineDeathIndicatorTexture:Show()
            end
        end
    end

    function timelineFrame.OnResetAllData()
        graphFrame.ResetAllSpellLines()
        timeLineFrame.ResetTimeline()
    end

    --refresh the main frame:
    function timelineFrame.Refresh(bossHash)
        local dataEnemySpellCasts = advancedDeathLogs.dataBase.enemySpellCasts
        local bossTable = dataEnemySpellCasts[bossHash]

        if (bossTable) then
            timelineFrame.LastBoss = bossHash
            timelineFrame.BuildGraph(bossHash)
        end
    end

    --OnShow Timeline - refresh the dropdown and show the first boss // should be show the last boss
    timelineFrame:SetScript("OnShow", function(self)
        segmentsDropdown:Refresh()

        segmentsDropdown:Select(1, true)
        segmentsDropdown:SelectLastEncounter()

        local currentValue = segmentsDropdown:GetValue()

        if (type(currentValue) == "string") then
            OnSelectBossEncounter(_, _, currentValue)
        end
    end)
end