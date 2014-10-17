-- --------------------------------------------------------------------------------
-- Moncai Compare
-- Copyright (C) 2009-2013 Moncai
-- Module for Encounter (Dungeon) Journal
-- --------------------------------------------------------------------------------

local fEncounterJournal_Loot_OnUpdate;

local function JournalHook()
	
	fEncounterJournal_Loot_OnUpdate = EncounterJournal_Loot_OnUpdate;
	EncounterJournal_Loot_OnUpdate = function(self, elapsed)
		if GameTooltip:IsOwned(self) then
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
				ShoppingTooltip3:Hide();
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
			eb:SetScript("OnEnter", function(self) --EncounterItemTemplate Blizzard_EncounterJournal.xml:1094
--~ 				print("enter button "..i); 
				-- Show tooltips left always
				GameTooltip.overrideside = "left"
				
				GameTooltip:SetOwner(self, "ANCHOR_LEFT");
				GameTooltip:SetHyperlink(self.link);
				self.showingTooltip = true;
				self:SetScript("OnUpdate", EncounterJournal_Loot_OnUpdate);
			end)
			eb:HookScript("OnLeave", function(self) GameTooltip.overrideside = "" end)		
		end
	end
end

--local fGameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
function Journal_GameTooltip_ShowCompareItem(self, shift)
	if ( not self ) then
		self = GameTooltip;
	end
	local item, link = self:GetItem();
	if ( not link ) then
		return;
	end
	
	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(self.shoppingTooltips);

	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local side = "left";
	if ( shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self) ) then
		item1 = true;
	end
	if ( shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self) ) then
		item2 = true;
	end
	if ( shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self) ) then
		item3 = true;
	end

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

	if self.overrideside then 
--~ 		print("force side " .. self.overrideside)
		side = self.overrideside
--~ 	else
--~ 		print("standard side")
	end
	
	-- see if we should slide the tooltip
	if ( self:GetAnchorType() and self:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
		local totalWidth = 0;
		if ( item1  ) then
			shoppingTooltip1:Show() -- need to show to get correct width...
			totalWidth = totalWidth + shoppingTooltip1:GetWidth();
--~ 			print("tip 1 width " .. shoppingTooltip1:GetWidth())
		end
		if ( item2  ) then
			shoppingTooltip2:Show()
			totalWidth = totalWidth + shoppingTooltip2:GetWidth();
--~ 			print("tip 2 width " .. shoppingTooltip2:GetWidth())
		end
		if ( item3  ) then
			shoppingTooltip3:Show()
			totalWidth = totalWidth + shoppingTooltip3:GetWidth();
--~ 			print("tip 3 width " .. shoppingTooltip3:GetWidth())
		end

		if ( (side == "left") and (totalWidth > leftPos) ) then
			self:SetAnchorType(self:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	-- anchor the compare tooltips
	if ( item3 ) then
		shoppingTooltip3:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip3:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip3:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
		else
			shoppingTooltip3:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self);
		shoppingTooltip3:Show();
	end
	
	if ( item1 ) then
		if( item3 ) then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE");
		else
			shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		end
		shoppingTooltip1:ClearAllPoints();
		if ( side and side == "left" ) then
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPRIGHT", shoppingTooltip3, "TOPLEFT", 0, 0);
			else
				shoppingTooltip1:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
			end
		else
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 0, 0);
			else
				shoppingTooltip1:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self);
		shoppingTooltip1:Show();

		if ( item2 ) then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE");
			shoppingTooltip2:ClearAllPoints();
			if ( side and side == "left" ) then
				shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", 0, 0);
			else
				shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 0, 0);
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self);
			shoppingTooltip2:Show();
		end
	end
end

hooksecurefunc("EncounterJournal_LoadUI", JournalHook)
--~ GameTooltip:HookScript("OnHide", function(self) print( (self and self:GetName() or "?") .. " hide") end)
