local L = LibStub("AceLocale-3.0"):NewLocale("Details_DeathGraphs", "zhCN") 
if not L then return end 

L["STRING_BRESS"] = "战斗复活"
L["STRING_DEATH_DESC"] = "显示玩家死亡记录"
L["STRING_DEATHS"] = "死亡"
L["STRING_ENCOUNTER_MAXSEGMENTS"] = "当前战斗最大分段"
L["STRING_ENCOUNTER_MAXSEGMENTS_DESC"] = "'当前战斗'所能显示的最大分段数。"
L["STRING_ENDURANCE"] = "生存值"
L["STRING_ENDURANCE_DEATHS_THRESHOLD"] = "生存值的死亡阀值"
L["STRING_ENDURANCE_DEATHS_THRESHOLD_DESC"] = "第一个死亡的 |cFFFFFF00X|r 玩家会损失生存值百分比。"
L["STRING_ENDURANCE_DESC"] = [=[生存值是概念性分数，其目标是告诉在团队战斗中谁更能生存。

生存值的百分比计算只考虑首次死亡 (可以在'|cFFFFDD00设置死亡限制|r下配置')。]=]
L["STRING_FLAWLESS"] = "|cFF44FF44完美无瑕的玩家！|r"
L["STRING_HEROIC"] = "英雄"
L["STRING_HEROIC_DESC"] = "当您在英雄难度时记录死亡。"
L["STRING_LATEST"] = "最近"
L["STRING_MYTHIC"] = "史诗"
L["STRING_MYTHIC_DESC"] = "当您在史诗难度时记录死亡。"
L["STRING_NORMAL"] = "普通"
L["STRING_NORMAL_DESC"] = "当您在普通难度时记录死亡。"
L["STRING_OPTIONS"] = "选项"
L["STRING_OVERALL_DEATHS_THRESHOLD"] = "全部死亡阈值"
L["STRING_OVERALL_DEATHS_THRESHOLD_DESC"] = "第一个死亡的 |cFFFFFF00X|r 玩家死亡记录会被记录在总死亡人数中。"
L["STRING_OVERTIME"] = "超时"
L["STRING_PLUGIN_DESC"] = [=[在首领战斗期间，捕获团队成员死亡信息，并从中建立统计数据。

- |cFFFFFFFF当前战斗|r: |cFFFF9900显示最近分段的死亡人数

- |cFFFFFFFF时间轴|r: |cFFFF9900显示一个图表，告诉团队成员何时受到来自BOSS的debuff和技能是什么时候在团队成员身上施放并画线标记死亡的时间轴。

- |cFFFFFFFF生存值|r: |cFFFF9900显示玩家列表，并用百分比表示他们在BOSS战中的存活时间。

- |cFFFFFFFF全部|r: |cFFFF9900显示玩家的死亡列表以及死亡前受到的技能伤害。]=]
L["STRING_PLUGIN_NAME"] = "高级死亡日志"
L["STRING_PLUGIN_WELCOME"] = [=[欢迎访问高级死亡日志!


-|cFFFFFF00当前战斗|r: 显示上一次BOSS战的死亡记录，在默认情况会保存最近2次的死亡记录，您可以在选项界面修改保存次数。

- |cFFFFFF00时间轴|r: 显示您的团队什么时候死亡最多，同时也显示敌人技能的时间。

- |cFFFFFF00生存值|r: 根据BOSS战中最先死亡的玩家中了什么技能，默认情况下前5名死亡的玩家会损失生存值百分比。

- |cFFFFFF00全部|r: 显示玩家死亡记录以及死亡前受到的技能总伤害。


- 你可以随时右键点击关闭窗口!]=]
L["STRING_RAIDFINDER"] = "随机团队"
L["STRING_RAIDFINDER_DESC"] = "当您在随机团队难度时记录死亡。"
L["STRING_RESET"] = "重置数据"
L["STRING_SURVIVAL"] = "存活"
L["STRING_TIMELINE_DEATHS_THRESHOLD"] = "死亡阈值时间轴"
L["STRING_TIMELINE_DEATHS_THRESHOLD_DESC"] = "第一个 |cFFFFFF00X|r 死亡的玩家显示在时间轴图表中。"
L["STRING_TOOLTIP"] = "显示死亡图表"

