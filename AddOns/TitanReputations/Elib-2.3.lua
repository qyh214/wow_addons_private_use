--[[
	Description: Titan Panel Lib. Be careful editing it, all plugins can stop working.
	Author: Eliote
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

local function defaultMenu(self, id, menus)
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[id].menuText)
	TitanPanelRightClickMenu_AddToggleIcon(id)
	TitanPanelRightClickMenu_AddToggleLabelText(id)

	if menus then
		for k, v in ipairs(menus) do
			if v.type == "toggle" then
				local info = UIDropDownMenu_CreateInfo();
				info.text = v.text;
				info.func = v.func or function() TitanToggleVar(id, v.var); TitanPanelButton_UpdateButton(id); end
				info.checked = TitanGetVar(id, v.var);
				info.keepShownOnClick = v.keepShown
				UIDropDownMenu_AddButton(info);
			elseif v.type == "rightSideToggle" then
				local info = UIDropDownMenu_CreateInfo();
				info.text = ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"];
				info.func = function() TitanToggleVar(id, "DisplayOnRightSide"); TitanPanel_InitPanelButtons(); end
				info.checked = TitanGetVar(id, "DisplayOnRightSide");
				UIDropDownMenu_AddButton(info);
			elseif v.type == "space" then
				TitanPanelRightClickMenu_AddSpacer()
			elseif v.type == "button" then
				local info = UIDropDownMenu_CreateInfo();
				info.text = v.text;
				info.func = v.func;
				info.notCheckable = true;
				info.arg1 = v.arg1;
				info.arg2 = v.arg2;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	TitanPanelRightClickMenu_AddSpacer()
	TitanPanelRightClickMenu_AddCommand(ACE["TITAN_PANEL_MENU_HIDE"], id, TITAN_PANEL_MENU_FUNC_HIDE);
end

local function setDefaultSavedVariables(sv, menus)
	sv.ShowIcon = sv.ShowIcon or 1
	sv.ShowLabelText = sv.ShowLabelText or false

	if menus then
		for k, v in ipairs(menus) do
			if v.var then sv[v.var] = v.def or false
			elseif v.type == "rightSideToggle" then sv.DisplayOnRightSide = v.def or false
			end
		end
	end
end

-- Using the private table to register the lib
function L.Elib(easyObject)
	local elap = 0

	-- Main button frame and addon base
	local frame = CreateFrame("Button", "TitanPanel" .. easyObject.id .. "Button", CreateFrame("Frame", nil, UIParent), "TitanPanelComboTemplate")
	frame:SetFrameStrata("FULLSCREEN")
	frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnClick", function(self, button, ...)
		if easyObject.onClick then easyObject.onClick(self, button, ...) end
		TitanPanelButton_OnClick(self, button)
	end)

	if easyObject.eventsTable then
		for event, func in pairs(easyObject.eventsTable) do
			frame[event] = func
			frame:RegisterEvent(event)
		end
	end

	function frame:ADDON_LOADED(a1)
		if a1 ~= ADDON_NAME then
			return
		end

		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil

		if easyObject.onLoad then easyObject.onLoad(self, easyObject.id) end

		local sv = easyObject.savedVariables or {}
		if not easyObject.prepareMenu then
			setDefaultSavedVariables(sv, easyObject.menus)
		end

		self.registry = {
			id = easyObject.id,
			menuText = easyObject.name .. "|r",
			buttonTextFunction = easyObject.getButtonText and "TitanPanelButton_Get" .. easyObject.id .. "ButtonText",
			tooltipTitle = easyObject.tooltip,
			tooltipTextFunction = easyObject.getTooltipText and "TitanPanelButton_Get" .. easyObject.id .. "TooltipText",
			frequency = (easyObject.onUpdate and easyObject.frequency) or 1,
			icon = easyObject.icon,
			iconWidth = 16,
			category = easyObject.category,
			version = easyObject.version,
			tooltipCustomFunction = easyObject.customTooltip,
			savedVariables = sv
		}

		if easyObject.onUpdate then
			self:SetScript("OnUpdate", function(this, a1)
				elap = elap + a1
				if elap < 1 then return end

				if easyObject.onUpdate(self, easyObject.id) then elap = 0 end
			end)
		end
	end

	_G["TitanPanelRightClickMenu_Prepare" .. easyObject.id .. "Menu"] = function(...)
		if easyObject.prepareMenu then return easyObject.prepareMenu(frame, easyObject.id, ...) end

		return defaultMenu(frame, easyObject.id, easyObject.menus)
	end

	if easyObject.getButtonText then
		_G["TitanPanelButton_Get" .. easyObject.id .. "ButtonText"] = function(...)
			return easyObject.getButtonText(frame, easyObject.id, ...)
		end
	end

	if easyObject.getTooltipText then
		_G["TitanPanelButton_Get" .. easyObject.id .. "TooltipText"] = function(...)
			return easyObject.getTooltipText(frame, easyObject.id, ...)
		end
	end

	return frame
end
