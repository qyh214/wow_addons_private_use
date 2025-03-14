local CraftScan = select(2, ...)

local DEBUG = false;
local DEBUG_FRAMES = false;

CraftScan.Debug = {}

CraftScan.Debug.IsEnabled = function() return DEBUG end

function CraftScan.Debug.Print(data, label)
    if not DEBUG then return; end
    if not DevTool then
        local loaded, reason = C_AddOns.LoadAddOn("DevTool");
        if not loaded then
            print("CraftScan: Error loading DevTools:", reason)
            return
        end
    end
    if DevTool and DEBUG then
        DevTool:AddData(data, label)
    end
end

function CraftScan.Debug.DrawGrid(frame, spacing)
    if not DEBUG_FRAMES then return end

    -- Create vertical grid lines
    for x = 0, frame:GetWidth(), spacing do
        local line = frame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 1, 1) -- Set color to white
        line:SetPoint("TOPLEFT", frame, "TOPLEFT", x, 0)
        line:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", x, 0)
        line:SetWidth(1) -- Line thickness (1px wide)
    end

    -- Create horizontal grid lines
    for y = 0, frame:GetHeight(), spacing do
        local line = frame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 1, 1) -- Set color to white
        line:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -y)
        line:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -y)
        line:SetHeight(1) -- Line thickness (1px tall)
    end
end

function CraftScan.Debug.OutlineFrame(frame)
    if not DEBUG_FRAMES then return end

    local factory = frame
    if frame:GetObjectType() ~= "Frame" then
        factory = frame:GetParent()
    end

    local lines = {
        { "TOPLEFT",    "BOTTOMLEFT" },
        { "TOPRIGHT",   "BOTTOMRIGHT" },
        { "TOPLEFT",    "TOPRIGHT" },
        { "BOTTOMLEFT", "BOTTOMRIGHT" },
    }

    for _, points in ipairs(lines) do
        local line = factory:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 1, 1) -- Set color to white
        line:SetPoint(points[1], frame, points[1], 0, 0)
        line:SetPoint(points[2], frame, points[2], 0, 0)
        line:SetWidth(1) -- Line thickness (1px wide)
    end
end
