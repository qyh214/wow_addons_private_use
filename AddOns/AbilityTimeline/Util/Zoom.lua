local appName, app = ...
---@class AbilityTimeline
local private = app

local function zoomAroundCenter(u, c, zoom)
   return c + (u - c) * zoom
end

local function clamp(v, lo, hi)
   if v < lo then return lo end
   if v > hi then return hi end
   return v
end

private.GetZoom = function(icon, zoom)
   -- get existing texcoords (ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
   local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = icon:GetTexCoord()

   -- build min/max and center (handles non-full textures / atlas subrects)
   local minU = math.min(ULx, LLx, URx, LRx)
   local maxU = math.max(ULx, LLx, URx, LRx)
   local minV = math.min(ULy, LLy, URy, LRy)
   local maxV = math.max(ULy, LLy, URy, LRy)

   local centerU = (minU + maxU) * 0.5
   local centerV = (minV + maxV) * 0.5

   local nULx = clamp(zoomAroundCenter(ULx, centerU, zoom), 0, 1)
   local nULy = clamp(zoomAroundCenter(ULy, centerV, zoom), 0, 1)
   local nLLx = clamp(zoomAroundCenter(LLx, centerU, zoom), 0, 1)
   local nLLy = clamp(zoomAroundCenter(LLy, centerV, zoom), 0, 1)
   local nURx = clamp(zoomAroundCenter(URx, centerU, zoom), 0, 1)
   local nURy = clamp(zoomAroundCenter(URy, centerV, zoom), 0, 1)
   local nLRx = clamp(zoomAroundCenter(LRx, centerU, zoom), 0, 1)
   local nLRy = clamp(zoomAroundCenter(LRy, centerV, zoom), 0, 1)

   return nULx, nULy, nLLx, nLLy, nURx, nURy, nLRx, nLRy
end

private.ResetZoom = function(icon)
   icon:SetTexCoord(0, 1, 0, 1)
end

private.SetZoom = function(icon, zoom)
   local nULx, nULy, nLLx, nLLy, nURx, nURy, nLRx, nLRy = private.GetZoom(icon, zoom)
   icon:SetTexCoord(nULx, nULy, nLLx, nLLy, nURx, nURy, nLRx, nLRy)
end