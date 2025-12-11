if not (C_Seasons and C_Seasons.GetActiveSeason() == 2) then return; end 
---@diagnostic disable: deprecated
local appName, _ = ...;
local flt,prof,r,x=_.CreateFilter,_.CreateProfession,_.CreateRecipe,_.CreateExpansion;
_.Categories.Unsorted={x(1,{flt(200,{prof(171,{r(17632,{b=1,itemID=13517,q=1,requireSkill=171})})})}),x(10,{flt(200,{prof(164,{r(427061,{b=1,itemID=210779,q=2,requireSkill=164})}),prof(202,{r(431362,{b=1,itemID=212230,q=3,requireSkill=202})}),prof(165,{r(439105,{itemID=217260,q=2,requireSkill=165}),r(439108,{itemID=217262,q=2,requireSkill=165}),r(439110,{itemID=217264,q=2,requireSkill=165}),r(439112,{itemID=217266,q=3,requireSkill=165}),r(439118,{itemID=217271,q=1,requireSkill=165})}),prof(171,{r(439960,{b=1,itemID=217399,q=2,requireSkill=171})}),prof(333,{r(448624,{itemID=223163,q=2,requireSkill=333})})})}),x(11,{flt(200,{prof(165,{r(1226689,{itemID=238925,lvl={60},requireSkill=165}),r(1226690,{itemID=238926,lvl={60},requireSkill=165})})})})};
