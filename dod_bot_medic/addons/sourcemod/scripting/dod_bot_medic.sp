#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION  "1.5"
#define FALLBACK_THRESHOLD 30

bool    g_bSaidMedic[MAXPLAYERS + 1];
ConVar  g_cvThreshold;

public Plugin myinfo =
{
    name        = "Bot Auto-Medic",
    author      = "Claude.ai guided by DNA.styx",
    description = "Makes bots use the medic voice command when health drops to or below the threshold",
    version     = PLUGIN_VERSION,
    url         = "https://github.com/DNA-styx/DoDS-Plugins"
};

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);

    g_cvThreshold = FindConVar("sm_dodmedic_maximum");

    // Hook bots already in-game when the plugin loads mid-map
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsFakeClient(i))
            SDKHook(i, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
    }
}

public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client))
        SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
}

public void OnClientDisconnect(int client)
{
    g_bSaidMedic[client] = false;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0)
        g_bSaidMedic[client] = false;
}

public void Hook_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim))
        return;

    if (g_bSaidMedic[victim])
        return;

    int threshold = FALLBACK_THRESHOLD;

    if (g_cvThreshold != null)
        threshold = g_cvThreshold.IntValue;

    if (GetClientHealth(victim) <= threshold)
    {
        g_bSaidMedic[victim] = true;
        float delay = 2.0 + GetRandomFloat(0.0, 1.0);
        CreateTimer(delay, Timer_SayMedic, GetClientUserId(victim));
    }
}

public Action Timer_SayMedic(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);

    if (client == 0 || !IsClientInGame(client))
        return Plugin_Stop;

    FakeClientCommand(client, "voice_medic");
    return Plugin_Stop;
}
