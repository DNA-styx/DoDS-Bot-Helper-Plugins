#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#define PLUGIN_VERSION "0.4"

#define TEAM_ALLIES 2
#define TEAM_AXIS 3

#define NUM_CLASSES 6
// Index order: 0 Rifleman, 1 Assault, 2 Support, 3 Sniper, 4 MachineGunner, 5 Rocket

public Plugin myinfo =
{
    name = "NavBot DoD:S Class Blocker",
    author = "Claude.ai guided by DNA.styx",
    description = "Allows blocking NavBot bots from selecting specific DoD:S classes",
    version = PLUGIN_VERSION,
    url = "https://github.com/DNA-styx/DoDS-Bot-Helper-Plugins"
};

ConVar g_hBlock[NUM_CLASSES];

char g_AlliesCmd[NUM_CLASSES][] = { "cls_garand", "cls_tommy", "cls_bar", "cls_spring", "cls_30cal", "cls_bazooka" };
char g_AxisCmd[NUM_CLASSES][]   = { "cls_k98", "cls_mp40", "cls_mp44", "cls_k98s", "cls_mg42", "cls_pschreck" };
char g_ClassCvarName[NUM_CLASSES][] = { "rifleman", "assault", "support", "sniper", "machinegunner", "rocket" };

public void OnPluginStart()
{
    CreateConVar("dod_navbot_classblock_version", PLUGIN_VERSION, "NavBot DoD:S Class Blocker plugin version.", FCVAR_NOTIFY | FCVAR_DONTRECORD);

    char cvarname[64];
    char description[128];

    for (int i = 0; i < NUM_CLASSES; i++)
    {
        Format(cvarname, sizeof(cvarname), "dod_navbot_block_%s", g_ClassCvarName[i]);
        Format(description, sizeof(description), "Set to 1 to block bots from selecting the %s class, 0 to allow it (default: 0).", g_ClassCvarName[i]);
        g_hBlock[i] = CreateConVar(cvarname, "0", description, FCVAR_NONE, true, 0.0, true, 1.0);
    }

    AutoExecConfig(true, "dod_navbot_classblock");
}

public Action OnClientCommand(int client, int args)
{
    if (!IsFakeClient(client))
    {
        return Plugin_Continue;
    }

    char cmd[32];
    GetCmdArg(0, cmd, sizeof(cmd));

    // Direct class selection: block if the matching class is flagged
    for (int i = 0; i < NUM_CLASSES; i++)
    {
        if (StrEqual(cmd, g_AlliesCmd[i], false) || StrEqual(cmd, g_AxisCmd[i], false))
        {
            if (g_hBlock[i].BoolValue)
            {
                return Plugin_Handled;
            }
            return Plugin_Continue;
        }
    }

    // Random class roll: redirect to a non-blocked class for the bot's team
    if (StrEqual(cmd, "cls_random", false))
    {
        int team = GetClientTeam(client);

        if (team != TEAM_ALLIES && team != TEAM_AXIS)
        {
            // Team not yet assigned, can't pick a side safely
            return Plugin_Continue;
        }

        int available[NUM_CLASSES];
        int count = 0;

        for (int i = 0; i < NUM_CLASSES; i++)
        {
            if (!g_hBlock[i].BoolValue)
            {
                available[count] = i;
                count++;
            }
        }

        if (count == 0)
        {
            // Every class blocked, nothing safe to redirect to
            return Plugin_Continue;
        }

        int pick = available[GetRandomInt(0, count - 1)];

        if (team == TEAM_ALLIES)
        {
            ClientCommand(client, g_AlliesCmd[pick]);
        }
        else
        {
            ClientCommand(client, g_AxisCmd[pick]);
        }

        return Plugin_Handled;
    }

    return Plugin_Continue;
}
