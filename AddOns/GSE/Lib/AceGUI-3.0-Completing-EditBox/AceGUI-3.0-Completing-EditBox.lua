--[[
Inspired by seeing AceGUI-3.0-Spell-EditBox in action.

Usage:
	lib:Register('typename', autocomplete_params_table)
	lib:Register('typename', autocomplete_include_flags, autocomplete_exclude_flags)
	TYPENAME is a tag to append to EditBox
	Either pass a pair of INCLUDE and EXCLUDE numbers (bitwise-OR'd flags), or
	a single table containing .include and .exclude fields pointing to such.

Examples:
	local AceGUI = LibStub("AceGUI-3.0")
	local Completing = LibStub("AceGUI-3.0-Completing-EditBox")

	-- For premade lists and list templates, see FrameXML/AutoComplete.lua
	-- For all flags, see FrameXML/AutoComplete.lua or http://www.wowpedia.org/API_GetAutoCompleteResults
	Completing:Register ("ExampleGroupMembers",       AUTOCOMPLETE_LIST_TEMPLATES.IN_GROUP)
	Completing:Register ("ExampleMailbox",            AUTOCOMPLETE_LIST.MAIL)
	Completing:Register ("ExampleOnlyOfflineFriends", AUTOCOMPLETE_FLAG_FRIEND, _G.bit.bor(AUTOCOMPLETE_FLAG_ONLINE,AUTOCOMPLETE_FLAG_BNET))
	....
	local editbox1 = AceGUI:Create("EditBoxExampleGroupMemebers")
	local editbox2 = AceGUI:Create("EditBoxExampleMailbox")
	local editbox3 = AceGUI:Create("EditBoxExampleOnlyOfflineFriends")
	....
	option = {
		name = "Example",
		type = 'input',
		dialogControl = "EditBoxExampleWhatever",
		get = function() return "type stuff here" end,
		set = function (info, value)
			print("Ooooh shiny, you might have typed", value, "with the help of autocompletion!")
		end,
	}

Technically you could also :Create("EditBox") and then adjust the scripts and
the self.editbox.autoCompleteParams field, but that wouldn't allow use in an
aceconfig options table.

blame this one on farmbuyer@gmail.com
]]
local MAJOR, MINOR = "AceGUI-3.0-Completing-EditBox", 1  -- possibly change minor to be revision
local lib, oldminor = LibStub:NewLibrary(MAJOR,MINOR)
if not lib then return end

local AceGUI = LibStub("AceGUI-3.0")


local function CompletingEditBox_OnEscapePressed (editbox)
	if not AutoCompleteEditBox_OnEscapePressed(editbox) then
		AceGUI:ClearFocus(editbox.obj)
	end
end

--[[
local function CompletingEditBox_OnTabPressed (editbox)
	if not AutoCompleteEditBox_OnTabPressed(editbox) then
		-- use EditBox_HandleTabbing to hop cursor focus around to other editboxes...?
		-- not in a library, but could be done by lib client
	end
end
]]

local function CompletingEditBox_OnEditFocusLost (editbox)
	AutoComplete_HideIfAttachedTo(editbox)
	EditBox_ClearHighlight(editbox)
end

local normal_OnEnterPressed
local function CompletingEditBox_OnEnterPressed (editbox)
	AutoCompleteEditBox_OnEnterPressed(editbox)
	return normal_OnEnterPressed(editbox)
end

local normal_OnTextChanged
local function CompletingEditBox_OnTextChanged (editbox, changedByUser)
	AutoCompleteEditBox_OnTextChanged(editbox,changedByUser)
	return normal_OnTextChanged(editbox)
end

local function ctor (params)
	local e = AceGUI:Create("EditBox")

	-- really we only need to do this once, but not until then
	-- freshly-created widgets *should* have all the same scripts, so *should* be safe
	normal_OnEnterPressed = e.editbox:GetScript("OnEnterPressed")
	normal_OnTextChanged = e.editbox:GetScript("OnTextChanged")

	e.editbox:SetScript("OnTabPressed", AutoCompleteEditBox_OnTabPressed)
	e.editbox:SetScript("OnEnterPressed", CompletingEditBox_OnEnterPressed)
	e.editbox:SetScript("OnTextChanged", CompletingEditBox_OnTextChanged)
	e.editbox:SetScript("OnChar", AutoCompleteEditBox_OnChar)
	e.editbox:SetScript("OnEditFocusLost", CompletingEditBox_OnEditFocusLost)
	e.editbox:SetScript("OnEscapePressed", CompletingEditBox_OnEscapePressed)

	e.editbox.addHighlightedText = true
	e.editbox.autoCompleteParams = params

	return e   -- RegisterAsWidget already done, no need to redo
end


function lib:Register (typename, params_taborin, params_nilorex)
	local params
	if type(params_taborin) == 'table' and type(params_nilorex) == 'nil' then
		assert(type(params_taborin.include) == 'number', "autocomplete table must have numerical '.include' field")
		assert(type(params_taborin.exclude) == 'number', "autocomplete table must have numerical '.exclude' field")
		params = params_taborin
	elseif type(params_taborin) == 'number' and type(params_nilorex) == 'number' then
		params = { include = params_taborin, exclude = params_nilorex }
	end
	assert(params, "usage:  Register('typename', autocomplete_params_table_or_include [,exclude])")

	-- Would have been nice to do a typename->params lookup instead of a closure,
	-- but AceGUI:Create does not pass anything to the constructors (such as the type).
	AceGUI:RegisterWidgetType ("EditBox"..typename, function() return ctor(params) end, MINOR)
end

-- vim: noet
