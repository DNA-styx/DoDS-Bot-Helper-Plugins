# dod_bot_medic

A SourceMod plugin for Day of Defeat: Source that monitors bot health and triggers the medic voice command when health falls to or below a configurable threshold.

## Features

- Monitors all bots on the server
- Triggers `voice_medic` when a bot's health drops to or below the threshold
- Bots will only call medic once per life
- Random delay between 2.0 and 3.0 seconds before the voice command fires, preventing multiple bots calling medic simultaneously
- Reads threshold value from `sm_dodmedic_maximum` if present on the server, otherwise falls back to 30 HP
- Supports mid-map plugin loads without requiring a map restart

## Dependencies

- [SourceMod](https://www.sourcemod.net/) 1.11 or later
- Optional: a medic plugin that registers `sm_dodmedic_maximum` (e.g. [DoD Medic](https://forums.alliedmods.net/))

## Installation

1. Copy `dod_bot_medic.smx` to `addons/sourcemod/plugins/`
2. No configuration required

## ConVars

This plugin does not register its own ConVars. It reads the following ConVar from an external plugin if available:

| ConVar | Default | Description |
|---|---|---|
| `sm_dodmedic_maximum` | `30` | Maximum HP at which a bot will call for medic |

## Credits

Created with Claude.ai, guided by DNA.styx
