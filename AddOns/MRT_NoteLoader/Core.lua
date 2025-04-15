local addonName, MRT_NL = ...
_G.MRT_NL = MRT_NL

local L = MRT_NL.L

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-------------------------------------------------
-- loaded
-------------------------------------------------
-- local visibilityUpdateRequired

eventFrame:RegisterEvent("ADDON_LOADED")
function eventFrame:ADDON_LOADED(addon)
    if addon == addonName then
        eventFrame:UnregisterEvent("ADDON_LOADED")

        if type(MRT_NL_DB) ~= "table" then MRT_NL_DB = {} end
        if type(MRT_NL_DB.scale) ~= "number" then MRT_NL_DB.scale = 1 end
        if type(MRT_NL_DB.clearMismatched) ~= "boolean" then MRT_NL_DB.clearMismatched = false end
        if type(MRT_NL_DB.showSendButton) ~= "boolean" then MRT_NL_DB.showSendButton = false end
        if type(MRT_NL_DB.postAction) ~= "string" then MRT_NL_DB.postAction = "" end
        if type(MRT_NL_DB.autoload) ~= "table" then
            MRT_NL_DB.autoload = {
                -- {
                --     ["type"] = "zone/eid/ename",
                --     ["value"] = string/number,
                --     ["note"] = noteName(string)/noteIndex(number),
                -- },
            }
        end
        MRT_NL:Fire("UpdateAutoload")

        eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        eventFrame:RegisterEvent("ZONE_CHANGED")
        eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        eventFrame:RegisterEvent("ENCOUNTER_START")
        eventFrame:RegisterEvent("ENCOUNTER_END")

        -- button
        hooksecurefunc(GMRT.A.Note.options, "Load", function()
            local b = MRT_NL.widgets:CreateButton(MRTOptionsFrameNote.tab.tabs[1], "MRT Note Loader", "blue", {135, 20})
            b:SetPoint("TOPRIGHT", -280, 0)
            b:SetScript("OnClick", function()
                MRT_NoteLoader:Show()
            end)
        end)

        -- NL_DEFAULT
        if VMRT.Note.BlackNames[1] ~= "Note Loader Default" then
            tinsert(VMRT.Note.BlackNames, 1, "Note Loader Default")
            tinsert(VMRT.Note.Black, 1, "")
            tinsert(VMRT.Note.AutoLoad, 1, nil)
        end

        -- send button
        MRT_NL:ShowSendButton(MRT_NL_DB.showSendButton)

        -- restore MRT visibility
        -- hooksecurefunc(GMRT.A.Note.frame, "UpdateText", function()
        --     print("UpdateVisibility?", visibilityUpdateRequired)
        --     if visibilityUpdateRequired then
        --         visibilityUpdateRequired = nil
        --         print("UpdateVisibility_UpdateText")
        --         GMRT.A.Note:Visibility()
        --     end
        --     -- GMRT.A.Note.frame:SetAlpha(VMRT.Note.Alpha and (VMRT.Note.Alpha / 100) or 1)
        --     -- if not VMRT.Note.Fix then
        --     --     GMRT.A.Note.frame:EnableMouse(true)
        --     -- end
        -- end)

        MRT_NL.version = GetAddOnMetadata(addonName, "version")
    end
end

-------------------------------------------------
-- callbacks
-------------------------------------------------
MRT_NL.autoload = {
    ["zone"] = {},
    ["zone_p"] = {},
    ["eid"] = {},
    ["eid_p"] = {},
    ["ename"] = {},
    ["ename_p"] = {},
}

MRT_NL:RegisterCallback("UpdateAutoload", "Core_UpdateAutoload", function()
    wipe(MRT_NL.autoload.zone)
    wipe(MRT_NL.autoload.zone_p)
    wipe(MRT_NL.autoload.eid)
    wipe(MRT_NL.autoload.eid_p)
    wipe(MRT_NL.autoload.ename)
    wipe(MRT_NL.autoload.ename_p)

    for _, t in pairs(MRT_NL_DB.autoload) do
        if t.isPersonal then
            MRT_NL.autoload[t.type.."_p"][t.value] = t.note
        else
            MRT_NL.autoload[t.type][t.value] = t.note
        end
    end
end)

-------------------------------------------------
-- functions
-------------------------------------------------
function MRT_NL:Print(msg)
    print("|cffff9015[MRT Note Loader]|r " .. msg)
end

local function GetNoteIndex(title)
    if type(title) == "string" then
        for i, name in pairs(VMRT.Note.BlackNames) do
            if title == name then
                return i
            end
        end
    elseif type(title) == "number" and VMRT.Note.Black[title] then
        return title
    end
end

local showByThisAddon = false
local isEncounterInProgress = false
local zoneNote = false
local zonePersonal = false
local encounterNote = false
local encounterPersonal = false

function MRT_NL:LoadNote(title, isPersonal, force)
    --! do not load if current note is loaded by ENCOUNTER_START
    if isEncounterInProgress and not force then return end

    local index = GetNoteIndex(title)
    if not index then
        MRT_NL:Print(string.format("note |cffff9015%s|r not found.", title))
        return
    end

    if not VMRT.Note.enabled then
        GMRT.A.Note:Enable()
    end

    if isPersonal then
        VMRT.Note.SelfText = VMRT.Note.Black[index]
        GMRT.A.Note.frame:UpdateText()
        MRTNotePersonal:UpdateText()
        MRT_NL:Print(string.format(L["personal note loaded"].." |cffff9015%s|r.", title))
    else
        GMRT.A.Note.frame:Save(index)
        MRT_NL:Print(string.format(L["note loaded"].." |cffff9015%s|r.", title))
    end

    if WeakAuras then
        WeakAuras.ScanEvents("EXRT_NOTE_UPDATE", true)
        WeakAuras.ScanEvents("MRT_NOTE_UPDATE", true)
    end

    GMRT.A.Note.frame:Show()
    MRTNotePersonal:Show()
    showByThisAddon = true
end

function MRT_NL:SendNote(isPersonal)
    local note
    if isPersonal then
        note = VMRT.Note.SelfText
    else
        note = VMRT.Note.Text1
    end

    if type(note) == "string" and strtrim(note) ~= "" then
        MRT_NL:SendChatMessage(note)
    else
        C_Timer.After(0.2, function()
            MRT_NL_Send:SetEnabled(true)
        end)
    end
end

-------------------------------------------------
-- after encounter / zone changed
-------------------------------------------------
local function PostAction()
    showByThisAddon = false

    if MRT_NL_DB.postAction == "hide" then
        -- visibilityUpdateRequired = true
        GMRT.A.Note.frame:Hide()
        MRTNotePersonal:Hide()
        -- GMRT.A.Note.frame:SetAlpha(0)
        -- GMRT.A.Note.frame:EnableMouse(false)

    elseif MRT_NL_DB.postAction == "load" or MRT_NL_DB.postAction == "load_clear" then
        if VMRT.Note.BlackNames[1] == "Note Loader Default" then
            GMRT.A.Note.frame:Save(1)
            MRT_NL:Print(string.format(L["note loaded"].." |cffff9015%s|r.", "Note Loader Default"))
        end
        if MRT_NL_DB.postAction == "load_clear" then
            VMRT.Note.SelfText = ""
        end
        GMRT.A.Note.frame:UpdateText()

    elseif MRT_NL_DB.postAction == "load_personal" or MRT_NL_DB.postAction == "load_personal_clear" then
        if VMRT.Note.BlackNames[1] == "Note Loader Default" then
            VMRT.Note.SelfText = VMRT.Note.Black[1]
            MRT_NL:Print(string.format(L["personal note loaded"].." |cffff9015%s|r.", "Note Loader Default"))
        end
        if MRT_NL_DB.postAction == "load_personal_clear" then
            VMRT.Note.Text1 = ""
        end
        GMRT.A.Note.frame:UpdateText()

    else
        -- do nothing
    end

end

local function ClearNote(forceNote, forcePersonal)
    -- clear note if not matched
    if not (zoneNote or encounterNote) or forceNote then
        VMRT.Note.Text1 = ""
    end

    -- clear personal note if not matched
    if not (zonePersonal or encounterPersonal) or forcePersonal then
        VMRT.Note.SelfText = ""
    end

    GMRT.A.Note.frame:UpdateText()
    MRTNotePersonal:UpdateText()
end

-------------------------------------------------
-- zone changed
-------------------------------------------------
function eventFrame:ZONE_CHANGED()
    -- local isIn, iType = IsInInstance()
    local zone = GetSubZoneText()
    if zone == "" then
        zone = GetRealZoneText()
    end

    if not zone then
        C_Timer.After(1, eventFrame.ZONE_CHANGED)
        return
    end

    MRT_NL:Fire("ZONE_CHANGED", zone)

    zoneNote = false
    zonePersonal = false

    if MRT_NL.autoload.zone[zone] then
        MRT_NL:LoadNote(MRT_NL.autoload.zone[zone])
        zoneNote = true
    end

    if MRT_NL.autoload.zone_p[zone] then
        MRT_NL:LoadNote(MRT_NL.autoload.zone_p[zone], true)
        zonePersonal = true
    end

    if showByThisAddon then
        if MRT_NL_DB.clearMismatched then
            ClearNote()
        end

        if not isEncounterInProgress and not (zoneNote or zonePersonal) then
            PostAction()
        end
    end
end

eventFrame.ZONE_CHANGED_INDOORS = eventFrame.ZONE_CHANGED
eventFrame.ZONE_CHANGED_NEW_AREA = eventFrame.ZONE_CHANGED

function eventFrame:PLAYER_ENTERING_WORLD(isLogin, isReload)
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if isReload then
        eventFrame:ZONE_CHANGED()
    end
end

-------------------------------------------------
-- encounter start
-------------------------------------------------
function eventFrame:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
    MRT_NL:Fire("ENCOUNTER_START", encounterID, encounterName)

    encounterNote = false
    encounterPersonal = false

    if MRT_NL.autoload.eid[encounterID] then
        isEncounterInProgress = true
        MRT_NL:LoadNote(MRT_NL.autoload.eid[encounterID], false, true)
        encounterNote = true
    end

    if MRT_NL.autoload.eid_p[encounterID] then
        isEncounterInProgress = true
        MRT_NL:LoadNote(MRT_NL.autoload.eid_p[encounterID], true, true)
        encounterPersonal = true
    end

    if MRT_NL.autoload.ename[encounterName] then
        isEncounterInProgress = true
        MRT_NL:LoadNote(MRT_NL.autoload.ename[encounterName], false, true)
        encounterNote = true
    end
    if MRT_NL.autoload.ename_p[encounterName] then
        isEncounterInProgress = true
        MRT_NL:LoadNote(MRT_NL.autoload.ename_p[encounterName], true, true)
        encounterPersonal = true
    end

    if showByThisAddon then
        if MRT_NL_DB.clearMismatched then
            ClearNote()
        end
    end

    if isEncounterInProgress then
        -- call MRT's ENCOUNTER_START
        GMRT.A.Note.main:ENCOUNTER_START(encounterID, encounterName, difficultyID, groupSize)
    end
end

function eventFrame:ENCOUNTER_END()
    isEncounterInProgress = false

    if showByThisAddon then
        if MRT_NL_DB.clearMismatched then
            ClearNote(encounterNote, encounterPersonal)
        end

        if zoneNote or zonePersonal then
            -- reload note for this zone
            eventFrame:ZONE_CHANGED()
        else
            PostAction()
        end
    end

    encounterNote = false
    encounterPersonal = false
end