local CraftScan = select(2, ...)

local function f(s, args)
   for k, v in pairs(args) do
     s = s:gsub("{"..k.."}", v)
   end
   return s
end
CraftScan.Utils.FString = f;