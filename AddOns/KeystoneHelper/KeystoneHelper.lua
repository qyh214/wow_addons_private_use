-- |cffa335ee|Hkeystone:207:5:1:6:0:0|h[Keystone: Vault of the Wardens]|h|r
-- |cffa335ee|Hitem:138019::::::::110:252:5111808:::207:5:6:1:::|h[Mythic Keystone]|h|r
-- |cffa335ee|Hkeystone:209:7:1:6:3:0|h[Keystone: The Arcway]|h|r
-- |cffa335ee|Hitem:138019::::::::110:577:6160384:::209:7:6:3:1:::|h[Mythic Keystone]|h|r
-- |Hkeystone:197:12:1:8:3:10|h[Keystone:Eye of Azshara]|h

-- |cffa335ee|Hkeystone:138019:227:13:5:3:9:0|h[Keystone: Return to Karazhan: Lower (13)]|h|r

function GetModifiers(linkType, ...)
	if type(linkType) ~= 'string' then return end
	local modifierOffset = 4
	local itemID, instanceID, mythicLevel, notDepleted, _ = ... -- "keystone" links
	if linkType:find('item') then -- only used for ItemRefTooltip currently
		_, _, _, _, _, _, _, _, _, _, _, _, _, instanceID, mythicLevel = ...
		if ... == '138019' then -- mythic keystone
			modifierOffset = 16
		else
			return
		end
	elseif not linkType:find('keystone') then
		return
	end

	local modifiers = {}
	for i = modifierOffset, select('#', ...) do
		local num = strmatch(select(i, ...) or '', '^(%d+)')
		if num then
			local modifierID = tonumber(num)
			--if not modifierID then break end
			tinsert(modifiers, modifierID)
		end
	end
	local numModifiers = #modifiers
	if modifiers[numModifiers] and modifiers[numModifiers] < 2 then
		tremove(modifiers, numModifiers)
	end
	return modifiers, instanceID, mythicLevel
end

local function DecorateTooltip(self, link, _)
	if not link then
		_, link = self:GetItem()
	end
	if type(link) == 'string' then
		local modifiers, instanceID, mythicLevel = GetModifiers(strsplit(':', link))
		if modifiers then
			for _, modifierID in ipairs(modifiers) do
				local modifierName, modifierDescription = C_ChallengeMode.GetAffixInfo(modifierID)
				if modifierName and
					modifierDescription then
					self:AddLine(format('|cff00ff00%s|r - %s', modifierName, modifierDescription), 0, 1, 0, true)
				end
			end
			self:Show()
		end
	end
end

-- hack to handle ItemRefTooltip:GetItem() not returning a proper keystone link
hooksecurefunc(ItemRefTooltip, 'SetHyperlink', DecorateTooltip) 
--ItemRefTooltip:HookScript('OnTooltipSetItem', DecorateTooltip)
GameTooltip:HookScript('OnTooltipSetItem', DecorateTooltip)
