#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3"

// Falling velocity threshold (negative Z velocity)
#define FALL_THRESHOLD -300.0

ConVar g_cvKey;

public Plugin myinfo = 
{
    name = "Bot Auto-Parachute",
    author = "Claude.ai guided by DNA.styx",
    description = "Automatically activates parachutes for bots",
    version = PLUGIN_VERSION,
    url = "https://github.com/DNA-styx/DoDS-Bot-Helper-Plugins/"
};

public void OnPluginStart()
{
    CreateConVar("dod_bot_parachute_version", PLUGIN_VERSION,
        "Bot Auto-Parachute version",
        FCVAR_NOTIFY | FCVAR_REPLICATED);

    g_cvKey = CreateConVar("dod_bot_parachute_key", "0",
        "Button used to activate parachute. 0 = +USE, 1 = +JUMP",
        FCVAR_NONE,
        true, 0.0,
        true, 1.0);

    AutoExecConfig(true, "dod_bot_parachute");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    // 1. Only run for bots that are alive and in-game
    if (IsClientInGame(client) && IsFakeClient(client) && IsPlayerAlive(client))
    {
        // 2. Check if the bot is in the air
        // m_hGroundEntity is -1 when the player is falling/jumping
        int groundEntity = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");

        if (groundEntity == -1)
        {
            // 3. Check downward velocity (Z-axis)
            float velocity[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

            if (velocity[2] < FALL_THRESHOLD)
            {
                // 4. Force the configured button
                if (g_cvKey.IntValue == 1)
                    buttons |= IN_JUMP;
                else
                    buttons |= IN_USE;
            }
        }
    }

    return Plugin_Continue;
}
