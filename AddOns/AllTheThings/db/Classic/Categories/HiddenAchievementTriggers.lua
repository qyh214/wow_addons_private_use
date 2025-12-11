if not (not C_Seasons or C_Seasons.GetActiveSeason() ~= 2) then return; end 
---@diagnostic disable: deprecated
local appName, _ = ...;
local ach,x=_.CreateAchievement,_.CreateExpansion;
_.Categories.HiddenAchievementTriggers={x(1,{ach(15329),ach(15578)})};
