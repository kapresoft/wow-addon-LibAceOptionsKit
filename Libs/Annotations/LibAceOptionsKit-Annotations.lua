--[[-----------------------------------------------------------------------------
Annotations: types for the option's `arg` and the widgets' row sizes.
Not loaded in game; packaged so editors with EmmyLua read it.
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- An AceConfig option whose `arg` the library's widgets read
--- @class LibAceOptionsKit_Option : AceConfig.OptionsTable
--- @field arg? LibAceOptionsKit_Arg

--- Per-option settings passed through AceConfig's `arg`
--- @class LibAceOptionsKit_Arg
--- @field layout? LibAceOptionsKit_Layout
--- @field tooltip? LibAceOptionsKit_TooltipArg
--- @field icon? LibAceOptionsKit_IconArg     @StepperDropdown only
--- @field button? LibAceOptionsKit_ButtonArg @StepperDropdown only

--- Icon toggle between the label and the dropdown, e.g. a favorite star
--- @class LibAceOptionsKit_IconArg
--- @field get fun(): boolean                 @On for the selected value
--- @field set fun(value: boolean)
--- @field atlasOn? string                    @Defaults to the favorite star
--- @field atlasOff? string                   @Defaults to the favorite star
--- @field tooltip? fun(tooltip: GameTooltip)
--- @field marks? fun(key: any): boolean      @Menu entries shown with atlasOn

--- Button after the dropdown, from Blizzard's RefreshButtonTemplate
--- @class LibAceOptionsKit_ButtonArg
--- @field onClick fun()
--- @field tooltip? fun(tooltip: GameTooltip)

--- Tooltip content, keyed by the part it shows over
--- @class LibAceOptionsKit_TooltipArg
--- @field dropdown? string|fun(tooltip: GameTooltip) @Shown over the dropdown, not its arrows

--- @class LibAceOptionsKit_Size
--- @field width? number  @px
--- @field height? number @px

--- Hover highlight insets from the row's left and right edges
--- @class LibAceOptionsKit_RowHighlight
--- @field left? number  @px
--- @field right? number @px

--- AceGUI sets the row width; the option's `width` sizes it
--- @class LibAceOptionsKit_RowLayout
--- @field height? number @px
--- @field gap? number    @px between label and control
--- @field highlight? LibAceOptionsKit_RowHighlight

--- Width includes the stepper arrows; 'fill' takes the rest of the row
--- @class LibAceOptionsKit_DropdownLayout
--- @field width? number|'fill' @px
--- @field height? number       @px

--- Width excludes the value label; 'fill' takes the rest of the row
--- @class LibAceOptionsKit_SliderLayout
--- @field width? number|'fill' @px
--- @field height? number       @px
--- @field valueWidth? number   @px kept for the value label by 'fill'

--- @class LibAceOptionsKit_IconLayout
--- @field width? number  @px
--- @field height? number @px
--- @field gap? number    @px between the icon and the dropdown

--- @class LibAceOptionsKit_ButtonLayout
--- @field gap? number @px between the dropdown and the button

--- Tooltip BOTTOMLEFT offset from its context's TOPRIGHT
--- @class LibAceOptionsKit_TooltipLayout
--- @field x? number @px
--- @field y? number @px

--- @class LibAceOptionsKit_Layout
--- @field row? LibAceOptionsKit_RowLayout
--- @field label? LibAceOptionsKit_Size
--- @field dropdown? LibAceOptionsKit_DropdownLayout
--- @field checkbox? LibAceOptionsKit_Size
--- @field slider? LibAceOptionsKit_SliderLayout
--- @field icon? LibAceOptionsKit_IconLayout
--- @field button? LibAceOptionsKit_ButtonLayout
--- @field tooltip? LibAceOptionsKit_TooltipLayout
