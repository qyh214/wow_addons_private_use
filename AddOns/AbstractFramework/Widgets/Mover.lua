---@class AbstractFramework
local AF = _G.AbstractFramework
local L = AF.L

local MOVER_PARENT_FRAME_LEVEL = 700
local MOVER_ON_TOP_FRAME_LEVEL = 777
local FINE_TUNING_FRAME_LEVEL = 800
local movers = {}

local moverParent, moverDialog, alignmentGrid, positionAdjustmentFrame
local anchorLockedText
local AnchorPositionAdjustmentFrame, UpdateAndSave, UpdatePositionAdjustmentFrame
local isAnchorLocked = false
local modified = {}

---------------------------------------------------------------------
-- base
---------------------------------------------------------------------
local lines = {}

local function CreateLine(key, color, alpha, x, y, w, h, subLevel)
    lines[key] = lines[key] or AF.CreateTexture(alignmentGrid, nil, AF.GetColorTable(color, alpha), "BACKGROUND", subLevel or 0, nil, nil, "NEAREST")
    AF.SetSize(lines[key], w, h)
    AF.ClearPoints(lines[key])
    AF.SetPoint(lines[key], "CENTER", x, y)
end

-- local function CreateLine2(color, alpha, x1, y1, x2, y2)
--     local l = alignmentGrid:CreateLine(nil, "BACKGROUND")
--     l:SetThickness(1)
--     l:SetColorTexture(AF.GetColorRGB(color, alpha))
--     l:SetStartPoint("BOTTOMLEFT", x1, y1)
--     l:SetEndPoint("BOTTOMLEFT", x2, y2)
--     return l
-- end

local function UpdateLines()
    -- local width, height = GetPhysicalScreenSize()

    local width, height = alignmentGrid:GetSize()
    local halfWidth, halfHeight = width / 2, height / 2

    -- center cross
    local centerX = math.floor((width - 1) / 2)
    local centerY = math.floor((height - 1) / 2)

    -- v center
    CreateLine("v0", "red", 0.75, 0, 0, 1, height, 1)

    -- h center
    CreateLine("h0", "red", 0.75, 0, 0, width, 1, 1)

    -- vleft
    local n = 0
    local offset = 0
    repeat
        n = n - 1
        offset = offset - 25
        CreateLine("v" .. n, "gray", 0.35, offset, 0, 1, height)
    until offset < -halfWidth

    -- vright
    n = 0
    offset = 0
    repeat
        n = n + 1
        offset = offset + 25
        CreateLine("v" .. n, "gray", 0.35, offset, 0, 1, height)
    until offset > halfWidth

    -- hbottom
    n = 0
    offset = 0
    repeat
        n = n - 1
        offset = offset - 25
        CreateLine("h" .. n, "gray", 0.35, 0, offset, width, 1)
    until offset < -halfHeight

    -- htop
    n = 0
    offset = 0
    repeat
        n = n + 1
        offset = offset + 25
        CreateLine("h" .. n, "gray", 0.35, 0, offset, width, 1)
    until offset > halfHeight
end

local function CreateAlignmentGrid()
    alignmentGrid = CreateFrame("Frame", "AFAlignmentGrid", moverParent)
    alignmentGrid:SetFrameStrata("BACKGROUND")
    -- alignmentGrid:SetBackdrop({bgFile=AF.GetPlainTexture()})
    -- alignmentGrid:SetBackdropColor(AF.GetColorRGB("disabled", 0)) -- for user customization?
    alignmentGrid:SetAllPoints()
    -- alignmentGrid:SetIgnoreParentScale(true)
    alignmentGrid:SetScale(AF.GetPixelFactor())

    -- DISPLAY_SIZE_CHANGED
    alignmentGrid:RegisterEvent("DISPLAY_SIZE_CHANGED")
    alignmentGrid:SetScript("OnEvent", UpdateLines)

    UpdateLines()
end

local function CreateMoverDialog()
    moverDialog = AF.CreateHeaderedFrame(moverParent, "AFMoverDialog", _G.HUD_EDIT_MODE_MENU, 300, 180, "FULLSCREEN_DIALOG", nil, true)
    moverDialog:SetFrameStrata("FULLSCREEN_DIALOG")

    anchorLockedText = AF.CreateFontString(moverDialog, L["Anchor Locked"], "accent", "AF_FONT_OUTLINE")
    anchorLockedText:Hide()
    AF.CreateBlinkAnimation(anchorLockedText)

    -- desc
    local desc = AF.CreateFontString(moverDialog, L["Close this dialog to exit Edit Mode"])
    AF.SetPoint(desc, "TOPLEFT", 10, -10)

    -- tips
    local tips = AF.CreateFontString(moverDialog,
        AF.WrapTextInColor(L["Left Drag"] .. ": ", "accent") .. L["move frames"] .. "\n" ..
        AF.WrapTextInColor(L["Right Click"] .. ": ", "accent") .. L["toggle Position Adjustment dialog"] .. "\n" ..
        "    " .. L["Right Click the Anchor button to lock the anchor"] .. "\n" ..
        AF.WrapTextInColor(L["Mouse Wheel"] .. ": ", "accent") .. L["move frames vertically"] .. "\n" ..
        AF.WrapTextInColor("Shift " .. L["Mouse Wheel"] .. ": ", "accent") .. L["move frames horizontally"] .. "\n" ..
        AF.WrapTextInColor("Shift " .. L["Right Click"] .. ": ", "accent") .. L["hide mover"]
    )
    AF.SetPoint(tips, "TOPLEFT", 10, -35)
    tips:SetJustifyH("LEFT")
    tips:SetSpacing(5)

    -- undo
    local undo = AF.CreateButton(moverDialog, L["Undo"], "accent", 60, 20)
    moverDialog.undo = undo
    AF.SetPoint(undo, "BOTTOMRIGHT", -7, 7)
    undo:SetScript("OnClick", AF.UndoMovers)

    -- dropdown
    local moverGroups = AF.CreateDropdown(moverDialog, 20, 7)
    AF.SetPoint(moverGroups, "BOTTOMLEFT", 7, 7)
    AF.SetPoint(moverGroups, "RIGHT", undo, "LEFT", -7, 0)
    local items = {}

    -- OnShow
    moverDialog:SetScript("OnShow", function()
        C_Timer.After(0, function()
            AF.SetWidth(moverDialog, AF.Round(max(desc:GetWidth(), tips:GetWidth()) + 40))
        end)
        AF.ClearPoints(moverDialog)
        AF.SetPoint(moverDialog, "BOTTOM", moverParent, "CENTER", 0, 100)

        undo:SetEnabled(false)
        wipe(modified)

        -- groups
        wipe(items)
        for group in pairs(movers) do
            tinsert(items, {
                ["text"] = group,
                ["value"] = group,
                ["onClick"] = function()
                    AF.ShowMovers(group)
                end
            })
        end

        sort(items, function(a, b)
            return a.value < b.value
        end)

        tinsert(items, 1, {
            ["text"] = _G.ALL,
            ["value"] = "all",
            ["onClick"] = function()
                AF.ShowMovers()
            end
        })

        moverGroups:SetItems(items)
        moverGroups:SetSelectedValue("all")
    end)

    -- OnHide
    moverDialog:SetScript("OnHide", function()
        AF.HideMovers()
    end)
end

local function CreateMoverParent()
    moverParent = CreateFrame("Frame", "AFMoverParent", AF.UIParent)
    moverParent:SetFrameStrata("FULLSCREEN")
    moverParent:SetFrameLevel(MOVER_PARENT_FRAME_LEVEL)
    moverParent:SetAllPoints(AF.UIParent)
    moverParent:Hide()

    -- hide in combat
    moverParent:RegisterEvent("PLAYER_REGEN_DISABLED")
    moverParent:SetScript("OnEvent", function()
        AF.HideMovers()
    end)

    CreateMoverDialog()
    CreateAlignmentGrid()
end

---------------------------------------------------------------------
-- calc new point
---------------------------------------------------------------------
function AF.CalcPoint(owner)
    local point, x, y

    if isAnchorLocked then
        point, _, _, x, y = owner:GetPoint()
    else
        local centerX, centerY = AF.UIParent:GetCenter()
        local width = AF.UIParent:GetRight()
        x, y = owner:GetCenter()

        if y >= centerY then
            point = "TOP"
            y = -(AF.UIParent:GetTop() - owner:GetTop())
        else
            point = "BOTTOM"
            y = owner:GetBottom()
        end

        if x >= (width * 2 / 3) then
            point = point .. "RIGHT"
            x = owner:GetRight() - width
        elseif x <= (width / 3) then
            point = point .. "LEFT"
            x = owner:GetLeft()
        else
            x = x - centerX
        end
    end

    -- x = tonumber(string.format("%.2f", x))
    -- y = tonumber(string.format("%.2f", y))
    x = AF.RoundToDecimal(x, 1)
    y = AF.RoundToDecimal(y, 1)

    return point, x, y
end

local function RePoint(owner, newPoint)
    local x, y = owner:GetCenter()
    local centerX, centerY = AF.UIParent:GetCenter()
    local width = AF.UIParent:GetRight()

    if strfind(newPoint, "^TOP") then
        y = -(AF.UIParent:GetTop() - owner:GetTop())
    elseif strfind(newPoint, "^BOTTOM") then
        y = owner:GetBottom()
    else
        y = y - centerY
    end

    if strfind(newPoint, "LEFT$") then
        x = owner:GetLeft()
    elseif strfind(newPoint, "RIGHT$") then
        x = owner:GetRight() - width
    else
        x = x - centerX
    end

    owner:ClearAllPoints()
    owner:SetPoint(newPoint, x, y)
    UpdateAndSave(owner, newPoint, x, y)
    UpdatePositionAdjustmentFrame(owner)
end

---------------------------------------------------------------------
-- position adjustment frame
---------------------------------------------------------------------
local function CreatePositionAdjustmentFrame()
    positionAdjustmentFrame = AF.CreateBorderedFrame(moverParent, nil, nil, nil, nil, "accent")
    positionAdjustmentFrame:SetFrameLevel(FINE_TUNING_FRAME_LEVEL)
    positionAdjustmentFrame:EnableMouse(true)
    positionAdjustmentFrame:SetClampedToScreen(true)
    AF.SetSize(positionAdjustmentFrame, 200, 91)
    positionAdjustmentFrame:Hide()

    -- title
    positionAdjustmentFrame.tp = AF.CreateTitledPane(positionAdjustmentFrame, "")
    AF.SetPoint(positionAdjustmentFrame.tp, "TOPLEFT", 7, -7)
    AF.SetPoint(positionAdjustmentFrame.tp, "BOTTOMRIGHT", -7, 7)

    -- anchor
    positionAdjustmentFrame.anchor = AF.CreateDropdown(positionAdjustmentFrame.tp, 20, 9, "texture", true, true, nil, 1)

    local items = {}
    local anchors = {"CENTER", "LEFT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", "RIGHT", "TOPLEFT", "TOP", "TOPRIGHT"}
    for _, anchor in pairs(anchors) do
        tinsert(items, {
            ["text"] = "",
            ["value"] = anchor,
            ["texture"] = AF.GetIcon("Anchor_" .. anchor),
            ["onClick"] = function()
                RePoint(positionAdjustmentFrame.owner, anchor)
            end
        })
    end
    positionAdjustmentFrame.anchor:SetItems(items)
    AF.SetPoint(positionAdjustmentFrame.anchor, "TOPLEFT", 0, -30)

    -- lock anchor
    positionAdjustmentFrame.anchor.lock = AF.CreateTexture(positionAdjustmentFrame.anchor.button, AF.GetIcon("SmallLock"), "white", "OVERLAY")
    AF.SetSize(positionAdjustmentFrame.anchor.lock, 20, 20)
    AF.SetPoint(positionAdjustmentFrame.anchor.lock, "CENTER", 2, -2)
    positionAdjustmentFrame.anchor.lock:Hide()
    positionAdjustmentFrame.anchor.button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    positionAdjustmentFrame.anchor.button:HookScript("OnClick", function(self, button)
        if button == "RightButton" then
            isAnchorLocked = not isAnchorLocked
            positionAdjustmentFrame.anchor.lock:SetShown(isAnchorLocked)
            anchorLockedText:SetShown(isAnchorLocked)
        end
    end)

    -- x
    positionAdjustmentFrame.x = AF.CreateEditBox(positionAdjustmentFrame.tp, "", 60, 20)
    AF.SetPoint(positionAdjustmentFrame.x, "LEFT", positionAdjustmentFrame.anchor, "RIGHT", 20, 0)

    local x = AF.CreateFontString(positionAdjustmentFrame.tp, "X", "accent")
    AF.SetPoint(x, "RIGHT", positionAdjustmentFrame.x, "LEFT", -2, 0)

    -- y
    positionAdjustmentFrame.y = AF.CreateEditBox(positionAdjustmentFrame.tp, "", 60, 20)
    AF.SetPoint(positionAdjustmentFrame.y, "BOTTOM", positionAdjustmentFrame.x)
    AF.SetPoint(positionAdjustmentFrame.y, "RIGHT")

    local y = AF.CreateFontString(positionAdjustmentFrame.tp, "Y", "accent")
    AF.SetPoint(y, "RIGHT", positionAdjustmentFrame.y, "LEFT", -2, 0)

    -- edit x
    positionAdjustmentFrame.x:SetOnEditFocusGained(function()
        positionAdjustmentFrame._x = positionAdjustmentFrame.x:GetNumber()
    end)
    positionAdjustmentFrame.x:SetOnEditFocusLost(function()
        positionAdjustmentFrame.x:SetText(positionAdjustmentFrame._x)
    end)
    positionAdjustmentFrame.x:SetOnEnterPressed(function(text)
        local v = tonumber(text)
        if v then
            positionAdjustmentFrame._x = v

            local owner = positionAdjustmentFrame.owner
            local _p, _, _, _x, _y = owner:GetPoint()

            -- validate
            local mv = AF.UIParent:GetRight() - owner:GetWidth()
            if strfind(_p, "LEFT$") then
                v = max(v, 0)
                v = min(v, mv)
            elseif strfind(_p, "RIGHT$") then
                v = max(-mv, v)
                v = min(v, 0)
            else
                v = max(v, -mv / 2)
                v = min(v, mv / 2)
            end

            owner:ClearAllPoints()
            owner:SetPoint(_p, v, _y)

            UpdateAndSave(owner, AF.CalcPoint(owner))
            AnchorPositionAdjustmentFrame(owner)
        end
    end)

    -- edit y
    positionAdjustmentFrame.y:SetOnEditFocusGained(function()
        positionAdjustmentFrame._y = positionAdjustmentFrame.y:GetNumber()
    end)
    positionAdjustmentFrame.y:SetOnEditFocusLost(function()
        positionAdjustmentFrame.y:SetText(positionAdjustmentFrame._y)
    end)
    positionAdjustmentFrame.y:SetOnEnterPressed(function(text)
        local v = tonumber(text)
        if v then
            positionAdjustmentFrame._y = v

            local owner = positionAdjustmentFrame.owner
            local _p, _, _, _x, _y = owner:GetPoint()

            -- validate
            local mv = AF.UIParent:GetTop() - owner:GetHeight()
            if strfind(_p, "^BOTTOM") then
                v = max(v, 0)
                v = min(v, mv)
            elseif strfind(_p, "^TOP") then
                v = max(-mv, v)
                v = min(v, 0)
            else
                v = max(v, -mv / 2)
                v = min(v, mv / 2)
            end

            owner:ClearAllPoints()
            owner:SetPoint(_p, _x, v)

            UpdateAndSave(owner, AF.CalcPoint(owner))
            AnchorPositionAdjustmentFrame(owner)
        end
    end)

    -- undo previous
    positionAdjustmentFrame.undo = AF.CreateButton(positionAdjustmentFrame.tp, L["Undo"], "accent", 17, 17)
    positionAdjustmentFrame.undo:SetEnabled(false)
    AF.SetPoint(positionAdjustmentFrame.undo, "BOTTOMLEFT")
    AF.SetPoint(positionAdjustmentFrame.undo, "BOTTOMRIGHT")
    positionAdjustmentFrame.undo:SetScript("OnClick", function()
        positionAdjustmentFrame.undo:SetEnabled(false)
        local owner = positionAdjustmentFrame.owner
        UpdateAndSave(owner, owner.mover._original[1], owner.mover._original[2], owner.mover._original[3], true)
        AnchorPositionAdjustmentFrame(owner)
    end)
end

UpdatePositionAdjustmentFrame = function(owner)
    if not (positionAdjustmentFrame and positionAdjustmentFrame:IsShown()) then return end

    positionAdjustmentFrame.tp:SetTitle(owner.mover.text:GetText())

    local p, _, _, x, y = owner:GetPoint()
    x = AF.RoundToDecimal(x, 1)
    y = AF.RoundToDecimal(y, 1)

    positionAdjustmentFrame.x:ClearFocus()
    positionAdjustmentFrame.y:ClearFocus()

    positionAdjustmentFrame.anchor:SetSelectedValue(p)
    AF.CloseDropdown()
    positionAdjustmentFrame.x:SetText(x)
    positionAdjustmentFrame.y:SetText(y)

    if owner.mover._original and (owner.mover._original[1] ~= p or owner.mover._original[2] ~= x or owner.mover._original[3] ~= y) then
        positionAdjustmentFrame.undo:SetEnabled(true)
    else
        positionAdjustmentFrame.undo:SetEnabled(false)
    end
end

AnchorPositionAdjustmentFrame = function(owner)
    if not positionAdjustmentFrame then return end

    positionAdjustmentFrame.owner = owner

    local centerX, centerY = AF.UIParent:GetCenter()
    local width = AF.UIParent:GetRight()
    local x, y = owner.mover:GetCenter()

    local point, relativePoint

    if x >= (width * 2 / 3) then
        point, relativePoint = "RIGHT", "LEFT"
        x, y = -1, 0
    elseif x <= (width / 3) then
        point, relativePoint = "LEFT", "RIGHT"
        x, y = 1, 0
    else
        if y >= centerY then
            point, relativePoint = "TOP", "BOTTOM"
            x, y = 0, -1
        else
            point, relativePoint = "BOTTOM", "TOP"
            x, y = 0, 1
        end
    end

    AF.ClearPoints(positionAdjustmentFrame)
    AF.SetPoint(positionAdjustmentFrame, point, owner.mover, relativePoint, x, y)

    AF.ClearPoints(anchorLockedText)
    if point == "TOP" then
        AF.SetPoint(anchorLockedText, "BOTTOM", owner.mover, "TOP", 0, 1)
    else
        AF.SetPoint(anchorLockedText, "TOP", owner.mover, "BOTTOM", 0, -1)
    end

    UpdatePositionAdjustmentFrame(owner)
end

local function TogglePositionAdjustmentFrame(owner)
    if not positionAdjustmentFrame then CreatePositionAdjustmentFrame() end

    if positionAdjustmentFrame:IsShown() then
        positionAdjustmentFrame:Hide()
        positionAdjustmentFrame.owner = nil
    else
        positionAdjustmentFrame:Show()
        AnchorPositionAdjustmentFrame(owner)
    end
end

---------------------------------------------------------------------
-- save
---------------------------------------------------------------------
UpdateAndSave = function(owner, p, x, y, isUndo)
    -- update ._points
    owner._useOriginalPoints = true
    owner._points = {}
    owner._points[p] = {p, AF.UIParent, p, x, y}
    AF.RePoint(owner)

    -- save position
    if type(owner.mover.save) == "function" then
        owner.mover.save(p, x, y)
    elseif type(owner.mover.save) == "table" then
        owner.mover.save[1] = p
        owner.mover.save[2] = x
        owner.mover.save[3] = y
    end

    -- update undo button status
    if isUndo then
        modified[owner] = nil
    else
        modified[owner] = true
    end
    if next(modified) then
        moverDialog.undo:SetEnabled(true)
    else
        moverDialog.undo:SetEnabled(false)
    end
end

---------------------------------------------------------------------
-- stop moving
---------------------------------------------------------------------
local function StopMoving(owner)
    owner.mover:SetScript("OnUpdate", nil)
    if owner.mover.moved then
        owner.mover.moved = nil

        -- calc new point
        local p, x, y = AF.CalcPoint(owner)
        UpdateAndSave(owner, p, x, y)
    end
end

---------------------------------------------------------------------
-- create mover
---------------------------------------------------------------------
---@param save function|table
function AF.CreateMover(owner, group, text, save)
    -- assert(owner:GetNumPoints() == 1, "mover owner must have 1 anchor point")
    -- assert(owner:GetParent() == AF.UIParent, "owner must be the direct child of AF.UIParent")
    -- NOTE:
    -- owner must be the direct child of AF.UIParent
    -- or
    -- its parent must SetAllPoints(AF.UIParent)

    if not moverParent then CreateMoverParent() end

    local mover = AF.CreateBorderedFrame(moverParent, nil, nil, nil, nil, "accent")
    mover:SetBackdropColor(AF.GetColorRGB("background", 0.8))

    owner.mover = mover
    mover.owner = owner
    mover.save = save

    if not movers[group] then movers[group] = {} end
    tinsert(movers[group], mover)

    mover:SetAllPoints(owner)
    mover:SetFrameLevel(MOVER_PARENT_FRAME_LEVEL)
    mover:EnableMouse(true)
    mover:Hide()

    mover.text = AF.CreateFontString(mover, text, nil, "AF_FONT_OUTLINE", "OVERLAY")
    mover.text:SetPoint("CENTER")
    mover.text:SetText(text)

    mover:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        mover.isDragging = true

        local scale = owner:GetEffectiveScale()
        local mouseX, mouseY = GetCursorPosition()

        local minX, maxX, minY, maxY

        local point, _, _, startX, startY = owner:GetPoint()

        if strfind(point, "^BOTTOM") then
            minY = 0
            maxY = AF.UIParent:GetHeight() - owner:GetHeight()
        elseif strfind(point, "^TOP") then
            minY = -(AF.UIParent:GetHeight() - owner:GetHeight())
            maxY = 0
        else -- LEFT/RIGHT/CENTER
            minY = -((AF.UIParent:GetHeight() - owner:GetHeight()) / 2)
            maxY = (AF.UIParent:GetHeight() - owner:GetHeight()) / 2
        end

        if strfind(point, "LEFT$") then
            minX = 0
            maxX = AF.UIParent:GetWidth() - owner:GetWidth()
        elseif strfind(point, "RIGHT$") then
            minX = -(AF.UIParent:GetWidth() - owner:GetWidth())
            maxX = 0
        else -- TOP/BOTTOM/CENTER
            minX = -((AF.UIParent:GetWidth() - owner:GetWidth()) / 2)
            maxX = (AF.UIParent:GetWidth() - owner:GetWidth()) / 2
        end

        local lastX = mouseX
        local lastY = mouseY

        mover:SetScript("OnUpdate", function()
            local newMouseX, newMouseY = GetCursorPosition()
            if newMouseX == lastX and newMouseY == lastY then return end

            lastX = newMouseX
            lastY = newMouseY

            local newX = startX + (newMouseX - mouseX) / scale
            newX = max(newX, minX)
            newX = min(newX, maxX)

            local newY = startY + (newMouseY - mouseY) / scale
            newY = max(newY, minY)
            newY = min(newY, maxY)

            -- print(newX, newY)
            owner:ClearAllPoints()
            owner:SetPoint(point, newX, newY)
            mover.moved = true

            AnchorPositionAdjustmentFrame(owner)
        end)
    end)

    mover:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then -- hide mover
                if positionAdjustmentFrame and positionAdjustmentFrame.owner == owner and positionAdjustmentFrame:IsShown() then
                    positionAdjustmentFrame.owner = nil
                    positionAdjustmentFrame:Hide()
                end
                mover:Hide()
                mover.text:SetColor("accent")
            else
                TogglePositionAdjustmentFrame(owner)
            end
        end

        if button ~= "LeftButton" then return end
        mover.isDragging = nil
        StopMoving(owner)

        -- update
        UpdatePositionAdjustmentFrame(owner)
    end)

    mover:SetScript("OnMouseWheel", function(self, delta)
        if mover.isDragging then return end

        local point, _, _, startX, startY = owner:GetPoint()
        startX = AF.RoundToDecimal(startX, 1)
        startY = AF.RoundToDecimal(startY, 1)

        mover.moved = true

        if delta == 1 then
            if IsShiftKeyDown() then
                -- move right
                owner:SetPoint(point, startX + 1, startY)
            else
                -- move up
                owner:SetPoint(point, startX, startY + 1)
            end
        else
            if IsShiftKeyDown() then
                -- move left
                owner:SetPoint(point, startX - 1, startY)
            else
                -- move down
                owner:SetPoint(point, startX, startY - 1)
            end
        end

        StopMoving(owner)

        -- update
        UpdatePositionAdjustmentFrame(owner)
    end)

    mover:SetScript("OnEnter", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                if m == mover then
                    m.text:SetColor("white")
                    m:SetFrameLevel(MOVER_ON_TOP_FRAME_LEVEL)
                    AF.FrameFadeIn(m, 0.25)
                elseif m:IsShown() then
                    m.text:SetColor("accent")
                    m:SetFrameLevel(MOVER_PARENT_FRAME_LEVEL)
                    AF.FrameFadeOut(m, 0.25, nil, 0.5)
                end
            end
        end

        AnchorPositionAdjustmentFrame(owner)
    end)

    mover:SetScript("onLeave", function()
        for _, g in pairs(movers) do
            for _, m in pairs(g) do
                if m:IsShown() then
                    m.text:SetColor("accent")
                    m:SetFrameLevel(MOVER_PARENT_FRAME_LEVEL)
                    AF.FrameFadeIn(m, 0.25)
                end
            end
        end
    end)

    mover:SetScript("OnShow", function()
        if not mover._original then
            local p, _, _, x, y = owner:GetPoint()
            mover._original = {p, AF.RoundToDecimal(x, 1), AF.RoundToDecimal(y, 1)}
        end
    end)
end

---@param save function|table
function AF.UpdateMoverSave(owner, save)
    assert(owner.mover, string.format("no mover for %s", owner:GetName() or "owner"))
    owner.mover.save = save
end

---------------------------------------------------------------------
-- toggle movers
---------------------------------------------------------------------
function AF.ShowMovers(group)
    if InCombatLockdown() then return end
    if not moverParent then CreateMoverParent() end

    for g, gt in pairs(movers) do
        local show
        if not group then
            show = true
        else
            show = group == g
        end
        for _, m in pairs(gt) do
            if show and (type(m.owner.enabled) ~= "boolean" or m.owner.enabled) then
                m:Show()
            else
                m:Hide()
            end
        end
    end
    moverParent:Show()
    moverDialog:Show()
    if positionAdjustmentFrame then positionAdjustmentFrame:Hide() end
end

function AF.HideMovers()
    if InCombatLockdown() or not moverParent then return end

    for _, g in pairs(movers) do
        for _, m in pairs(g) do
            m:Hide()
            m._original = nil
        end
    end
    moverParent:Hide()
    if positionAdjustmentFrame then positionAdjustmentFrame:Hide() end
end

function AF.ToggleMovers()
    if InCombatLockdown() then return end
    if not (moverParent and moverParent:IsShown()) then
        AF.ShowMovers()
    else
        AF.HideMovers()
    end
end

function AF.UndoMovers()
    if InCombatLockdown() then return end
    if not moverParent:IsShown() then return end

    for _, g in pairs(movers) do
        for _, m in pairs(g) do
            if m._original then
                UpdateAndSave(m.owner, m._original[1], m._original[2], m._original[3], true)
            end
        end
    end
    if positionAdjustmentFrame then positionAdjustmentFrame:Hide() end
end