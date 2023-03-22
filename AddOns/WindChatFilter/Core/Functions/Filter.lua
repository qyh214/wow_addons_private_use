local W, F, L = unpack(select(2, ...))

local pairs = pairs
local pcall = pcall
local time = time

local GetPlayerInfoByGUID = GetPlayerInfoByGUID

function F.CleanupPlayerInfoCache(onlyExpired)
    local now = time()
    for guid, playerInfo in pairs(W.global.playerInfoCache) do
        if not onlyExpired or now - playerInfo.updateTime > W.global.advanced.playerInfoCacheExpiration then
            W.global.playerInfoCache[guid] = nil
        end
    end
end

function F.ForceUpdatePlayerInfo(guid)
    local result

    local ok, _, englishClass, _, englishRace, _, name, realm = pcall(GetPlayerInfoByGUID, guid)
    if ok and englishClass and englishRace and name then
        result = {
            class = englishClass,
            race = englishRace,
            name = name,
            realm = realm,
            updateTime = time()
        }
    end

    if not W.global.advanced.doNotUseGUIDCache then
        W.global.playerInfoCache[guid] = result
    end

    return result
end

function F.FetchPlayerInfo(guid)
    if not guid then
        return
    end

    local playerInfo = W.global.playerInfoCache[guid]

    if W.global.advanced.doNotUseGUIDCache or not playerInfo then
        playerInfo = F.ForceUpdatePlayerInfo(guid)
    else
        local playerInfo = W.global.playerInfoCache[guid]
        if time() - playerInfo.updateTime > W.global.advanced.playerInfoCacheExpiration then
            playerInfo = F.ForceUpdatePlayerInfo(guid)
        end
    end

    return playerInfo
end
