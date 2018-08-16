/*  Button Watcher
 *
 *  Copyright (C) 2017-2018 Francisco 'Franc1sco' García
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

#include <sourcemod>
#include <sdktools>

bool g_bPressed[2048];

ConVar cv_showtype, cv_log, cv_onlyadmins;

public Plugin myinfo =
{
	name = "Button Watcher",
	author = "Franc1sco franug",
	description = "Generates an output when a button is pressed",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	HookEntityOutput("func_button", "OnPressed", Button_Pressed);
	CreateConVar("sm_buttonwatcher", "1.2", "", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	cv_showtype = CreateConVar("sm_buttonwatcher_showtype", "1", "1 = show in chat. 0 = show in console");
	
	cv_log = CreateConVar("sm_buttonwatcher_log", "1", "1 = enabled logging. 0 = disabled logging");
	
	cv_onlyadmins = CreateConVar("sm_buttonwatcher_onlyadmins", "0", "1 = show only for admins. 0 = show for everybody");
}

public void Button_Pressed(const char[] output, int caller, int activator, float delay)
{
	if(!IsValidClient(activator) || !IsValidEntity(caller)) return;
	
	if(g_bPressed[caller]) return;
	
	decl String:entity[512];
	GetEntPropString(caller, Prop_Data, "m_iName", entity, sizeof(entity));

	if(GetConVarBool(cv_showtype)) 
	{
		if(!GetConVarBool(cv_onlyadmins)) 
		{
			PrintToChatAll(" \x02[BW] \x0C%N \x04pressed button\x0C %i %s", activator, caller, entity);
		}
		else 
		{
			for (int i = 1; i <= MaxClients; i++)
			{	
				if (IsClientInGame(i) && (GetUserAdmin(i) != INVALID_ADMIN_ID || IsClientSourceTV(i)))
				{
					PrintToChat(i, " \x02[BW] \x0C%N \x04pressed button\x0C %i %s", activator, caller, entity);
				}
			}
		}
	}
	else
	{
		if(!GetConVarBool(cv_onlyadmins)) 
		{
			PrintToConsoleAll("[BW] %N pressed button %i %s", activator, caller, entity);
		}
		else 
		{
			for (int i = 1; i <= MaxClients; i++)
			{	
				if (IsClientInGame(i) && (GetUserAdmin(i) != INVALID_ADMIN_ID || IsClientSourceTV(i)))
				{
					PrintToConsole(i, "[BW] %N pressed button %i %s", activator, caller, entity);
				}
			}
		}
		
	}
	
	if(GetConVarBool(cv_log)) 
		LogMessage("[BW] %L pressed the button %i %s", activator, caller, entity)
	
	g_bPressed[caller] = true;
	CreateTimer(5.0, Timer_End, caller);
}

public Action Timer_End(Handle timer, int entity)
{
	g_bPressed[entity] = false;
}

public bool IsValidClient( int client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) || !IsPlayerAlive(client) ) 
        return false; 
     
    return true; 
}
