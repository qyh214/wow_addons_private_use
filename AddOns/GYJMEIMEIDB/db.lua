GYJMEIMEIDB = {
    targeted = {
        [434756] = {"点名", "注意点名.ogg"}, --Throw Chair
        [441119] = {"击退", "小心击退.ogg"}, --Bee-Zooka
        [426619] = {"冲锋", "注意冲锋.ogg"}, --One-Hand Headlock
        [474031] = {"分散", "注意分散.ogg"}, --Void Crush
        [430179] = {"脚下", "注意脚下.ogg"}, --Seeping Corruption
        [424423] = {"分散", "注意分散.ogg"}, --Lunging Strike
        [448787] = {"点名", "注意点名.ogg"}, --Purification
        [1217279] = {"击退", "小心击退.ogg"}, --Uppercut
        [257582] = {"锁定", "目标锁定.ogg"}, --Raging Gaze
        [262794] = {"点名", "注意点名.ogg"}, --Mind Lash
        [268846] = {"分散", "注意分散.ogg"}, --Echo Blade
        [262383] = {"锁定", "目标锁定.ogg"}, --Deploy Crawler Mine
        [330532] = {"流血", "注意流血.ogg"}, --Jagged Quarrel
        [333861] = {"流血", "注意流血.ogg"}, --Ricocheting Blade
        [448619] = {"冲锋", "注意冲锋.ogg"}, --Reckless Delivery
    },
    trash_cc = {
        --[spellID] = {"name",category,"soundFile","role", "show target" (true/false), "important" (true/false)},
        [267354] = {"刀扇", 2, "", "ALL", false, true}, --刀扇
        [268702] = {"AoE", 0, "", "ALL", false, true}, --狂怒地震
        [427342] = {"防御", 2, "CC.ogg", "ALL", false, true}, --防御
        [1215412] = {"治疗吸收", 2, "CC.ogg", "ALL", false, true}, --腐蚀性粘液
        [465120] = {"准备锁定", 2, "CC.ogg", "ALL", true, true}, --上发条施法
        [465127] = {"锁定", 2, "", "ALL", true, true}, --上发条引导
        [341969] = {"AoE", 0, "", "ALL", false, true}, --枯萎排放
        [471733] = {"治疗", 0, "", "ALL", false, true}, --恢复性藻类
        [1214780] = {"AoE", 0, "Kick.ogg", "ALL", false, true}, --最大扭曲
    },
    timers = {
        --Cinderbrew Meadery
        ["214697"] = {[463206] = {"SPELL_CAST_START", 1, "ALL", "击退预警", 8.1, 18.1}}, --Tenderize
        ["210269"] = {[463218] = {"SPELL_CAST_START", 1, "ALL", "DOT预警", 8.5, 24.2}}, --Volatile Keg
        ["223423"] = {[448619] = {"SPELL_CAST_START", 1, "ALL", "冲锋预警", 9.1, 30.3}}, --Reckless Delivery
        ["220946"] = {[442995] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 10.3, 23}}, --Swarming Surprise
        ["220141"] = {[440687] = {"SPELL_CAST_START", 6, "ALL", "准备躲避", 5.9, 25.4}}, --Honey Volley
        --Darkflame Cleft
        ["211121"] = {[428066] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 9.8, 23.4}}, --Overpowering Roar
        ["233152"] = {[430171] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 5.3, 18.2}}, --Quenching Blast
        ["208450"] = {[430171] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 5.3, 18.2}}, --Quenching Blast
        ["212411"] = {[1218117] = {"SPELL_CAST_START", 1, "ALL", "击退预警", 4.9, 18.2}}, --Massive Stomp
        --The Rookery
        ["209801"] = {[426893] = {"SPELL_CAST_START", 2, "ALL", "准备躲避", 6, 13.3}}, --Bounding Void
        ["212786"] = {[427404] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 15.4, 23}}, --Localized Storm
        ["214421"] = {[430812] = {"SPELL_CAST_START", 0, "ALL", "DOT预警", 5.2, 21.8}}, --Attracting Shadows
        ["212793"] = {[1214523] = {"SPELL_CAST_START", 1, "ALL", "DOT预警", 5.2, 24.2}}, --Feasting Void
        --Priory of the Scared Flame
        ["206696"] = {[427609] = {"SPELL_CAST_START", 1, "ALL", "准备打断", 20.4, 23}}, --Disrupting Shout
        ["212826"] = {
            [448485] = {"SPELL_CAST_START", 4, "TANK", "准备减伤", 5.9, 12.1}, --Shield Slam
            [448492] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 14.7, 15.7}, --Thunderclap
        },
        ["212831"] = {[427897] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 10.8, 18.2}}, --Heat Wave
        ["239833"] = {[424431] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 26.1, 37.6}}, --Holy Radiance
        ["206704"] = {[448791] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 15.5, 21.7}}, --Sacred Toll
        --Floodgate
        ["230748"] = {[465827] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 6.8, 19.4}}, --Warp Blood
        ["231197"] = {
            [469818] = {"SPELL_CAST_START", 2, "ALL", "准备引导", 4.5, 21.8} , --Bubble Burp
            [469721] = {"SPELL_CAST_START", 1, "ALL", "DOT预警", 15.5, 21.8} , --Backwash
        },
        --Mechagon
        ["144293"] = {[1215409] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 6.8, 25.4}}, --Mega Drill
        ["144298"] = {[297128] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 16.7, 27.9}}, --Short Out
        ["151476"] = {[295169] = {"SPELL_CAST_START", 0, "ALL", "准备躲避", 16.7, 27.9}}, --Capacitor Discharge
        ["144299"] = {[293683] = {"SPELL_CAST_SUCCESS", 5, "ALL", "准备护盾", 9.7, 21.9}}, --Shield Generator
        --Motherlode
        ["136139"] = {
            [263628] = {"SPELL_CAST_START", 4, "TANK", "准备减伤", 16.5, 27}, --Charged Shield
            [472041] = {"SPELL_CAST_START", 5, "ALL", "准备引导", 8.5, 19.4}, --Tear Gas
        },
        ["130485"] = {
            [263628] = {"SPELL_CAST_START", 4, "TANK", "准备减伤", 16.5, 27}, --Charged Shield
            [472041] = {"SPELL_CAST_START", 5, "ALL", "准备引导", 8.5, 19.4}, --Tear Gas
        },
        ["134232"] = {[267354] = {"SPELL_CAST_SUCCESS", 0, "ALL", "准备躲避", 13, 20.6}}, --Fan of Knives
        ["136643"] = {[473168] = {"SPELL_CAST_START", 0, "ALL", "准备跳舞", 15.5, 26.7}}, --Rapid Extraction
        ["133430"] = {[473304] = {"SPELL_CAST_START", 2, "ALL", "准备扔道具", 7.9, 23}}, --Brainstorm
        ["133463"] = {[269429] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 7.4, 18.2}}, --Charged Shot
        --Theater of Pain
        ["170850"] = {[333241] = {"SPELL_CAST_START", 1, "ALL", "AOE预警", 7.2, 18.2}}, --Raging Tantrum
        ["167998"] = {
            [330716] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 9.4, 27.1}, --Soulstorm
            [330725] = {"SPELL_CAST_SUCCESS", 2, "ALL", "准备诅咒", 3.6, 18.2}, --Shadow Vulnerability
        },
        ["163086"] = {[330614] = {"SPELL_CAST_START", 2, "ALL", "准备躲避", 7, 15.7}}, --Vile Eruption
        ["169927"] = {[330586] = {"SPELL_CAST_START", 4, "TANK", "准备减伤", 0.1, 26.7}}, --Devour Flesh
        ["162744"] = {[342135] = {"SPELL_CAST_START", 1, "ALL", "准备打断", 10.4, 17.9}}, --Interrupting Roar
        ["167532"] = {[342135] = {"SPELL_CAST_START", 1, "ALL", "准备打断", 2.4, 17.9}}, --Interrupting Roar
        ["167538"] = {[1215850] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 10.4, 13.2}}, --Earthcrusher
        ["167533"] = {[333827] = {"SPELL_CAST_START", 0, "ALL", "AOE预警", 2.1, 9.7}}, --Seismic Stomp
        ["169893"] = {[333299] = {"SPELL_CAST_SUCCESS", 2, "ALL", "准备诅咒", 6.9, 12.1}}, --Curse of Desolation
    },
    private_auras = {

    },
    tank = {
        [432229] = {"击退", 4, true, "小心击退.ogg"}, --Keg Smash
        [439031] = {"击退", 4, true, "小心击退.ogg"}, --Bottoms Uppercut
        [436592] = {"击退", 4, true, "小心击退.ogg"}, --Cash Cannon
        [422245] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Rock Buster
        [445457] = {"注意头前", 4, true, "注意头前.ogg"}, --Oblivion Wave
        [448485] = {"击退", 4, true, "小心击退.ogg"}, --Shield Slam
        [448515] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Divine Judgement
        [424414] = {"流血", 4, true, "注意流血.ogg"}, --Pierce Armor
        [435165] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Blazing Strike
        [471585] = {"注意带位置", 4, true, "注意带位置.ogg"}, --Mobilizing Mechadrones
        [473351] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Electrocrush
        [469478] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Sludge Claws
        [465666] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Sparkslam
        [466190] = {"击退", 4, true, "小心击退.ogg"}, --Thunder Punch
        [1215065] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Platinum Pummel
        [1215411] = {"流血", 4, true, "注意流血.ogg"}, --Puncture
        [291878] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Pulse Blast
        [263628] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Charged Shield
        [320069] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Mortal Strike
        [474087] = {"注意头前", 4, true, "注意头前.ogg"}, --Necrotic Eruption
        [330586] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Devour Flesh
        [323515] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Hateful Strike
        [324079] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Reaping Scythe
        [331316] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --Savage Flurry
        [459799] = {"击退", 4, true, "小心击退.ogg"}, --Wallop
        [331288] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --粉碎者赫文
        [443487] = {"注意减伤", 4, true, "坦克承伤.ogg"}, --绝命之刺
    },
}