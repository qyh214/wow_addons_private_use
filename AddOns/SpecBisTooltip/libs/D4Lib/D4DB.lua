local _, D4 = ...
local TAB = nil
function D4:SetDbTab(newTab)
    TAB = newTab
end

function D4:GV(db, key, value)
    if db == nil then
        D4:MSG("[D4:GV] db is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return value
    end

    if type(db) ~= "table" then
        D4:MSG("[D4:GV] db is not table", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return value
    end

    if db[key] ~= nil then return db[key] end

    return value
end

function D4:SV(db, key, value)
    if db == nil then
        D4:MSG("[D4:SV] db is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return false
    end

    if key == nil then
        D4:MSG("[D4:SV] key is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return false
    end

    db[key] = value
end

function D4:DBGV(key, value)
    if TAB == nil then
        D4:INFO("[D4:DBGV] Missing DB TAB in DBGV")

        return value
    end

    if TAB[key] == nil then
        TAB[key] = value
    end

    return TAB[key]
end

function D4:DBSV(key, value)
    if TAB == nil then
        D4:INFO("[D4:DBSV] Missing DB TAB in DBSV")

        return false
    end

    TAB[key] = value

    return true
end
