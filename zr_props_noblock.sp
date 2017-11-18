/*  SM Franug Props Noblock
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zombiereloaded>

#define VERSION "1.0"

#define MAXENTITIES 2048

new Handle:timers[MAXENTITIES];

public Plugin:myinfo =
{
    name = "SM Props Noblock",
    author = "Franc1sco franug",
    description = "Noblock in props",
    version = VERSION,
    url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	CreateConVar("sm_propsnoblock_version", VERSION, "", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEvent("round_start", Event_RoundStart);
}

public Action:Event_RoundStart(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	// clear the entities´s cache
	
	for(new i = MAXPLAYERS+1;i<MAXENTITIES;i++)
		if(timers[i] != INVALID_HANDLE) timers[i] = INVALID_HANDLE;
} 

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "func_physbox") || StrEqual(classname, "prop_physics") || StrEqual(classname, "prop_physics_override") || StrEqual(classname, "prop_physics_multiplayer"))
	{
		SDKHook(entity, SDKHook_StartTouch, StartTouch);
		SDKHook(entity, SDKHook_Touch, StartTouch);
	}
}

public StartTouch(entity, client)
{
	if(IsValidClient(client) && ZR_IsClientHuman(client))
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		
		if(timers[entity] != INVALID_HANDLE) KillTimer(timers[entity]);
		timers[entity] = CreateTimer(3.0, Pasado, EntIndexToEntRef(entity));
		//timers[entity] = CreateTimer(3.0, Pasado, entity);
	}
}

public Action:Pasado(Handle:timer, any:ref)
{
 	new ent = EntRefToEntIndex(ref);
	if(ent == INVALID_ENT_REFERENCE) return;
	
	timers[ent] = INVALID_HANDLE;
	
	//if(IsValidEdict(ent) && IsValidEntity(ent))
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", -1);
}

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}