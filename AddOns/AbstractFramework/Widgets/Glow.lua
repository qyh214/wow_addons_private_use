---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- normal glow
---------------------------------------------------------------------
---@param parent Frame
---@param color? string
---@param size? number default is 5
---@param autoHide? boolean only available for the first call
function AF.ShowNormalGlow(parent, color, size, autoHide)
    if not parent.normalGlow then
        parent.normalGlow = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        AF.SetFrameLevel(parent.normalGlow, -1)

        if autoHide then
            parent.normalGlow:SetScript("OnHide", function() parent.normalGlow:Hide() end)
        end
    end

    parent.normalGlow.size = size or parent.normalGlow.size or 5
    parent.normalGlow.color = color or parent.normalGlow.color or "accent"
    -- parent.normalGlow.insets = insets or parent.normalGlow.insets

    AF.SetBackdrop(parent.normalGlow, {edgeFile = AF.GetTexture("StaticGlow"), edgeSize = parent.normalGlow.size})
    -- NOTE: insets not work well
    -- AF.SetBackdrop(parent.normalGlow, {edgeFile = AF.GetTexture("StaticGlow"), edgeSize = parent.normalGlow.size, insets = parent.normalGlow.insets})

    -- if type(insets) == "table" then
    --     AF.SetOutsets(parent.normalGlow, parent,
    --         parent.normalGlow.size + insets[1],
    --         parent.normalGlow.size + insets[2],
    --         parent.normalGlow.size + insets[3],
    --         parent.normalGlow.size + insets[4]
    --     )
    -- else
        AF.SetOutside(parent.normalGlow, parent, parent.normalGlow.size)
    -- end

    if type(parent.normalGlow.color) == "string" then
        parent.normalGlow:SetBackdropBorderColor(AF.GetColorRGB(parent.normalGlow.color))
    elseif type(parent.normalGlow.color) == "table" then
        parent.normalGlow:SetBackdropBorderColor(AF.UnpackColor(parent.normalGlow.color))
    end

    parent.normalGlow:Show()
end

function AF.HideNormalGlow(parent)
    if parent.normalGlow then
        parent.normalGlow:Hide()
    end
end

---------------------------------------------------------------------
-- callout glow
---------------------------------------------------------------------
---@param parent Frame
---@param blink boolean only available for the first call
---@param autoHide boolean only available for the first call
---@param relativeFrameLevel number? default is -1, only available for the first call
function AF.ShowCalloutGlow(parent, blink, autoHide, relativeFrameLevel)
    if not parent.calloutGlow then
        parent.calloutGlow = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        parent.calloutGlow:SetBackdrop({edgeFile = AF.GetTexture("CalloutGlow"), edgeSize = 7})
        parent.calloutGlow:SetBorderBlendMode("ADD")
        AF.SetOutside(parent.calloutGlow, parent, 4)
        AF.SetFrameLevel(parent.calloutGlow, relativeFrameLevel or -1)

        if autoHide then
            parent.calloutGlow:SetScript("OnHide", function() parent.calloutGlow:Hide() end)
        end

        if blink then
            AF.CreateBlinkAnimation(parent.calloutGlow, 0.5)
        end
    end

    parent.calloutGlow:Show()
end

function AF.HideCalloutGlow(parent)
    if parent.calloutGlow then
        parent.calloutGlow:Hide()
    end
end