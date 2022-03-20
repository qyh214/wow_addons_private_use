--自定义体API，启用描边禁用阴影，可读性较佳
local function SetFont(obj, optSize)
  local fontName, _,fontFlags = obj:GetFont()
  obj:SetFont(fontName, optSize, "OUTLINE")
  obj:SetShadowOffset(0, 0)
end

local function default()
  --启用名字模式，注意这个CVAR是全局的，所以使用时必需搭配姓名板插件，否则敌方姓名板也没有血条
  --如果你哪天不用这段代码了，光删代码删插件没用，要在游戏里输入 /run SetCVar("nameplateShowOnlyNames", 0) 才能恢复设置
  if IsInInstance() then
    -- 在副本中启用名字模式
    -- 显示友方血条血条
    SetCVar("nameplateShowFriends", 1)
    SetCVar("nameplateShowOnlyNames", 1)
    
    --禁用点击，使用之后，对于友方玩家，点名字无法选中目标，要选模型
    C_NamePlate.SetNamePlateFriendlyClickThrough(true)
    --友方显示条件，把非玩家都隐去
    SetCVar("nameplateShowFriendlyGuardians", 0) --守护者
    SetCVar("nameplateShowFriendlyMinions", 0) --仆从
    SetCVar("nameplateShowFriendlyNPCs", 0) --npc
    SetCVar("nameplateShowFriendlyPets", 0) --宠物
    SetCVar("nameplateShowFriendlyTotems", 0) --图腾
  else
    --不在副本中，关闭名字模式
    SetCVar("nameplateShowFriends", 0)
    SetCVar("nameplateShowOnlyNames", 0)

    C_NamePlate.SetNamePlateFriendlyClickThrough(false)
    SetCVar("nameplateShowFriendlyGuardians", 1) --守护者
    SetCVar("nameplateShowFriendlyMinions", 1) --仆从
    SetCVar("nameplateShowFriendlyNPCs", 1) --npc
    SetCVar("nameplateShowFriendlyPets", 1) --宠物
    SetCVar("nameplateShowFriendlyTotems", 1) --图腾
  end

  --全局配置
  --将自定义字体API套用到姓名板的文字上
  SetFont(SystemFont_LargeNamePlate, 12)
  SetFont(SystemFont_NamePlate, 12)
  SetFont(SystemFont_LargeNamePlateFixed, 12)
  SetFont(SystemFont_NamePlateFixed, 12)
  SetFont(SystemFont_NamePlateCastBar, 12)
    
  --将友方姓名板的框架尺寸设为1，由于暴雪的CVAR只是单纯的隐藏血条，必需做这个设置，才能在堆叠模式下不挤占敌方姓名板空间
  C_NamePlate.SetNamePlateFriendlySize(1,1)

  --将全局缩放设为1，否则引起掉帧(7.0最严重能掉一半，9.0掉个1/3吧)
  SetCVar("namePlateMinScale", 1)
  SetCVar("namePlateMaxScale", 1)
  
  --下面随喜好
  --边缘贴齐
  SetCVar("nameplateOtherTopInset", .08)
  SetCVar("nameplateOtherBottomInset", .1)
  SetCVar("nameplateLargeTopInset", .08)
  SetCVar("nameplateLargeBottomInset", .1)
  --堆叠堆叠模式时的堆叠间距
  SetCVar("nameplateOverlapH", 0.3) --default is 0.8
  SetCVar("nameplateOverlapV", 0.7) --default is 1.1
end

--载入事件
local frame = CreateFrame("FRAME")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:SetScript("OnEvent", default)
