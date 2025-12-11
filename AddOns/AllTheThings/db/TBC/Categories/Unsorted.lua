---@diagnostic disable: deprecated
local appName, _ = ...;
local flt,prof,r,s=_.CreateFilter,_.CreateProfession,_.CreateRecipe,_.CreateItemSource;
_.Categories.Unsorted={flt(4,{s(133747,23349,{f=4,q=1}),s(133868,23472,{f=4,q=1})}),flt(200,{prof(202,{r(30349,{b=1,itemID=23817,q=1,requireSkill=202})})})};
