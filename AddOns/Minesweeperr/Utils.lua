local _, _MS = ...

_MS.UTILS = {}

local _U = _MS.UTILS

_U.FLAG = {}
_U.FLAG.REFRESH_GEAR_FLAG = false
_U.FLAG.REFRESH_ACHI_FLAG = false

function _U.FLAG.getRefreshFlag()
    return _U.FLAG.REFRESH_GEAR_FLAG or _U.FLAG.REFRESH_ACHI_FLAG 
end

function _U.FLAG.lockRefreshFlag()
    _U.FLAG.REFRESH_GEAR_FLAG = true
    _U.FLAG.REFRESH_ACHI_FLAG = true
end

function _U.FLAG.releaseRefreshFlag()
    _U.FLAG.REFRESH_GEAR_FLAG = false
    _U.FLAG.REFRESH_ACHI_FLAG = false
end

function _U.FLAG.getGearRefreshFlag()
    return _U.FLAG.REFRESH_GEAR_FLAG
end

function _U.FLAG.getAchiRefreshFlag()
    return _U.FLAG.REFRESH_ACHI_FLAG 
end

function _U.FLAG.lockGearRefreshFlag()
    _U.FLAG.REFRESH_GEAR_FLAG = true
end

function _U.FLAG.lockAchiRefreshFlag()
    _U.FLAG.REFRESH_ACHI_FLAG = true
end

function _U.FLAG.releaseGearRefreshFlag()
    _U.FLAG.REFRESH_GEAR_FLAG = false
end

function _U.FLAG.releaseAchiRefreshFlag()
    _U.FLAG.REFRESH_ACHI_FLAG = false
end

_U.FLAG.MEMBER_CHANGED_FLAG = false
function _U.FLAG.getMemberChangedFlag()
    return _U.FLAG.MEMBER_CHANGED_FLAG
end

function _U.FLAG.lockMemberChangedFlag()
    _U.FLAG.MEMBER_CHANGED_FLAG = true
end

function _U.FLAG.releaseMemberChangedFlag()
    _U.FLAG.MEMBER_CHANGED_FLAG = false
end




function _U.Striping(self, f)
    assert(f, "doesn't exist!")
	local frameName = f.GetName and f:GetName()
	if f.styling then return end
	local style = CreateFrame("Frame", frameName or nil, f)
    local stripes = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER", f)
    stripes:ClearAllPoints()
    stripes:SetPoint("TOPLEFT", 1, -1)
    stripes:SetPoint("BOTTOMRIGHT", -1, 1)
    stripes:SetTexture([[Interface\AddOns\Minesweeperr\media\stripes]], true, true)
    stripes:SetHorizTile(true)
    stripes:SetVertTile(true)
    stripes:SetBlendMode("ADD")
    style.stripes = stripes
	style:SetFrameLevel(f:GetFrameLevel() + 1)
	f.styling = style
end


function _U.setFrameTexture(self, f, edgeSize, bgTexture)
    if not bgTexture then
       bgTexture = "Interface\\AddOns\\Minesweeperr\\media\\normTex"
    end
    f:SetBackdrop({
          bgFile = bgTexture,
          insets = {left = 1,right = 1,top = 1,bottom = 1},
          edgeFile = "Interface\\AddOns\\Minesweeperr\\media\\normTex",
          edgeSize = edgeSize,
    })
 end

 function _U.setFrameColor(self, f, bgR, bgG, bgB, bgA, egR, egG, egB, egA)
    f:SetBackdropColor(bgR, bgG, bgB, bgA)
    f:SetBackdropBorderColor(egR, egG, egB, egA)
 end

 function _U.setFrameText(self, f, text, size, pa, ca, offsetx, offsety)
    f.Text = f:CreateFontString(nil, "OVERLAY")
    f.Text:SetFont("Interface\\Addons\\Minesweeperr\\media\\font.ttf", size, "THINOUTLINE") 
    f.Text:SetText(text)
    f.Text:SetPoint(pa, f, ca, offsetx, offsety)
 end

 function _U.setFrameMouseSizeEffect(self, f, oriSize, actSize)
    f:SetScript('OnEnter', function() f:SetSize(actSize, actSize) end)
    f:SetScript('OnLeave', function() f:SetSize(oriSize, oriSize) end)
 end

 function _U.setBtnMouseColorEffect(self, f)
    f:SetScript('OnEnter', function() f:SetBackdropColor(0.1, 0.1, 0.1, 0.9) end)
    f:SetScript('OnLeave', function() f:SetBackdropColor(0, 0, 0, 0.9) end)
 end

 function _U.setRefreshMouseColorEffect(self, f)
    f:SetScript('OnEnter', function() f:SetBackdropColor(0.7, 0.7, 0.7, 0.9) end)
    f:SetScript('OnLeave', function() f:SetBackdropColor(0.25, 0.25, 0.25, 0.9) end)
 end

 function _U.setRefreshMouseAnimation(self, f, duration)
    local ag = f:CreateAnimationGroup()    
    local rotate = ag:CreateAnimation("Rotation")
    rotate:SetDegrees(360/3.5*duration)
    rotate:SetDuration(duration)
    f.ag = ag
 end

 function _U.setFrameMovable(self, f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
 end

function _U.getN(self, map)
    local count = 0
    for k,v in pairs(map) do count = count + 1 end
    return count
end



_MS.waitTable = {}
_MS.waitFrame = nil

function _U.wait(self, delay, func, ...)
    if(type(delay)~="number" or type(func)~="function") then
        return false;
    end
    if(_MS.waitFrame == nil) then
        _MS.waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
        _MS.waitFrame:SetScript("onUpdate", function (self, elapse)
            local count = #_MS.waitTable;
            local i = 1;
            while(i <= count) do
                local waitRecord = tremove(_MS.waitTable,i);
                local d = tremove(waitRecord,1);
                local f = tremove(waitRecord,1);
                local p = tremove(waitRecord,1);
                if(d>elapse) then
                    tinsert(_MS.waitTable,i,{d-elapse,f,p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(_MS.waitTable,{delay,func,{...}});
    return true;
end


function _U.toString(self, tbl)
    local result = "{"
    for k, v in pairs(tbl) do
       -- Check the key type (ignore any numerical keys - assume its an array)
       if type(k) == "string" then
          result = result.."[\""..k.."\"]".."="
       end
       
       -- Check the value type
       if type(v) == "table" then
          result = result.._U:toString(v)
       elseif type(v) == "boolean" then
          result = result..tostring(v)
       else
          result = result.."\""..v.."\""
       end
       result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "{" then
       result = result:sub(1, result:len()-1)
    end
    return result.."}"
 end



function _U.createMessage(self, type, body)
    local message = {}
    message["prefix"] = "MS"
    message["type"] = type
    message["body"] = body
    return _U:toString(message)
end




-- ----------
-- List

_U.List = {}
function _U.List.new ()
    return {first = 0, cur = nil, keys = {}}
end

function _U.List.push (self, list, value, key)
    if list.keys[key] then
        return
    end
    list.keys[key] = 1
    local first = list.first + 1
    list.first = first
    list[first] = {}
    list[first]["key"] = key
    list[first]["value"] = value
    if getn(list) > 10 then
        list[first-9] = nil
    end
end

function _U.List.pop (self, list)
    if not list.cur then
        list.cur = list.first
    end
    local value = list[list.cur]
    if value then
        list.cur = list.cur - 1
        return value["value"]
    else
        list.cur = nil
        return value
    end
end
