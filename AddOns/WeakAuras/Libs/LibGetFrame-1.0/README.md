# LibGetFrame

Return unit frame for a given unit

## Usage

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local frame = LGF.GetUnitFrame(unit , options)
```

## Options

- framePriorities : array, default :

```Lua
{
    -- raid frames
    "^Vd1", -- vuhdo
    "^Vd2", -- vuhdo
    "^Vd3", -- vuhdo
    "^Vd4", -- vuhdo
    "^Vd5", -- vuhdo
    "^Vd", -- vuhdo
    "^HealBot", -- healbot
    "^GridLayout", -- grid
    "^Grid2Layout", -- grid2
    "^PlexusLayout", -- plexus
    "^ElvUF_RaidGroup", -- elv
    "^oUF_bdGrid", -- bdgrid
    "^oUF_.-Raid", -- generic oUF
    "^LimeGroup", -- lime
    "^SUFHeaderraid", -- suf
    -- party frames
    "^AleaUI_GroupHeader", -- Alea
    "^SUFHeaderparty", --suf
    "^ElvUF_PartyGroup", -- elv
    "^oUF_.-Party", -- generic oUF
    "^PitBull4_Groups_Party", -- pitbull4
    "^CompactRaid", -- blizz
    "^CompactParty", -- blizz
    -- player frame
    "^SUFUnitplayer",
    "^PitBull4_Frames_Player",
    "^ElvUF_Player",
    "^oUF_.-Player",
    "^PlayerFrame",
}
```

- ignorePlayerFrame : boolean (default true)
- ignoreTargetFrame : boolean (default true)
- ignoreTargettargetFrame : boolean (default true)
- ignorePartyFrame : boolean (default false)
- ignorePartyTargetFrame : boolean (default true)
- ignoreRaidFrame : boolean (default false)

- playerFrames : array, default :

```Lua
{
    "SUFUnitplayer",
    "PitBull4_Frames_Player",
    "ElvUF_Player",
    "oUF_.-Player",
    "oUF_PlayerPlate",
    "PlayerFrame",
}
```

- targetFrames : array, default :

```Lua
{
    "SUFUnittarget",
    "PitBull4_Frames_Target",
    "ElvUF_Target",
    "oUF_.-Target",
    "TargetFrame",
}
```

- targettargetFrames : array, default :

```Lua
{
    "SUFUnittargetarget",
    "PitBull4_Frames_Target's target",
    "ElvUF_TargetTarget",
    "oUF_.-TargetTarget",
    "oUF_ToT",
    "TargetTargetFrame",
}
```

- partyFrames : array, default :

```Lua
{
    "^AleaUI_GroupHeader",
    "^SUFHeaderparty",
    "^ElvUF_PartyGroup",
    "^oUF_.-Party",
    "^PitBull4_Groups_Party",
    "^CompactParty",
}
```

- partyTargetFrames : array, default :

```Lua
{
    "SUFChildpartytarget",
}
```

- raidFrames : array, default :

```Lua
{
    "^Vd",
    "^HealBot",
    "^GridLayout",
    "^Grid2Layout",
    "^PlexusLayout",
    "^ElvUF_RaidGroup",
    "^oUF_.-Raid",
    "^LimeGroup",
    "^SUFHeaderraid",
    "^CompactRaid",
}
```

- ignoreFrames : array, default :

```Lua
{
        "PitBull4_Frames_Target's target's target",
        "ElvUF_PartyGroup%dUnitButton%dTarget",
        "ElvUF_FocusTarget",
        "RavenButton"
}
```

- returnAll : boolean (default false)

## Examples

### Glow player frame

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local frame = LGF.GetUnitFrame("player")

if frame then
  LCG.ButtonGlow_Start(frame)
  -- LCG.ButtonGlow_Stop(frame)
end
```

### Glow every frames for your target

```Lua
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")

local frames = LGF.GetUnitFrame("target", {
      ignorePlayerFrame = false,
      ignoreTargetFrame = false,
      ignoreTargettargetFrame = false,
      returnAll = true,
})

for _, frame in pairs(frames) do
   LCG.ButtonGlow_Start(frame)
   --LCG.ButtonGlow_Stop(frame)
end
```

### Ignore Vuhdo panel 2 and 3

```Lua
local frame = LGF.GetUnitFrame("player", {
      ignoreFrames = { "Vd2.*", "Vd3.*" }
})
```

[GitHub Project](https://github.com/mrbuds/LibGetFrame)
