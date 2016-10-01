-- --------------------------------------------------------------------------------
-- Moncai Compare
-- Copyright (C) 2009-2016 Moncai
-- Main module
-- --------------------------------------------------------------------------------

-- local addonName, addonTable = ...; 

local ItemRefTooltip = ItemRefTooltip

ItemRefTooltip.UpdateTooltip = function(self)
	if ( not self.comparing and not IsModifiedClick("COMPAREITEMS")) then
		GameTooltip_ShowCompareItem(self);
		self.comparing = true;
	elseif ( self.comparing and IsModifiedClick("COMPAREITEMS")) then
		for _, frame in pairs(self.shoppingTooltips) do
			frame:Hide();
		end
		
		self.needsReset = true;
		self.comparing = false;
	end
end

ItemRefTooltip:SetScript("OnTooltipSetItem", function(self)
	if (not IsModifiedClick("COMPAREITEMS") and self:IsMouseOver()) then
		GameTooltip_ShowCompareItem(self);
		self.comparing = true;
	end
end 
)

ItemRefTooltip:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
	if (not IsModifiedClick("COMPAREITEMS") ) then --We do this to choose where the comparison is shown
		GameTooltip_ShowCompareItem(self);
		self.comparing = true;
	end
end
)

GameTooltip:SetScript("OnTooltipSetItem", function(self)
	if ( not IsModifiedClick("COMPAREITEMS") and not self:IsEquippedItem() ) then
		GameTooltip_ShowCompareItem(self);
	else
		local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
		shoppingTooltip1:Hide();
		shoppingTooltip2:Hide();
	end
	if (BattlePetTooltip) then
		BattlePetTooltip:Hide();
	end
	
--~ 	print("tipset")
end
)
