---@class AddonPrivate
local Private = select(2, ...)

---@class QuickActionBarUtils
---@field callbackUtils CallbackUtils
---@field actions QuickActionObject[]
local quickActionBarUtils = {
    callbackUtils = nil,
    actions = {},
    ---@type table<any, string>
    L = nil,
}
Private.QuickActionBarUtils = quickActionBarUtils

local const = Private.constants
local qaConst = const.QUICK_ACTION_BAR

---@class QuickActionObject : QuickActionMixin

---@class QuickActionMixin
---@field actionType QA_ACTION_TYPE
---@field actionID number|string|nil
---@field customCode string|nil
---@field checkVisibility (fun(self:QuickActionObject):shouldShow:boolean)?
---@field icon number|string|?
---@field title string
---@field id number
local quickActionMixin = {
    actionType = qaConst.ACTION_TYPE.NONE,
    actionID = nil,
    customCode = nil,
    checkVisibility = nil,
    icon = nil,
}

---@return QA_ACTION_TYPE? actionType
function quickActionMixin:GetActionType()
    return self.actionType
end

---@param actionType QA_ACTION_TYPE?
function quickActionMixin:SetActionType(actionType)
    self.actionType = actionType
end

---@return number|string|nil actionID
function quickActionMixin:GetActionID()
    return self.actionID
end

---@param id number|string|?
function quickActionMixin:SetActionID(id)
    self.actionID = id
end

---@return string|nil customCode
function quickActionMixin:GetCustomCode()
    return self.customCode
end

---@param codeStr string|nil
function quickActionMixin:SetCustomCode(codeStr)
    self.customCode = codeStr
end

---@return string|number? icon
function quickActionMixin:GetIcon()
    if self.icon then
        return self.icon
    end

    local actionID = self:GetActionID()
    if not actionID then return end

    local actionType = self:GetActionType()

    if actionType == qaConst.ACTION_TYPE.ITEM then
        return C_Item.GetItemIconByID(actionID)
    elseif actionType == qaConst.ACTION_TYPE.SPELL then
        local icon = C_Spell.GetSpellTexture(actionID)
        return icon
    end
end

---@return string|number? iconOverride
function quickActionMixin:GetIconOverride()
    return self.icon
end

---@param icon string|number|?
function quickActionMixin:SetIconOverride(icon)
    self.icon = icon
end

---@return boolean shouldShow
function quickActionMixin:GetVisibility()
    if self.checkVisibility then
        return self:checkVisibility()
    end
    return true
end

---@param func (fun(self:QuickActionObject):shouldShow:boolean)?
function quickActionMixin:SetVisibilityFunc(func)
    self.checkVisibility = func
end

---@return fun(self: QuickActionObject):(shouldShow: boolean)? func
function quickActionMixin:GetVisibilityFunc()
    return self.checkVisibility
end

---@return number
function quickActionMixin:GetID()
    return self.id
end

---@param id number
function quickActionMixin:SetID(id)
    self.id = id
end

---@return string
function quickActionMixin:GetTitle()
    return self.title
end

---@param title string
function quickActionMixin:SetTitle(title)
    self.title = title
end

---@return fun(self:QuickActionObject):shouldShow:boolean
function quickActionBarUtils:GetDefaultVisibilityFunc()
    return function(obj)
        local objType = obj:GetActionType()
        if objType == qaConst.ACTION_TYPE.NONE then
            return false
        elseif objType == qaConst.ACTION_TYPE.SPELL then
            local spellIdentifier = obj:GetActionID()
            local isUsable = C_Spell.IsSpellUsable(spellIdentifier)
            return isUsable
        elseif objType == qaConst.ACTION_TYPE.ITEM then
            local itemIdentifier = obj:GetActionID()
            local count = C_Item.GetItemCount(itemIdentifier, false, true)
            if count <= 0 and itemIdentifier then
                local itemID = C_Item.GetItemIDForItemInfo(itemIdentifier)
                local usable = C_ToyBox.IsToyUsable(itemID) or false
                return usable and PlayerHasToy(itemID)
            end
            return count > 0
        end

        return true
    end
end

---@class QuickActionObjectDTO
---@field actionType QA_ACTION_TYPE
---@field actionID number|string
---@field icon string|number
---@field checkVisibility boolean|nil
---@field title string|nil
---@field customCode string|nil

---@param dto QuickActionObjectDTO
function quickActionBarUtils:CreateFromDTO(dto)
    local obj = self:CreateAction(
        dto.actionType,
        dto.actionID,
        dto.icon,
        dto.checkVisibility and self:GetDefaultVisibilityFunc() or nil,
        dto.title
    )
    obj:SetCustomCode(dto.customCode)
end

function quickActionBarUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.callbackUtils = Private.CallbackUtils

    local actions = addon:GetDatabaseValue("quickActionBar.actions", true)
    if not actions then actions = self:GetDefaultOptions() end
    ---@cast actions QuickActionObjectDTO[]
    for _, actionData in ipairs(actions) do
        self:CreateFromDTO(actionData)
    end

    addon:RegisterEvent("ITEM_COUNT_CHANGED", "QuickActionBarUtils_ItemCountChanged", function()
        self:TriggerVisibilityCallbacks()
    end)
    addon:RegisterEvent("BAG_UPDATE_DELAYED", "QuickActionBarUtils_BagUpdateDelayed", function()
        self:TriggerVisibilityCallbacks()
    end)
    addon:RegisterEvent("SPELLS_CHANGED", "QuickActionBarUtils_SpellsChanged", function()
        self:TriggerVisibilityCallbacks()
    end)
end

function quickActionBarUtils:GetDefaultOptions()
    return qaConst.DEFAULT_ACTIONS
end

function quickActionBarUtils:OnDisable()
    local actionsToSave = {}
    for _, action in ipairs(self.actions) do
        tinsert(actionsToSave, {
            actionType = action:GetActionType(),
            actionID = action:GetActionID(),
            icon = action:GetIconOverride(),
            checkVisibility = action:GetVisibilityFunc() ~= nil,
            title = action:GetTitle(),
            customCode = action:GetCustomCode(),
        })
    end
    Private.Addon:SetDatabaseValue("quickActionBar.actions", actionsToSave)
end

---@return function
function quickActionBarUtils:GetOnDefaulted()
    return function()
        self.actions = {}
        for _, action in ipairs(self:GetDefaultOptions()) do
            self:CreateFromDTO(action)
        end
    end
end

function quickActionBarUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["QuickActionBarUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["QuickActionBarUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreatePanel(settingsCategory, nil, nil, 400, "QuickActionBarSettingsPanel", Private.QuickActionBarUI:GetTreeSettingsInitializer(),
        self:GetOnDefaulted(), { settingsPrefix })
end

---@param id number
---@return QuickActionObject|nil
function quickActionBarUtils:GetActionByID(id)
    for _, action in ipairs(self.actions) do
        if action:GetID() == id then
            return action
        end
    end
    return nil
end

---@param id number
---@param newObj QuickActionObject
---@return string? errorMessage
function quickActionBarUtils:EditActionByID(id, newObj)
    local action = self:GetActionByID(id)
    if not action then return self.L["QuickActionBarUtils.ActionNotFound"] end

    action:SetActionType(newObj:GetActionType())
    action:SetActionID(newObj:GetActionID())
    action:SetIconOverride(newObj:GetIconOverride())
    action:SetVisibilityFunc(newObj:GetVisibilityFunc())
    action:SetTitle(newObj:GetTitle())

    self:TriggerUpdateCallbacks()
end

---@param id number
function quickActionBarUtils:DeleteActionByID(id)
    for index, action in ipairs(self.actions) do
        if action:GetID() == id then
            tremove(self.actions, index)
            self:TriggerUpdateCallbacks()
            return
        end
    end
end

---@return QuickActionObject[]
function quickActionBarUtils:GetVisibleActions()
    local visibleActions = {}

    for _, action in ipairs(self.actions) do
        if action:GetVisibility() then
            tinsert(visibleActions, action)
        end
    end

    return visibleActions
end

---@return QuickActionObject[]
function quickActionBarUtils:GetAllActions()
    return self.actions
end

---@param actionType QA_ACTION_TYPE?
---@param actionID string|number|nil
---@param iconOverride string|number|nil
---@param visibilityFunc (fun(self:QuickActionObject):shouldShow:boolean)?
---@param title string|nil
---@return QuickActionObject
function quickActionBarUtils:CreateAction(actionType, actionID, iconOverride, visibilityFunc, title)
    local obj = {}
    setmetatable(obj, { __index = quickActionMixin })
    ---@cast obj QuickActionObject

    obj:SetActionType(actionType)
    obj:SetActionID(actionID)
    obj:SetIconOverride(iconOverride)
    obj:SetVisibilityFunc(visibilityFunc)

    local nextID = #self.actions + 1
    while self:GetActionByID(nextID) do
        nextID = nextID + 1
    end
    obj:SetID(nextID)
    obj:SetTitle(title or (self.L["QuickActionBarUtils.Action"]:format(tostring(nextID))))

    tinsert(self.actions, obj)

    self:TriggerUpdateCallbacks()

    return obj
end

---@param callbackObj CallbackObject
function quickActionBarUtils:RemoveCallback(callbackObj)
    self.callbackUtils:RemoveCallback(callbackObj)
end

---@param callbackFunction fun(actions: QuickActionObject[])
---@return CallbackObject|nil callbackObject
function quickActionBarUtils:AddUpdateCallback(callbackFunction)
    local callback = self.callbackUtils:AddCallback(const.QUICK_ACTION_BAR.CALLBACK_CATEGORY_UPDATE, callbackFunction)
    if not callback then return nil end
    callback:Trigger(self:GetAllActions())
    return callback
end

function quickActionBarUtils:TriggerUpdateCallbacks()
    local callbacks = self.callbackUtils:GetCallbacks(const.QUICK_ACTION_BAR.CALLBACK_CATEGORY_UPDATE)
    local actions = self:GetAllActions()
    for _, callback in ipairs(callbacks) do
        callback:Trigger(actions)
    end
    self:TriggerVisibilityCallbacks()
end

---@param callbackFunction fun(visibleActions: QuickActionObject[])
---@return CallbackObject|nil callbackObject
function quickActionBarUtils:AddVisibilityCallback(callbackFunction)
    local callback = self.callbackUtils:AddCallback(const.QUICK_ACTION_BAR.CALLBACK_CATEGORY_VISIBILITY, callbackFunction)
    if not callback then return nil end
    callback:Trigger(self:GetVisibleActions())
    return callback
end

function quickActionBarUtils:TriggerVisibilityCallbacks()
    local callbacks = self.callbackUtils:GetCallbacks(const.QUICK_ACTION_BAR.CALLBACK_CATEGORY_VISIBILITY)
    local visibleActions = self:GetVisibleActions()
    for _, callback in ipairs(callbacks) do
        callback:Trigger(visibleActions)
    end
end
