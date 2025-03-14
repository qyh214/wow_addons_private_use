---@class BFC
local BFC = select(2, ...)

BFC.category = {
    ---------------------------------------------------------------------
    -- 武器
    ---------------------------------------------------------------------
    {
        category = "武器",
        subs = {
            {
                category = "单手",
                subs = {
                    "单手斧",
                    "单手锤",
                    "单手剑",
                    "战刃",
                    "匕首",
                    "拳套",
                    "魔杖",
                },
            },
            {
                category = "双手",
                subs = {
                    "双手斧",
                    "双手锤",
                    "双手剑",
                    "长柄武器",
                    "法杖",
                },
            },
            {
                category = "远程",
                subs = {
                    "弓",
                    "弩",
                    "枪械",
                },
            },
        },
    },

    ---------------------------------------------------------------------
    -- 护甲
    ---------------------------------------------------------------------
    {
        category = "护甲",
        subs = {
            {
                category = "头部",
            },
            {
                category = "肩部",
            },
            {
                category = "胸部",
            },
            {
                category = "腰部",
            },
            {
                category = "腿部",
            },
            {
                category = "脚部",
            },
            {
                category = "腕部",
            },
            {
                category = "披风",
            },
            {
                category = "手指",
            },
            {
                category = "饰品",
            },
            {
                category = "副手物品",
            },
            {
                category = "盾牌",
            },
            {
                category = "装饰品",
            },
        },
    },

    ---------------------------------------------------------------------
    -- 专业装备
    ---------------------------------------------------------------------
    {
        category = "专业装备",
        subs = {
            {
                category = "铭文",
            },
            {
                category = "裁缝",
            },
            {
                category = "制皮",
            },
            {
                category = "珠宝加工",
            },
            {
                category = "炼金",
            },
            {
                category = "锻造",
            },
            {
                category = "工程学",
            },
            {
                category = "附魔",
            },
            {
                category = "草药学",
            },
            {
                category = "采矿",
            },
            {
                category = "剥皮",
            },
            {
                category = "烹饪",
            },
            {
                category = "钓鱼",
            },
        },
    },

    ---------------------------------------------------------------------
    -- 杂项
    ---------------------------------------------------------------------
    {
        category = "杂项",
        subs = {
            {
                category = "其他",
            },
        },
    },
}

function BFC.GetRelatedCategories(category)
    local c1, c2, c3 = strsplit("|", category)
    -- print(c1, c2, c3)

    local result = {}

    if c3 then
        result[c3] = true

    elseif c2 then
        for _, t1 in pairs(BFC.category) do
            if t1.category == c1 then
                for _, t2 in pairs(t1.subs) do
                    if t2.category == c2 then
                        if t2.subs then
                            for _, t3 in pairs(t2.subs) do
                                result[t3] = true
                            end
                        else
                            result[t2.category] = true
                        end
                        break
                    end
                end
                break
            end
        end

    else
        for _, t1 in pairs(BFC.category) do
            if t1.category == c1 then
                for _, t2 in pairs(t1.subs) do
                    if t2.subs then
                        for _, t3 in pairs(t2.subs) do
                            result[t3] = true
                        end
                    else
                        result[t2.category] = true
                    end
                end
                break
            end
        end
    end


    return result
end