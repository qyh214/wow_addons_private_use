local id, e = ...
local addName= POWER_TYPE_FOOD
local Save={
    itemClass={},--物品类型
    noUseItems={},--禁用物品
    --autoLogin= e.Player.husandro,--启动,查询
    onlyMaxExpansion=true,--仅本版本物品
    autoWho=e.Player.husandro
}

local panel= CreateFrame("Frame")
local Buttons={}
local itemClass={}--物品列表
local button

local function setPanelPostion()--设置按钮位置
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('RIGHT', WoWToolsOpenItemsButton, 'LEFT')
    end
end

local function set_Item_Cooldown_Count(self)--图标冷却
    if self.itemID then
        local start, duration, enable = GetItemCooldown(self.itemID)
        local num= GetItemCount(self.itemID, nil, true, true)
        local notFind= enable==0 or num==0
        if notFind then
            if self.cooldown then
                self.cooldown:Clear()
            end
        else
            e.Ccool(self, start, duration, nil, true, nil, true)--冷却条
        end
        self.count:SetText(num>1 and num or (num==1 and Save.autoWho) and num or '')
        self.texture:SetDesaturated(notFind)
    end
end


--#########
--提示, 事件
--#########
local function set_Button_Init(self)
    if not self.itemID then
        self:UnregisterAllEvents()
        return
    end
    e.LoadDate({id=self.itemID, type='item'})

    self:SetAttribute("type", "item")
    self:SetAttribute("item", C_Item.GetItemNameByID(self.itemID))
    self.texture:SetTexture(C_Item.GetItemIconByID(self.itemID))

    if not self.count then--设置, 数量
        self.count= e.Cstr(self, {size=10, color=true})--10, nil,nil, true)
        self.count:SetPoint('BOTTOMRIGHT', -4,4)
    end

    self:SetScript("OnEnter",function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self2.itemID)
        e.tips:AddLine(' ')
        if self==button then
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        else
            e.tips:AddDoubleLine(e.onlyChinese and '禁用' or DISABLE, 'Shift+'..e.Icon.right)
        end
        e.tips:Show()
    end)
    self:SetScript("OnLeave",function() e.tips:Hide() end)

    self:RegisterEvent('BAG_UPDATE')
    self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    self:SetScript("OnEvent", set_Item_Cooldown_Count)
    if self~=button then
        self:SetScript('OnMouseDown',function(self2, d)
            if d=='RightButton' and IsShiftKeyDown() then
                Save.noUseItems[self2.itemID]=true
                local link= select(2, GetItemInfo(self2.itemID))
                print(id, addName, e.onlyChinese and '禁用' or DISABLE, link or self2.itemID, '|cnRED_FONT_COLOR:', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end)
    end
    set_Item_Cooldown_Count(self)
end

local function find_Item_Type(class, subclass)
    local tab={}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink and info.itemID and GetItemSpell(info.itemID) then
                local classID, subClassID, _, expacID = select(12, GetItemInfo(info.hyperlink))
                if classID==class and subClassID==subclass and (Save.onlyMaxExpansion and (info.itemID==113509 or e.ExpansionLevel==expacID) or not Save.onlyMaxExpansion) then
                    e.LoadDate({id=info.itemID, type='item'})
                    table.insert(tab, info.itemID)
                end
            end
        end
    end
    return tab
end

local function create_Button(self)
    self= self or button
    local btn= e.Cbtn2(nil, self, true, nil)
    btn:SetPoint('RIGHT', self, 'LEFT')
    return btn
end

for classID=0, 20 do
    if classID~=10 then
        local className=GetItemClassInfo(classID)--生成,物品列表
        if className then
            for subClassID= 0, 20 do
                local subclassName=GetItemSubClassInfo(classID, subClassID)
                if subclassName and subclassName~='' then
                    local tab={
                        className=className,
                        subclassName=subclassName,
                        classID=classID,
                        subClassID=subClassID
                    }
                    table.insert(itemClass, tab)
                else
                    break
                end
            end
        else
            break
        end
    end
end


local function set_Item_Button()--检查,物品
    if UnitAffectingCombat('player') then
        panel.bat=true
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    local index=1
    local created={}
    for _, tab in pairs(itemClass) do
        if Save.itemClass[tab.className..tab.subclassName] then
            local Tabs=find_Item_Type(tab.classID, tab.subClassID)
            for _, itemID in pairs(Tabs) do
                if not Save.noUseItems[itemID] and itemID~=button.itemID and not created[itemID] then
                    local btn= Buttons[index]
                    btn= btn or create_Button(Buttons[index-1])
                    btn.itemID= itemID
                    Buttons[index]=btn
                    set_Button_Init(btn)
                    btn:SetShown(true)
                    index= index +1
                    created[itemID]=true
                end
            end
        end
    end

    for i= index , #Buttons do
        local btn= Buttons[i]
        btn.itemID=nil
        set_Button_Init(btn)
        btn:SetShown(false)
    end
end






--#####
--主菜单
--#####
local function get_Save_itemClass_Select()--已选中类别, 数量
    local num=0
    for _ in pairs(Save.itemClass) do
        num=num+1
    end
    return num
end

local function set_auto_Who_Event()--设置事件,自动更新
    if Save.autoWho and get_Save_itemClass_Select()>0 then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
    else
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')
    end
end
local function get_Save_Numer_SubClass(name)--子类, 选中数量
    local num=0
    for className,_ in pairs(Save.itemClass) do
        if className:find(name..'(.+)') then
            num= num+1
        end
    end
    return num==0 and '' or '|cnGREEN_FONT_COLOR:'..num..'|r'
end

local function InitMenu(self, level, type)--主菜单
    if UnitAffectingCombat('player') then
        return
    end
    local info
    if type=='DISABLE' then
        for itemID, _ in pairs(Save.noUseItems) do
            local itemLink, _, _, _, _, _,_, _, itemTexture = select(2, GetItemInfo(itemID))
            info={
                text= itemLink or ('itemID '..itemID),
                notCheckable=true,
                icon=itemTexture,
                tooltipOnButton=true,
                tooltipTitle=e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                func=function()
                    Save.noUseItems[itemID]=nil
                    set_Item_Button()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            disabled=bat,
            func= function()
                Save.noUseItems={}
                set_Item_Button()
                print(id, addName, CLEAR_ALL, DISABLE, ITEMS, DONE)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='WHO' then
        info= {
            text= e.onlyChinese and '登录游戏时: 查找' or (LOGIN or SOCIAL_TWITTER_SIGN_IN)..GAME,
            tooltipOnButton=true,
            tooltipTitle=AUTO_JOIN:gsub(JOIN,WHO),
            tooltipText='1 '..VOICEMACRO_LABEL_CHARGE1,
            checked=Save.autoLogin,
            func= function()
                Save.autoLogin= not Save.autoLogin and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info= {--自动, 更新物品, 查询
            text= e.onlyChinese and '自动查找' or UPDATE..ITEMS,
            tooltipOnButton=true,
            tooltipTitle=EVENTS_LABEL..': BAG_UPDATE_DELAYED',
            checked=Save.autoWho,
            func= function()
                Save.autoWho= not Save.autoWho and true or nil
                if Save.autoWho then
                    set_Item_Button()
                end
                set_auto_Who_Event()--设置事件,自动更新
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '仅当前版本物品' or 	LFG_LIST_CROSS_FACTION:format(REFORGE_CURRENT..(VERSION or GAME_VERSION_LABEL)),
            checked= Save.onlyMaxExpansion,
            tooltipOnButton=true,
            tooltipTitle= e.ExpansionLevel,
            func= function()
                Save.onlyMaxExpansion= not Save.onlyMaxExpansion and true or nil
                set_Item_Button()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type then
        for _, tab in pairs(itemClass) do
            if type==tab.className then
                info={
                    text=tab.subClassID..' '..tab.subclassName,
                    checked= Save.itemClass[tab.className..tab.subclassName],
                    tooltipOnButton=true,
                    tooltipTitle= tab.className.. ' classID |cnGREEN_FONT_COLOR:'..tab.classID..'|r',
                    tooltipText= tab.subclassName..' subClassID |cnGREEN_FONT_COLOR:'..tab.subClassID..'|r',
                    func=function()
                        Save.itemClass[tab.className..tab.subclassName]= not Save.itemClass[tab.className..tab.subclassName] and true or nil
                        set_Item_Button()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        return
    end

    local classNum=get_Save_itemClass_Select()
    info={
        text='|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '查找' or WHO).. e.Icon.mid..' '..classNum,
        colorCode='|cff00ff00',
        notCheckable=true,
        disabled=classNum==0,
        menuList='WHO',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN,
        func= function()
            set_Item_Button()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    local find={}
    for _, tab in pairs(itemClass) do
        if not find[tab.className] then
            info={
                text=get_Save_Numer_SubClass(tab.className)..tab.className,
                notCheckable=true,
                menuList=tab.className,
                hasArrow=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find[tab.className]=true
        end
    end

    info={
        text=e.Icon.up2.. (e.onlyChinese and '全部取消' or CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL)),
        colorCode= '|cffff0000',
        notCheckable=true,
        func= function()
            Save.itemClass={}
            set_Item_Button()
            print(id, addName, CALENDAR_EVENT_REMOVED_MAIL_SUBJECT:format(ALL), DONE)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info= {
        text= e.onlyChinese and '禁用' or DISABLE,
        notCheckable=true,
        menuList='DISABLE',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info= {
        text= e.Icon.right.. (e.onlyChinese and '移动' or NPE_MOVE),
        isTitle= true,
        notCheckable= true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '还原位置' or RESET_POSITION,
        notCheckable=true,
        colorCode= not Save.point and'|cff606060',
        func=function()
            Save.point=nil
            button:ClearAllPoints()
            setPanelPostion()--设置按钮位置
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

--####
--初始
--####
local function Init()
    for itemID, _ in pairs(Save.noUseItems) do
        e.LoadDate({id=itemID, type='item'})
    end

    setPanelPostion()--设置按钮位置
    button:SetSize(30, 30)

    set_Button_Init(button)--提示, 事件

    if Save.autoWho then
        set_auto_Who_Event()--设置事件,自动更新
    end
    if  get_Save_itemClass_Select()>0 and (Save.autoLogin or Save.autoWho) then
        set_Item_Button()
    end

    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetScript("OnDragStart", function(self,d)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        e.LibDD:CloseDropDownMenus()
    end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    button:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    button:SetScript('OnMouseWheel',function(self,d)
        if d==-1 and not IsModifierKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, e.onlyChinese and '查询' or WHO, '|cnRED_FONT_COLOR:'..COMBAT )
            else
                set_Item_Button()
            end
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if not WoWToolsSave[addName..'Tools'] then--初始,类, 设置
                local className=GetItemClassInfo(0)
                Save.itemClass={
                    [className..GetItemSubClassInfo(0, 1)]=true,--药水
                    [className..GetItemSubClassInfo(0, 2)]=true,--药剂
                    [className..GetItemSubClassInfo(0, 3)]=true,--合计
                    [className..GetItemSubClassInfo(0, 5)]=true,--食物
                }
            end

            Save= WoWToolsSave[addName..'Tools'] or Save

            if not e.toolsFrame.disabled then
                button=e.Cbtn2(nil, WoWToolsMountButton, true, nil)
                button.itemID= 5512--治疗石
                set_Button_Init(button)--提示, 事件

                panel:RegisterEvent("PLAYER_LOGOUT")

                C_Timer.After(2.3, function()
                    if UnitAffectingCombat('player') then
                        panel.setInitBat=true
                        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
                    else
                        Init()--初始
                    end
                end)
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Item_Button()--检查,物品

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.bat then
            set_Item_Button()--检查,物品
            panel.bat=nil

        elseif panel.setInitBat then
            Init()--初始
            panel.setInitBat=nil
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)