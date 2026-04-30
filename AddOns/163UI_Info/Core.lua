local addonName, private = ...

local addon = {}
private.addon = addon

--[[GLOBAL]] NetEase163UI_Info = addon

local ns = select(2, ...)

function addon.StartPlayerInfoTimer()
    local function SendPlayerInfo()
        local playerName = UnitName("player")
        local realmName = GetRealmName()

        if not playerName or playerName == "" or playerName == "Unknown" then
            return
        end

        if not realmName or realmName == "" or realmName == "Unknown" then
            return
        end

        local className, classFileName = UnitClass("player")

        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
        local inChallenge = false
        local challengeMapID = nil
        local keystoneLevel = 0
        local affixes = {}

        if instanceType == "party" or instanceType == "raid" then
            if instanceType == "party" and C_ChallengeMode then
                if C_ChallengeMode.IsChallengeModeActive then
                    inChallenge = C_ChallengeMode.IsChallengeModeActive()
                end
                if inChallenge and C_ChallengeMode.GetActiveChallengeMapID then
                    challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
                end
                if inChallenge and C_ChallengeMode.GetActiveKeystoneInfo then
                    local cmLevel = C_ChallengeMode.GetActiveKeystoneInfo()
                    if cmLevel then
                        keystoneLevel = cmLevel
                    end
                end

                if inChallenge and C_ChallengeMode.GetActiveAffixIDs and C_ChallengeMode.GetAffixInfo then
                    local affixIDs = C_ChallengeMode.GetActiveAffixIDs()
                    if affixIDs then
                        for i, affixID in ipairs(affixIDs) do
                            local affixName, description, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
                            if affixName then
                                table.insert(affixes, {
                                    id = affixID,
                                    name = affixName,
                                })
                            end
                        end
                    end
                end
            end
        end

        local playerData = {
            serverName = realmName,
            roleName = playerName,
            occupation = classFileName,
            mapName = name,
            mapID = challengeMapID or instanceID,
            instanceID = instanceID,
            instanceType = instanceType,
            difficultyID = difficultyID,
            difficultyName = difficultyName,
            isChallenge = inChallenge,
            keystoneLevel = keystoneLevel,
            affixes = affixes,
            timestamp = time(),
        }

        if ns and ns.PixelComm then
            ns.PixelComm:sendCommand('accountInfo', playerData)
        end
    end

    C_Timer.After(5, SendPlayerInfo)
    C_Timer.NewTicker(30, SendPlayerInfo)
end

function addon.OnInit()
    if not MythicArchiveDB then
        MythicArchiveDB = {}
    end

    if addon.InitializeMythicPlus then
        addon.InitializeMythicPlus()
    end

    addon.StartPlayerInfoTimer()
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", addon.OnInit)
