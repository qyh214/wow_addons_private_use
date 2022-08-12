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
local strjoin = strjoin
local strmatch = strmatch
local strsplit = strsplit
local tinsert = tinsert
local tonumber = tonumber
local type = type
local unpack = unpack
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

local function GetBestChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
        return "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "PARTY"
    end
end

function AD:InitializeAuthority()
    local successfulRequest = C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)
    assert(successfulRequest, L["The addon message prefix registration is failed."])

    local guidSplitted = {strsplit("-", UnitGUID("player"))}
    myServerID = tonumber(guidSplitted[2], 10)
    myPlayerUID = tonumber(guidSplitted[3], 16)
end

do
    local channelLevel = {
        SELF = 0,
        EMOTE = 1,
        PARTY = 2
    }

    function AD:SendMyLevel(force)
        if not self.db then
            return
        end

        if IsInGroup() then
            local level = self.db.notification.channel and channelLevel[self.db.notification.channel] or 0

            -- If reload the ui, the data is cleared
            if self.inRecording then
                level = level + 100
            end

            if level ~= 0 and force then
                if authorityCache then
                    level = authorityCache.level + 1
                end
            end

            local message = format("%s;%d;%d", level, myServerID, myPlayerUID)
            C_ChatInfo_SendAddonMessage(self.prefix, message, GetBestChannel())
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

        waitSend = true

        C_Timer_After(
            0.5,
            function()
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    authorityCache = nil
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
    if not self.db.notification.enable or not IsInGroup() then
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

    C_ChatInfo_SendAddonMessage(self.prefix, "RESET_AUTHORITY", GetBestChannel())
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
            -- 懷恨幽影
            type = MISTAKE.MELEE,
            npc = 174773
        },
        {
            -- 夢魘 (S4 納斯雷茲姆滲透者)
            type = MISTAKE.AURA,
            aura = 373391
        },
        {
            -- 腐屍蟲群 (S4 納斯雷茲姆滲透者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 373429
        }
    },
    ["Tazavesh: Streets of Wonder"] = {
        -- 小怪
        {
            -- 裂隙衝擊 (傳送門法師佐洪)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355306
        },
        {
            -- 震擊地雷 (指揮官佐發)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355476
        },
        {
            -- 致命武力 (指揮官佐發)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355487
        },
        {
            -- 震光屏障 (環境)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355502
        },
        {
            -- 鎮壓猛襲 (市場保安官)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355638
        },
        {
            -- 干擾手榴彈 (海關警衛)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355903
        },
        {
            -- 光束接合者 (武裝監督者, 『追蹤者』佐寇司)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 356011
        },
        {
            -- 腐爛的食物 (脫序的顧客)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 356482
        },
        {
            -- 聖光裂片撤退 (集團幫派)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 357019
        },
        -- [1] 佐菲克斯
        {
            -- 武裝保全
            type = MISTAKE.SPELL_DAMAGE,
            spell = 348366
        },
        -- [2] 大展示廳
        {
            -- 飢餓之握 (阿克魯斯)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 349663
        },
        {
            -- 宏偉吞噬 (阿克魯斯)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 349801
        },
        {
            -- 靈魄引爆 (亞奇力特)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 349999
        },
        {
            -- 散熱震盪 (亞奇力特)
            -- 測試 (可能無法避免)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 351070
        },
        {
            -- 旋風之滅 (溫札‧金熔)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 350090
        },
        -- [3] 佐戈隆
        {
            -- 控場
            type = MISTAKE.SPELL_DAMAGE,
            spell = 350921
        },
        {
            -- 壓制火光
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355439
        },
        {
            -- 不許進入！
            type = MISTAKE.SPELL_DAMAGE,
            spell = 357799
        },
        -- [4] 郵務主管
        {
            -- 灑出的液體
            type = MISTAKE.SPELL_DAMAGE,
            spell = 346329
        },
        -- [5] 索阿茲米
        {
            -- 殊離之環
            type = MISTAKE.SPELL_DAMAGE,
            spell = 347481
        }
    },
    ["Tazavesh: So'leah's Gambit"] = {
        -- 小怪
        {
            -- 易爆河豚 (暗洋魚法師)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355234
        },
        {
            -- 巨石投擲 (岸行者巨人)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355465
        },
        {
            -- 轟雷 (風鑄守護者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355581
        },
        {
            -- 充電脈衝 (風鑄守護者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 355584
        },
        {
            -- 潮汐爆發 (沙漏號浪潮賢者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 356260
        },
        {
            -- 漂流之星 (絢麗觀星者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 357228
        },
        -- [1] 海布藍德
        {
            -- 淨滅火焰
            type = MISTAKE.SPELL_DAMAGE,
            spell = 346960
        },
        {
            -- 淨滅力場
            type = MISTAKE.SPELL_DAMAGE,
            spell = 346961
        },
        {
            -- 泰坦撞擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 347094
        },
        {
            -- 符文回應
            type = MISTAKE.SPELL_DAMAGE,
            spell = 356796
        },
        -- [2] 時光船長鉤尾
        {
            -- 無限吐息
            type = MISTAKE.SPELL_DAMAGE,
            spell = 347149
        },
        {
            -- 鉤尾掃擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 347151
        },
        {
            -- 火砲彈幕
            type = MISTAKE.SPELL_DAMAGE,
            spell = 347370
        },
        {
            -- 鉤到啦！
            type = MISTAKE.SPELL_DAMAGE,
            spell = 354334
        },
        {
            -- 燃燒焦油
            type = MISTAKE.SPELL_DAMAGE,
            spell = 358947
        },
        -- [3] 索利亞
        {
            -- 能量分離
            type = MISTAKE.SPELL_DAMAGE,
            spell = 351101
        },
        {
            -- 極光新星
            type = MISTAKE.SPELL_DAMAGE,
            spell = 351646
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
            -- 彗星風暴 (楼上的)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320784
        },
        {
            -- 彗星風暴 (楼下的)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321956
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
            -- 死靈箭雨 (癲狂縛魂者, [4] 庫薩洛克)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 317367
        },
        {
            -- 噁心爆發 (染疫嘔泥者死亡綠圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 321041
        },
        {
            -- 骸骨風暴 (魂鑄削骨者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 331224
        },
        {
            -- 地面潰擊 (『毀壞者』黑文)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 332708
        },
        {
            -- 蠻橫跳躍 (『殘暴者』多奇格)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 342126
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
            -- 邪惡爆發 (腐臭肉囊 後噴)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 330592
        },
        {
            -- 邪惡爆發 (腐臭肉囊 前噴)
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
        {
            -- 抓握之手
            type = MISTAKE.SPELL_DAMAGE,
            spell = 319639
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
        {
            -- 璀璨之息
            type = MISTAKE.SPELL_DAMAGE,
            spell = 340160
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
            -- 淵染毒液 (污水)
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
            -- 蒼穹砲
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323372
        },
        {
            -- 靈魄力場
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323792
        },
        {
            -- 蓄能踐踏
            type = MISTAKE.SPELL_DAMAGE,
            spell = 324608,
            playerIsNotTank = true
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
            noPlayerDebuff = 335805
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
            -- 劍刃風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 332672
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
            -- 織線 (無頭的顧客)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 332157
        },
        {
            -- 機械炸彈松鼠
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320830
        },
        {
            -- 靈魄星風暴 (去商人路上隨機出現的小圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323136
        },
        -- [1]『奪魂者』哈卡
        {
            -- 鮮血彈幕
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323118
        },
        -- [2] 曼納斯頓夫婦
        {
            -- 回音指尖極限雷射
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323992
        },
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
            spell = 323001,
            playerIsNotTank = true
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
        {
            -- 靈魂泉
            type = MISTAKE.SPELL_DAMAGE,
            spell = 338013
        },
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
        },
        {
            -- 釋放磨難
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323236
        },
        {
            -- 爆發折磨
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327885
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
    },
    ["Operation: Mechagon - Junkyard"] = {
        -- 小怪
        {
            -- 螺旋碎塊 (故障的廢料機器人)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294890 -- TODO: 到底是哪個?
        },
        {
            -- 螺旋碎塊 (故障的廢料機器人)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300159
        },
        {
            -- 自毀程序 (故障的廢料機器人)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300129
        },
        {
            -- 急速射擊 (機械岡騎兵)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 301667
        },
        {
            -- B.O.R.K (廢料獵犬)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 299475
        },
        {
            -- 廢料爆炸 (活塞頭技師)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 299535
        },
        {
            -- 超U質模組：廢料火砲 (武裝爬行蛛)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300188
        },
        {
            -- 震懾波 (廢骨惡霸)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300427
        },
        {
            -- 爆炸 (廢骨垃圾投擲者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300561
        },
        {
            -- 黏液波 (軟泥元素)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 300816
        },
        -- 勾巴馬克王
        {
            -- 土崩石塌
            type = MISTAKE.SPELL_DAMAGE,
            spell = 297283
        },
        -- 髒克
        {
            -- 劇毒波
            type = MISTAKE.SPELL_DAMAGE,
            spell = 297834
        },
        {
            -- 結合
            type = MISTAKE.SPELL_DAMAGE,
            spell = 297835
        },
        {
            -- 燃盡
            type = MISTAKE.SPELL_DAMAGE,
            spell = 297985
        },
        -- 崔克西和奈洛
        {
            -- 燃盡
            type = MISTAKE.SPELL_DAMAGE,
            spell = 298571
        },
        {
            -- 電力懸浮
            type = MISTAKE.SPELL_DAMAGE,
            spell = 298849
        },
        {
            -- 螺栓破擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 298940
        },
        {
            -- 油門踩到底
            type = MISTAKE.SPELL_DAMAGE,
            spell = 299164
        },
        {
            -- 劇烈電擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 302681
        },
        -- HK-8型空中壓制單位
        {
            -- 火砲轟擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 295536
        },
        {
            -- 排氣口爆發
            type = MISTAKE.SPELL_DAMAGE,
            spell = 296150
        },
        {
            -- 自體毀滅
            type = MISTAKE.SPELL_DAMAGE,
            spell = 296522
        },
        {
            -- 靜電迸發
            type = MISTAKE.SPELL_DAMAGE,
            spell = 302384
        }
    },
    ["Operation: Mechagon - Workshop"] = {
        -- 小怪
        {
            -- 高殺傷性松鼠 (高殺傷性松鼠)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 293861
        },
        {
            -- 音波脈衝 (砲轟機器人X-80型)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 293986
        },
        {
            -- 發射高爆性火箭 (砲轟機器人X-80型)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294015
        },
        {
            -- 電容器釋電 (砲轟機器人X-80型)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 295168
        },
        {
            -- 火箭彈幕 (火箭機兵)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294128
        },
        {
            -- 熔爐火焰 (傳送帶)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 301299
        },
        {
            -- 處理廢料 (廢棄物處理器)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294291
        },
        {
            -- 強力鑽刺 (廢棄物處理器)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294324
        },
        -- 暴力機兵
        {
            -- 電鋸
            type = MISTAKE.SPELL_DAMAGE,
            spell = 282945
        },
        {
            -- 極限衝刺
            type = MISTAKE.SPELL_DAMAGE,
            spell = 283422
        },
        {
            -- 迴旋刀刃
            type = MISTAKE.SPELL_DAMAGE,
            spell = 285020
        },
        {
            -- 設置詭雷
            type = MISTAKE.SPELL_DAMAGE,
            spell = 285344
        },
        -- K.U.-J.0.機械犬
        {
            -- 空投
            type = MISTAKE.SPELL_DAMAGE,
            spell = 291930
        },
        {
            -- 噴射烈焰
            type = MISTAKE.SPELL_DAMAGE,
            spell = 291946
        },
        {
            -- 垃圾炸彈
            type = MISTAKE.SPELL_DAMAGE,
            spell = 291953
        },
        -- 機械工花園
        {
            -- 混-亂-榴彈
            type = MISTAKE.SPELL_DAMAGE,
            spell = 285454
        },
        {
            -- 自我修剪樹籬
            type = MISTAKE.SPELL_DAMAGE,
            spell = 294954
        },
        -- 機械岡國王
        {
            -- 校準
            type = MISTAKE.SPELL_DAMAGE,
            spell = 291856
        },
        {
            -- 電漿球
            type = MISTAKE.SPELL_DAMAGE,
            spell = 291915
        }
    },
    ["Return to Karazhan: Lower"] = {
        -- 小怪
        {
            -- 哥布林龍槍 (魅影賓客)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 21910
        },
        {
            -- 琅琅詩詞 (鬼魅候補演員)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227917
        },
        {
            -- 勁爆終曲 (鬼魅候補演員)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227925
        },
        {
            -- 閃光 (骷髏接待員)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227966
        },
        {
            -- 閃光 (骷髏接待員)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227977
        },
        {
            -- 乾坤一擲 (鬼魅慈善家)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 228001
        },
        {
            -- 衝鋒 (鬼靈戰騎)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 228603
        },
        {
            -- 秘法爆發 (秘法看守者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 238606
        },
        {
            -- 盾牌潰擊 (魅影守衛)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 241774
        },
        -- 歌劇大廳: 西荒故事
        {
            -- 烈焰掃腿
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227568
        },
        {
            -- 洗淨一切
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227799
        },
        -- 歌劇大廳: 美女與野獸
        {
            -- 殘羹
            type = MISTAKE.SPELL_DAMAGE,
            spell = 228019
        },
        {
            -- 兇猛除塵
            type = MISTAKE.SPELL_DAMAGE,
            spell = 228215
        },
        -- 獵人阿圖曼
        {
            -- 苦難共享
            type = MISTAKE.SPELL_DAMAGE,
            spell = 228852
        },
        {
            -- 舉踏
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227339
        },
        {
            -- 鬼騎衝鋒
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227645
        },
        -- 摩洛斯
        {
            -- 喪志打擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227672
        }
    },
    ["Return to Karazhan: Upper"] = {
        -- 小怪
        {
            -- 騎士出動 (騎士)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229298
        },
        {
            -- 騎士出動 (騎士)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229563
        },
        {
            -- 皇后出動 (皇后)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229384
        },
        {
            -- 皇家斬擊 (國王)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229427
        },
        {
            -- 主教出動 (主教)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229559
        },
        {
            -- 城堡出動 (城堡)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229568
        },
        {
            -- 燒灼方格 (憤怒守衛烈焰使者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229988
        },
        {
            -- 不穩定的能量 (受損的魔像)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 242894
        },
        -- 館長
        {
            -- 能量釋放
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227285
        },
        {
            -- 能量釋放
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227465
        },
        -- 麥迪文之影
        {
            -- 不絕寒冬
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227806
        },
        -- 法力吞噬者
        {
            -- 秘法炸彈
            type = MISTAKE.SPELL_DAMAGE,
            spell = 227620
        },
        -- 『監視者』維茲亞頓
        {
            -- 崩解
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229151
        },
        {
            -- 爆裂黑影
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229161
        },
        {
            -- 魔化能量光束
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229248
        },
        {
            -- 轟炸
            type = MISTAKE.SPELL_DAMAGE,
            spell = 229285
        }
    },
    ["Iron Docks"] = {
        -- [1] 『血肉撕裂者』諾加爾
        {
            -- 燃燒箭
            type = MISTAKE.SPELL_DAMAGE,
            spell = 164632
        },
        {
            -- 倒鉤箭雨
            type = MISTAKE.SPELL_DAMAGE,
            spell = 164648
        },
        -- [2] 恐軌執行者
        {
            -- 撕碎肌腱
            type = MISTAKE.SPELL_DAMAGE,
            spell = 163276
        },
        {
            -- 熔岩掃擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 165152
        },
        -- [3] 歐席爾
        {
            --  原始突襲
            type = MISTAKE.SPELL_DAMAGE,
            spell = 161256
        },
        -- [4] 史庫洛克
        {
            -- 急速射擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 168348,
            noPlayerDebuff = 168398
        },
        {
            -- 火砲彈幕
            type = MISTAKE.SPELL_DAMAGE,
            spell = 168390
        }
    },
    ["Grimrail Depot"] = {
        -- 小怪
        {
            -- 黑石炸彈 (恐軌投彈手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 164188
        },
        {
            -- 破片射擊 (格羅姆卡槍手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 156303
        },
        {
            -- 黑石迫擊炮 (格羅姆卡砲手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 160963
        },
        {
            -- 黑石手榴彈 (格羅姆卡擲彈手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 161153
        },
        {
            -- 風暴之盾 (格羅姆卡先知)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 166336
        },
        {
            -- 雷獄 (格羅姆卡先知)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 166340
        },
        {
            -- 火舌 (格羅姆卡識燼者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 176033
        },
        {
            -- 火舌 (格羅姆卡識燼者)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 176039
        },
        {
            -- 火砲彈幕 (格羅姆卡砲手)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 176131
        },
        -- [1] 火箭光和波爾卡
        {
            -- 瘋狂衝刺
            type = MISTAKE.SPELL_DAMAGE,
            spell = 161089
        },
        {
            -- VX18-B目標殲滅者
            type = MISTAKE.SPELL_DAMAGE,
            spell = 162513
        },
        -- [2] 奈楚格‧雷塔
        {
            -- 壓制射擊
            type = MISTAKE.SPELL_DAMAGE,
            spell = 161220
        },
        {
            -- 黑石迫擊炮
            type = MISTAKE.SPELL_DAMAGE,
            spell = 163741
        },
        -- [3] 傲天者托芙菈
        {
            -- 散射能量
            type = MISTAKE.SPELL_DAMAGE,
            spell = 161588
        },
        {
            -- 冰凍陷阱
            type = MISTAKE.SPELL_DAMAGE,
            spell = 162065
        },
        {
            -- 旋轉長矛
            type = MISTAKE.SPELL_DAMAGE,
            spell = 162057
        }
    }
}

--------------------------------------------
-- Triggers
--------------------------------------------

do
    local MapTable = {
        [595] = "Iron Docks",
        [606] = "Grimrail Depot",
        [607] = "Grimrail Depot",
        [608] = "Grimrail Depot",
        [609] = "Grimrail Depot",
        [809] = "Return to Karazhan: Lower",
        [810] = "Return to Karazhan: Lower",
        [811] = "Return to Karazhan: Lower",
        [812] = "Return to Karazhan: Lower",
        [813] = "Return to Karazhan: Lower",
        [814] = "Return to Karazhan: Lower",
        [815] = "Return to Karazhan: Upper",
        [816] = "Return to Karazhan: Upper",
        [817] = "Return to Karazhan: Upper",
        [818] = "Return to Karazhan: Upper",
        [819] = "Return to Karazhan: Upper",
        [820] = "Return to Karazhan: Upper",
        [821] = "Return to Karazhan: Upper",
        [822] = "Return to Karazhan: Upper",
        [1490] = "Operation: Mechagon - Junkyard",
        [1491] = "Operation: Mechagon - Workshop",
        [1493] = "Operation: Mechagon - Junkyard",
        [1494] = "Operation: Mechagon - Workshop",
        [1497] = "Operation: Mechagon - Workshop",
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
        [1697] = "Plaguefall",
        [1989] = "Tazavesh: Streets of Wonder",
        [1990] = "Tazavesh: Streets of Wonder",
        [1991] = "Tazavesh: Streets of Wonder",
        [1992] = "Tazavesh: Streets of Wonder",
        [1993] = "Tazavesh: So'leah's Gambit",
        [1995] = "Tazavesh: So'leah's Gambit",
        [1996] = "Tazavesh: So'leah's Gambit",
        [1997] = "Tazavesh: So'leah's Gambit"
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
            return F.Round(amount / 1000, self.db.notification.accuracy) .. L["[UNIT] k"]
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
local meleeNPCs = {}

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
    local _, event, _, sourceGUID, sourceName, _, _, _, destName, _, _, param12, _, _, param15, param16, param17 =
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
        self:GetHit_Swing(destName, sourceGUID, sourceName, param12)
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
    -- Windwalker monk karma
    if PlayerHasBuff(player, 125174) then
        return false
    end

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

function AD:GetHit_Swing(player, sourceGUID, sourceName, amount)
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

    if not meleeNPCs[player] then
        meleeNPCs[player] = {}
    end
    meleeNPCs[player][sourceName] = true

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
        if spellID == 6603 then
            local names = {}
            for name in pairs(meleeNPCs[player]) do
                tinsert(names, name)
            end
            spellLinks = spellLinks .. GetSpellLink(spellID) .. "(" .. strjoin(",", unpack(names)) .. ") "
        else
            spellLinks = spellLinks .. GetSpellLink(spellID) .. " "
        end
        totalDamage = totalDamage + damage
    end

    timerData[player] = nil
    timers[player] = nil
    meleeNPCs[player] = nil

    local playerMaxHealth = UnitHealthMax(player)
    local damageText = self:FormatNumber(totalDamage)
    local percentage = totalDamage / playerMaxHealth * 100

    if self.db.notification.enable and percentage >= self.db.notification.threshold then
        if self.db.rank.enable and self.db.rank.onlyRanking then
            return
        end
        self:SendChatMessage(self:GenerateOutput(spellMessage, player, spellLinks, nil, damageText, percentage))
    end
end

function AD:ResetStatistic()
    wipe(meleeNPCs)
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
    else
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
            self:SendChatMessage("--------------------------------")
            self:SendChatMessage(format("%s: %s", self.db.rank.customWorst, damageTable[1].key))
        end
    end

    if self.db.rank.addonInfo then
        self:SendChatMessage("--------------------------------")
        self:SendChatMessage(L["The report generated by Wind Dungeon Helper."])
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
    AD:InitializeAuthority()
    AD:ProfileUpdate()
    AD:SetNotificationText()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function AD:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    if isLogin or isReload then
        self:ResetAuthority()
    end
end

function AD:ZONE_CHANGED_NEW_AREA()
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
