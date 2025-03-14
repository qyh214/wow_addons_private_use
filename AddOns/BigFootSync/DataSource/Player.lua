---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.player = {}

local U = BigFootSync.utils
---@class Player
local P = BigFootSync.player

---------------------------------------------------------------------
-- 通过unitId保存单位的基础信息
---------------------------------------------------------------------
function P.SaveUnitBaseData(t, unit, useFullNameAsIndex)
    if not UnitIsPlayer(unit) then return end

    -- 全名
    local fullName, name, realm = U.UnitName(unit)
    if not (fullName and name and realm) then return end

    -- 对于所有玩家的数据保存，以全名为索引
    if useFullNameAsIndex then
        if not t[fullName] then t[fullName] = {} end
        t = t[fullName]
    else
        t["fullName"] = fullName
    end

    t["incomplete"] = nil

    -- guid（可能发生变化）
    t["guid"] = UnitGUID(unit)
    -- 名字（短）
    t["name"] = name
    -- 服务器（normalized）
    t["realm"] = realm
    -- 等级
    t["level"] = UnitLevel(unit)
    -- 性别
    t["gender"] = UnitSex(unit)
    -- 种族
    t["raceId"] = select(3, UnitRace(unit))
    -- 职业
    t["classId"] = select(2, UnitClassBase(unit))
    -- 阵营
    t["faction"] = UnitFactionGroup(unit)
    -- 公会
    t["guild"] = GetGuildInfo(unit)
    -- 地区（为了客户端读取方便）
    t["region"] = BFS_Account["region"]
    -- 游戏版本（为了客户端读取方便）
    t["version"] = U.GetBigFootClientVersion()
    -- 更新时间
    t["lastSeen"] = GetServerTime()

    -- 自己的装等
    if UnitIsUnit("player", unit) and t["level"] == U.GetMaxLevel() then
        t["itemLevel"] = Round(select(2, GetAverageItemLevel()))
    end
end


---------------------------------------------------------------------
-- 保存玩家自己的属性信息
---------------------------------------------------------------------
function P.SavePlayerStatData(t)
    -- 主属性
    local stats = {"strength", "agility", "stamina", "intellect"}
    if not BigFootSync.isRetail then tinsert(stats, "spirit") end
    for k, v in pairs(stats) do
        t[v] = select(2, UnitStat("player", k)) -- stat, effectiveStat, posBuff(包括装备), negBuff
    end

    -- 最大生命值
    t["healthMax"] = UnitHealthMax("player")
    -- 最大能量值
    t["powerMax"] = UnitPowerMax("player")
    -- 能量类型 TODO: 根据天赋仅保存主要能量类型，目前保存当前类型
    t["powerType"] = UnitPowerType("player", 0) -- MANA
    -- 护甲值
    t["armor"] = select(2, UnitArmor("player"))
    -- 护甲物理减伤百分比（目标等级相同时）
    t["armorEffectiveness"] = C_PaperDollInfo.GetArmorEffectiveness(t["armor"], UnitLevel("player"))
    -- 急速（直接加百分号，怀旧服使用 CR_HASTE_*）
    t["haste"] = GetHaste()
    -- 暴击率（直接加百分号）
    t["critChance"] = GetCritChance()
    -- 躲闪概率（直接加百分号）
    t["dodgeChance"] = GetDodgeChance()
    -- 招架概率（直接加百分号）
    t["parryChance"] = GetParryChance()
    -- 格挡概率（直接加百分号）
    t["blockChance"] = GetBlockChance()

    -- spellBonusDamage
    -- 1 Physical
    -- 2 Holy
    -- 3 Fire
    -- 4 Nature
    -- 5 Frost
    -- 6 Shadow
    -- 7 Arcane
    t["spellBonusDamage"] = 0
    for i = 1, 7 do
        local sbd = GetSpellBonusDamage(i)
        if sbd > t["spellBonusDamage"] then
            t["spellBonusDamage"] = sbd
        end
    end

    -- reset
    t["versatility"] = nil
    t["leech"] = nil
    t["avoidance"] = nil
    t["speed"] = nil
    t["resistance"] = nil

    if BigFootSync.isRetail then
        -- 全能（直接加百分号，伤害增加值，若要获取受到伤害减免值，除以2即可）
        t["versatility"] = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
        -- 吸血
        t["leech"] = GetLifesteal()
        -- 闪避
        t["avoidance"] = GetAvoidance()
        -- 加速
        t["speed"] = GetSpeed()
    else
        -- 抗性 https://warcraft.wiki.gg/wiki/API_UnitResistance
        t["resistance"] = {
            -- ["physical"] = 0,
            ["holy"] = 1,
            ["fire"] = 2,
            ["nature"] = 3,
            ["forst"] = 4,
            ["shadow"] = 5,
            ["arcane"] = 6,
        }
        for k, i in pairs(t["resistance"]) do
            t["resistance"][k] = select(2, UnitResistance("player", i))
        end
    end
end


---------------------------------------------------------------------
-- 保存玩家自己的 CombatRating 和 CombatRatingBonus
---------------------------------------------------------------------
local CR_RETAIL = {
    -- "CR_UNUSED_1", -- 1
    "CR_DEFENSE_SKILL", -- 2
    "CR_DODGE", -- 3
    "CR_PARRY", -- 4
    "CR_BLOCK", -- 5
    "CR_HIT_MELEE", -- 6
    "CR_HIT_RANGED", -- 7
    "CR_HIT_SPELL", -- 8
    "CR_CRIT_MELEE", -- 9
    "CR_CRIT_RANGED", -- 10
    "CR_CRIT_SPELL", -- 11
    "CR_CORRUPTION", -- 12
    "CR_CORRUPTION_RESISTANCE", -- 13
    "CR_SPEED", -- 14
    "COMBAT_RATING_RESILIENCE_CRIT_TAKEN", -- 15
    "COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN", -- 16
    "CR_LIFESTEAL", -- 17
    "CR_HASTE_MELEE", -- 18
    "CR_HASTE_RANGED", -- 19
    "CR_HASTE_SPELL", -- 20
    "CR_AVOIDANCE", -- 21
    -- "CR_UNUSED_2", -- 22
    "CR_WEAPON_SKILL_RANGED", -- 23
    "CR_EXPERTISE", -- 24
    "CR_ARMOR_PENETRATION", -- 25
    "CR_MASTERY", -- 26
    -- "CR_UNUSED_3", -- 27
    -- "CR_UNUSED_4", -- 28
    "CR_VERSATILITY_DAMAGE_DONE", -- 29
    "CR_VERSATILITY_DAMAGE_TAKEN", -- 31
}

local CR_WRATH = {
    "CR_WEAPON_SKILL", -- 1
    "CR_DEFENSE_SKILL", -- 2
    "CR_DODGE", -- 3
    "CR_PARRY", -- 4
    "CR_BLOCK", -- 5
    "CR_HIT_MELEE", -- 6
    "CR_HIT_RANGED", -- 7
    "CR_HIT_SPELL", -- 8
    "CR_CRIT_MELEE", -- 9
    "CR_CRIT_RANGED", -- 10
    "CR_CRIT_SPELL", -- 11
    "CR_RESILIENCE_CRIT_TAKEN", -- 15
    "CR_RESILIENCE_PLAYER_DAMAGE_TAKEN", -- 16
    "CR_HASTE_MELEE", -- 18
    "CR_HASTE_RANGED", -- 19
    "CR_HASTE_SPELL", -- 20
    "CR_EXPERTISE", -- 24
    "CR_ARMOR_PENETRATION", -- 25
}

local function SavePlayerCombatRatingData(t)
    local CR
    if BigFootSync.isRetail then
        CR = CR_RETAIL
    elseif BigFootSync.isWrath then
        CR = CR_WRATH
    elseif BigFootSync.isCata then
        CR = CR_CATA -- TODO: 之后再说
    end
    if not CR then return end

    for _, cr in pairs(CR) do
        if type(_G[cr]) == "number" then
            -- 数值
            t["combatRating"][cr] = GetCombatRating(_G[cr])
            -- 百分比
            t["combatRatingBonus"][cr] = GetCombatRatingBonus(_G[cr])
        end
    end
end


---------------------------------------------------------------------
-- 保存队内玩家数据
---------------------------------------------------------------------
function P.SaveGroupMemberData(t)
    for unit in U.IterateGroupMembers() do
        P.SaveUnitBaseData(t, unit, true)
    end
end


---------------------------------------------------------------------
-- 保存公会玩家数据
---------------------------------------------------------------------
function P.SaveGuildMemberData(t, guildName, guildRealm, guildFaction)
    for i = 1, GetNumGuildMembers() do
        local name, _, _, level, _, _, _, _, _, _, classFile = GetGuildRosterInfo(i)

        if not t[name] then
            -- 标记该记录需要进一步的信息完善
            t[name] = {["incomplete"] = true}
        end

        t[name]["name"] = U.ToShortName(name)
        t[name]["level"] = level
        t[name]["classId"] = U.GetClassID(classFile)
        t[name]["guild"] = guildName
        t[name]["realm"] = guildRealm -- 默认为公会服务器
        t[name]["faction"] = guildFaction -- 默认为公会阵营
        t[name]["region"] = BFS_Account["region"] -- 地区（为了客户端读取方便）
        t[name]["version"] = U.GetBigFootClientVersion() -- 游戏版本（为了客户端读取方便）
        t[name]["lastSeen"] = GetServerTime() -- 更新时间
    end
end


---------------------------------------------------------------------
-- 保存好友数据
---------------------------------------------------------------------
function P.SaveFriendData(t)
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)

        local name, realm
        -- 角色名可能不带服务器
        if strfind(info.name, "-") then
            name, realm = strsplit("-", info.name)
        else
            name = info.name
            realm = GetNormalizedRealmName()
            info.name = info.name.."-"..GetNormalizedRealmName()
        end

        if not t[info.name] then
            -- 标记该记录需要进一步的信息完善
            t[info.name] = {["incomplete"] = true}
        end

        t[info.name]["name"] = name
        t[info.name]["guid"] = info.guid
        t[info.name]["level"] = info.level -- 未在线可能为0
        t[info.name]["realm"] = realm
        if info.className ~= _G.UNKNOWN then
            t[info.name]["classId"] = U.GetClassID(info.className)
        end
        t[info.name]["region"] = BFS_Account["region"] -- 地区（为了客户端读取方便）
        t[info.name]["faction"] = UnitFactionGroup("player") -- 游戏好友，阵营与玩家一致
        t[info.name]["version"] = U.GetBigFootClientVersion() -- 游戏版本（为了客户端读取方便）
        t[info.name]["lastSeen"] = GetServerTime() -- 更新时间
    end
end

function P.SaveBNetFriendData(t, realmDataTable)
    for i = 1, BNGetNumFriends() do
        -- https://warcraft.wiki.gg/wiki/API_C_BattleNet.GetFriendAccountInfo
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info.gameAccountInfo and info.gameAccountInfo.clientProgram == _G.BNET_CLIENT_WOW then
            info = info.gameAccountInfo

            -- 游戏版本（为了客户端读取方便）
            local version = info.wowProjectID and U.GetBigFootClientVersion(info.wowProjectID)

            -- 不同版本客户端之间可能获取不到服务器
            if info.realmName and info.isInCurrentRegion and version then
                -- 角色名不带服务器
                local name = info.characterName.."-"..info.realmName

                if not t[name] then
                    -- 标记该记录需要进一步的信息完善
                    t[name] = {["incomplete"] = true}
                end

                t[name]["name"] = info.characterName
                t[name]["guid"] = info.playerGuid
                t[name]["level"] = info.characterLevel
                t[name]["realm"] = info.realmDisplayName
                t[name]["faction"] = info.factionName
                t[name]["classId"] = U.GetClassID(info.className)
                t[name]["lastSeen"] = GetServerTime() -- 更新时间
                -- info.raceName: 本地化后的种族名

                -- 补充服务器信息
                if not realmDataTable[info.realmID] then
                    realmDataTable[info.realmID] = {
                        ["name"] = info.realmDisplayName,
                        ["normalizedName"] = info.realmName,
                    }
                end

                t[name]["region"] = BFS_Account["region"] -- 地区（为了客户端读取方便）
                t[name]["version"] = version -- 游戏版本（为了客户端读取方便）
            end
        end
    end
end