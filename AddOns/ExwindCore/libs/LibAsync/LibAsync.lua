--- @class LibAsync : table
--- @field GetHandler fun(self, config: LibAsyncConfig | nil) : LibAsyncHandler

--- @class LibAsyncConfig
--- @field type "everyFrame" The type of handler to create.
--- @field maxTime number The maximum time in milliseconds to spend on a single update.
--- @field maxTimeCombat number The maximum time in milliseconds to spend on a single update while in dungeon combat.
--- @field errorHandler fun(msg: string, stacktrace?: string, name?: string) The error handler to use when a coroutine errors.

--- @class LibAsyncHandler
--- @field size number
--- @field frame table
--- @field update table
--- @field CancelAsync fun(self, name: string)
--- @field Async fun(self, func: function, name: string, singleton: boolean)

local LibAsync

do
  local _MAJOR = "LibAsync"
  local _MINOR = 3
  if LibStub then
    local lib, minor = LibStub:GetLibrary(_MAJOR, true)
    if lib and minor and minor >= _MINOR then
      return lib
    else
      LibAsync = LibStub:NewLibrary(_MAJOR, _MINOR)
    end
  else
    LibAsync = {}
  end
  LibAsync._MAJOR = _MAJOR
  LibAsync._MINOR = _MINOR
end

local bytetoB64 = {
  [0] = "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "(",
  ")"
}

local function getUniqueId(length)
  local s = {}
  for i = 1, 11 do
    tinsert(s, bytetoB64[math.random(0, 63)])
  end
  return table.concat(s)
end

--- @param config LibAsyncConfig
--- @return LibAsyncHandler
local function createHandler(config)
  local handler = {}
  handler.frame = CreateFrame("Frame")
  handler.update = {}
  handler.size = 0

  function handler.Async(self, func, name, singleton)
    if singleton then
      handler.CancelAsync(self, name)
    end
    if not name then
      name = string.format("NIL", handler.size + 1);
    end
    if handler.update[name] then
      name = name..getUniqueId(11)
    end
    if not handler.update[name] then
      handler.update[name] = coroutine.create(func);
      handler.size = handler.size + 1
      handler.frame:Show();
    end
  end

  function handler.CancelAsync(self, name)
    if handler.update[name] then
      handler.update[name] = nil;
      handler.size = handler.size - 1
      if handler.size == 0 then
        handler.frame:Hide();
      end
    end
  end

  -- Setup frame
  handler.frame:Hide();
  if config.type == "everyFrame" then
    handler.frame:SetScript("OnUpdate", function(self, elapsed)
      local start = debugprofilestop(); --in ms
      local hasData = true;
      elapsed = elapsed * 1000;
      local maxExecutionTime = ((InCombatLockdown() and IsInInstance()) and config.maxTimeCombat or config.maxTime)

      while (debugprofilestop() - start < max(1, maxExecutionTime - elapsed) and hasData) do
        hasData = false;
        -- Resume all coroutines
        for name, func in pairs(handler.update) do
          hasData = true;
          -- Resume or remove
          if coroutine.status(func) ~= "dead" then
            local ok, msg = coroutine.resume(func)
            if not ok then
              -- default error handler only takes msg
              -- we add debugstack and name to custom error handlers
              config.errorHandler(msg, debugstack(func), name)
            end
          else
            handler:CancelAsync(name);
          end
        end
      end
    end);
  end
  return handler
end

--- @type LibAsyncConfig
local defaultHandlerConfig = {
  type = "everyFrame",
  maxTime = 40,
  maxTimeCombat = 8,
  errorHandler = geterrorhandler(),
}

--- @param config LibAsyncConfig | nil
--- @return LibAsyncHandler
function LibAsync:GetHandler(config)
  config = config or defaultHandlerConfig
  return createHandler(config)
end
