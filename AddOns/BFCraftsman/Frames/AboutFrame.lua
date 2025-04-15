---@class BFC
local BFC = select(2, ...)
local L = BFC.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local aboutFrame

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateAboutFrame()
    aboutFrame = AF.CreateBorderedFrame(BFCMainFrame, "BFCAboutFrame", nil, 160, nil, "accent")
    AF.SetPoint(aboutFrame, "TOPLEFT", BFCMainFrame, 10, -10)
    AF.SetPoint(aboutFrame, "TOPRIGHT", BFCMainFrame, -10, -10)
    AF.SetFrameLevel(aboutFrame, 100)
    aboutFrame:Hide()

    aboutFrame:SetOnShow(function()
        AF.ShowMask(BFCMainFrame)
    end)

    aboutFrame:SetOnHide(function()
        AF.HideMask(BFCMainFrame)
        aboutFrame:Hide()
    end)

    -- close
    local closeBtn = AF.CreateCloseButton(aboutFrame)
    AF.SetPoint(closeBtn, "TOPRIGHT")
    closeBtn:SetBorderColor("accent")

    -- feedback (Cn)
    local feedbackCnEditBox = AF.CreateEditBox(aboutFrame, nil, nil, 20)
    AF.SetPoint(feedbackCnEditBox, "TOPLEFT", 10, -35)
    AF.SetPoint(feedbackCnEditBox, "RIGHT", -10, 0)
    feedbackCnEditBox:SetNotUserChangable(true)
    feedbackCnEditBox:SetText("https://kook.vip/zLbWWR")

    local feedbackCnText = AF.CreateFontString(aboutFrame, AF.EscapeIcon(AF.GetLogo("kook"), 18) .. " " .. AF.L["Feedback & Suggestions"] .. " (CN)")
    AF.SetPoint(feedbackCnText, "BOTTOMLEFT", feedbackCnEditBox, "TOPLEFT", 2, 2)
    feedbackCnText:SetColor("accent")

    -- feedback (En)
    local feedbackEnEditBox = AF.CreateEditBox(aboutFrame, nil, nil, 20)
    AF.SetPoint(feedbackEnEditBox, "TOPLEFT", feedbackCnEditBox, "BOTTOMLEFT", 0, -35)
    AF.SetPoint(feedbackEnEditBox, "RIGHT", feedbackCnEditBox)
    feedbackEnEditBox:SetNotUserChangable(true)
    feedbackEnEditBox:SetText("https://discord.gg/9PSe3fKQGJ")

    local feedbackEnText = AF.CreateFontString(aboutFrame, AF.EscapeIcon(AF.GetLogo("discord"), 18) .. " ".. AF.L["Feedback & Suggestions"] .. " (EN)")
    AF.SetPoint(feedbackEnText, "BOTTOMLEFT", feedbackEnEditBox, "TOPLEFT", 2, 2)
    feedbackEnText:SetColor("accent")

    -- author
    local authorText = AF.CreateFontString(aboutFrame, AF.WrapTextInColor(AF.L["Author"] .. ": ", "accent") .. "enderneko")
    AF.SetPoint(authorText, "TOPLEFT", feedbackEnEditBox, "BOTTOMLEFT", 0, -20)

    -- version
    local versionText = AF.CreateFontString(aboutFrame, AF.WrapTextInColor(AF.L["Version"] .. ": ", "accent") .. AF.GetAddOnMetadata("Version"))
    AF.SetPoint(versionText, "LEFT", aboutFrame, "BOTTOM", 10, 0)
    AF.SetPoint(versionText, "BOTTOM", authorText)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFC.ToggleAboutFrame()
    if not aboutFrame then
        CreateAboutFrame()
    end
    aboutFrame:Toggle()
end