
--documentation: see the header of the file charts.lua


--1º example: making a simple chart with two lines, just copy and paste this code into a lua file and run it
do
    local ChartFrameTest = ChartFrameExample1 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample1")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0) --set the position of the chart
    ChartFrameTest:SetSize(800, 600) --set the size of the chart
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest) --apply a backdrop to this example hence see the frame size

    --add a line:
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24, 18, 17, 14, 15, 8, 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4, 8, 7, 4, 12, 12, 4}
    local smoothingMethod = "sma" --(optional, default: "sma")
    local smoothnessLevel = 3 --(optional, default: 1)
    local name = "Line 1" --(optional, default: none)
    local red, green, blue, alpha = 1, 1, 1, 1 --(optional, default: 1, 1, 1, 1)

    ChartFrameTest:AddData(data, smoothingMethod, smoothnessLevel, name, red, green, blue, alpha)

    --add another line:
    data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    smoothingMethod = "loess" --using a different smoothing method
    smoothnessLevel = 50
    name = "Line 2"
    local color = "red" --using a string with the color name
    ChartFrameTest:AddData(data, smoothingMethod, smoothnessLevel, name, color)

    --draw the chart
    ChartFrameTest:Plot()
end

--2º example: thickness and scale of the line:
do
    local ChartFrameTest = ChartFrameExample2 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample2")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0) --set the position of the chart
    ChartFrameTest:SetSize(800, 600) --set the size of the chart
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest) --apply a backdrop to this example hence see the frame size

    --add the data (required)
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4 ,8, 7 ,4, 12, 12 , 4}
    ChartFrameTest:AddData(data)

    --set the line thickness (optional, default: 2)
    local lineThickness = 3
    ChartFrameTest:SetLineThickness(lineThickness)

    --height modifier, if for some reason need to scale the chart height
    local heightScale = 1.2 --(optional, default: 1)
    --draw the chart
    ChartFrameTest:Plot(heightScale)
end

--3º example: setting the axes lines and labels
do
    local ChartFrameTest = ChartFrameExample3 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample3")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0)
    ChartFrameTest:SetSize(800, 600)
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest)

    --create guide lines in the left and bottom of the chart
    local xOffset = 48 --pixels from the left border of the chart
    local yOffset = 28 --pixels from the bottom border of the chart
    local whichSide = "left" --which side of vertical line should be placed
    local thickness = 1
    local amountYLabels = 10 --amounf of texts indicating the scale of the chart
    local amountXLabels = 10
    local r, g, b, a = 1, 1, 1, 1
    ChartFrameTest:CreateAxesLines(xOffset, yOffset, whichSide, thickness, amountYLabels, amountXLabels, r, g, b, a)

    --the labels in the bottom line can be 'time', 'number' or 'value'
    ChartFrameTest:SetXAxisDataType("time")
    --set the data to be used in the bottom line labels, how the data is formatted depends on the type set above
    ChartFrameTest:SetXAxisData(10) --with type 'time' the chart interprets this as seconds and shows 1:00 to 10:00

    ChartFrameTest:SetXAxisDataType("number")
    ChartFrameTest:SetXAxisData(600) --the chart interprets this as a 'number' type and displays it as 60, 120, 180.

    ChartFrameTest:SetXAxisDataType("value")
    ChartFrameTest:SetXAxisData("hello", "world", 1, 2, 3, 4, "chart", 0, 1, 0) --and 'value' show the values passed

    --setting the data, doesn't matter if it is set at the top or right before Plot()
    local data = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4 ,8, 7 ,4, 12, 12 , 4}
    ChartFrameTest:AddData(data)
    ChartFrameTest:Plot()
end

--4º example: a multi line chart is a chart which supports multiple lines, each line can have a different color, name, smoothnessLevel and thickness
do
    local ChartFrameTest = ChartFrameExample4 or DetailsFramework:CreateGraphicMultiLineFrame(UIParent, "ChartFrameExample4")
    ChartFrameTest:SetPoint("left", UIParent, "left", 10, 0)
    ChartFrameTest:SetSize(800, 600)
    DetailsFramework:ApplyStandardBackdrop(ChartFrameTest)

    --when using multi-line, the Reset() function instructs the chart to discard the previous data as new data is about to be added
    ChartFrameTest:Reset()

    --smoothnessLevel, name, red, green, blue, alpha
    local smoothnessLevel = 2 --(optional, default: 0)
    local line1Name, line2Name, line3Name = "Line 1", "Line 2", "Line 3" --show the line name at the top right corner (optional, default none)
    local line1Color, line2Color, line3Color = "lime", "purple", "orange" --(optional, default "white")

    --add data into the chart (it plots a line for each data added when :Plot() is called)
    local data1 = {1, 2, 30, 25, 6, 5, 4, 8, 7, 4, 1, 12, 15, 24 ,18, 17 ,14, 15, 8 , 4, 14, 42, 22, 25, 30, 35, 39, 8, 7, 4, 1, 2, 5, 4}
    ChartFrameTest:AddData(data1, smoothnessLevel, line1Name, line1Color)

    local data2 = {3, 5, 20, 25, 6, 5, 15, 18, 12, 14, 11, 8, 7, 8 ,7, 4 ,1, 25, 26 , 30, 28, 20, 22, 25, 20, 15, 10, 8, 7, 4, 1, 2, 5, 4}
    ChartFrameTest:AddData(data2, smoothnessLevel, line2Name, line2Color)

    local data3 = {5, 7, 15, 30, 6, 2, 10, 13, 10, 5, 11, 8, 7, 5, 3, 1, 1, 8, 10 , 12, 15, 20, 25, 25, 20, 17, 12, 7, 7, 6, 4, 5, 6, 5}
    ChartFrameTest:AddData(data3, smoothnessLevel, line3Name, line3Color)

    ChartFrameTest:Plot()
end