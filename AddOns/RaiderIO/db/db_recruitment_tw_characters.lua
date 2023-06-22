--
-- Copyright (c) 2023 by Ludicrous Speed, LLC
-- All rights reserved.
--
local provider={name=...,data=3,region="tw",date="2023-06-21T21:02:58Z",numCharacters=30752,db={}}
local F

F = function() provider.db["阿薩斯"]={0,"惡魔腳毛","漆黑腳毛","蜜雪","黑龍腳毛"} end F()
F = function() provider.db["世界之樹"]={8,"Paoda","菜菜子","阿提米斯"} end F()
F = function() provider.db["亞雷戈斯"]={14,"穢邪路路"} end F()
F = function() provider.db["冰霜之刺"]={16,"七轟"} end F()
F = function() provider.db["聖光之願"]={18,"永遠沒事做"} end F()
F = function() provider.db["日落沼澤"]={20,"冰火雙重天","十一顆","咖哩咖哩幽默","咖哩小尾巴","小壞","我爱看烟花","旅行包","晴朗","灵犀","無尾熊之星","肉嘟嘟胖呼呼","花殤紫幽幽","阿戦","阿莱克斯莉萨","非正义的圣光"} end F()
F = function() provider.db["暗影之月"]={50,"Nazhock","Worchief","巨獸斬","狼魅妹"} end F()
F = function() provider.db["水晶之刺"]={58,"潘鳳"} end F()

F = nil
RaiderIO.AddProvider(provider)
