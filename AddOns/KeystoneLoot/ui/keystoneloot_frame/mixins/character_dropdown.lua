local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;
local Character = KeystoneLoot.Character;
local L = KeystoneLoot.L;

KeystoneLootCharacterDropdownMixin = {};

function KeystoneLootCharacterDropdownMixin:Init()
    self:Refresh();

    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_CHARACTER_DROPDOWN");

        local extent = 20;
        local maxCharacters = 18;
        local maxScrollExtent = extent * maxCharacters;
        rootDescription:SetScrollMode(maxScrollExtent);

        local function IsSelected(data)
            return data.key == Character:GetSelectedKey();
        end

        local function SetSelected(data)
            DB:Set("ui.selectedCharacterKey", data.key);

            local info = Character:ParseKey(data.key);
            if (info) then
                DB:Set("filters.classId", info.classId);
                DB:Set("filters.specId", 0);
            end
        end

        for _, data in ipairs(Character:GetAllCharacters()) do
            local name = data.name;

            if (not data.isHidden) then
                local classColor = C_ClassColor.GetClassColor(data.classFile);
                name = classColor:WrapTextInColorCode(data.name);
            end

            local label = string.format(LFG_LIST_TOOLTIP_CLASS_ROLE, name, data.realm);

            if (data.isHidden) then
                label = DISABLED_FONT_COLOR:WrapTextInColorCode(label);
            end

            local radio = rootDescription:CreateRadio(label, IsSelected, SetSelected, data);

            if (data.isHidden) then
                radio:SetTooltip(function(tooltip, elementDescription)
                    tooltip:SetText(L["This character is hidden."]);
                end);
            end
        end
    end);

    DB:AddObserver("ui.selectedCharacterKey", function() self:Refresh(); end);
end

function KeystoneLootCharacterDropdownMixin:OnMouseDown()
    self:GetNormalTexture():AdjustPointsOffset(1, -1);
    self:GetHighlightTexture():AdjustPointsOffset(1, -1);
    self.Indicator:AdjustPointsOffset(1, -1);
end

function KeystoneLootCharacterDropdownMixin:OnMouseUp()
    self:GetNormalTexture():AdjustPointsOffset(-1, 1);
    self:GetHighlightTexture():AdjustPointsOffset(-1, 1);
    self.Indicator:AdjustPointsOffset(-1, 1);
end

function KeystoneLootCharacterDropdownMixin:Refresh()
    local info = Character:ParseKey(Character:GetSelectedKey());
    if (not info) then
        return;
    end

    local classInfo = C_CreatureInfo.GetClassInfo(info.classId);
    local classColor = C_ClassColor.GetClassColor(classInfo.classFile);
    self.Indicator:SetVertexColor(classColor.r, classColor.g, classColor.b);
end
