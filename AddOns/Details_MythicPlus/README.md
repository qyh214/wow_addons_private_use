## Public API

All functions and variables that are explicitly exposed are listed in public.lua. Other public functions may change or be removed at any point.

### Functions

```lua
DetailsMythicPlus.GetAmountOfLikesGivenByPlayerSelf(targetPlayerName)
DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf(targetPlayerName)
DetailsMythicPlus.Open(runId)
DetailsMythicPlus.GetSimpleDescription(runId)
DetailsMythicPlus.GetLatestRunId()
DetailsMythicPlus.UnregisterCallback(event, callbackFunction)
DetailsMythicPlus.RegisterCallback(event, callbackFunction)
```

### Events

You can (de)register events by using the `UnregisterCallback` and `RegisterCallback` functions listed above.

- `RunFinished` triggers right after `CreateRunInfo()` and `OpenScoreBoardAtEnd()`
  - args:
    - `runId: number`
- `PlayerLiked`
  - args:
    - `runId: number`
    - `playerName: string` This is the name of the player that someone liked, not the player who liked someone
