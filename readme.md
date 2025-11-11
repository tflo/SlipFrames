# Slip Frames

Unit frame transparency and click-through on demand.

## Is this addon for you?

This addon is for you if one of the following is true:

1) You keep your Blizzard Player and Target frames in the corner or at the bottom of your screen because otherwise they would get in the way.  
2) You have your Player and Target frames in the center area of your screen, but this isn’t all shiny because the frames often do get in the way: they intercept your mouse clicks, or obscure your view.  
3) You have the Target frame in the mid to lower right-center part of the screen, and when you move with the right mouse button, you often get stuck due to accidental clicks on the frame.

Slip Frames is *probably* not compatible with other unit-frame addons that modify or replace these frames. But you might give it a try.

## What the addon does

The addon is very simplistic and modifies (on your demand) just two attributes of the frames:

- **Transparency,** aka opacity
- **Click-through behavior: ** whether the frame intercepts (receives) mouse clicks, or if clicks on the frame are passed through to the background/world frame.

The affected frames are:

- Player frame
- Pet frame
- Target frame
- Focus frame

### The Point of this?

By (Blizz)default, these frames are 100% opaque and always receive mouse clicks. This is a good starting point, but lacks flexibility.

Some third-party unit-frame addons allow you to set transparency and click-through, but the settings are buried in a settings panel or require slash commands. As a result, they become permanent either-or settings, making hot swapping impossible.

## Usage

Slip Frames  allows you to change the two things (transparency and click-through behavior) on the fly, *without having to open any settings panel or enter any slash command,* just by simple mouse wheel actions:

**With your mouse over the Player, Pet, Target, or Focus frame:**

- **Click-through:** *Mouse wheel up* (forward) to make the frame immune to mouse clicks; *mouse wheel down* (backward) to make the frame receive clicks.
- **Transparency:** Hold down *any modifier key* and roll the mouse wheel up/down to adjust transparency.

Any modifier key works: Cmd/Meta, Alt, Ctrl, or Shift.

## More details

- While in combat:  
    - You can change the click-through behavior also in combat, since this can be crucial, e.g. for setting raid markers via right-click. This is securely implemented so that it doesn’t taint.
    - Opacity will always be at 100% while in combat, and you cannot change it. It will revert to the set values after combat ends.
- For the transparency value, the frames are treated as two groups: 
    - Player & Pet frame
    - Target & Focus frame
    - Changes to one group member also affect the other, but not the other group.
    - This allows you to have different transparency for Player/Pet vs Target/Focus frame.
- Click-through is set per frame.
- Any changes you make will print feedback to the chat console (e.g. the current alpha (opacity) value in percent).
- To prevent accidental changes to your transparency values, double-click any of the affected frames (transparency lock). The automatic increase to 100% opacity during combat is not blocked by this.
    - For obvious reasons, click-through must be disabled for this to work.

## UI and Settings

There are no GUI or slash command settings. Everything is done with the mouse wheel. The values will be saved account-wide (not per char).

If you forgot how the addon works, you can display a help text by entering `/slipframes` or `/sfs` in the chat console. `/sfs version` print the addon version.

__Have fun with the addon!__

---

Feel free to share your suggestions or report issues on the [GitHub Issues](https://github.com/tflo/SlipFrames/issues) page of the repository.  
__Please avoid posting suggestions or issues in the comments on Curseforge.__

---

__Other addons by me:__

- [___PetWalker___](https://www.curseforge.com/wow/addons/petwalker): Never lose your pet again (…or randomly summon a new one).
- [___Auto Quest Tracker Mk III___](https://www.curseforge.com/wow/addons/auto-quest-tracker-mk-iii): Continuation of the one and only original. Up to date and tons of new features.
- [___Move 'em All___](https://www.curseforge.com/wow/addons/move-em-all): Mass move items/stacks from your bags to wherever. Works also fine with most bag addons.
- [___Auto Discount Repair___](https://www.curseforge.com/wow/addons/auto-discount-repair): Automatically repair your gear – where it’s cheap.
- [___Auto-Confirm Equip___](https://www.curseforge.com/wow/addons/auto-confirm-equip): Less (or no) confirmation prompts for BoE and BtW gear.
- [___Action Bar Button Growth Direction___](https://www.curseforge.com/wow/addons/action-bar-button-growth-direction): Fix the button growth direction of multi-row action bars to what is was before Dragonflight (top --> bottom).
- [___EditBox Font Improver___](https://www.curseforge.com/wow/addons/editbox-font-improver): Better fonts and font size for the macro/script edit boxes of many addons, incl. Blizz's. Comes with 70+ preinstalled monospaced fonts.

__WeakAuras:__

- [___Stats Mini___](https://wago.io/S4023p3Im): A *very* compact but beautiful and feature-loaded stats display: primary/secondary stats, *all* defensive stats (also against target), GCD, speed (rating/base/actual/Skyriding), iLevel (equipped/overall/difference), char level +progress.
