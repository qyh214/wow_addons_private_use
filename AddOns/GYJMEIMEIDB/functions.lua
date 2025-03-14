GYJMEIMEIAPI = {}

function GYJMEIMEIAPI:GetCastInfo(unit)
    local name, startC, endC, icon, notInterruptible, spellID, duration, expirationTime, _, castType
    if UnitCastingInfo(unit) then
        name, _, icon, startC, endC, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
        castType = "cast"
    elseif UnitChannelInfo(unit) then
        name, _, icon, startC, endC, _, notInterruptible, spellID = UnitChannelInfo(unit)
        castType = "channel"
    end
    if startC and endC then
        duration = (endC - startC) / 1000
        expirationTime = endC / 1000
    end
    return name, duration, expirationTime, icon, notInterruptible, spellID, castType
end