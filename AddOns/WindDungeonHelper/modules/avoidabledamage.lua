-- Modified from ElitismHelper
local W, F, L, P = unpack(select(2, ...))
local AD = W:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0")

local assert = assert
local format = format
local gsub = gsub
local math_pow = math.pow
local pairs = pairs
local print = print
local select = select
local sort = sort
local strmatch = strmatch
local strsplit = strsplit
local tinsert = tinsert
local tonumber = tonumber
local type = type
local wipe = wipe

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetRealmName = GetRealmName
local GetSpellLink = GetSpellLink
local GetUnitName = GetUnitName
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealthMax = UnitHealthMax
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer

local C_ChatInfo_GetRegisteredAddonMessagePrefixes = C_ChatInfo.GetRegisteredAddonMessagePrefixes
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Timer_After = C_Timer.After

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local wprint = function()
    return
end
--local wprint = print

--------------------------------------------
-- Authority
--------------------------------------------
AD.prefix = "WDH_AD"
local myServerID, myPlayerUID, authorityCache

function AD:InitializeAuthority()
    local successfulRequest = C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)
    assert(successfulRequest, L["The addon message prefix registration is failed."])

    local guidSplitted = {strsplit("-", UnitGUID("player"))}
    myServerID = tonumber(guidSplitted[2], 10)
    myPlayerUID = tonumber(guidSplitted[3], 16)
end

function AD:CheckAuthority(key)
    if IsInGroup() then
        if authorityCache.playerUID ~= myPlayerUID or authorityCache.serverID ~= myServerID then
            return false
        end
    end

    return true
end

do
    local channelLevel = {
        SELF = 0,
        EMOTE = 1,
        PARTY = 2
    }

    function AD:SendMyLevel()
        if IsInGroup(LE_PARTY_CATEGORY_HOME) then
            local level = self.db.notification.channel and channelLevel[self.db.notification.channel] or 0

            -- If reload the ui, the data is cleared
            if self.inRecording then
                level = level + 100
            end

            local message = format("%s;%d;%d", level, myServerID, myPlayerUID)
            C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
        end
    end
end

function AD:ReceiveLevel(message, sender)
    if message == "RESET_AUTHORITY" then
        self:UpdatePartyInfo()
        return
    end

    local level, serverID, playerUID = strmatch(message, "^([0-9]-);([0-9]-);([0-9]+)")
    level = tonumber(level)
    serverID = tonumber(serverID)
    playerUID = tonumber(playerUID)

    if not authorityCache then
        authorityCache = {
            level = level,
            serverID = serverID,
            playerUID = playerUID,
            name = sender
        }
        return
    end

    local needUpdate = false
    if level > authorityCache.level then -- 等级比较
        needUpdate = true
    elseif level == authorityCache.level then
        if serverID > authorityCache.serverID then -- 服务器 ID 比较
            needUpdate = true
        elseif serverID == authorityCache.serverID then
            if playerUID > authorityCache.playerUID then -- 玩家 ID 比较
                needUpdate = true
            end
        end
    end

    if needUpdate then
        authorityCache.level = level
        authorityCache.serverID = serverID
        authorityCache.playerUID = playerUID
        authorityCache.name = sender
    end
end

function AD:CHAT_MSG_ADDON(_, prefix, message, channel, sender)
    if prefix == self.prefix then
        self:ReceiveLevel(message, sender)
    end
end

do
    local waitSend = false
    function AD:UpdatePartyInfo()
        if waitSend or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
            return
        end

        authorityCache = nil
        waitSend = true

        C_Timer_After(
            0.5,
            function()
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    AD:SendMyLevel()
                end
                waitSend = false
            end
        )
    end
end

function AD:GetActiveUser()
    return authorityCache and authorityCache.name or GetUnitName("player")
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return
    end

    if authorityCache and authorityCache.playerUID ~= myPlayerUID then
        return
    end

    if self.db.notification.channel == "SELF" then
        print(message)
    elseif self.db.notification.channel == "PARTY" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(message, "PARTY")
    elseif self.db.notification.channel == "EMOTE" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(": " .. message, "EMOTE")
    end
end

function AD:ResetAuthority()
    if not IsInGroup() then
        return
    end

    C_ChatInfo_SendAddonMessage(self.prefix, "RESET_AUTHORITY", "PARTY")
end

--------------------------------------------
-- Database
--------------------------------------------
-- Types
local MISTAKE = {
    SPELL_DAMAGE = 1, -- 法術傷害
    AURA = 2, -- 得到錯誤的效果
    MELEE = 3 -- 近戰傷害
}
-- Data
local MistakeData = {
    ["General"] = {
        -- Debug (死靈進門右轉法術怪)
        -- {
        --     -- 近戰攻擊
        --     type = MISTAKE.MELEE,
        --     npc = 166302
        -- },
        -- {
        --     -- 汲取體液
        --     type = MISTAKE.SPELL_DAMAGE,
        --     spell = 334749
        -- },
        {
            -- 火山煙流
            type = MISTAKE.SPELL_DAMAGE,
            spell = 209862
        },
        {
            -- 膿血
            type = MISTAKE.SPELL_DAMAGE,
            spell = 226512
        },
        {
            -- 地震
            type = MISTAKE.SPELL_DAMAGE,
            spell = 240448
        },
        {
            -- 風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 343520
        },
        {
            -- 逞凶鬥狠 (第一賽季)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 342494
        }
    },
    ["The Necrotic Wake"] = {
        -- 小怪
        {
            -- 嚴寒尖刺
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324391
        },
        {
            -- 臟腑削切 (胖子)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333477
        },
        -- [1] 荒骨
        -- [2] 『收割者』亞瑪斯
        {
            -- 死靈吐息
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333489
        },
        {
            -- 死靈膿液
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333492
        },
        -- [3] 縫補師縫肉
        {
            -- 肉鉤
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327952
        },
        {
            -- 防腐黏液 (腳下污水)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320365
        },
        {
            -- 防腐黏液 (腳下污水)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320366
        },
        {
            -- 劇毒迷霧
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327100
        },
        {
            -- 病態凝視 (追人)
            type = MISTAKE.MELEE,
            npc = 162689,
            playerDebuff = 343556
        },
        -- [4] 『霜縛者』納爾索
        {
            -- 彗星風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320784
        },
        {
            -- 鋒利碎冰 (大冰圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 328212
        }
    },
    ["Theater of Pain"] = {
        -- 小怪
        {
            -- 死靈箭雨
            type = MISTAKE.SPELL_DAMAGE,
            spell = 317367
        },
        {
            -- 骸骨風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331224
        },
        {
            -- 地面潰擊 (『毀壞者』黑文)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 332708
        },
        {
            -- 迴旋刀刃 (『割碎者』奈克薩拉)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 337037
        },
        {
            -- 死亡之風 (會被吹下平台)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333297
        },
        {
            -- 邪惡爆發 (腐臭肉囊 前後雙噴)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 330592
        },
        {
            -- 邪惡爆發 (腐臭肉囊 前後雙噴)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 330608
        },
        {
            -- 骸骨尖刺 (魂鑄削骨者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331243
        },
        -- [1] 蔑視挑戰者
        {
            -- 灼熱死亡 (腳下圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333292,
            noPlayerDebuff = 333231
        },
        -- [2] 肉排
        {
            -- 搗肉猛擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 318406
        },
        {
            -- 鋸齒劈砍 (被勾上)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323406
        },
        -- [3] 『未逝者』薩夫
        {
            -- 震耳衝擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339415
        },
        {
            -- 巨力猛劈
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320729
        },
        {
            -- 粉碎猛擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 317231
        },
        -- [4] 庫薩洛克
        {
            -- 幻魄寄生 (腳下圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 319765,
            noPlayerDebuff = 319626
        },
        -- [5] 『不朽女皇』莫瑞莎
        {
            -- 黑暗破滅
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323681
        },
        {
            -- 鬼魅衝鋒
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339751
        },
        {
            -- 屠殺殘影
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339573
        },
        {
            -- 戰鬥殘影
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339550
        }
    },
    ["Mists of Tirna Scithe"] = {
        -- 小怪
        {
            -- 困惑花粉 (面前衝擊)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321968
        },
        {
            -- 刺藤爆發(佐司特斷枝者 緩速黑水)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 325027
        },
        {
            -- 後背踢 (霧紗守護者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331748
        },
        {
            -- 長舌鞭笞 (青蛙怪)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 340300
        },
        {
            -- 毒性分泌物 (青蛙怪)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 340304
        },
        {
            -- 長矛亂舞
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331721,
            playerIsNotTank = true
        },
        -- [1] 英拉馬洛克
        {
            -- 靈魄之潭 (藍色污水)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323250
        },
        {
            -- 困惑花粉 (面前衝擊)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323137
        },
        -- [2] 喚霧者
        {
            -- 拍蛋糕
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321828
        },
        {
            -- 躲避球
            type = MISTAKE.SPELL_DAMAGE,
            spell = 336759
        },
        {
            -- 冰凍衝擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321893
        },
        -- [3] 崔朵瓦
        {
            -- 酸液滴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 326021
        },
        {
            -- 消化酸
            type = MISTAKE.SPELL_DAMAGE,
            spell = 326309
        },
        {
            -- 酸液噴吐
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322655
        }
    },
    ["Spires of Ascension"] = {
        -- 小怪
        {
            -- 迅捷削切 (琪瑞安黑暗軍教官)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323786
        },
        {
            -- 橫掃攻擊 (棄誓者先鋒)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 317943
        },
        {
            -- 漸弱 (萊克西斯 左邊門神)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 336420
        },
        {
            -- 衝擊 (棄誓者小隊長)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323740
        },
        {
            -- 粉碎重擊 (棄誓者小隊長)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 336447
        },
        {
            -- 強音 (棄誓者惡徒 4方向AoE)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 336444,
            playerIsNotTank = true
        },
        -- [1] 金塔拉
        {
            -- 充能之矛
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321034
        },
        {
            -- 巨力斬擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320966,
            playerIsNotTank = true
        },
        {
            -- 離子電漿
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324662
        },
        {
            -- 深度連結 (連線)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331251
        },
        {
            -- 淵染毒液 (午睡)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 317626
        },
        {
            -- 弱化彈幕 (黑球)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324370
        },
        -- [2] 溫圖納斯
        {
            -- 黑闇箭
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324141
        },
        -- [3] 奧利菲翁
        {
            -- 蓄能踐踏
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324608
        },
        -- [4]『猜疑楷模』德沃絲
        {
            -- 穿梭
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323943
        },
        {
            -- 冥淵引爆
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334625,
            damageThreshold = 10000
        }
    },
    ["De Other Side"] = {
        -- 小怪
        {
            -- 黑暗蓮花 (延遲爆炸紫圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 328729
        },
        {
            -- 黑暗爆發 (亡語者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334051
        },
        {
            -- 狂怒面具
            type = MISTAKE.SPELL_DAMAGE,
            spell = 342869
        },
        {
            -- 狂怒面具
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333790
        },
        {
            -- 斬掠 (遠處旋風斬)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333250
        },
        {
            -- 噴灑精華 (哈卡之子 大紅圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323569
        },
        {
            -- 近戰 (阿塔萊死亡行者的靈魂 追人)
            type = MISTAKE.MELEE,
            npc = 170483
        },
        {
            -- 瘋狂鑽鑿 (損壞的鑽牙器 需卡視角)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331933
        },
        {
            -- 機械炸彈松鼠
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320830
        },
        {
            -- 靈魄星風暴 (去商人路上隨機出現的小圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 313236
        },
        -- [1]『奪魂者』哈卡

        -- [2] 曼納斯頓夫婦
        -- [3] 商人希夏
        {
            -- 爆炸裝置
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320232
        },
        {
            -- 位移衝擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320723
        },
        -- [4] 繆薩拉
        {
            -- 星能雲霧
            type = MISTAKE.SPELL_DAMAGE,
            spell = 335000
        },
        {
            -- 宇宙崩壞
            type = MISTAKE.SPELL_DAMAGE,
            spell = 325691
        },
        {
            -- 破碎領域
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327427
        },
        {
            -- 死亡主宰
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334913
        }
    },
    ["Sanguine Depths"] = {
        -- 小怪
        {
            -- 回音戳刺 (本體)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320999
        },
        {
            -- 回音戳刺 (鏡像)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320991
        },
        {
            -- 易爆陷阱 (恐怖神獵手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334563
        },
        {
            -- 橫掃揮擊 (監護長賈夫臨 面前放風)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334615
        },
        {
            -- 斷魂削砍 (大石像鬼正面順劈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322429,
            playerIsNotTank = true
        },
        {
            -- 爆裂皮紙 (研究紀錄者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 334378
        },
        {
            -- 峭岩裂石
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322418
        },
        -- [1] 貪婪的奎西斯
        -- [2] 處決者塔沃德
        {
            -- 罪觸靈魄
            type = MISTAKE.SPELL_DAMAGE,
            spell = 328494
        },
        {
            -- 殘渣
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323573
        },
        -- [3] 總監督者貝莉亞
        {
            -- 苦痛狂嚎
            type = MISTAKE.SPELL_DAMAGE,
            spell = 325885
        },
        {
            -- 滋長的猜忌
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322212
        },
        -- [4] 凱厄將軍
        {
            -- 穿透殘影
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323810
        },
        {
            -- 沉鬱疾風
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323810,
            noPlayerBuff = 324092
        }
    },
    ["Halls of Atonement"] = {
        -- 小怪
        {
            -- 爆發折磨
            -- TODO: Check this
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327885
        },
        {
            -- 致命推進 (墮落的暗刃兵)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 325523
        },
        {
            -- 罪孽震盪 (哈奇厄斯裂片)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 326440
        },
        {
            -- 急速射擊 (墮落的馴犬者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 325799
        },
        {
            -- 岩石之息
            type = MISTAKE.SPELL_DAMAGE,
            spell = 346866,
            playerIsNotTank = true
        },
        {
            -- 強力揮擊 (石源魔斬擊者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 326997,
            playerIsNotTank = true
        },
        -- [1]『罪污巨人』哈奇厄斯
        {
            -- 拋擲殘骸
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322945
        },
        {
            -- 玻璃裂片
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323001
        },
        {
            -- 折射罪光
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324044
        },
        -- [2] 艾可隆
        {
            -- 血腥洪流
            type = MISTAKE.SPELL_DAMAGE,
            spell = 319702
        },
        -- [3] 至高判決者阿利茲
        -- [4] 宮務大臣
        {
            -- 念力碰撞
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323126
        },
        {
            -- 念力猛襲
            type = MISTAKE.SPELL_DAMAGE,
            spell = 329113
        }
    },
    ["Plaguefall"] = {
        -- 小怪
        {
            -- 黏著寄生 (沼地怪幼體)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 335882
        },
        {
            -- 振翅攻擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 330404
        },
        {
            -- 腐臭膽汁 (噴湧軟泥)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 319120
        },
        {
            -- 瘟疫炸彈 (路上炸彈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 328501
        },
        {
            -- 毒液池 (腐爛的血肉巨人)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320072
        },
        {
            -- 鋸齒脊刺 (荒蕪斷脊者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320519
        },
        {
            -- 膿瘡噴射 (荒蕪斷脊者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 318949
        },
        {
            -- 嘔吐瘟疫
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327233
        },
        -- [1] 葛洛格羅
        {
            -- 軟泥波
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324667
        },
        {
            -- 軟泥波
            type = MISTAKE.SPELL_DAMAGE,
            spell = 326242
        },
        -- [2] 伊克思博士
        {
            -- 黏液爆發
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333808
        },
        {
            -- 軟泥突擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 329217
        },
        -- [3] 多米娜‧毒刃
        -- [4] 藩侯史特拉達瑪
        {
            -- 瘟疫撞擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 322475
        },
        {
            -- 瘟疫泉源
            type = MISTAKE.SPELL_DAMAGE,
            spell = 330135
        }
    }
}

--------------------------------------------
-- Triggers
--------------------------------------------

do
    local MapTable = {
        [1663] = "Halls of Atonement",
        [1664] = "Halls of Atonement",
        [1665] = "Halls of Atonement",
        [1666] = "The Necrotic Wake",
        [1667] = "The Necrotic Wake",
        [1668] = "The Necrotic Wake",
        [1669] = "Mists of Tirna Scithe",
        [1674] = "Plaguefall",
        [1675] = "Sanguine Depths",
        [1676] = "Sanguine Depths",
        [1677] = "De Other Side",
        [1678] = "De Other Side",
        [1679] = "De Other Side",
        [1680] = "De Other Side",
        [1683] = "Theater of Pain",
        [1684] = "Theater of Pain",
        [1685] = "Theater of Pain",
        [1686] = "Theater of Pain",
        [1687] = "Theater of Pain",
        [1692] = "Spires of Ascension",
        [1693] = "Spires of Ascension",
        [1694] = "Spires of Ascension",
        [1695] = "Spires of Ascension",
        [1697] = "Plaguefall"
    }

    function AD:GetCurrentDungeonName()
        local mapID = C_Map_GetBestMapForUnit("player")
        return mapID and MapTable[mapID]
    end
end

local policy = {
    spell = {},
    aura = {},
    melee = {}
}

local function GetIDByGUID(guid)
    return tonumber(strmatch(guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function AD:CompilePolicy(policies)
    for _, mistake in pairs(policies) do
        if mistake.type == MISTAKE.SPELL_DAMAGE then
            policy.spell[mistake.spell] = mistake
        elseif mistake.type == MISTAKE.AURA then
            policy.aura[mistake.aura] = mistake
        elseif mistake.type == MISTAKE.MELEE then
            policy.melee[mistake.npc] = mistake
        end
    end
end

function AD:Compile()
    policy = {
        spell = {},
        aura = {},
        melee = {}
    }

    local mapName = self:GetCurrentDungeonName()
    if not mapName or not MistakeData[mapName] then
        return
    end

    self:CompilePolicy(MistakeData.General)
    self:CompilePolicy(MistakeData[mapName])
end

--------------------------------------------
-- Message Functions
--------------------------------------------
local warningMessage
local stacksMessage
local spellMessage

function AD:FormatNumber(amount)
    if not self.db or not self.db.notification then
        return
    end

    if self.db.notification.unit == "ASIA" then
        if amount > math_pow(10, 4) then
            return F.Round(amount / 10000, self.db.notification.accuracy) .. L["[UNIT] W"]
        else
            return amount
        end
    elseif self.db.notification.unit == "WESTERN" then
        if amount > math_pow(10, 3) then
            return F.Round(amount / 1000, self.db.notification.accuracy) .. L["[UNIT] K"]
        else
            return amount
        end
    end

    return amount
end

function AD:SetNotificationText()
    if self.db.custom.enable then
        warningMessage = self.db.custom.warningMessage
        stacksMessage = self.db.custom.stacksMessage
        spellMessage = self.db.custom.spellMessage
    else
        warningMessage = P.avoidableDamage.custom.warningMessage
        stacksMessage = P.avoidableDamage.custom.stacksMessage
        spellMessage = P.avoidableDamage.custom.spellMessage
    end
end

function AD:GenerateOutput(text, name, spell, stack, damage, percent)
    text = gsub(text, "%%name%%", name)
    text = gsub(text, "%%spell%%", spell)

    if stack then
        text = gsub(text, "%%stack%%", stack)
    end

    if damage then
        text = gsub(text, "%%damage%%", damage)
    end

    if percent then
        percent = F.Round(percent, self.db.notification.accuracy)
        text = gsub(text, "%%percent%%", format("%s%%%%", percent))
    end

    return text
end

--------------------------------------------
-- Statistic Functions
--------------------------------------------
local timers = {}
local timerData = {}
local combinedFails = {}

local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
end

local function PlayerHasBuff(player, spellID)
    for i = 1, 40 do
        local debuffID = select(10, UnitBuff(player, i))
        if debuffID == spellID then
            return true
        end
    end

    return false
end

local function PlayerHasDebuff(player, spellID)
    for i = 1, 40 do
        local debuffID = select(10, UnitDebuff(player, i))
        if debuffID == spellID then
            return true
        end
    end

    return false
end

function AD:COMBAT_LOG_EVENT_UNFILTERED()
    local _, event, _, sourceGUID, _, _, _, _, destName, _, _, param12, _, _, param15, param16, param17 =
        CombatLogGetCurrentEventInfo()

    if not UnitIsPlayer(destName) then
        return
    end

    local eventPrefix, eventSuffix = strmatch(event, "^(.-)_?([^_]*)$")

    if (strmatch(eventPrefix, "^SPELL") or strmatch(eventSuffix, "^RANGE")) and eventSuffix == "DAMAGE" then
        -- SPELL_DAMAGE | RANGE_DAMAGE | SPELL_PERIODIC_DAMAGE | SPELL_BUILDING_DAMAGE
        -- spell: 12th
        -- amount: 15th
        self:GetHit_Spell(destName, param12, param15)
    elseif eventPrefix == "SWING" and eventSuffix == "DAMAGE" then
        -- SWING_DAMAGE
        -- amount: 12th
        self:GetHit_Swing(destName, sourceGUID, param12)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        -- SPELL_MISSED | SPELL_PERIODIC_MISSED
        -- spell: 12th
        -- amountMissed: 17th
        if param17 then
            self:GetHit_Spell(destName, param12, param17)
        end
    elseif event == "SPELL_AURA_APPLIED" then
        -- spell: 12th
        -- amount: 16th
        -- TODO
    elseif event == "SPELL_AURA_APPLIED_DOSE" then
    -- spell: 12th
    -- amount: 16th
    -- TODO
    end
end

function AD:IsPolicyPassed(player, amount, data)
    if data.noPlayerDebuff then
        if type(data.noPlayerDebuff) == "number" then
            if PlayerHasDebuff(player, data.noPlayerDebuff) then
                return false
            end
        end
    end

    if data.noPlayerBuff then
        if type(data.noPlayerBuff) == "number" then
            if PlayerHasBuff(player, data.noPlayerBuff) then
                return false
            end
        end
    end

    if data.playerIsNotTank then
        if UnitGroupRolesAssigned(player) == "TANK" then
            return false
        end
    end

    if data.damageThreshold then
        if amount < data.damageThreshold then
            return false
        end
    end

    return true
end

function AD:GetHit_Spell(player, spellID, amount)
    if not policy.spell[spellID] then
        return
    end

    if not self:IsPolicyPassed(player, amount, policy.spell[spellID]) then
        return
    end

    if timerData[player] == nil then
        timerData[player] = {}
    end

    if combinedFails[player] == nil then
        combinedFails[player] = 0
    end

    combinedFails[player] = combinedFails[player] + amount
    if timerData[player][spellID] == nil then
        timerData[player][spellID] = amount
    else
        timerData[player][spellID] = timerData[player][spellID] + amount
    end

    self:AnnounceAfterSeconds(4, player)
end

function AD:GetHit_Swing(player, sourceGUID, amount)
    local sourceID = GetIDByGUID(sourceGUID)
    if not sourceID or not policy.melee[sourceID] then
        return
    end

    if not self:IsPolicyPassed(player, amount, policy.melee[sourceID]) then
        return
    end

    if not timerData[player] then
        timerData[player] = {}
    end

    if not combinedFails[player] then
        combinedFails[player] = 0
    end
    combinedFails[player] = combinedFails[player] + amount

    if not timerData[player][6603] then
        timerData[player][6603] = amount
    else
        timerData[player][6603] = timerData[player][6603] + amount
    end

    self:AnnounceAfterSeconds(4, player)
end

function AD:AnnounceAfterSeconds(sec, player)
    if not timers[player] then
        timers[player] = true
        C_Timer_After(
            sec,
            function()
                self:DamageAnnouncer(player)
            end
        )
    end
end

function AD:DamageAnnouncer(player)
    if not timerData[player] then
        return
    end

    local spellLinks = ""
    local totalDamage = 0

    for spellID, damage in pairs(timerData[player]) do
        spellLinks = spellLinks .. GetSpellLink(spellID) .. " "
        totalDamage = totalDamage + damage
    end

    timerData[player] = nil
    timers[player] = nil

    local playerMaxHealth = UnitHealthMax(player)
    local damageText = self:FormatNumber(totalDamage)
    local percentage = totalDamage / playerMaxHealth * 100

    if self.db.notification.enable and percentage >= self.db.notification.threshold then
        self:SendChatMessage(self:GenerateOutput(spellMessage, player, spellLinks, nil, damageText, percentage))
    end
end

function AD:ResetStatistic()
    wipe(combinedFails)
    wipe(timerData)
    wipe(timers)
end

--------------------------------------------
-- Toggling
--------------------------------------------
function AD:CHALLENGE_MODE_COMPLETED()
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    if not self.db.rank.enable then
        return
    end

    local count = 0
    for _ in pairs(combinedFails) do
        count = count + 1
    end

    if count == 0 then
        self:SendChatMessage(L["No failure damage was taken this run."])
        return
    end

    self:SendChatMessage(L["Amount of failure damage:"])

    local damageTable = {}
    for name, damage in pairs(combinedFails) do
        tinsert(damageTable, {key = name, value = damage})
    end

    SortTable(damageTable)

    for index, data in pairs(damageTable) do
        self:SendChatMessage(format("%d. %s %s", index, data.key, self:FormatNumber(data["value"])))
    end

    if self.db.rank.worst then
        self:SendChatMessage("-----------------------")
        self:SendChatMessage(format("%s: %s", self.db.rank.customWorst, damageTable[1].key))
    end

    self:ResetStatistic()
    self.inRecording = nil
end

function AD:CHALLENGE_MODE_START()
    if not self:GetCurrentDungeonName() then
        return
    end

    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:Compile()
    self:ResetStatistic()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.inRecording = true
end

function AD:OnInitialize()
    self:InitializeAuthority()
    self:ProfileUpdate()
    self:SetNotificationText()
end

function AD:ZONE_CHANGED_NEW_AREA()
    self:ResetAuthority()
    self:Compile()
end

function AD:ProfileUpdate()
    self.db = W.db.avoidableDamage

    if self.db.enable then
        self:Compile()
        self:UpdatePartyInfo()
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE", "ResetAuthority")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        if IsInInstance() then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        self:UnregisterEvent("CHAT_MSG_ADDON")
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("CHALLENGE_MODE_START")
        self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:ResetStatistic()
    end
end
