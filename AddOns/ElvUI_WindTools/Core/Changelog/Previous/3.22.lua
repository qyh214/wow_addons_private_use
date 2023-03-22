local W = unpack((select(2, ...)))

W.Changelog[322] = {
    RELEASE_DATE = "2022/01/26",
    IMPORTANT = {
        ["zhCN"] = {
            "适配 10.0.5 改动.",
            "最低 ElvUI 支持版本更改为 13.23.",
            "重新默认开启 PlayStyleString 修复."
        },
        ["zhTW"] = {
            "適配 10.0.5 改動.",
            "最低 ElvUI 支援版本更改為 13.23.",
            "重新默認開啟 PlayStyleString 修復."
        },
        ["enUS"] = {
            "Adapt to 10.0.5 changes.",
            "The minimum ElvUI version is changed to 13.23.",
            "Re-enable PlayStyleString fix by default."
        },
        ["koKR"] = {
            "Adapt to 10.0.5 changes.",
            "The minimum ElvUI version is changed to 13.23.",
            "Re-enable PlayStyleString fix by default."
        },
        ["ruRU"] = {
            "Адаптация под изменения 10.0.5.",
            "Минимальная версия ElvUI изменена на 13.23.",
            "Исправление для PlayStyleString включено по умолчанию."
        }
    },
    NEW = {
        ["zhCN"] = {
            "[其他] 新增了自动开关聊天泡泡功能. 默认关闭.",
            "[预组建列表] 新增了排序功能."
        },
        ["zhTW"] = {
            "[其他] 新增了自動開關聊天泡泡功能. 默認關閉.",
            "[預組列表] 新增了排序功能."
        },
        ["enUS"] = {
            "[Misc] Add auto toggle chat bubble. Disabled by default.",
            "[LFG List] Add sorting support."
        },
        ["koKR"] = {
            "[Misc] Add auto toggle chat bubble. Disabled by default.",
            "[LFG List] Add sorting support."
        },
        ["ruRU"] = {
            "[Разное] Добавлено автопереключение облачков чата. Отключено по умолчанию.",
            "[Список LFG] Добавлена поддержка сортировки."
        }
    },
    IMPROVEMENT = {
        ["zhCN"] = {
            "过期代码清理.",
            "[事件追踪器] 修复了提醒声音无法播放的问题.",
            "[事件追踪器] 提醒功能现在将在进入游戏 10 秒之后开启.",
            "[额外物品条] 新增野性皮革战鼓到实用物品列表.",
            "[额外物品条] 从商人食物列表中移除美味龙涎.",
            "[预组建列表] 右侧面板现在可以被拖动.",
            "[预组建列表] 添加更多说明方便使用.",
            "[预组建列表] 设置过滤器后将会以暴雪允许的频度进行自动刷新.",
            "[预组建列表] 点击每周奖励进度可以打开宝库框体.",
            "[预组建列表] 一起加入更改为职责可用, 单人时也能根据专精进行过滤."
        },
        ["zhTW"] = {
            "過期代碼清理.",
            "[事件追蹤器] 修復了提醒聲音無法播放的問題.",
            "[事件追蹤器] 提醒功能現在將在進入遊戲 10 秒之後開啟.",
            "[額外物品條] 新增野性皮革戰鼓到實用物品列表.",
            "[額外物品條] 從商人食物列表中移除美味的龍涎.",
            "[預組列表] 右側面板現在可以被拖動.",
            "[預組列表] 添加更多說明方便使用.",
            "[預組列表] 設定過濾器後將會以暴雪容許的頻度進行自動刷新.",
            "[預組列表] 點擊每周獎勵進度可以打開寶庫框架.",
            "[預組列表] 一起加入更改為職責可用, 單人時也能根據專精進行過濾."
        },
        ["enUS"] = {
            "Clean up unused code.",
            "[Event Tracker] Fix the issue that the alert sound can not be played.",
            "[Event Tracker] The alert will be enabled after 10 seconds after entering the game.",
            "[Extra Item Bar] Add Feral Hide Drums to Utility Items.",
            "[Extra Item Bar] Remove Delicious Dragon Spittle from vendor food group.",
            "[LFG List] The right panel can now be moved by dragging.",
            "[LFG List] Add more tooltips for easy use.",
            "[LFG List] Set filters will now auto refresh at the frequency allowed by Blizzard.",
            "[LFG List] Clicking the weekly reward progress can open the treasure frame.",
            "[LFG List] Join Together is now Role Available, and can filter groups by specialization when solo."
        },
        ["koKR"] = {
            "Clean up unused code.",
            "[Event Tracker] Fix the issue that the alert sound can not be played.",
            "[Event Tracker] The alert will be enabled after 10 seconds after entering the game.",
            "[Extra Item Bar] Add Feral Hide Drums to Utility Items.",
            "[Extra Item Bar] Remove Delicious Dragon Spittle from vendor food group.",
            "[LFG List] The right panel can now be moved by dragging.",
            "[LFG List] Add more tooltips for easy use.",
            "[LFG List] Set filters will now auto refresh at the frequency allowed by Blizzard.",
            "[LFG List] Clicking the weekly reward progress can open the treasure frame.",
            "[LFG List] Join Together is now Role Available, and can filter groups by specialization when solo."
        },
        ["ruRU"] = {
            "Удалён неиспользуемый код.",
            "[Отслеживание событий] Исправлена ошибка, из-за которой не воспроизводился звук оповещения.",
            "[Отслеживание событий] Оповещение будет включено через 10 секунд после входа в игру.",
            "[Панель дополнительных предметов] К полезным предметам добавлены 'Барабаны из дикой шкуры'.",
            "[Панель дополнительных предметов] 'Сладкая слюна дракона' удалена из списка продуктов торговца.",
            "[Список LFG] Правую панель теперь можно перетаскивать.",
            "[Список LFG] Добавлено больше всплывающих подсказок для удобства использования.",
            "[Список LFG] Установленные фильтры теперь будут автоматически обновляться с частотой, которая разрешена Blizzard.",
            "[Список LFG] Нажав на прогресс еженедельной награды, Вы можете открыть фрейм с сокровищами.",
            "[Список LFG] 'Присоединиться вместе' теперь доступно по ролям и можно фильтровать группы по специализации, когда играете в одиночку."
        }
    }
}
