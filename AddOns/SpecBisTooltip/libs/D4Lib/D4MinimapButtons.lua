local _, D4 = ...
local deg, atan2 = math.deg, math.atan2
local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
local mmShapes = {
    ["ROUND"] = {true, true, true, true},
    ["SQUARE"] = {false, false, false, false},
    ["CORNER-TOPLEFT"] = {false, false, false, true},
    ["CORNER-TOPRIGHT"] = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
    ["SIDE-LEFT"] = {false, true, false, true},
    ["SIDE-RIGHT"] = {true, false, true, false},
    ["SIDE-TOP"] = {false, false, true, true},
    ["SIDE-BOTTOM"] = {true, true, false, false},
    ["TRICORNER-TOPLEFT"] = {false, true, true, true},
    ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local pos = {}
function D4:UpdatePosition(button, position, parent)
    parent = parent or Minimap
    pos[button] = position or 225
    local angle = rad(pos[button])
    local x, y, q = cos(angle), sin(angle), 1
    if x < 0 then
        q = q + 1
    end

    if y > 0 then
        q = q + 2
    end

    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local qt = mmShapes[minimapShape]
    local w = (Minimap:GetWidth() / 2) + button:GetWidth() / 2 - button:GetWidth() / 5
    local h = (Minimap:GetHeight() / 2) + button:GetHeight() / 2 - button:GetHeight() / 5
    w = w / button:GetScale()
    h = h / button:GetScale()
    if qt[q] then
        x, y = x * w, y * h
    else
        local drw = sqrt(2 * w ^ 2) - 10
        local drh = sqrt(2 * h ^ 2) - 10
        x = max(-w, min(x * drw, w))
        y = max(-h, min(y * drh, h))
    end

    if InCombatLockdown() and button:IsProtected() then
        D4:After(
            0.1,
            function()
                D4:UpdatePosition(button, position, parent)
            end, "UpdatePosition"
        )

        return false
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", parent, "CENTER", x, y)

    return true
end

function D4:GetMMBtn(name)
    return _G[name]
end

function D4:CreateMinimapButton(params)
    if params.icon == nil and params.atlas == nil then
        D4:MSG("[CreateMinimapButton] Missing Icon/Atlas")

        return
    end

    if params.name == nil then
        D4:MSG("[CreateMinimapButton] Missing Name")

        return
    end

    if params.dbtab == nil then
        D4:MSG("[CreateMinimapButton] Missing Database")

        return
    end

    params.sw = params.sw or 31
    params.sh = params.sh or 31
    if params.border == nil then
        params.border = true
    end

    params.dbtab[params.name] = params.dbtab[params.name] or {}
    _G["MinimapButton_D4Lib_LibDBIcon_" .. params.name] = CreateFrame("Button", "MinimapButton_D4Lib_LibDBIcon_" .. params.name, params.parent or Minimap)
    local btn = _G["MinimapButton_D4Lib_LibDBIcon_" .. params.name]
    btn:SetFrameLevel(501)
    btn.border = params.border
    btn.db = params.dbtab
    btn.db.minimapPos = btn.db.minimapPos or 0
    btn.minimapPos = btn.minimapPos or 0
    btn:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    btn.icon = btn:CreateTexture()
    btn.icon:SetPoint("CENTER")
    if params.icon ~= nil then
        btn.icon:SetTexture(params.icon)
        --btn.icon:SetMask("Interface\\AddOns\\ImproveAny\\media\\minimap_mask_round")
    elseif params.atlas ~= nil then
        local info = C_Texture.GetAtlasInfo(params.atlas)
        btn.icon:SetTexture(info.file)
        btn.icon:SetTexCoord(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord)
    end

    btn:SetSize(params.sw, params.sh)
    if params.point ~= nil and params.parent ~= nil then
        btn:SetPoint(unpack(params.point))
    else
        D4:UpdatePosition(btn, btn.db.minimapPos)
        btn:RegisterForClicks("AnyUp")
        btn:RegisterForDrag("LeftButton")
        btn:SetMovable(true)
        btn:SetScript(
            "OnDragStart",
            function(sel)
                sel.isMouseDown = true
                sel:SetScript(
                    "OnUpdate",
                    function(se)
                        local mx, my = Minimap:GetCenter()
                        local px, py = GetCursorPosition()
                        local scale = Minimap:GetEffectiveScale()
                        px, py = px / scale, py / scale
                        local posi = 0
                        if se.db then
                            posi = deg(atan2(py - my, px - mx)) % 360
                            se.db.minimapPos = posi
                        else
                            posi = deg(atan2(py - my, px - mx)) % 360
                            se.minimapPos = posi
                        end

                        D4:UpdatePosition(se, posi)
                    end
                )

                sel.tooltip:Hide()
            end
        )

        btn:SetScript(
            "OnDragStop",
            function(sel)
                sel:SetScript("OnUpdate", nil)
                sel.isMouseDown = false
            end
        )
    end

    btn.overlay = btn:CreateTexture(nil, "OVERLAY")
    if D4:GetWoWBuild() == "RETAIL" then
        btn.overlay:SetSize(params.sw * 0.95, params.sh * 0.95)
        btn.overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
        btn.overlay:SetPoint("CENTER", btn, "CENTER", -0.6, -0.2)
        btn.overlay:SetTexCoord(0, 0.6, 0, 0.6)
        btn.icon:SetSize(params.sw * 0.65, params.sh * 0.65)
    else
        btn.overlay:SetSize(params.sw * 0.95, params.sh * 0.95)
        btn.overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
        btn.overlay:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.overlay:SetTexCoord(0, 0.6, 0, 0.6)
        btn.icon:SetSize(params.sw * 0.65, params.sh * 0.65)
    end

    if params.border == false then
        btn.overlay:Hide()
    end

    btn:SetScript(
        "OnClick",
        function(sel, btnName)
            if sel.isMouseDown then return end
            if btnName == "LeftButton" and IsShiftKeyDown() and params.funcSL then
                params:funcSL()
            elseif btnName == "RightButton" and IsShiftKeyDown() and params.funcSR then
                params:funcSR()
            elseif btnName == "LeftButton" and params.funcL then
                params:funcL()
            elseif btnName == "RightButton" and params.funcR then
                params:funcR()
            end
        end
    )

    btn.tooltip = CreateFrame("GameTooltip", params.name .. "_tooltip", UIParent, "GameTooltipTemplate")
    btn:SetScript(
        "OnEnter",
        function(sel)
            btn.tooltip:SetOwner(sel, "ANCHOR_RIGHT")
            if params.vTT then
                for i, v in pairs(params.vTT) do
                    btn.tooltip:AddDoubleLine(v[1], v[2])
                end
            end

            if params.vTTUpdate then
                params:vTTUpdate(btn.tooltip)
            end

            btn.tooltip:Show()
        end
    )

    btn:SetScript(
        "OnLeave",
        function(sel)
            btn.tooltip:Hide()
        end
    )

    if AddonCompartmentFrame and (params.addoncomp == nil or params.addoncomp == true) then
        AddonCompartmentFrame:RegisterAddon(
            {
                text = params.name,
                icon = params.icon,
                registerForAnyClick = true,
                notCheckable = true,
                func = function(button, menuInputData, menu)
                    local btnName = menuInputData.buttonName
                    if btnName == "LeftButton" and IsShiftKeyDown() and params.funcSL then
                        params:funcSL()
                    elseif btnName == "RightButton" and IsShiftKeyDown() and params.funcSR then
                        params:funcSR()
                    elseif btnName == "LeftButton" and params.funcL then
                        params:funcL()
                    elseif btnName == "RightButton" and params.funcR then
                        params:funcR()
                    end
                end,
                funcOnEnter = function(button)
                    MenuUtil.ShowTooltip(
                        button,
                        function(tooltip)
                            if not tooltip or not tooltip.AddLine then return end
                            for i, v in pairs(params.vTT) do
                                tooltip:AddDoubleLine(v[1], v[2])
                            end
                        end
                    )
                end,
                funcOnLeave = function(button)
                    MenuUtil.HideTooltip(button)
                end,
            }
        )
    end

    if not params.noalpha then
        btn.fadeOut = btn:CreateAnimationGroup()
        local animOut = btn.fadeOut:CreateAnimation("Alpha")
        animOut:SetOrder(1)
        animOut:SetDuration(0.2)
        if animOut.SetFromAlpha then
            animOut:SetFromAlpha(1)
        end

        if animOut.SetToAlpha then
            animOut:SetToAlpha(0)
        end

        animOut:SetStartDelay(1)
        if btn.fadeOut and btn.fadeOut.SetToFinalAlpha then
            btn.fadeOut:SetToFinalAlpha(true)
        end

        btn.fadeIn = btn:CreateAnimationGroup()
        local animIn = btn.fadeIn:CreateAnimation("Alpha")
        animIn:SetOrder(1)
        animIn:SetDuration(0.2)
        if animIn.SetFromAlpha then
            animIn:SetFromAlpha(0)
        end

        if animIn.SetToAlpha then
            animIn:SetToAlpha(1)
        end

        animIn:SetStartDelay(0.2)
        if btn.fadeIn and btn.fadeIn.SetToFinalAlpha then
            btn.fadeIn:SetToFinalAlpha(true)
        end

        local oldState = false
        local function BtnThink()
            if oldState ~= MouseIsOver(btn) then
                oldState = MouseIsOver(btn)
                if MouseIsOver(btn) then
                    if D4:GetParent(btn) == Minimap then
                        btn.fadeOut:Stop()
                        btn.fadeIn:Play()
                        btn:SetAlpha(1)
                    else
                        btn.fadeOut:Stop()
                        btn.fadeIn:Stop()
                        btn:SetAlpha(1)
                    end
                else
                    if D4:GetParent(btn) == Minimap then
                        btn.fadeIn:Stop()
                        btn.fadeOut:Play()
                    else
                        btn.fadeOut:Stop()
                        btn.fadeIn:Stop()
                        btn:SetAlpha(1)
                    end
                end
            end
        end

        btn:HookScript(
            "OnEnter",
            function()
                BtnThink()
            end
        )

        btn:HookScript(
            "OnLeave",
            function()
                BtnThink()
            end
        )

        Minimap:HookScript(
            "OnEnter",
            function()
                BtnThink()
            end
        )

        Minimap:HookScript(
            "OnLeave",
            function()
                BtnThink()
            end
        )

        D4:After(
            4,
            function()
                if D4:GetParent(btn) == Minimap then
                    btn.fadeOut:Play()
                end
            end, "[D4] MinimapInit"
        )
    end

    if params.dbkey and params.dbkey ~= "" then
        if D4.IsEnabled then
            if D4:IsEnabled(params.dbkey, D4:GetWoWBuild() ~= "RETAIL") then
                D4:ShowMMBtn(params.name)
            else
                D4:HideMMBtn(params.name)
            end
        else
            if D4:GV(params.dbtab, params.dbkey, D4:GetWoWBuild() ~= "RETAIL") then
                D4:ShowMMBtn(params.name)
            else
                D4:HideMMBtn(params.name)
            end
        end
    elseif params.dbkey == nil then
        D4:MSG("Missing dbkey in CreateMinimapButton", params.name, params.dbkey)
    end

    return btn
end

function D4:ShowMMBtn(name)
    if name == nil then
        D4:MSG("[ShowMMBtn] Missing Name")

        return
    end

    local btn = D4:GetMMBtn("MinimapButton_D4Lib_LibDBIcon_" .. name)
    if btn then
        btn:Show()
    else
        D4:MSG("[ShowMMBtn] Missing Button", name)
    end
end

function D4:HideMMBtn(name)
    if name == nil then
        D4:MSG("[HideMMBtn] Missing Name")

        return
    end

    local btn = D4:GetMMBtn("MinimapButton_D4Lib_LibDBIcon_" .. name)
    if btn then
        btn:Hide()
    else
        D4:MSG("[HideMMBtn] Missing Button", name)
    end
end

function D4:UpdateLTP()
    local MinimapModder = LeaPlusDB and LeaPlusDB["MinimapModder"] and LeaPlusDB["MinimapModder"] == "On"
    if MinimapModder then
        local CombineAddonButtons = LeaPlusDB["CombineAddonButtons"] == "On"
        --local HideMiniAddonButtons = LeaPlusDB["HideMiniAddonButtons"] == "On"
        local btnParent = _G["LeaPlusGlobalMinimapCombinedButtonFrame"]
        D4:ForeachChildren(
            Minimap,
            function(child)
                local name = D4:GetName(child)
                if name then
                    local s1 = string.find(string.lower(name), "libdbicon")
                    if s1 and s1 > 1 and child.ltp == nil then
                        child.ltp = true
                        child:SetScale(0.75)
                        D4:UpdatePosition(child, pos[child])
                        if CombineAddonButtons and btnParent then
                            child:SetParent(btnParent)
                        end
                    end
                end
            end, "MMBtns"
        )
    end
end

D4:After(
    4,
    function()
        D4:UpdateLTP()
    end, "UpdateLTP"
)
