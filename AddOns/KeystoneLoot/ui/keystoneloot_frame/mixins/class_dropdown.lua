local AddonName, KeystoneLoot = ...;

local DB = KeystoneLoot.DB;

KeystoneLootClassDropdownMixin = {};

function KeystoneLootClassDropdownMixin:Init()
    self:SetSelectionText(function(selections)
        if (#selections == 0) then
            return CLASS;
        end

        local data = selections[1].data;
        if (not data or not data.classId) then
            return CLASS;
        end

        local classInfo = C_CreatureInfo.GetClassInfo(data.classId);
        local classColor = C_ClassColor.GetClassColor(classInfo.classFile);
        local className = classColor:WrapTextInColorCode(classInfo.className);

        local specId = data.specId;
        if (specId == 0) then
            return className;
        end

        local _, specName = GetSpecializationInfoForSpecID(specId);
        return string.format(RECENT_ALLY_RAID_NAME_STRING_FORMAT, className, specName);
    end);

    self:SetupMenu(function(dropdown, rootDescription)
        rootDescription:SetTag("MENU_KEYSTONELOOT_CLASS_DROPDOWN");

        local function IsSelected(data)
            return DB:Get("filters.classId") == data.classId and DB:Get("filters.specId") == data.specId;
        end

        local function SetSelected(data)
            DB:Set("filters.classId", data.classId);
            DB:Set("filters.specId", data.specId);
        end

        for classId = 1, GetNumClasses() do
            local classInfo = C_CreatureInfo.GetClassInfo(classId);
            local classColor = C_ClassColor.GetClassColor(classInfo.classFile);

            local classMenu = rootDescription:CreateButton(classColor:WrapTextInColorCode(classInfo.className));
            classMenu:CreateRadio(ALL_SPECS, IsSelected, SetSelected, { classId = classId, specId = 0 });

            for index = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classId) do
                local specId, specName = GetSpecializationInfoForClassID(classId, index);
                classMenu:CreateRadio(specName, IsSelected, SetSelected, { classId = classId, specId = specId });
            end
        end
    end);

    DB:AddObserver("filters.specId", function() self:GenerateMenu(); end);
end
