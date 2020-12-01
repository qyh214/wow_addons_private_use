## wow_addons & wow_addons_private_use 魔兽世界自用整合插件
魔兽世界官方正式服务器自用整合插件。

LEG时期全部为单体插件（支持直接单独插件使用，部分模块化插件除外），非集中模块化整合类插件（与网易有爱、大脚、多玩魔盒等不同）。

自BFA前夕开始改用[ElvUI](https://www.tukui.org/download.php?ui=elvui&changelog)整合界面插件+部分单体插件组合使用。

以适用于自身为基准，目前主玩萨满祭司（恢复），所以界面、插件将针对此做出必要调整，并未考虑是否适用于其他专精、职业。

特别提示：部分插件可能功能有重叠，应当只使用其中一个或选择性使用。

## 使用方法
将addons文件夹放置在```游戏根目录/_retail_/interface/```下，例如```D:\World of Warcraft\_retail_\interface\addons```，进入后便是插件列表，避免出现```D:\World of Warcraft\_retail_\interface\addons\addons```等情况。

## 效果图
一般
![screen](./Screenshots/WoWScrnShot_072418_114147.jpg)

选中他人
![screen](./Screenshots/WoWScrnShot_072418_114142.jpg)

AFK离开状态（```/afk```）
![screen](./Screenshots/WoWScrnShot_072418_114158.jpg)

更多效果图可以查看[Screenshots](./Screenshots/)文件夹。

## 插件列表
全部插件请看[插件列表](addonslist.md)。

## 许可证
请查阅[LICENSE](LICENSE)。

## 说明、贡献指南
如有兴趣使用，可使用全部插件或提取部分插件使用。

均不包含插件配置、界面配置信息（个人的WTF文件），需要自行配置各个插件（通常是位置）。

部分插件支持命令，例如/dbm，等等。其他插件可以在界面-插件里修改。

## 插件维护更新方式
ElvUI：
- 下载：https://www.tukui.org/download.php?ui=elvui&download
- 更新历史：https://www.tukui.org/download.php?ui=elvui&changelog

自动截图插件：http://bbs.ngacn.cc/read.php?tid=7534350

TinyInspect、TinyTooltip：http://bbs.ngacn.cc/read.php?tid=10240957

其他单体插件可用curse客户端管理，curse客户端下载地址：https://www.curseforge.com/twitch-client

## WA字符串
鼠标跟踪：https://wago.io/SypUT-DPm

属性监控：https://wago.io/rJZgZUxn7

全职业中二语音：https://bbs.nga.cn/read.php?tid=20729857

只狼特效：https://wago.io/sekirowa

奶萨wa技能监控：https://wago.io/Rshaman_AfenarUI

增强、元素萨满wa技能监控：https://wago.io/Afenar_Shaman

蓝量报警：https://bbs.nga.cn/read.php?tid=21781278

标记坦克和治疗：https://wago.io/QcIHcKjkP

暗影国度地下城与团队副本：
- 地下城（中文）：https://wago.io/DtdLKK4XF  （来源： https://bbs.nga.cn/read.php?tid=23417528 ）
- 地下城（英语原版）：https://wago.io/ZpDhyMJ9K
- 纳斯利亚堡团队副本：https://wago.io/BYNw1h77H

## 一些有用的重要命令
在游戏内聊天窗口输入，然后回车：

最远镜头距离：`/console cameraDistanceMaxZoomFactor 2.6`

总是对比装备：`/console alwaysCompareItems 1`

以上命令可借助插件AdvancedInterfaceOptions、ElvUI_WindTools控制。

WTF（WOW安装目录/WTF/config.wtf）：

在配置文件内添加以下内容（可能会被覆盖掉，可由插件AdvancedInterfaceOptions再次单角色控制）

```
SET overrideArchive "0"
```

自2020年4月4日起，cn地区的`SET profanityFilter "0"`被agent强制监管覆盖更新，可配合使用fuckyou等插件以及诸如WA字符串解决。