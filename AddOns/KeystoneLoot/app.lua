local AddonName, KeystoneLoot = ...;

local Translate = KeystoneLoot.Translate;


function KeystoneLoot:GetSeasonId()
	return 15; -- 15 = TWW Season 3
end

local _slotList = { INVTYPE_HEAD, INVTYPE_NECK, INVTYPE_SHOULDER, INVTYPE_CLOAK, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND, INVTYPE_FINGER, INVTYPE_TRINKET, EJ_LOOT_SLOT_FILTER_OTHER }
function KeystoneLoot:GetSlotList()
	return _slotList;
end

function KeystoneLoot:ShowExportDialog()
	if (StaticPopupDialogs.KEYSTONELOOT_EXPORT_DIALOG == nil) then
		StaticPopupDialogs.KEYSTONELOOT_EXPORT_DIALOG = {
			text = Translate['The favorites are ready to share:'],
			button1 = OKAY,
			hasEditBox = 1,
			editBoxWidth = 350,
			OnAccept = function(self) end,
			OnShow = function(self)
				self.popupElapsed = 1;
				if (self.editBox == nil) then
					self.editBox = _G[self:GetName().."EditBox"];
				end
			end,
			OnHide = function(self)
				ChatEdit_FocusActiveWindow();
				self.popupElapsed = nil;
			end,
			OnUpdate = function(self, elapsed)
				if (self.popupElapsed >= 0.1) then
					self.editBox:SetText(self.data);
					self.editBox:HighlightText();
					self.popupElapsed = 0;
				end
			end,
			EditBoxOnEnterPressed = function(self)
				self:GetParent():Hide();
			end,
			EditBoxOnEscapePressed = function(self)
				self:GetParent():Hide();
			end,
			hideOnEscape = 1,
			timeout = 0,
			whileDead = 1,
		};
	end

	StaticPopup_Hide('KEYSTONELOOT_IMPORT_DIALOG');
	StaticPopup_Show('KEYSTONELOOT_EXPORT_DIALOG', nil, nil, self:ExportFavorites());
end

function KeystoneLoot:ShowImportDialog()
	if (StaticPopupDialogs.KEYSTONELOOT_IMPORT_DIALOG == nil) then
		StaticPopupDialogs.KEYSTONELOOT_IMPORT_DIALOG = {
			text = Translate['Paste an import string to import favorites:'],
			button1 = ADD,
			button2 = Translate['Overwrite'],
			button3 = CANCEL,
			hasEditBox = 1,
			editBoxWidth = 350,
			OnShow = function(self)
				if (self.editBox == nil) then
					self.editBox = _G[self:GetName().."EditBox"];
				end
			end,
			OnHide = function(self)
				ChatEdit_FocusActiveWindow();
			end,
			OnAccept = function(self)
				KeystoneLoot:ImportFavorites(self.editBox:GetText(), false);
			end,
			OnCancel = function(self)
				KeystoneLoot:ImportFavorites(self.editBox:GetText(), true);
			end,
			OnAlt = function(self) end,
			EditBoxOnEnterPressed = function(self)
				self:GetParent():Hide();
			end,
			EditBoxOnEscapePressed = function(self)
				self:GetParent():Hide();
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
	end

	StaticPopup_Hide('KEYSTONELOOT_EXPORT_DIALOG');
	StaticPopup_Show('KEYSTONELOOT_IMPORT_DIALOG');
end


SlashCmdList.KEYSTONELOOT = function(msg)
	local OverviewFrame = KeystoneLoot:GetOverview();
	OverviewFrame:SetShown(not OverviewFrame:IsShown());
end;

SLASH_KEYSTONELOOT1 = "/ksl";
SLASH_KEYSTONELOOT2 = "/keyloot";
SLASH_KEYSTONELOOT3 = "/keystoneloot";

SlashCmdList.KSLRELOAD = ReloadUI;
SLASH_KSLRELOAD1 = "/rl";
SLASH_KSLRELOAD2 = "/reload";
SLASH_KSLRELOAD3 = "/reloadui";


local function OnEvent(self, event, ...)
	self:UnregisterEvent(event);

	KeystoneLoot:CheckDB();
	KeystoneLoot:CheckCharacterDB();

	KeystoneLoot:UpdateMinimapButton();
	KeystoneLoot:UpdateUpgradeTooltip();
end

local handler = CreateFrame('Frame');
handler:RegisterEvent('PLAYER_ENTERING_WORLD');
handler:SetScript('OnEvent', OnEvent);
