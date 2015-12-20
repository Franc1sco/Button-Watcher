#include <sourcemod>
#include <sdktools>

new bool:espresionado[2048];

public Plugin:myinfo =
{
	name = "Button Watcher",
	author = "Franc1sco franug",
	description = "Generates an output when a button is pressed",
	version = "1.1",
	url = "http://www.zeuszombie.com/"
};

public OnPluginStart()
{
	HookEntityOutput("func_button", "OnPressed", Presionado);
	CreateConVar("sm_buttonwatcher", "1.1", "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public Presionado(const String:output[], caller, activator, Float:delay)
{
	if(!IsValidClient(activator)) return;
	
	if(espresionado[caller]) return;
	
	decl String:entity[512];
	GetEntPropString(caller, Prop_Data, "m_iName", entity, sizeof(entity));

	PrintToChatAll(" \x02[BW] \x0C%N \x04pressed button\x0C %i %s", activator, caller, entity);
	
	LogMessage("[BW] %L pressed the button %i %s", activator, caller, entity)
	
	espresionado[caller] = true;
	CreateTimer(5.0, Pasado, caller);
}

public Action:Pasado(Handle:timer, any:entity)
{
	espresionado[entity] = false;
}

public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) || !IsPlayerAlive(client) ) 
        return false; 
     
    return true; 
}
