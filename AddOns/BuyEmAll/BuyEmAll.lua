-- BuyEmAll - Originally created and developed by Cogwheel up to version 2.8.4, now developed by Shinisuryu.

BuyEmAll = {}

local L = BUYEMALL_LOCALS;

-- These are used for the text on the Max and Stack buttons. See BuyEmAll.xml.

BUYEMALL_MAX = L.MAX;
BUYEMALL_STACK = L.STACK;

-- It's ALIVE!!! Muahahahahhahahaa!!!!!

function BuyEmAll:OnLoad()
    -- Set up confirmation dialog.

    StaticPopupDialogs["BUYEMALL_CONFIRM"] = {
        preferredIndex = 3,
        text = L.CONFIRM,
        button1 = YES,
        button2 = NO,
        OnAccept = function(dialog) self:DoPurchase(dialog.data) end,
        timeout = 0,
        hideOnEscape = true,
    };
    self.ConfirmNoItemLink = 0;
    StaticPopupDialogs["BUYEMALL_CONFIRM2"] = {
        preferredIndex = 3,
        text = L.CONFIRM,
        button1 = YES,
        button2 = NO,
        OnAccept = function(dialog) BuyMerchantItem(self.ConfirmNoItemLink) end,
        timeout = 0,
        hideOnEscape = true,
    };

    -- Clear textures and text to prevent pink textures.

    BuyEmAllCurrency1:SetTexture();
    BuyEmAllCurrency2:SetTexture();
    BuyEmAllCurrency3:SetTexture();
    BuyEmAllCurrencyAmt1:SetText();
    BuyEmAllCurrencyAmt2:SetText();
    BuyEmAllCurrencyAmt3:SetText();

    self.OrigMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick;
    MerchantItemButton_OnModifiedClick = function(frame, button)
        self:MerchantItemButton_OnModifiedClick(frame, button);
    end

    self.OrigMerchantFrame_OnHide = MerchantFrame:GetScript("OnHide");
    MerchantFrame:SetScript("OnHide", function(...)
        return self:MerchantFrame_OnHide(...);
    end)

    SLASH_BUYEMALL1 = "/buyemall"
    SlashCmdList["BUYEMALL"] = function(message, editbox)
        BuyEmAll:SlashHandler(message);
    end
end


function BuyEmAll:SlashHandler(message, editbox)
    if message == "" then
        print("BuyEmAll: Use /buyemall confirm to enable/disable the large purchange confirm.");
    elseif message == "confirm" then
        if BEAConfirmToggle == true then
            BEAConfirmToggle = false;
            print("BuyEmAll: Large purchase confirm window disabled.");
        elseif BEAConfirmToggle == false then
            BEAConfirmToggle = true;
            print("BuyEmAll: Large purchase confirm window enabled.");
        end
    end
end

-- Variable setup/check.

local BEAframe = CreateFrame("FRAME", "BEAFrame");
BEAframe:Hide();
BEAframe:RegisterEvent("ADDON_LOADED");
local function eventHandler(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5 = ...;
    if (event == "ADDON_LOADED") and (arg1 == "BuyEmAll") then
        if (BEAConfirmToggle == nil) then
            BEAConfirmToggle = true;
        elseif (BEAConfirmToggle == 0) then
            BEAConfirmToggle = false;
        elseif (BEAConfirmToggle == 1) then
            BEAConfirmToggle = true;
        end
    end
end

BEAframe:SetScript("OnEvent", eventHandler);

-- Makes sure the BuyEmAll frame goes away when you leave a vendor.

function BuyEmAll:MerchantFrame_OnHide(...)
    BuyEmAllFrame:Hide();
    return self.OrigMerchantFrame_OnHide(...);
end

function BuyEmAll:CogsFreeBagSpace(itemID)
    local freeSpace = 0;
    local itemSubType = GetItemFamily(itemID);
    local stackSize = select(8, GetItemInfo(itemID));

    for theBag = 0, 4 do
        local doBag = true;

        if theBag > 0 then -- 0 is always the backpack.
        local bagLink = GetInventoryItemLink("player", 19 + theBag); -- Bag #1 is in inventory slot 20.
        if bagLink then
            local bagSubType = GetItemFamily(bagLink);
            if bagSubType == itemSubType then
                doBag = true;
            elseif bagSubType == 0 then
                doBag = true;
            elseif bit.band(itemSubType, bagSubType) == bagSubType then
                doBag = true;
            else doBag = false;
            end
        else
            doBag = false;
        end
        end

        if doBag then
            local numSlot = GetContainerNumSlots(theBag);
            for theSlot = 1, numSlot do
                local itemLink = GetContainerItemLink(theBag, theSlot);
                if not itemLink then
                    freeSpace = freeSpace + stackSize;
                elseif strfind(itemLink, "item:" .. itemID .. ":") then
                    local _, itemCount = GetContainerItemInfo(theBag, theSlot);
                    freeSpace = freeSpace + stackSize - itemCount;
                end
            end
        end
    end
    return freeSpace, stackSize;
end


-- Hooks left-clicks on merchant item buttons.

function BuyEmAll:MerchantItemButton_OnModifiedClick(frame, button)
    self.itemIndex = frame:GetID();

    -- Don't think this is needed anymore.
    --if ChatFrame1EditBox:HasFocus() then ChatFrame1EditBox:Insert(GetMerchantItemLink(frame:GetID()));


    if MerchantFrame.selectedTab == 1
            and IsShiftKeyDown()
            and not IsControlKeyDown()
            and not ChatFrame1EditBox:HasFocus() then

        -- Set up various data before showing the BuyEmAll frame.

        -- Misc variables for help with error logs.
        self.NPCName = UnitName("npc");

        self.AltCurrencyMode = false;
        self.AtVendor = true; -- Currently at the vendor, for later purchase interruption.

        local name, texture, price, quantity, numAvailable =
        GetMerchantItemInfo(self.itemIndex);
        self.preset = quantity;
        self.price = price;
        self.itemName = name;
        self.available = numAvailable;

        self.itemLink = GetMerchantItemLink(self.itemIndex);

        -- Bypass for purchasable things without an itemlink, don't know any other way right now.

        if self.itemLink == nil then
            self.ConfirmNoItemLink = self.itemIndex;
            local dialog = StaticPopup_Show("BUYEMALL_CONFIRM2", quantity, self.itemName);
            return
        end

        -- Buying a currency with a currency! At least what it should be. Don't know if there are any items that are used to purchase currency.

        if tonumber(strmatch(self.itemLink, "item:(%d+):")) == nil then
            local CurrencyTex = select(2, GetMerchantItemInfo(self.itemIndex));
            local CurrencyID = self:AltCurrencyTranslating(CurrencyTex);
            self.fit = select(6, GetCurrencyInfo(CurrencyID));
            if self.fit == 0 then
                self.fit = 10000000; -- 0 meaning no set maximum, so set how much one can fit super high.
            end
            self.stack = 1;
            self:AltCurrencyHandling(self.itemIndex, frame);
            return
        end

        self.itemID = tonumber(strmatch(self.itemLink, "item:(%d+):"));
        local bagMax, stack = self:CogsFreeBagSpace(self.itemID);
        self.stack = stack;
        self.fit = bagMax;

        if select(7, GetMerchantItemInfo(self.itemIndex)) == true then
            self:AltCurrencyHandling(self.itemIndex, frame);
            return
        end

        BuyEmAllCurrency1:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon");
        BuyEmAllCurrency2:SetTexture("Interface\\MONEYFRAME\\UI-SilverIcon"); -- Once known it's a standard transaction, use regular money textures.
        BuyEmAllCurrency3:SetTexture("Interface\\MONEYFRAME\\UI-CopperIcon");


        -- Modified to check for free items. Mostly for the PTR/Beta servers, but it shouldn't hurt to leave it in.
        -- Put after the alternate currency trigger to prevent issues. Always had it here, just adding the note.

        if self.price == 0 then
            self.afford = self.fit;
        else
            self.afford = floor(GetMoney() / ceil(price / self.preset));
        end

        self.max = min(self.fit, self.afford);
        if numAvailable > -1 then
            self.max = min(self.max, numAvailable);
        end
        if self.max == 0 then
            return
        elseif self.max == 1 then
            MerchantItemButton_OnClick(frame, "LeftButton");
            return
        end

        self.defaultStack = quantity;
        self.split = 1;

        self.partialFit = self.fit % stack;
        self:SetStackClick();



        self:Show(frame);
    else
        self.OrigMerchantItemButton_OnModifiedClick(frame, button);
    end
end

--[[ Processor for Alternate Currencies. Yeah, it's huge, as far as I can tell it's as small as I can get it while also
including every possibility, but I still want to see if I can make it smaller. ]]

function BuyEmAll:AltCurrencyHandling(itemIndex, frame)
    self.AltCurrencyMode = true;

    local price1, price2, price3 = 0, 0, 0;
    self.price1, self.price2, self.price3 = 0, 0, 0;

    self.AltCurrency1Type, self.AltCurrency2Type, self.AltCurrency3Type = 0, 0, 0;
    self.AltCurrency1, self.AltCurrency2, self.AltCurrency3 = 0, 0, 0;
    local Afford1, Afford2, Afford3 = 999999, 999999, 999999; -- Set them all to a high number to begin with. For later.

    local NumAltCurrency = GetMerchantItemCostInfo(itemIndex);


    self.NumAltCurrency = NumAltCurrency;
    if (NumAltCurrency == 1) or (NumAltCurrency == 2) or (NumAltCurrency == 3) then
        if (select(3, GetMerchantItemCostItem(itemIndex, 1)) == nil) then -- Itemlink check.
            self.AltCurrency1Type = 0; -- 0 = Pure currency, 1 = Item/Currency, possibly more later.
            self.AltCurrency1Tex = select(1, GetMerchantItemCostItem(itemIndex, 1)); -- Grabs texture path, hopefully the same no matter the language.
            self.AltCurrency1 = self:AltCurrencyTranslating(self.AltCurrency1Tex); -- Uses the currency texture to determine which one it is.
            price1 = select(2, GetMerchantItemCostItem(itemIndex, 1)); -- Gets the cost of the item being purchased.
            Afford1 = floor(select(2, GetCurrencyInfo(self.AltCurrency1)) / price1) * self.preset; -- How much can be bought.
        else
            self.AltCurrency1Type = 1; -- Currency is an item/something that can be in bags.
            self.AltCurrency1 = tonumber(strmatch(select(3, GetMerchantItemCostItem(itemIndex, 1)), "item:(%d+):")); -- Grabs the item's ID.
            self.AltCurrency1Tex = select(10, GetItemInfo(self.AltCurrency1)); -- Gets the texture for the item to show in the BEA frame.
            price1 = select(2, GetMerchantItemCostItem(itemIndex, 1)); -- Gets the number of the item required.
            Afford1 = floor((GetItemCount(self.AltCurrency1, true)) / price1) * self.preset; -- How much can be bought.
        end
    end
    if (NumAltCurrency == 2) or (NumAltCurrency == 3) then
        if (select(3, GetMerchantItemCostItem(itemIndex, 2)) == nil) then
            self.AltCurrency2Type = 0;
            self.AltCurrency2Tex = select(1, GetMerchantItemCostItem(itemIndex, 2));
            self.AltCurrency2 = self:AltCurrencyTranslating(self.AltCurrency2Tex);
            price2 = select(2, GetMerchantItemCostItem(itemIndex, 2));
            Afford2 = floor(select(2, GetCurrencyInfo(self.AltCurrency2)) / price2) * self.preset;
        else
            self.AltCurrency2Type = 1;
            self.AltCurrency2 = tonumber(strmatch(select(3, GetMerchantItemCostItem(itemIndex, 2)), "item:(%d+):"));
            self.AltCurrency2Tex = select(10, GetItemInfo(self.AltCurrency2));
            price2 = select(2, GetMerchantItemCostItem(itemIndex, 2));
            Afford2 = floor((GetItemCount(self.AltCurrency2, true)) / price2) * self.preset;
        end
    end
    if (NumAltCurrency == 3) then
        if (select(3, GetMerchantItemCostItem(itemIndex, 3)) == nil) then
            self.AltCurrency3Type = 0;
            self.AltCurrency3Tex = select(1, GetMerchantItemCostItem(itemIndex, 3));
            self.AltCurrency3 = self:AltCurrencyTranslating(self.AltCurrency3Tex);
            price3 = select(2, GetMerchantItemCostItem(itemIndex, 3));
            Afford3 = floor(select(2, GetCurrencyInfo(self.AltCurrency3)) / price3) * self.preset;
        else
            self.AltCurrency3Type = 1;
            self.AltCurrency3 = tonumber(strmatch(select(3, GetMerchantItemCostItem(itemIndex, 3)), "item:(%d+):"));
            self.AltCurrency3Tex = select(10, GetItemInfo(self.AltCurrency3));
            price3 = select(2, GetMerchantItemCostItem(itemIndex, 3));
            Afford3 = floor((GetItemCount(self.AltCurrency3, true)) / price3) * self.preset;
        end
    end

    self.price1 = price1;
    self.price2 = price2;
    self.price3 = price3;

    self.afford = min(Afford1, Afford2, Afford3); -- Used Min so if there's not 3 currencies, the unused Affords will be really high and not be used.

    self.max = min(self.fit, self.afford);

    if self.available > -1 then
        self.max = min(self.max, self.available * self.preset);
    end

    if self.max == 0 then
        return
    elseif self.max == 1 then
        MerchantItemButton_OnClick(frame, "LeftButton");
        return
    end

    self.defaultStack = self.preset;
    self.split = self.defaultStack;

    self.partialFit = self.fit % self.stack;
    self:SetStackClick();

    -- Misc variables for help with error logs.

    self.NPCName = UnitName("npc");
    self.ItemName = select(1, GetMerchantItemInfo(self.itemIndex));

    self:Show(frame);
end

function BuyEmAll:AltCurrencyTranslating(Texture) -- Uses the texture string/path to determine which currency it is, only way I know how right now.
    if (strmatch(Texture, "%a+_%d+$") == "variety_01") then -- Dalaran Jewelcrafter's Token
        return 61;
    elseif (strmatch(Texture, "%a+_%d+$") == "ribbon_01") then -- Epicurean's Award
        return 81;
    elseif (strmatch(Texture, "_(%a+)$") == "artofwar") then -- Champion's Seal
        return 241;
    elseif (strmatch(Texture, "_(%w+)$") == "argentdawn3") then -- Illustrious Jewelcrafter's Token
        return 361;
    elseif (strmatch(Texture, "$a+_%a+$") == "zone_tolbarad") then -- Tol Barad Commendation
        return 391;
    elseif (strmatch(Texture, "_(%a+)$") == "idolofferocity") then -- Ironpaw Token
        return 402;
    elseif (strmatch(Texture, "_(%a+)$") == "markoftheworldtree") then -- Mark of the World Tree
        return 416;
    elseif (strmatch(Texture, "%a+_%d+$") == "darkmoon_01") then -- Darkmoon Prize Ticket
        return 515;
    elseif (strmatch(Texture, "_(%a+)$") == "sealofkings") then -- Mote of Darkness
        return 614;
    elseif (strmatch(Texture, "%a+_%a+$") == "primal_shadow") then -- Essence of Corrupted Deathwing
        return 615;
    elseif (strmatch(Texture, "%a+_%d+$") == "coin_17") then -- Elder Charm of Good Fortune
        return 697;
    elseif (strmatch(Texture, "%a+_%d+$") == "coin_18") then -- Lesser Charm of Good Fortune
        return 738;
    elseif (strmatch(Texture, "%a+$") == "mogucoin") then -- Mogu Rune of Fate
        return 752;
    elseif (strmatch(Texture, "%a+$") == "timelesscoin") then -- Timeless Coin
        return 777;
    elseif (strmatch(Texture, "%a+-%a+$") == "timelesscoin-bloody") then -- Bloody Coin
        return 789;
    elseif (strmatch(Texture, "%a+_%a+$") == "apexis_draenor") then -- Apexis Crystal
        return 823;
    elseif (strmatch(Texture, "%a+_%a+$") == "garrison_resource") then -- Garrison Resources
        return 824;
    elseif (strmatch(Texture, "%a+_%a+$") == "ashran_artifact") then -- Artifact Fragment
        return 944;
    elseif (strmatch(Texture, "%a+_%a+$") == "ability_animusorbs") then -- Seal of Tempered Fate
        return 994;
    elseif (strmatch(Texture, "%a+_%a+_%d+$") == "misc_coin_09") then -- Dingy Iron Coins
        return 980;
    elseif (strmatch(Texture, "%a+_%a+_%a+$") == "reputation_kirintor_offensive") then -- Sightless Eye
        return 1149;
    elseif (strmatch(Texture, "%a+-%a+$") == "pvecurrency-justice") then -- Timewarped Badge
        return 1166;
    elseif (strmatch(Texture, "%a+-%a+$") == "pvecurrency-valor") then -- Valor
        return 1191;
    elseif (strmatch(Texture, "%a+%d+$") == "datacrystal01") then -- Nethershard
        return 1226;
    elseif (strmatch(Texture, "%a+_%a+$") == "orderhall_orderresources") then -- Order Resources
        return 1220;
    elseif (strmatch(Texture, "%a+_%a+$") == "misc_elvencoins") then -- Curious Coin
        return 1275;
    end
end

-- Prepare the various UI elements of the BuyEmAll frame and show it.

function BuyEmAll:Show(frame)
    self.typing = false;
    BuyEmAllLeftButton:Disable();
    BuyEmAllRightButton:Enable();

    BuyEmAllStackButton:Enable();
    if self.max < self.stackClick then
        BuyEmAllStackButton:Disable();
    end

    BuyEmAllFrame:ClearAllPoints();
    BuyEmAllFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0);

    BuyEmAllFrame:Show(frame);
    self:UpdateDisplay();
end


-- If the amount is more than stack and defaultStack, show a confirmation. Otherwise, do the purchase.

function BuyEmAll:VerifyPurchase(amount)
    amount = amount or self.split;
    if (amount > 0) then
        amount = (amount / self.preset) * self.preset;
        if amount > self.stack and amount > self.defaultStack then
            if BEAConfirmToggle == true then
                self:DoConfirmation(amount);
            else
                self:DoPurchase(amount);
            end
        else
            self:DoPurchase(amount);
        end
    end
end

-- This code is from Treeston on the MMO-Champion forums, and modified to suit my needs. Link: https://is.gd/25JTV1

local framePurchAmount, frameNumLoops, frameLeftover = 0, 0, 0; -- Have to use locals because the whole self bit doesn't work in this function. Fun fact, that still goes over my head. ;.;
local frameItemIndex;

local PurchaseLoopFrame = CreateFrame("Frame");
function BuyEmAll:onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if (self.sinceLastUpdate >= 0.5) then -- In seconds, this being half a second.
        if (frameNumLoops == 0) and (frameLeftover == 0) then
            PurchaseLoopFrame:SetScript("OnUpdate", nil); -- When purchasing is done, clear the script so it's not running constantly.
            return
        end
        if (frameNumLoops == 0) and (frameLeftover ~= 0) then
            BuyMerchantItem(frameItemIndex, frameLeftover);
            frameLeftover = 0;
        elseif (frameNumLoops > 0) then
            BuyMerchantItem(frameItemIndex, framePurchAmount);
            frameNumLoops = frameNumLoops - 1;
        end
        self.sinceLastUpdate = 0;
    end
end

-- End of code from Treeston.

-- Makes the actual purchase(s)
function BuyEmAll:DoPurchase(amount)
    BuyEmAllFrame:Hide();
    local numLoops, purchAmount, leftover;

    if amount <= self.stack then
        purchAmount = amount;
        numLoops = 1;
        leftover = 0;
    else
        if (amount % self.stack) > 0 then
            purchAmount = self.stack;
            numLoops = floor(amount / self.stack);
            leftover = amount % self.stack;
        else
            purchAmount = self.stack;
            numLoops = floor(amount / self.stack);
            leftover = 0;
        end
    end

    framePurchAmount = purchAmount;
    frameNumLoops = numLoops;
    if leftover == 0 then
        frameLeftover = 0;
    else
        frameLeftover = leftover;
    end
    frameItemIndex = self.itemIndex;

    PurchaseLoopFrame:SetScript("OnUpdate", BuyEmAll.onUpdate);
end


-- Changes the money display to however much amount of the item will cost. If amount is not specified, it uses the current split value.

function BuyEmAll:UpdateDisplay()
    local purchase = self.split;
    
    BuyEmAllLeftButton:Enable();
    BuyEmAllRightButton:Enable();
    BuyEmAllMaxButton:Enable();
    if (self.split == self.max) then
        BuyEmAllRightButton:Disable();
        BuyEmAllMaxButton:Disable();
    end
    if (self.AltCurrencyMode == false) and (self.split == 1) then
        BuyEmAllLeftButton:Disable();
    end
    if (self.AltCurrencyMode == true) and (self.split == self.preset) then
        BuyEmAllLeftButton:Disable();
    end

    self:SetStackClick();
    BuyEmAllStackButton:Enable();
    if self.max < self.stackClick then
        BuyEmAllStackButton:Disable();
    end
    
    if (self.AltCurrencyMode == false) then
        local cost = 0;
        if self.defaultStack > 1 then
            cost = purchase * (self.price / self.defaultStack);
        else
            cost = purchase * self.price;
        end
        cost = ceil(cost);
        local gold = floor(abs(cost / 10000));
        local silver = floor(abs(mod(cost / 100, 100)));
        local copper = floor(abs(mod(cost, 100)));

        BuyEmAllCurrencyAmt1:SetText(gold);
        BuyEmAllCurrencyAmt2:SetText(silver);
        BuyEmAllCurrencyAmt3:SetText(copper);
    elseif (self.AltCurrencyMode == true) then
        if ((purchase % self.preset) ~= 0) then
            if ((purchase % self.preset) <= (self.preset / 2)) then
                if ((purchase - (purchase % self.preset)) == 0) then
                    purchase = self.preset;
                end
                purchase = purchase - (purchase % self.preset);
            elseif ((purchase % self.preset) > (self.preset / 2)) then
                purchase = purchase + (self.preset - (purchase % self.preset));
            end
        end
        self.AltNumPurchases = purchase / self.preset; -- Adjustment for not being able to buy less than the preset of items using alternate currency.
        if ((self.NumAltCurrency == 1) or (self.NumAltCurrency == 2) or (self.NumAltCurrency == 3)) then
            local cost1 = self.AltNumPurchases * self.price1;
            BuyEmAllCurrencyAmt1:SetText(cost1);
            BuyEmAllCurrency1:SetTexture(self.AltCurrency1Tex);
        end
        if ((self.NumAltCurrency == 2) or (self.NumAltCurrency == 3)) then
            local cost2 = self.AltNumPurchases * self.price2;
            BuyEmAllCurrencyAmt2:SetText(cost2);
            BuyEmAllCurrency2:SetTexture(self.AltCurrency2Tex);
        end
        if ((self.NumAltCurrency == 3)) then
            local cost3 = self.AltNumPurchases * self.price3;
            BuyEmAllCurrencyAmt3:SetText(cost3);
            BuyEmAllCurrency3:SetTexture(self.AltCurrency3Tex);
        end
    end

    BuyEmAllText:SetText(self.split);
end


-- Shows the confirmation dialog.

function BuyEmAll:DoConfirmation(amount)
    local dialog = StaticPopup_Show("BUYEMALL_CONFIRM", amount, self.itemName);
    dialog.data = amount;
end


-- Calculates the amount that the Stack button will enter.

function BuyEmAll:SetStackClick()
    local increase = (self.partialFit == 0 and self.stack or self.partialFit) - (self.split % self.stack);
    self.stackClick = self.split + (increase == 0 and self.stack or increase);
end

function BuyEmAll:DeStackClick()
    local decrease = tonumber(BuyEmAllText:GetText());
    if decrease <= self.stack then
        self.split = 1;
        self:UpdateDisplay();
    else
        self.split = decrease - self.stack;
        self:UpdateDisplay();
    end
end


-- OnClick handler for the four main buttons.

function BuyEmAll:OnClick(frame, button)
    if frame == BuyEmAllOkayButton then
        local amount = tonumber(BuyEmAllText:GetText());
        self:VerifyPurchase(amount);
    elseif frame == BuyEmAllCancelButton then
        BuyEmAllFrame:Hide();
    elseif frame == BuyEmAllStackButton then
        if button == "LeftButton" then
            self.split = self.stackClick;
            self:UpdateDisplay();
            if frame:IsEnabled() == true then
                self:OnEnter(frame);
            else
                GameTooltip:Hide();
            end
        elseif button == "RightButton" then
            self:DeStackClick();
            if frame:IsEnabled() == true then
                self:OnEnter(frame);
            else
                GameTooltip:Hide();
            end
        end
    elseif frame == BuyEmAllMaxButton then
        self.split = self.max;
        self:UpdateDisplay();
    end
end


-- Allows you to type a number to buy. This is adapted directly from the Default UI's code.

function BuyEmAll:OnChar(text)
    if text < "0" or text > "9" then
        return
    end

    if self.typing == false then
        self.typing = true;
        self.split = 0;
    end

    local split = (self.split * 10) + text;

    if split == self.split then
        if self.split == 0 then
            self.split = 1;
        end
        self:UpdateDisplay();
        return
    end
    if split <= self.max then
        self.split = split;
    elseif (split > self.max) then
        self.split = self.max;
    elseif split == 0 then
        self.split = 1;
    end
    self:UpdateDisplay();
end


-- Key handler for keys other than 0-9.

function BuyEmAll:OnKeyDown(key)
    if key == "BACKSPACE" or key == "DELETE" then
        if self.typing == false or self.split == 1 then
            return
        end

        self.split = floor(self.split / 10);
        if self.split <= 1 then
            self.split = 1;
            self.typing = false;
        end

        self:UpdateDisplay();
    elseif key == "ENTER" then
        self:VerifyPurchase();
    elseif key == "ESCAPE" then
        BuyEmAllFrame:Hide();
    elseif key == "LEFT" or key == "DOWN" then
        BuyEmAll:Left_Click();
    elseif key == "RIGHT" or key == "UP" then
        BuyEmAll:Right_Click();
    elseif key == "PRINTSCREEN" then
        Screenshot();
    end
end


-- Decreases the amount by however much is necessary to go down to the next lowest multiple of the preset stack size.

function BuyEmAll:Left_Click()
    if (self.AltCurrencyMode == false) then
        self.split = self.split - 1;
        self:UpdateDisplay();
    else
        self.split = self.split - self.preset;
        self:UpdateDisplay();
    end
end


-- Increases the amount by however much is necessary to go up to the next highest multiple of the preset stack size.

function BuyEmAll:Right_Click()
    if (self.AltCurrencyMode == false) then
        self.split = self.split + 1;
        self:UpdateDisplay();
    else
        self.split = self.split + self.preset;
        self:UpdateDisplay();
    end
end


-- This table is used for the two functions that follow.

BuyEmAll.lines = {
    stack = {
        label = L.STACK_PURCH,
        field = "stackClick",
        { label = L.STACK_SIZE, field = "stack" },
        { label = L.PARTIAL, field = "partialFit" },
    },
    max = {
        label = L.MAX_PURCH,
        field = "max",
        { label = L.AFFORD, field = "afford" },
        { label = L.FIT, field = "fit" },
        {
            label = L.AVAILABLE,
            field = "available",
            Hide = function()
                return BuyEmAll.available <= 1
            end
        },
    },
}


-- Shows tooltips when you hover over the Stack or Max buttons.

function BuyEmAll:OnEnter(frame)
    local lines = self.lines[frame == BuyEmAllMaxButton and "max" or "stack"];

    lines.amount = self[lines.field];
    for i, line in ipairs(lines) do
        line.amount = self[line.field];
    end

    self:CreateTooltip(frame, lines);
end


-- Creates the tooltip from the given lines table. See the structure of lines above for more insight.

function BuyEmAll:CreateTooltip(frame, lines)
    GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetText(lines.label .. "|cFFFFFFFF - |r" .. GREEN_FONT_COLOR_CODE .. lines.amount .. "|r");

    for _, line in ipairs(lines) do
        if not (line.Hide and line.Hide()) then
            local color =
            line.amount == lines.amount and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
            GameTooltip:AddDoubleLine(line.label, line.amount, 1, 1, 1, color.r, color.g, color.b);
        end
    end

    --SetTooltipMoney(GameTooltip, ceil(lines.amount / self.preset) * self.price);
    -- Need to replace, but also need to understand tooltips more to do so.

    GameTooltip:Show();
end


-- Hides the tooltip.

function BuyEmAll:OnLeave()
    GameTooltip:Hide();

    --GameTooltip_ClearMoney(GameTooltip);
    -- Not needed because of previous commenting out.
end


-- When the BuyEmAll frame is closed, close any confirmations waiting for a response as well as clear the currencies.

function BuyEmAll:OnHide()
    BuyEmAllCurrency1:SetTexture();
    BuyEmAllCurrency2:SetTexture();
    BuyEmAllCurrency3:SetTexture();
    BuyEmAllCurrencyAmt1:SetText();
    BuyEmAllCurrencyAmt2:SetText();
    BuyEmAllCurrencyAmt3:SetText();
    StaticPopup_Hide("BUYEMALL_CONFIRM");
end