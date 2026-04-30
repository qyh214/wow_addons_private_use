## Auto Potion

Smart, always-up-to-date healing macros for Healthstones, healing potions, class/racial self-heals and bandages.

Auto Potion was previously known as *Healthstone Auto Macro*. The addon automatically maintains one or two macros for you:

- **`AutoPotion`** – uses your class/racial healing spells, Healthstones and the best available healing potion (and some special healing items).
- **`AutoBandage`** – optional bandage macro that always uses your strongest bandage, with special handling in battlegrounds.

You never have to edit these macros yourself – Auto Potion keeps them updated as your bags, talents and gear change.

## What the addon does

- **Automatic healing macro**: Keeps a `/castsequence` macro up to date so you can bind a single key for self-heals, Healthstones and healing potions.
- **Smart priority system**:
  - Class/racial healing spells (like Renewal, Exhilaration, Desperate Prayer, Gift of the Naaru, etc.).
  - Optional support for **Heartseeking Health Injector** (engineering tinker) on Retail.
  - Warlock **Healthstones** (including classic variants), with an option to lower their priority if you prefer potions first.
  - The **strongest available healing potion** in your bags, including modern and legacy potions (Algari / Invigorating / Dreamwalker's / Withering / Cosmic / Spiritual / etc.).
  - Optional **Cavedweller's Delight** support as a separate, toggleable step.
- **Smart battleground support**:
  - Uses the appropriate PvP-only healing draughts and bandages when you are in battlegrounds (e.g. Ashran tonic, Classic draughts and BG bandages).
- **Bandage macro**:
  - Maintains an `AutoBandage` macro that uses the best bandage available for your current game version and content.
- **Works across versions**:
  - Retail (The War Within and later), Classic Era, WotLK Classic, Cataclysm Classic and Mists of Pandaria Classic.

## How it works

- **Macro maintenance**:
  - On login, `/reload`, leaving combat, changing talents, changing equipment, summoning a pet (for certain classes) or when your bags change, the addon:
    - Scans your character for supported healing spells, Healthstones, healing potions and special items.
    - Builds an ordered list based on your settings.
    - Rebuilds the `AutoPotion` and `AutoBandage` macros.
- **Macro content (high level)**:
  - Uses standard macro commands like `/cast`, `/castsequence` and `/use` with `[@player]` where appropriate.
  - Can optionally include `/stopcasting` at the top of the macro if you enable that in the settings.
  - Uses a `reset=` condition that can factor in the shortest cooldown of your selected healing spells if you enable the **CD reset** option.
- **Performance-friendly**:
  - Bag events are debounced so the macro is not rebuilt excessively when your bags change rapidly.
  - Macro updates are postponed while in combat to comply with WoW's secure execution rules.

## Installation & Quick Start

1. **Install the addon**
   - Install via CurseForge/Wago or manually drop the `AutoPotion` folder into your `Interface/AddOns` directory.
2. **Create the macro**
   - Create an empty macro called **`AutoPotion`** (and optionally **`AutoBandage`**) in the standard WoW macro UI.
3. **Place it on your bars**
   - Drag the `AutoPotion` macro to your action bar and bind it to a comfortable key.
   - If you use the bandage macro, do the same for `AutoBandage`.
4. **Reload once**
   - Type `/reload` to let the addon initialize and populate the macros.
5. **Configure (optional)**
   - Open the settings via `/ap` or through the **Interface → AddOns → AutoPotion** options panel to fine-tune priorities.

After this, just press your keybind whenever you need an emergency heal; Auto Potion will handle the rest according to your configuration.

## Configuration

Open the settings via `/ap` or **Interface → AddOns → AutoPotion**. The most important options are:

- **Class/Racial Spells**:
  - Choose which supported self-healing spells and racials should be part of the sequence for your class.
- **Include `/stopcasting` in the macro**:
  - Useful for casters; immediately stop your current cast before using a heal.
- **Include shortest cooldown in reset**:
  - Optionally include the shortest cooldown of your selected heals in the castsequence `reset=` condition. **Use carefully** if you are not familiar with castsequence behavior.
- **Low Priority Healthstones**:
  - Let health potions be used before Healthstones (or leave disabled to prefer Healthstones first).
- **Potion of Withering Vitality / Potion of Withering Dreams**:
  - Toggle whether these riskier potions are allowed in the rotation.
- **Cavedweller's Delight**:
  - Enable/disable Cavedweller's Delight (and its fleeting versions) as a separate step.
- **Heartseeking Health Injector (tinker)**:
  - Enable support for the engineering tinker on Retail if you have it equipped.
- **Bandage Priority**:
  - Dedicated bandage priority display that shows which bandage will be used first (including battleground-specific bandages in Classic).

The UI also shows the **current priority order** for your heals and bandages so you can easily verify what the macro will do.

## Terms of Use & Fair Play (Not a Cheat)

Auto Potion is designed to be fully compliant with World of Warcraft's Terms of Use and addon policies:

- **No automation of gameplay**:
  - The addon **never presses buttons for you** and does not trigger abilities automatically.
  - You still need to **manually press your keybind** for the macro to activate any spell or item.
- **Uses only Blizzard-approved functionality**:
  - Relies on the normal macro system (`/cast`, `/castsequence`, `/use`, `[@player]`, etc.).
  - Respects combat lockdown rules and only edits macros when it is safe and allowed by the client.
- **No protected actions outside keypresses**:
  - All healing actions are executed exactly as if you had written the macro yourself – Auto Potion just **keeps the macro text up to date**.

In short: Auto Potion is a **quality-of-life** addon, not an automation or botting tool.

## MegaMacro Compatibility

If you use the **MegaMacro** addon, Auto Potion can update your MegaMacro macros instead of the default WoW macro system.

- **Important setup steps**:
  - Create a **Global** macro in MegaMacro named **`AutoPotion`**.
  - (Optional) Create another **Global** macro named **`AutoBandage`** if you want the bandage macro as well.
  - Type `/reload` in-game.
- **How it behaves**:
  - When MegaMacro is installed and loaded, Auto Potion **will not create or manage standard WoW macros** for these names.
  - Instead, it looks for the matching **global MegaMacro entries** and updates their macro text directly.
- **Troubleshooting**:
  - If you see an AutoPotion error about a missing MegaMacro macro:
    - Verify that you created a **Global** (not character-specific) macro.
    - Ensure the name is **exactly** `AutoPotion` (or `AutoBandage` for bandages).
    - `/reload` after creating the macro so Auto Potion can detect and update it.

Once configured, you can use your MegaMacro-managed `AutoPotion`/`AutoBandage` macros exactly like the standard ones.

## FAQ

- **Q: Do I still need to press a key to heal?**  
  **A:** Yes. The addon only updates the macro text. You must press your keybind for any heal, potion, or bandage to be used.

- **Q: Does this work in all versions of WoW?**  
  **A:** Yes. Auto Potion supports Retail, Classic Era, WotLK Classic, Cataclysm Classic and Mists of Pandaria Classic, adapting the item and bandage lists to each version.

- **Q: Can I change which spells are used?**  
  **A:** Yes. Open the settings (`/ap`) and toggle your preferred class/racial self-healing spells.

- **Q: What if I only want potions and Healthstones, no spells?**  
  **A:** Simply disable all class/racial spells in the settings; the macro will then consist only of items.
