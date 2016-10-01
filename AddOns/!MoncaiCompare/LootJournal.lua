-- --------------------------------------------------------------------------------
-- Moncai Compare
-- Copyright (C) 2009-2016 Moncai
-- Module for Loot Journal
-- --------------------------------------------------------------------------------

function LootJournalHook()
	fLootJournalItemButton_OnUpdate = LootJournalItemButton_OnUpdate
	LootJournalItemButton_OnUpdate = function(self, elapsed)
		if GameTooltip:IsOwned(self) then
			if (not IsModifiedClick("COMPAREITEMS")) and not IsEquippedItem(self.itemID) then
				GameTooltip_ShowCompareItem();
			else
				ShoppingTooltip1:Hide();
				ShoppingTooltip2:Hide();
			end

			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end	
	end
end
hooksecurefunc("EncounterJournal_LoadUI", LootJournalHook)
