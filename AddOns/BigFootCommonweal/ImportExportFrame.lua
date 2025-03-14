---@class BFC
local BFC = select(2, ...)

local Serializer = LibStub:GetLibrary("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local deflateConfig = {level = 9}

local importExportFrame, confirmDialog
local tipText, errorText, editboxContainer, scrollingEditBox, importButton
local mode, exportedStr, importedData

---------------------------------------------------------------------
-- HighlightText
---------------------------------------------------------------------
local function HighlightText()
    scrollingEditBox.eb:HighlightText()
end

---------------------------------------------------------------------
-- DoImport
---------------------------------------------------------------------
local function DoImport()
    if not importedData then return end
    BFC.ProcessImportedCraftsmanData(importedData.data, importedData.updateTime)
    BFC.ReloadCraftsmanData()
    importedData = nil
end

---------------------------------------------------------------------
-- OnTextChanged
---------------------------------------------------------------------
local function OnTextChanged(_, _, userChanged)
    if mode == "export" then
        -- refill text
        scrollingEditBox:SetText(exportedStr)
        HighlightText()

    elseif mode == "import" then
        -- import
        if userChanged then
            local text = scrollingEditBox.eb:GetText()
            if text ~= "" then
                local type, data = string.match(scrollingEditBox.eb:GetText(), "^!BFC:(%u+)!(.+)$")
                if type and data then
                    local success
                    data = LibDeflate:DecodeForPrint(data) -- decode
                    -- print("LibDeflate.DecodeForPrint:", data)
                    success, data = pcall(LibDeflate.DecompressDeflate, LibDeflate, data) -- decompress
                    -- print("LibDeflate.DecompressDeflate:", success, data)
                    success, data = Serializer:Deserialize(data) -- deserialize
                    -- print("LibSerialize.Deserialize:", success, data)

                    if success and data then
                        if data.updateTime >= BFCCraftsman.localUpdateTime then
                            importedData = data
                            importButton:SetEnabled(true)
                            errorText:SetText("")
                            -- texplore(importedData)
                        else
                            importedData = nil
                            importButton:SetEnabled(false)
                            errorText:SetText("无法导入过旧的数据")
                        end
                    else
                        importedData = nil
                        importButton:SetEnabled(false)
                        errorText:SetText("无法解析此字符串")
                    end
                else
                    importedData = nil
                    importButton:SetEnabled(false)
                    errorText:SetText("无法解析此字符串")
                end
            else
                importedData = nil
                importButton:SetEnabled(false)
                errorText:SetText("")
            end
        end
    end
end

---------------------------------------------------------------------
-- CreateConfirmDialog
---------------------------------------------------------------------
local function CreateConfirmDialog()
    confirmDialog = CreateFrame("Frame", "BFC_ImportExportConfirm", importExportFrame, "PortraitFrameTemplate")
    confirmDialog:SetFrameLevel(BFC_MainFrame:GetFrameLevel() + 1500)
    confirmDialog:SetSize(300, 140)
    confirmDialog:SetPoint("CENTER")
    ButtonFrameTemplate_HidePortrait(confirmDialog)
    confirmDialog:Hide()

    confirmDialog:SetScript("OnShow", function()
        BFC_MainFrameMask:SetFrameLevel(BFC_MainFrame:GetFrameLevel() + 1000)
    end)

    confirmDialog:SetScript("OnHide", function()
        confirmDialog:Hide()
        BFC_MainFrameMask:SetFrameLevel(BFC_MainFrame:GetFrameLevel() + 200)
    end)

    local message = confirmDialog:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    confirmDialog.message = message
    message:SetPoint("TOPLEFT", 20, -50)
    message:SetPoint("TOPRIGHT", -20, -50)
    message:SetText("所有工匠数据将被覆盖！")
    message:SetTextColor(1, 0, 0)

    local yes = CreateFrame("Button", nil, confirmDialog, "UIPanelButtonTemplate")
    yes:SetPoint("BOTTOMLEFT", 35, 20)
    yes:SetWidth(100)
    yes:SetText("确定")
    yes:SetScript("OnClick", function()
        DoImport()
        importExportFrame:Hide()
    end)

    local no = CreateFrame("Button", nil, confirmDialog, "UIPanelButtonTemplate")
    no:SetPoint("BOTTOMRIGHT", -30, 20)
    no:SetWidth(100)
    no:SetText("取消")
    no:SetScript("OnClick", function()
        confirmDialog:Hide()
    end)
end

---------------------------------------------------------------------
-- CreateImportExportFrame
---------------------------------------------------------------------
local function CreateImportExportFrame()
    importExportFrame = CreateFrame("Frame", "BFC_ImportExportFrame", BFC_MainFrame, "PortraitFrameTemplate")
    importExportFrame:SetFrameLevel(BFC_MainFrame:GetFrameLevel() + 300)
    importExportFrame:SetHeight(300)
    importExportFrame:SetPoint("TOPLEFT", 55, -70)
    importExportFrame:SetPoint("TOPRIGHT", -50, -70)
    ButtonFrameTemplate_HidePortrait(importExportFrame)
    importExportFrame:Hide()

    importExportFrame:SetScript("OnShow", function()
        BFC_MainFrameMask:Show()
    end)
    importExportFrame:SetScript("OnHide", function()
        importExportFrame:Hide()
        BFC_MainFrameMask:Hide()
    end)

    -- editbox container
    editboxContainer = CreateFrame("Frame", nil, importExportFrame, "TooltipBackdropTemplate")
    editboxContainer:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    editboxContainer:SetBackdropBorderColor(0.9, 0.9, 0.9, 1)
    editboxContainer:SetPoint("TOPLEFT", 30, -55)
    editboxContainer:SetPoint("BOTTOMRIGHT", -25, 40)

    -- tip text
    tipText = importExportFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    tipText:SetPoint("BOTTOMLEFT", editboxContainer, "TOPLEFT", 0, 5)
    tipText:SetTextColor(1, 1, 0)

    -- error text
    errorText = importExportFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    errorText:SetPoint("BOTTOMRIGHT", editboxContainer, "TOPRIGHT", 0, 5)
    errorText:SetTextColor(1, 0, 0)

    -- scrollingEditBox
    scrollingEditBox = CreateFrame("Frame", "BFC_ImportExportEditBox", editboxContainer, "ScrollingEditBoxTemplate")
    scrollingEditBox:SetPoint("TOPLEFT", 4, -4)
    scrollingEditBox:SetPoint("BOTTOMRIGHT", -3, 4)
    scrollingEditBox:SetScript("OnMouseUp", HighlightText)
    scrollingEditBox.eb = scrollingEditBox:GetEditBox()
    scrollingEditBox.eb:RegisterCallback("OnMouseUp", HighlightText)
    scrollingEditBox.eb:RegisterCallback("OnTextChanged", OnTextChanged)

    -- scroll bar
    local scrollBar = CreateFrame("EventFrame", nil, editboxContainer, "MinimalScrollBar")
    scrollBar:SetPoint("TOPRIGHT", -10, -5)
    scrollBar:SetPoint("BOTTOMRIGHT", -10, 5)

    local scrollBox = scrollingEditBox:GetScrollBox()
    ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)

    local scrollBoxAnchorsWithBar = {
        CreateAnchor("TOPLEFT", scrollingEditBox, "TOPLEFT", 0, 0),
        CreateAnchor("BOTTOMRIGHT", scrollingEditBox, "BOTTOMRIGHT", -23, 0),
    }
    local scrollBoxAnchorsWithoutBar = {
        scrollBoxAnchorsWithBar[1],
        CreateAnchor("BOTTOMRIGHT", scrollingEditBox, "BOTTOMRIGHT", -2, 0),
    }
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)

    -- import button
    importButton = CreateFrame("Button", nil, importExportFrame, "UIPanelButtonTemplate")
    importButton:SetPoint("TOPLEFT", editboxContainer, "BOTTOMLEFT", 0, -5)
    importButton:SetPoint("TOPRIGHT", editboxContainer, "BOTTOMRIGHT", 0, -5)
    importButton:SetText("导入")
    importButton:SetScript("OnClick", function()
        confirmDialog:Show()
    end)

    CreateConfirmDialog()
end

---------------------------------------------------------------------
-- export
---------------------------------------------------------------------
function BFC.ShowExportFrame()
    if not importExportFrame then
        CreateImportExportFrame()
    end

    mode = "export"

    tipText:SetText("导出的数据仅包含当前（大）服务器")
    errorText:SetText("")
    editboxContainer:SetPoint("BOTTOMRIGHT", -25, 20)
    importButton:Hide()

    -- local testData = {
    --     updateTime = 1725650000,
    --     data = {
    --         {
    --             title = "619装等[永铸防御者] 稳5星 3星材料1星公函，下单：篠崎",
    --             categoryName = "盾牌",
    --             itemName = "永铸防御者",
    --             itemLevel = 619,
    --             price = 6666,
    --             serverName = "影之哀伤",
    --             gameCharacterName = "篠崎"
    --         },
    --     }
    -- }
    -- exportedStr = Serializer:Serialize(testData) -- serialize

    -- export
    exportedStr = Serializer:Serialize(BFC.loadedCraftsman) -- serialize
    exportedStr = LibDeflate:CompressDeflate(exportedStr, deflateConfig) -- compress
    exportedStr = LibDeflate:EncodeForPrint(exportedStr) -- encode
    exportedStr = "!BFC:CRAFT!" .. exportedStr
    scrollingEditBox:SetText(exportedStr)
    scrollingEditBox.eb:HighlightText()

    importExportFrame.TitleContainer.TitleText:SetText("工匠数据导出")
    importExportFrame:Show()
end

---------------------------------------------------------------------
-- import
---------------------------------------------------------------------
function BFC.ShowImportFrame()
    if not importExportFrame then
        CreateImportExportFrame()
    end

    mode = "import"
    importedData = nil

    tipText:SetText("导入的数据仅保留当前（大）服务器")
    errorText:SetText("")
    editboxContainer:SetPoint("BOTTOMRIGHT", -25, 40)
    scrollingEditBox:SetText("")
    importButton:SetEnabled(false)
    importButton:Show()

    importExportFrame.TitleContainer.TitleText:SetText("工匠数据导入")
    importExportFrame:Show()
end