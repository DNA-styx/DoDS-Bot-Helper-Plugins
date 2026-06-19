#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <vehicles>

#define PLUGIN_VERSION "1.6"
#define REENTRY_BLOCK_DURATION 3.0

#define SOUND_TAKECOVER_ALLIES "player/american/us_takecover.wav"
#define SOUND_TAKECOVER_AXIS "player/german/ger_takecover.wav"

ConVar g_hCvarCriticalHealth;

bool g_bPendingUse[MAXPLAYERS + 1];
float g_flLastExitTime[MAXPLAYERS + 1];
bool g_bAwaitingExit[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name        = "NavBot Vehicle Helper",
	author      = "Claude.ai guided by DNA.styx",
	description = "Makes bots press +use when touching a prop_vehicle_driveable, and exit if vehicle health drops too low",
	version     = PLUGIN_VERSION,
	url         = "https://github.com/DNA-styx/DoDS-Bot-Helper-Plugins"
};

public void OnPluginStart()
{
	CreateConVar("dod_navbot_vehicle_helper_version", PLUGIN_VERSION,
		"NavBot Vehicle Helper version", FCVAR_NOTIFY);

	g_hCvarCriticalHealth = CreateConVar("dod_navbot_vehicle_helper_critical_health", "75.0",
		"Vehicle health (HP) below which evacuation behavior triggers");

	AutoExecConfig(true, "dod_navbot_vehicle_helper");
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("vehicles"))
		SetFailState("Required plugin \"vehicles\" not found.");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_TAKECOVER_ALLIES, true);
	PrecacheSound(SOUND_TAKECOVER_AXIS, true);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "prop_vehicle_driveable"))
	{
		SDKHook(entity, SDKHook_StartTouch, Hook_VehicleStartTouch);
	}
}

public void Hook_VehicleStartTouch(int entity, int other)
{
	if (other <= 0 || other > MaxClients)
		return;

	if (!IsClientInGame(other) || !IsFakeClient(other) || !IsPlayerAlive(other))
		return;

	// Don't let a bot get into a vehicle that's already in critical health
	float health = Vehicle(entity).Health;
	if (health > 0.0 && health < g_hCvarCriticalHealth.FloatValue)
		return;

	// Don't auto re-enter a vehicle the bot was just forced out of for low health
	if (GetGameTime() - g_flLastExitTime[other] < REENTRY_BLOCK_DURATION)
		return;

	g_bPendingUse[other] = true;
}

public void OnClientDisconnect(int client)
{
	g_bPendingUse[client] = false;
	g_flLastExitTime[client] = 0.0;
	g_bAwaitingExit[client] = false;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if (g_bPendingUse[client])
	{
		buttons |= IN_USE;
		g_bPendingUse[client] = false;
	}

	if (IsFakeClient(client) && IsPlayerAlive(client))
	{
		int vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
		bool isDriver = (vehicle != -1 && GetEntPropEnt(vehicle, Prop_Data, "m_hPlayer") == client);
		bool isShooter = (vehicle != -1 && !isDriver && Vehicle(vehicle).Shooter == client);

		if (isDriver || isShooter)
		{
			float health = Vehicle(vehicle).Health;

			if (health > 0.0 && health < g_hCvarCriticalHealth.FloatValue)
			{
				// Mirrors the engine's own exit-eligibility check in vehicles.sp
				if (GetEntProp(vehicle, Prop_Data, "m_nSpeed") <= GetEntPropFloat(vehicle, Prop_Data, "m_flMinimumSpeedToEnterExit"))
				{
					g_bPendingUse[client] = true;
					g_flLastExitTime[client] = GetGameTime();
					g_bAwaitingExit[client] = true;
				}
				else if (isDriver)
				{
					// Only the driver's controls affect vehicle speed
					buttons &= ~(IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT);
				}
			}
		}
		else if (g_bAwaitingExit[client])
		{
			// No longer in the vehicle in either role, so the forced exit has actually completed now
			g_bAwaitingExit[client] = false;
			ScheduleTakeCoverSound(client);
		}
	}

	return Plugin_Continue;
}

void ScheduleTakeCoverSound(int client)
{
	CreateTimer(GetRandomFloat(0.5, 2.0), Timer_PlayTakeCoverSound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_PlayTakeCoverSound(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if (client == 0 || !IsClientInGame(client) || !IsFakeClient(client) || !IsPlayerAlive(client))
		return Plugin_Stop;

	PlayTakeCoverSound(client);

	return Plugin_Stop;
}

void PlayTakeCoverSound(int client)
{
	// Team values follow the same convention used in vehicles.sp (Player.Team - 2 indexes
	// a 2-element array), i.e. 2 = Allies (American), 3 = Axis (German).
	int team = GetClientTeam(client);

	if (team == 2)
		EmitSoundToAll(SOUND_TAKECOVER_ALLIES, client, SNDCHAN_VOICE, SNDLEVEL_NORMAL);
	else if (team == 3)
		EmitSoundToAll(SOUND_TAKECOVER_AXIS, client, SNDCHAN_VOICE, SNDLEVEL_NORMAL);
}
