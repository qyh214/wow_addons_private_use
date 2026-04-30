-- =============================================================
-- [[ ExwindTools 核心组件：重要法术数据库 (ExwindCDDB) ]]
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

-- [SpellID] = { class, talents, cooldown, zhCN_name, enUS_name }
ExwindTools.CDDB = {
    --------------------------------------------------------------------------------
    -- Warrior / 战士 (0208更新)
    --------------------------------------------------------------------------------
    [871] = { class = 1, talents = { 73 }, cooldown = 60, zhCN_name = "盾墙", enUS_name = "Shield Wall" },
    [107574] = { class = 1, talents = { 71, 72, 73 }, cooldown = 90, zhCN_name = "天神下凡", enUS_name = "Avatar" },
    [118038] = { class = 1, talents = { 71 }, cooldown = 120, zhCN_name = "剑在人在", enUS_name = "Die by the Sword" },
    [184364] = { class = 1, talents = { 72, }, cooldown = 120, zhCN_name = "狂怒回复", enUS_name = "Enraged Regeneration" },
    [389722] = { class = 1, talents = { 72 }, cooldown = 90, zhCN_name = "鲁莽", enUS_name = "Recklessness" },

    --------------------------------------------------------------------------------
    -- Paladin / 圣骑士 (0208更新)
    --------------------------------------------------------------------------------
    [498] = { class = 2, talents = { 65, 70 }, cooldown = 60, zhCN_name = "圣佑术", enUS_name = "Divine Protection" },
    [31850] = { class = 2, talents = { 66 }, cooldown = 90, zhCN_name = "炽热防御者", enUS_name = "Ardent Defender" },
    [31884] = { class = 2, talents = { 65, 66, 70 }, cooldown = 120, zhCN_name = "复仇之怒", enUS_name = "Avenging Wrath" },
    [216331] = { class = 2, talents = { 65 }, cooldown = 60, zhCN_name = "复仇十字军", enUS_name = "Avenging Crusader" },
    [231895] = { class = 2, talents = { 0 }, cooldown = 120, zhCN_name = "复仇之怒", enUS_name = "Avenging Wrath" },
    [389539] = { class = 2, talents = { 66 }, cooldown = 60, zhCN_name = "戒卫", enUS_name = "Sentinel" },
    [403876] = { class = 2, talents = { 65, 70 }, cooldown = 60, zhCN_name = "圣佑术", enUS_name = "Divine Protection" },
    [454351] = { class = 2, talents = { 70, }, cooldown = 30, zhCN_name = "复仇之怒", enUS_name = "Avenging Wrath" }, --被动
    [454373] = { class = 2, talents = { 0 }, cooldown = 0, zhCN_name = "复仇之怒", enUS_name = "Avenging Wrath" },
    [1261559] = { class = 2, talents = { 0 }, cooldown = 60, zhCN_name = "圣佑术", enUS_name = "Divine Protection" },

    --------------------------------------------------------------------------------
    -- Hunter / 猎人 (0208更新)
    --------------------------------------------------------------------------------
    [109304] = { class = 3, talents = { 253, 254, 255 }, cooldown = 120, zhCN_name = "意气风发", enUS_name = "Exhilaration" },
    [264735] = { class = 3, talents = { 253, 254, 255 }, cooldown = 2, zhCN_name = "优胜劣汰", enUS_name = "Survival of the Fittest" },
    [266779] = { class = 3, talents = { 0 }, cooldown = 120, zhCN_name = "协同进攻", enUS_name = "Coordinated Assault" },
    [288613] = { class = 3, talents = { 254 }, cooldown = 120, zhCN_name = "百发百中", enUS_name = "Trueshot" },
    [359844] = { class = 3, talents = { 0 }, cooldown = 120, zhCN_name = "荒野的召唤", enUS_name = "Call of the Wild" },
    [360952] = { class = 3, talents = { 0 }, cooldown = 120, zhCN_name = "协同进攻", enUS_name = "Coordinated Assault" },
    [377572] = { class = 3, talents = { 0 }, cooldown = 0, zhCN_name = "协同进攻", enUS_name = "Coordinated Assault" },
    [389654] = { class = 3, talents = { 0 }, cooldown = 0, zhCN_name = "驯兽大师", enUS_name = "Master Handler" },
    [389660] = { class = 3, talents = { 0 }, cooldown = 0, zhCN_name = "毒蛇之咬", enUS_name = "Snake Bite" },
    [1250646] = { class = 3, talents = { 255 }, cooldown = 90, zhCN_name = "狩魂一击", enUS_name = "Takedown" },
    [1251703] = { class = 3, talents = { 255 }, cooldown = 0, zhCN_name = "狩魂一击", enUS_name = "Takedown" },

    --------------------------------------------------------------------------------
    -- Rogue / 潜行者
    --------------------------------------------------------------------------------
    [5277] = { class = 4, talents = { 259, 260, 261 }, cooldown = 120, zhCN_name = "闪避", enUS_name = "Evasion" },
    [13750] = { class = 4, talents = { 260 }, cooldown = 180, zhCN_name = "冲动", enUS_name = "Adrenaline Rush" },
    [79140] = { class = 4, talents = { 0 }, cooldown = 120, zhCN_name = "宿敌", enUS_name = "Vendetta" },
    [121471] = { class = 4, talents = { 261 }, cooldown = 90, zhCN_name = "暗影之刃", enUS_name = "Shadow Blades" },
    [185311] = { class = 4, talents = { 259, 260, 261 }, cooldown = 30, zhCN_name = "猩红之瓶", enUS_name = "Crimson Vial" },
    [360194] = { class = 4, talents = { 259 }, cooldown = 120, zhCN_name = "死亡印记", enUS_name = "Deathmark" },
    [361175] = { class = 4, talents = { 0 }, cooldown = 180, zhCN_name = "午夜", enUS_name = "Midnight" },

    --------------------------------------------------------------------------------
    -- Priest / 牧师 (0208更新)
    --------------------------------------------------------------------------------
    [19236] = { class = 5, talents = { 256, 257, 258 }, cooldown = 90, zhCN_name = "绝望祷言", enUS_name = "Desperate Prayer" },
    [64843] = { class = 5, talents = { 257 }, cooldown = 180, zhCN_name = "神圣赞美诗", enUS_name = "Divine Hymn" },
    [194249] = { class = 5, talents = { 258 }, cooldown = 120, zhCN_name = "虚空形态", enUS_name = "Voidform" },
    [228260] = { class = 5, talents = { 258 }, cooldown = 120, zhCN_name = "虚空形态", enUS_name = "Voidform" },
    [391109] = { class = 5, talents = { 0 }, cooldown = 60, zhCN_name = "黑暗升华", enUS_name = "Dark Ascension" },
    [408558] = { class = 5, talents = { 0 }, cooldown = 0, zhCN_name = "相位变换", enUS_name = "Phase Shift" },
    [1246965] = { class = 5, talents = { 0 }, cooldown = 0, zhCN_name = "心灵帷幕", enUS_name = "Psychic Shroud" },

    --------------------------------------------------------------------------------
    -- Death Knight / 死亡骑士 (0208更新)
    --------------------------------------------------------------------------------
    [48707] = { class = 6, talents = { 250, 251, 252 }, cooldown = 60, zhCN_name = "反魔法护罩", enUS_name = "Anti-Magic Shell" },
    [48792] = { class = 6, talents = { 250, 251, 252 }, cooldown = 120, zhCN_name = "冰封之韧", enUS_name = "Icebound Fortitude" },
    [49028] = { class = 6, talents = { 250 }, cooldown = 120, zhCN_name = "符文刃舞", enUS_name = "Dancing Rune Weapon" },
    [51271] = { class = 6, talents = { 251 }, cooldown = 45, zhCN_name = "冰霜之柱", enUS_name = "Pillar of Frost" },
    [55233] = { class = 6, talents = { 250 }, cooldown = 90, zhCN_name = "吸血鬼之血", enUS_name = "Vampiric Blood" },
    [275699] = { class = 6, talents = { 252 }, cooldown = 45, zhCN_name = "天启", enUS_name = "Apocalypse" },

    --------------------------------------------------------------------------------
    -- Shaman / 萨满祭司 (0208更新 元素萨的风暴/火元素需要查看)
    --------------------------------------------------------------------------------
    [8178] = { class = 7, talents = { 0 }, cooldown = 0, zhCN_name = "根基图腾", enUS_name = "Grounding Totem" },
    [51533] = { class = 7, talents = { 263 }, cooldown = 90, zhCN_name = "野性狼魂", enUS_name = "Feral Spirit" },
    [108271] = { class = 7, talents = { 262, 263, 264 }, cooldown = 120, zhCN_name = "星界转移", enUS_name = "Astral Shift" },
    [108280] = { class = 7, talents = { 264 }, cooldown = 120, zhCN_name = "治疗之潮图腾", enUS_name = "Healing Tide Totem" },
    [192249] = { class = 7, talents = { 262 }, cooldown = 5, zhCN_name = "风暴元素", enUS_name = "Storm Elemental" },
    [198067] = { class = 7, talents = { 262 }, cooldown = 5, zhCN_name = "火元素", enUS_name = "Fire Elemental" },

    --------------------------------------------------------------------------------
    -- Mage / 法师 (0208更新)
    --------------------------------------------------------------------------------
    [118] = { class = 8, talents = { 0 }, cooldown = 60, zhCN_name = "变形术", enUS_name = "Polymorph" },
    [12472] = { class = 8, talents = { 64 }, cooldown = 120, zhCN_name = "冰冷血脉", enUS_name = "Icy Veins" },
    [55342] = { class = 8, talents = { 62, 63, 64 }, cooldown = 120, zhCN_name = "镜像", enUS_name = "Mirror Image" },
    [110909] = { class = 8, talents = { 62, 63, 64 }, cooldown = 60, zhCN_name = "操控时间", enUS_name = "Alter Time" },
    [190319] = { class = 8, talents = { 63 }, cooldown = 120, zhCN_name = "燃烧", enUS_name = "Combustion" },
    [198144] = { class = 8, talents = { 64 }, cooldown = 60, zhCN_name = "寒冰形态", enUS_name = "Ice Form" },
    [365350] = { class = 8, talents = { 62 }, cooldown = 90, zhCN_name = "奥术涌动", enUS_name = "Arcane Surge" },
    [365362] = { class = 8, talents = { 62 }, cooldown = 90, zhCN_name = "奥术涌动", enUS_name = "Arcane Surge" },

    --------------------------------------------------------------------------------
    -- Warlock / 术士 (0208更新)
    --------------------------------------------------------------------------------
    [104773] = { class = 9, talents = { 265, 266, 267 }, cooldown = 180, zhCN_name = "不灭决心", enUS_name = "Unending Resolve" },
    [205180] = { class = 9, talents = { 265 }, cooldown = 120, zhCN_name = "召唤黑眼", enUS_name = "Summon Darkglare" },
    [265187] = { class = 9, talents = { 266 }, cooldown = 60, zhCN_name = "召唤恶魔暴君", enUS_name = "Summon Demonic Tyrant" },
    [335235] = { class = 9, talents = { 267 }, cooldown = 120, zhCN_name = "召唤地狱火", enUS_name = "Summon Infernal" },
    [367679] = { class = 9, talents = { 0 }, cooldown = 0, zhCN_name = "召唤渎神魔", enUS_name = "Summon Blasphemy" },
    [387278] = { class = 9, talents = { 265 }, cooldown = 180, zhCN_name = "召唤黑眼", enUS_name = "Summon Darkglare" },

    --------------------------------------------------------------------------------
    -- Monk / 武僧 (0208更新)
    --------------------------------------------------------------------------------
    [115203] = { class = 10, talents = { 268 }, cooldown = 360, zhCN_name = "壮胆酒", enUS_name = "Fortifying Brew" },
    [115310] = { class = 10, talents = { 0 }, cooldown = 120, zhCN_name = "还魂术", enUS_name = "Revival" },
    [132578] = { class = 10, talents = { 268 }, cooldown = 120, zhCN_name = "玄牛下凡", enUS_name = "Invoke Niuzao, the Black Ox" },
    [137639] = { class = 10, talents = { 269 }, cooldown = 16, zhCN_name = "风火雷电", enUS_name = "Storm, Earth, and Fire" },
    [243435] = { class = 10, talents = { 268, 269, 270 }, cooldown = 420, zhCN_name = "壮胆酒", enUS_name = "Fortifying Brew" },
    [297850] = { class = 10, talents = { 70 }, cooldown = 120, zhCN_name = "还魂术", enUS_name = "Revival" },
    [388615] = { class = 10, talents = { 270 }, cooldown = 120, zhCN_name = "还阳术", enUS_name = "Restoral" },
    [395267] = { class = 10, talents = { 268 }, cooldown = 180, zhCN_name = "玄牛下凡", enUS_name = "Invoke Niuzao, the Black Ox" },

    --------------------------------------------------------------------------------
    -- Druid / 德鲁伊 (0208更新)
    --------------------------------------------------------------------------------
    [22812] = { class = 11, talents = { 102, 103, 104, 105 }, cooldown = 60, zhCN_name = "树皮术", enUS_name = "Barkskin" },
    [50334] = { class = 11, talents = { 0 }, cooldown = 180, zhCN_name = "狂暴", enUS_name = "Berserk" },
    [102543] = { class = 11, talents = { 103 }, cooldown = 180, zhCN_name = "化身：阿莎曼之灵", enUS_name = "Incarnation: Avatar of Ashamane" },
    [102558] = { class = 11, talents = { 104 }, cooldown = 180, zhCN_name = "化身：乌索克的守护者", enUS_name = "Incarnation: Guardian of Ursoc" },
    [102560] = { class = 11, talents = { 102 }, cooldown = 120, zhCN_name = "化身：艾露恩之眷", enUS_name = "Incarnation: Chosen of Elune" },
    [106951] = { class = 11, talents = { 103 }, cooldown = 180, zhCN_name = "狂暴", enUS_name = "Berserk" },
    [194223] = { class = 11, talents = { 102 }, cooldown = 120, zhCN_name = "超凡之盟", enUS_name = "Celestial Alignment" },
    [383410] = { class = 11, talents = { 102 }, cooldown = 120, zhCN_name = "超凡之盟", enUS_name = "Celestial Alignment" },
    [390414] = { class = 11, talents = { 102 }, cooldown = 120, zhCN_name = "化身：艾露恩之眷", enUS_name = "Incarnation: Chosen of Elune" },
    [1236574] = { class = 11, talents = { 105 }, cooldown = 180, zhCN_name = "宁静", enUS_name = "Tranquility" },

    --------------------------------------------------------------------------------
    -- Demon Hunter / 恶魔猎手 (0208更新)
    --------------------------------------------------------------------------------
    [187827] = { class = 12, talents = { 581 }, cooldown = 120, zhCN_name = "恶魔变形", enUS_name = "Metamorphosis" },
    [191427] = { class = 12, talents = { 577 }, cooldown = 120, zhCN_name = "恶魔变形", enUS_name = "Metamorphosis" },
    [198589] = { class = 12, talents = { 577, 1480 }, cooldown = 60, zhCN_name = "疾影", enUS_name = "Blur" },
    [204021] = { class = 12, talents = { 581 }, cooldown = 60, zhCN_name = "烈火烙印", enUS_name = "Fiery Brand" },
    [212800] = { class = 12, talents = { 0 }, cooldown = 60, zhCN_name = "疾影", enUS_name = "Blur" },
    [1217605] = { class = 12, talents = { 1480 }, cooldown = 0, zhCN_name = "虚空变形", enUS_name = "Void Metamorphosis" },

    --------------------------------------------------------------------------------
    -- Evoker / 唤魔师
    --------------------------------------------------------------------------------
    [363916] = { class = 13, talents = { 1467, 1468, 1473 }, cooldown = 120, zhCN_name = "黑曜鳞片", enUS_name = "Obsidian Scales" },
    [375087] = { class = 13, talents = { 1467 }, cooldown = 120, zhCN_name = "狂龙之怒", enUS_name = "Dragonrage" },
    [378464] = { class = 13, talents = { 0 }, cooldown = 90, zhCN_name = "废灵遮罩", enUS_name = "Nullifying Shroud" },
    [443069] = { class = 13, talents = { 0 }, cooldown = 120, zhCN_name = "烈焰之泉", enUS_name = "Well of Flame" },
}

-- ==================== 查询接口 ====================
function ExwindTools:GetSpellCD(spellID)
    local data = self.CDDB[spellID]
    return data and data.cooldown or 0
end

function ExwindTools:GetSpellName(spellID, locale)
    local data = self.CDDB[spellID]
    if not data then return nil end
    return (locale == "enUS") and data.enUS_name or data.zhCN_name
end

function ExwindTools:GetSpellsByClass(classID)
    local result = {}
    for spellID, data in pairs(self.CDDB) do
        if data.class == classID then
            result[spellID] = data
        end
    end
    return result
end

