local _L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_Argus", "koKR")

if not _L then return end

if _L then

--
-- DATA
--

--
--	READ THIS BEFORE YOU TRANSLATE !!!
--
--	DO NOT TRANSLATE THE RARE NAMES HERE UNLESS YOU HAVE A GOOD REASON!!!
--	FOR EU KEEP THE RARE PART AS IT IS. CHINA & CO MAY NEED TO ADJUST!!!
--
--	_L["Rarename_search"] must have at least 2 Elements! First is the hardfilter, >=2nd are softfilters
--	Keep the hardfilter as general as possible. If you must, set it to "".
--	These Names are only used for the Group finder!
--	Tooltip names are already localized!
--

_L["Watcher Aival"] = "감시자 에이발";
_L["Watcher Aival_search"] = { "에이발", "애이발" };
_L["Watcher Aival_note"] = "";
_L["Puscilla"] = "푸실라";
_L["Puscilla_search"] = { "푸실라", "푸실라" };
_L["Puscilla_note"] = "동굴 입구는 남동쪽입니다 - 동쪽 다리를 이용하세요.";
_L["Vrax'thul"] = "브락스툴";
_L["Vrax'thul_search"] = { "브락스툴", "브락스톨" };
_L["Vrax'thul_note"] = "";
_L["Ven'orn"] = "벤오른";
_L["Ven'orn_search"] = { "벤오른", "밴오른" };
_L["Ven'orn_note"] = "동굴 입구는 거미 지역의 66, 54.1에서 북동쪽입니다";
_L["Varga"] = "바르가";
_L["Varga_search"] = { "바르가", "바르가" };
_L["Varga_note"] = "";
_L["Lieutenant Xakaar"] = "부관 자카아르";
_L["Lieutenant Xakaar_search"] = { "자카아르", "자카아르" };
_L["Lieutenant Xakaar_note"] = "";
_L["Wrath-Lord Yarez"] = "분노군주 야레즈";
_L["Wrath-Lord Yarez_search"] = { "야레즈", "야래즈" };
_L["Wrath-Lord Yarez_note"] = "";
_L["Inquisitor Vethroz"] = "심문관 베스로즈";
_L["Inquisitor Vethroz_search"] = { "베스로즈", "배스로즈" };
_L["Inquisitor Vethroz_note"] = "";
_L["Portal to Commander Texlaz"] = "사령관 텍스라즈에게 통하는 차원문";
_L["Portal to Commander Texlaz_note"] = "";
_L["Commander Texlaz"] = "사령관 텍스라즈";
_L["Commander Texlaz_search"] = { "텍스라즈", "택스라즈" };
_L["Commander Texlaz_note"] = "함선에 오르려면 80.2, 62.3에서 차원문을 사용하세요";
_L["Admiral Rel'var"] = "제독 렐바르";
_L["Admiral Rel'var_search"] = { "렐바르", "랠바르" };
_L["Admiral Rel'var_note"] = "";
_L["All-Seer Xanarian"] = "모두를 보는 자 자나리안";
_L["All-Seer Xanarian_search"] = { "자나리안", "자나리안" };
_L["All-Seer Xanarian_note"] = "";
_L["Worldsplitter Skuul"] = "세계분열자 스쿠울";
_L["Worldsplitter Skuul_search"] = { "스쿠울", "스쿠올" };
_L["Worldsplitter Skuul_note"] = "원 주위를 비행합니다. 가끔 지면 가까이 내려옵니다. 항상 원에 있지 않습니다.";
_L["Houndmaster Kerrax"] = "사냥개조련사 케락스";
_L["Houndmaster Kerrax_search"] = { "케락스", "캐락스" };
_L["Houndmaster Kerrax_note"] = "";
_L["Void Warden Valsuran"] = "공허 감시자 발수란";
_L["Void Warden Valsuran_search"] = { "발수란", "발슈란" };
_L["Void Warden Valsuran_note"] = "";
_L["Chief Alchemist Munculus"] = "수석 연금술사 먼큘러스";
_L["Chief Alchemist Munculus_search"] = { "먼큘러스", "먼쿨러스" };
_L["Chief Alchemist Munculus_note"] = "";
_L["The Many-Faced Devourer"] = "다면의 포식자";
_L["The Many-Faced Devourer_search"] = { "다면", "포식자" };
_L["The Many-Faced Devourer_note"] = "항상 소환할 수 있습니다. 하지만 주변의 적들로부터 '포식자의 소명'을 찾고 3가지를 더 모은 후 청소부의 뼈무덤으로 돌아가면 소환할 수 있습니다.";
_L["Portal to Squadron Commander Vishax"] = "편대 사령관 비샥스에게 통하는 차원문";
_L["Portal to Squadron Commander Vishax_note"] = "먼저 불멸의 황천방랑자에게서 망가진 차원문 생성기를 찾아야 합니다. 그 후 에레다르 전쟁기술자와 지옥서약 미르미돈에게서 전도성 피복, 아크 회로, 동력 장치를 모읍니다. 망가진 차원문 생성기를 사용하면 비샥스에게 가는 차원문을 엽니다.";
_L["Squadron Commander Vishax"] = "편대 사령관 비샥스";
_L["Squadron Commander Vishax_search"] = { "편대", "비샥스", "비삭스" };
_L["Squadron Commander Vishax_note"] = "함선에 오르려면 77.2, 73.2에서 차원문을 사용하세요";
_L["Doomcaster Suprax"] = "파멸술사 수프락스";
_L["Doomcaster Suprax_search"] = { "수프", "수프락스" };
_L["Doomcaster Suprax_note"] = "소환하려면 3개의 룬 위에 한명씩 서야 합니다. 실패하면 재생성되는데 5분이 걸립니다!";
_L["Mother Rosula"] = "대모 로줄라";
_L["Mother Rosula_search"] = { "로줄라", "로쥴라" };
_L["Mother Rosula_note"] = "동굴 안에 있습니다. 동쪽 다리를 사용하세요. 동굴 내부의 임프를 처치하고 임프 고기 100개를 모으세요. 임프 고기를 사용하고 표시된 지점의 녹색 수액에 역겨운 만찬을 배치하세요.";
_L["Rezira the Seer"] = "현자 레지라";
_L["Rezira the Seer_search"] = { "현자", "레지라" };
_L["Rezira the Seer_note"] = "차원문을 열려면 감시자의 공간 공명체를 사용하세요. 모두를 보는 자 오릭스(60.2, 45.4)가 온전한 악마 눈 500개에 판매합니다.";
_L["Blistermaw"] = "물집아귀";
_L["Blistermaw_search"] = { "물집아귀", "뮬집아귀" };
_L["Blistermaw_note"] = "";
_L["Mistress Il'thendra"] = "여군주 일센드라";
_L["Mistress Il'thendra_search"] = { "일센드라", "일샌드라" };
_L["Mistress Il'thendra_note"] = "";
_L["Gar'zoth"] = "가르조스";
_L["Gar'zoth_search"] = { "가르조스", "가르조스" };
_L["Gar'zoth_note"] = "";

_L["One-of-Many"] = "오면상이";
_L["One-of-Many_note"] = "";
_L["Minixis"] = "꼬마락시스";
_L["Minixis_note"] = "";
_L["Watcher"] = "감시자";
_L["Watcher_note"] = "";
_L["Bloat"] = "팽창이";
_L["Bloat_note"] = "";
_L["Earseeker"] = "귀냠냠이";
_L["Earseeker_note"] = "";
_L["Pilfer"] = "슬쩍이";
_L["Pilfer_note"] = "";

_L["Orix the All-Seer"] = "모두를 보는 자 오릭스";
_L["Orix the All-Seer_note"] = "녹색 악마 눈을 찾으세요. 눈을 클릭하세요. 90%의 생명력을 잃고 이 지역의 모든 악마에게서 눈을 획득하세요.";

_L["Forgotten Legion Supplies"] = "잊혀진 군단 보급품";
_L["Forgotten Legion Supplies_note"] = "바위가 길을 막고 있습니다. 빛벼림 기갑전투복의 도약을 사용하여 바위를 파괴하세요.";
_L["Ancient Legion War Cache"] = "고대 군단 전쟁 보관함";
_L["Ancient Legion War Cache_note"] = "작은 동굴로 조심히 뛰어 내리세요. 글라이더가 도움이 됩니다. 빛의 심판으로 바위를 제거하세요.";
_L["Fel-Bound Chest"] = "지옥결속 상자";
_L["Fel-Bound Chest_note"] = "약간 남동쪽에서 출발하세요, 53.7, 30.9. 바위를 뛰어넘어 동굴에 도착하세요. 바위가 동굴을 막고 있습니다. 빛의 심판으로 제거하세요.";
_L["Legion Treasure Hoard"] = "군단 보물 비축물";
_L["Legion Treasure Hoard_note"] = "지옥 폭포 뒤에 있습니다. 가서 집으세요.";
_L["Timeworn Fel Chest"] = "시간에 바랜 지옥 상자";
_L["Timeworn Fel Chest_note"] = "모두를 보는 자 자나리안의 위치에서 출발하세요. 건물 왼쪽으로 달리세요. 바위를 몇 번 뛰어넘어 녹색 수액으로 둘러쌓인 상자에 도착하세요.";
_L["Missing Augari Chest"] = "사라진 아우가리 상자";
_L["Missing Augari Chest_note"] = "상자는 녹색 수액 아래에 있습니다. 비전 반향의 장막을 사용하고 상자를 여세요.";

-- 48382
_L["48382_67546980_note"] = "건물 내부";
_L["48382_67466226_note"] = "";
_L["48382_71326946_note"] = "하드록스 옆";
_L["48382_58066806_note"] = "";
_L["48382_68026624_note"] = "군단 건물 내부";
_L["48382_64506868_note"] = "외부";
_L["48382_62666823_note"] = "건물 내부";
_L["48382_60096945_note"] = "외부, 건물 뒤편";
_L["48382_62146938_note"] = "";
_L["48382_69496785_note"] = "";
_L["48382_58806467_note"] = "건물 내부";
_L["48382_57796495_note"] = "";
-- 48383
_L["48383_56903570_note"] = "";
_L["48383_57633179_note"] = "";
_L["48383_52182918_note"] = "";
_L["48383_58174021_note"] = "";
_L["48383_51863409_note"] = "";
_L["48383_55133930_note"] = "";
_L["48383_58413097_note"] = "건물 내부, 바닥";
_L["48383_53753556_note"] = "";
_L["48383_51703529_note"] = "절벽 위";
_L["48383_59853583_note"] = "";
_L["48383_58273570_note"] = "건물 내부, 일센드라 단상 입구"
-- 48384
_L["48384_60872900_note"] = "";
_L["48384_61332054_note"] = "먼큘러스 건물 내부";
_L["48384_59081942_note"] = "건물 내부";
_L["48384_64152305_note"] = "사냥개조련사 케락스 동굴 내부";
_L["48384_66621709_note"] = "임프 동굴 내부, 대모 로줄라 옆";
_L["48384_63682571_note"] = "사냥개조련사 케락스 동굴 앞";
_L["48384_61862236_note"] = "외부, 수석 연금술사 먼큘러스 옆";
_L["48384_64132738_note"] = "";
_L["48384_63522090_note"] = "케락스 동굴 반대편 끝";
-- 48385
_L["48385_50605720_note"] = "";
_L["48385_55544743_note"] = "";
_L["48385_57135124_note"] = "";
_L["48385_55915425_note"] = "";
_L["48385_48195451_note"] = "";
_L["48385_57825901_note"] = "";
-- 48387
_L["48387_69403965_note"] = "";
_L["48387_66643654_note"] = "";
_L["48387_68983342_note"] = "";
_L["48387_65522831_note"] = "다리 밑";
_L["48387_73404669_note"] = "수액을 뛰어 넘으세요";
_L["48387_67954006_note"] = "";
_L["48387_63603642_note"] = "";
_L["48387_72404207_note"] = "";
-- 48388
_L["48388_51502610_note"] = "";
_L["48388_59261743_note"] = "";
_L["48388_55921387_note"] = "";
_L["48388_55841722_note"] = "";
_L["48388_55622042_note"] = "발수란 근처, 바위 경사를 올라가세요";
_L["48388_59661398_note"] = "";
_L["48388_54102803_note"] = "에이발 단상 근처";
_L["48388_55922675_note"] = "";
-- 48389
_L["48389_64305040_note"] = "바르가 동굴 내부";
_L["48389_60254351_note"] = "";
_L["48389_65514081_note"] = "";
_L["48389_60304675_note"] = "";
_L["48389_65345192_note"] = "동굴 안 바르가 뒤쪽";
_L["48389_64114242_note"] = "바위 아래";
_L["48389_58734323_note"] = "수액에 둘러 쌓인 작은 땅";
_L["48389_62955007_note"] = "녹색 수액 주변";
_L["48389_64254720_note"] = "";
-- 48390
_L["48390_81306860_note"] = "함선 위";
_L["48390_80406152_note"] = "";
_L["48390_82566503_note"] = "함선 위";
_L["48390_73316858_note"] = "제독 렐바르 옆의 위쪽";
_L["48390_77127529_note"] = "비샥스 차원문 옆";
_L["48390_72527293_note"] = "렐바르 뒤편";
_L["48390_77255876_note"] = "경사 아래";
_L["48390_72215680_note"] = "건물 내부";
_L["48390_73277299_note"] = "렐바르 뒤편";
_L["48390_77975620_note"] = "경사를 내려간 후 절벽을 뛰어넘으세요"
_L["48390_77246412_note"] = "돌아올 때 조심하세요. 절벽 아래로 뛰어내리지 마세요!";
_L["48390_76595659_note"] = "자나리안의 건물 내부";
-- 48391
_L["48391_64135867_note"] = "벤오른 거미 동굴 내부";
_L["48391_67404790_note"] = "거미 지역, 북쪽 출구 옆의 작은 동굴 내부";
_L["48391_63615622_note"] = "벤오른 거미 동굴 내부";
_L["48391_65005049_note"] = "거미 지역 외부";
_L["48391_63035762_note"] = "벤오른 거미 동굴 내부";
_L["48391_65185507_note"] = "거미 지역으로 통하는 위쪽 입구";
_L["48391_68095075_note"] = "거미 지역의 작은 동굴 내부";
_L["48391_69815522_note"] = "거미 지역 외부";
_L["48391_71205441_note"] = "거미 지역 외부";
_L["48391_66544668_note"] = "거미 지역 북쪽의 땅이 녹색인 지역으로 나가세요. 바위를 뛰어넘으세요.";
_L["48391_65164951_note"] = "거미 지역의 작은 동굴 내부"

-- Krokuun
_L["Khazaduum"] = "카자두움";
_L["Khazaduum_search"] = { "카자두움", "카자둠" };
_L["Khazaduum_note"] = "입구는 남동쪽 50.3, 17.3입니다";
_L["Commander Sathrenael"] = "사령관 사스레나엘";
_L["Commander Sathrenael_search"] = { "사스레나엘", "사스래나엘", "사스레나앨", "사스래나앨" };
_L["Commander Sathrenael_note"] = "";
_L["Commander Endaxis"] = "사령관 엔닥시스";
_L["Commander Endaxis_search"] = { "엔닥시스", "앤닥시스" };
_L["Commander Endaxis_note"] = "";
_L["Sister Subversia"] = "자매 서브버시아";
_L["Sister Subversia_search"] = { "서브버시아", "서브버시아" };
_L["Sister Subversia_note"] = "";
_L["Siegemaster Voraan"] = "공성전문가 보라안";
_L["Siegemaster Voraan_search"] = { "보라안", "보란" };
_L["Siegemaster Voraan_note"] = "";
_L["Talestra the Vile"] = "흉측한 탈레스트라";
_L["Talestra the Vile_search"] = { "탈레스트라", "탈래스트라" };
_L["Talestra the Vile_note"] = "";
_L["Commander Vecaya"] = "사령관 베카야";
_L["Commander Vecaya_search"] = { "베카야", "배카야" };
_L["Commander Vecaya_note"] = "그녀에게 가는 길은 동쪽 42, 57.1에서 시작합니다";
_L["Vagath the Betrayed"] = "배신당한 자 바가스";
_L["Vagath the Betrayed_search"] = { "바가스", "바가스" };
_L["Vagath the Betrayed_note"] = "";
_L["Tereck the Selector"] = "선택자 테렉";
_L["Tereck the Selector_search"] = { "테렉", "태랙", "테랙", "태렉" };
_L["Tereck the Selector_note"] = "";
_L["Tar Spitter"] = "타르 살포자";
_L["Tar Spitter_search"] = { "타르", "살포자" };
_L["Tar Spitter_note"] = "";
_L["Imp Mother Laglath"] = "임프 어미 라글라스";
_L["Imp Mother Laglath_search"] = { "라글라스", "라글라스" };
_L["Imp Mother Laglath_note"] = "";
_L["Naroua"] = "나로우아";
_L["Naroua_search"] = { "나로우아", "나로우아" };
_L["Naroua_note"] = "";

_L["Baneglow"] = "파멸야광이";
_L["Baneglow_note"] = "";
_L["Foulclaw"] = "썩은발톱이";
_L["Foulclaw_note"] = "";
_L["Ruinhoof"] = "폐허발굽";
_L["Ruinhoof_note"] = "";
_L["Deathscreech"] = "죽음끽끽이";
_L["Deathscreech_note"] = "";
_L["Gnasher"] = "뾰족니";
_L["Gnasher_note"] = "";
_L["Retch"] = "게우미";
_L["Retch_note"] = "";

-- Shoot First, Loot Later
_L["Krokul Emergency Cache"] = "크로쿨 비상 보관함";
_L["Krokul Emergency Cache_note"] = "동굴은 절벽 위에 있습니다. 바위가 길을 막고 있습니다. 빛벼림 기갑전투복의 도약 능력을 사용하여 바위를 파괴하세요.";
_L["Legion Tower Chest"] = "군단 탑 상자";
_L["Legion Tower Chest_note"] = "나로우아에게 가는 길에 이 상자로 가는 길을 바위가 막고 있습니다. 빛의 심판으로 제거하세요.";
_L["Lost Krokul Chest"] = "잃어버린 크로쿨 상자";
_L["Lost Krokul Chest_note"] = "길 위의 작은 동굴 안에 있습니다. 빛의 심판을 사용하여 바위를 제거하세요.";
_L["Long-Lost Augari Treasure"] = "오래 전 사라진 아우가리 보물";
_L["Long-Lost Augari Treasure_note"] = "비전 반향의 장막을 사용하고 상자를 여세요.";
_L["Precious Augari Keepsakes"] = "귀중한 아우가리 유품";
_L["Precious Augari Keepsakes_note"] = "비전 반향의 장막을 사용하고 상자를 여세요.";

-- 47752
_L["47752_55555863_note"] = "바위 위로 점프하세요, 약간 서쪽에서 출발하세요";
_L["47752_52185431_note"] = "알레리아를 처음 봤던 곳까지 길을 따라 올라가세요";
_L["47752_50405122_note"] = "알레리아를 처음 봤던 곳까지 길을 따라 올라가세요";
_L["47752_53265096_note"] = "알레리아를 처음 봤던 곳까지 길을 따라 올라가세요. 녹색 수액의 반대편에 있습니다. 지옥 용암이 뜨겁습니다!";
_L["47752_57005472_note"] = "돌출된 바위 아래, 좁은 땅의 가장자리에 있습니다";
_L["47752_59695196_note"] = "제스탈 근처, 바위의 뒤편에 있습니다.";
_L["47752_51425958_note"] = "";
_L["47752_55525237_note"] = "지역의 하층부에 있습니다. 녹색 수액을 뛰어넘어야 합니다. 찾기 어려운 상자입니다. 제스탈 위치에서 출발하세요.";
_L["47752_58375051_note"] = "";
-- 47753
_L["47753_53137304_note"] = "";
_L["47753_55228114_note"] = "";
_L["47753_59267341_note"] = "";
_L["47753_56118037_note"] = "탈레스트라 건물 외부";
_L["47753_58597958_note"] = "악마 가시 뒤편";
_L["47753_58197157_note"] = "";
_L["47753_52737591_note"] = "바위 뒤편";
_L["47753_58048036_note"] = "";
_L["47753_60297610_note"] = "";
_L["47753_56827212_note"] = "";
-- 47997
_L["47997_45876777_note"] = "다리 옆, 바위 아래";
_L["47997_45797753_note"] = "";
_L["47997_43858139_note"] = "49.1, 69.3에서 길이 시작합니다. 상자에 도착할 때까지 능선을 따라 남쪽으로 가세요.";
_L["47997_43816689_note"] = "바위 아래 있습니다. 다시 근처 길에서 아래로 뛰어내리세요.";
_L["47997_40687531_note"] = "";
_L["47997_46996831_note"] = "뱀 해골의 위에 있습니다";
_L["47997_41438003_note"] = "파괴된 군단 함선까지 바위를 올라가세요";
_L["47997_41548379_note"] = "";
_L["47997_46458665_note"] = "이 상자에 도달하려면 바위를 뛰어넘으세요.";
_L["47997_40357414_note"] = "";
_L["47997_44198653_note"] = "";
_L["47997_46787984_note"] = "";
_L["47997_42737546_note"] = "";
-- 47999
_L["47999_62592581_note"] = "";
_L["47999_59763951_note"] = "";
_L["47999_59071884_note"] = "위쪽, 바위 뒤편";
_L["47999_61643520_note"] = "";
_L["47999_61463580_note"] = "건물 내부";
_L["47999_59603052_note"] = "다리 위";
_L["47999_60891852_note"] = "바가스 뒤의 오두막 내부";
_L["47999_49063350_note"] = "";
_L["47999_65992286_note"] = "";
_L["47999_64632319_note"] = "건물 내부";
_L["47999_51533583_note"] = "작은 수액 호수 너머 건물 외부";
_L["47999_60422354_note"] = "";
_L["47999_62763812_note"] = "건물 내부";
_L["47999_60492781_note"] = "";
_L["47999_46768337_note"] = "";
_L["47999_59433273_note"] = "절벽 위";
_L["47999_58442866_note"] = "건물 내부";
_L["47999_48613092_note"] = "";
_L["47999_57642617_note"] = "절벽 위";
-- 48000
_L["48000_70907370_note"] = "";
_L["48000_74136790_note"] = "";
_L["48000_75166435_note"] = "동굴의 반대편 끝";
_L["48000_69605772_note"] = "";
_L["48000_69787836_note"] = "옆에 있는 경사를 뛰어오르세요";
_L["48000_68566054_note"] = "선택자 테렉의 동굴 앞";
_L["48000_72896482_note"] = "";
_L["48000_71827536_note"] = "";
_L["48000_73577146_note"] = "";
_L["48000_71846166_note"] = "기울어진 기둥을 올라가세요";
_L["48000_67886231_note"] = "기둥 뒤편";
_L["48000_74996922_note"] = "";
_L["48000_62946824_note"] = "위쪽 동굴 안에 있습니다. 위쪽 동굴로 가려면 여기서 동쪽으로 바위를 타고 오르세요."
_L["48000_69386278_note"] = "";
_L["48000_67656999_note"] = "경사로를 오른 후 기울어진 기둥 너머에 상자가 있습니다.";
-- 48336
_L["48336_33575511_note"] = "제네다르 상층, 외부";
_L["48336_32047441_note"] = "";
_L["48336_27196668_note"] = "";
_L["48336_31936750_note"] = "";
_L["48336_35415637_note"] = "제네다르의 아래쪽 입구 앞의 땅";
_L["48336_29645761_note"] = "동굴 내부";
_L["48336_40526067_note"] = "노란색 오두막 내부";
_L["48336_36205543_note"] = "제네다르 내부, 상층";
_L["48336_25996814_note"] = "";
_L["48336_37176401_note"] = "부스러기 아래";
_L["48336_28247134_note"] = "";
_L["48336_30276403_note"] = "탈출선 내부";
_L["48336_34566305_note"] = "";
_L["48336_36605881_note"] = "제네다르 상층, 외부";
-- 48339
_L["48339_68533891_note"] = "";
_L["48339_63054240_note"] = "";
_L["48339_64964156_note"] = "";
_L["48339_73393438_note"] = "";
_L["48339_72213234_note"] = "거인 해골의 뒤편";
_L["48339_65983499_note"] = "";
_L["48339_64934217_note"] = "나무 줄기 내부";
_L["48339_67713454_note"] = "";
_L["48339_72493605_note"] = "";
_L["48339_44864342_note"] = "";
_L["48339_46094082_note"] = "";
_L["48339_70503063_note"] = "";
_L["48339_61876413_note"] = "";

-- Mac'Aree
_L["Shadowcaster Voruun"] = "흑마술사 보룬";
_L["Shadowcaster Voruun_search"] = { "보룬", "보룬" };
_L["Shadowcaster Voruun_note"] = "5분 재생성 타이머!";
_L["Soultwisted Monstrosity"] = "영혼이 뒤틀린 흉물";
_L["Soultwisted Monstrosity_search"] = { "흉물", "흉물" };
_L["Soultwisted Monstrosity_note"] = "";
_L["Wrangler Kravos"] = "사냥꾼 크라보스";
_L["Wrangler Kravos_search"] = { "크라보스", "크라보스" };
_L["Wrangler Kravos_note"] = "";
_L["Kaara the Pale"] = "창백한 카아라";
_L["Kaara the Pale_search"] = { "카아라", "카이라" };
_L["Kaara the Pale_note"] = "";
_L["Feasel the Muffin Thief"] = "머핀 도둑 피즐";
_L["Feasel the Muffin Thief_search"] = { "피즐", "머핀", "피줄" };
_L["Feasel the Muffin Thief_note"] = "잠복 차단하세요";
_L["Vigilant Thanos"] = "감시자 타노스";
_L["Vigilant Thanos_search"] = { "타노스", "타노스" };
_L["Vigilant Thanos_note"] = "";
_L["Vigilant Kuro"] = "감시자 쿠로";
_L["Vigilant Kuro_search"] = { "쿠로", "쿠로" };
_L["Vigilant Kuro_note"] = "";
_L["Venomtail Skyfin"] = "맹독꼬리 하늘지느러미";
_L["Venomtail Skyfin_search"] = { "하늘지느러미", "맹독꼬리" };
_L["Venomtail Skyfin_note"] = "";
_L["Turek the Lucid"] = "또렷한 의식의 투레크";
_L["Turek the Lucid_search"] = { "투레크", "투래크" };
_L["Turek the Lucid_note"] = "건물 안의 계단을 내려가세요";
_L["Captain Faruq"] = "대장 파루크";
_L["Captain Faruq_search"] = { "파루크", "파루크" };
_L["Captain Faruq_note"] = "";
_L["Umbraliss"] = "엄브랄리스";
_L["Umbraliss_search"] = { "엄브랄리스", "엄브랄리스" };
_L["Umbraliss_note"] = "";
_L["Sorolis the Ill-Fated"] = "비운의 소롤리스";
_L["Sorolis the Ill-Fated_search"] = { "소롤리스", "소룰리스" };
_L["Sorolis the Ill-Fated_note"] = "";
_L["Herald of Chaos"] = "혼돈의 전령";
_L["Herald of Chaos_search"] = { "혼돈", "전령" };
_L["Herald of Chaos_note"] = "2층에 있습니다.";
_L["Sabuul"] = "사부울";
_L["Sabuul_search"] = { "사부울", "사부울", "사불" };
_L["Sabuul_note"] = "";
_L["Jed'hin Champion Vorusk"] = "제드힌 우승자 보루스크";
_L["Jed'hin Champion Vorusk_search"] = { "보루스크", "제드힌" };
_L["Jed'hin Champion Vorusk_note"] = "";
_L["Overseer Y'Beda"] = "감독관 이베다";
_L["Overseer Y'Beda_search"] = { "이베다", "이배다" };
_L["Overseer Y'Beda_note"] = "";
_L["Overseer Y'Sorna"] = "감독관 이소르나";
_L["Overseer Y'Sorna_search"] = { "이소르나", "이소르나" };
_L["Overseer Y'Sorna_note"] = "";
_L["Overseer Y'Morna"] = "감독관 이모르나";
_L["Overseer Y'Morna_search"] = { "이모르나", "이모르나" };
_L["Overseer Y'Morna_note"] = "";
_L["Instructor Tarahna"] = "교관 타라흐나";
_L["Instructor Tarahna_search"] = { "타라흐나", "타라흐나" };
_L["Instructor Tarahna_note"] = "";
_L["Zul'tan the Numerous"] = "다중인격의 줄탄";
_L["Zul'tan the Numerous_search"] = { "줄탄", "쥴탄" };
_L["Zul'tan the Numerous_note"] = "건물 내부";
_L["Commander Xethgar"] = "사령관 제스가";
_L["Commander Xethgar_search"] = { "제스가", "재스가" };
_L["Commander Xethgar_note"] = "";
_L["Skreeg the Devourer"] = "파멸의 스크리그";
_L["Skreeg the Devourer_search"] = { "스크리그", "스크리그" };
_L["Skreeg the Devourer_note"] = "";
_L["Baruut the Bloodthirsty"] = "피에 굶주린 바루우트";
_L["Baruut the Bloodthirsty_search"] = { "바루우트", "바루우트" };
_L["Baruut the Bloodthirsty_note"] = "";
_L["Ataxon"] = "아탁쏜";
_L["Ataxon_search"] = { "아탁쏜", "아탁손" };
_L["Ataxon_note"] = "";
_L["Slithon the Last"] = "최후의 슬리쏜";
_L["Slithon the Last_search"] = { "슬리쏜", "슬리손" };
_L["Slithon the Last_note"] = "";

_L["Gloamwing"] = "어스름펄럭이";
_L["Gloamwing_note"] = "";
_L["Bucky"] = "버키";
_L["Bucky_note"] = "";
_L["Mar'cuus"] = "마르쿠우스";
_L["Mar'cuus_note"] = "";
_L["Snozz"] = "킁킁마르술";
_L["Snozz_note"] = "";
_L["Corrupted Blood of Argus"] = "아르거스의 타락한 피";
_L["Corrupted Blood of Argus_note"] = "";
_L["Shadeflicker"] = "그림자깜빡이";
_L["Shadeflicker_note"] = "";

_L["Nabiru"] = "나비루"
_L["Nabiru_note"] = "동굴 안에 있습니다. 직업 전당 추종자를 얻으려면 연맹 자원 900을 반납하세요.";

-- Shoot First, Loot Later
_L["Eredar Treasure Cache"] = "에레다르 보물 보관함";
_L["Eredar Treasure Cache_note"] = "작은 동굴 안에 있습니다. 빛벼림 기갑전투복의 도약을 사용하여 막고 있는 바위를 제거하세요.";
_L["Chest of Ill-Gotten Gains"] = "부정한 노략물 상자";
_L["Chest of Ill-Gotten Gains_note"] = "빛의 심판을 사용하여 바위를 파괴하세요.";
_L["Student's Surprising Surplus"] = "수련생의 놀라운 불용품";
_L["Student's Surprising Surplus_note"] = "상자는 동굴 안에 있습니다. 입구는 62.2, 72.2입니다. 빛의 심판으로 바위를 파괴하세요.";
_L["Void-Tinged Chest"] = "공허에 물든 상자";
_L["Void-Tinged Chest_note"] = "지하에 있습니다. 빛벼림 기갑전투복의 도약을 사용하여 막고 있는 바위를 제거하세요.";
_L["Augari Secret Stash"] = "아우가리 비밀 보관함";
_L["Augari Secret Stash_note"] = "68.0, 56.9으로 가세요. 여기서 보관함을 볼 수 있습니다. 탈것을 타고 상자 쪽으로 점프하세요. 즉시 글라이더를 사용하여 상자에 안전하게 도착하세요.";
_L["Desperate Eredar's Cache"] = "절박한 에레다르의 보관함";
_L["Desperate Eredar's Cache_note"] = "57.1, 74.3에서 출발하여 탑 뒤편으로 뛰어오르세요.";
_L["Shattered House Chest"] = "부서진 집 상자";
_L["Shattered House Chest_note"] = "31.2, 44.9로 가세요, 여기서 약간 남동쪽입니다. 심연으로 뛰어내린 후 글라이더를 사용해 상자에 도착하세요.";
_L["Doomseeker's Treasure"] = "파멸길잡이의 보물";
_L["Doomseeker's Treasure_note"] = "보물은 지하에 있습니다. 이 곳의 동쪽은 호수의 물이 떨어지는 깊은 구멍입니다. 구멍 안으로 뛰어내린 후 올바르게 착지하세요. 탈것을 탄 상태로 뛰는 걸로 가능합니다, 하지만 상자가 있는 작은 집에 도착하는 데 고블린 글라이더가 많은 도움이 됩니다.";
_L["Augari-Runed Chest"] = "아우가리룬 상자";
_L["Augari-Runed Chest_note"] = "상자는 나무 아래에 있습니다. 비전 반향의 장막을 사용하고 상자를 여세요.";
_L["Secret Augari Chest"] = "비밀의 아우가리 상자";
_L["Secret Augari Chest_note"] = "작은 오두막 안에 있습니다. 비전 반향의 장막을 사용하고 상자를 여세요.";
_L["Augari Goods"] = "아우가리 용품";
_L["Augari Goods_note"] = "상자는 작은 집 안에 있습니다. 비전 반향의 장막을 사용하고 상자를 여세요.";
-- Ancient Eredar Cache
-- 48346
_L["48346_55167766_note"] = "";
_L["48346_59386372_note"] = "투명한 붉은색 텐트 내부" ;
_L["48346_57486159_note"] = "크라보스 옆의 건물 내부" ;
_L["48346_50836729_note"] = "";
_L["48346_52868241_note"] = "";
_L["48346_47186234_note"] = "";
_L["48346_50107580_note"] = "";
_L["48346_53328001_note"] = "지하실 내부"
_L["48346_55297347_note"] = "";
_L["48346_52696161_note"] = "";
_L["48346_54806710_note"] = "";
_L["48346_51677163_note"] = "";
_L["48346_57397517_note"] = "";
_L["48346_61047074_note"] = "나무 아래";
-- 48350
_L["48350_59622088_note"] = "건물 내부 계단 아래";
_L["48350_60493338_note"] = "건물 내부";
_L["48350_53912335_note"] = "건물 내부";
_L["48350_55063508_note"] = "";
_L["48350_62202636_note"] = "발코니에 있습니다. 건물 안으로 들어간 후 오른쪽 계단을 올라가세요.";
_L["48350_53332740_note"] = "나무 아래";
_L["48350_58574078_note"] = "";
_L["48350_63262000_note"] = "건물 내부";
_L["48350_54952484_note"] = "";
_L["48350_63332255_note"] = "붉은 오두막 내부";
-- 48351
_L["48351_43637134_note"] = "";
_L["48351_34205929_note"] = "혼돈의 전령이 있는 2층에 있습니다.";
_L["48351_43955630_note"] = "나무 아래";
_L["48351_46917346_note"] = "나무 아래 숨겨져 있습니다";
_L["48351_36296646_note"] = "";
_L["48351_42645361_note"] = "동굴 안에 있습니다. 입구는 여기서 남서쪽입니다.";
_L["48351_38126342_note"] = "투렉의 지하실 내부";
_L["48351_42395752_note"] = "건물 내부";
_L["48351_39175934_note"] = "건물 폐허 내부";
_L["48351_43555993_note"] = "나비루의 동굴 내부"
_L["48351_35535717_note"] = "2층"
_L["48351_43666847_note"] = "건물 폐허 내부";
_L["48351_38386704_note"] = "";
_L["48351_35635604_note"] = "2층";
-- 48357
_L["48357_49412387_note"] = "";
_L["48357_47672180_note"] = "";
_L["48357_48482115_note"] = "";
_L["48357_57881053_note"] = "";
_L["48357_52871676_note"] = "계단 위";
_L["48357_47841956_note"] = "";
_L["48357_51802871_note"] = "북쪽 계단을 올라가는 지역"
_L["48357_49912946_note"] = "";
_L["48357_54951750_note"] = "";
_L["48357_46381509_note"] = "";
_L["48357_50021442_note"] = "";
_L["48357_52631644_note"] = "";
_L["48357_45981325_note"] = "";
_L["48357_44571860_note"] = "";
_L["48357_53491281_note"] = "";
_L["48357_45241327_note"] = "";
_L["48357_48251289_note"] = "아래 층, 스크리그 근처";
-- 48371
_L["48371_48604971_note"] = "";
_L["48371_49865494_note"] = "";
_L["48371_47023655_note"] = "계단 위";
_L["48371_49623585_note"] = "계단 위";
_L["48371_51094790_note"] = "나무 아래";
_L["48371_35535718_note"] = "2층 혼돈의 전령 옆에 있습니다";
_L["48371_25383016_note"] = "";
_L["48371_53594211_note"] = "";
_L["48371_59405863_note"] = "";
_L["48371_19694227_note"] = "건물 내부";
_L["48371_24763858_note"] = "건물 폐허 내부";
_L["48371_50575594_note"] = "";
_L["48371_28913361_note"] = "";
_L["48371_32644686_note"] = "";
-- 48362
_L["48362_66682786_note"] = "건물 내부, 다중인격의 줄탄 옆";
_L["48362_62134077_note"] = "건물 내부";
_L["48362_67254608_note"] = "건물 내부";
_L["48362_68355322_note"] = "건물 내부";
_L["48362_65966017_note"] = "";
_L["48362_62053268_note"] = "상부 지형";
_L["48362_60964354_note"] = "건물 내부";
_L["48362_64445956_note"] = "건물 내부";
_L["48362_65354194_note"] = "";
_L["48362_63924532_note"] = "";
_L["48362_67893170_note"] = "";
_L["48362_65974679_note"] = "건물 내부";
_L["48362_68404122_note"] = "";
_L["48362_61924258_note"] = "건물 내부";
_L["48362_67235673_note"] = "건물 내부";
_L["48362_70243379_note"] = "";
_L["48362_69304993_note"] = "건물 내부, 중간 층";
-- Void-Seeped Cache / Treasure Chest
-- 49264
_L["49264_38143985_note"] = "";
_L["49264_37613608_note"] = "";
_L["49264_37812344_note"] = "";
_L["49264_33972078_note"] = "";
_L["49264_33312952_note"] = "";
_L["49264_37102005_note"] = "";
_L["49264_33592361_note"] = "나무 아래 숨겨져 있습니다"
_L["49264_31582553_note"] = "";
_L["49264_32332131_note"] = "구석에 숨겨져 있습니다";
_L["49264_35293848_note"] = "";
-- 48361
_L["48361_37664221_note"] = "동굴 안의 기둥 뒤편";
_L["48361_25824471_note"] = "";
_L["48361_20674033_note"] = "";
_L["48361_29503999_note"] = "";
_L["48361_29455043_note"] = "나무 아래";
_L["48361_18794171_note"] = "건물 뒤편 외부";
_L["48361_25293498_note"] = "";
_L["48361_35283586_note"] = "엄브랄리스 뒤편"
_L["48361_24654126_note"] = "";
_L["48361_37754868_note"] = "동굴 지역에서 아래로"
_L["48361_39174733_note"] = "동굴 지역에서 아래로";
_L["48361_28784425_note"] = "";
_L["48361_32583679_note"] = "";

--
--	KEEP THESE ENGLISH FOR THE GROUP BROWSER IN EU/US!! CHINA & CO ADJUST
--	SEARCH ARRAY AS BEFORE, MUST HAVE MINIMUM 2 ELEMENTS
--

_L["Invasion Point: Val"] = "침공 거점: 밸";
_L["Invasion Point: Aurinor"] = "침공 거점: 아우리노르";
_L["Invasion Point: Sangua"] = "침공 거점: 센구아";
_L["Invasion Point: Naigtal"] = "침공 거점: 나익탈";
_L["Invasion Point: Bonich"] = "침공 거점: 보니크";
_L["Invasion Point: Cen'gar"] = "침공 거점: 센가르";
_L["Greater Invasion Point: Mistress Alluradel"] = "상급 침공 거점: 여군주 알루라델";
_L["Greater Invasion Point: Matron Folnuna"] = "상급 침공 거점: 대모 폴누나";
_L["Greater Invasion Point: Sotanathor"] = "상급 침공 거점: 소타나토르";
_L["Greater Invasion Point: Occularus"] = "상급 침공 거점: 오큘라러스";
_L["Greater Invasion Point: Inquistor Meto"] = "상급 침공 거점: 심문관 메토";
_L["Greater Invasion Point: Pit Lord Vilemus"] = "상급 침공 거점: 지옥의 군주 바일머스";

_L["invasion_val_search"] = { "밸", "침공.*밸", "밸.*침공" };
_L["invasion_aurinor_search"] = { "아우리노르", "아우리노르" };
_L["invasion_sangua_search"] = { "센구아", "샌구아" };
_L["invasion_naigtal_search"] = { "나익탈", "나익탈" };
_L["invasion_bonich_search"] = { "보니크", "보니크" };
_L["invasion_cengar_search"] = { "센가르", "샌가르" };
_L["invasion_alluradel_search"] = { "알루라델", "알루라댈" };
_L["invasion_folnuna_search"] = { "폴", "폴누나" };
_L["invasion_sotanathor_search"] = { "소타나토르", "소타나토르" };
_L["invasion_occularus_search"] = { "오큘라러스", "오쿨라러스" };
_L["invasion_meto_search"] = { "메토", "매토" };
_L["invasion_vilemus_search"] = { "바일머스", "바일머스" };

_L["Dreadblade Annihilator"] = "공포칼날 파멸자";
_L["bsrare_dreadbladeannihilator_search"] = { "공포칼날", "파멸자" };
_L["Salethan the Broodwalker"] = "무리방랑자 살레단";
_L["bsrare_salethan_search"] = { "무리방랑자", "살레단" };
_L["Corrupted Bonebreaker"] = "타락한 뼈파괴자";
_L["bsrare_corruptedbonebreaker_search"] = { "뼈", "뼈파괴자" };
_L["Flllurlokkr"] = "플루르로크르";
_L["bsrare_flllurlokkr_search"] = { "플루르", "로크르" };
_L["Grossir"] = "그로시르";
_L["bsrare_grossir_search"] = { "그로시르", "그로시르" };
_L["Eye of Gurgh"] = "구르그의 눈";
_L["bsrare_eyeofgurgh_search"] = { "구르그", "구르그" };
_L["Somber Dawn"] = "흐릿한 여명";
_L["bsrare_somberdawn_search"] = { "흐릿", "여명" };
_L["Felcaller Zelthae"] = "지옥소환사 젤타이";
_L["bsrare_zelthae_search"] = { "지옥소환사", "젤타이" };
_L["Duke Sithizi"] = "공작 시티지";
_L["bsrare_dukesithizi_search"] = { "공작", "시티지" };
_L["Lord Hel'Nurath"] = "군주 헬누라스";
_L["bsrare_helnurath_search"] = { "헬누라스", "핼누라스" };
_L["Imp Mother Bruva"] = "임프 어미 브루바";
_L["bsrare_bruva_search"] = { "브루바", "부르바" };
_L["Potionmaster Gloop"] = "물약의 달인 글룹";
_L["bsrare_gloop_search"] = { "글룹", "글룹" };
_L["Dreadeye"] = "공포눈";
_L["bsrare_dreadeye_search"] = { "공포눈", "공포눈" };
_L["Malorus the Soulkeeper"] = "영혼지킴이 말로러스";
_L["bsrare_malorus_search"] = { "영혼지킴이", "말로러스" };
_L["Brother Badatin"] = "수사 배다틴";
_L["bsrare_badatin_search"] = { "배다틴", "베다틴" };
_L["Felbringer Xar'thok"] = "지옥소환사 자르토크";
_L["bsrare_xarthok_search"] = { "자르토크", "자르토크" };
_L["Malgrazoth"] = "말그라조스";
_L["bsrare_malgrazoth_search"] = { "말그라조스", "말그라조스" };
_L["Emberfire"] = "잿불불꽃";
_L["bsrare_emberfire_search"] = { "잿불불꽃", "잿불불꽃" };
_L["Xorogun the Flamecarver"] = "화염조각사 조로군";
_L["bsrare_xorogun_search"] = { "조로군", "조로군" };
_L["Lady Eldrathe"] = "여군주 엘드라스";
_L["bsrare_eldrathe_search"] = { "엘드라스", "앨드라스" };
_L["Aqueux"] = "아퀘욱스";
_L["bsrare_aqueux_search"] = { "아퀘욱스", "아퀘옥스" };

--
--
-- INTERFACE
--
--

_L["Argus"] = "아르거스";
_L["Antoran Wastes"] = "안토란 황무지";
_L["Krokuun"] = "크로쿠운";
_L["Mac'Aree"] = "마크아리";

_L["Shield"] = "방패";
_L["Cloth"] = "천";
_L["Leather"] = "가죽";
_L["Mail"] = "사슬";
_L["Plate"] = "판금";
_L["1h Mace"] = "한손 둔기";
_L["1h Sword"] = "한손 도검";
_L["1h Axe"] = "한손 도끼";
_L["2h Mace"] = "양손 둔기";
_L["2h Sword"] = "양손 도검";
_L["2h Axe"] = "양손 도끼";
_L["Dagger"] = "단검";
_L["Staff"] = "지팡이";
_L["Fist"] = "장착 무기";
_L["Polearm"] = "장창";
_L["Bow"] = "활";
_L["Gun"] = "총";
_L["Crossbow"] = "석궁";

_L["groupBrowserOptionOne"] = "%s - %s명 (%s)";
_L["groupBrowserOptionMore"] = "%s - %s명 (%s)";
_L["chatmsg_no_group_priv"] = "|cFFFF0000권한이 없습니다. 당신은 파티장이 아닙니다.";
_L["chatmsg_group_created"] = "|cFF6CF70F%s 파티를 만들었습니다.";
_L["chatmsg_search_failed"] = "|cFFFF0000검색 요청이 너무 많습니다, 몇 초후 다시 시도해주세요.";
_L["hour_short"] = "시간";
_L["minute_short"] = "분";
_L["second_short"] = "초";

-- KEEP THESE 2 ENGLISH IN EU/US
_L["listing_desc_rare"] = "아르거스의 희귀 몬스터 %s|1과;와; 전투를 벌입니다.";
_L["listing_desc_invasion"] = "아르거스의 %s|1을;를; 진행합니다.";

_L["Pet"] = "애완동물";
_L["(Mount known)"] = "(|cFF00FF00획득한 탈것|r)";
_L["(Mount missing)"] = "(|cFFFF0000미획득 탈것|r)";
_L["(Toy known)"] = "(|cFF00FF00획득한 장난감|r)";
_L["(Toy missing)"] = " (|cFFFF0000미획득 장난감|r)";
_L["(itemLinkGreen)"] = "(|cFF00FF00%s|r)";
_L["(itemLinkRed)"] = "(|cFFFF0000%s|r)";
_L["Retrieving data ..."] = "데이터 검색 중 ...";
_L["Sorry, no groups found!"] = "파티를 찾을 수 없습니다!";
_L["Search in Quests"] = "퀘스트에서 검색";
_L["Groups found:"] = "파티 발견:";
_L["Create new group"] = "새로운 파티 만들기";
_L["Close"] = "닫기";

_L["context_menu_title"] = "Handynotes 아르거스";
_L["context_menu_check_group_finder"] = "파티 유효성 확인";
_L["context_menu_reset_rare_counters"] = "파티 숫자 초기화";
_L["context_menu_add_tomtom"] = "이 위치를 TomTom 목표 지점에 추가";
_L["context_menu_hide_node"] = "이 노드 숨기기";
_L["context_menu_restore_hidden_nodes"] = "숨겨진 모든 노드 복원";

_L["options_title"] = "아르거스";

_L["options_icon_settings"] = "아이콘 설정";
_L["options_icon_settings_desc"] = "아이콘 설정";
_L["options_icons_treasures"] = "보물 상자 아이콘";
_L["options_icons_treasures_desc"] = "보물 상자 아이콘";
_L["options_icons_rares"] = "희귀 몬스터 아이콘";
_L["options_icons_rares_desc"] = "희귀 몬스터 아이콘";
_L["options_icons_pet_battles"] = "애완동물 대전 아이콘";
_L["options_icons_pet_battles_desc"] = "애완동물 대전 아이콘";
_L["options_icons_sfll"] = "선 탐험 후 발견 아이콘";
_L["options_icons_sfll_desc"] = "선 탐험 후 발견 아이콘";
_L["options_scale"] = "크기 비율";
_L["options_scale_desc"] = "1 = 100%";
_L["options_opacity"] = "불투명도";
_L["options_opacity_desc"] = "0 = 투명, 1 = 불투명";
_L["options_visibility_settings"] = "표시";
_L["options_visibility_settings_desc"] = "표시";
_L["options_toggle_treasures"] = "보물";
_L["options_toggle_rares"] = "희귀 몬스터";
_L["options_toggle_battle_pets"] = "애완동물 대전";
_L["options_toggle_sfll"] = "선 탐험 후 발견";
_L["options_toggle_npcs"] = "NPC";
_L["options_toggle_portals"] = "차원문";
_L["options_general_settings"] = "일반";
_L["options_general_settings_desc"] = "일반";
_L["options_toggle_alreadylooted_rares"] = "이미 획득한 희귀 몬스터";
_L["options_toggle_alreadylooted_rares_desc"] = "전리품 상태와 상관없이 모든 희귀 몬스터를 표시합니다";
_L["options_toggle_alreadylooted_treasures"] = "이미 획득한 보물";
_L["options_toggle_alreadylooted_treasures_desc"] = "전리품 상태와 상관없이 모든 보물을 표시합니다";
_L["options_toggle_alreadylooted_sfll"] = "이미 획득한 '선 탐험 후 발견' 보물";
_L["options_toggle_alreadylooted_sfll_desc"] = "전리품 상태와 상관없이 모든 업적 보물을 표시합니다";
_L["options_toggle_nodeRareGlow"] = "희귀 몬스터 아이콘 색상"
_L["options_toggle_nodeRareGlow_desc"] = "파티 유효성에 따라 희귀 몬스터 아이콘에 색상을 추가합니다. 색상 없음 = 파티 없음, 붉은색 = 낮은 유효성, 녹색 = 높은 유효성."
_L["options_tooltip_settings"] = "툴팁";
_L["options_tooltip_settings_desc"] = "툴팁";
_L["options_toggle_show_loot"] = "전리품 표시";
_L["options_toggle_show_loot_desc"] = "툴팁에 전리품 정보를 추가합니다";
_L["options_toggle_show_notes"] = "메모 표시";
_L["options_toggle_show_notes_desc"] = "메모가 있으면 툴팁에 도움이 되는 메모를 추가합니다";

_L["options_general_settings"] = "일반";
_L["options_general_settings_desc"] = "일반 설정";
_L["options_toggle_leave_group_on_search"] = "파티 떠나기";
_L["options_toggle_leave_group_on_search_desc"] = "파티 중일 때 검색을 시도하면 파티를 떠납니다. 주의해서 사용하세요!";
_L["chatmsg_old_group_delisted_create"] = "|cFFF7C92A오래된 파티가 등록 해제되었습니다. %s의 새로운 파티를 만드려면 다시 클릭해주세요."
_L["chatmsg_left_group_create"] = "|cFFF7C92A파티를 떠났습니다. %s의 새로운 파티를 만드려면 다시 클릭해주세요.";
_L["chatmsg_old_group_delisted_search"] = "|cFFF7C92A오래된 파티가 등록 해제되었습니다. %s의 파티를 검색하려면 다시 클릭해주세요."
_L["chatmsg_left_group_search"] = "|cFFF7C92A파티를 떠났습니다. %s의 파티를 검색하려면 다시 클릭해주세요.";

_L["options_toggle_include_player_seen"] = "플레이어가 발견했던 희귀 몬스터 포함";
_L["options_toggle_include_player_seen_desc"] = "아직 사용하지 마세요.";
_L["options_toggle_show_debug"] = "디버그";
_L["options_toggle_show_debug_desc"] = "디버그 기능 표시";

_L["options_toggle_hideKnowLoot"] = "모든 전리품을 배운 희귀 몬스터 숨기기";
_L["options_toggle_hideKnowLoot_desc"] = "전리품을 모두 알고 있는 모든 희귀 몬스터를 숨깁니다.";

_L["options_toggle_alwaysTrackCoA"] = "아르거스의 사령관 항상 추적";
_L["options_toggle_alwaysTrackCoA_desc"] = "업적이 계정 내에선 획득했지만 캐릭터는 획득하지 못했을 때 아르거스의 사령관을 항상 추적합니다.";
_L["Missing for CoALink"] = "%s 누락";

end
