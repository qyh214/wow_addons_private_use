if not IsAddOnLoaded('ElvUI') then return; end

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags');

local U = select(2, ...);
local L = {};

local function SetSlotFilter(self, bagID, slotID)
    local f = B:GetContainerFrame(bagID > NUM_BAG_SLOTS or bagID == BANK_CONTAINER);
    if not (f and f.FilterHolder) then return; end

    if f.FilterHolder.active and self.Bags[bagID] and self.Bags[bagID][slotID] then
        local link = GetContainerItemLink(bagID, slotID);
        if not link or f.FilterHolder[f.FilterHolder.active].filter(link, select(12, GetItemInfo(link))) then
            self.Bags[bagID][slotID].searchOverlay:Hide();
        else
            self.Bags[bagID][slotID].searchOverlay:Show();
        end
    end
end

local function SetFilter(self)
    local f = B:GetContainerFrame(self.isBank);
    if not (f and f.FilterHolder) then return; end

    for i = 1, U.numFilters do
        if i ~= self:GetID() then
            f.FilterHolder[i]:SetChecked(nil);
        end
    end
    f.FilterHolder.active = self:GetID();
        
    for i, bagID in ipairs(f.BagIDs) do
        if f.Bags[bagID] then
            for slotID = 1, f.Bags[bagID].numSlots do
                SetSlotFilter(f, bagID, slotID);
            end
        end
    end
end

local function ResetFilter(self)
    local f = B:GetContainerFrame(self.isBank);
    if not (f and f.FilterHolder) then return; end

    if f.FilterHolder.active then
        f.FilterHolder[f.FilterHolder.active]:SetChecked(nil);
        f.FilterHolder.active = nil;
        
        for i, bagID in ipairs(f.BagIDs) do
            if f.Bags[bagID] then
                for slotID = 1, f.Bags[bagID].numSlots do
                    if f.Bags[bagID][slotID] then
                        f.Bags[bagID][slotID].searchOverlay:Hide();
                    end
                end
            end
        end
    end
end
    
local function AddFilterButtons(f, isBank)
    local buttonSize = isBank and B.db.bankSize or B.db.bagSize;
    local buttonSpacing = E.Border * 2;
    local lastContainerButton;

    for i, filter in ipairs(U.Filters) do
        if not f.FilterHolder[i] then
            local name, icon, func = unpack(filter);

            f.FilterHolder[i] = CreateFrame('CheckButton', nil, f.FilterHolder);
            f.FilterHolder[i]:SetTemplate('Default', true);
            f.FilterHolder[i]:StyleButton();
            f.FilterHolder[i]:SetNormalTexture('');
            f.FilterHolder[i]:SetPushedTexture('');
            f.FilterHolder[i].ttText = name;
            f.FilterHolder[i].filter = func;
            f.FilterHolder[i].isBank = isBank;
            f.FilterHolder[i]:SetScript('OnEnter', B.Tooltip_Show);
            f.FilterHolder[i]:SetScript('OnLeave', B.Tooltip_Hide);
            f.FilterHolder[i]:SetScript('OnClick', SetFilter);
            f.FilterHolder[i]:SetScript('OnHide', ResetFilter);
            f.FilterHolder[i]:SetID(i);

            f.FilterHolder[i].iconTexture = f.FilterHolder[i]:CreateTexture();
            f.FilterHolder[i].iconTexture:SetInside();
            f.FilterHolder[i].iconTexture:SetTexCoord(unpack(E.TexCoords));
            f.FilterHolder[i].iconTexture:SetTexture(icon);
        end
        
        f.FilterHolder:Size(((buttonSize + buttonSpacing) * i) + buttonSpacing, buttonSize + (buttonSpacing * 2));
          
        f.FilterHolder[i]:Size(buttonSize);
        f.FilterHolder[i]:ClearAllPoints();
        if i == 1 then
            f.FilterHolder[i]:SetPoint('BOTTOMLEFT', f.FilterHolder, 'BOTTOMLEFT', buttonSpacing, buttonSpacing)
        else
            f.FilterHolder[i]:SetPoint('LEFT', lastContainerButton, 'RIGHT', buttonSpacing, 0);
        end
        
        lastContainerButton = f.FilterHolder[i];
    end
end

local function AddMenuButton(isBank)
    if E.private.bags.enable ~= true then return; end
    local f = B:GetContainerFrame(isBank);
    
    if not f or f.FilterHolder then return; end
    f.FilterHolder = CreateFrame('Button', nil, f);
    f.FilterHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1);
    f.FilterHolder:SetTemplate('Transparent');
    f.FilterHolder:Hide();
    
    f.filterButton = CreateFrame('Button', nil, f.holderFrame);
    f.filterButton:SetSize(16 + E.Border, 16 + E.Border);
    f.filterButton:SetTemplate();
    f.filterButton:SetPoint("RIGHT", f.sortButton, "LEFT", -5, 0);
    f.filterButton:SetNormalTexture("Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_BOUNTIFULBAGS");
    f.filterButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
    f.filterButton:GetNormalTexture():SetInside();
    f.filterButton:SetPushedTexture("Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_BOUNTIFULBAGS");
    f.filterButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords));
    f.filterButton:GetPushedTexture():SetInside();
    f.filterButton:StyleButton(nil, true);
    f.filterButton.ttText = L.Filter;
    f.filterButton:SetScript('OnEnter', B.Tooltip_Show);
    f.filterButton:SetScript('OnLeave', B.Tooltip_Hide);
    f.filterButton:SetScript('OnClick', function() 
        f.ContainerHolder:Hide();
        ToggleFrame(f.FilterHolder);
    end);
    
    f.bagsButton:HookScript('OnClick', function()
        f.FilterHolder:Hide();
    end);
    
    -- realign
    f.bagsButton:SetPoint("RIGHT", f.filterButton, "LEFT", -5, 0);

    AddFilterButtons(f, isBank);
 end

do
    L.Weapon = AUCTION_CATEGORY_WEAPONS;
    L.Armor = AUCTION_CATEGORY_ARMOR;
    L.Container = AUCTION_CATEGORY_CONTAINERS;
    L.Consumable = AUCTION_CATEGORY_CONSUMABLES;
    L.Glyph = AUCTION_CATEGORY_GLYPHS;
    L.TradeGood = AUCTION_CATEGORY_TRADE_GOODS;
    L.Recipe = AUCTION_CATEGORY_RECIPES;
    L.Gem = AUCTION_CATEGORY_GEMS;
    L.Misc = AUCTION_CATEGORY_MISCELLANEOUS;
    L.Quest = AUCTION_CATEGORY_QUEST_ITEMS;
    L.BattlePets = AUCTION_CATEGORY_BATTLE_PETS;
    L.Enhancement = AUCTION_CATEGORY_ITEM_ENHANCEMENT;
    L.Power = ARTIFACT_POWER;

    L.All = ALL;
    L.Equipment = L.Weapon .. ' & ' .. L.Armor;
    L.Filter = FILTER;
    
    U.Filters = {
        { L.All, 'Interface/Icons/INV_Misc_EngGizmos_17', 
          function(link, type, subType) 
              return true;
          end
        },
        { L.Equipment, 'Interface/Icons/INV_Chest_Chain_04', 
          function(link, type, subType) 
              return type == LE_ITEM_CLASS_ARMOR or type == LE_ITEM_CLASS_WEAPON; 
          end
        },
        { L.Consumable, 'Interface/Icons/INV_Potion_93', 
          function(link, type, subType) 
              return type == LE_ITEM_CLASS_CONSUMABLE;
          end
        },
        { L.Quest, 'Interface/QuestFrame/UI-QuestLog-BookIcon',
          function(link, type, subType)
              return type == LE_ITEM_CLASS_QUESTITEM;
          end
        },
        { L.TradeGood, 'Interface/Icons/INV_Fabric_Silk_02',
          function(link, type, subType)
              return type == LE_ITEM_CLASS_TRADEGOODS or 
                type == LE_ITEM_CLASS_RECIPE or type == LE_ITEM_CLASS_GEM or 
                type == LE_ITEM_CLASS_ITEM_ENHANCEMENT or type == LE_ITEM_CLASS_GLYPH;
          end
        },
        { L.Power, 'Interface/Icons/INV_Artifact_XP01',
          function(link, type, subType)
              return type == LE_ITEM_CLASS_CONSUMABLE and link:find(":8388608:");
          end
        },
        { L.Misc, 'Interface/Icons/INV_Misc_Rune_01',
          function(link, type, subType)
              return type == LE_ITEM_CLASS_MISCELLANEOUS or
                type == LE_ITEM_CLASS_BATTLEPET or type == LE_ITEM_CLASS_CONTAINER;
          end
        },
    };
       
    U.numFilters = #U.Filters;
    
    hooksecurefunc(B, 'Layout', function(self, isBank)
        AddMenuButton(isBank);
    end);
    
    hooksecurefunc(B, 'UpdateSlot', SetSlotFilter);
end