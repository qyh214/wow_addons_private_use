function wodrraonload()
	wodrraachdone1=true
	wodrracounter1=0
	wodrratimerfurnace=nil
	wodrratimerkromog=nil
	rscupdhpcheckhr=GetTime()

SetMapToCurrentZone()
if GetCurrentMapAreaID()==988 or GetCurrentMapAreaID()==1026 then
	RaidAchievement_wodrra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	RaidAchievement_wodrra:RegisterEvent("UNIT_POWER")
	RaidAchievement_wodrra:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
end
	RaidAchievement_wodrra:RegisterEvent("PLAYER_REGEN_DISABLED")
	RaidAchievement_wodrra:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	RaidAchievement_wodrra:RegisterEvent("ADDON_LOADED")
	
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
	if select(3,GetInstanceInfo())==17 then
		lfrenable=1
  else
    lfrenable=nil
  end


wodrraspisokach25={

8929,
8980, --http://www.wowhead.com/achievement=8980 Stamp Stamp Revolution
8930, --http://www.wowhead.com/achievement=8930 Ya, We've got time
8983, --http://www.wowhead.com/achievement=8983 Would you give me a hand

--6.2 patch
10026,
10057,

9972,
9979,

--9988,
9989,

10087,

}



if (wodrraspisokon==nil) then
wodrraspisokon={}
end


end


function wodrra_OnUpdate(curtime)


if rscupdhpcheckhr and GetTime()>rscupdhpcheckhr and GetCurrentMapAreaID()==1026 and UnitGUID("boss3") then
	rscupdhpcheckhr=GetTime()+2
	if wodrraspisokon[5]==1 and wodrraachdone1 then
	if (raGetUnitID(UnitGUID("boss3"))==90018) then
		local lhp1=UnitHealth("boss3")
		local lhp2=UnitHealthMax("boss3")
		if (lhp1 and lhp1>0 and lhp2 and lhp2>0) then
			--считаем
			if (lhp1<(lhp2*0.9)) then
				wodrrafailnoreason(5)
			end
		end
	end
	if (raGetUnitID(UnitGUID("boss2"))==90018) then
		local lhp1=UnitHealth("boss2")
		local lhp2=UnitHealthMax("boss2")
		if (lhp1 and lhp1>0 and lhp2 and lhp2>0) then
			--считаем
			if (lhp1<(lhp2*0.9)) then
				wodrrafailnoreason(5)
			end
		end
	end
	end
end




if rpradelayzonech and curtime>rpradelayzonech then
rpradelayzonech=nil
SetMapToCurrentZone()
if GetCurrentMapAreaID()==988 or GetCurrentMapAreaID()==1026 then
RaidAchievement_wodrra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
RaidAchievement_wodrra:RegisterEvent("UNIT_POWER")
RaidAchievement_wodrra:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
else
RaidAchievement_wodrra:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
RaidAchievement_wodrra:UnregisterEvent("UNIT_POWER")
RaidAchievement_wodrra:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
end
end


-- Ya, We've got time
if wodrratimerfurnace and GetTime()>wodrratimerfurnace then
   wodrratimerfurnace=nil -- reset timer since achievement is failed
   wodrrafailnoreason(3)
end

-- Would you give me a hand
if wodrratimerkromog and GetTime()>wodrratimerkromog then
   wodrratimerkromog=nil -- reset timer since achievement is failed
   wodrrafailnoreason(4,wodrracounter1)
   wodrraachdone1=true --продолжаем следить за ачивкой
   wodrracounter1=0
end

if rsprotossdb1 and #rsprotossdb1>0 and rastartprotosstimer and GetTime()>rastartprotosstimer then
	rastartprotosstimer=GetTime()+1
	for i=1,#rsprotossdb1 do
		if rsprotossdb1[i] then
			local ltime=GetTime()-rsprotossdb2[i]
			if ltime>5.5 then
				ltime=math.ceil(ltime*10)/10
				if wodrraspisokon[9]==1 and wodrraachdone1 then
					wodrrafailnoreason(9, rsprotossdb3[i].." (> "..ltime.." sec and STILL THERE)")
					table.remove(rsprotossdb1,i)
					table.remove(rsprotossdb2,i)
					table.remove(rsprotossdb3,i)
				end
			end
		end
	end
end







end


function wodrraonevent(self,event,...)

local arg1, arg2, arg3,arg4,arg5,arg6 = ...



if event == "PLAYER_REGEN_DISABLED" then
if (rabilresnut and GetTime()<rabilresnut+3) or racheckbossincombat then
else
--обнулять все данные при начале боя тут:
wodrraachdone1=true
wodrracounter1=0
wodrratimerfurnace=nil
wodrratimerkromog=nil
raramapwidth=nil
raramapheight=nil
psranormgolong=nil

rababahcount=nil

ramariotrack=nil
ramariotableguid=nil
ratableforgaroshach1=nil
ratableforgaroshach2=nil

rsprotossdb1=nil
rsprotossdb2=nil
rsprotossdb3=nil


	if UnitGUID("boss1") and UnitName("boss1")~="" then
		local id2=UnitGUID("boss1")
		local id=raGetUnitID(id2)

	else
		racrtimerbossrecheck=GetTime()+3
	end
end

end


if event == "CHAT_MSG_RAID_BOSS_EMOTE" then



end


if event == "ZONE_CHANGED_NEW_AREA" then

rpradelayzonech=GetTime()+2

	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
	if select(3,GetInstanceInfo())==17 then
		lfrenable=1
  else
    lfrenable=nil
  end

end

if event == "ADDON_LOADED" then
	if arg1=="RaidAchievement_WoDRaids" then

for i=1,#wodrraspisokach25 do
if wodrraspisokon[i]==nil then wodrraspisokon[i]=1 end
end
	end
end


if event == "UNIT_POWER" then
if UnitName("boss1") and UnitName("boss1")~="" then



end
end




if event == "COMBAT_LOG_EVENT_UNFILTERED" and lfrenable==nil then

local arg1, arg2, arg3,arg4,arg5,arg6,argNEW1,arg7,arg8,arg9,argNEW2,arg10,arg11,arg12,arg13,arg14, arg15,arg16,arg17,arg18,arg19 = ...


--ТУТ АЧИВЫ

--BRF (2 dung)
if GetCurrentMapAreaID()==988 then

if arg2=="UNIT_DIED" then
  if wodrraspisokon[1]==1 and wodrraachdone1 then
  local id=raGetUnitID(arg7)
  if id==77337 then
      wodrrafailnoreason(1)
    end
  end
end

-- Stamp Stamp Revolution

if (arg2=="SPELL_DAMAGE" and arg10==158140) and arg4 and arg8 then
   raunitisplayer(arg7,arg8)
   if raunitplayertrue then
      if wodrraspisokon[2]==1 and wodrraachdone1 then
         wodrrafailnoreason(2,arg8)
      end
   end
end

-- Ya, We've Got Time

if arg2=="UNIT_DIED" then
  if wodrraspisokon[3]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==76815 then
       wodrracounter1=wodrracounter1+1

       if wodrratimerfurnace==nil then -- start the timer if this was first kill
          wodrratimerfurnace=GetTime()+10
       end
       if wodrracounter1==4 then
          wodrratimerfurnace=nil -- reset timer since achievement is completed
          wodrraachcompl(3)
       end
     end
  end
end
-- Would you give me a hand
if arg2=="UNIT_DIED" then
  if wodrraspisokon[4]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==77893 then
       wodrracounter1=wodrracounter1+1

       if wodrratimerkromog==nil then -- start the timer if this was first kill
          wodrratimerkromog=GetTime()+5
       end
       if wodrracounter1>=10 then
          wodrratimerkromog=nil -- reset timer since achievement is completed
          wodrraachcompl(4)
       end
     end
  end
end
end
--
--

if GetCurrentMapAreaID()==1026 then
if arg2=="UNIT_DIED" then
  if wodrraspisokon[6]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==94808 then
       wodrracounter1=wodrracounter1+1

       if wodrracounter1==10 then
          wodrraachcompl(6)
       end
     end
  end
end

if arg2=="UNIT_DIED" then
  if wodrraspisokon[7]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==90980 then
          wodrrafailnoreason(7)
     end
  end
end

if arg2=="UNIT_DIED" then
  if wodrraspisokon[8]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==93145 then
          wodrraachcompl(8)
     end
  end
end

--Pro-toss // ОТКЛЮЧЕНО
if arg2=="SPELL_AURA_APPLIED" and arg10==1792029999 then
	if rsprotossdb1==nil then
		rsprotossdb1={}
		rsprotossdb2={}
		rsprotossdb3={}
	end
	local bil=0
	if (#rsprotossdb1>0) then
		for i=1,#rsprotossdb1 do
			if rsprotossdb1[i]==arg7 then
				rsprotossdb2[i]=GetTime()
				bil=1
			end
		end
	end
	if (bil==0) then
		table.insert(rsprotossdb1,arg7)
		table.insert(rsprotossdb2,GetTime())
		table.insert(rsprotossdb3,arg8)
		rastartprotosstimer=GetTime()
	end
end
if arg2=="SPELL_AURA_REMOVED" and arg10==1792029999 then
	if rsprotossdb1 and #rsprotossdb1>0 then
		for i=1,#rsprotossdb1 do
			if rsprotossdb1[i] then
				if rsprotossdb1[i]==arg7 then
					local ltime=GetTime()-rsprotossdb2[i]
					if ltime>5 then
						ltime=math.ceil(ltime*10)/10
						if wodrraspisokon[9]==1 and wodrraachdone1 then
							wodrrafailnoreason(9, arg8.." ("..ltime.." sec)")
							table.remove(rsprotossdb1,i)
							table.remove(rsprotossdb2,i)
							table.remove(rsprotossdb3,i)
						end
					end
				end
			end
		end
	end
end

if arg2=="UNIT_DIED" then
  if wodrraspisokon[9]==1 and wodrraachdone1 then
     local id=raGetUnitID(arg7)
     if id==90270 and UnitGUID("boss1") then
          wodrrafailnoreason(9)
     end
  end
end

if (arg2=="SPELL_AURA_APPLIED" and arg10==185656) and arg8 then
   raunitisplayer(arg7,arg8)
   if raunitplayertrue then
      if wodrraspisokon[10]==1 and wodrraachdone1 then
         wodrrafailnoreason(10,arg8)
      end
   end
end



end
--



end
end --КОНЕЦ ОНЕВЕНТ

function wodrra_closeallpr()
wodrramain6:Hide()
end


function wodrra_button2()
PSFea_closeallpr()
wodrramain6:Show()
openmenureportwodrra()



if (wodrranespamit==nil) then

wodrraspislun= # wodrraspisokach25
wodrracbset={}

for i=1,wodrraspislun do

if i>14 then
l=280
j=i-14
else
l=0
j=i
end

if GetAchievementLink(wodrraspisokach25[i]) then

local _, wodrraName, _, completed, _, _, _, Description, _, wodrraImage = GetAchievementInfo(wodrraspisokach25[i])

if completed then
wodrraName="|cff00ff00"..wodrraName.."|r"
else
--no more red
end



--текст
local f = CreateFrame("Frame",nil,wodrramain6)
f:SetFrameStrata("DIALOG")
f:SetWidth(248)
f:SetHeight(24)




f:SetScript("OnEnter", function(self) Raiccshowtxt(self,Description) end )
f:SetScript("OnLeave", function(self) Raiccshowtxt2() end )
f:SetScript("OnMouseDown", function(self) if IsShiftKeyDown() then if ChatFrame1EditBox:GetText() and string.len(ChatFrame1EditBox:GetText())>0 then ChatFrame1EditBox:SetText(ChatFrame1EditBox:GetText().." "..GetAchievementLink(wodrraspisokach25[i])) else ChatFrame_OpenChat(GetAchievementLink(wodrraspisokach25[i])) end end end )

--картинка
local t = f:CreateTexture(nil,"OVERLAY")
t:SetTexture(wodrraImage)
t:SetWidth(24)
t:SetHeight(24)
t:SetPoint("TOPLEFT",0,0)

local t = f:CreateFontString()
t:SetFont(GameFontNormal:GetFont(), rafontsset[2])
t:SetWidth(548)
if i==3 then
  t:SetText(wodrraName)
else
  t:SetText(wodrraName)
end
t:SetJustifyH("LEFT")
t:SetPoint("LEFT",27,0)


f:SetPoint("TOPLEFT",l+45,-14-j*30)
f:Show()

end

--чекбатон
local c = CreateFrame("CheckButton", nil, wodrramain6, "UICheckButtonTemplate")
c:SetWidth("25")
c:SetHeight("25")
c:SetPoint("TOPLEFT", l+20, -14-j*30)
c:SetScript("OnClick", function(self) wodrragalka(i) end )
table.insert(wodrracbset, c)


end --for i
wodrranespamit=1
end --nespam


wodrragalochki()




end --конец бутон2

function Raiccshowtxt(self,i)
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_TOP")
	GameTooltip:SetText(i)
end

function Raiccshowtxt2(i)
GameTooltip:Hide()
end


function wodrragalochki()
for i=1,#wodrraspisokach25 do
if(wodrraspisokon[i]==1)then wodrracbset[i]:SetChecked(true) else wodrracbset[i]:SetChecked(false) end
end
end

function wodrragalka(nomersmeni)
if wodrraspisokon[nomersmeni]==1 then wodrraspisokon[nomersmeni]=0 else wodrraspisokon[nomersmeni]=1 end
end

function wodrra_buttonchangeyn(yesno)
wodrraspislun= # wodrraspisokach25
for i=1,wodrraspislun do
wodrraspisokon[i]=yesno
end
wodrragalochki()
end

function wodrra_button1()
wodrraspislun= # wodrraspisokach25
for i=1,wodrraspislun do
if wodrraspisokon[i]==1 then wodrraspisokon[i]=0 else wodrraspisokon[i]=1 end
end
wodrragalochki()
end


function openmenureportwodrra()
if not DropDownMenureportwodrra then
CreateFrame("Frame", "DropDownMenureportwodrra", wodrramain6, "UIDropDownMenuTemplate")
end
rachatdropm(DropDownMenureportwodrra,5,7)
end



function raGetMapSize()
	-- try custom map size first
	local mapName = GetMapInfo()
	local floor, a1, b1, c1, d1 = GetCurrentMapDungeonLevel()

	--Blizzard's map size
	if not (a1 and b1 and c1 and d1) then
		local zoneIndex, a2, b2, c2, d2 = GetCurrentMapZone()
		a1, b1, c1, d1 = a2, b2, c2, d2
	end

	if not (a1 and b1 and c1 and d1) then return end
	return abs(c1-a1), abs(d1-b1)
end