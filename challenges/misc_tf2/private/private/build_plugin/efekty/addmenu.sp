#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <morecolors>

new const attributs_index[MaxAttributs] = { 134, 142, 261 };
new const attributs_ks_index[MaxAttributs] = { 2013, 2014, 2025 };

/*new const String:attributs_name[MaxAttributs][25] = { "attach particle effect", "set item tint RGB", "set item tint RGB 2" };

new const attributs_particle_index[2] = { 519, 520 };
new const String:attributs_particle_name[2][32] = { "particle effect vertical offset", "particle effect use head origin" };
new const String:attributs_particle_menu_name[2][32] = { "Vertical Offset", "Head Offset" };
new player_efekt[MAXPLAYERS+1] = {0, 0, ...};*/

public OnPluginStart_Menu()
{	
	RegConsoleCmd("sm_bron", CmdWeapons);
	RegConsoleCmd("sm_bronie", CmdWeapons);

	RegConsoleCmd("sm_czapki", CmdHats);
	RegConsoleCmd("sm_hats", CmdHats);
	
	RegConsoleCmd("sm_efekty", CmdEffects);
	RegConsoleCmd("sm_effects", CmdEffects);
	
	RegConsoleCmd("sm_usun", CmdDelete);
	RegConsoleCmd("sm_delete", CmdDelete);
	
	RegConsoleCmd("sm_kolory", CmdColors);
	RegConsoleCmd("sm_colors", CmdColors);

	//RegConsoleCmd("sm_offset", CmdOffset);
}

/*public Action:CmdOffset(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	new Handle:hMenu = CreateMenu(Menu_Hat_Offset);
	SetMenuTitle(hMenu, "Wybierz offset");
	
	decl String:szInt[10];
	for(new i=0; i<2; i++)
	{
		IntToString(i, szInt, sizeof(szInt));
		AddMenuItem(hMenu, szInt, attributs_particle_menu_name[i]);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;	
}

public Menu_Hat_Offset(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		decl String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		
		player_efekt[client] = StringToInt(szInt);
		CPrintToChat(client, "Ustawiłeś offset %s ,zmień klase aby zobaczyć efekt ;)", attributs_particle_name[player_efekt[client]]);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}*/

public TF2Items_OnGiveNamedItem_Post(client, String:classname[], itemDefinitionIndex, itemLevel, itemQuality, entityIndex)
{
	if(StrEqual(classname, "tf_wearable"))
	{
		new index = -1;
		if((index = FindValueInArray(gPlayerData[client][hItems], itemDefinitionIndex)) == -1)
			return;
			
		new arrayDane[3] = {0, 0, ...};
		GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane, 3);
		
		for(new i=0; i<3; i++) 
		{
			if(arrayDane[i] == 0)
				continue;

			TF2Attrib_SetByDefIndex(entityIndex, attributs_index[i], float(arrayDane[i]));
		}
	}
	else if(StrContains(classname, "tf_weapon_") != -1)
	{
		new index = -1;
		if((index = FindValueInArray(gPlayerData[client][hItems], TF2_GetPlayerClass(client))) == -1)
		{
			if((index = FindValueInArray(gPlayerData[client][hItems], 0)) == -1)
				return;
		}
			
		new arrayDane[3] = {0, 0, ...};
		GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane, 3);
		// 0 - efekt
		// 1 - Sheen
		// 2 - suma tych dwuch
			
		for(new i=0; i<3; i++)
		{
			if(arrayDane[i] == 0)
				continue;
			
			TF2Attrib_SetByDefIndex(entityIndex, attributs_ks_index[i], float(arrayDane[i]));
		}
	}
}

/*public Action:TF2Items_OnGiveNamedItem(client, String:strClassName[], iItemDefinitionIndex, &Handle:hItemOverride)
{
	if(IsFakeClient(client))
		return Plugin_Continue;

	if(hItemOverride != INVALID_HANDLE)
		return Plugin_Continue;
		
	if(!StrEqual(strClassName, "tf_wearable"))
		return Plugin_Continue;
		
	new index = -1;
	if((index = FindValueInArray(gPlayerData[client][hItems], iItemDefinitionIndex)) == -1)
		return Plugin_Continue;
		
	new AtributsCount, ghFlags = 0, Handle:hItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	TF2Items_SetQuality(hItem, 7);
	ghFlags |= OVERRIDE_ITEM_QUALITY;
	
	new arrayDane[3] = {0, 0, ...};
	GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane, 3);
	
	//if(player_efekt[client] > 1)
	//	player_efekt[client] = 0;
		
	//if(player_efekt[client] == 0)
	//	arrayDane[3] = arrayDane[0];
		
	//if(player_efekt[client] == 1)
	//	arrayDane[4] = arrayDane[0];
	
	for(new i=0; i<3; i++) 
	{
		if(arrayDane[i] == 0)
			continue;

		TF2Items_SetAttribute(hItem, AtributsCount, attributs_index[i], float(arrayDane[i]));
		AtributsCount++;
	}
	if(AtributsCount != 0)
	{
		TF2Items_SetNumAttributes(hItem, AtributsCount);
		ghFlags |= OVERRIDE_ATTRIBUTES;
	}
	TF2Items_SetFlags(hItem, ghFlags);

	hItemOverride = hItem;
	return Plugin_Changed;
}*/

public Action:CmdColors(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	MenuKolory(client);
	return Plugin_Continue;	
}

public Action:CmdWeapons(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	MenuBronie(client);
	return Plugin_Continue;	
}

public Action:CmdHats(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	MenuSklep(client);
	return Plugin_Continue;	
}

public Action:CmdDelete(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	MenuUsun(client);
	return Plugin_Continue;	
}

public Action:CmdEffects(client, args)
{
	if(!IsClientInGame(client))
		return Plugin_Continue;

	new String:userFlag[10], arrayDane[3];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
	{
		CPrintToChat(client, "%t", "AccessToVip");
		return Plugin_Continue;
	}
	GetTrieArray(gServerData[hAccessTrie], userFlag, arrayDane, sizeof(arrayDane));
	
	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleMain", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_hMain);
	SetMenuTitle(hMenu, szLang);
	
	if(arrayDane[2] > 0)
	{
		AddMenuItem(hMenu, "0", "[NEW] Dodaj efekt na broń");
	}
	if(arrayDane[0] > 0)
	{
		AddMenuItem(hMenu, "1", "Dodaj efekt na czapki");
		AddMenuItem(hMenu, "2", "Usun efekt z czapki");
	}
	if(arrayDane[1] > 0)
	{
		AddMenuItem(hMenu, "3", "Stwórz własną farbę");
		AddMenuItem(hMenu, "4", "Usuń farbe z listy");
	}
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;	
}

public Menu_hMain(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		decl String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
	
		switch(StringToInt(szInt))
		{
			case 0: MenuBronie(client);
			case 1: MenuSklep(client);
			case 2: MenuUsun(client);
			case 3: MenuKoloryDodaj(client);
			case 4: MenuKoloryUsun(client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuSklep(client)
{
	if(!gServerData[iFile])
		return;

	new String:userFlag[10], arrayDane[3];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
	{ 
		CPrintToChat(client, "%t", "AccessToVip");
		return;
	}
	GetTrieArray(gServerData[hAccessTrie], userFlag, arrayDane, sizeof(arrayDane));
	
	if(!gPlayerData[client][bPlayerHaveColors])
	{
		OnCheckPlayerColors(client);
	}
	
	new ilosc = 0;
	for(new i=0; i<GetArraySize(gPlayerData[client][hItems]); i++)
	{
		if(GetArrayCell(gPlayerData[client][hItems], i) <= _:TFClass_Engineer)
			continue;
		ilosc++;
	}
	if(ilosc >= arrayDane[0] && arrayDane[0])
	{
		CPrintToChat(client, "%t", "TooMany", ilosc);
		return;
	}
	
	CPrintToChat(client, "%t", "Waiting");
	StworzSocket(client);
}

public MenuKolory(client)
{
	if(!gServerData[iFile])
		return;

	new String:userFlag[10];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
	{
		CPrintToChat(client, "%t", "AccessToVip");
		return;
	}
	
	if(!gPlayerData[client][bPlayerHaveColors])
	{
		OnCheckPlayerColors(client);
		CPrintToChat(client, "%t", "Replay");
		return;
	}
		
	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleColors", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_hKolory);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "0", "Zrób kolor");
	AddMenuItem(hMenu, "1", "Usuń kolor");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public MenuKoloryDodaj(client)
{
	new String:userFlag[10], arrayDane[3];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
	{
		CPrintToChat(client, "%t", "AccessToVip");
		return;
	}
	GetTrieArray(gServerData[hAccessTrie], userFlag, arrayDane, sizeof(arrayDane));
	
	new ilosc = GetArraySize(gPlayerData[client][hColors]);
	if(ilosc >= arrayDane[1] && arrayDane[1])
	{
		CPrintToChat(client, "%t", "TooManyColors", ilosc);
		return;
	}
	
	SendSocketOnce(client);
	
	decl String:szUrl[128];
	Format(szUrl, sizeof(szUrl), "http://%s%s/colors/?sid=%s", SOCKET_URL[index_socket], SOCKET_HOME[index_socket], gPlayerData[client][iPlayerSid]);
	UstawMotd(client, szUrl);
}

public MenuKoloryUsun(client)
{
	new ilosc = GetArraySize(gPlayerData[client][hColors]);
	if(ilosc <= 0)
	{
		CPrintToChat(client, "%t", "NoColors");
		return;
	}

	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleColorDelete", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Kolory_Usun);
	SetMenuTitle(hMenu, szLang);
	
	decl String:szName[20];
	for(new i=0; i<ilosc; i++)
	{
		GetArrayString(gPlayerData[client][hCName], i, szName, sizeof(szName));
		AddMenuItem(hMenu, szName, szName);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Kolory_Usun(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		decl String:szName[20];
		GetMenuItem(menu, param2, szName, sizeof(szName));
		
		DelClientColor(client, szName);
		CPrintToChat(client, "%t", "RemoveColor", szName);
		
		MenuKoloryUsun(client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_hKolory(Handle:menu, MenuAction:action, client, item)
{
	if(action == MenuAction_Select) 
	{
		if(item == 0)
		{
			MenuKoloryDodaj(client);
		}
		else
		{
			MenuKoloryUsun(client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuUsun(client)
{
	if(!gServerData[iFile])
		return;

	new ilosc = 0;
	for(new i=0; i<GetArraySize(gPlayerData[client][hItems]); i++)
	{
		if(GetArrayCell(gPlayerData[client][hItems], i) <= _:TFClass_Engineer)
			continue;
		ilosc++;
	}
	
	if(ilosc <= 0)
	{
		CPrintToChat(client, "%t", "NoEffects");
		return;
	}

	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleDelete", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Hats_Usun);
	SetMenuTitle(hMenu, szLang);
	
	decl String:szHat[64], String:szInt[10];
	new cell = 0;
	for(new i=0; i<GetArraySize(gPlayerData[client][hItems]); i++)
	{
		cell = GetArrayCell(gPlayerData[client][hItems], i);
		if(cell <= _:TFClass_Engineer)
			continue;
			
		IntToString(cell, szInt, sizeof(szInt));
		GetTrieString(gServerData[hItemsTrie], szInt, szHat, sizeof(szHat));
		AddMenuItem(hMenu, szInt, szHat);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Hats_Usun(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Taunting)) //gdy jest na drwinie to nie mozna
			return;
	
		decl String:szInt[10], String:szHat[64];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		GetTrieString(gServerData[hItemsTrie], szInt, szHat, sizeof(szHat));
		
		gPlayerData[client][iPlayerHat] = StringToInt(szInt);
		new arrayData[3] = {0, 0, ...}, index = -1;
		if((index = FindValueInArray(gPlayerData[client][hItems], gPlayerData[client][iPlayerHat])) == -1)
			return;
		
		GetArrayArray(gPlayerData[client][hEfekt], index, arrayData, sizeof(arrayData));
		TF2Attrib_AutoIndexForAllHats(client, arrayData, true);
		
		DelClientEfekt(client, gPlayerData[client][iPlayerHat]);
		CPrintToChat(client, "%t", "RemoveEffect", szHat);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public CreateClientHats(client, Handle:hArray) //otwiera sie po wywolaniu StworzSocket(client)
{
	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleHats", LANG_SERVER);

	new Handle:hMenu = CreateMenu(Menu_Hats);
	SetMenuTitle(hMenu, szLang);
	
	decl String:szHat[64], String:szInt[10];
	new item, flags, len;
	for(new i=0; i<GetArraySize(hArray); i++) 
	{
		item = GetArrayCell(hArray, i);
		IntToString(item, szInt, 9);
		if(FindValueInArray(gPlayerData[client][hItems], item) != -1)
			continue;
		
		if(!GetTrieString(gServerData[hItemsTrie], szInt, szHat, sizeof(szHat)))
			continue;
			
		len = 0;
		flags = 0;
		GetTrieValue(gServerData[hFlagsTrie], szInt, flags);
		len += Format(szHat[len], sizeof(szHat)-len, "%s ", szHat);
		if(flags & f_KOLOR)
			len += Format(szHat[len], sizeof(szHat)-len, "[P]");
		if(flags & f_EFEKT)
			len += Format(szHat[len], sizeof(szHat)-len, "[U]");
		
		AddMenuItem(hMenu, szInt, szHat);
	}
	CloseHandle(hArray);
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Hats(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		decl String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		GetTrieValue(gServerData[hFlagsTrie], szInt, gPlayerData[client][iPlayerFlags]);
		
		gPlayerData[client][iPlayerHat] = StringToInt(szInt);
		
		if(gPlayerData[client][iPlayerFlags] & f_EFEKT)
		{
			StworzMenuEfekt(client);
		}
		else
		{
			gPlayerData[client][iPlayerEffect] = 0;
			StworzMenuFarba(client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public StworzMenuEfekt(client)
{
	decl String:szLang[128], String:szInt[11], String:szItems[64];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleEffects", LANG_SERVER, gPlayerData[client][iPlayerHat]);
	
	new Handle:hMenu = CreateMenu(Menu_Efekt);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "n", "Nie chce żadnego Efektu!");
	new cell = 0;
	for(new i=0; i<GetArraySize(gServerData[hEfektyArray]); i++)
	{
		cell = GetArrayCell(gServerData[hEfektyArray], i);
		if(!(cell < 2000))
			continue;
			
		IntToString(cell, szInt, sizeof(szInt));
		GetTrieString(gServerData[hEfektyTrie], szInt, szItems, sizeof(szItems));

		AddMenuItem(hMenu, szInt, szItems);
	}

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Efekt(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select && gPlayerData[client][iPlayerHat] > 0) 
	{
		new String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		if(szInt[0] != 'n') // chce
			gPlayerData[client][iPlayerEffect] = StringToInt(szInt);
		else
			gPlayerData[client][iPlayerEffect] = 0;

		if(gPlayerData[client][iPlayerFlags] & f_KOLOR && GetArraySize(gPlayerData[client][hColors]) > 0)
		{
			StworzMenuFarba(client);
		}
		else
		{
			new arrayDane[3] = {0, 0, 0};
			arrayDane[0] = gPlayerData[client][iPlayerEffect];
			TF2Attrib_AutoIndexForAllHats(client, arrayDane, false);
			
			UstawEfekty(client, arrayDane);
		}

	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

new const String:NazwyPostaci[][] = {"All", "Skaut", "Snajper", "Żołnierz", "Demoman", "Medyk", "Gruby", "Pyro", "Szpieg", "Inżynier"};
public MenuBronie(client)
{
	if(!gServerData[iFile])
		return;
		
	new String:userFlag[10], arrayDane[3];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
	{
		CPrintToChat(client, "%t", "AccessToVip");
		return;
	}
	GetTrieArray(gServerData[hAccessTrie], userFlag, arrayDane, sizeof(arrayDane));
	if(!arrayDane[2])
	{
		CPrintToChat(client, "%t", "AccessToVip");
		return;
	}

	decl String:szLang[128], String:szInt[11];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleClass", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Class);
	SetMenuTitle(hMenu, szLang);
	
	for(new i=0; i<sizeof(NazwyPostaci); i++)
	{
		IntToString(i, szInt, sizeof(szInt));
		AddMenuItem(hMenu, szInt, NazwyPostaci[i]);
	}
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Class(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		new String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		gPlayerData[client][iPlayerHat] = StringToInt(szInt);
		
		MenuBronie2(client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuBronie2(client)
{
	decl String:szLang[128];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleWeapons", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Weapons);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "0", "Killstreaker (efekt)");
	AddMenuItem(hMenu, "1", "Sheen (blask)");
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Weapons(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select && gPlayerData[client][iPlayerHat] <= _:TFClass_Engineer) 
	{
		switch(param2)
		{
			case 0: MenuKillstreaker(client);
			case 1: MenuSheen(client);
		}
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		MenuBronie(client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuKillstreaker(client)
{
	decl String:szLang[128], String:szInt[11], String:szItems[64];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleKillstreaker", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Handle_Kill);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "n", "Brak!");
	new cell = 0;
	for(new i=0; i<GetArraySize(gServerData[hEfektyArray]); i++)
	{
		cell = GetArrayCell(gServerData[hEfektyArray], i);
		if(!(cell >= 2002 && cell < 22002))
			continue;
			
		IntToString(cell, szInt, sizeof(szInt));
		GetTrieString(gServerData[hEfektyTrie], szInt, szItems, sizeof(szItems));
	
		AddMenuItem(hMenu, szInt, szItems);
	}
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public MenuSheen(client)
{
	decl String:szLang[128], String:szInt[11], String:szItems[64];
	Format(szLang, sizeof(szLang), "%T", "MenuTitleSheen", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Handle_Sheen);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "n", "Brak!");
	new cell = 0;
	for(new i=0; i<GetArraySize(gServerData[hEfektyArray]); i++)
	{
		cell = GetArrayCell(gServerData[hEfektyArray], i);
		if(!(cell >= 22002))
			continue;
			
		IntToString(cell, szInt, sizeof(szInt));
		GetTrieString(gServerData[hEfektyTrie], szInt, szItems, sizeof(szItems));
	
		AddMenuItem(hMenu, szInt, szItems);
	}
	
	SetMenuExitBackButton(hMenu, true);
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Handle_Kill(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select && gPlayerData[client][iPlayerHat] <= _:TFClass_Engineer) 
	{
		new String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));
		
		new arrayData[3] = {0, 0, ...};
		new index = -1;
		if((index = FindValueInArray(gPlayerData[client][hItems], gPlayerData[client][iPlayerHat])) == -1)
		{
			arrayData[1] = 0;
		}
		else
		{
			new arrayDane2[3] = {0, 0, ...};
			GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane2, 3);
			arrayData[1] = arrayDane2[1];
		}
		arrayData[0] = StringToInt(szInt);
		
		if(szInt[0] == 'n')
			arrayData[0] = 0;

		if(arrayData[0] > 0 && arrayData[1] > 0)
			arrayData[2] = 3;
		else if(arrayData[0] == 0 && arrayData[1] > 0)
			arrayData[2] = 2;
		else if(arrayData[0] > 0 && arrayData[1] == 0)
			arrayData[2] = 2;
		else
			arrayData[2] = 0;
			
		if(arrayData[2] == 0)
			TF2Attrib_AutoIndexForAllWeapons(client, arrayData, true); //usuwa
			
		if(arrayData[0] == 0 && arrayData[1] && arrayData[2])
			TF2Attrib_DefIndexForAllWeapons(client, attributs_ks_index[0], 0.0, true);
			
		if(arrayData[0] == 0 && arrayData[1] == 0 && arrayData[2] == 0 && gPlayerData[client][iPlayerHat] > 0)
		{
			if((index = FindValueInArray(gPlayerData[client][hItems], 0)) != -1)
			{
				new arrayDane2[3] = {0, 0, ...};
				GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane2, 3);
				TF2Attrib_AutoIndexForAllWeapons(client, arrayDane2, false); //dodaje
			}
		}
		TF2Attrib_AutoIndexForAllWeapons(client, arrayData, false); //dodaje
	
		UstawEfekty(client, arrayData);
		MenuBronie2(client);
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		MenuBronie2(client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_Handle_Sheen(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select && gPlayerData[client][iPlayerHat] <= _:TFClass_Engineer) 
	{
		new String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));

		new arrayData[3] = {0, 0, ...};
		new index = -1;
		if((index = FindValueInArray(gPlayerData[client][hItems], gPlayerData[client][iPlayerHat])) == -1)
		{
			if((index = FindValueInArray(gPlayerData[client][hItems], 0)) == -1)
				arrayData[0] = 0;
		}
		else
		{
			new arrayDane2[3] = {0, 0, ...};
			GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane2, 3);
			arrayData[0] = arrayDane2[0];
		}
		arrayData[1] = StringToInt(szInt);
		
		if(arrayData[1] >= 22002)
				arrayData[1] -= 22001;
		
		if(szInt[0] == 'n')
			arrayData[1] = 0;

		if(arrayData[0] > 0 && arrayData[1] > 0)
			arrayData[2] = 3;
		else if(arrayData[0] == 0 && arrayData[1] > 0)
			arrayData[2] = 2;
		else if(arrayData[0] > 0 && arrayData[1] == 0)
			arrayData[2] = 2;
		else
			arrayData[2] = 0;
		
		if(arrayData[2] == 0)
			TF2Attrib_AutoIndexForAllWeapons(client, arrayData, true); //usuwa
			
		if(arrayData[1] == 0 && arrayData[0] && arrayData[2])
			TF2Attrib_DefIndexForAllWeapons(client, attributs_ks_index[0], 0.0, true);
			
		if(arrayData[0] == 0 && arrayData[1] == 0 && arrayData[2] == 0 && gPlayerData[client][iPlayerHat] > 0) //po usuenia z wybranej klasu ustawia dla danej klasy
		{
			if((index = FindValueInArray(gPlayerData[client][hItems], 0)) != -1)
			{
				new arrayDane2[3] = {0, 0, ...};
				GetArrayArray(gPlayerData[client][hEfekt], index, arrayDane2, 3);
				TF2Attrib_AutoIndexForAllWeapons(client, arrayDane2, false); //dodaje
			}
		}
		TF2Attrib_AutoIndexForAllWeapons(client, arrayData, false); //dodaje

		UstawEfekty(client, arrayData);
		MenuBronie2(client);
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		MenuBronie2(client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public StworzMenuFarba(client)
{
	new ilosc = GetArraySize(gPlayerData[client][hColors]);
	if(ilosc <= 0)
	{
		CPrintToChat(client, "%t", "NoColors");
		return;
	}

	decl String:szLang[128], String:szInt[11], String:szName[64];
	Format(szLang, sizeof(szLang), "%T", "MenuTitlePaints", LANG_SERVER);
	
	new Handle:hMenu = CreateMenu(Menu_Farba);
	SetMenuTitle(hMenu, szLang);
	
	AddMenuItem(hMenu, "n", "Nie chce żadnej Farby!");
	for(new i=0; i<ilosc; i++)
	{
		IntToString(i, szInt, sizeof(szInt));
		GetArrayString(gPlayerData[client][hCName], i, szName, sizeof(szName));

		AddMenuItem(hMenu, szInt, szName);
	}

	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_Farba(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select) 
	{
		decl String:szInt[10];
		GetMenuItem(menu, param2, szInt, sizeof(szInt));

		new arrayFarba[2] = {0, 0}, arrayDane[3] = {0, 0, 0};
		if(szInt[0] != 'n')
			GetArrayArray(gPlayerData[client][hColors], StringToInt(szInt), arrayFarba, 2);
		else
		{
			arrayFarba[0] = 0;
			arrayFarba[1] = 0;
		}
		arrayDane[0] = gPlayerData[client][iPlayerEffect];
		arrayDane[1] = arrayFarba[0];
		arrayDane[2] = arrayFarba[1];
		TF2Attrib_AutoIndexForAllHats(client, arrayDane, false);
		
		UstawEfekty(client, arrayDane);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public UstawEfekty(client, array[3])
{
	AddClientEfekt(client, gPlayerData[client][iPlayerHat], array);
	CPrintToChat(client, "%t", "InfoAfterBuy");
}

public UstawMotd(client, const String:url[])
{
	new Handle:Kv = CreateKeyValues("data");
	KvSetString(Kv, "title", "Title");
	KvSetNum(Kv, "type", MOTDPANEL_TYPE_URL);
	KvSetString(Kv, "msg", url);
	KvSetNum(Kv, "customsvr", 1);
	ShowVGUIPanel(client, "info", Kv);
	CloseHandle(Kv);
}

stock TF2Attrib_AutoIndexForAllWeapons(client, arrayDane[3], bool:delete = false) //ustaw tylko gdy jestem na tej samej klasy ktora wybrealem
{
	if(!IsPlayerAlive(client))
		return;

	if(_:TF2_GetPlayerClass(client) != gPlayerData[client][iPlayerHat] && gPlayerData[client][iPlayerHat] > 0)
		return;
		
	new bool:is_spy = !!(TF2_GetPlayerClass(client) == TFClass_Spy);
	for(new i=0; i<3; i++)
	{
		if(is_spy && i == 1)
			continue;
	
		new entity = GetPlayerWeaponSlot(client, i);
		if(!IsValidEntity(entity))
			continue;
		
		for(new j=0; j<3; j++)
		{
			if(arrayDane[j] == 0 && !delete)
				continue;
				
			delete? TF2Attrib_RemoveByDefIndex(entity, attributs_ks_index[j]) : TF2Attrib_SetByDefIndex(entity, attributs_ks_index[j], float(arrayDane[j]));
		}
	}
}

stock TF2Attrib_DefIndexForAllWeapons(client, iAttrib, Float:fVal, bool:delete = false)
{
	if(!IsPlayerAlive(client))
		return;

	if(_:TF2_GetPlayerClass(client) != gPlayerData[client][iPlayerHat] && gPlayerData[client][iPlayerHat] > 0)
		return;
		
	new bool:is_spy = !!(TF2_GetPlayerClass(client) == TFClass_Spy);
	for(new i=0; i<3; i++)
	{
		if(is_spy && i == 1)
			continue;
	
		new entity = GetPlayerWeaponSlot(client, i);
		if(!IsValidEntity(entity))
			continue;
		
		delete? TF2Attrib_RemoveByDefIndex(entity, iAttrib) : TF2Attrib_SetByDefIndex(entity, iAttrib, fVal);
	}
}

stock TF2Attrib_AutoIndexForAllHats(client, arrayDane[3], bool:delete = false)
{
	if(!IsPlayerAlive(client))
		return;

	new entity = MaxClients+1;
	while((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client || GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex") != gPlayerData[client][iPlayerHat])
			continue;
		
		for(new j=0; j<3; j++)
		{
			if(arrayDane[j] == 0 && !delete)
				continue;
				
			delete? TF2Attrib_RemoveByDefIndex(entity, attributs_index[j]) : TF2Attrib_SetByDefIndex(entity, attributs_index[j], float(arrayDane[j]));
		}
	}
}

/*stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
*/