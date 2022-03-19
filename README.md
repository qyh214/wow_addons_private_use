## wow_addons & wow_addons_private_use 魔兽世界自用整合插件
魔兽世界官方正式服务器自用整合插件。

LEG时期全部为单体插件（支持直接单独插件使用，部分模块化插件除外），非集中模块化整合类插件（与网易有爱、大脚、多玩魔盒等不同）。

自BFA前夕开始改用[ElvUI](https://www.tukui.org/download.php?ui=elvui&changelog)整合界面插件+部分单体插件组合使用。

以适用于自身为基准，目前主玩萨满祭司（恢复），所以界面、插件将针对此做出必要调整，并未考虑是否适用于其他专精、职业。

特别提示：部分插件可能功能有重叠，应当只使用其中一个或选择性使用，或者部分插件的某些功能需要关闭，以免出现冲突。

插件包本身虽然可能提供八国语言，但目前只在简体中文客户端下使用，因此无法确保繁体中文等语言是否仍然可用。

## 使用方法
将addons文件夹放置在```游戏根目录/_retail_/interface/```下，例如```D:\World of Warcraft\_retail_\interface\addons```，进入后便是插件列表，避免出现```D:\World of Warcraft\_retail_\interface\addons\addons```等情况。

## 效果图
请注意：效果图仅供参考，截图时间可能较早。你可以通过直播、录像等形式了解实际情况。

一般
![screen](./Screenshots/WoWScrnShot_072418_114147.jpg)

选中他人
![screen](./Screenshots/WoWScrnShot_072418_114142.jpg)

AFK离开状态（```/afk```）
![screen](./Screenshots/WoWScrnShot_072418_114158.jpg)

更多效果图可以查看[Screenshots](./Screenshots/)文件夹。

## 插件列表
全部插件请看[插件列表](ADDONS.md)。

## WA字符串
全部WA请看[wa列表](WA.md)。

## 工具
在tools文件夹下提供了一些工具，供使用。
- fonts：提供一个命令符，供你将想要使用的字体命名为符合要求的字体，用于替换游戏中字体，不提供字体的下载，这可能违反部分字体文件的许可协议。
- icons：提供个人使用的高清图标文件，具体请自行查看说明并下载。
- wtfconvert：提供配置文件的备份、覆盖的一个工具，具体请自行查看说明并下载。

## 许可证
请查阅[LICENSE](LICENSE)。

根据暴雪守则以及社区相关规定，禁止将插件、插件部分、或者组合提供收费定制服务，本人整合之插件包的部分和全部，禁止并谢绝通过拦截，或阻断，或增加获取难度，或经过部分修改后以收费、会员制度、闭源客户端提供。

本插件包在自管内部搭建之代码管理网站gitlab和国际通行的代码管理网站github免费、完整提供源代码，并在黑盒工坊中免费提供了本插件包的完整配置文件等参数。

## 说明、贡献指南
如有兴趣使用，可使用全部插件或提取部分插件使用。

包含部分插件配置、界面配置信息，建议根据需要自行配置各个插件（通常是位置和部分细节调整）。

部分插件支持命令，例如/dbm，等等。其他插件可以在界面-插件里修改。

## 插件维护更新方式
ElvUI：
- 下载：https://www.tukui.org/download.php?ui=elvui&download
- 更新历史：https://www.tukui.org/download.php?ui=elvui&changelog

自动截图插件：http://bbs.ngacn.cc/read.php?tid=7534350

TinyInspect、TinyTooltip：http://bbs.ngacn.cc/read.php?tid=10240957
TinyInspect、TinyTooltip社区9.2更新：https://bbs.nga.cn/read.php?tid=31055323

其他单体插件可用curse客户端管理，curse客户端下载地址：https://curseforge.overwolf.com

wa字符串更新客户端：https://weakauras.wtf/

wa和插件也可以用类似的统一管理客户端管理，例如：
- ajour：https://github.com/ajour/ajour
- 黑盒工坊：https://xiaoheihe.cn/workshop

## 一些有用的重要命令
在游戏内聊天窗口输入，然后回车：

最远镜头距离：`/console cameraDistanceMaxZoomFactor 2.6`

总是对比装备：`/console alwaysCompareItems 1`

以上命令可借助插件AdvancedInterfaceOptions、ElvUI_WindTools控制。

- WTF（WOW安装目录/WTF/config.wtf）：

在配置文件内添加以下内容（可能会被覆盖掉，可由插件AdvancedInterfaceOptions再次单角色控制）

```
SET overrideArchive "0"
```

自2020年4月4日起，cn地区的`SET profanityFilter "0"`被agent强制监管覆盖更新，可配合使用fuckyou等插件以及诸如WA字符串解决，目前ElvUI_WindTools也提供了相关解锁功能。

## 配置文件
导入这个字符串可以形成近似于当前使用的elvui风格：https://wago.io/fpHXHN2wA

wa自用字符串、合集整理可访问：https://wago.io/p/shihuang214

全部插件和配置文件的备份：黑盒工坊分享码：21540cYOUddK4Cw
