local CraftScan = select(2, ...)

local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

local dialogPool = CreateFramePool("Frame", UIParent, "CraftScanDialogTemplate")
local textPool = CreateFramePool("Frame", nil, "CraftScanDialogTextTemplate")
local editBoxPool = CreateFramePool("EditBox", nil, "CraftScanDialogTextInputTemplate")
local multiLineEditBoxPool = CreateFramePool("ScrollFrame", nil, "CraftScanDialogMultiLineTextInputTemplate")
local defaultButtonPool = CreateFramePool("Button", nil, "CraftScan_DialogDefaultButtonTemplate")
local checkButtonPool = CreateFramePool("CheckButton", nil, "CraftScanDialogCheckButtonTemplate")

CraftScan.Dialog = {}

CraftScan.Dialog.Element = {
    EditBox = 1,
    Text = 2,
    CheckButton = 3,

    DefaultButton = 4,
};

CraftScan_DialogCheckButtonMixin = {}

function CraftScan_DialogCheckButtonMixin:OnClick()
    self:GetParent():CheckEnableSubmit()
end

-- We support both a basic EditBox and a multiline EditBox with a ScrollFrame
-- around it. We want all the same validations on the text in the EditBox to be
-- supported. The only real difference is whether we are nested in a
-- ScrollFrame, so this is used to dereference the EditBox.
local function EditBoxToFrame(editBox)
    if editBox:IsMultiLine() then
        return editBox:GetParent();
    end
    return editBox;
end

-- We also occasionally iterate the frames to collect inputs, so we need to be
-- able to dereference a frame to get its EditBox. The EditBox can be either the
-- frame itself or the EditBox within the ScrollFrame.
local function FrameToEditBox(frame)
    if frame.EditBox then
        return frame.EditBox;
    end
    return frame;
end

local function CreateArgs(dialog)
    local args = {};
    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            table.insert(args, FrameToEditBox(frame):GetText());
        end
        if frame.type == CraftScan.Dialog.Element.CheckButton then
            table.insert(args, frame:GetChecked())
        end
    end
    return unpack(args);
end

CraftScanDialogMixin = {};

function CraftScanDialogMixin:CheckEnableSubmit()
    for _, frame in ipairs(self.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            local editBox = FrameToEditBox(frame)
            if (not editBox.allowEmpty and (editBox:GetText() == "")) or frame.error == true then
                self.SubmitButton:SetEnabled(false);
                return;
            end
        end
    end

    local enabled = true;
    if self.Validator then
        enabled = self.Validator(CreateArgs(self));
    end

    self.SubmitButton:SetEnabled(enabled);
end

local uniq = {};

function CraftScanDialogMixin:OnHide()
    if self.initialized then
        if not self.accepted and self.OnReject then
            self.OnReject();
        end

        if self.frames then
            for _, frame in ipairs(self.frames) do
                if frame.type == CraftScan.Dialog.Element.EditBox then
                    frame.InvalidInput.error = nil;
                    frame.InvalidInput.warning = nil;
                    frame.InvalidInput:Hide();
                    frame.InvalidInput:Hide();
                    frame.error = false;

                    local editBox = FrameToEditBox(frame);
                    editBox:SetText("");
                    editBox.Validator = nil;
                    if editBox == frame then
                        editBoxPool:Release(frame);
                    else
                        multiLineEditBoxPool:Release(frame);
                    end
                elseif frame.type == CraftScan.Dialog.Element.DefaultButton then
                    defaultButtonPool:Release(frame);
                elseif frame.type == CraftScan.Dialog.Element.CheckButton then
                    checkButtonPool:Release(frame);
                else
                    textPool:Release(frame);
                end
            end
            self.frames = nil;
        end
        self.accepted = nil;
        self.initialized = nil;
        if self.key then
            uniq[self.key] = nil;
        end
        CraftScan.Utils.printTable("Hiding dialog", self.key);
        self.key = nil;
        self.OnAccept = nil;
        self.OnReject = nil;
        self.Validator = nil;
        dialogPool:Release(self);
    end
end

CraftScanDialogSubmitMixin = {};

function CraftScanDialogSubmitMixin:OnClick()
    local dialog = self:GetParent();
    if dialog.OnAccept then
        dialog.OnAccept(CreateArgs(dialog));
    end
    dialog.accepted = true;
    dialog:Hide();
end

CraftScan_DialogTextInputAlertIconMixin = {}

function CraftScan_DialogTextInputAlertIconMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.error then
        GameTooltip:SetText(self.error, 1, 0, 0, 1, true)
    else
        GameTooltip:SetText(self.warning, 1, 0.647, 0, 1, true)
    end
    GameTooltip:Show()
end

function CraftScan_DialogTextInputAlertIconMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScanDialogTextInputMixin = {};

function CraftScanDialogTextInputMixin:OnLoad()
    self:SetAutoFocus(false);
end

CraftScanDialogMultiLineTextInputMixin = {};

function CraftScanDialogMultiLineTextInputMixin:OnLoad()
    local editBox = self.EditBox;
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetAutoFocus(false);
    editBox:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    InputScrollFrame_OnLoad(self);
end

local function EditBox_OnEscapePressed(self)
    self:ClearFocus();
end

local function EditBox_OnTabPressed(self)
    local next = false;
    local dialog = EditBoxToFrame(self):GetParent();
    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            if next then
                FrameToEditBox(frame):SetFocus(true);
                return;
            end
            if FrameToEditBox(frame) == self then
                next = true;
            end
        end
    end
    self:ClearFocus();
end

local function EditBox_OnEnterPressed(self)
    self:ClearFocus();

    local dialog = EditBoxToFrame(self):GetParent();
    if dialog.SubmitButton:IsEnabled() then
        dialog.SubmitButton:OnClick();
    else
        EditBox_OnTabPressed(self);
    end
end

local function EditBox_OnEditFocusLost(self)
    local text = self:GetText()

    local frame = EditBoxToFrame(self);

    if frame.DefaultButton then
        frame.DefaultButton:Refresh();
    end

    if self.Validator then
        local result = self.Validator(self.index, text);
        frame.error = false;

        if result ~= nil then
            if result.error then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(result.error, 1, 0, 0, 1, true)
                GameTooltip:Show()

                frame.InvalidInput:SetAtlas("common-icon-redx")
                frame.InvalidInput.error = result.error;
                frame.InvalidInput:Show();
                frame.InvalidInput:OnEnter();
                frame.error = true;

                frame:GetParent().SubmitButton:SetEnabled(false);
                return;
            end
            if result.warning then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                frame.InvalidInput:SetAtlas("UI-HUD-MicroMenu-Questlog-Mouseover")
                frame.InvalidInput.warning = result.warning;
                frame.InvalidInput:Show();
                frame.InvalidInput:OnEnter();
            end
        else
            GameTooltip:Hide();
            frame.InvalidInput:Hide();
        end
    end
    frame:GetParent():CheckEnableSubmit();
end

CraftScan_DialogDefaultButtonMixin = {}

function CraftScan_DialogDefaultButtonMixin:OnClick()
    self.EditBox:SetText(self.default_text);
    EditBox_OnEditFocusLost(self.EditBox);
    self:SetEnabled(false);
end

function CraftScan_DialogDefaultButtonMixin:Refresh()
    if FrameToEditBox(self:GetParent()):GetText() == self.default_text then
        self:SetEnabled(false);
    else
        self:SetEnabled(true);
    end
end

local function LayoutFramesVertically(frames, parent, padding)
    local totalHeight = 0;
    for _, frame in ipairs(frames) do
        if frame.type ~= CraftScan.Dialog.Element.DefaultButton then
            frame:ClearAllPoints(); -- Clear any previous points to avoid conflicts
            local totalPadding = (frame.padding or 0) + padding;
            if frame.alignLeft then
                frame.alignLeft = nil;
                frame:SetPoint("TOPLEFT", parent, frame.relativePoint or "TOPLEFT", 25,
                    -totalHeight - totalPadding - 28);
            else
                frame:SetPoint("TOP", parent, "TOP", 0, -totalHeight - totalPadding - 28);
            end
            totalHeight = totalHeight + frame:GetHeight() + totalPadding;
        end
    end
    return totalHeight;
end

function CraftScan.Dialog.Show(config)
    if config.key and uniq[config.key] then
        return;
    end

    local dialog = dialogPool:Acquire();

    dialog:SetWidth(config.width or 300);

    local elementWidth = dialog:GetWidth() - 40;

    local firstEditBox = nil;
    local editBoxIndex = 1;
    dialog.frames = {};
    local nextPadding = 0;
    for _, entry in ipairs(config.elements) do
        local np = nextPadding;
        nextPadding = 0;

        local widthAdjust = 0;
        local frame;
        if entry.type == CraftScan.Dialog.Element.EditBox then
            if entry.multiline then
                frame = multiLineEditBoxPool:Acquire();
            else
                frame = editBoxPool:Acquire();
            end
            submitEnabled = false;

            local editBox = FrameToEditBox(frame);
            if not firstEditBox then
                firstEditBox = editBox;
            end

            editBox.Validator = entry.Validator;
            editBox.index = editBoxIndex;
            editBox.allowEmpty = entry.allowEmpty;
            editBoxIndex = editBoxIndex + 1;

            if not entry.multiline then
                editBox:SetScript("OnEnterPressed", function(self) EditBox_OnEnterPressed(self) end);
            end
            editBox:SetScript("OnEditFocusLost", function(self) EditBox_OnEditFocusLost(self) end);
            editBox:SetScript("OnTabPressed", function(self) EditBox_OnTabPressed(self) end);
            editBox:SetScript("OnEscapePressed", function(self) EditBox_OnEscapePressed(self) end);

            if entry.initial_text then
                editBox:SetText(entry.initial_text);
            end
            if entry.default_text then
                local defaultButton = defaultButtonPool:Acquire();
                defaultButton:SetParent(frame);
                defaultButton:SetText(entry.default_label or L("Default"));
                defaultButton:FitToText();
                defaultButton:ClearAllPoints();
                defaultButton:SetPoint("LEFT", frame, "RIGHT", entry.multiline and 8 or 3, 0);
                defaultButton.EditBox = editBox;
                frame.DefaultButton = defaultButton;
                defaultButton.default_text = entry.default_text;
                defaultButton:Refresh();
                defaultButton:Show();
                widthAdjust = -defaultButton:GetWidth();
                frame.alignLeft = true;
                defaultButton.type = CraftScan.Dialog.Element.DefaultButton;
                table.insert(dialog.frames, defaultButton);
            end
            if entry.multiline then
                -- The scrollframe has some padding the edit box does not. This
                -- aligns with the extra xOffset above.
                widthAdjust = widthAdjust - 5;
                editBox:SetWidth(elementWidth + widthAdjust - 20) -- -20 for the scrollbar
            end
        elseif entry.type == CraftScan.Dialog.Element.CheckButton then
            frame = checkButtonPool:Acquire();
            frame.Text:SetText(entry.text);
            frame:SetChecked(entry.default or false);
            if entry.description then
                frame.Description:SetHeight(1000); -- ALlow textwrapping to work, then resize to fit
                frame.Description:SetWidth(elementWidth - 35);
                frame.Description:SetJustifyH("LEFT");
                frame.Description:SetText(entry.description);
                local height = frame.Description:GetStringHeight();
                frame.Description:SetHeight(height + 25);
                nextPadding = height + 10;
            else
                frame:SetHeight(18);
            end
            frame.alignLeft = true;
        elseif entry.type == CraftScan.Dialog.Element.Text then
            frame = textPool:Acquire();
            frame.Text:SetHeight(1000); -- ALlow textwrapping to work, then resize to fit
            frame:SetHeight(1000);      -- ALlow textwrapping to work, then resize to fit
            frame.Text:SetText(entry.text);
            local height = frame.Text:GetStringHeight() + 25;
            frame.Text:SetHeight(height);
            frame:SetHeight(height);
        end
        frame.type = entry.type;
        if entry.padding or np ~= 0 then
            frame.padding = (entry.padding or 0) + np;
        end
        if entry.type ~= CraftScan.Dialog.Element.CheckButton then
            frame:SetWidth(elementWidth + widthAdjust)
        end
        frame:Show();
        frame:SetParent(dialog);
        table.insert(dialog.frames, frame);
    end

    dialog:SetHeight(80 + LayoutFramesVertically(dialog.frames, dialog, 0));
    dialog:SetTitle(config.title);
    dialog.SubmitButton:SetText(config.submit);
    dialog.SubmitButton:FitToText();
    dialog:CheckEnableSubmit();
    dialog.OnAccept = config.OnAccept;
    dialog.OnReject = config.OnReject;
    dialog.Validator = config.Validator;


    for _, frame in ipairs(dialog.frames) do
        if frame.type == CraftScan.Dialog.Element.EditBox then
            local editBox = FrameToEditBox(frame);
            if editBox.Validator and #editBox:GetText() then
                EditBox_OnEditFocusLost(editBox);
            end
        end
    end

    CraftScan.Frames.makeMovable(dialog);
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    dialog.initialized = true;
    dialog.key = config.key;
    uniq[config.key] = dialog;
    CraftScan.Utils.printTable("Showing dialog", config.key);
    dialog:Show();

    if firstEditBox then
        firstEditBox:SetFocus();
    end
end
