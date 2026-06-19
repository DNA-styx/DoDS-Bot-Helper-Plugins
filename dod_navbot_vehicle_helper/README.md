# NavBot Vehicle Helper

A SourceMod plugin for Day of Defeat: Source that makes NavBots interact sensibly with driveable vehicles (`prop_vehicle_driveable`) — entering on touch, and evacuating a critically damaged vehicle once it has actually stopped.

## What it does

- **Auto-enter:** A bot that touches a vehicle automatically presses `+use` to get in.
- **Auto-evacuate on critical health:** When a vehicle's health drops below a critical threshold:
  - The bot driver's movement keys are blocked so the vehicle coasts to a stop under normal friction.
  - Once the vehicle's actual speed drops to or below its own exit-speed threshold (the same check the game engine itself uses), the bot driver — and any bot gunner riding along — are made to press `+use` and exit.
  - After a bot has fully left the vehicle, it plays a randomized, team-appropriate "take cover" voice line (US or German) audible to everyone, positioned at the bot.
  - The bot is blocked from immediately walking back into the vehicle it just escaped, for a short cooldown.
- **No entry into already-critical vehicles:** A bot will not get into a vehicle that's already below the critical health threshold.
- **Real players are never affected.** All of the above only applies to bots (`IsFakeClient`); a real player's `+use` and movement input are untouched in every code path.

## Requirements

- SourceMod 1.12 or later
- The `vehicles` plugin ([source-vehicles](https://github.com/DNA-styx/source-vehicles)) must be loaded. On load, this plugin checks for it via `LibraryExists("vehicles")` and will refuse to run if it isn't present, logging an error rather than failing silently.

## Installation

1. Make sure `vehicles.smx` is already loaded (or loads first).
2. Copy `dod_navbot_vehicle_helper.smx` into `addons/sourcemod/plugins/` to autoload, or into an optional subfolder if you prefer to load it manually.
3. Load it with `sm plugins load dod_navbot_vehicle_helper`.

A version ConVar (`dod_navbot_vehicle_helper_version`) is created on load for confirming the running version in `sm plugins list` / `sm cvar`.

## Configuration

| ConVar | Default | Meaning |
|---|---|---|
| `dod_navbot_vehicle_helper_critical_health` | `75.0` | Vehicle health (HP) below which evacuation behavior triggers |

Set in `cfg/sourcemod/dod_navbot_vehicle_helper.cfg`, generated on first load.

## Version

Current version: 1.6

## Author

claude.ai guided by DNA.styx
