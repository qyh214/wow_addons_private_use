---@meta

-- ----------------------------------------------------------------------------
-- Types
-- ----------------------------------------------------------------------------
---@class Array<T>: { [integer]: T }
---@class Dictionary<T>: { [string]: T }
---@class Localizations: Dictionary<boolean|string>


-- ----------------------------------------------------------------------------
-- Keystone Info
-- ----------------------------------------------------------------------------
---@class KeystoneInfo
---@field itemId integer
---@field instanceId integer
---@field keyLevel integer
---@field affix1 integer
---@field affix2 integer
---@field affix3 integer
---@field affix4 integer


-- ----------------------------------------------------------------------------
-- Item Bonus Info
-- ----------------------------------------------------------------------------
---@class ItemBonusInfo
---@field itemLevel integer
---@field rank integer
---@field upgradeLevel integer
---@field maxUpgradeLevel integer
---@field upgradeGroup integer
---@field costs Array<Array<UpgradeTrackCost>>


-- ----------------------------------------------------------------------------
-- Honor Bonus Data
-- ----------------------------------------------------------------------------
---@class HonorBonusData
---@field itemLevel integer
---@field upgradeLevel integer
---@field maxUpgradeLevel integer


-- ----------------------------------------------------------------------------
-- Bonus Data
-- ----------------------------------------------------------------------------
---@class BonusData
---@field currencyId integer
---@field amount integer
---@field toMax integer


-- ----------------------------------------------------------------------------
-- Mythic+ Table Data
-- ----------------------------------------------------------------------------
---@class MythicPlusInfo
---@field keyLevel integer|string
---@field lootDrops integer
---@field vaultReward integer
---@field currency UpgradeData


-- ----------------------------------------------------------------------------
-- Raid Table Data
-- ----------------------------------------------------------------------------
---@class RaidInfo
---@field boss integer|string
---@field lfr integer
---@field normal integer
---@field heroic integer
---@field mythic integer

---@class RaidCurrencyInfo
---@field lfrCurrency UpgradeData
---@field normalCurrency UpgradeData
---@field heroicCurrency UpgradeData
---@field mythicCurrency UpgradeData


-- ----------------------------------------------------------------------------
-- Upgrade Table Data
-- ----------------------------------------------------------------------------
---@class UpgradeData
---@field name string
---@field shortName string
---@field color ColorMixin
---@field icon fileID|integer
---@field itemId integer?
---@field currencyId integer?

---@class UpgradeTrackCost
---@field currencyId integer
---@field amount integer

---@class UpgradeTrackInfo
---@field itemLevel integer
---@field upgrade1 UpgradeTrackUpgrade
---@field upgrade2 UpgradeTrackUpgrade?
---@field upgrade3 UpgradeTrackUpgrade?
---@field upgrade4 UpgradeTrackUpgrade?
---@field currency UpgradeData

---@class UpgradeTrackUpgrade
---@field rank integer
---@field upgradeLevel integer
---@field maxUpgradeLevel integer


-- ----------------------------------------------------------------------------
-- Crafting Data
-- ----------------------------------------------------------------------------
---@class CraftingInfo
---@field itemLevel integer
---@field itemId integer
---@field rank integer
---@field iconPath string
---@field itemInfo table?
