-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Util = TSM:NewModule("Util", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Vendoring") -- loads the localization table
local private = {}

Util.Currencies = {
["Interface\\Icons\\inv_datacrystal06"] = 897,
["Interface\\Icons\\pvecurrency-justice"] = 395,
["Interface\\Icons\\INV-Sword_53"] = 22,
["Interface\\Icons\\inv_misc_coin_17"] = 697,
["Interface\\Icons\\INV_Misc_Rune_07"] = 125,
["Interface\\Icons\\inv_misc_ticket_darkmoon_01"] = 515,
["Interface\\Icons\\INV_Misc_Coin_16"] = 201,
["Interface\\Icons\\INV_Misc_Coin_07"] = 4,
["Interface\\Icons\\inv_apexis_draenor"] = 823,
["Interface\\Icons\\trade_alchemy"] = 910,
["Interface\\Icons\\trade_archaeology_nerubian_artifactfragment"] = 400,
["Interface\\Icons\\INV_Jewelry_Necklace_27"] = 321,
["Interface\\Icons\\trade_blacksmithing"] = 1020,
["Interface\\Icons\\pvecurrency-valor"] = 396,
["Interface\\Icons\\inv_garrison_resource"] = 824,
["Interface\\Icons\\achievement_zone_tolbarad"] = 391,
["Interface\\Icons\\trade_archaeology_titan_fragment"] = 698,
["Interface\\Icons\\PVPCurrency-Conquest-Horde"] = 390,
["Interface\\Icons\\timelesscoin-bloody"] = 789,
["Interface\\Icons\\spell_nature_rockbiter"] = 828,
["Interface\\Icons\\inv_ashran_artifact"] = 944,
["Interface\\Icons\\trade_leatherworking"] = 1017,
["Interface\\Icons\\trade_archaeology_highborne_artifactfragment"] = 394,
["Interface\\Icons\\achievement_battleground_templeofkotmogu_02_green"] = 1129,
["Interface\\Icons\\inv_stone_15"] = 810,
["Interface\\Icons\\trade_archaeology_dwarf_artifactfragment"] = 384,
["Interface\\Icons\\Spell_Nature_EyeOfTheStorm"] = 123,
["Interface\\Icons\\INV_Jewelry_Necklace_21"] = 121,
["Interface\\Icons\\archaeology_5_0_mogucoin"] = 752,
["Interface\\Icons\\Spell_Holy_ChampionsGrace"] = 221,
["Interface\\Icons\\pvpcurrency-conquest-horde"] = 692,
["Interface\\Icons\\trade_tailoring"] = 999,
["Interface\\Icons\\garrison_oil"] = 1101,
["Interface\\Icons\\achievement_dungeon_arakkoaspires"] = 829,
["Interface\\Icons\\inv_misc_gem_01"] = 1008,
["Interface\\Icons\\ability_animusorbs"] = 994,
["Interface\\Icons\\achievement_character_orc_male_brn"] = 821,
["Interface\\Icons\\trade_archaeology_vrykul_artifactfragment"] = 677,
["Interface\\Icons\\Spell_Holy_ChampionsBond"] = 104,
["Interface\\Icons\\INV_Jewelry_Amulet_01"] = 124,
["Interface\\Icons\\trade_archaeology_orc_artifactfragment"] = 397,
["Interface\\Icons\\inv_misc_coin_09"] = 980,
["Interface\\Icons\\trade_archaeology_fossil_fern"] = 393,
["Interface\\Icons\\inv_misc_markoftheworldtree"] = 416,
["Interface\\Icons\\inv_elemental_primal_shadow"] = 615,
["Interface\\Icons\\inv_arcane_orb"] = 776,
["Interface\\Icons\\timelesscoin"] = 777,
["Interface\\Icons\\inv_relics_idolofferocity"] = 402,
["Interface\\Icons\\inv_misc_frostemblem_01"] = 341,
["Interface\\Icons\\Spell_Holy_ProclaimChampion_02"] = 102,
["Interface\\Icons\\INV_Misc_Gem_Variety_01"] = 61,
["Interface\\Icons\\INV_Misc_Ribbon_01"] = 81,
["Interface\\Icons\\inv_misc_archaeology_mantidstatue_01"] = 754,
["Interface\\Icons\\INV_Misc_Platnumdisks"] = 161,
["Interface\\Icons\\inv_misc_coin_18"] = 738,
["Interface\\Icons\\spell_holy_summonchampion"] = 301,
["Interface\\Icons\\Ability_Paladin_ArtofWar"] = 241,
["Interface\\Icons\\trade_archaeology_draenei_artifactfragment"] = 398,
["Interface\\Icons\\INV_Jewelry_Ring_66"] = 126,
["Interface\\Icons\\INV_Jewelry_Amulet_07"] = 122,
["Interface\\Icons\\trade_archaeology_troll_artifactfragment"] = 385,
["Interface\\Icons\\INV_Banner_03"] = 181,
["Interface\\Icons\\spell_shadow_sealofkings"] = 614,
["Interface\\Icons\\PVPCurrency-Honor-Horde"] = 392,
["Interface\\Icons\\inv_misc_token_argentdawn3"] = 361
}

function Util:GetMaxAfford(index)
	local maxAfford = nil
	local price, extendedCost = TSMAPI.Util:Select({3, 7}, GetMerchantItemInfo(index))

	if price > 0 then
		maxAfford = math.floor(GetMoney() / price)
	end

	if extendedCost then
		local numCosts = GetMerchantItemCostInfo(index)

		for cindex = 1, numCosts do
			local costTexture, costValue, costItemLink, costName = GetMerchantItemCostItem(index,cindex)

			if costValue > 0 then
				local costNumHave = 0

				if costItemLink then
					local costItemString = TSMAPI.Item:ToItemString(costItemLink)
					costNumHave = TSMAPI.Inventory:GetBagQuantity(costItemString) + TSMAPI.Inventory:GetBankQuantity(costItemString) + TSMAPI.Inventory:GetReagentBankQuantity(costItemString)
				else
					local currency = Util.Currencies[costTexture]

					if currency then
						costNumHave = select(2, GetCurrencyInfo(currency))
					end
				end

				local costCanBuy = math.floor(costNumHave / costValue)

				if maxAfford == nil or costCanBuy < maxAfford then
					maxAfford = costCanBuy
				end
			end
		end
	end

	return maxAfford or 0
end

function Util:GetMaxFit(index)

	local itemLink = GetMerchantItemLink(index)
	local itemString = TSMAPI.Item:ToItemString(itemLink)
	local maxStackSize = TSMAPI.Item:GetMaxStack(itemString)

	local maxFit = 0

	for bag = 0, NUM_BAG_SLOTS do
		if TSMAPI.Inventory:ItemWillGoInBag(itemLink, bag) then
			for slot = 1, GetContainerNumSlots(bag) do
				local iString = TSMAPI.Item:ToItemString(GetContainerItemLink(bag, slot))
				if iString == itemString then
					local stackSize = select(2, GetContainerItemInfo(bag, slot))
					maxFit = maxFit + (maxStackSize - stackSize)
				elseif not iString then
					maxFit = maxFit + maxStackSize
				end
			end
		end
	end

	return maxFit
end
