---@class BFC
local BFC = select(2, ...)

---------------------------------------------------------------------
-- main frame
---------------------------------------------------------------------
local mainFrame = CreateFrame("Frame", "BFC_MainFrame", UIParent, "ButtonFrameTemplate") -- PortraitFrameTemplate
mainFrame:SetFrameStrata("HIGH")

-- base
ButtonFrameTemplate_HidePortrait(mainFrame)
mainFrame.Inset:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 11, -11)
-- FrameTemplate_SetAtticHeight(mainFrame, ATTIC_HEIGHT)
-- FrameTemplate_SetButtonBarHeight(mainFrame, 100)
mainFrame:SetSize(750, 400)
mainFrame:SetPoint("CENTER")
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:SetClampedToScreen(true)

-- drag & title
mainFrame.titleBar = CreateFrame("Frame", nil, mainFrame, "PanelDragBarTemplate")
mainFrame.titleBar:SetPoint("TOPLEFT")
mainFrame.titleBar:SetPoint("TOPRIGHT")
mainFrame.titleBar:SetHeight(32)
mainFrame.titleBar:Init(mainFrame)
-- mainFrame:SetTitle(BFC.displayedName)

-- resize
mainFrame:SetResizable(true)
mainFrame.resizeButton = CreateFrame("Button", nil, mainFrame, "PanelResizeButtonTemplate")
mainFrame.resizeButton:SetPoint("BOTTOMRIGHT")
mainFrame.resizeButton:Init(mainFrame, 750, 400, 1600, 900)

-- ESC
tinsert(UISpecialFrames, "BFC_MainFrame")

mainFrame:SetScript("OnHide", function()
    if not InCombatLockdown() then
        collectgarbage()
    end
end)

---------------------------------------------------------------------
-- refresh
---------------------------------------------------------------------
-- local refreshButton = CreateFrame("Button", "BFC_RefreshButton", mainFrame, "UIPanelButtonTemplate")
-- mainFrame.refreshButton = refreshButton
-- refreshButton:SetHeight(25)
-- refreshButton:SetTextToFit(_G.REFRESH)
-- refreshButton:SetPoint("TOPRIGHT", -10, -32)

---------------------------------------------------------------------
-- mask
---------------------------------------------------------------------
local maskFrame = CreateFrame("Frame", "BFC_MainFrameMask", mainFrame, "BackdropTemplate")
maskFrame:EnableMouse(true)
maskFrame:SetFrameLevel(mainFrame:GetFrameLevel() + 200)
maskFrame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8"})
maskFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
maskFrame:SetPoint("TOPLEFT", 5, -20)
maskFrame:SetPoint("BOTTOMRIGHT", -2, 2)
maskFrame:Hide()

maskFrame:SetScript("OnShow", function()
    mainFrame.resizeButton:SetEnabled(false)
end)
maskFrame:SetScript("OnHide", function()
    mainFrame.resizeButton:SetEnabled(true)
end)

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFC.ShowMainFrame()
    mainFrame:Show()
    BFC.ShowCraftsmanFrame()
end

function BFC.ToggleMainFrame()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        BFC.ShowCraftsmanFrame()
    end
end