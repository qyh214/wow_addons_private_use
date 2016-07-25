-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - koKR
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "koKR")
if not L then return end
L["Canceled"] = "취소" -- Needs review
-- L["Deposit Reagents"] = ""
L["Displays realtime move data."] = "데이터 이동을 실시간으로 표시합니다." -- Needs review
L["Empty Bags"] = "가방 비우기"
L["Enable Restock"] = "재보충 사용" -- Needs review
L["Enable this to set the quantity to keep back in your bags"] = "활성화 시 가방에 유지할 수량을 설정할 수 있습니다." -- Needs review
L["Enable this to set the quantity to keep back in your bank / guildbank"] = "활성화 시 은행/길드 은행에 유지할 수량을 설정할 수 있습니다." -- Needs review
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = "활성화 시 이동할 수량을 설정할 수 있습니다. 비활성화 시 모든 아이템이 이동됩니다." -- Needs review
L["Enable this to set the restock quantity"] = "활성화 시 재보충 수량을 설정할 수 있습니다." -- Needs review
-- L["Enable this to set the stack size multiple to be moved"] = ""
L["General"] = "일반" -- Needs review
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = "아이템 링크, 아이템ID, 입력된 부분적인 아이템 이름과 일치하는 아이템을 은행 또는 길드 은행에서 가져옵니다." -- Needs review
L["Invalid criteria entered."] = "입력이 잘못되었습니다." -- Needs review
L["Keep in Bags Quantity"] = "가방에 유지할 수량" -- Needs review
L["Keep in Bank/GuildBank Quantity"] = "은행/길드 은행에 유지할 수량" -- Needs review
-- L["Lists the groups with warehousing operations. Left click to select/deselect the group, Right click to expand/collapse the group."] = ""
L["Move Data has been turned off"] = "데이터 이동 중지" -- Needs review
L["Move Data has been turned on"] = "데이터 이동 가능" -- Needs review
L["Move Group to Bags"] = "가방으로 이동"
L["Move Group to Bank"] = "은행으로 이동"
L["Move Quantity"] = "이동 수량" -- Needs review
L["Move Quantity Settings"] = "이동 수량 설정" -- Needs review
L["Nothing to Move"] = "이동할 아이템 없음" -- Needs review
L["Nothing to Restock"] = "재보충할 아이템 없음" -- Needs review
L["Preparing to Move"] = "이동 준비" -- Needs review
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = "아이템 링크, 아이템ID, 입력된 부분적인 아이템 이름과 일치하는 아이템을 은행 또는 길드 은행에 넣습니다." -- Needs review
L["Restock Bags"] = "가방 재보충" -- Needs review
L["Restocking"] = "재보충 중" -- Needs review
L["Restock Quantity"] = "재보충 수량" -- Needs review
L["Restock Settings"] = "재보충 설정" -- Needs review
L["Restore Bags"] = "가방 복구"
L["Set Keep in Bags Quantity"] = "가방에 유지할 수량 설정" -- Needs review
L["Set Keep in Bank Quantity"] = "은행에 유지할 수량 설정" -- Needs review
L["Set Move Quantity"] = "이동 수량 설정" -- Needs review
-- L["Set Stack Size for bags"] = ""
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = "'%s' 그룹에 포함된 '%s' 작업은 더이상 존재하지 않습니다." -- Needs review
-- L["Stack Size Multiple"] = ""
L["There are no visible banks."] = "은행이 없습니다." -- Needs review
-- L["These will toggle between the module specific tabs."] = ""
-- L["This button will deposit all reagents to your reagent bank (if unlocked)."] = ""
-- L["This button will de-select all groups."] = ""
-- L["This button will empty the contents of your bags and move them all to the bank. It will remember what you moved so that you can use the restore button to put them back"] = ""
-- L["This button will move all items in the selected groups using the operation restock settings from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from your bags to the bank."] = ""
-- L["This button will restore the items to your bags from the last time you clicked empty bags."] = ""
-- L["This button will select all groups."] = ""
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = "창고 작업은 아이템 그룹을 이동할 수 있는 설정을 가지고 있습니다. 아래 상자에 새 작업 이름을 입력하고 '엔터'를 치면 새 창고 작업이 생성됩니다." -- Needs review
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = "은행 / 길드 은행으로 아이템을 이동시킬 때 이 수량만큼은 가방에 남겨둡니다." -- Needs review
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = "가방으로 아이템을 이동시킬 때 이 수량만큼은 은행 / 길드 은행에 남겨둡니다." -- Needs review
-- L["Warehousing will ensure this number remain in your bank / guildbank when restocking items to your bags."] = ""
L["Warehousing will move all of the items in this group."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹의 모든 아이템을 이동시킵니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지하고, 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 가방에서 은행/길드은행으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 은행/길드은행에서 가방으로 이동 시 각각 %d개의 아이템을 유지합니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = "창고 관리자는 이 그룹 아이템을 각각 최대 %d개씩 이동시킵니다. 재보충으로 %d개의 아이템을 가방에 유지합니다." -- Needs review
L["Warehousing will move this number of each item"] = "각 아이템을 이 수량만큼 이동시킵니다." -- Needs review
-- L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"] = ""
L["Warehousing will restock your bags up to this number of items"] = "최대 이 수량만큼의 아이템을 가방에 재보충합니다." -- Needs review
