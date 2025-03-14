local CraftScan = select(2, ...)

local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local plot                    = nil;
local canvas                  = CreateFrame("Frame");
local texturePool             = {}
local priorZoom               = {}

local SECONDS_PER_DAY         = 24 * 3600;
local WIDTH                   = 600;
local HEIGHT                  = 200;
local X_LABELS_W              = 50;
local Y_LABELS_H              = 50;
local X_LEGEND_W              = 150;

local PLOT_MIN_X              = X_LABELS_W;
local PLOT_MAX_X              = X_LABELS_W + WIDTH;
local PLOT_MIN_Y              = Y_LABELS_H;
local PLOT_MAX_Y              = Y_LABELS_H + HEIGHT;

local PLOT_X_LABEL_WIDTH      = 48
local PLOT_MIN_X_LINE_SPACING = PLOT_X_LABEL_WIDTH * 1.5 + 8

local function AcquireTexture(tracker)
    local texture;
    if #texturePool > 0 then
        texture = table.remove(texturePool)
        texture:ClearAllPoints();
        texture:SetVertexColor(1, 1, 1, 1)
        texture:Show();
    else
        texture = canvas:CreateTexture(nil, "BACKGROUND")
    end

    tracker.textures = tracker.textures or {};
    table.insert(tracker.textures, texture);

    return texture
end

local function ReleaseTextures(tracker)
    if tracker.textures then
        for _, texture in ipairs(tracker.textures) do
            texture:Hide()
            table.insert(texturePool, texture)
        end
        tracker.textures = nil;
    end
end

local textPool = {}

local function AcquireText(tracker)
    local text;
    if #textPool > 0 then
        text = table.remove(textPool)
        text:SetFontObject("GameFontHighlight");
        text:SetJustifyH("CENTER");
        text:ClearAllPoints();
        text:SetRotation(0)
        text:EnableMouse(false);
        text:SetScript("OnMouseUp", nil);
        text:SetVertexColor(1, 1, 1, 1)
        text:Show();
    else
        text = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
    end

    tracker.texts = tracker.texts or {};
    table.insert(tracker.texts, text);

    return text;
end

local function ReleaseTexts(tracker)
    if tracker.texts then
        for _, text in ipairs(tracker.texts) do
            text:Hide()
            table.insert(textPool, text)
        end
        tracker.texts = nil;
    end
end

-- The TSM axis label handling is very nice, so after my initial sloppy attempt,
-- hoisting the key bits.
local function Scale(value, fromStart, fromEnd, toStart, toEnd)
    assert(value >= min(fromStart, fromEnd) and value <= max(fromStart, fromEnd))
    return toStart + ((value - fromStart) / (fromEnd - fromStart)) * (toEnd - toStart)
end

local function GraphXStepFunc(prevValue, suggestedStep)
    local year, day, month, hour, min, sec = strsplit(",", date("%Y,%d,%m,%H,%M,%S", prevValue))
    local time_ = {};
    time_.year = tonumber(year)
    time_.day = tonumber(day)
    time_.month = tonumber(month)
    time_.hour = tonumber(hour)
    time_.min = tonumber(min)
    time_.sec = tonumber(sec)
    if suggestedStep > SECONDS_PER_DAY * 14 then
        time_.month = time_.month + 1
        time_.day = 1
        time_.hour = 0
        time_.min = 0
        time_.sec = 0
    elseif suggestedStep > SECONDS_PER_DAY / 6 then
        time_.day = time_.day + 1
        if time_.hour == 23 then
            -- add an extra hour to avoid DST issues
            time_.hour = 1
        else
            time_.hour = 0
        end
        time_.min = 0
        time_.sec = 0
    else
        time_.hour = time_.hour + 2
        time_.min = 0
        time_.sec = 0
    end
    local newValue = time(time_)
    assert(newValue > prevValue)
    return newValue
end

local function GraphFormatX(timestamp, suggestedStep)
    if suggestedStep > SECONDS_PER_DAY * 14 then
        return date("%b '%y", timestamp)
    elseif suggestedStep > SECONDS_PER_DAY * 2 then
        return date("%b %d", timestamp)
    elseif suggestedStep > SECONDS_PER_DAY / 6 then
        return date("%a", timestamp)
    else
        if GetCVar("timeMgrUseMilitaryTime") == "1" then
            return date("%H:%M", timestamp)
        else
            return strtrim(date("%I %p", timestamp), "0")
        end
    end
end

local SNAP_BUTTONS = {
    {
        label = "1Y",
        duration = 365 * SECONDS_PER_DAY,
    },
    {
        label = "6M",
        duration = 180 * SECONDS_PER_DAY,
    },
    {
        label = "3M",
        duration = 90 * SECONDS_PER_DAY,
    },
    {
        label = "1M",
        duration = 30 * SECONDS_PER_DAY,
    },
    {
        label = "1W",
        duration = 7 * SECONDS_PER_DAY,
    },
    {
        label = "1D",
        duration = SECONDS_PER_DAY,
    },
}


local BUCKETS = {
    {
        seconds = 60,
        label = "1 Minute Bins",
    },
    {
        seconds = 300,
        label = "5 Minute Bins",
    },
    {
        seconds = 600,
        label = "10 Minute Bins",
    },
    {
        seconds = 1800,
        label = "30 Minute Bins",
    },
    {
        seconds = 3600,
        label = "1 Hour Bins",
    },
    {
        seconds = 6 * 3600,
        label = "6 Hour Bins",
    },
    {
        seconds = 12 * 3600,
        label = "12 Hour Bins",
    },
    {
        seconds = 24 * 3600,
        label = "24 Hour Bins",
    },
    {
        seconds = 7 * 24 * 3600,
        label = "1 Week Bins",
    },
}

local function CreateBuckets(data, start, end_)
    local startIndex = 0;
    local endIndex = 0;
    for i in ipairs(data) do
        local timestamp = CraftScan.Analytics.GetTimeStamp(data[i]);
        if startIndex == 0 and timestamp >= start then
            startIndex = i;
        end
        if timestamp > end_ then
            endIndex = i - 1;
            break;
        end
    end
    if endIndex == 0 and CraftScan.Analytics.GetTimeStamp(data[#data]) <= end_ then
        endIndex = #data;
    end
    if startIndex == 0 or endIndex == 0 then
        return;
    end

    local DESIRED_BUCKETS = 100;
    local duration = end_ - start;
    local desiredBucketSize = duration / DESIRED_BUCKETS;
    local bucketInfo = BUCKETS[#BUCKETS];

    for _, bi in ipairs(BUCKETS) do
        if desiredBucketSize < bi.seconds then
            bucketInfo = bi;
            break;
        end
    end

    local buckets = {}
    for i = startIndex, endIndex, 1 do
        local entry = data[i];
        local timestamp, count
        if type(entry) == "table" then
            count = entry.c or 1;
            timestamp = entry.t;
        else
            count = 1;
            timestamp = entry;
        end

        local bucketIndex = math.floor((timestamp - start) / bucketInfo.seconds);

        local bucket = buckets[bucketIndex];
        if not bucket then
            buckets[bucketIndex] = {
                c = 0,
                cs = 0,
            }
            bucket = buckets[bucketIndex];
        end
        bucket.c = bucket.c + count;
        bucket.cs = bucket.cs + 1;
    end

    local max = 0;
    local bucketArray = {}
    for bucketIndex, count in pairs(buckets) do
        if count.c > max then max = count.c; end
        table.insert(bucketArray, { bucket = bucketIndex, count = count.c, intensity = count.c / count.cs, })
    end

    table.sort(bucketArray, function(a, b) return a.bucket > b.bucket end)

    return bucketArray, bucketInfo, max;
end

local function CreateVerticalLine(length, width)
    local line = AcquireTexture(plot);
    line:SetColorTexture(1, 1, 1);
    line:SetSize(width, length);
    return line;
end

local function CreateHorizontalLine(length, width)
    local line = AcquireTexture(plot);
    line:SetColorTexture(1, 1, 1);
    line:SetSize(length, width);
    return line;
end

local function WhiteToGreenGradient(value, maxValue)
    local cappedValue = math.max(1, math.min(value, maxValue));

    local factor = (cappedValue - 1) / maxValue

    -- Calculate the RGB components
    local red = 1 - factor  -- Decrease red from 1 to 0
    local green = 1         -- Green is always fully on
    local blue = 1 - factor -- Decrease blue from 1 to 0

    return red, green, blue
end

local function AcquireVerticalText()
    -- If we just return a rotated text, its horizontal position depends on the
    -- length of the text. Anchoring it to a small texture lets us move the
    -- texture around and the text stays centered right on it.
    local position = AcquireTexture(plot);
    position:SetSize(10, 10);
    position:SetVertexColor(1, 1, 1, 0)

    local text = AcquireText(plot);
    text:SetPoint("CENTER", position, "CENTER")
    text:SetRotation(math.rad(90))
    return text, position
end

local function UpdateCursorLabelText(label, timestamp)
    label:SetText(date("%I:%M %p %b %d, %Y", timestamp))
end

local function DrawPlot(data, start, end_)
    local buckets, bucketInfo, max = CreateBuckets(data, start, end_);
    if not buckets then
        canvas.empty = true;
        return;
    end

    local duration = end_ - start;

    local yIntervals = math.min(5, max);
    local yInterval = math.ceil(max / yIntervals);
    max = yInterval * yIntervals;
    do -- Setup the Y axis tick marks and labels
        for i = 0, yIntervals, 1 do
            local xLine = CreateHorizontalLine(WIDTH + 3, 1)
            local ratio = i / yIntervals;
            xLine:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", X_LABELS_W - 3, Y_LABELS_H + ratio * HEIGHT)
            xLine:SetVertexColor(1, 1, 1, 0.2)

            local text = AcquireText(plot);
            local value = i * yInterval;
            text:SetText(value);
            text:SetPoint("RIGHT", canvas, "BOTTOMLEFT", X_LABELS_W - 5, Y_LABELS_H + ratio * HEIGHT)
        end
        local yAxisLabel, yAxisLabelPosition = AcquireVerticalText();
        yAxisLabel:SetText(L("Request Count"));
        yAxisLabelPosition:SetPoint("LEFT", canvas, "LEFT", 10, 0)
    end

    do
        local xSuggestedStep  = Scale(PLOT_MIN_X_LINE_SPACING, 0, WIDTH, 0, end_ - start);
        local prevXAxisOffset = nil;
        local xAxisValue      = GraphXStepFunc(start, xSuggestedStep);
        while xAxisValue <= end_ do
            local xAxisOffset = Scale(xAxisValue, start, end_, 0, WIDTH)
            if not prevXAxisOffset or (xAxisOffset - prevXAxisOffset) > PLOT_MIN_X_LINE_SPACING then
                local yLine = CreateVerticalLine(HEIGHT + 3, 1)
                yLine:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", X_LABELS_W + xAxisOffset, Y_LABELS_H - 3)
                yLine:SetVertexColor(1, 1, 1, 0.2)

                local text = AcquireText(plot);
                text:SetText(GraphFormatX(Scale(xAxisOffset, 0, WIDTH, start, end_), xSuggestedStep));
                text:SetPoint("TOP", canvas, "BOTTOMLEFT", X_LABELS_W + xAxisOffset, Y_LABELS_H - 5)

                prevXAxisOffset = xAxisOffset
            end
            xAxisValue = GraphXStepFunc(xAxisValue, xSuggestedStep)
        end

        local xAxisLabel = AcquireText(plot);
        xAxisLabel:SetText(L(bucketInfo.label));
        xAxisLabel:SetPoint("BOTTOM", canvas, "BOTTOM", 0, 15)
    end

    do
        local nBuckets = duration / bucketInfo.seconds;
        for _, entry in ipairs(buckets) do
            local texture = AcquireTexture(plot);
            texture:SetAtlas("CircleMaskScalable");

            local y = Scale(entry.count, 0, max, 0, HEIGHT);
            local x = Scale(entry.bucket, 0, nBuckets, 0, WIDTH);
            texture:SetPoint("CENTER", canvas, "BOTTOMLEFT", X_LABELS_W + x, Y_LABELS_H + y);
            texture:SetSize(10, 10)
            local r, g, b = WhiteToGreenGradient(entry.intensity, 3);
            texture:SetVertexColor(r, g, b, 1)
        end
    end
end

local curStart = nil;
local curEnd = nil;
local function SavePriorZoom()
    local selected = nil;
    for _, i in ipairs(SNAP_BUTTONS) do
        if i.selected == true then
            selected = i;
            break;
        end
    end
    table.insert(priorZoom, {
        start = curStart,
        end_ = curEnd,
        selected = selected,
    });
    for _, i in ipairs(SNAP_BUTTONS) do
        i.selected = false;
    end
end

local function PlotDataRange(start, end_)
    ReleaseTextures(plot);
    ReleaseTexts(plot);

    local data = plot.data;
    local rawData = {};
    for _, timestamp in pairs(data) do
        local ts = CraftScan.Analytics.GetTimeStamp(timestamp);
        table.insert(rawData, date("%Y-%m-%d %I:%M:%S %p", ts));
    end

    canvas:ClearAllPoints();
    canvas:SetSize(WIDTH + X_LABELS_W + X_LEGEND_W, HEIGHT + Y_LABELS_H);

    plot.textures = {}
    plot.texts = {}

    local xAxis = CreateHorizontalLine(WIDTH, 1)
    xAxis:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", X_LABELS_W, Y_LABELS_H)

    local yAxis = CreateVerticalLine(HEIGHT, 1)
    yAxis:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", X_LABELS_W, Y_LABELS_H)

    if end_ - start < 60 then
        start = start - 30;
        end_ = end_ + 30;
    end
    curStart = start;
    curEnd = end_;

    DrawPlot(data, start, end_);

    do
        local cursorLine = CreateVerticalLine(HEIGHT + 3, 1)
        cursorLine:SetVertexColor(0.678, 0.847, 0.902, 1)
        cursorLine:Hide();
        canvas.cursorLine = cursorLine;

        local selectedArea = CreateVerticalLine(HEIGHT + 3, 1)
        selectedArea:SetVertexColor(0.678, 0.847, 0.902, 0.1)
        selectedArea:SetBlendMode("BLEND");
        selectedArea:Hide();
        canvas.selectedArea = selectedArea;
    end

    do
        local cursorLabel = AcquireText(plot);
        cursorLabel:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", 0, 25)
        canvas.cursorLabel = cursorLabel;
        UpdateCursorLabelText(cursorLabel, end_);
    end

    local y = -5;
    local function CreateLegendLabel(text, x)
        local label = AcquireText(plot);
        label:SetPoint("LEFT", canvas, "TOPRIGHT", -X_LEGEND_W + 20 + (x or 0), y)
        label:SetText(text);
        y = y - 15;
    end
    local function CreateDot(r, g, b)
        local texture = AcquireTexture(plot);
        texture:SetAtlas("CircleMaskScalable");
        texture:SetPoint("LEFT", canvas, "TOPRIGHT", -X_LEGEND_W + 20, y);
        texture:SetSize(10, 10)
        texture:SetVertexColor(r, g, b, 1)
    end
    do -- Legend white dot
        CreateDot(1, 1, 1);
        CreateLegendLabel(L("No repeat requests"), 12)
    end
    do -- Legend green dot
        CreateDot(0, 1, 0);
        CreateLegendLabel(L("3 or more repeats"), 12)
    end
    CreateLegendLabel(L("Click row to interact"))
    CreateLegendLabel(L("Click + drag to zoom"))
    CreateLegendLabel(L("Right click to unzoom"))
    CreateLegendLabel(L("Right click to close"))
    CreateLegendLabel(L("Click row to close"))

    canvas.buttons = {}
    for _, info in ipairs(SNAP_BUTTONS) do
        y = y - 15;
        local button = AcquireText(plot);
        button:SetText(info.label);
        if not info.selected then
            button:SetVertexColor(0.25, 0.25, 0.25, 1);
        end
        button:ClearAllPoints();
        button:SetPoint("LEFT", canvas, "TOPRIGHT", -X_LEGEND_W + 20, y);
        button:EnableMouse(true);
        button:SetScript("OnMouseUp", function()
            local end_ = time()
            local start = end_ - info.duration;
            SavePriorZoom();
            info.selected = true;
            PlotDataRange(start, end_);
        end)
        table.insert(canvas.buttons, button);
        button:Show();
    end
end

local plotLock = nil;

local function GetPosition(frame)
    local mouseX, mouseY = GetCursorPosition();
    local scale = frame:GetEffectiveScale();
    local frameLeft = frame:GetLeft();
    local frameBottom = frame:GetBottom();

    local localX = (mouseX / scale) - frameLeft;
    local localY = (mouseY / scale) - frameBottom;

    return math.min(math.max(localX, 0), PLOT_MAX_X), math.min(math.max(localY, 0), PLOT_MAX_Y);
end

local function CalculateXDate(xPos)
    local x = xPos - X_LABELS_W;
    local ratio = x / WIDTH;
    return ratio * (curEnd - curStart) + curStart;
end

local xDragStart = nil
local function OnPlotMouseDown(self, button)
    if button ~= "LeftButton" then return; end
    xDragStart = GetPosition(self);
end

local function OnPlotMouseUp(self, button)
    if button == "RightButton" then
        if #priorZoom == 0 then
            plotLock = nil;
            CraftScan.Utils:HideTooltipPlot();
            return;
        else
            local entry = priorZoom[#priorZoom];
            for _, i in ipairs(SNAP_BUTTONS) do
                i.selected = (i == entry.selected)
            end
            PlotDataRange(entry.start, entry.end_);
            table.remove(priorZoom);
        end
    end

    if xDragStart ~= nil then
        local x = GetPosition(self);
        local cursorDate = CalculateXDate(x);
        local dragStartDate = CalculateXDate(xDragStart);
        local lhsDate = math.min(cursorDate, dragStartDate);
        local rhsDate = math.max(cursorDate, dragStartDate);
        self.selectedArea:Hide();
        SavePriorZoom();
        PlotDataRange(lhsDate, rhsDate);
        xDragStart = nil;
    end
end

local function OnMouseMove(self)
    local x, y = GetPosition(self);

    if x > PLOT_MIN_X and x < PLOT_MAX_X and y > PLOT_MIN_Y and y < PLOT_MAX_Y then
        self.cursorLine:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", x, PLOT_MIN_Y - 3);
        self.cursorLine:Show();

        local cursorDate = CalculateXDate(x);
        UpdateCursorLabelText(self.cursorLabel, cursorDate);

        if xDragStart ~= nil then
            local lhs = math.min(x, xDragStart);
            local rhs = math.max(x, xDragStart);
            self.selectedArea:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", lhs, PLOT_MIN_Y - 3);
            self.selectedArea:SetWidth(rhs - lhs);
            self.selectedArea:Show();
        end
    else
        self.selectedArea:Hide();
        self.cursorLine:Hide();
        UpdateCursorLabelText(self.cursorLabel, curEnd);
    end
end

function CraftScan.Utils.ShowTooltipPlot(anchor, itemID, data, togglePlotLock)
    if togglePlotLock then
        local before = plotLock
        plotLock = nil;
        CraftScan.Utils.HideTooltipPlot();
        if before == anchor then return; end

        plotLock = anchor;
    elseif plotLock then
        return;
    end

    if not plot then
        plot = CreateFrame("GameTooltip", "CraftScanTooltipPlot", UIParent, "GameTooltipTemplate");
        canvas:EnableMouse(true);
        canvas:SetScript("OnMouseDown", OnPlotMouseDown);
        canvas:SetScript("OnMouseUp", OnPlotMouseUp);
    end
    plot:SetOwner(anchor, "ANCHOR_TOPLEFT", -75);

    local start = CraftScan.Analytics.GetTimeStamp(data[1]);
    local end_ = CraftScan.Analytics.GetTimeStamp(data[#data]);
    plot.data = data;
    PlotDataRange(start, end_);

    item = Item:CreateFromItemID(itemID);
    GameTooltip_SetTitle(plot, item:GetItemLink());
    plot.TextLeft1:SetJustifyH("CENTER");

    GameTooltip_AddBlankLineToTooltip(plot);
    GameTooltip_InsertFrame(plot, canvas);

    plot:Show();

    canvas:SetScript("OnEnter", function(self)
        self:SetScript("OnUpdate", OnMouseMove)
    end)
    canvas:SetScript("OnLeave", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

function CraftScan.Utils.ForceHideTooltipPlot()
    plotLock = nil;
    CraftScan.Utils.HideTooltipPlot();
end

function CraftScan.Utils.HideTooltipPlot()
    if plotLock or not plot then return; end

    priorZoom = {}
    ReleaseTextures(plot);
    ReleaseTexts(plot);
    canvas:SetScript("OnEnter", nil);
    canvas:SetScript("OnLeave", nil);
    canvas:SetScript("OnUpdate", nil);
    canvas.cursorLine = nil;
    canvas.selectedArea = nil;
    canvas.cursorLabel = nil;

    for _, i in ipairs(SNAP_BUTTONS) do
        i.selected = false;
    end

    plot:Hide();
end
