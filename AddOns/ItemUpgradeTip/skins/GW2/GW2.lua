-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local private = select(2, ...) ---@class PrivateNamespace

local GW = GW2_ADDON

local function SkinContainerFrame(frame)
    frame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(frame, frame:GetTitleText(), "Interface/AddOns/ItemUpgradeTip/skins/GW2/Textures/itemupgrade-window-icon", {
        IUTView.BountifulDelvesFrame,
        IUTView.MythicPlusFrame,
        IUTView.RaidFrame,
        IUTView.UpgradeFrame,
        IUTView.CraftingFrame,
        IUTView.InfoFrame
    }, -10, true, true)
    frame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/Auction/windowbg.png")
	frame.tex:SetTexCoord(0, 1, 0, 0.74)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "LEFT", -20, 3)
    frame:GetTitleText():SetPoint("BOTTOMLEFT", frame.gwHeader, "BOTTOMLEFT", 25, 10)
    frame:GetBreadcrumb():SetFont(DAMAGE_TEXT_FONT, 14)
    frame:GetBreadcrumb():SetTextColor(255 / 255, 241 / 255, 209 / 255)
    frame.CloseButton:GwSkinButton(true)
    frame.CloseButton:SetPoint("TOPRIGHT", -5, -2)

    for index, tab in next, frame.Tabs do
		if not tab.isSkinned then
			local id = index == 1 and "quickjoin"
                or index == 2 and "raid"
                or index == 3 and "delve"
                or index == 4 and "upgrade"
                or index == 5 and "craft"
                or index == 6 and "profiles"
                or "overview"
            ;
			local iconTexture = "Interface/AddOns/ItemUpgradeTip/skins/GW2/Textures/tabicon_" .. id
			GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
		end

		tab:ClearAllPoints()
		tab:SetPoint("TOPRIGHT", IUTViewLeftPanel, "TOPLEFT", 1, -32 + (-40 * (index - 1)))
		tab:SetParent(IUTViewLeftPanel)
		tab:SetSize(64, 40)
	end
end

local skinners = {
    EditBox = function(frame)
        GW.SkinTextBox(frame.Middle, frame.Left, frame.Right)
    end,
    ScrollArea = function(frame)
        GW.HandleTrimScrollBar(frame.ScrollBar)
        GW.HandleScrollControls(frame, "ScrollBar")

        hooksecurefunc(frame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

        GW.HandleItemListScrollBoxHover(frame.ScrollBox)
    end,
    ContainerFrame = function(frame)
        SkinContainerFrame(frame)
    end,
    NavBar = function(frame)
        GW.HandleSrollBoxHeaders(frame)
    end,
    NavBarButton = function(frame)
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _, c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:SetTextColor(1, 1, 1, 1)
                c:SetShadowOffset(0, 0)
            end
        end
        frame.tex = frame:CreateTexture(nil, "BACKGROUND")
        frame.tex:SetPoint("LEFT", frame, "LEFT")
        frame.tex:SetPoint("TOP", frame, "TOP")
        frame.tex:SetPoint("BOTTOM", frame, "BOTTOM")
        frame.tex:SetPoint("RIGHT", frame, "RIGHT")
        frame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner.png")
        frame.tex:SetAlpha(1)
    end,
    InsetFrame = function(frame)
        frame:Hide()
    end,
}

local function SkinFrame(details)
    local func = skinners[details.frameType]
    if func then
        func(details.frame, details.extraInfo)
    end
end

if GW then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function()
        ItemUpgradeTip:RegisterSkinListener(SkinFrame)

        for _, details in ipairs(ItemUpgradeTip:GetAllFrames()) do
            SkinFrame(details)
        end
    end)
end
