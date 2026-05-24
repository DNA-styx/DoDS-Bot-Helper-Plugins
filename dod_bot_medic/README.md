# dod_bot_medic

A SourceMod plugin for Day of Defeat: Source that monitors bot health and triggers a medic command when health falls to or below a configurable threshold.

## Features

- Monitors all bots on the server
- Supports multiple medic command modes: `voice_medic`, `say !medic`, `say medic`
- Bots will only call medic once per life
- Random delay between 2.0 and 7.0 seconds before the command fires
- Reads threshold value from external medic plugin ConVars if present, otherwise falls back to a configurable value
- Auto-generates a configuration file on first load

## Dependencies

- [SourceMod](https://www.sourcemod.net/) 1.11 or later
- A medic plugin (links below). Optional: that registers one of the supported ConVars (see ConVars section below)

## Installation

1. Copy `dod_bot_medic.smx` to `addons/sourcemod/plugins/`
2. Restart the map or use `sm plugins load dod_bot_medic`
3. Configuration file will be generated at `cfg/sourcemod/dod_bot_medic.cfg`

## ConVars

### Supported Plugin ConVars

| ConVar | Default | Description |
|---|---|---|
| `dod_bot_medic_mode` | `0` | Medic command mode. 0 = voice_medic, 1 = say !medic, 2 = say medic |
| `dod_bot_medic_threshold` | `30` | HP threshold at which bots call for medic. Used if no external medic plugin ConVar is found |

### External ConVars (optional)

If any of the following ConVars are registered by another plugin, they will be used as the health threshold in the order listed. The first one found takes priority.

| ConVar | Plugin | URL |
|---|---|---|
| `sm_dodmedic_maximum` | DoD Medic v1.0 | [Link](https://forums.alliedmods.net/showthread.php?p=501686) |
| `sm_medic_health` | [DOD:S] Medic Mod v1.0.109 | [Link](https://forums.alliedmods.net/showthread.php?p=682373) |
| `dod_medic_health_maximum` | DoD Medic v1.1 | [Link](https://forums.alliedmods.net/showthread.php?p=501686) |

## Credits

Created with Claude.ai, guided by DNA.styx
