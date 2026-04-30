local AddonName, KeystoneLoot = ...;

KeystoneLoot.Character = {};

local Character = KeystoneLoot.Character;
local DB = KeystoneLoot.DB;

function Character:GetKey()
    local name = UnitName("player");
    local realm = GetRealmName();
    local classId = self:GetCurrentClassId();

    return string.format("%s-%s-%d", realm, name, classId);
end

function Character:GetSelectedKey()
    return DB:Get("ui.selectedCharacterKey") or self:GetKey();
end

function Character:ParseKey(characterKey)
    local realm, name, classId = characterKey:match("^(.-)%-(.-)%-(%d+)$");

    if (realm and name and classId) then
        return {
            realm = realm,
            name = name,
            classId = tonumber(classId)
        };
    end
end

function Character:GetCurrentClassId()
    local _, _, classId = UnitClass("player");
    return classId;
end

function Character:GetCurrentSpecId()
    return GetSpecializationInfo(GetSpecialization() or 1) or 0;
end

function Character:GetClassName(classId)
    classId = classId or self:GetCurrentClassId();
    local classInfo = C_CreatureInfo.GetClassInfo(classId);

    return classInfo and classInfo.className or "";
end

function Character:GetClassFile(classId)
    classId = classId or self:GetCurrentClassId();
    local classInfo = C_CreatureInfo.GetClassInfo(classId);

    return classInfo and classInfo.classFile or "";
end

function Character:GetSpecName(specId)
    specId = specId or self:GetCurrentSpecId();
    local _, name = GetSpecializationInfoByID(specId);

    return name or "";
end

function Character:GetAllSpecs(classId)
    classId = classId or self:GetCurrentClassId();

    local specs = {};

    for i = 1, GetNumSpecializationsForClassID(classId) do
        local specId, name, _, icon = GetSpecializationInfoForClassID(classId, i);
        table.insert(specs, {
            specId = specId,
            name = name,
            icon = icon
        });
    end

    return specs;
end

function Character:IsHidden(characterKey)
    return DB:Get("settings.hiddenCharacters")[characterKey] == true;
end

function Character:SetHidden(characterKey, hidden)
    local hiddenChars = DB:Get("settings.hiddenCharacters");
    hiddenChars[characterKey] = hidden and true or nil;
    DB:Set("settings.hiddenCharacters", hiddenChars);
end

function Character:GetAllCharacters(includeHidden)
    local characters = {};
    local favorites = DB:Get("favorites") or {};
    local currentKey = self:GetKey();

    for characterKey in pairs(favorites) do
        local isHidden = self:IsHidden(characterKey);

        if (includeHidden or not isHidden or characterKey == currentKey) then
            local info = self:ParseKey(characterKey);
            if (info) then
                table.insert(characters, {
                    key = characterKey,
                    name = info.name,
                    realm = info.realm,
                    classId = info.classId,
                    className = self:GetClassName(info.classId),
                    classFile = self:GetClassFile(info.classId),
                    isHidden = isHidden
                });
            end
        end
    end

    -- Sort: By class, then by name
    table.sort(characters, function(a, b)
        if (a.classId == b.classId) then
            return a.name < b.name;
        end

        return a.classId < b.classId;
    end);

    return characters;
end

function Character:Delete(characterKey)
    if (not characterKey) then
        return false;
    end

    -- Don't allow deleting current character
    if (characterKey == self:GetKey()) then
        return false;
    end

    local favorites = DB:Get("favorites");

    if (favorites and favorites[characterKey]) then
        favorites[characterKey] = nil;

        -- Save to DB
        DB:Set("favorites", favorites);

        return true;
    end

    return false;
end
