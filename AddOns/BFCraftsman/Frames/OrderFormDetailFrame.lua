---@class BFC
local BFC = select(2, ...)
local L = BFC.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local detailFrame
local checkTimer
local FRAME_HEIGHT = 210

---------------------------------------------------------------------
-- send chat msg
---------------------------------------------------------------------
local SendChatMessage = SendChatMessage
local GetTradeSkillDisplayName = C_TradeSkillUI.GetTradeSkillDisplayName
local GetRecipeInfo = C_TradeSkillUI.GetRecipeInfo
local RECRAFT = "(" .. strlower(_G.PROFESSIONS_CRAFTING_RECRAFT) .. ")"

local formatter = {
    p = function()
        return GetTradeSkillDisplayName(detailFrame.professionID) or ""
    end,
    f = function()
        local craftingFee = BFC_DB.list[detailFrame.id].craftingFee
        return craftingFee and craftingFee .. "g" or ""
    end,
    r = function()
        local info = GetRecipeInfo(detailFrame.recipeID)
        local link = info and info.hyperlink or ""
        if ProfessionsCustomerOrdersFrame.Form.order.isRecraft then
            return link .. RECRAFT
        else
            return link
        end
    end,
    c = function()
        local name = BFC_DB.list[detailFrame.id].name
        return name and AF.ToShortName(name) or ""
    end,
}

local function SendTemplateWhisper()
    local msg = BFC_DB.whisperTemplate:gsub("%[(%w)%]", function(s)
        return formatter[s] and formatter[s]() or ""
    end)
    SendChatMessage("[" .. L["BFC"] ..  "] " .. msg, "WHISPER", nil, BFC_DB.list[detailFrame.id].name)
end

---------------------------------------------------------------------
-- CHAT_MSG_SYSTEM
---------------------------------------------------------------------
-- local ERR_CHAT_PLAYER_NOT_FOUND_S = ERR_CHAT_PLAYER_NOT_FOUND_S
-- local PLAYER_OFFLINE = PLAYER_OFFLINE

-- local function CHAT_MSG_SYSTEM(_, _, msg)
--     if not BFC_DB.list[detailFrame.id] then return end
--     local name = BFC_DB.list[detailFrame.id].name
--     local msg1 = ERR_CHAT_PLAYER_NOT_FOUND_S:format(name)
--     local msg2 = ERR_CHAT_PLAYER_NOT_FOUND_S:format(AF.ToShortName(name))
--     if msg == msg1 or msg == msg2 then
--         if checkTimer then checkTimer:Cancel() end
--         detailFrame.sendWhisperButton:SetText(PLAYER_OFFLINE)
--         detailFrame.sendWhisperButton:SetColor("red")
--     end
-- end

---------------------------------------------------------------------
-- crafter list
---------------------------------------------------------------------
local function GetCraftersOnMyServer(t)
    if not t then return end
    local craftersOnMyServer = {}
    for _, crafter in pairs(t) do
        if AF.IsConnectedRealm(crafter[1]) then -- and (crafter[3] == AF.player.faction or not crafter[3]) then
            -- NOTE: same realm, same faction, or no faction (old data)
            tinsert(craftersOnMyServer, crafter)
        end
    end
    return craftersOnMyServer
end

local crafterPanePool = AF.CreateObjectPool(function()
    local f = AF.CreateFrame(detailFrame, nil, nil, 20)

    local b = AF.CreateButton(f, nil, "green", 20, 20)
    f.b = b
    b:SetTexture(AF.GetIcon("ArrowLeft1"))
    b:SetPoint("TOPLEFT")
    b:SetClickSound("bell")
    b:SetOnClick(function()
        local t = BFC_DB.list[detailFrame.id]
        if t then
            -- for k, v in ProfessionsCustomerOrdersFrame.Form.OrderRecipientDropdown:GetMenuDescription():EnumerateElementDescriptions() do
            --     if k == 3 then
            --         ProfessionsCustomerOrdersFrame.Form.OrderRecipientDropdown:Pick(v, 0)
            --         break
            --     end
            -- end
            ProfessionsCustomerOrdersFrame.Form.OrderRecipientDropdown:Increment()
            ProfessionsCustomerOrdersFrame.Form.OrderRecipientDropdown:Increment()
            ProfessionsCustomerOrdersFrame.Form.OrderRecipientTarget:SetText(f.name)
            ProfessionsCustomerOrdersFrame.Form.PaymentContainer.TipMoneyInputFrame.GoldBox:SetText(t.craftingFee or 0)
        end
    end)

    local eb = AF.CreateEditBox(f, nil, nil, 20)
    AF.SetPoint(eb, "TOPLEFT", b, "TOPRIGHT", -1, 0)
    AF.SetPoint(eb, "BOTTOMRIGHT")

    function f:Load(t)
        f.name = t[1]
        local faction = AF.GetIconString(t[3] and ("Faction_" .. t[3]))
        eb:SetText(faction .. AF.WrapTextInColor(t[1], t[2]))
        eb:SetCursorPosition(0)
    end

    return f
end, function(_, f)
    f:Hide()
end)

local function ShowCrafters(crafters)
    if AF.IsEmpty(crafters) then return end

    for _, t in pairs(crafters) do
        local f = crafterPanePool:Acquire()
        f:Load(t)
    end

    local widgets = crafterPanePool:GetAllActives()
    AF.AnimatedResize(detailFrame, nil, FRAME_HEIGHT + 5 + #widgets * 25, nil, nil, nil, function()
        detailFrame.separator:Show()

        for i, f in pairs(widgets) do
            AF.ClearPoints(f)
            AF.SetPoint(f, "RIGHT", -5, 0)
            if i == 1 then
                AF.SetPoint(f, "TOPLEFT", detailFrame.separator, "BOTTOMLEFT", 0, -5)
            else
                AF.SetPoint(f, "TOPLEFT", widgets[i - 1], "BOTTOMLEFT", 0, -5)
            end
            f:Show()
        end

        if not BFC_DB.orderDetailHelpViewed then
            AF.ShowHelpTip({
                widget = widgets[#widgets].b,
                position = "BOTTOM",
                text = L["Click to auto-fill name and fee"],
                width = 220,
                glow = true,
                callback = function()
                    BFC_DB.orderDetailHelpViewed = true
                end,
            })
        end
    end)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateDetailFrame()
    detailFrame = AF.CreateHeaderedFrame(BFCOrderFormListFrame, "BFCOrderFormListDetailFrame", L["Details"], 170, FRAME_HEIGHT)
    AF.SetPoint(detailFrame, "TOPLEFT", BFCOrderFormListFrame, "TOPRIGHT", 5, 0)
    detailFrame:SetMovable(false)
    detailFrame:SetTitleJustify("LEFT")

    detailFrame:SetOnHide(function()
        detailFrame:Hide()
        AF.SetHeight(detailFrame, FRAME_HEIGHT)
        -- detailFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
    end)

    -- name editbox
    local nameEditBox = AF.CreateEditBox(detailFrame, nil, nil, 20)
    AF.SetPoint(nameEditBox, "TOPLEFT", detailFrame, 5, -5)
    AF.SetPoint(nameEditBox, "TOPRIGHT", detailFrame, -5, -5)
    nameEditBox:SetNotUserChangable(true)

    -- tagline
    local taglineEditBox = AF.CreateScrollEditBox(detailFrame, nil, nil, nil, 100)
    AF.SetPoint(taglineEditBox, "TOPLEFT", nameEditBox, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(taglineEditBox, "TOPRIGHT", nameEditBox, "BOTTOMRIGHT", 0, -5)
    taglineEditBox:SetNotUserChangable(true)

    -- send whisper button
    local sendWhisperButton = AF.CreateButton(detailFrame, L["Send Whisper"], {"static", "sheet_cell_highlight"}, nil, 20)
    detailFrame.sendWhisperButton = sendWhisperButton
    AF.SetPoint(sendWhisperButton, "TOPLEFT", taglineEditBox, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(sendWhisperButton, "TOPRIGHT", taglineEditBox, "BOTTOMRIGHT", 0, -5)
    sendWhisperButton:SetOnClick(function()
        if BFC_DB.list[detailFrame.id] then
            BFC.SendWhisper(BFC_DB.list[detailFrame.id].name)
        end
    end)

    -- template whisper button
    local templateWhisperButton = AF.CreateButton(detailFrame, L["Template Whisper"], {"static", "sheet_cell_highlight"}, nil, 20)
    detailFrame.templateWhisperButton = templateWhisperButton
    AF.SetPoint(templateWhisperButton, "TOPLEFT", sendWhisperButton, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(templateWhisperButton, "TOPRIGHT", sendWhisperButton, "BOTTOMRIGHT", 0, -5)
    templateWhisperButton:SetOnClick(function()
        templateWhisperButton:SetEnabled(false)
        templateWhisperButton:SetText(5)
        templateWhisperButton.countdown = 5
        templateWhisperButton.timer = C_Timer.NewTicker(1, function()
            templateWhisperButton.countdown = templateWhisperButton.countdown - 1
            templateWhisperButton:SetText(templateWhisperButton.countdown)
            if templateWhisperButton.countdown <= 0 then
                templateWhisperButton:SetText(L["Template Whisper"])
                templateWhisperButton.timer = nil
                templateWhisperButton:SetEnabled(not (AF.IsEmpty(detailFrame.crafters) or AF.IsBlank(BFC_DB.whisperTemplate)))
            end
        end, 5)

        -- send
        SendTemplateWhisper()
    end)

    function templateWhisperButton:Reset()
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
            self:SetText(L["Template Whisper"])
            self:SetEnabled(not AF.IsBlank(BFC_DB.whisperTemplate))
        end
    end

    -- check button
    local checkButton = AF.CreateButton(detailFrame, L["Can Craft?"], "yellow", nil, 20)
    detailFrame.checkButton = checkButton
    AF.SetPoint(checkButton, "TOPLEFT", templateWhisperButton, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(checkButton, "TOPRIGHT", templateWhisperButton, "BOTTOMRIGHT", 0, -5)
    checkButton:SetOnClick(function()
        if not IsAltKeyDown() and detailFrame.isChecking then
            return
        end

        detailFrame.isChecking = true
        checkButton:SetText(L["Checking..."])
        checkButton:SetColor("yellow")
        if checkTimer then checkTimer:Cancel() end

        checkTimer = C_Timer.NewTimer(5, function()
            checkButton:SetText(L["Timeout"])
            checkButton:SetColor("red")
            detailFrame.isChecking = nil
        end)
        BFC.CheckCanCraft(detailFrame.id, detailFrame.recipeID)
    end)

    -- separator
    local separator = AF.CreateSeparator(detailFrame, nil, 1)
    detailFrame.separator = separator
    separator:Hide()
    AF.SetPoint(separator, "TOPLEFT", checkButton, "BOTTOMLEFT", 0, -5)
    AF.SetPoint(separator, "TOPRIGHT", checkButton, "BOTTOMRIGHT", 0, -5)

    -- load
    function detailFrame:Load(id)
        if checkTimer then checkTimer:Cancel() end
        detailFrame.isChecking = nil

        if not BFC_DB.list[id] then
            detailFrame:Hide()
            return
        end

        separator:Hide()
        crafterPanePool:ReleaseAll()
        AF.SetHeight(detailFrame, FRAME_HEIGHT)

        detailFrame.id = id
        detailFrame.recipeID = BFC.GetOrderRecipeID()
        detailFrame.professionID = BFC.GetOrderProfessionID()
        detailFrame.crafters = GetCraftersOnMyServer(BFC_DB.list[id].recipes[detailFrame.recipeID])

        nameEditBox:SetText(BFC_DB.list[id].name)
        nameEditBox:SetTextColor(AF.GetClassColor(BFC_DB.list[id].class))
        nameEditBox:SetCursorPosition(0)

        taglineEditBox:SetText(BFC_DB.list[id].tagline or "")

        if not AF.IsEmpty(detailFrame.crafters) then
            checkButton:SetText(L["Can Craft"])
            checkButton:SetColor("green")
            if not templateWhisperButton.timer then
                templateWhisperButton:SetEnabled(not AF.IsBlank(BFC_DB.whisperTemplate))
            end
        else
            checkButton:SetText(L["Can Craft?"])
            checkButton:SetColor("yellow")
            templateWhisperButton:SetEnabled(false)
        end

        -- detailFrame:RegisterEvent("CHAT_MSG_SYSTEM")
        C_Timer.After(0.25, function()
            ShowCrafters(detailFrame.crafters)
        end)
    end
end

---------------------------------------------------------------------
-- comm
---------------------------------------------------------------------
function BFC.NotifyCanCraft(id, recipeID, crafters)
    if not (detailFrame and detailFrame.id == id) then return end
    if checkTimer then checkTimer:Cancel() end
    detailFrame.isChecking = nil

    detailFrame.crafters = GetCraftersOnMyServer(crafters)

    if not AF.IsEmpty(detailFrame.crafters) then
        detailFrame.checkButton:SetText(L["Can Craft"])
        detailFrame.checkButton:SetColor("green")
        if not detailFrame.templateWhisperButton.timer then
            detailFrame.templateWhisperButton:SetEnabled(not AF.IsBlank(BFC_DB.whisperTemplate))
        end

        detailFrame.separator:Hide()
        crafterPanePool:ReleaseAll()
        ShowCrafters(detailFrame.crafters)
    else
        detailFrame.checkButton:SetText(L["Cannot Craft"])
        detailFrame.checkButton:SetColor("red")
        detailFrame.templateWhisperButton:SetEnabled(false)
    end
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
function BFC.ShowOrderFormDetailFrame(id)
    if not detailFrame then
        CreateDetailFrame()
    end
    detailFrame:Load(id)
    detailFrame:Show()
end