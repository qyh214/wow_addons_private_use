local appName, app = ...
---@class AbilityTimeline
local private = app
local AceGUI = LibStub("AceGUI-3.0")

local Type = "AtTimingsEditorDataFrame"
local Version = 1
local variables = {
    BackdropBorderColor = { 0.25, 0.25, 0.25, 0.9 },
    BackdropColor = { 0, 0, 0, 0.9 },
    FrameHeight = 600,
    FrameWidth = 800,
    Backdrop = {
        bgFile = nil,
        edgeFile = nil,
        tile = true,
        tileSize = 16,
        edgeSize = 1,
    },
    FrameLeftSize = 240,
    FrameRightSize = 800,
    Padding = { x = 2, y = 2 },
    sliderSize = 1100,
    timelinePixelsPerSecond = 6,
    RowHeight = 44,
    RowPadding = 8,
}

local function formatTime(seconds)
    seconds = tonumber(seconds) or 0
    local minutes = math.floor(seconds / 60)
    local secs = seconds - minutes * 60
    return string.format("%d:%05.2f", minutes, secs)
end

local function copyReminder(reminder)
    local t = {}
    for k, v in pairs(reminder or {}) do
        t[k] = v
    end
    return t
end

---@param self AtTimingsEditorDataFrame
local function OnAcquire(self)
    self.frame:Show()
    self.frame:SetPoint("CENTER", UIParent, "CENTER")
    self.frame:SetWidth(variables.FrameLeftSize + variables.FrameRightSize + 40)
    self.frame:SetHeight(variables.FrameHeight)
    private.Debug(self, "AT_TIMINGS_EDITOR_DATA_FRAME_ONACQUIRE")
end

---@param self AtTimingsEditorDataFrame
local function OnRelease(self)
    if self.reminderList then
        self.reminderList:ReleaseChildren()
    end
    if type(self.items) == "table" then
        for _, v in pairs(self.items) do
            if v and type(v) == "table" and v.spellContainer then
                v.spellContainer:Release()
            end
        end
    end
    if self.reminderPins then
        for _, pin in ipairs(self.reminderPins) do
            if pin and pin.Hide then pin:Hide() end
            if pin and pin.SetParent then pin:SetParent(nil) end
        end
    end
    self.reminderPins = {}
    -- Extra safety: also clear any stray timeline children
    if self.timeline and self.timeline.GetChildren then
        local children = { self.timeline:GetChildren() }
        for _, child in ipairs(children) do
            if child and child.isReminderPin then
                child:Hide()
                child:SetParent(nil)
            end
        end
    end
    self.reminderRows = {}
    self.items = {}
end

local function HandleTicks(self)
    if not self.timeline then return end
    for i = 1, #self.timeline.Ticks do
        self.timeline.Ticks[i].frame:Hide()
        self.timeline.Ticks[i]:Release()
    end
    wipe(self.timeline.Ticks)
    local tickCount = math.floor((self.combatDuration or 0) / 15)
    local timelineWidth = self.timeline:GetWidth()
    for i = 1, tickCount do
        local widget = AceGUI:Create("AtTimelineTicks")
        self.timeline.Ticks[i] = widget
        widget:SetTick(self.timeline, i * 15, timelineWidth, self.combatDuration, true)
        widget.frame:Show()
    end
end

local function UpdateTimelineWidth(self)
    if not self.rightContent or not self.timeline or not self.rightViewport or not self.hslider then return end
    local width = math.max(variables.FrameRightSize,
        math.floor((self.combatDuration or 0) * variables.timelinePixelsPerSecond) + 200)
    self.rightContent:SetWidth(width)
    self.timeline:SetWidth(width)
    local maxScroll = math.max(0, width - self.rightViewport:GetWidth())
    self.hslider:SetSliderValues(0, self.combatDuration or 0, 1)
    local value = math.min(self.hslider:GetValue() or 0, self.combatDuration or 0)
    self.hslider:SetValue(value)
    local scrollPos = (value / (self.combatDuration or 1)) * maxScroll
    self.hscroll:SetHorizontalScroll(scrollPos)

    self.hslider:SetCallback("OnValueChanged", function(_, _, value)
        local scrollPos = (value / (self.combatDuration or 1)) * maxScroll
        self.hscroll:SetHorizontalScroll(scrollPos)
    end)
end

local function SetCombatDuration(self, duration)
    self.combatDuration = tonumber(duration) or private.db.profile.editor.defaultEncounterDuration or 300
    if self.durationBox then
        self.durationBox:SetText(tostring(math.floor(self.combatDuration)))
    end
    UpdateTimelineWidth(self)
    HandleTicks(self)
end

local function getReminderTexture(reminder)
    private.Debug(reminder, "Reminder")
    private.Debug("No iconId found in reminder")
    if reminder.spellId then
        local icon = C_Spell.GetSpellTexture(reminder.spellId)
        if icon then
            return icon
        end
    elseif reminder.iconId then
        return reminder.iconId
    end
    return 134400
end

local function clearPins(self)
    if not self.reminderPins then return end
    if self.rowBands then
        for _, band in ipairs(self.rowBands) do
            if band and band.Hide then band:Hide() end
            if band and band.SetParent then band:SetParent(nil) end
        end
    end
    self.rowBands = {}
    -- Hide and destroy all tracked pins and their delay bars
    for _, pin in ipairs(self.reminderPins) do
        if pin and pin.delayBar then
            pin.delayBar:Hide()
            if pin.delayBar.Destroy then
                pin.delayBar:Destroy()
            else
                pin.delayBar:SetParent(nil)
            end
        end
        if pin and pin.Hide then
            pin:Hide()
        end
        if pin and pin.SetParent then
            pin:SetParent(nil)
        end
    end
    wipe(self.reminderPins)

    -- Extra safety: also clear any stray children that were not tracked
    if self.timeline and self.timeline.GetChildren then
        local children = { self.timeline:GetChildren() }
        for _, child in ipairs(children) do
            if child and child.isReminderPin then
                child:Hide()
                child:SetParent(nil)
            end
            if child and child.isDelayBar then
                child:Hide()
                if child.Destroy then
                    child:Destroy()
                else
                    child:SetParent(nil)
                end
            end
        end
    end
end

local function anchorPin(self, pin, time, rowIndex)
    local width = self.timeline and self.timeline:GetWidth() or 0
    if width <= 0 or not self.combatDuration or self.combatDuration <= 0 then return end
    local pos = (time / self.combatDuration) * width
    local rowHeight = variables.RowHeight
    local rowPadding = variables.RowPadding
    local y = -rowPadding - (rowIndex - 1) * (rowHeight + rowPadding) - (rowHeight * 0.5)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", self.timeline, "TOPLEFT", pos, y)
    -- position/size delay bar if present (extends right from the icon)
    if pin.delayBar then
        local delay = tonumber(pin.delaySeconds) or 0
        if delay > 0 then
            local pixelsPerSecond = variables.timelinePixelsPerSecond or 6
            local barWidth = math.max(0, delay * pixelsPerSecond)
            pin.delayBar:ClearAllPoints()
            pin.delayBar:SetPoint("LEFT", self.timeline, "TOPLEFT", pos + 2, y)
            pin.delayBar:SetSize(barWidth, 6)
            pin.delayBar:Show()
        else
            pin.delayBar:Hide()
        end
    end
end

local function SortReminders(self)
    table.sort(self.reminders, function(a, b)
        return (a.CombatTime or 0) < (b.CombatTime or 0)
    end)
end

local function SaveReminders(self)
    if not self.encounterID then return end
    local copy = {}
    for _, reminder in ipairs(self.reminders) do
        local r = copyReminder(reminder)
        -- persist EJ ids so the encounter can be restored precisely
        if self.journalEncounterID then r.journalEncounterID = self.journalEncounterID end
        if self.journalInstanceID then r.journalInstanceID = self.journalInstanceID end
        table.insert(copy, r)
    end
    private.db.profile.reminders[self.encounterID] = copy
end

local function createPin(self, reminder, rowIndex)
    local pin = CreateFrame("Button", nil, self.timeline, "BackdropTemplate")
    pin:SetSize(20, 20)
    -- mark so we can reliably clear later
    pin.isReminderPin = true
    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints()
    local texture = getReminderTexture(reminder)
    private.Debug("Setting texture: " .. texture)
    pin.icon:SetTexture(texture)
    -- optional delay bar behind the icon representing CombatTimeDelay
    local delay = tonumber(reminder.CombatTimeDelay) or 0
    pin.delaySeconds = delay
    pin.delayBar = CreateFrame("Frame", nil, self.timeline, "BackdropTemplate")
    pin.delayBar.isDelayBar = true -- mark for cleanup
    pin.delayBar:SetFrameLevel(pin:GetFrameLevel() - 1)
    pin.delayBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 8,
        edgeSize = 0,
    })
    pin.delayBar:SetBackdropColor(1, 1, 1, 0.6) -- semi-transparent white bar
    pin.delayBar:Hide()
    pin:SetScript("OnEnter", function()
        GameTooltip:SetOwner(pin, "ANCHOR_TOP")
        GameTooltip:AddLine(reminder.name or reminder.spellName or private.getLocalisation("ReminderCreatorTitle"))
        GameTooltip:AddLine(formatTime(reminder.CombatTime or 0), 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- Disable dragging for now to prevent XY drag bugs and duplication
    -- If needed later, implement X-only dragging with constrained repositioning.
    anchorPin(self, pin, reminder.CombatTime or 0, rowIndex)
    table.insert(self.reminderPins, pin)
end

local function clearReminderRows(self)
    if self.reminderList then
        self.reminderList:ReleaseChildren()
    end
    wipe(self.reminderRows)
end

local function deleteReminder(self, index)
    table.remove(self.reminders, index)
    SaveReminders(self)
    self:RefreshReminders()
end

local function createRow(self, reminder, index)
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout("Flow")
    row:SetFullWidth(true)

    local icon = AceGUI:Create("Icon")
    icon:SetImage(getReminderTexture(reminder))
    icon:SetImageSize(18, 18)
    icon:SetWidth(24)
    row:AddChild(icon)

    local label = AceGUI:Create("InteractiveLabel")
    local name = reminder.name or reminder.spellName or private.getLocalisation("ReminderCreatorTitle")
    label:SetText(string.format("%s - %s", tostring(name), formatTime(reminder.CombatTime)))
    label:SetFullWidth(true)
    label:SetCallback("OnClick", function()
        self:OpenReminderDialog(index)
    end)
    row:AddChild(label)

    local editBtn = AceGUI:Create("Button")
    editBtn:SetText(private.getLocalisation("ReminderEditButton"))
    editBtn:SetWidth(60)
    editBtn:SetCallback("OnClick", function()
        self:OpenReminderDialog(index)
    end)
    row:AddChild(editBtn)

    local deleteBtn = AceGUI:Create("Button")
    deleteBtn:SetText(private.getLocalisation("ReminderDeleteButton"))
    deleteBtn:SetWidth(60)
    deleteBtn:SetCallback("OnClick", function()
        deleteReminder(self, index)
    end)
    row:AddChild(deleteBtn)

    self.reminderList:AddChild(row)
    -- Ensure the row and reminderList frames are visible and at correct level
    if row.frame then row.frame:Show() end
    if self.reminderList and self.reminderList.frame then
        self.reminderList.frame:Show()
        if self.left and self.left.GetFrameLevel then
            self.reminderList.frame:SetFrameLevel(self.left:GetFrameLevel() + 50)
        end
    end
    table.insert(self.reminderRows, row)
end

local function RefreshReminders(self)
    clearReminderRows(self)
    clearPins(self)
    -- Defensive: ensure reminderList AceGUI widget exists (may be lost after many create/release cycles)
    if not self.reminderList or type(self.reminderList.AddChild) ~= "function" then
        private.Debug("recreating missing reminderList AceGUI widget")
        local rl = AceGUI:Create("ScrollFrame")
        rl:SetLayout("List")
        if self.left then
            rl:SetParent(self.left)
            if rl.frame and self.left then
                rl.frame:SetPoint("TOPLEFT", self.left, "TOPLEFT", 0, -125)
                rl.frame:SetPoint("BOTTOMRIGHT", self.left, "BOTTOMRIGHT", 0, 0)
                rl.frame:SetFrameLevel(self.left:GetFrameLevel() + 50)
            end
        end
        self.reminderList = rl
    end
    if #self.reminders == 0 then
        local emptyLabel = AceGUI:Create("Label")
        emptyLabel:SetText(private.getLocalisation("ReminderListEmpty"))
        emptyLabel:SetFullWidth(true)
        self.reminderList:AddChild(emptyLabel)
        if emptyLabel.frame then emptyLabel.frame:Show() end
        if self.reminderList and self.reminderList.frame then self.reminderList.frame:Show() end
        table.insert(self.reminderRows, emptyLabel)
        UpdateTimelineWidth(self)
        HandleTicks(self)
        return
    end

    SortReminders(self)

    -- Build a map from reminder reference to its index in the master list so edit/delete target the correct entry
    local reminderIndexMap = {}
    for i, r in ipairs(self.reminders) do
        reminderIndexMap[r] = i
    end

    -- Group reminders by spell (or name) so each spell gets its own row on the timeline
    local groups = {}
    local order = {}
    for _, reminder in ipairs(self.reminders) do
        local rawKey = reminder.spellId or reminder.spellName or reminder.name or reminder.iconId or "Unknown"
        local key = tostring(rawKey)
        local name = reminder.spellName or reminder.name or "Unknown"
        if type(name) ~= "string" then name = tostring(name) end
        if not groups[key] then
            groups[key] = {
                key = key,
                name = name,
                icon = getReminderTexture(reminder),
                reminders = {},
            }
            table.insert(order, key)
        end
        table.insert(groups[key].reminders, reminder)
    end

    table.sort(order, function(a, b)
        return tostring(groups[a].name or "") < tostring(groups[b].name or "")
    end)

    local rowHeight = variables.RowHeight
    local rowPadding = variables.RowPadding
    local rowsCount = #order
    local totalRowsHeight = rowsCount * (rowHeight + rowPadding) + rowPadding

    -- Ensure the timeline and its scroll child are tall enough to show all rows
    local targetHeight = math.max(totalRowsHeight + 20, self.rightViewport:GetHeight())
    self.timeline:SetHeight(targetHeight)
    self.rightContent:SetHeight(targetHeight + 20)

    -- Alternate row backgrounds for readability
    self.rowBands = self.rowBands or {}
    for idx, key in ipairs(order) do
        local top = -rowPadding - (idx - 1) * (rowHeight + rowPadding)
        local band = self.timeline:CreateTexture(nil, "BACKGROUND", nil, -8)
        local shade = (idx % 2 == 0) and 0.10 or 0.14
        band:SetColorTexture(shade, shade, shade, 0.55)
        band:SetPoint("TOPLEFT", self.timeline, "TOPLEFT", 0, top)
        band:SetPoint("TOPRIGHT", self.timeline, "TOPRIGHT", 0, top)
        band:SetHeight(rowHeight)
        table.insert(self.rowBands, band)
    end

    -- Build rows in the reminder list (kept sorted by time within each spell)
    local maxTime = 0
    local rowIndex = 0
    for _, key in ipairs(order) do
        rowIndex = rowIndex + 1
        local group = groups[key]
        table.sort(group.reminders, function(a, b)
            return (a.CombatTime or 0) < (b.CombatTime or 0)
        end)
        for _, reminder in ipairs(group.reminders) do
            maxTime = math.max(maxTime, reminder.CombatTime or 0)
            local actualIndex = reminderIndexMap[reminder]
            createRow(self, reminder, actualIndex)
            createPin(self, reminder, rowIndex)
        end
    end

    SetCombatDuration(self, math.max(self.combatDuration or 0, maxTime + 10))
    UpdateTimelineWidth(self)
    HandleTicks(self)
    -- Make sure reminderList is visible after building rows
    if self.reminderList and self.reminderList.frame then
        self.reminderList.frame:Show()
        if self.left and self.left.GetFrameLevel then
            self.reminderList.frame:SetFrameLevel(self.left:GetFrameLevel() + 50)
        end
    end
end

local function OpenReminderDialog(self, reminderIndex)
    if self.addEntry then
        self.addEntry:Release()
    end

    local isEditing = reminderIndex ~= nil and self.reminders[reminderIndex] ~= nil
    local current = isEditing and copyReminder(self.reminders[reminderIndex]) or {}
    local dialog = AceGUI:Create("AtReminderCreator")
    if isEditing then
        dialog:SetTitle(private.getLocalisation("ReminderEditTitle"))
    else
        dialog:SetTitle(private.getLocalisation("ReminderAddTitle"))
    end
    dialog:SetLayout("Flow")

    local nameBox = AceGUI:Create("EditBox")
    nameBox:SetLabel(private.getLocalisation("ReminderNameLabel"))
    nameBox:SetText(current.name or current.spellName or "")
    nameBox:SetRelativeWidth(0.55)
    nameBox:DisableButton(true)
    dialog:AddChild(nameBox)

    local spellIdBox = AceGUI:Create("EditBox")
    spellIdBox:SetLabel(private.getLocalisation("ReminderSpellIdLabel"))
    spellIdBox:SetText(current.spellId and tostring(current.spellId) or "")
    spellIdBox:SetRelativeWidth(0.30)
    spellIdBox:DisableButton(true)
    dialog:AddChild(spellIdBox)

    local iconPreview = AceGUI:Create("Icon")
    iconPreview:SetImage(getReminderTexture(current))
    iconPreview:SetImageSize(32, 32)
    iconPreview:SetRelativeWidth(0.15)
    dialog:AddChild(iconPreview)

    local timingBox = AceGUI:Create("EditBox")
    timingBox:SetLabel(private.getLocalisation("ReminderCreatorTimingLabel"))
    timingBox:SetText(tostring(current.CombatTime or 0))
    timingBox:SetRelativeWidth(0.5)
    timingBox:DisableButton(true)
    dialog:AddChild(timingBox)

    local delayBox = AceGUI:Create("EditBox")
    delayBox:SetLabel(private.getLocalisation("ReminderDelayLabel"))
    private.AddFrameTooltip(delayBox.frame, "ReminderDelayDescription")
    delayBox:SetText(tostring(current.CombatTimeDelay or 0))
    delayBox:SetRelativeWidth(0.5)
    delayBox:DisableButton(true)
    dialog:AddChild(delayBox)

    local startTimerAfterBox = AceGUI:Create("EditBox")
    startTimerAfterBox:SetLabel(private.getLocalisation("StartTimerAfterLabel"))
    private.AddFrameTooltip(startTimerAfterBox.frame, "StartTimerAfterDescription")
    startTimerAfterBox:SetText(tostring(current.StartTimerAfter or 0))
    startTimerAfterBox:SetRelativeWidth(0.5)
    startTimerAfterBox:DisableButton(true)
    dialog:AddChild(startTimerAfterBox)

    local severity = AceGUI:Create("Dropdown")
    severity:SetLabel(private.getLocalisation("ReminderSeverityLabel"))
    severity:SetList({
        [0] = "Info",
        [1] = "Alert",
        [2] = "Critical",
    })
    severity:SetFullWidth(true)
    severity:SetValue(current.severity or 0)
    dialog:AddChild(severity)

    local effects = AceGUI:Create("Dropdown")
    effects:SetLabel(private.getLocalisation("ReminderEffectTypesLabel"))
    effects:SetList({
        [1] = private.getLocalisation("DeadlyEffect"),
        [2] = private.getLocalisation("EnrageEffect"),
        [4] = private.getLocalisation("BleedEffect"),
        [8] = private.getLocalisation("MagicEffect"),
        [16] = private.getLocalisation("DiseaseEffect"),
        [32] = private.getLocalisation("CurseEffect"),
        [64] = private.getLocalisation("PoisonEffect"),
        [128] = private.getLocalisation("TankRole"),
        [256] = private.getLocalisation("HealerRole"),
        [512] = private.getLocalisation("DpsRole")
    })
    effects:SetFullWidth(true)
    effects:SetValue(current.effectTypes)
    dialog:AddChild(effects)

    local function refreshSpellInfo()
        local spellIdText = spellIdBox:GetText()
        local spellId = tonumber(spellIdText)
        local spellName, icon
        if spellId then
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            if spellInfo then
                spellName = spellInfo.name
                icon = spellInfo.iconID
            end
        end

        if icon then
            iconPreview:SetImage(icon)
        else
            -- fallback: derive icon from current reminder or default
            iconPreview:SetImage(getReminderTexture({
                spellId = spellId or current.spellId,
                spellName = spellName or current.spellName,
                iconId = current.iconId,
            }))
        end

        if spellName and nameBox:GetText() == "" then
            nameBox:SetText(spellName)
        end
    end

    spellIdBox:SetCallback("OnEnterPressed", function()
        refreshSpellInfo()
    end)
    spellIdBox:SetCallback("OnTextChanged", function()
        refreshSpellInfo()
    end)

    -- initialize preview when dialog opens
    refreshSpellInfo()

    local saveButton = AceGUI:Create("Button")
    saveButton:SetText(private.getLocalisation("ReminderSaveButton"))
    saveButton:SetRelativeWidth(0.5)
    saveButton:SetCallback("OnClick", function()
        local timeValue = tonumber(timingBox:GetText())
        if not timeValue then
            return
        end
        local startTimeAfter = tonumber(startTimerAfterBox:GetText())
        local spellId        = tonumber(spellIdBox:GetText())
        local spellInfo      = spellId and C_Spell.GetSpellInfo(spellId) or nil
        local reminder       = {
            name = nameBox:GetText() ~= "" and nameBox:GetText() or nil,
            spellId = spellId,
            spellName = spellInfo and spellInfo.name or nil,
            iconId = spellInfo and spellInfo.iconID or getReminderTexture(current),
            CombatTime = timeValue,
            CombatTimeDelay = tonumber(delayBox:GetText()),
            StartTimerAfter = startTimeAfter,
            severity = severity:GetValue(),
            effectTypes = effects:GetValue(),
        }
        if isEditing then
            self.reminders[reminderIndex] = reminder
        else
            table.insert(self.reminders, reminder)
        end
        SortReminders(self)
        SaveReminders(self)
        SetCombatDuration(self, math.max(self.combatDuration or 0, timeValue + 5))
        self:RefreshReminders()
        dialog:Release()
        self.addEntry = nil
    end)
    dialog:AddChild(saveButton)

    if isEditing then
        local deleteButton = AceGUI:Create("Button")
        deleteButton:SetText(private.getLocalisation("ReminderDeleteButton"))
        deleteButton:SetRelativeWidth(0.5)
        deleteButton:SetCallback("OnClick", function()
            deleteReminder(self, reminderIndex)
            dialog:Release()
            self.addEntry = nil
        end)
        dialog:AddChild(deleteButton)
    else
        local cancelButton = AceGUI:Create("Button")
        cancelButton:SetText(private.getLocalisation("ReminderCancelButton"))
        cancelButton:SetRelativeWidth(0.5)
        cancelButton:SetCallback("OnClick", function()
            dialog:Release()
            self.addEntry = nil
        end)
        dialog:AddChild(cancelButton)
    end

    dialog.frame:Show()
    dialog.closeButton:SetScript("OnClick", function()
        dialog:Release()
        self.addEntry = nil
    end)

    self.addEntry = dialog
end

local function loadReminders(self, encounterID)
    local stored = private.db.profile.reminders[encounterID] or {}
    self.reminders = {}
    for _, reminder in ipairs(stored) do
        table.insert(self.reminders, copyReminder(reminder))
    end
    SortReminders(self)
end

local function SetEncounter(self, encounterParams)
    assert(type(encounterParams) == "table", "SetEncounter requires a table parameter")
    assert(
        encounterParams.journalEncounterID and encounterParams.journalInstanceID or encounterParams.dungeonEncounterID,
        "SetEncounter requires journalEncounterID, journalInstanceID, and dungeonEncounterID")
    self.journalEncounterID = encounterParams.journalEncounterID
    self.journalInstanceID = encounterParams.journalInstanceID
    self.encounterID = encounterParams.dungeonEncounterID

    local instanceName = EJ_GetInstanceInfo(self.journalInstanceID)
    local encounterName = EJ_GetEncounterInfo(self.journalEncounterID)
    self.container:SetTitle(string.format("%s%s - %s", private.getLocalisation("TimingsEditorTitle"), instanceName,
        encounterName))
    -- Clear any existing pins/rows before loading new encounter data
    clearPins(self)
    clearReminderRows(self)
    loadReminders(self, self.encounterID)
    SetCombatDuration(self, private.db.profile.editor.defaultEncounterDuration)
    UpdateTimelineWidth(self)
    HandleTicks(self)
    self:RefreshReminders()
    self.addEntryButton:SetCallback("OnClick", function()
        self:OpenReminderDialog(nil)
    end)
    if self.container and self.container.frame then
        self.container.frame:Show()
    end
    self.frame:Show()
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)

    -- main window
    local container = AceGUI:Create("ATTimingsEditorContainer")
    local main = container.content

    -- LEFT column (fixed width)
    local left = CreateFrame("Frame", Type .. "_Left", main, "BackdropTemplate")
    left:SetPoint("TOPLEFT", main, "TOPLEFT", 10, -10)
    left:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 10, 40)
    left:SetWidth(variables.FrameLeftSize)
    left:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    left:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    left:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.9)

    -- Create a container for controls at top (label, duration, button)
    local controlsContainer = AceGUI:Create("SimpleGroup")
    controlsContainer:SetLayout("List")
    controlsContainer:SetParent(left)
    controlsContainer.frame:SetPoint("TOPLEFT", left, "TOPLEFT", 0, 0)
    controlsContainer.frame:SetPoint("TOPRIGHT", left, "TOPRIGHT", 0, 0)
    controlsContainer.frame:SetFrameLevel(left:GetFrameLevel() + 50)

    local durationBox = AceGUI:Create("EditBox")
    durationBox:SetLabel(private.getLocalisation("ReminderDurationLabel"))
    durationBox:SetText(tostring(private.db.profile.editor.defaultEncounterDuration or 300))
    durationBox:SetFullWidth(true)
    controlsContainer:AddChild(durationBox)

    local addEntryButton = AceGUI:Create("Button")
    addEntryButton:SetText(private.getLocalisation("TimingsEditorAddEntryButton"))
    addEntryButton:SetRelativeWidth(1)
    addEntryButton:SetHeight(20)
    controlsContainer:AddChild(addEntryButton)

    local importButton = AceGUI:Create("Button")
    importButton:SetText(private.getLocalisation("ReminderImportButton"))
    importButton:SetRelativeWidth(1)
    importButton:SetHeight(20)
    controlsContainer:AddChild(importButton)

    local exportButton = AceGUI:Create("Button")
    exportButton:SetText(private.getLocalisation("ReminderExportButton"))
    exportButton:SetRelativeWidth(1)
    exportButton:SetHeight(20)
    controlsContainer:AddChild(exportButton)

    -- encounter picker removed; use Options -> Encounter Browser to add encounters or the EJ button.

    -- Reminder list below controls, filling remaining space
    local reminderList = AceGUI:Create("ScrollFrame")
    reminderList:SetLayout("List")
    reminderList:SetParent(left)
    reminderList.frame:SetPoint("TOPLEFT", left, "TOPLEFT", 0, -125)
    reminderList.frame:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", 0, 0)
    reminderList.frame:SetFrameLevel(left:GetFrameLevel() + 50)

    -- RIGHT column: viewport with horizontal scroll for timeline
    local rightViewport = CreateFrame("Frame", Type .. "_RightViewport", main)
    rightViewport:SetPoint("TOPLEFT", main, "TOPLEFT", variables.FrameLeftSize + 20, -10)
    rightViewport:SetPoint("TOPRIGHT", main, "TOPRIGHT", -10, -10)
    rightViewport:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -10, 40)

    -- right horizontal ScrollFrame
    local hscroll = CreateFrame("ScrollFrame", Type .. "_RightHScroll", rightViewport)
    hscroll:SetAllPoints(rightViewport)

    -- right content must be wider than viewport to allow horizontal scroll
    local rightContent = CreateFrame("Frame", Type .. "_RightContent", hscroll, "BackdropTemplate")
    rightContent:SetSize(2000, rightViewport:GetHeight())
    hscroll:SetScrollChild(rightContent)

    rightContent:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    rightContent:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
    rightContent:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.9)

    local timeline = CreateFrame("Frame", Type .. "_Timeline", rightContent, "BackdropTemplate")
    timeline:SetPoint("TOPLEFT", rightContent, "TOPLEFT", 10, -25)
    timeline:SetPoint("BOTTOMRIGHT", rightContent, "BOTTOMRIGHT", -10, 10)
    timeline:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    timeline:SetBackdropColor(0.05, 0.05, 0.06, 0.95)
    timeline:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.9)
    timeline:SetFrameLevel(rightContent:GetFrameLevel() + 50)
    timeline.Ticks = {}

    -- add a horizontal slider under rightViewport to control horizontal scroll
    local hslider = AceGUI:Create("Slider")
    hslider.frame:SetSize(rightViewport:GetWidth() - 20, 20)
    hslider:SetPoint("TOPLEFT", rightViewport, "BOTTOMLEFT", 0, 8)
    hslider:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -10, 8)
    hslider:SetSliderValues(0, 0, 1)
    hslider:SetUserData('maxScroll', 0)
    hslider:SetValue(0)
    hslider:SetCallback("OnValueChanged", function(_, _, value)
        hscroll:SetHorizontalScroll(value)
    end)
    private.Debug(hslider, "AT_TIMINGS_EDITOR_HSLIDER")

    -- Create a dummy content frame for compatibility
    local content = rightContent

    ---@class AtTimingsEditorDataFrame : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        frame = container.frame,
        content = main,
        type = Type,
        count = count,
        container = container,
        items = ITEMS,
        rightContent = rightContent,
        leftContent = controlsContainer,
        addEntryButton = addEntryButton,
        importButton = importButton,
        SetEncounter = SetEncounter,
        timeline = timeline,
        reminderList = reminderList,
        reminderPins = {},
        reminderRows = {},
        reminders = {},
        durationBox = durationBox,
        hslider = hslider,
        hscroll = hscroll,
        rightViewport = rightViewport,
        left = left,
        HandleTicks = HandleTicks,
        SetCombatDuration = SetCombatDuration,
        RefreshReminders = RefreshReminders,
        LoadReminders = loadReminders,
        OpenReminderDialog = OpenReminderDialog,
        SaveReminders = SaveReminders,
        SortReminders = SortReminders,
    }

    -- no inline encounter picker

    durationBox:SetCallback("OnEnterPressed", function(_, _, value)
        widget:SetCombatDuration(value)
        widget:RefreshReminders()
    end)

    importButton:SetCallback("OnClick", function()
        if widget.encounterID then
            private.showImportDialog(widget.encounterID, widget)
        end
    end)

    exportButton:SetCallback("OnClick", function()
        if widget.encounterID then
            private.showExportDialog(widget.encounterID)
        end
    end)

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
