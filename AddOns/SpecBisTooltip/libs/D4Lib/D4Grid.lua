local _, D4 = ...
local grid = nil
function D4:Grid(n, snap)
    n = n or 0
    snap = snap or 10
    local mod = n % snap

    return (mod > (snap / 2)) and (n - mod + snap) or (n - mod)
end

function D4:SetGridSize(size)
    return size
end

function D4:GetGridSize()
    return 10
end

function D4:UpdateGrid()
    if grid then
        local id = 0
        grid.lines = grid.lines or {}
        for i, v in pairs(grid.lines) do
            v:Hide()
        end

        for x = 0, GetScreenWidth() / 2, D4:GetGridSize() do
            grid.lines[id] = grid.lines[id] or grid:CreateTexture()
            grid.lines[id]:SetPoint("CENTER", 0.5 + x, 0)
            grid.lines[id]:SetSize(1.09, GetScreenHeight())
            if x % 50 == 0 then
                grid.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
            else
                grid.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
            end

            grid.lines[id]:Show()
            id = id + 1
        end

        for x = 0, -GetScreenWidth() / 2, -D4:GetGridSize() do
            grid.lines[id] = grid.lines[id] or grid:CreateTexture()
            grid.lines[id]:SetPoint("CENTER", 0.5 + x, 0)
            grid.lines[id]:SetSize(1.09, GetScreenHeight())
            if x % 50 == 0 then
                grid.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
            else
                grid.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
            end

            grid.lines[id]:Show()
            id = id + 1
        end

        for y = 0, GetScreenHeight() / 2, D4:GetGridSize() do
            grid.lines[id] = grid.lines[id] or grid:CreateTexture()
            grid.lines[id]:SetPoint("CENTER", 0, 0.5 + y)
            grid.lines[id]:SetSize(GetScreenWidth(), 1.09, GetScreenHeight())
            if y % 50 == 0 then
                grid.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
            else
                grid.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
            end

            grid.lines[id]:Show()
            id = id + 1
        end

        for y = 0, -GetScreenHeight() / 2, -D4:GetGridSize() do
            grid.lines[id] = grid.lines[id] or grid:CreateTexture()
            grid.lines[id]:SetPoint("CENTER", 0, 0.5 + y)
            grid.lines[id]:SetSize(GetScreenWidth(), 1.09)
            if y % 50 == 0 then
                grid.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
            else
                grid.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
            end

            grid.lines[id]:Show()
            id = id + 1
        end
    end
end

function D4:CreateGrid()
    if grid == nil then
        grid = CreateFrame("Frame", "grid", UIParent)
        grid.lines = grid.lines or {}
        grid:EnableMouse(false)
        grid:SetSize(GetScreenWidth(), GetScreenHeight())
        grid:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        grid:SetFrameStrata("LOW")
        grid:SetFrameLevel(1)
        grid.bg = grid:CreateTexture("grid.bg", "BACKGROUND", nil, 0)
        grid.bg:SetAllPoints(grid)
        grid.bg:SetColorTexture(0.03, 0.03, 0.03, 0)
        grid.hor = grid:CreateTexture()
        grid.hor:SetPoint("CENTER", 0, -0.5)
        grid.hor:SetSize(GetScreenWidth(), 1)
        grid.hor:SetColorTexture(1, 1, 1, 1)
        grid.ver = grid:CreateTexture()
        grid.ver:SetPoint("CENTER", 0.5, 0)
        grid.ver:SetSize(1, GetScreenHeight())
        grid.ver:SetColorTexture(1, 1, 1, 1)
    end

    D4:UpdateGrid()

    return grid
end

function D4:AddHelper(frame, hide)
    if frame.hh == nil then
        frame.hh = frame:CreateTexture(nil, "HIGHLIGHT")
        frame.hh:SetSize(1.1, frame:GetHeight())
        frame.hh:SetPoint("CENTER", frame, "CENTER", 0, 0)
        frame.hh:SetColorTexture(1, 1, 1)
    end

    if frame.vh == nil then
        frame.vh = frame:CreateTexture(nil, "HIGHLIGHT")
        frame.vh:SetSize(frame:GetWidth(), 1.1)
        frame.vh:SetPoint("CENTER", frame, "CENTER", 0, 0)
        frame.vh:SetColorTexture(1, 1, 1)
    end

    if hide then
        frame.hh:Hide()
        frame.vh:Hide()
    else
        frame.hh:Show()
        frame.vh:Show()
    end
end

function D4:HideGrid(frame)
    D4:AddHelper(frame, true)
    D4:CreateGrid()
    if grid then
        grid:Hide()
    end
end

function D4:ShowGrid(frame)
    D4:AddHelper(frame, false)
    D4:CreateGrid()
    if grid then
        grid:Show()
    end
end
