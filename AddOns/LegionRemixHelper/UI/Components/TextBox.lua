---@class AddonPrivate
local Private = select(2, ...)

Private.Components = Private.Components or {}

---@class TextBoxComponentObject: TextBoxComponentMixin

---@class TextBoxComponentOptions
---@field frame_strata FrameStrata?
---@field width number?
---@field height number?
---@field anchors table?
---@field template string? Default "InputBoxInstructionsTemplate"
---@field text string?
---@field instructions string?
---@field color table? CreateColor
---@field font string?
---@field justifyH "LEFT"|"CENTER"|"RIGHT"?
---@field justifyV "TOP"|"MIDDLE"|"BOTTOM"?
---@field maxLetters integer?
---@field onEnterPressed fun(text:string)?
---@field onEscapePressed fun(text:string)?
---@field onTextChanged fun(text:string, userInput:boolean)?
local defaultOptions = {
    frame_strata = "HIGH",
    width = 150,
    height = 20,
    anchors = {
        { "CENTER" },
    },
    template = "InputBoxInstructionsTemplate",
    text = "",
    instructions = "",
    color = CreateColor(1, 1, 1, 1),
    font = "GameFontNormal",
    justifyH = "LEFT",
    justifyV = "MIDDLE",
    maxLetters = nil,
    onEnterPressed = nil,
    onEscapePressed = nil,
    onTextChanged = nil,
}

---@class TextBoxComponent
---@field defaultOptions TextBoxComponentOptions
local textBoxComponent = {
    defaultOptions = defaultOptions,
}
Private.Components.TextBox = textBoxComponent

local componentsBase = Private.Components.Base

---@class TextBoxComponentMixin
---@field editBox EditBox
---@field instructionsFS FontString|nil
local textBoxComponentMixin = {}

function textBoxComponentMixin:SetText(text)
    self.editBox:SetText(text or "")
end

function textBoxComponentMixin:GetText()
    return self.editBox:GetText()
end

function textBoxComponentMixin:SetTextColor(r, g, b, a)
    if self.editBox.SetTextColor then
        self.editBox:SetTextColor(r, g, b, a)
    end
end

function textBoxComponentMixin:SetFontObject(fontObject)
    self.editBox:SetFontObject(fontObject or "GameFontNormal")
end

function textBoxComponentMixin:SetJustifyH(justify)
    if self.editBox.SetJustifyH then
        self.editBox:SetJustifyH(justify or "LEFT")
    end
end

function textBoxComponentMixin:SetJustifyV(justify)
    if self.editBox.SetJustifyV then
        self.editBox:SetJustifyV(justify or "MIDDLE")
    end
end

function textBoxComponentMixin:SetInstructions(text)
    if self.instructionsFS then
        self.instructionsFS:SetText(text or "")
    end
end

function textBoxComponentMixin:SetMaxLetters(max)
    if type(max) == "number" then
        self.editBox:SetMaxLetters(max)
    end
end

function textBoxComponentMixin:SetFocus()
    self.editBox:SetFocus()
end

function textBoxComponentMixin:ClearFocus()
    self.editBox:ClearFocus()
end

---@param parent Frame?
---@param options TextBoxComponentOptions
---@return TextBoxComponentObject textBox
function textBoxComponent:CreateFrame(parent, options)
    parent = parent or UIParent
    if not options.frame_strata then
        options.frame_strata = parent:GetFrameStrata()
    end
    options = componentsBase:MixTables(defaultOptions, options)

    ---@class EditBoxWithInstructions: EditBox
    ---@field Instructions FontString|nil
    local editBox = CreateFrame("EditBox", nil, parent, options.template)
    editBox:SetFrameStrata(options.frame_strata)
    editBox:SetSize(options.width, options.height)
    editBox:SetAutoFocus(false)
    editBox:SetMultiLine(false)

    for _, anchor in ipairs(options.anchors) do
        editBox:SetPoint(unpack(anchor))
    end

    -- Configure visuals and behavior
    if options.font then
        editBox:SetFontObject(options.font)
    end
    if options.justifyH and editBox.SetJustifyH then
        editBox:SetJustifyH(options.justifyH)
    end
    if options.justifyV and editBox.SetJustifyV then
        editBox:SetJustifyV(options.justifyV)
    end
    if options.text then
        editBox:SetText(options.text)
    end
    if options.color and editBox.SetTextColor then
        local r, g, b, a = options.color:GetRGBA()
        editBox:SetTextColor(r, g, b, a)
    end
    if options.maxLetters then
        editBox:SetMaxLetters(options.maxLetters)
    end

    local instructionsFS = nil
    if editBox.Instructions then
        instructionsFS = editBox.Instructions
        if instructionsFS and options.instructions then
            instructionsFS:SetText(options.instructions)
        end
    end

    editBox:SetScript("OnEnterPressed", function()
        editBox:ClearFocus()
        if options.onEnterPressed then
            options.onEnterPressed(editBox:GetText())
        end
    end)
    editBox:SetScript("OnEscapePressed", function()
        editBox:ClearFocus()
        if options.onEscapePressed then
            options.onEscapePressed(editBox:GetText())
        end
    end)
    editBox:HookScript("OnTextChanged", function(_, userInput)
        if options.onTextChanged then
            options.onTextChanged(editBox:GetText(), userInput)
        end
    end)

    return self:CreateObject(editBox, instructionsFS)
end

---@param editBox EditBox
---@param instructionsFS FontString|nil
---@return TextBoxComponentObject
function textBoxComponent:CreateObject(editBox, instructionsFS)
    local obj = {}
    obj.editBox = editBox
    obj.instructionsFS = instructionsFS

    setmetatable(obj, { __index = textBoxComponentMixin })
    return obj
end
