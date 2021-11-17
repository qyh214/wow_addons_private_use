local Tooltip;

local TOOLTIP_NAME = "NarciUtilityTooltip";
local IS_ITEM_CACHED = {};
local IS_LINE_HOOKED = {};

local pinnedObject, lastItem, lastText, onTextChangedCallback;

local function OnTextChanged(object, text)
    print(object.lineIndex);
    print(text);
end

local function SetTooltipItem(item)
    if not item then return end;

    if type(item) == "number" then
        Tooltip:SetItemByID(item);
    else
        Tooltip:SetHyperlink(item);
    end

    if IS_ITEM_CACHED[item] then
        return true
    else
        IS_ITEM_CACHED[item] = true;
        return false
    end
end

local function GetPinnedLineText()
    if pinnedObject then
        local newText = pinnedObject:GetText();
        if newText ~= lastText then
            lastText = newText;
            if onTextChangedCallback then
                onTextChangedCallback(newText);
            end
            return true
        end
    end
end

local function Tooltip_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.25 then
        self.t = 0;
        self.iteration = self.iteration + 1;
        if self.iteration > 3 then
            self:SetScript("OnUpdate", nil);
        end
        SetTooltipItem(lastItem);
        GetPinnedLineText()
    end
end

local function GetItemTooltipTextByLine(item, line, callbackFunc)
    if not Tooltip then
        Tooltip = CreateFrame("GameTooltip", TOOLTIP_NAME, nil, "GameTooltipTemplate");
        Tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    end

    onTextChangedCallback = callbackFunc;
    local isCached = SetTooltipItem(item);

    if item ~= lastItem then
        lastItem = item;
        Tooltip.t = 0;
        Tooltip.iteration = 0;
        Tooltip:SetScript("OnUpdate", Tooltip_OnUpdate);
    end

    local object = _G[TOOLTIP_NAME.."TextLeft"..line];
    pinnedObject = object;
    local text;
    if object then
        if not IS_LINE_HOOKED[line] then
            IS_LINE_HOOKED[line] = true;
            object.lineIndex = line;
        end
        text = object:GetText();
    end

    return text, isCached
end

NarciAPI.GetCachedItemTooltipTextByLine = GetItemTooltipTextByLine;