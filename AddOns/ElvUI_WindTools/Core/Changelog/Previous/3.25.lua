local W = unpack((select(2, ...)))

W.Changelog[325] = {
    RELEASE_DATE = "2023/03/13",
    IMPORTANT = {
        ["zhCN"] = {
            "由于需要强制手机认证, 移除 KOOK 社区链接.",
            "[移动框体] 由于可能发生的错误, 停用了玩家选择框体的移动功能."
        },
        ["zhTW"] = {
            "由於需要強制簡訊認證, 移除 KOOK 社區連結.",
            "[移動框架] 由於可能發生的錯誤, 停用了玩家選擇框架的移動功能."
        },
        ["enUS"] = {
            "Remove the KOOK community link due to the need for forced SMS authentication.",
            "[Move Frames] Disable the support of player choice frame due to a possible error."
        },
        ["koKR"] = {
            "Remove the KOOK community link due to the need for forced SMS authentication.",
            "[Move Frames] Disable the support of player choice frame due to a possible error."
        },
        ["ruRU"] = {
            "Удалена ссылка на сообщество KOOK в связи с необходимостью принудительной SMS-аутентификации.",
            "[Перемещение фреймов] Отключено перемещение фрейма выбора игрока из-за возможных ошибок."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[通告] 新增对原子重校器的支持.",
            "[聊天文字] 新增公会成员状态提示增强功能.",
            "[聊天文字] 新增公会成员上线消息增加邀请链接的功能.",
            "[聊天文字] 新增合并成就消息的功能.",
            "[聊天链接] 新增对成就链接图标的支持."
        },
        ["zhTW"] = {
            "[通告] 新增對原子校準器的支援.",
            "[聊天文字] 新增公會成員狀態提示增強功能.",
            "[聊天文字] 新增公會成員上線消息增加邀請鏈接的功能.",
            "[聊天文字] 新增合併成就消息的功能.",
            "[聊天鏈接] 新增對成就鏈接圖示的支援."
        },
        ["enUS"] = {
            "[Announcement] Add support for Atomic Recalibrator.",
            "[Chat Text] Add a new feature for enhancing the guild member status change messages.",
            "[Chat Text] Add a new feature for adding the invite link to the guild member online messages.",
            "[Chat Text] Add a new feature for merging the achievement messages.",
            "[Chat Link] Add support for achievement link icon."
        },
        ["koKR"] = {
            "[Announcement] Add support for 원자 재측정기.",
            "[Chat Text] Add a new feature for enhancing the guild member status change messages.",
            "[Chat Text] Add a new feature for adding the invite link to the guild member online messages.",
            "[Chat Text] Add a new feature for merging the achievement messages.",
            "[Chat Link] Add support for achievement link icon."
        },
        ["ruRU"] = {
            "[Анонс] Добавлена поддержка для Атомного преобразователя.",
            "[Текст чата] Добавлена новая функция для улучшения сообщений об изменении статуса члена гильдии.",
            "[Текст чата] Добавлена новая функция для добавления ссылки-приглашения в онлайн-сообщения члена гильдии.",
            "[Текст чата] Добавлена новая функция для объединения сообщений о достижениях.",
            "[Ссылка для чата] Добавлена поддержка значков ссылок на достижения."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "[聊天文字] 重构了设定项目.",
            "[通告] 被地震打断时不再通报自己打断了自己.",
            "[通告] 在更换钥石时现在也会进行通告.",
            "[额外物品条] 更新专业物品列表",
            "[交接] 修复无法使用修饰键暂停部分对话的问题.",
            "[美化外观] 更新 Auctionator 皮肤.",
            "[美化外观] 更新 ElvUI 动作条皮肤.",
            "[美化外观] 修复贸易站皮肤的一个错误.",
            "[美化外观] 更新玩家选择框体皮肤.",
            "[吸收] 修复切换配置文件时可能造成的一个错误.",
            "[好友列表] 代码清理.",
            "[好友列表] 修复了魔兽世界好友的美化.",
            "[智能 Tab] 修复了错误信息 API 错误."
        },
        ["zhTW"] = {
            "[聊天文字] 重構了設定項目.",
            "[通告] 被地震打斷時不再通報自己打斷了自己.",
            "[通告] 在更換鑰石時現在也會進行通報.",
            "[額外物品條] 更新專業物品列表",
            "[交接] 修復無法使用修飾鍵暫停部分對話的問題.",
            "[美化外觀] 更新 Auctionator 皮膚.",
            "[美化外觀] 更新 ElvUI 動作條皮膚.",
            "[美化外觀] 修復貿易站皮膚的一個錯誤.",
            "[美化外觀] 更新玩家選擇框架皮膚.",
            "[吸收] 修復切換配置文件時可能造成的一個錯誤.",
            "[好友列表] 代碼清理.",
            "[好友列表] 修復了魔獸世界好友的美化.",
            "[智能 Tab] 修復了錯誤信息 API 錯誤."
        },
        ["enUS"] = {
            "[Chat Text] Refactor the options.",
            "[Announcement] No longer announce you interrupt yourself by quake.",
            "[Announcement] Add the announcement after you changed the keystone.",
            "[Extra Item Bar] Update the profession item list.",
            "[Turn In] Fix the issue that you cannot pause some conversations with modifier key.",
            "[Skins] Update Auctionator skin.",
            "[Skins] Update ElvUI actionbar skin.",
            "[Skins] Fix an error in trading post skin.",
            "[Skins] Update player choice frame skin.",
            "[Absorb] Fix an error when switching profile.",
            "[Friend List] Code cleanup.",
            "[Friend List] Fix the issue that the WoW friends are not skinned.",
            "[Smart Tab] Fix the API usage of UI error message."
        },
        ["koKR"] = {
            "[Chat Text] Refactor the options.",
            "[Announcement] No longer announce you interrupt yourself by quake.",
            "[Announcement] Add the announcement after you changed the keystone.",
            "[Extra Item Bar] Update the profession item list.",
            "[Turn In] Fix the issue that you cannot pause some conversations with modifier key.",
            "[Skins] Update Auctionator skin.",
            "[Skins] Update ElvUI actionbar skin.",
            "[Skins] Fix an error in trading post skin.",
            "[Skins] Update player choice frame skin.",
            "[Absorb] Fix an error when switching profile.",
            "[Friend List] Code cleanup.",
            "[Friend List] Fix the issue that the WoW friends are not skinned.",
            "[Smart Tab] Fix the API usage of UI error message."
        },
        ["ruRU"] = {
            "[Текст чата] Переработаны параметры.",
            "[Объявление] Больше не объявляет, что Вы прерываете себя Землетрясением.",
            "[Объявление] Теперь будет уведомление при замене М+ ключа.",
            "[Панель дополнительных предметов] Обновление списка предметов профессии.",
            "[Сдать квест] Исправлена проблема, из-за которой Вы не могли приостановить некоторые разговоры с помощью клавиши-модификатора.",
            "[Скины] Обновлен скин Auctionator",
            "[Скины] Обновлен скин панели действий ElvUI.",
            "[Скины] Исправлена ошибка в скине Торговой лавки.",
            "[Скины] Обновлен скин рамки выбора игрока.",
            "[Поглощение] Исправлена ошибка, которая могла возникнуть при переключении профиля.",
            "[Список друзей] Чистка кода.",
            "[Список друзей] Исправление проблемы, из-за которой вкладка Друзья WoW не имела скина.",
            "[Умная вкладка] Исправлены сообщения об ошибках API."
        }
    }
}
