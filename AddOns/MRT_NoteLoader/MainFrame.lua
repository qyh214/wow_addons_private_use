local _, MRT_NL = ...
local W = MRT_NL.widgets
local L = MRT_NL.L

local currentZone, currentEncounterID, currentEncounterName
local UpdateButtons, LoadList, LoadNoteNames
local isPersonal

local mainFrame =  W:CreateMovableFrame("MRT Note Loader", "MRT_NoteLoader", 370, 592, "DIALOG")
mainFrame:Hide()
mainFrame:ClearAllPoints()
mainFrame:SetPoint("TOPLEFT", 200, -200)
mainFrame:SetClampRectInsets(0, 0, 20, 385)

local scaleSlider = W:CreateSlider("", mainFrame.header, 1, 4, 50, 0.25, nil, function(value)
    MRT_NL_DB.scale = value
    mainFrame:SetScale(value)
end)
scaleSlider:SetPoint("TOPLEFT", 5, -5)
scaleSlider.lowText:Hide()
scaleSlider.highText:Hide()
scaleSlider.currentEditBox:Hide()

-- MRT.Options:Add(moduleName,frameName)
-- local MRT_OptionsFrameName = "MRTOptionsFrame"
-- local MRT_NoteModuleName = "Note"

local mrtBtn = W:CreateButton(mainFrame.header, "MRT", "blue", {50, 20})
mrtBtn:SetPoint("BOTTOMRIGHT", mainFrame.header.closeBtn, "BOTTOMLEFT", 1, 0)
mrtBtn:SetScript("OnClick", function()
    MRTOptionsFrame:Show()
    MRTOptionsFrame:SetPage(MRTOptionsFrameNote)
end)

-------------------------------------------------
-- send button
-------------------------------------------------
function MRT_NL:ShowSendButton(show)
    if show then
        if not MRT_NL_Send then
            MRT_NL_Send = W:CreateButton(MRTNote, "", "blue", {20, 20}, true)
            MRT_NL_Send:SetPoint("BOTTOMLEFT", MRTNote, "TOPLEFT")
            MRT_NL_Send:SetTexture("Interface\\AddOns\\MRT_NoteLoader\\Media\\chat", {16, 16}, {"CENTER", 0, 0})
            MRT_NL_Send:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            MRT_NL_Send:SetScript("OnClick", function(self, button)
                MRT_NL_Send:SetEnabled(false)
                MRT_NL:SendNote(button == "RightButton")
            end)
            hooksecurefunc(GMRT.A.Note.frame, "UpdateText", function()
                if MRT_NL_DB.showSendButton then
                    local note = GMRT.A.Note.frame.text:GetText()
                    if type(note) ~= "string" or strtrim(note) == "" then
                        MRT_NL_Send:Hide()
                    else
                        MRT_NL_Send:Show()
                    end
                end
            end)
        end
        MRT_NL_Send:Show()
    elseif MRT_NL_Send then
        MRT_NL_Send:Hide()
    end
end

-------------------------------------------------
-- info
-------------------------------------------------
local infoPane = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
infoPane:SetPoint("TOPLEFT")
infoPane:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", 0, -146)
infoPane:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
infoPane:SetBackdropBorderColor(0, 0, 0, 1)

-- zone
local zoneEB = W:CreateEditBox(infoPane, 337, 20)
zoneEB:SetPoint("TOPLEFT", 7, -10)

local zoneText = zoneEB:CreateFontString(nil, "OVERLAY", "MRT_NL_FONT_NORMAL")
zoneText:SetPoint("RIGHT", -2, 0)
zoneText:SetText(L["zone"])
zoneText:SetTextColor(0.7, 0.7, 0.7, 0.7)

local zoneRefreshBtn = W:CreateButton(infoPane, "", "accent", {20, 20})
zoneRefreshBtn:SetPoint("TOPLEFT", zoneEB, "TOPRIGHT", -1, 0)
zoneRefreshBtn:SetTexture("Interface\\AddOns\\MRT_NoteLoader\\Media\\refresh", {16, 16}, {"CENTER", 0, 0})
zoneRefreshBtn:SetScript("OnClick", function()
    zoneEB:SetText(currentZone)
end)

-- encounterID
local idEB = W:CreateEditBox(infoPane, 337, 20, false, false, true)
idEB:SetPoint("TOPLEFT", zoneEB, "BOTTOMLEFT", 0, -7)

local idText = idEB:CreateFontString(nil, "OVERLAY", "MRT_NL_FONT_NORMAL")
idText:SetPoint("RIGHT", -2, 0)
idText:SetText(L["encounterID"])
idText:SetTextColor(0.7, 0.7, 0.7, 0.7)

-- encounterName
local nameEB = W:CreateEditBox(infoPane, 337, 20)
nameEB:SetPoint("TOPLEFT", idEB, "BOTTOMLEFT", 0, -7)

local nameText = nameEB:CreateFontString(nil, "OVERLAY", "MRT_NL_FONT_NORMAL")
nameText:SetPoint("RIGHT", -2, 0)
nameText:SetText(L["encounterName"])
nameText:SetTextColor(0.7, 0.7, 0.7, 0.7)

local encounterRefreshBtn = W:CreateButton(infoPane, "", "accent", {20, 20})
encounterRefreshBtn:SetPoint("TOPLEFT", idEB, "TOPRIGHT", -1, 0)
encounterRefreshBtn:SetPoint("BOTTOMLEFT", nameEB, "BOTTOMRIGHT", -1, 0)
encounterRefreshBtn:SetTexture("Interface\\AddOns\\MRT_NoteLoader\\Media\\refresh", {16, 16}, {"CENTER", 0, 0})
encounterRefreshBtn:SetScript("OnClick", function()
    idEB:SetText(currentEncounterID or "")
    nameEB:SetText(currentEncounterName or "")
end)

-------------------------------------------------
-- notes
-------------------------------------------------
local noteDD = W:CreateDropdown(infoPane, 240)
noteDD:SetPoint("TOPLEFT", nameEB, "BOTTOMLEFT", 0, -7)

local noteText = noteDD:CreateFontString(nil, "OVERLAY", "MRT_NL_FONT_NORMAL")
noteText:SetPoint("RIGHT", -20, 0)
noteText:SetText(L["note"])
noteText:SetTextColor(0.7, 0.7, 0.7, 0.7)

local noteRefreshBtn = W:CreateButton(infoPane, "", "accent", {20, 20})
noteRefreshBtn:SetPoint("TOPLEFT", noteDD, "TOPRIGHT", -1, 0)
noteRefreshBtn:SetTexture("Interface\\AddOns\\MRT_NoteLoader\\Media\\refresh", {16, 16}, {"CENTER", 0, 0})
noteRefreshBtn:SetScript("OnClick", function()
    LoadNoteNames()
end)
W:RegisterForCloseDropdown(noteRefreshBtn)

local personalCB = W:CreateCheckButton(infoPane, "|cff90ee90"..L["Personal"], function(checked)
    if checked then
        isPersonal = true
    else
        isPersonal = nil
    end
end, {0.56, 0.93, 0.56, 0.6})
personalCB:SetPoint("BOTTOMLEFT", noteRefreshBtn, "BOTTOMRIGHT", 7, 3)

LoadNoteNames = function()
    local items = {}
    for i = 2, #VMRT.Note.Black do
        tinsert(items, {
            ["text"] = (VMRT.Note.BlackNames[i] and VMRT.Note.BlackNames[i] ~= "") and VMRT.Note.BlackNames[i] or i,
            ["onClick"] = function()
                UpdateButtons()
                personalCB:SetChecked(false)
                isPersonal = nil
            end,
        })
    end
    noteDD:SetItems(items)
end

-------------------------------------------------
-- create
-------------------------------------------------
-- add zone
local addZoneBtn = W:CreateButton(infoPane, "+ "..L["zone"], "accent", {114, 20})
addZoneBtn:SetEnabled(false)
addZoneBtn:SetPoint("TOPLEFT", noteDD, "BOTTOMLEFT", 0, -7)
zoneEB:SetScript("OnTextChanged", function()
    addZoneBtn:SetEnabled(noteDD.selected and zoneEB:GetText() ~= "")
end)
addZoneBtn:SetScript("OnClick", function()
    tinsert(MRT_NL_DB.autoload, {
        ["type"] = "zone",
        ["value"] = strtrim(zoneEB:GetText()),
        ["note"] = noteDD:GetSelected(),
        ["isPersonal"] = isPersonal,
    })
    MRT_NL:Fire("UpdateAutoload")
end)

-- add encounterID
local addIdBtn = W:CreateButton(infoPane, "+ "..L["eid"], "accent", {114, 20})
addIdBtn:SetEnabled(false)
addIdBtn:SetPoint("TOPLEFT", addZoneBtn, "TOPRIGHT", 7, 0)
idEB:SetScript("OnTextChanged", function()
    addIdBtn:SetEnabled(noteDD.selected and idEB:GetNumber() ~= 0)
end)
addIdBtn:SetScript("OnClick", function()
    tinsert(MRT_NL_DB.autoload, {
        ["type"] = "eid",
        ["value"] = idEB:GetNumber(),
        ["note"] = noteDD:GetSelected(),
        ["isPersonal"] = isPersonal,
    })
    MRT_NL:Fire("UpdateAutoload")
end)

-- add encounterName
local addNameBtn = W:CreateButton(infoPane, "+ "..L["ename"], "accent", {114, 20})
addNameBtn:SetEnabled(false)
addNameBtn:SetPoint("TOPLEFT", addIdBtn, "TOPRIGHT", 7, 0)
nameEB:SetScript("OnTextChanged", function()
    addNameBtn:SetEnabled(noteDD.selected and nameEB:GetText() ~= "")
end)
addNameBtn:SetScript("OnClick", function()
    tinsert(MRT_NL_DB.autoload, {
        ["type"] = "ename",
        ["value"] = strtrim(nameEB:GetText()),
        ["note"] = noteDD:GetSelected(),
        ["isPersonal"] = isPersonal,
    })
    MRT_NL:Fire("UpdateAutoload")
end)

UpdateButtons = function()
    addZoneBtn:SetEnabled(noteDD.selected and zoneEB:GetText() ~= "")
    addIdBtn:SetEnabled(noteDD.selected and idEB:GetText() ~= "")
    addNameBtn:SetEnabled(noteDD.selected and nameEB:GetText() ~= "")
end

-------------------------------------------------
-- events
-------------------------------------------------
MRT_NL:RegisterCallback("ZONE_CHANGED", "MainFrame_ZoneChanged", function(zone)
    currentZone = zone
    zoneEB:SetText(zone)
end)

MRT_NL:RegisterCallback("ENCOUNTER_START", "MainFrame_EncounterStart", function(encounterID, encounterName)
    currentEncounterID = encounterID
    currentEncounterName = encounterName
    idEB:SetText(encounterID)
    nameEB:SetText(encounterName)
end)

MRT_NL:RegisterCallback("UpdateAutoload", "MainFrame_UpdateAutoload", function()
    LoadList()
end)

-------------------------------------------------
-- list
-------------------------------------------------
local listPane = CreateFrame("Frame", nil, mainFrame)
listPane:SetPoint("TOPLEFT", infoPane, "BOTTOMLEFT", 0, -7)
listPane:SetPoint("BOTTOMRIGHT", 0, 122)
W:CreateScrollFrame(listPane)

LoadList = function()
    listPane.scrollFrame:Reset()

    local last
    for i, t in pairs(MRT_NL_DB.autoload) do
        local b = W:CreateAutoloadButton(listPane.scrollFrame.content, t.type, t.value, t.note, t.isPersonal)
        b:SetPoint("RIGHT", -7, 0)
        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -7)
        else
            b:SetPoint("TOPLEFT", 7, 0)
        end
        last = b

        b.closeBtn:SetScript("OnClick", function()
            tremove(MRT_NL_DB.autoload, i)
            MRT_NL:Fire("UpdateAutoload")
        end)

        b:SetScript("OnClick", function()
            MRT_NL:LoadNote(t.note, t.isPersonal, true)
        end)
    end

    listPane.scrollFrame:SetContentHeight(20, #MRT_NL_DB.autoload, 7)
    listPane.scrollFrame:SetScrollStep(27)
end

-------------------------------------------------
-- options
-------------------------------------------------
local optionsPane = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
optionsPane:SetPoint("TOPLEFT", listPane, "BOTTOMLEFT", 0, -7)
optionsPane:SetPoint("BOTTOMRIGHT")
optionsPane:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
optionsPane:SetBackdropBorderColor(0, 0, 0, 1)

local postActionText = optionsPane:CreateFontString(nil, "OVERLAY", "MRT_NL_FONT_ACCENT")
postActionText:SetPoint("TOPLEFT", 7, -10)
postActionText:SetText(L["After zone changes / encounter ends"])

local postActionDD = W:CreateDropdown(optionsPane, 356)
postActionDD:SetPoint("TOPLEFT", 7, -28)
postActionDD:SetItems({
    {
        ["text"] = L["Do nothing"],
        ["value"] = "",
        ["onClick"] = function()
            MRT_NL_DB.postAction = ""
        end,
    },
    {
        ["text"] = L["Hide"],
        ["value"] = "hide",
        ["onClick"] = function()
            MRT_NL_DB.postAction = "hide"
        end,
    },
    {
        ["text"] = L["Load %s"]:format("|cffff9015Note Loader Default|r"),
        ["value"] = "load",
        ["onClick"] = function()
            MRT_NL_DB.postAction = "load"
        end,
    },
    -- {
    --     ["text"] = "Load |cffff9015Note Loader Default|r and clear",
    --     ["value"] = "load_clear",
    --     ["onClick"] = function()
    --         MRT_NL_DB.postAction = "load_clear"
    --     end,
    -- },
    {
        ["text"] = L["Load %s (personal)"]:format("|cffff9015Note Loader Default|r"),
        ["value"] = "load_personal",
        ["onClick"] = function()
            MRT_NL_DB.postAction = "load_personal"
        end,
    },
    -- {
    --     ["text"] = "Load |cffff9015Note Loader Default|r as personal and clear",
    --     ["value"] = "load_personal_clear",
    --     ["onClick"] = function()
    --         MRT_NL_DB.postAction = "load_personal_clear"
    --     end,
    -- },
})

local clearMismatchedCB = W:CreateCheckButton(optionsPane, L["Clear mismatched note for current zone / encounter"], function(checked)
    MRT_NL_DB.clearMismatched = checked
end)
clearMismatchedCB:SetPoint("TOPLEFT", 7, -62)

local showSendCB = W:CreateCheckButton(optionsPane, L["Show a %s button next to Note frame"]:format(W:WrapTextInAccentColor(L["Send"])), function(checked)
    MRT_NL_DB.showSendButton = checked
    MRT_NL:ShowSendButton(checked)
end)
showSendCB:SetPoint("TOPLEFT", 7, -90)

showSendCB:HookScript("OnEnter", function()
    MRT_NL_Tooltip:SetOwner(showSendCB, "ANCHOR_NONE")
    MRT_NL_Tooltip:SetPoint("BOTTOMLEFT", showSendCB, "TOPLEFT", 0, 3)
    MRT_NL_Tooltip:AddLine(W:WrapTextInAccentColor(L["Send Button"]))
    MRT_NL_Tooltip:AddLine("|cffffffff"..L["Left-Click: send current note"])
    MRT_NL_Tooltip:AddLine("|cffffffff"..L["Right-Click: send current personal note"])
    MRT_NL_Tooltip:AddLine(" ")
    MRT_NL_Tooltip:AddLine(W:WrapTextInAccentColor(L["Or you can use these slash commands:"]))
    MRT_NL_Tooltip:AddLine("|cffffffff".."/mrtnl send, /nl send")
    MRT_NL_Tooltip:AddLine("|cffffffff".."/mrtnl sendp, /nl sendp")
    MRT_NL_Tooltip:Show()
end)

showSendCB:HookScript("OnLeave", function()
    MRT_NL_Tooltip:Hide()
end)

-------------------------------------------------
-- onshow
-------------------------------------------------
mainFrame:SetScript("OnShow", function()
    scaleSlider:SetValue(MRT_NL_DB.scale)
    mainFrame:SetScale(MRT_NL_DB.scale)
    LoadNoteNames()
    postActionDD:SetSelectedValue(MRT_NL_DB.postAction)
    clearMismatchedCB:SetChecked(MRT_NL_DB.clearMismatched)
    showSendCB:SetChecked(MRT_NL_DB.showSendButton)

    mainFrame.header.text:SetText("MRT Note Loader " .. MRT_NL.version)
end)

mainFrame:SetScript("OnHide", function()
    noteDD.selected = nil
    noteDD.text:SetText("")
    addZoneBtn:SetEnabled(false)
    addIdBtn:SetEnabled(false)
    addNameBtn:SetEnabled(false)
    personalCB:SetChecked(false)
    isPersonal = nil
end)

-------------------------------------------------
-- slash
-------------------------------------------------
SLASH_MRT_NOTE_LOADER1 = "/mrtnl"
SLASH_MRT_NOTE_LOADER2 = "/mnl"
SLASH_MRT_NOTE_LOADER3 = "/nl"
function SlashCmdList.MRT_NOTE_LOADER(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")

    if command == "send" then
        MRT_NL:SendNote()
    elseif command == "sendp" then
        MRT_NL:SendNote(true)
    else
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show()
        end
    end
end