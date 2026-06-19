# dod_navbot_classblock

Lets server operators block NavBot bots from selecting specific DoD:S classes. Human players are unaffected.

## Cvars

Each class has its own cvar. Set to `1` to block bots from that class, `0` to allow it (default: `0` for all).

- `dod_navbot_block_rifleman`
- `dod_navbot_block_assault`
- `dod_navbot_block_support`
- `dod_navbot_block_sniper`
- `dod_navbot_block_machinegunner`
- `dod_navbot_block_rocket`

On first load, these are written to `cfg/sourcemod/dod_navbot_classblock.cfg`. Edit that file directly, or set the cvars live from the server console.

`dod_navbot_classblock_version` reports the installed plugin version.

## How it works

When a bot tries to join a blocked class, the plugin stops the command before it takes effect. If a bot rolls a random class and lands on a blocked one, it's redirected to a random allowed class on the same team instead.

If every class is blocked, bots are left alone rather than forced into anything.

## Notes

This only affects bots. Human players can still pick any class normally.
