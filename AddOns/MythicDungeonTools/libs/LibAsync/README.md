# LibAsync

WoW library for running code asynchronously.
The code of the Library is based on the coroutine handler found in WeakAuras.

Due to the nature of WoW, this library is not truly asynchronous, but it does allow you to run code in a way that will not block the main thread. This is useful for running code that may take a long time to execute, such as iterating over a large table.

The need for this library came from a change that Blizzard made after an exploit was used on Mythic Raszageth. The exploit called very expensive code that resulted in a long freeze for the player. This made the player's character ignore pushback from the wind mechanic. To combat this Blizzard limited code execution in dungeon and raid combat to a total of about 100 milliseconds per frame. When Mythic Dungeon Tools loads a lot of expensive code has to be ran to generate the dungeon map. The simple solution could have been to just not allow MDT users to use the addon in combat, but I wanted to find a way to allow the addon to be used in combat without causing any issues. This library allows you to run expensive code asynchronously in a way that should not cause any issues with Blizzard's new restrictions.

## Usage

1. Create a handler that will run all your async code

```lua
local handler = LibStub("LibAsync"):GetHandler()
```

2. Run your function asynchronously using the handler and call `coroutine.yield()` throughout the function to allow the handler to pause execution

```lua
handler:Async(function()
    for i = 1, 1000000 do
        if i % 100 == 0 then
            coroutine.yield() -- Yielding will allow the handler to pause execution
        end
        print(i)
    end
end, "MyAsyncFunction")
```

### Optional

You can also pass a config table when creating the handler that can define the following options:

- `type` - The type of handler to create. Currently only `"everyFrame"` is supported
- `maxTime` - The maximum time in milliseconds to spend on a single update.
- `maxTimeCombat` - The maximum time in milliseconds to spend on a single update while in dungeon combat.
- `errorHandler` - The error handler to use when a coroutine errors. Defaults to `geterrorhandler()`

```lua
local handler = LibStub("LibAsync"):GetHandler({
    type = "everyFrame",
    maxTime = 40,
    maxTimeCombat = 8,
    errorHandler = geterrorhandler()
})
```
