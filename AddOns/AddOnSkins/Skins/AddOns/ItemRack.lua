local AS, L, S, R = unpack(AddOnSkins)

function R:ItemRack()
	local function SkinButton(idx,itemID)
		if _G["ItemRackMenu"..idx] then
			S:HandleItemButton(_G["ItemRackMenu"..idx])
		end
	end
	local function SkinButton2()
		for i=0,20 do
			if _G["ItemRackButton"..i] then
				S:HandleItemButton(_G["ItemRackButton"..i])
			end
		end
	end

	hooksecurefunc(ItemRack, 'CreateMenuButton', SkinButton)
	hooksecurefunc(ItemRack, 'InitButtons', SkinButton2)
	SkinButton(1)
	SkinButton2()
end

AS:RegisterSkin('ItemRack')
