
local addonId, addonTable = ...
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_ChartViewer")
local Details = Details

---@type detailsframework
local detailsFramework = DetailsFramework

local ChartViewer = addonTable.ChartViewer
local ChartViewerWindowFrame = ChartViewerWindowFrame
local IsInInstance = IsInInstance
ChartViewerWindowFrame:SetToplevel(true)

--using the new chart frames from the details framework
---@type df_chartmulti
local chartPanel = detailsFramework:CreateGraphicMultiLineFrame(ChartViewerWindowFrame, "ChartViewerWindowFrameChartFrame")
chartPanel.xAxisLabelsYOffset = -9
chartPanel:CreateAxesLines(48, 28, "left", 1, 10, 10, 1, 1, 1, 1)
chartPanel:SetXAxisDataType("time")

chartPanel:SetPoint("topleft", ChartViewerWindowFrame, "topleft", 2, -72)
chartPanel:SetPoint("bottomright", ChartViewerWindowFrame, "bottomright", -1, 20)

chartPanel:SetLineThickness(3)
--detailsFramework:ApplyStandardBackdrop(chartPanel)

--refresh the graphic
local colors = {
    {1, 1, 1}, {1, 1, .4}, {1, 0.9, 0.1}, {1, 0.5, 0.1}, {1, 0.1, 0.1}, {1, 0.1, 0.5}, {1, 0.1, 0.9}, {0.9, 0.4, 1}, {0.6, 0.7, 1}, {0.3, 0.9, 1},
    {0.1, 1, 0.9}, {0.1, 1, 0.5}, {0.1, 1, 0.1}, {0.4, 0.5, 0.5}, {0.7, 0.3, 0.3}, {1, 0.5, 1}, {0.8, 0.5, 0.8}, {0.9, 0.5, 0.8}, {1, 0.4, 0.8}, {0.4, 0.4, 0.8}
}

function ChartViewer:RefreshGraphic()
    local combatObject = Details:GetCombatFromBreakdownWindow()

    local currentTab = ChartViewer:TabGetCurrent()
    local captureName = currentTab.data
    local tabType = currentTab.segment_type
    local options = currentTab.options

    local segments_start_index = 1

    local elapsedTime = combatObject:GetCombatTime()
    local texture = currentTab.texture
    local data = {}
    local maxTime = 0
    local bossId = combatObject.is_boss and combatObject.is_boss.id

    local combatUniqueId = combatObject:GetCombatUID()
    local combatChartData = ChartViewerDB.chartData[combatUniqueId]

    --from the plugin Encounter Details
    if (captureName == "Raid Damage Done") then
        local EDDB = EncounterDetailsDB
        combatChartData = EDDB and EDDB.chartData and EDDB.chartData[combatUniqueId]
        tabType = 1
    end

    if (combatChartData) then
        if (captureName:find("MULTICHARTS~") and tabType == 1 and elapsedTime > 12) then --current
            local charts = {}
            for key in captureName:gsub("MULTICHARTS~", ""):gmatch("[^%~]+") do
                charts[key] = true
            end

            local i = 1
            for chartName, timeData in pairs(combatChartData) do
                if (charts[chartName] and timeData.max_value and timeData.max_value > 0) then
                    --mostrar
                    local color = colors[i] or colors[1]
                    if (options) then
                        if (options.colors and options.colors[chartName]) then
                            color = options.colors[chartName]
                        end
                    end

                    table.insert(data, {timeData, color, elapsedTime, chartName, texture})
                    if (elapsedTime > maxTime) then
                        maxTime = elapsedTime
                    end
                    i = i + 1
                end
            end

        elseif (captureName:find("PRESET_") and tabType == 1 and elapsedTime > 12) then --current
            local i = 1
            for name, chartData in pairs(combatChartData) do
                if (name:find(captureName) and chartData.max_value and chartData.max_value > 0) then
                    --show
                    local dataName = name:gsub((".*%~"), "")
                    dataName = dataName:gsub(("%-.*"), "")
                    table.insert(data, {chartData, colors[i] or colors[1], elapsedTime, dataName, texture})
                    if (elapsedTime > maxTime) then
                        maxTime = elapsedTime
                    end
                    i = i + 1
                end
            end

        elseif (tabType == 1 and elapsedTime > 12) then --current segment
            local chartData = combatChartData[captureName]
            if (chartData and chartData.max_value and chartData.max_value > 0) then
                table.insert(data, {chartData, {1, 1, 1}, elapsedTime, captureName, texture})
                if (elapsedTime > maxTime) then
                    maxTime = elapsedTime
                end
            end

        elseif (tabType == 2) then --last 5 segments
            local colorIndex = 1
            local bossIndex = 1

            for i = segments_start_index + 5, segments_start_index, -1 do
                local thisCombatObject = Details:GetCombat(i)
                if (thisCombatObject) then
                    local bBossValidated = true
                    if (bossId) then
                        if ((not thisCombatObject.is_boss) or (not thisCombatObject.is_boss.id) or (thisCombatObject.is_boss.id ~= bossId)) then
                            bBossValidated = false
                        end
                    end

                    local thisElapsedTime = thisCombatObject:GetCombatTime()
                    if (thisElapsedTime > 12 and bBossValidated) then
                        if (captureName:find("PRESET_")) then --current
                            for name, chartData in pairs(combatChartData) do
                                if (name:find(captureName) and chartData.max_value and chartData.max_value > 0) then
                                    local dataName
                                    if (bossIndex == 1) then
                                        dataName = name:gsub((".*%~"), "")
                                        bossIndex = bossIndex + 1
                                    else
                                        dataName = "segment #" .. bossIndex
                                        bossIndex = bossIndex + 1
                                    end

                                    table.insert(data, {chartData, colors[colorIndex] or colors[1], thisElapsedTime, dataName, texture})
                                    colorIndex = colorIndex + 1

                                    if (thisElapsedTime > maxTime) then
                                        maxTime = thisElapsedTime
                                    end
                                end
                            end
                        else
                            local chartData = combatChartData[captureName]
                            if (chartData and chartData.max_value and chartData.max_value > 0) then
                                local dataName
                                if (bossIndex == 1) then
                                    dataName = captureName
                                    bossIndex = bossIndex + 1
                                else
                                    dataName = "segment #" .. bossIndex
                                    bossIndex = bossIndex + 1
                                end

                                table.insert(data, {chartData, colors[colorIndex] or colors[1], thisElapsedTime, dataName, texture})
                                colorIndex = colorIndex + 1

                                if (thisElapsedTime > maxTime) then
                                    maxTime = thisElapsedTime
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    chartPanel:Reset()
    chartPanel:SetXAxisData(elapsedTime)

    if (#data > 0) then
        for index, chart in ipairs(data) do
            --get the tables and color
            local chartData = chart[1]
            local chartColor = chart[2]
            local lineName = chart[4]

            chartPanel:AddData(chartData, 3, lineName, chartColor)
        end

        ---@type number[]
        local bloodLustTimers = combatObject.bloodlust or {}
        for index, bloodlustCombatTime in ipairs(bloodLustTimers) do
            chartPanel:AddBackdropIndicator("Bloodlust #" .. index, bloodlustCombatTime, bloodlustCombatTime + 40, {0, 0, 1, 0.2})
        end

        chartPanel:Plot()
    end
end