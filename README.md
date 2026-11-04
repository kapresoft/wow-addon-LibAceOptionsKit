# LibAceOptionsKit

<img src="doc/media/LibAceOptionsKit-Logo.png" alt="LibAceOptionsKit logo" width="200">

## **Step. Slide. Check.**

Embeddable WoW library of Blizzard Settings-style widgets for AceConfig options tables.

AceConfigDialog's default controls look dated next to Blizzard's own Settings panel. LibAceOptionsKit adds modern-looking widgets you plug into any AceConfig option with `dialogControl`, so your options dialog matches the game's Settings UI without rebuilding it.

## Features

- **Stepper dropdown:** a dropdown with previous/next arrows on either side, to cycle values without opening the list.
- **Stepper slider:** a slider with step arrows and a value label, for precise values.
- **Settings checkbox:** a checkbox styled like Blizzard's Settings panel; clicking anywhere on the row toggles it.
- Rows line up like Blizzard's Settings: a label column, then the control, with the same hover highlight.
- Sizes are adjustable per addon and per option, without touching other addons' dialogs.
- Safe to embed in many addons at once: no XML templates and no global names besides `LibStub` and `LibAceOptionsKit` (the newest loaded copy, same as `LibStub('LibAceOptionsKit-1.0')`).
- Works on Retail and Classic clients.

## Embedding

Add LibAceOptionsKit as an external in your `pkgmeta.yaml`:

```yaml
externals:
  ThirdParty/Libs/LibAceOptionsKit:
    url: https://github.com/kapresoft/wow-addon-LibAceOptionsKit
    tag: latest
```

Then load it from your TOC or XML, after LibStub, AceGUI-3.0 and AceConfig-3.0:

```xml
<Script file="ThirdParty\Libs\Ace3\LibStub\LibStub.lua"/>
<Include file="ThirdParty\Libs\Ace3\CallbackHandler-1.0\CallbackHandler-1.0.xml"/>
<Include file="ThirdParty\Libs\Ace3\AceGUI-3.0\AceGUI-3.0.xml"/>
<Include file="ThirdParty\Libs\Ace3\AceConfig-3.0\AceConfig-3.0.xml"/>
<Include file="ThirdParty\Libs\LibAceOptionsKit\LibAceOptionsKit.xml"/>
```

The library doesn't bundle its dependencies: your addon either bundles Ace3 and loads it first, as above, or uses Ace3 installed as an addon. `LibAceOptionsKit.xml` includes `ThirdParty\ThirdParty.xml` to declare what it needs, but those files ship only with the standalone install, so in your addon that include loads nothing.

## Usage

Set an option's `dialogControl` to the widget's `Type`. Everything else about the option (`name`, `desc`, `get`, `set`, `disabled`, ...) works as usual.

```lua
local AOK = LibStub('LibAceOptionsKit-1.0')

options.args.showMinimap = {
  type = 'toggle',
  name = 'Show Minimap Button',
  desc = 'Shows the button on the minimap.',
  width = 'full',
  dialogControl = AOK.SettingsCheckbox.Type,
  get = function() return db.showMinimap end,
  set = function(_, value) db.showMinimap = value end,
}
```

| Widget | Option `type` | `dialogControl` |
|---|---|---|
| Settings checkbox | `toggle` | `AOK.SettingsCheckbox.Type` |
| Stepper slider | `range` | `AOK.StepperSlider.Type` |
| Stepper dropdown | `select` | `AOK.StepperDropdown.Type` |

- Use `width = 'full'`. AceConfig's `width` sizes the whole row, and a `'normal'` row is narrower than a label plus its control.
- Reading `Type` from `AOK` instead of writing the string means a typo errors right away, not when the panel opens.

### Stepper slider

`min`, `max`, `step` and `isPercent` work as with Ace's own slider. Dragging and the arrows snap to `step`.

```lua
options.args.scale = {
  type = 'range',
  name = 'Scale',
  width = 'full',
  min = 0.5, max = 2, step = 0.05, isPercent = true,
  dialogControl = AOK.StepperSlider.Type,
  get = function() return db.scale end,
  set = function(_, value) db.scale = value end,
}
```

### Stepper dropdown

Entries are sorted by their text, or follow the option's `sorting` list when it has one. The arrows step through them in that order and disable at either end.

```lua
options.args.fontSize = {
  type = 'select',
  name = 'Font Size',
  width = 'full',
  values = { [10] = 'Small', [12] = 'Medium', [14] = 'Large' },
  sorting = { 10, 12, 14 },
  dialogControl = AOK.StepperDropdown.Type,
  arg = { tooltip = { dropdown = 'Applies to every chat frame.' } },
  get = function() return db.fontSize end,
  set = function(_, value) db.fontSize = value end,
}
```

- `desc` shows beside the label, like any option's tooltip.
- `arg.tooltip.dropdown` is an extra tooltip over the dropdown itself: a string, or a `function(tooltip)` that fills `GameTooltip`.

#### Icon toggle and trailing button

Two optional extras turn the row into `[Label] [icon] < [dropdown] > [button]`. Each shows only when the option sets it, e.g. a favorite star and a reload button:

```lua
arg = {
  icon = {
    get = function() return db.favorites[db.profile] end,  -- on/off for the selected value
    set = function(on) db.favorites[db.profile] = on end,
    marks = function(key) return db.favorites[key] end,    -- menu entries shown with the icon
    tooltip = function(tooltip) tooltip:SetText('Favorite') end,
  },
  button = {
    onClick = function() ReloadUI() end,
    tooltip = function(tooltip) tooltip:SetText('Reload') end,
  },
}
```

- `arg.icon`: clicking it calls `set(not get())`. `atlasOn` and `atlasOff` pick another icon (lock, pin, eye, ...); the default is the favorite star. `marks` and `tooltip` are optional.
- `arg.button`: Blizzard's refresh button after the dropdown. `tooltip` is optional.
- Both disable with the option, and their tooltips are placed like the dropdown's.

## Layout

Each widget's sizes come from three layers. Each one overrides the one before it, key by key:

1. The library's defaults.
2. Your addon's defaults, set once per AceConfig app name:
   ```lua
   AOK:SetDefaults('MyAddon', {
     label = { width = 220 },
     dropdown = { width = 240 },
   })
   ```
   Call it before the dialog opens. Calling it again merges into what's there.
3. One option's `arg.layout`:
   ```lua
   arg = { layout = { checkbox = { width = 36, height = 36 } } }
   ```

Defaults are per app name, not global: every addon that embeds the library shares one copy, so a global setting would resize other addons' dialogs. If your addon registers several AceConfig apps, call `SetDefaults` for each.

| Key | What it sizes |
|---|---|
| `row.height` | The row. |
| `row.gap` | Space between the label and the control. |
| `row.highlight.left` / `row.highlight.right` | The hover highlight's insets from the row's edges. |
| `label.width` | The label column. |
| `checkbox.width` / `checkbox.height` | The checkbox. |
| `slider.width` / `slider.height` | The slider, not counting its value label. |
| `slider.valueWidth` | Room kept for the value label when `slider.width` is `'fill'`. |
| `dropdown.width` / `dropdown.height` | The dropdown, arrows included. A `'fill'` dropdown leaves room for the icon and button. |
| `icon.width` / `icon.height` | The stepper dropdown's icon toggle. |
| `icon.gap` / `button.gap` | Space between the dropdown and its icon or button. |
| `tooltip.x` / `tooltip.y` | The tooltip's offset from the part it shows beside. |

`slider.width` and `dropdown.width` also take `'fill'`: the control takes what's left of the row after the label.

### About `arg`

AceConfig rejects option keys it doesn't know, so `arg` is the only place for per-option settings. AceConfig also passes `arg` to your handlers as `info.arg`. If you use it there too, keep your own data under a key of its own:

```lua
arg = { layout = { label = { width = 300 } }, myAddon = { refresh = true } }
```

When `arg` isn't a table, the widgets use the defaults.

### EmmyLua annotations

`LibAceOptionsKit_Option` is an `AceConfig.OptionsTable` with a typed `arg`. Cast an option to it, and your editor completes and checks the `arg.layout` and `arg.tooltip` keys:

```lua
options.args.fontSize = {
  type = 'select',
  name = 'Font Size',
  width = 'full',
  values = { [10] = 'Small', [12] = 'Medium', [14] = 'Large' },
  dialogControl = AOK.StepperDropdown.Type,
  arg = { layout = { dropdown = { width = 'fill' } } },
} --[[@as LibAceOptionsKit_Option]]
```

Annotations are optional: they're comments, and the library runs the same without them. The library's types build on the WoW API annotations (`AceConfig.OptionsTable`, `AceGUIWidget`, `GameTooltip`, ...) from [vscode-wow-api](https://github.com/Ketho/vscode-wow-api):

- **VS Code:** install the **WoW API** extension.
- **Other editors with EmmyLua** (e.g. IntelliJ): clone the repo and add its `Annotations/Core` folder to `workspace.library` in your `.emmyrc.json`:
  ```json
  {
    "workspace": {
      "library": ["/path/to/vscode-wow-api/Annotations/Core"]
    }
  }
  ```

Without them, `arg.layout` and `arg.tooltip` still complete; the other option fields just aren't typed.

## Wrapping a widget

To build your own widget on top of a stepper dropdown, create one with `AceGUI:Create(AOK.StepperDropdown.Type)` and extend it. These parts are supported:

- `widget.frame`: the row frame, the parent for your extra regions.
- `widget.label`, `widget.control`: anchors. The widget re-anchors `control` on each `OnWidthSet`, so a wrapper that moves it does so in its own `OnWidthSet` hook, after the original.
- `widget.dropdown`: the dropdown button, e.g. to point a help tip at it.
- `widget.icon`, `widget.button`: the icon toggle and trailing button, shown only when the option sets `arg.icon` / `arg.button`.
- `widget:GetEntryText(key)`: override it to decorate menu entries. The closed dropdown still shows the plain value. An override replaces the `arg.icon.marks` decoration.
- `OnWidthSet`, `SetDisabled`: hook them by calling the original first.
- `AOK:Layout(widget)`: the merged layout. Your own keys in `arg.layout` pass through.
- `AOK:AnchorTooltip(widget, tooltip, context)`: places a tooltip the way the library's widgets do.

## Example: DevSuite

[DevSuite](https://github.com/kapresoft/wow-addon-devsuite) embeds LibAceOptionsKit for its General and Debug Console options:

- **External:** [`pkgmeta.yaml`](https://github.com/kapresoft/wow-addon-devsuite/blob/46f34dae82965d95737d6613fdbaa15085e7bf67/pkgmeta.yaml#L38-L40) pulls the library.
- **Loading:** [`ThirdParty.xml`](https://github.com/kapresoft/wow-addon-devsuite/blob/46f34dae82965d95737d6613fdbaa15085e7bf67/DevSuite/ThirdParty/ThirdParty.xml#L16-L20) loads its files.
- **Accessor:** [`ns:LibAceOptionsKit()`](https://github.com/kapresoft/wow-addon-devsuite/blob/46f34dae82965d95737d6613fdbaa15085e7bf67/DevSuite/Libs/Global/Namespace.lua#L222-L223) returns the library.
- **Checkboxes:** [`OptionsDialogMixin.lua`](https://github.com/kapresoft/wow-addon-devsuite/blob/46f34dae82965d95737d6613fdbaa15085e7bf67/DevSuite/Libs/Options/OptionsDialogMixin.lua#L134-L142) uses a SettingsCheckbox with a wider label through `arg.layout`.
- **Stepper dropdown with a tooltip:** [`OptionsDebugConsole.lua`](https://github.com/kapresoft/wow-addon-devsuite/blob/46f34dae82965d95737d6613fdbaa15085e7bf67/DevSuite/Libs/Options/OptionsDebugConsole.lua#L77-L95) shows a font preview over the dropdown through `arg.tooltip.dropdown`.

## API

| Member | Description |
|---|---|
| `AOK.SettingsCheckbox`, `AOK.StepperSlider`, `AOK.StepperDropdown` | Each has the widget's AceGUI `Type` and `Version`. |
| `AOK:SetDefaults(appName, layout)` | Merges `layout` into the app's defaults. |
| `AOK:Layout(widget)` | The widget's merged layout, as a new table. |
| `AOK:ArgFor(widget)` | The option's `arg` table, or nil if it has none. |
| `AOK:AnchorTooltip(widget, tooltip, context)` | Places `tooltip` beside `context`, a part of the widget. |

## Requirements

- LibStub
- Ace3: AceGUI-3.0 and AceConfig-3.0 (AceConfigDialog-3.0)

## License

[MIT](LICENSE)

### Donations

If LibAceOptionsKit has made your addon development easier, consider supporting its development:

- **[Paypal&trade; Donation](https://www.paypal.com/donate/?hosted_button_id=AX58YP3GSGXVU)**
- **[Bitcoin Donation](https://www.blockchain.com/btc/address/3QQVAwJGkKHMM2oq6CLVWYgfx83TFVwp39)**

## About

- About the Author [(Tony Lagnada)](https://tony.resume.lagnada.com/)
- My AddOn Portfolio Can Be Found Here [Curse Forge/Kapresoft](https://www.curseforge.com/members/kapresoft/projects)
