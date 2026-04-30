local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

private.createImportDialog = function(editorWindow, encounterID, initialImportText)
    local dialog = AceGUI:Create("AtImportDialog")
    dialog:SetTitle(private.getLocalisation("ImportDialogTitle"))
    dialog:SetLayout("List")
    dialog:SetAutoAdjustHeight(true)

    -- Track the open dialog
    private.IMPORT_DIALOG_WINDOW = dialog

    dialog.closeButton:SetScript("OnClick", function()
        dialog:Release()
        private.IMPORT_DIALOG_WINDOW = nil
        if private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS then
            local params = private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS
            private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS = nil
            private.openTimingsEditor(params)
        end
    end)

    local settingsGroup = AceGUI:Create("SimpleGroup")
    settingsGroup:SetLayout("Flow")
    settingsGroup:SetFullWidth(true)
    settingsGroup:SetHeight(50)

    local filterCheckbox = AceGUI:Create("CheckBox")
    filterCheckbox:SetLabel(private.getLocalisation("ImportRelevant"))
    private.AddFrameTooltip(filterCheckbox.frame, "ImportRelevantDescription")
    filterCheckbox:SetValue(private.db.profile.importRelevant)
    filterCheckbox:SetRelativeWidth(0.5)
    settingsGroup:AddChild(filterCheckbox)

    local mergeCheckbox = AceGUI:Create("CheckBox")
    mergeCheckbox:SetLabel(private.getLocalisation("ImportMergeMode"))
    private.AddFrameTooltip(mergeCheckbox.frame, "ImportMergeModeDescription")
    mergeCheckbox:SetValue(private.db.profile.importMergeMode)
    mergeCheckbox:SetRelativeWidth(0.5)
    settingsGroup:AddChild(mergeCheckbox)
    mergeCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        private.db.profile.importMergeMode = value
    end)

    dialog:AddChild(settingsGroup)

    local parsedEncounterID = nil

    local importText = AceGUI:Create("MultiLineEditBox")
    importText:SetLabel(private.getLocalisation("ImportTextPlaceholder"))
    importText:SetFullWidth(true)
    importText:SetNumLines(15)
    importText:DisableButton(true)
    dialog:AddChild(importText)

    local previewGroup = AceGUI:Create("SimpleGroup")
    previewGroup:SetLayout("List")
    previewGroup:SetFullWidth(true)
    previewGroup:SetHeight(150)

    local previewLabel = AceGUI:Create("Label")
    previewLabel:SetText(private.getLocalisation("ImportPreviewEmpty"))
    previewLabel:SetFullWidth(true)
    previewGroup:AddChild(previewLabel)

    dialog:AddChild(previewGroup)

    local function updatePreview()
        local warningLabel = ""
        local importData = importText:GetText()
        if not importData or importData:trim() == "" then
            previewLabel:SetText(private.getLocalisation("ImportPreviewEmpty"))
            return
        end

        local reminders, errorMsg = private.ImportUtil:ParseImportText(importData)

        if errorMsg then
            previewLabel:SetText("|cffff0000" .. private.getLocalisation("ImportError"):format(errorMsg) .. "|r")
            return
        end

        parsedEncounterID = private.ImportUtil.lastParsedEncounterID
        if parsedEncounterID and parsedEncounterID ~= encounterID then
            warningLabel = "|cffff6600" .. private.getLocalisation("ImportEncounterMismatch") .. "|r"
        end

        local filteredReminders = reminders
        if private.db.profile.importRelevant then
            filteredReminders = private.ImportUtil:FilterReminders(reminders)
        end

        local count = #filteredReminders
        if count == 0 then
            previewLabel:SetText("|cffff0000" ..
            private.getLocalisation("ImportError"):format("No reminders found for your character") .. "|r")
            return
        end

        local countMsg
        if count ~= #reminders then
            countMsg = "|cffff9900" .. private.getLocalisation("ImportPreviewFiltered"):format(count, #reminders) .. "|r"
        else
            countMsg = "|cff00ff00" .. private.getLocalisation("ImportPreview"):format(count) .. "|r"
        end
        previewLabel:SetText(countMsg .. " " .. warningLabel)
    end

    importText:SetCallback("OnTextChanged", function()
        updatePreview()
        dialog:DoLayout()
    end)

    filterCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        updatePreview()
        dialog:DoLayout()
        private.db.profile.importRelevant = value
    end)

    if initialImportText and initialImportText ~= "" then
        importText:SetText(initialImportText)
        updatePreview()
        dialog:DoLayout()
    end

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    buttonGroup:SetHeight(25)

    local importButton = AceGUI:Create("Button")
    importButton:SetText(private.getLocalisation("ImportButton"))
    importButton:SetRelativeWidth(0.5)
    importButton:SetCallback("OnClick", function()
        local importData = importText:GetText()
        if not importData or importData == "" then
            private.Debug("Import text is empty")
            return
        end

        local reminders, errorMsg = private.ImportUtil:ParseImportText(importData)

        if errorMsg then
            private.Debug("Import error: " .. tostring(errorMsg))
            return
        end

        if filterCheckbox:GetValue() then
            reminders = private.ImportUtil:FilterReminders(reminders)
        end

        local valid, validationMsg = private.ImportUtil:ValidateReminders(reminders)
        if not valid then
            private.Debug("Validation error: " .. tostring(validationMsg))
            return
        end

        dialog:Release()
        private.IMPORT_DIALOG_WINDOW = nil
        -- before importing show a progress popup
        local importPopup = AceGUI:Create("AtImportPopup")

        local function onComplete()
            local success = private.ImportUtil:ApplyReminders(encounterID, reminders, private.db.profile.importMergeMode)

            if success then
                private.Debug("Successfully imported " .. #reminders .. " reminders")

                if editorWindow then
                    if editorWindow.LoadReminders then
                        editorWindow:LoadReminders(encounterID)
                    end
                    editorWindow:RefreshReminders()
                elseif private.TIMINGS_EDITOR_WINDOW then
                    if private.TIMINGS_EDITOR_WINDOW.LoadReminders then
                        private.TIMINGS_EDITOR_WINDOW:LoadReminders(encounterID)
                    end
                    private.TIMINGS_EDITOR_WINDOW:RefreshReminders()
                end
            else
                private.Debug("Failed to apply reminders")
            end

            -- Reopen timings editor if it was closed
            if private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS then
                private.openTimingsEditor(private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS)
                private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS = nil
            end
        end

        local function onCancel()
            private.Debug("Import cancelled by user")
            -- Reshow the import dialog with the original import text
            private.showImportDialog(encounterID, editorWindow, importData)
        end

        importPopup:StartImport(5, onComplete, onCancel)
    end)
    buttonGroup:AddChild(importButton)

    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText(private.getLocalisation("ReminderCancelButton"))
    cancelButton:SetRelativeWidth(0.5)
    cancelButton:SetCallback("OnClick", function()
        dialog:Release()
        private.IMPORT_DIALOG_WINDOW = nil
        -- Reopen timings editor if it was closed
        if private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS then
            local params = private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS
            private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS = nil
            private.openTimingsEditor(params)
        end
    end)
    buttonGroup:AddChild(cancelButton)

    dialog:AddChild(buttonGroup)

    return dialog
end

private.showImportDialog = function(encounterID, editorWindow, initialImportText)
    if not encounterID then
        private.Debug("No encounter ID provided for import")
        return
    end

    -- Don't open a new dialog if one is already open
    if private.IMPORT_DIALOG_WINDOW then
        private.Debug("Import dialog is already open, ignoring duplicate request")
        return
    end

    -- Close timings editor if open and store encounter params
    if private.TIMINGS_EDITOR_WINDOW then
        private.IMPORT_DIALOG_STORED_ENCOUNTER_PARAMS = {
            journalEncounterID = private.TIMINGS_EDITOR_WINDOW.journalEncounterID,
            journalInstanceID = private.TIMINGS_EDITOR_WINDOW.journalInstanceID,
            dungeonEncounterID = private.TIMINGS_EDITOR_WINDOW.encounterID
        }
        private.closeTimingsEditor()
    end

    private.createImportDialog(editorWindow, encounterID, initialImportText)
end

private.showExportDialog = function(encounterID)
    if not encounterID then
        private.Debug("No encounter ID provided for export")
        return
    end

    -- Get reminders for this encounter first (before closing editor)
    if not private.db or not private.db.profile or not private.db.profile.reminders then
        private.Debug("No reminders database found")
        return
    end

    local reminders = private.db.profile.reminders[encounterID]
    if not reminders or #reminders == 0 then
        private.Debug("No reminders found for this encounter")
        return
    end

    -- Only close timings editor if we have reminders to export
    if private.TIMINGS_EDITOR_WINDOW then
        private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS = {
            journalEncounterID = private.TIMINGS_EDITOR_WINDOW.journalEncounterID,
            journalInstanceID = private.TIMINGS_EDITOR_WINDOW.journalInstanceID,
            dungeonEncounterID = private.TIMINGS_EDITOR_WINDOW.encounterID
        }
        private.closeTimingsEditor()
    end

    local dialog = AceGUI:Create("AtImportDialog")
    dialog:SetTitle(private.getLocalisation("ExportDialogTitle"))
    dialog:SetLayout("List")
    private.Debug("Export dialog created and shown")

    dialog.closeButton:SetScript("OnClick", function()
        dialog:Release()
        -- Reopen timings editor if it was closed
        if private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS and private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS.dungeonEncounterID then
            local params = private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS
            private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS = nil
            private.openTimingsEditor(params)
        end
    end)

    local formatGroup = AceGUI:Create("SimpleGroup")
    formatGroup:SetLayout("Flow")
    formatGroup:SetFullWidth(true)
    formatGroup:SetHeight(50)

    local exportText = AceGUI:Create("MultiLineEditBox")
    exportText:SetLabel(private.getLocalisation("ExportDialogTitle"))
    exportText:SetFullWidth(true)
    exportText:SetNumLines(15)
    exportText:DisableButton(true)

    local encounterName = EJ_GetEncounterInfo(encounterID) or ""

    local function updateExport(format)
        local exportData = private.ImportUtil:ExportReminders(reminders, format, encounterID, encounterName)
        exportText:SetText(exportData)
    end
    updateExport("encoded")

    local encodedButton = AceGUI:Create("Button")
    encodedButton:SetText(private.getLocalisation("ExportAsEncoded"))
    encodedButton:SetRelativeWidth(0.25)
    encodedButton:SetCallback("OnClick", function()
        updateExport("encoded")
    end)
    formatGroup:AddChild(encodedButton)

    local viserioButton = AceGUI:Create("Button")
    viserioButton:SetText(private.getLocalisation("ExportAsViserio"))
    viserioButton:SetRelativeWidth(0.25)
    viserioButton:SetCallback("OnClick", function()
        updateExport("viserio")
    end)
    formatGroup:AddChild(viserioButton)

    local jsonButton = AceGUI:Create("Button")
    jsonButton:SetText(private.getLocalisation("ExportAsJSON"))
    jsonButton:SetRelativeWidth(0.25)
    jsonButton:SetCallback("OnClick", function()
        updateExport("json")
    end)
    formatGroup:AddChild(jsonButton)

    local mrtButton = AceGUI:Create("Button")
    mrtButton:SetText(private.getLocalisation("ExportAsMRT"))
    mrtButton:SetRelativeWidth(0.25)
    mrtButton:SetCallback("OnClick", function()
        updateExport("mrt")
    end)
    formatGroup:AddChild(mrtButton)

    dialog:AddChild(formatGroup)
    dialog:AddChild(exportText)

    local hintText = AceGUI:Create("Label")
    hintText:SetText(private.getLocalisation("ExportCopyHint"))
    hintText:SetFullWidth(true)
    dialog:AddChild(hintText)

    local sendToChatButton = AceGUI:Create("Button")
    sendToChatButton:SetText(private.getLocalisation("ReminderSendToChatButton"))
    sendToChatButton:SetRelativeWidth(1)
    sendToChatButton:SetCallback("OnClick", function()
        private.StartExportingToChat(encounterID)
        dialog:Release()
        -- Reopen timings editor if it was closed
        if private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS then
            private.openTimingsEditor(private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS)
            private.EXPORT_DIALOG_STORED_ENCOUNTER_PARAMS = nil
        end
    end)
    dialog:AddChild(sendToChatButton)
end
