local env = select(2, ...)
local UIKit_TagManager = env.modules:Import("packages\\ui-kit\\tag-manager")
local UIAnim_Easing = env.modules:Import("packages\\ui-anim\\easing")
local UIAnim_Enum = env.modules:Import("packages\\ui-anim\\enum")
local UIAnim_Processor = env.modules:New("packages\\ui-anim\\processor")

local type = type
local math_pi = math.pi

local PROP_ALPHA = UIAnim_Enum.Property.Alpha
local PROP_SCALE = UIAnim_Enum.Property.Scale
local PROP_WIDTH = UIAnim_Enum.Property.Width
local PROP_HEIGHT = UIAnim_Enum.Property.Height
local PROP_POSX = UIAnim_Enum.Property.PosX
local PROP_POSY = UIAnim_Enum.Property.PosY
local PROP_ROTATION = UIAnim_Enum.Property.Rotation
local APPLY_METHOD = 1
local APPLY_POS_X = 2
local APPLY_POS_Y = 3
local APPLY_ROTATION = 4

function UIAnim_Processor.ResolveTarget(target)
    return type(target) == "string" and UIKit_TagManager.GetElementById(target) or target
end

function UIAnim_Processor.GetEasing(easingName)
    local func = UIAnim_Easing[easingName]
    return type(func) == "function" and func or UIAnim_Easing.Linear
end

function UIAnim_Processor.Apply(target, property, value)
    if not target then return end

    if property == PROP_ALPHA then
        if target.SetAlpha then target:SetAlpha(value) end
    elseif property == PROP_SCALE then
        if target.SetScale then target:SetScale(value) end
    elseif property == PROP_WIDTH then
        if target.SetWidth then target:SetWidth(value) end
    elseif property == PROP_HEIGHT then
        if target.SetHeight then target:SetHeight(value) end
    elseif property == PROP_POSX or property == PROP_POSY then
        if target.SetPoint and target.GetPoint then
            local point, relativeTo, relativePoint, offsetX, offsetY = target:GetPoint()
            point = point or "CENTER"
            relativeTo = relativeTo or target:GetParent()
            relativePoint = relativePoint or point
            offsetX = offsetX or 0
            offsetY = offsetY or 0
            
            target:ClearAllPoints()
            if property == PROP_POSX then
                target:SetPoint(point, relativeTo, relativePoint, value, offsetY)
            else
                target:SetPoint(point, relativeTo, relativePoint, offsetX, value)
            end
        end
    elseif property == PROP_ROTATION then
        if target.SetRotation then target:SetRotation(value * math_pi / 180) end
    end
end

function UIAnim_Processor.Read(target, property)
    if not target then return 0 end

    if property == PROP_ALPHA then
        return target.GetAlpha and target:GetAlpha() or 1
    elseif property == PROP_SCALE then
        return target.GetScale and target:GetScale() or 1
    elseif property == PROP_WIDTH then
        return target.GetWidth and target:GetWidth() or 0
    elseif property == PROP_HEIGHT then
        return target.GetHeight and target:GetHeight() or 0
    elseif property == PROP_POSX or property == PROP_POSY then
        if target.GetPoint then
            local _, _, _, offsetX, offsetY = target:GetPoint()
            return property == PROP_POSX and (offsetX or 0) or (offsetY or 0)
        end
    elseif property == PROP_ROTATION then
        return target.GetRotation and (target:GetRotation() * 180 / math_pi) or 0
    end

    return 0
end

function UIAnim_Processor.PrepareApply(target, property)
    if not target then return end

    if property == PROP_ALPHA then
        local setter = target.SetAlpha
        if setter then
            return APPLY_METHOD, setter
        end
    elseif property == PROP_SCALE then
        local setter = target.SetScale
        if setter then
            return APPLY_METHOD, setter
        end
    elseif property == PROP_WIDTH then
        local setter = target.SetWidth
        if setter then
            return APPLY_METHOD, setter
        end
    elseif property == PROP_HEIGHT then
        local setter = target.SetHeight
        if setter then
            return APPLY_METHOD, setter
        end
    elseif property == PROP_POSX or property == PROP_POSY then
        if target.SetPoint and target.GetPoint then
            local point, relativeTo, relativePoint, offsetX, offsetY = target:GetPoint()
            point = point or "CENTER"
            relativePoint = relativePoint or point
            return property == PROP_POSX and APPLY_POS_X or APPLY_POS_Y, target.SetPoint, point, relativeTo or target:GetParent(), relativePoint, offsetX or 0, offsetY or 0
        end
    elseif property == PROP_ROTATION then
        local setter = target.SetRotation
        if setter then
            return APPLY_ROTATION, setter
        end
    end
end
