-- ADT 中文本地化补充
-- 此文件在 enUS.lua 之后加载，仅用于确保 zhCN 表完整
-- 实际语言表定义在 enUS.lua 中的 ADT.Locales.zhCN
local ADDON_NAME, ADT = ...

-- 如果 ADT.Locales.zhCN 不存在（理论上不应发生），创建它
if not ADT.Locales then ADT.Locales = {} end
if not ADT.Locales.zhCN then
    ADT.Locales.zhCN = {}
end

-- 注意：zhCN 的字符串已在 enUS.lua 中定义
-- 此文件仅作为加载顺序占位符
