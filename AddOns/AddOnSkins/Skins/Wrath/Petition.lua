local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs

function S:PetitionFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.petition) then return end

	local PetitionFrame = _G.PetitionFrame
	S:HandleFrame(PetitionFrame, true, nil, 12, -17, -28, 65)

	-- Buttons
	local buttons = {
		_G.PetitionFrameSignButton,
		_G.PetitionFrameRequestButton,
		_G.PetitionFrameRenameButton,
		_G.PetitionFrameCancelButton
	}

	for _, button in ipairs(buttons) do
		S:HandleButton(button)
	end

	S:HandleCloseButton(_G.PetitionFrameCloseButton)

	-- Text Colors
	_G.PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	_G.PetitionFrameCharterName:SetTextColor(1, 1, 1)
	_G.PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	_G.PetitionFrameMasterName:SetTextColor(1, 1, 1)
	_G.PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

	for i = 1, 9 do
		_G['PetitionFrameMemberName'..i]:SetTextColor(1, 1, 1)
	end

	_G.PetitionFrameInstructions:SetTextColor(1, 1, 1)

	_G.PetitionFrameRenameButton:Point('LEFT', _G.PetitionFrameRequestButton, 'RIGHT', 3, 0)
	_G.PetitionFrameRenameButton:Point('RIGHT', _G.PetitionFrameCancelButton, 'LEFT', -3, 0)
end

S:AddCallback('PetitionFrame')
