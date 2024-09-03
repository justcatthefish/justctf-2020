#include <sourcemod>

public OnPluginStart_Parser()
{	
	RegAdminCmd("sm_efekty_access_reload", PrzeladujAccessKonfing, ADMFLAG_ROOT, "Aktualizuje baze czapke dostepnych w menu"); 

	WczytajNazwyCzapek();
	WczytajAccessKonfing();
}

public Action:PrzeladujAccessKonfing(client, args) 
{
	ReplyToCommand(0, "Trwa przeladowanie konfinga");
	WczytajAccessKonfing();
	return Plugin_Handled;
}

public WczytajNazwyCzapek()
{
	decl String:szFile[128];
	BuildPath(Path_SM, szFile, sizeof(szFile), "data/hats_info_pl.txt");
	if((gServerData[iFile] = FileExists(szFile)) == false)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOFILE);
		return;
	}
	SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) & ~(CVAR_NOFILE));
	
	new Handle:open = OpenFile(szFile, "rt");
	decl String:szText[128], String:AttribsArray[3][64];
	
	if(gServerData[hItemsTrie] == INVALID_HANDLE)
		gServerData[hItemsTrie] = CreateTrie();
	else
		ClearTrie(gServerData[hItemsTrie]);
		
	if(gServerData[hFlagsTrie] == INVALID_HANDLE)
		gServerData[hFlagsTrie] = CreateTrie();
	else
		ClearTrie(gServerData[hFlagsTrie]);
	
	while(!IsEndOfFile(open))
	{
		ReadFileLine(open, szText, sizeof(szText));
		if(ExplodeString(szText, " ; ", AttribsArray, 3, 64) != 3)
			continue;
			
		TrimString(AttribsArray[0]);
		TrimString(AttribsArray[1]);
		TrimString(AttribsArray[2]);
		
		SetTrieString(gServerData[hItemsTrie], AttribsArray[0], AttribsArray[1]);
		SetTrieValue(gServerData[hFlagsTrie], AttribsArray[0], StringToInt(AttribsArray[2]));
	}
	
	CloseHandle(open);
	WczytajNazwyEfektow();
}

public WczytajNazwyEfektow()
{
	decl String:szFile[128];
	BuildPath(Path_SM, szFile, sizeof(szFile), "data/efekt_info.txt");
	if((gServerData[iFile] = FileExists(szFile)) == false)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOFILE);
		return;
	}
	SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) & ~(CVAR_NOFILE));

	new Handle:open = OpenFile(szFile, "rt");
	decl String:szText[128], String:AttribsArray[2][64];
	
	if(gServerData[hEfektyArray] == INVALID_HANDLE)
		gServerData[hEfektyArray] = CreateArray();
	else
		ClearArray(gServerData[hEfektyArray]);
		
	if(gServerData[hEfektyTrie] == INVALID_HANDLE)
		gServerData[hEfektyTrie] = CreateTrie();
	else
		ClearTrie(gServerData[hEfektyTrie]);
	
	while(!IsEndOfFile(open))
	{
		ReadFileLine(open, szText, sizeof(szText));
		if(ExplodeString(szText, " ; ", AttribsArray, 2, 64) != 2)
			continue;
			
		TrimString(AttribsArray[0]);
		TrimString(AttribsArray[1]);
		
		PushArrayCell(gServerData[hEfektyArray], StringToInt(AttribsArray[0]));
		SetTrieString(gServerData[hEfektyTrie], AttribsArray[0], AttribsArray[1]);
	}
	
	CloseHandle(open);
}

public WczytajAccessKonfing()
{
	decl String:szFile[128];
	BuildPath(Path_SM, szFile, sizeof(szFile), "configs/efekty_access.cfg");
	if((gServerData[iFile] = FileExists(szFile)) == false)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOACCESS);
		return;
	}
	SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) & ~(CVAR_NOACCESS));

	if(gServerData[hAccessTrie] == INVALID_HANDLE)
		gServerData[hAccessTrie] = CreateTrie();
	else
		ClearTrie(gServerData[hAccessTrie]);
		
	new Handle:hParser = SMC_CreateParser();
	new line = 0;

	SMC_SetReaders(hParser, Config_NewSection, Config_KeyValue, Config_EndSection);

	new SMCError:result = SMC_ParseFile(hParser, szFile);
	CloseHandle(hParser);

	if(result != SMCError_Okay) 
	{
		decl String:szError[128];
		SMC_GetErrorString(result, szError, sizeof(szError));
		LogError("Blad %s w lini %d, na pliku %s", szError, line, szFile);
	}
}

enum enumSMC
{
	iFlag,
	iLKillStreak,
	iLEffect,
	iLColor,
	iMin,
	iMax,
};
new gSMCdata[enumSMC];

public SMCResult:Config_NewSection(Handle:parser, const String:section[], bool:quotes) 
{
	return SMCParse_Continue;
}

public SMCResult:Config_KeyValue(Handle:parser, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes)
{
	if(StrEqual(key, "flag", false))
	{
		gSMCdata[iFlag] = value[0];
	}
	else if(StrEqual(key, "killstreak-bool", false))
	{
		gSMCdata[iLKillStreak] = !!(value[0]-'0');
	}
	else if(StrEqual(key, "effect-limit", false))
	{
		gSMCdata[iLEffect] = StringToInt(value);
	}
	else if(StrEqual(key, "color-limit", false))
	{
		gSMCdata[iLColor] = StringToInt(value);
	}
	return SMCParse_Continue;
}

public SMCResult:Config_EndSection(Handle:parser) 
{
	if('a' <= gSMCdata[iFlag] <= 'z' || gSMCdata[iFlag] == '0')
	{
		new String:szFlag[2], arrayDane[3] = {0, 0, ...};
		arrayDane[0] = gSMCdata[iLEffect];
		arrayDane[1] = gSMCdata[iLColor];
		arrayDane[2] = gSMCdata[iLKillStreak];
		
		Format(szFlag, sizeof(szFlag), "%c", gSMCdata[iFlag]);
		SetTrieArray(gServerData[hAccessTrie], szFlag, arrayDane, sizeof(arrayDane));
	}
	return SMCParse_Continue;
}