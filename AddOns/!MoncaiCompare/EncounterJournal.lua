-- --------------------------------------------------------------------------------
-- Moncai Compare
-- Copyright (C) 2009-2017 Moncai
-- Module for Encounter (Dungeon) Journal
-- --------------------------------------------------------------------------------

local fEncounterJournal_Loot_OnUpdate;

local function JournalHook()
--~ 	print("Journalhook");
	
	fEncounterJournal_Loot_OnUpdate = EncounterJournal_Loot_OnUpdate;
	EncounterJournal_Loot_OnUpdate = function(self, elapsed)
		if GameTooltip:IsOwned(self) then
--~ 			print("LootOnUpdate");
			-- Show tooltips left always
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
		
			if (not IsModifiedClick("COMPAREITEMS")) and not IsEquippedItem(self.itemID) then
--~ 				if (not self.comparing) then
					Journal_GameTooltip_ShowCompareItem();
--~ 					self.comparing = true
--~ 				end
			else
--~ 				self.comparing = nil
				ShoppingTooltip1:Hide();
				ShoppingTooltip2:Hide();
				--ShoppingTooltip3:Hide(); --602 removed?
			end

			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end	
	end;	
	
	for i = 1, 8, 1 do
		local eb = _G["EncounterJournalEncounterFrameInfoLootScrollFrameButton"..i]
		if eb then
			eb:SetScript("OnEnter", function(self) --EncounterItemTemplate Blizzard_EncounterJournal.xml: old: 1094 -> 6.0.2: 1136
--~ 				print("enter button "..i); --MOD
				-- Show tooltips left always
				GameTooltip.overrideside = "left" --EMOD

				GameTooltip:SetOwner(self, "ANCHOR_LEFT");
				EncounterJournal_SetTooltip(self.link);
				self.showingTooltip = true;
				
--~ 				if self.itemID then
--~ 					GameTooltip:SetOwner(self, "ANCHOR_LEFT");
--~ 					GameTooltip:SetItemByID(self.itemID);
--~ 					self.showingTooltip = true;
--~ 				end

				self:SetScript("OnUpdate", EncounterJournal_Loot_OnUpdate); -- MOD 602 still needed
			end)
			eb:HookScript("OnLeave", function(self) GameTooltip.overrideside = "" end)		
		end
	end
end

--local fGameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
function Journal_GameTooltip_ShowCompareItem(self, shift)
--~ 	print("Journal Compare");
	
	if ( not self ) then
		self = GameTooltip;
	end
	
	if ( self.needsReset ) then
		self:ResetSecondaryCompareItem();
		GameTooltip_AdvanceSecondaryCompareItem(self);
		self.needsReset = false;
	end
	
	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);

	local primaryItemShown, secondaryItemShown = shoppingTooltip1:SetCompareItem(shoppingTooltip2, self);

	local side = "left";
	
	-- find correct side
	local rightDist = 0;
	local leftPos = self:GetLeft();
	local rightPos = self:GetRight();
	if ( not rightPos ) then
		rightPos = 0;
	end
	if ( not leftPos ) then
		leftPos = 0;
	end

	rightDist = GetScreenWidth() - rightPos;

	if (leftPos and (rightDist < leftPos)) then
		side = "left";
	else
		side = "right";
	end

	if self.overrideside then --MOD
--~ 		print("force side " .. self.overrideside)
		side = self.overrideside
--~ 	else
--~ 		print("standard side")
	end --EMOD
	
	-- see if we should slide the tooltip
	if ( self:GetAnchorType() and self:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
		local totalWidth = 0;
		if ( primaryItemShown  ) then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth();
		end
		if ( secondaryItemShown  ) then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth();
		end

		if ( (side == "left") and (totalWidth > leftPos) ) then
			self:SetAnchorType(self:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end
	
	if ( secondaryItemShown ) then
		shoppingTooltip2:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip2:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip2:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
		else
			shoppingTooltip2:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
		end
		
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();
		
		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("TOPRIGHT", shoppingTooltip2, "TOPLEFT");
		else
			shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip2, "TOPRIGHT");
		end
	else
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();
		
		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
		else
			shoppingTooltip1:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
		end

		shoppingTooltip2:Hide();
	end
	
	-- We have to call this again because :SetOwner clears the tooltip.
	shoppingTooltip1:SetCompareItem(shoppingTooltip2, self);
	shoppingTooltip1:Show();
end

hooksecurefunc("EncounterJournal_LoadUI", JournalHook)
--~ GameTooltip:HookScript("OnHide", function(self) print( (self and self:GetName() or "?") .. " hide") end)
