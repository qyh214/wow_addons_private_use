---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants

---@class UpdateUtils
local updateUtils = {
    ---@type LegionRH
    addon = nil,
    ---@type table<any, string>
    L = nil,
}
Private.UpdateUtils = updateUtils

function updateUtils:OnEnable()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon

    local dbVersion = addon:GetDatabaseValue("version", true)

    if dbVersion ~= const.ADDON_VERSION then
        addon:SetDatabaseValue("version", const.ADDON_VERSION)
        self:ShowPatchNotes(dbVersion, const.ADDON_VERSION)
    end
end

---@param oldVersion string|nil
---@param newVersion string|nil
function updateUtils:ShowPatchNotes(oldVersion, newVersion)
    oldVersion = oldVersion or self.L["UpdateUtils.NilVersion"]
    newVersion = newVersion or self.L["UpdateUtils.NilVersion"]
    self.addon:FPrint(self.L["UpdateUtils.PatchNotesMessage"], tostring(oldVersion), tostring(newVersion))
end