local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "zhCN")
if not L then return end

-- Translation by: zhouf616

-- Init
L["ENH_LOGIN_MSG"] = "您正在使用 |cff1784d1ElvUI Enhanced Again|r |cffff8000|r version %s%s|r."
L["ENH_LOGIN_MSG_WRATH"] = "You are using |cff1784d1ElvUI Enhanced Again|r |cffff8000(Wrath Classic)|r version %s%s|r."
L["Your version of ElvUI is to old (required v10.52 or higher). Please, download the latest version from tukui.org."] = "您的ElvUI版本过低(需要 v6.51 或更高), 请前往tukui.org下载最新版本."

-- Equipment
L["Equipment"] = "自动换装"
L["EQUIPMENT_DESC"] = "当你切换专精或进入战场时自动更换装备, 你可以在选项中选择相关的装备模组."
L["No Change"] = "不改变"

L["Specialization"] = "专精"
L["Enable/Disable the specialization switch."] = "开启/关闭 专精切换"

L["Primary Talent"] = "主专精"
L["Choose the equipment set to use for your primary specialization."] = "选择当你使用主专精时的装备模组."

L["Secondary Talent"] = "副专精"
L["Choose the equipment set to use for your secondary specialization."] = "选择当你使用副专精时的装备模组."

L["Battleground"] = "战场"
L['Enable/Disable the battleground switch.'] = "开启/关闭 战场切换"

L["Equipment Set"] = "装备模组"
L["Choose the equipment set to use when you enter a battleground or arena."] = "选择当你进入战场时的装备模组."

L["You have equipped equipment set: "] = "你已装备此模组: "

L["DURABILITY_DESC"] = "调整设置人物窗口装备耐久度显示."
L['Enable/Disable the display of durability information on the character screen.'] = "开启/关闭 人物窗口装备耐久度显示."
L["Damaged Only"] = "受损显示"
L["Only show durabitlity information for items that are damaged."] = "只在装备受损时显示耐久度."

L["ITEMLEVEL_DESC"] = "Adjust the settings for the item level information on the character screen."
L["Enable/Disable the display of item levels on the character screen."] = true

L["Miscellaneous"] = true
L['Equipment Set Overlay'] = true
L['Show the associated equipment sets for the items in your bags (or bank).'] = true

-- Movers
L["Mover Transparency"] = true
L["Changes the transparency of all the movers."] = true

-- Automatic Role Assignment
L['Automatic Role Assignment'] = true
L['Enables the automatic role assignment based on specialization for party / raid members (only work when you are group leader or group assist).'] = true

-- Auto Hide Role Icons in combat
L['Hide Role Icon in combat'] = true
L['All role icons (Damage/Healer/Tank) on the unit frames are hidden when you go into combat.'] = true

-- GPS module
L['GPS'] = "GPS定位"
L['Show the direction and distance to the selected party or raid member.'] = "显示你与当前队伍或团队成员的方向与距离."

-- Attack Icon
L['Attack Icon'] = true
L['Show attack icon for units that are not tapped by you or your group, but still give kill credit when attacked.'] = true

-- Class Icon
L['Show class icon for units.'] = true

-- Minimap Buttons
L["Minimap Button Bar"] = "小地图按钮整合列"
L['Skin Buttons'] = "美化按钮"
L['Skins the minimap buttons in Elv UI style.'] = "将小地图图标美化成ElvUI风格."
L['Skin Style'] = "美化风格"
L['Change settings for how the minimap buttons are skinned.'] = "改变美化设定."
L['The size of the minimap buttons.'] = "小地图图标尺寸."

L['No Anchor Bar'] = "没有锚点"
L['Horizontal Anchor Bar'] = "水平状"
L['Vertical Anchor Bar'] = "垂直状"

L['Layout Direction'] = true
L['Normal is right to left or top to bottom, or select reversed to switch directions.'] = true
L['Normal'] = true
L['Reversed'] = true

-- Minimap Location
L['Above Minimap'] = true
L['Location Digits'] = true
L['Number of digits for map location.'] = true

-- Minimap Combat Hide
L["Hide minimap while in combat."] = true
L["FadeIn Delay"] = true
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = true

-- PvP Autorelease
L['PvP Autorelease'] = "PVP自动释放灵魂"
L['Automatically release body when killed inside a battleground.'] = "在战场死亡后自动释放灵魂."

-- Track Reputation
L['Track Reputation'] = "声望追踪"
L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'] = "当你获得某个阵营的声望时, 将自动追踪此阵营的声望至经验栏位." 

-- Select Quest Reward
L['Select Quest Reward'] = true
L['Automatically select the quest reward with the highest vendor sell value.'] = true

-- Item Level Datatext
L['Item Level'] = true

-- Range Datatext
L['Target Range'] = true
L['Distance'] = "距离"

-- Extra Datatexts
L['Actionbar1DataPanel'] = '快捷列 1 资讯框'
L['Actionbar3DataPanel'] = '快捷列 3 资讯框'
L['Actionbar5DataPanel'] = '快捷列 5 资讯框'

-- Farmer
L["Sunsong Ranch"] = "日歌农场"
L["The Halfhill Market"] = "半山市集"
L["Tilled Soil"] = "开垦过的土壤"
L['Right-click to drop the item.'] = "右键点击需删除的项目."

L['Farmer'] = "农夫"
L["FARMER_DESC"] = "调整设置以便你在日歌农场更有效的耕作."
L['Farmer Bars'] = "农夫列"
L['Farmer Portal Bar'] = "农夫列:传送"
L['Farmer Seed Bar'] = "农夫列:种子"
L['Farmer Tools Bar'] = "农夫列:工具"
L['Enable/Disable the farmer bars.'] = "开启/关闭 农夫快捷列."
L['Only active buttons'] = "只显示有效的按钮"
L['Only show the buttons for the seeds, portals, tools you have in your bags.'] = "只显示你背包中有的种子, 传送门和工具."
L['Drop Tools'] = "删除工具"
L['Automatically drop tools from your bags when leaving the farming area.'] = "当你离开农场范围时, 自动删除背包中的工具."
L['Seed Bar Direction'] = true
L['The direction of the seed bar buttons (Horizontal or Vertical).'] = true

-- Nameplates
L["Threat Text"] = "威胁值文字"
L["Display threat level as text on targeted, boss or mouseover nameplate."] = "在首领或鼠标悬停的血条上显示威胁值文字."
L["Target Count"] = true
L["Display the number of party / raid members targetting the nameplate unit."] = true

-- HealGlow
L['Heal Glow'] = true
L['Direct AoE heals will let the unit frames of the affected party / raid members glow for the defined time period.'] = true
L["Glow Duration"] = true
L["The amount of time the unit frames of party / raid members will glow when affected by a direct AoE heal."] = true
L["Glow Color"] = true

-- Raid Marker Bar
L['Raid Marker Bar'] = true
L['Display a quick action bar for raid targets and world markers.'] = true
L['Modifier Key'] = true
L['Set the modifier key for placing world markers.'] = true
L['Shift Key'] = true
L['Ctrl Key'] = true
L['Alt Key'] = true
L["Raid Markers"] = true
L["Click to clear the mark."] = true
L["Click to mark the target."] = true
L["%sClick to remove all worldmarkers."] = true
L["%sClick to place a worldmarker."] = true

-- WatchFrame
L['WatchFrame'] = true
L['WATCHFRAME_DESC'] = "Adjust the settings for the visibility of the watchframe (questlog) to your personal preference."
L['Hidden'] = true
L['Collapsed'] = true
L['Settings'] = true
L['City (Resting)'] = true
L['PvP'] = true
L['Arena'] = true
L['Party'] = true
L['Raid'] = true

-- Tooltips
L['Progression Info'] = true
L['Display the players raid progression in the tooltip, this may not immediately update when mousing over a unit.'] = true
