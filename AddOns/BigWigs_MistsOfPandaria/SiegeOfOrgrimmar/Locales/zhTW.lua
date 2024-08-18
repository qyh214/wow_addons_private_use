local L = BigWigs:NewBossLocale("The Fallen Protectors", "zhTW")
if not L then return end
if L then
L["defile_you"] = "自身腳下褻瀆之地"
L["defile_you_desc"] = "當你腳下褻瀆之地時發出警報。"
L["inferno_self"] = "自身煉獄之擊"
L["inferno_self_bar"] = ">你< 爆炸！"
L["inferno_self_desc"] = "當你受到煉獄之擊時顯示特殊冷卻計時條。"
L["intermission_desc"] = "當首領使用絕處求生時發出警報。"
L["no_meditative_field"] = ">你< 不在保護罩！"

	L.custom_off_bane_marks = "暗言術:禍 標記"
	L.custom_off_bane_marks_desc = "幫助驅散分配，給最初受到暗言術:禍的玩家使用{rt1}{rt2}{rt3}{rt4}{rt5}進行標記 (依照此順序標記，不代表所有都會用到)，需要權限。"
end

L = BigWigs:NewBossLocale("Norushen", "zhTW")
if L then
L["big_add"] = "大型增援（%d）"
L["big_add_killed"] = "已擊殺大型增援（%d）"
L["big_adds"] = "大型增援"
L["big_adds_desc"] = "當大型增援出現和被擊殺時發出警報。"
L["warmup_trigger"] = "很好，我會創造一個力場隔離你們的腐化。"
end

L = BigWigs:NewBossLocale("Sha of Pride", "zhTW")
if L then
L["projection_green_arrow"] = "綠箭頭"
L["titan_pride"] = "泰坦+傲：%s"

	L.custom_off_titan_mark = "泰坦之賜標記"
	L.custom_off_titan_mark_desc = "將受到泰坦之賜的玩家使用{rt1}{rt2}{rt3}{rt4}{rt5}{rt6}標記，需要權限。\n|cFFFF0000團隊中只能有一個玩家啟用此選項以避免標記衝突。|r"

	L.custom_off_fragment_mark = "Corrupted Fragment marker"
	L.custom_off_fragment_mark_desc = "Mark the Corrupted Fragments with {rt8}{rt7}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
end

L = BigWigs:NewBossLocale("Galakras", "zhTW")
if L then
L["adds_desc"] = "當新一波增援進入戰鬥時發出警報。"
L["demolisher_message"] = "石毀車"
L["drakes"] = "元龍"
L["north_tower"] = "北塔"
L["north_tower_trigger"] = "封鎖北塔的門已經遭到破壞!"
L["south_tower"] = "南塔"
L["south_tower_trigger"] = "封鎖南塔的門已經遭到破壞!"
L["start_trigger_alliance"] = "做得好!登陸小隊，集合!步兵打前鋒!"
L["start_trigger_horde"] = "很好，第一梯隊已經登陸。"
L["tower_defender"] = "防空砲塔守護者"
L["towers"] = "高塔"
L["towers_desc"] = "當高塔被突破時發出警報"
L["warlord_zaela"] = "督軍札伊拉"

	L.custom_off_shaman_marker = "薩滿標記"
	L.custom_off_shaman_marker_desc = "To help interrupt assignments, mark the Dragonmaw Tidal Shamans with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the shamans is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Iron Juggernaut", "zhTW")
if L then
	L.custom_off_mine_marks = "Mine marker"
	L.custom_off_mine_marks_desc = "To help soaking assignments, mark the Crawler Mines with {rt1}{rt2}{rt3}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over all the mines is the fastest way to mark them.|r"
end

L = BigWigs:NewBossLocale("Kor'kron Dark Shaman", "zhTW")
if L then
L["blobs"] = "腐敗的軟泥怪"

	L.custom_off_mist_marks = "Toxic Mist marker"
	L.custom_off_mist_marks_desc = "To help healing assignments, mark the people who have Toxic Mist on them with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
end

L = BigWigs:NewBossLocale("General Nazgrim", "zhTW")
if L then
	L.custom_off_bonecracker_marks = "Bonecracker marker"
	L.custom_off_bonecracker_marks_desc = "To help healing assignments, mark the people who have Bonecracker on them with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"

	L.stance_bar = "%s(現在:%s)"
	L.battle = "戰鬥"
	L.berserker = "狂暴"
	L.defensive = "防禦"

	L.adds_trigger1 = "守住大門!"
	L.adds_trigger2 = "重整部隊!"
	L.adds_trigger3 = "下一隊，來前線!"
	L.adds_trigger4 = "戰士們，快點過來!"
	L.adds_trigger5 = "柯爾克隆，來我身邊!"
	L.adds_trigger_extra_wave = "所有科爾克隆...聽我號令...殺死他們!"
	L.extra_adds = "額外增援部隊"
	L.final_wave = "最後一波"
	L.add_wave = "%s (%s): %s"

	L.chain_heal_message = "你的專注目標正在施放治療鍊！"

	L.arcane_shock_message = "Your focus is casting Arcane Shock!"
end

L = BigWigs:NewBossLocale("Malkorok", "zhTW")
if L then
	L.custom_off_energy_marks = "Displaced Energy marker"
	L.custom_off_energy_marks_desc = "To help dispelling assignments, mark the people who have Displaced Energy on them with {rt1}{rt2}{rt3}{rt4}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
end

L = BigWigs:NewBossLocale("Spoils of Pandaria", "zhTW")
if L then
L["enable_zone"] = "文物倉庫"
L["start_trigger"] = "我們在錄音嗎?有嗎?好。哥布林-泰坦控制模組開始運作，請後退。"
L["win_trigger"] = "系統重置中。請勿關閉電源，否則可能會爆炸。"

	--L.crates = "Crates"
	--L.crates_desc = "Messages for how much power you still need and how many large/medium/small crates it will take."
	--L.full_power = "Full Power!"
	--L.power_left = "%d left! (%d/%d/%d)"
end

L = BigWigs:NewBossLocale("Thok the Bloodthirsty", "zhTW")
if L then
L["adds_desc"] = "當雪人或蝙蝠進入戰鬥時發出警報。"
L["cage_opened"] = "籠子已打開"
L["npc_akolik"] = "阿葛里克"
L["npc_waterspeaker_gorai"] = "水語者郭萊"
end

L = BigWigs:NewBossLocale("Siegecrafter Blackfuse", "zhTW")
if L then
L["assembly_line_items"] = "物品 (%d): %s"
L["assembly_line_message"] = "未組裝的武器"
L["assembly_line_trigger"] = "尚未完成的武器開始從生產線上掉落。"
L["disabled"] = "已停用"
L["item_deathdealer"] = "亡賈砲台"
L["item_laser"] = "雷射"
L["item_magnet"] = "磁鐵"
L["item_mines"] = "地雷"
L["item_missile"] = "飛彈"
L["laser_on_you"] = "雷射正在追＞你＜！"
L["overcharged_crawler_mine"] = "超載的爬行者地雷"
L["shockwave_missile_trigger"] = "來看看全新的ST-03衝擊波飛彈砲台！"
L["shredder_engage_trigger"] = "有個自動化伐木機靠近了!"

	L.custom_off_mine_marker = "地雷標記"
	--L.custom_off_mine_marker_desc = "Mark the mines for specific stun assignments. (All the marks are used)"
end

L = BigWigs:NewBossLocale("Paragons of the Klaxxi", "zhTW")
if L then
	L.catalyst_match = "催化劑: |c%s引爆你|r" -- might not be best for colorblind?
	L.you_ate = "You ate a Parasite (%d left)"
	L.other_ate = "%s ate a %sParasite (%d left)"
	L.parasites_up = "%d |4Parasite:Parasites; up"
	L.dance = "%s, 跳舞"
	L.prey_message = "Use Prey on parasite"
	L.injection_over_soon = "注射即將結束: (%s)!"

	L.one = "一"
	L.two = "二"
	L.three = "三"
	L.four = "四"
	L.five = "五"

	L.custom_off_edge_marks = "Edge marks"
	L.custom_off_edge_marks_desc = "Mark the players who will be edges based on the calculations {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}{rt8}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.edge_message = "You are an edge!"

	L.custom_off_parasite_marks = "Parasite marker"
	L.custom_off_parasite_marks_desc = "Mark the parasites for crowd control and Prey assignments with {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"

	L.injection_tank = "Injection cast"
	L.injection_tank_desc = "Timer bar for when Injection is cast for his current tank."
end

L = BigWigs:NewBossLocale("Garrosh Hellscream", "zhTW")
if L then
L["bombardment"] = "轟炸"
L["bombardment_desc"] = "轟炸暴風城，地上會殘留火焰，轟炸期間可觸發鋼鐵之星。"
L["chain_heal_bar"] = "專注：治療鏈"
L["chain_heal_desc"] = "{focus}治療一個友方目標及附近友方目標40%生命值上限。"
L["chain_heal_message"] = "你的專注目標正在施放治療鏈！"
L["clump_check_desc"] = "每3秒檢查是否有玩家過於集中，集中會觸發鋼鐵之星。"
L["clump_check_warning"] = "集中警報，鋼鐵之星觸發"
L["empowered_message"] = ">%s< 強化腐化！"
L["farseer_trigger"] = "先知們，治療我們的傷口!"
L["ironstar_impact_desc"] = "鋼鏡之星衝擊的計時條"
L["ironstar_rolling"] = "鋼鐵之星衝擊! "
L["manifest_rage"] = "實體化的狂怒之煞"
L["manifest_rage_desc"] = "當地獄吼能量到達100時會唱法2秒，然後開始引導。引導期間會出現極大量狂怒之煞。風箏並帶引鋼鐵之星撞擊地獄吼可中斷唱法。"
L["phase_3_end_trigger"] = "你以為你嬴了？"

	L.custom_off_shaman_marker = "先知標記"
	--L.custom_off_shaman_marker_desc = "To help interrupt assignments, mark the Farseer Wolf Rider with {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the farseers is the fastest way to mark them.|r"

	L.custom_off_minion_marker = "亞煞拉懼的爪牙標記"
	--L.custom_off_minion_marker_desc = "To help separate Empowered Whirling Corruption adds, mark them with {rt1}{rt2}{rt3}{rt4}{rt5}{rt6}{rt7}, requires promoted or leader."

	--L.warmup_yell_chat_trigger1 = "It is not too late, Garrosh" -- It is not too late, Garrosh. Lay down the mantle of Warchief. We can end this here, now, with no more bloodshed."
	--L.warmup_yell_chat_trigger2 = "Do you remember nothing of Honor" -- Ha! Do you remember nothing of Honor? Of glory on the battlefield?  You who would parlay with the humans, who allowed warlocks to practice their dark magics right under our feet.  You are weak.
end

