---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants
local addon = Private.Addon

function addon:OnInitialize(...)
    Private.SettingsUtils:Init()

    Private.CommsUtils:Init()
    Private.TooltipUtils:Init()
    Private.ScrappingUtils:Init()
    Private.ToastUtils:Init()
    Private.ArtifactTraitUtils:Init()
    Private.ResearchTaskUtils:Init()
    Private.CollectionUtils:Init()
    Private.QuickActionBarUtils:Init()
    Private.QuestUtils:Init()
    Private.ItemOpenerUtils:Init()
    Private.MerchantUtils:Init()

    Private.CollectionsTabUI:Init()
    Private.ToastUI:Init()

    Private.UXUtils:Init()
    Private.CommandUtils:Init()
end

function addon:OnEnable(...)
    Private.DatabaseUtils:LoadDefaultsForMissing()
    Private.EditModeUtils:Init()

    Private.UXUtils:CreateSettings()
    Private.MerchantUtils:CreateSettings()
    Private.ToastUtils:CreateSettings()
    Private.QuestUtils:CreateSettings()
    Private.ArtifactTraitUtils:CreateSettings()
    Private.TooltipUtils:CreateSettings()
    Private.QuickActionBarUtils:CreateSettings()
    Private.ItemOpenerUtils:InitAndCreateSettings()

    Private.ToastUI:CreateEditModeElements()

    Private.UpdateUtils:OnEnable()
end

function addon:OnDisable(...)
    Private.QuickActionBarUtils:OnDisable()
end
