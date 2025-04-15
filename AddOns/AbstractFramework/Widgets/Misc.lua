---@class AbstractFramework
local AF = _G.AbstractFramework

--TODO: adjust text colors

---------------------------------------------------------------------
-- net stats
---------------------------------------------------------------------
---@param layout string "horizontal|vertical"
function AF.CreateNetStatsPane(parent, anchorPoint, showBandwidth, showLatency, layout)
    anchorPoint = anchorPoint or "LEFT"
    anchorPoint = strupper(anchorPoint)
    layout = layout or "horizontal"
    layout = strlower(layout)

    local f = AF.CreateFrame(parent, nil, 20, 20)

    f.text = AF.CreateFontString(f, nil, "sand", "AF_FONT_SMALL")
    AF.SetPoint(f.text, anchorPoint)
    if strfind(anchorPoint, "LEFT$") then
        f.text:SetJustifyH("LEFT")
    elseif strfind(anchorPoint, "RIGHT$") then
        f.text:SetJustifyH("RIGHT")
    else
        f.text:SetJustifyH("CENTER")
    end

    local str = ""

    if showBandwidth then
        str = str .. AF.GetIconString("Upload") .. "%sKB/s_"
        str = str .. AF.GetIconString("Download") .. "%sKB/s_"
    end

    if showLatency then
        str = str .. AF.GetIconString("Home") .. "%sms_"
        str = str .. AF.GetIconString("World") .. "%sms_"
    end

    if layout == "horizontal" then
        f.text:SetWordWrap(false)
        str = string.gsub(str, "_", " ")
    else
        f.text:SetWordWrap(true)
        str = string.gsub(str, "_", "\n")
    end

    local function Update()
        local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
        bandwidthIn = tonumber(string.format("%.2f", bandwidthIn))
        bandwidthOut = tonumber(string.format("%.2f", bandwidthOut))
        -- print(bandwidthIn, bandwidthOut)

        if showBandwidth and showLatency then
            f.text:SetFormattedText(str, bandwidthOut, bandwidthIn, latencyHome, latencyWorld)
        elseif showBandwidth then
            f.text:SetFormattedText(str, bandwidthOut, bandwidthIn)
        elseif showLatency then
            f.text:SetFormattedText(str, latencyHome, latencyWorld)
        end
    end

    f:SetScript("OnShow", function()
        f.timer = C_Timer.NewTicker(2, Update)
    end)

    f:SetScript("OnHide", function()
        if f.timer then
            f.timer:Cancel()
            f.timer = nil
        end
    end)

    Update()
    f:Hide()
    f:Show()

    return f
end

---------------------------------------------------------------------
-- fps
---------------------------------------------------------------------
function AF.CreateFPSPane(parent, anchorPoint)
    anchorPoint = anchorPoint or "LEFT"
    anchorPoint = strupper(anchorPoint)

    local f = AF.CreateFrame(parent, nil, 20, 20)

    f.text = AF.CreateFontString(f, nil, "sand", "AF_FONT_SMALL")
    AF.SetPoint(f.text, anchorPoint)
    if strfind(anchorPoint, "LEFT$") then
        f.text:SetJustifyH("LEFT")
    elseif strfind(anchorPoint, "RIGHT$") then
        f.text:SetJustifyH("RIGHT")
    else
        f.text:SetJustifyH("CENTER")
    end

    local function Update()
        f.text:SetFormattedText("%.1ffps", GetFramerate())
    end

    f:SetScript("OnShow", function()
        f.timer = C_Timer.NewTicker(0.2, Update)
    end)

    f:SetScript("OnHide", function()
        if f.timer then
            f.timer:Cancel()
            f.timer = nil
        end
    end)

    Update()
    f:Hide()
    f:Show()

    return f
end