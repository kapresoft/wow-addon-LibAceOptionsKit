# LibAceOptionsKit

<img src="doc/media/LibAceOptionsKit-Logo.png" alt="LibAceOptionsKit logo" width="200">

## **Step. Slide. Check.**

Embeddable WoW library of Blizzard Settings-style widgets for AceConfig options tables.

AceConfigDialog's default controls look dated next to Blizzard's own Settings panel. LibAceOptionsKit adds modern-looking widgets you plug into any AceConfig option with `dialogControl`, so your options dialog matches the game's Settings UI without rebuilding it.

## Planned widgets

- **Stepper dropdown:** a dropdown with previous/next arrows on either side, to cycle values without opening the list.
- **Stepper slider:** a slider with step buttons for precise values.
- **Settings checkbox:** a checkbox styled like Blizzard's Settings panel.

## Status

Early development. The widgets are being extracted from AddonSuite, DevSuite and LuaDevKit, where they already ship. The API may change before the first release, and embedding instructions will follow with it.

## Requirements

- Ace3 (AceGUI-3.0 and AceConfigDialog-3.0)
