---@class BFC
local BFC = select(2, ...)
---@type AbstractFramework
local AF = _G.AbstractFramework
local L = BFC.L

local BFCMainFrame = AF.CreateHeaderedFrame(AF.UIParent, "BFCMainFrame", L["BFCraftsman"], 350, 575, nil, 100)
BFCMainFrame:SetPoint("LEFT", AF.UIParent, "CENTER", 200, 0)

---------------------------------------------------------------------
-- BN events
---------------------------------------------------------------------
BFCMainFrame:RegisterEvent("BN_CONNECTED")
BFCMainFrame:RegisterEvent("BN_DISCONNECTED")
BFCMainFrame:SetScript("OnEvent", function()
    if BNConnected() then
        AF.HideMask(BFCMainFrame)
    else
        AF.ShowMask(BFCMainFrame, BN_CHAT_DISCONNECTED)
    end
end)

---------------------------------------------------------------------
-- init widgets
---------------------------------------------------------------------
local function InitFrameWidgets()
    -- slider
    local slider = AF.CreateSlider(BFCMainFrame.header, nil, 50, 1, 2, 0.05)
    AF.SetPoint(slider, "LEFT", BFCMainFrame.header, 5, 0)
    slider:SetEditBoxShown(false)
    slider:SetValue(BFC_DB.scale)
    slider:SetAfterValueChanged(function(value)
        BFC_DB.scale = value
        BFCMainFrame:SetScale(value)
        AF.UpdatePixelsForAddon()
    end)

    -- about
    local aboutButton = AF.CreateButton(BFCMainFrame.header, nil, "accent_hover", 20, 20)
    AF.SetPoint(aboutButton, "BOTTOMRIGHT", BFCMainFrame.header.closeBtn, "BOTTOMLEFT", 1, 0)
    aboutButton:SetTexture(AF.GetIcon("Question1"), {14, 14})
    aboutButton:SetOnClick(BFC.ToggleAboutFrame)

    -- switch
    local switch = AF.CreateSwitch(BFCMainFrame, 330, 20)
    AF.SetPoint(switch, "TOPLEFT", BFCMainFrame, "TOPLEFT", 10, -10)
    switch:SetLabels({
        {
            text = L["Browse"],
            value = "Browse",
            onClick = AF.GetFireFunc("BFC_ShowFrame", "Browse")
        },
        {
            text = L["Publish"],
            value = "Publish",
            onClick = AF.GetFireFunc("BFC_ShowFrame", "Publish")
        },
        {
            text = L["Config"],
            value = "Config",
            onClick = AF.GetFireFunc("BFC_ShowFrame", "Config")
        }
    })
    switch:SetSelectedValue("Browse")
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
local init
function BFC.ToggleMainFrame()
    if not init then
        BFCMainFrame:UpdatePixels()
        InitFrameWidgets()
        init = true
    end
    BFCMainFrame:Toggle()
end