local AS, L, S, R = unpack(AddOnSkins)

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleCheckBox(checkbox)
	checkbox:CreateBackdrop()
	checkbox.backdrop:SetInside(nil, 4, 4)

	for _, region in next, { checkbox:GetRegions() } do
		if region:IsObjectType('Texture') then
			if region:GetTexture() == 130751 then
				region:SetTexture(S.Media.StatusBar)

				local checkedTexture = checkbox:GetCheckedTexture()
				checkedTexture:SetVertexColor(1, .82, 0, 0.8)
				S:SetInside(checkedTexture, checkbox.backdrop)
			else
				region:SetTexture('')
			end
		end
	end
end

local function HandleDialogs()
	local dialog = _G.EditModeSystemSettingsDialog
	for _, button in next, { dialog.Buttons:GetChildren() } do
		if button.Controller and not button.isSkinned then
			S:HandleButton(button)
		end
	end

	for _, frame in next, { dialog.Settings:GetChildren() } do
		local dd = frame.Dropdown
		if dd and (dd.DropDownMenu and not dd.isSkinned) then
			S:HandleDropDownBox(dd.DropDownMenu, 250)
			dd.isSkinned = true
		end

		local checkbox = frame.Button
		if checkbox and not checkbox.backdrop then
			HandleCheckBox(checkbox)
		end
	end
end

function R:Blizzard_EditorManagerFrame()
	if not AS:IsSkinEnabled('Blizzard_EditorManagerFrame', 'editor') then return end

	-- Main Window
	local editMode = _G.EditModeManagerFrame
	S:HandleFrame(editMode, true)
	editMode.Tutorial:Kill()

	S:HandleButton(editMode.RevertAllChangesButton)
	S:HandleButton(editMode.SaveChangesButton)
	S:HandleDropDownBox(editMode.LayoutDropdown.DropDownMenu, 250)

	S:HandleCheckBox(editMode.ShowGridCheckButton.Button)
	S:HandleCheckBox(editMode.EnableSnapCheckButton.Button)

	for _, frame in next, { editMode.AccountSettings.Settings:GetChildren() } do
		if frame.Button then
			S:HandleCheckBox(frame.Button)
		end
	end

	-- Layout Creator
	local layout = _G.EditModeNewLayoutDialog
	S:HandleFrame(layout)
	S:HandleButton(layout.AcceptButton)
	S:HandleButton(layout.CancelButton)
	S:HandleEditBox(layout.LayoutNameEditBox)
	HandleCheckBox(layout.CharacterSpecificLayoutCheckButton.Button)

	-- Layout Unsaved
	local unsaved = _G.EditModeUnsavedChangesDialog
	S:HandleFrame(unsaved)
	S:HandleButton(unsaved.CancelButton)
	S:HandleButton(unsaved.ProceedButton)
	S:HandleButton(unsaved.SaveAndProceedButton)

	-- Layout Importer
	local import = _G.EditModeImportLayoutDialog
	S:HandleFrame(import)
	S:HandleButton(import.AcceptButton)
	S:HandleButton(import.CancelButton)
	HandleCheckBox(import.CharacterSpecificLayoutCheckButton.Button)

	local importBox = import.ImportBox
	S:HandleEditBox(importBox)

	local importBackdrop = importBox.backdrop
	importBackdrop:ClearAllPoints()
	S:Point(importBackdrop, 'TOPLEFT', importBox, -4, 4)
	S:Point(importBackdrop, 'BOTTOMRIGHT', importBox, 0, -4)

	local scrollbar = importBox.ScrollBar
	S:HandleScrollBar(scrollbar)
	scrollbar:ClearAllPoints()
	S:Point(scrollbar, 'TOPLEFT', importBox, 'TOPRIGHT', 4, 4)
	S:Point(scrollbar, 'BOTTOMLEFT', importBox, 'BOTTOMRIGHT', 0, -4)

	local editbox = import.LayoutNameEditBox
	S:HandleEditBox(editbox)

	local editbackdrop = editbox.backdrop
	editbackdrop:ClearAllPoints()
	S:Point(editbackdrop, 'TOPLEFT', editbox, -2, -4)
	S:Point(editbackdrop, 'BOTTOMRIGHT', editbox, 2, 4)

	-- Dialog (Mover Settings)
	local dialog = _G.EditModeSystemSettingsDialog
	S:HandleFrame(dialog)
	S:HandleCloseButton(dialog.CloseButton)

	hooksecurefunc(dialog.Buttons, 'AddLayoutChildren', HandleDialogs)
	HandleDialogs()
end

AS:RegisterSkin('Blizzard_EditorManagerFrame')
