#include <sourcemod>
#include <morecolors>

public OnPluginStart_Sql()
{	
	CreateDataBase();
}

public OnMapStart_Sql()
{
	/*new String:query[255];
	Format(query, sizeof(query), "DELETE FROM `PlayerEfektNew` WHERE `TIME` < '%d'", GetTime());
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, query);*/
}

public OnClientPostAdminCheck_Sql(client)
{
	if(gEfekty & f_EFEKT)
	{
		SET_LICENSE;
		return;
	}

	if(gPlayerData[client][hItems] == INVALID_HANDLE) 
		gPlayerData[client][hItems] = CreateArray();
	else
		ClearArray(gPlayerData[client][hItems]);
		
	if(gPlayerData[client][hEfekt] == INVALID_HANDLE) 
		gPlayerData[client][hEfekt] = CreateArray(3);
	else
		ClearArray(gPlayerData[client][hEfekt]);
		
	if(gPlayerData[client][hCName] == INVALID_HANDLE) 
		gPlayerData[client][hCName] = CreateArray(ByteCountToCells(20));
	else
		ClearArray(gPlayerData[client][hCName]);
		
	if(gPlayerData[client][hColors] == INVALID_HANDLE)
		gPlayerData[client][hColors] = CreateArray(2);
	else
		ClearArray(gPlayerData[client][hColors]);

	new String:userFlag[10];
	if(GetUserFlagByTrie(client, userFlag, sizeof(userFlag)) == false)
		return;
	
	decl String:buffer[255];
	Format(buffer, sizeof(buffer), "SELECT `ITEM`,`EFEKT` FROM `PlayerEfektNew` WHERE `PlayerEfektNew`.`STEAMID` = '%s'", gPlayerData[client][iPlayerSid]);
	SQL_TQuery(gServerData[hDb], SQL_CheckEfektUsr, buffer, GetClientUserId(client));
}

public SQL_CheckEfektUsr(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
	if((client = GetClientOfUserId(data)) == 0)
		return;
	
	if(hndl == INVALID_HANDLE)
	{
		LogError("SQL_CheckEfektUsr Query failed! %s", error);
		return;
	}

	decl String:szText[32], String:AttribsArray[3][10];
	new arrayDane[3] = {0, 0, 0}, IDitem;
	while(SQL_FetchRow(hndl))
	{
		IDitem = SQL_FetchInt(hndl, 0);
		if(FindValueInArray(gPlayerData[client][hItems], IDitem) != -1)
			continue;
		
		SQL_FetchString(hndl, 1, szText, sizeof(szText));
		ExplodeString(szText, " ", AttribsArray, 3, 10);
		
		arrayDane[0] = StringToInt(AttribsArray[0]);
		arrayDane[1] = StringToInt(AttribsArray[1]);
		arrayDane[2] = StringToInt(AttribsArray[2]);
				
		if(arrayDane[0] || arrayDane[1] || arrayDane[2])
		{
			PushArrayArray(gPlayerData[client][hEfekt], arrayDane, 3);
			PushArrayCell(gPlayerData[client][hItems], IDitem);
		}
	}
}

public OnCheckPlayerColors(client)
{
	decl String:buffer[255];
	Format(buffer, sizeof(buffer), "SELECT `NAME`,`COLOR` FROM `PlayerColors` WHERE `PlayerColors`.`STEAMID` = '%s'", gPlayerData[client][iPlayerSid]);
	SQL_TQuery(gServerData[hDb], SQL_CheckKolorUsr, buffer, GetClientUserId(client));
}

public SQL_CheckKolorUsr(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client;
	if((client = GetClientOfUserId(data)) == 0)
		return;
	
	if(hndl == INVALID_HANDLE)
	{
		LogError("SQL_CheckKolorUsr Query failed! %s", error);
		return;
	}

	decl String:szText[32], String:AttribsArray[2][10];
	new arrayDane[2] = {0, 0};
	while(SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, szText, sizeof(szText));
		if(FindStringInArray(gPlayerData[client][hCName], szText) != -1)
			continue;

		PushArrayString(gPlayerData[client][hCName], szText);
			
		SQL_FetchString(hndl, 1, szText, sizeof(szText));
		ExplodeString(szText, " ", AttribsArray, 2, 10);
			
		arrayDane[0] = StringToInt(AttribsArray[0]);
		arrayDane[1] = StringToInt(AttribsArray[1]);
				
		PushArrayArray(gPlayerData[client][hColors], arrayDane, 2);
	}
	gPlayerData[client][bPlayerHaveColors] = true;
}

public SQL_ErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(!StrEqual("", error))
	{
		LogError("SQL_ErrorCheckCallback Error: %s", error);
		return;
	}
}

CreateDataBase()
{
	if(!SQL_CheckConfig("default"))
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOSQL);
		return;
	}
	
	new String:Error[255];
	gServerData[hDb] = SQL_Connect("default", true, Error, 255);
	if(gServerData[hDb] == INVALID_HANDLE)	
	{
		PrintToServer("Failed to connect: %s", Error);
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOSQL);
		return;
	}
	
	new len = 0;
	decl String:query[512];
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PlayerEfektNew` (");
	len += Format(query[len], sizeof(query)-len, "`STEAMID` varchar(32) NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "`ITEM` int(11) NOT NULL, PRIMARY KEY(`STEAMID`, `ITEM`), ");
	len += Format(query[len], sizeof(query)-len, "`EFEKT` varchar(32) NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "`TIME` int(11) NOT NULL");
	len += Format(query[len], sizeof(query)-len, ") ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;");
	SQL_FastQuery(gServerData[hDb], query);
	
	//SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, "ALTER TABLE `PlayerEfektNew` DROP PRIMARY KEY");
	//SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, "DELETE FROM `PlayerEfektNew`,`PlayerColors` WHERE 1");
	//SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, "ALTER TABLE `PlayerEfektNew` ADD PRIMARY KEY(`STEAMID`,`ITEM`)");
	//SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, "ALTER TABLE `PlayerColors` ADD PRIMARY KEY(`STEAMID`,`NAME`)");

	len = 0;
	len = Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `PlayerColors` (");
	len += Format(query[len], sizeof(query)-len, "`STEAMID` varchar(32) NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "`NAME` varchar(20) NOT NULL, PRIMARY KEY(`STEAMID`, `NAME`), ");
	len += Format(query[len], sizeof(query)-len, "`COLOR` varchar(32) NOT NULL,");
	len += Format(query[len], sizeof(query)-len, "`TIME` int(11) NOT NULL");
	len += Format(query[len], sizeof(query)-len, ") ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci;");
	SQL_FastQuery(gServerData[hDb], query);
}

AddClientEfekt(client, czapka, efekt[3])
{
	/*decl String:buffer[250];
	if(efekt[0] || efekt[1] || efekt[2])
	{
		Format(buffer, sizeof(buffer), "INSERT INTO `PlayerEfektNew` (`STEAMID`,`ITEM`,`EFEKT`,`TIME`) VALUES ('%s','%d','%d %d %d','%d') ON DUPLICATE KEY UPDATE `EFEKT` = '%d %d %d'", gPlayerData[client][iPlayerSid], czapka, efekt[0], efekt[1], efekt[2], GetTime()+30*24*60*60, efekt[0], efekt[1], efekt[2]);
	}
	else
	{
		Format(buffer, sizeof(buffer), "DELETE FROM `PlayerEfektNew` WHERE `STEAMID` = '%s' AND `ITEM` = '%d'", gPlayerData[client][iPlayerSid], czapka);
	}
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, buffer);
	*/
	
	decl String:buffer[250];
	Format(buffer, sizeof(buffer), "INSERT INTO `PlayerEfektNew` (`STEAMID`,`ITEM`,`EFEKT`,`TIME`) VALUES ('%s','%d','%d %d %d','%d') ON DUPLICATE KEY UPDATE `EFEKT` = '%d %d %d'", gPlayerData[client][iPlayerSid], czapka, efekt[0], efekt[1], efekt[2], GetTime()+30*24*60*60, efekt[0], efekt[1], efekt[2]);
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, buffer);
	
	new index = -1;
	if((index = FindValueInArray(gPlayerData[client][hItems], czapka)) != -1)
	{
		RemoveFromArray(gPlayerData[client][hItems], index);
		RemoveFromArray(gPlayerData[client][hEfekt], index);
	}
	if(efekt[0] || efekt[1] || efekt[2])
	{
		PushArrayCell(gPlayerData[client][hItems], czapka);
		PushArrayArray(gPlayerData[client][hEfekt], efekt, 3);
	}
}

DelClientEfekt(client, czapka)
{
	decl String:buffer[250];
	Format(buffer, sizeof(buffer), "DELETE FROM `PlayerEfektNew` WHERE `STEAMID` = '%s' AND `ITEM` = '%d'", gPlayerData[client][iPlayerSid], czapka);
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, buffer);
	
	new index = -1;
	if((index = FindValueInArray(gPlayerData[client][hItems], czapka)) != -1)
	{
		RemoveFromArray(gPlayerData[client][hItems], index);
		RemoveFromArray(gPlayerData[client][hEfekt], index);
	}
}

AddClientColor(client, color[2], String:szName[])
{
	decl String:buffer[250];
	Format(buffer, sizeof(buffer), "INSERT INTO `PlayerColors` (`STEAMID`,`NAME`,`COLOR`,`TIME`) VALUES ('%s','%s','%d %d','%d')", gPlayerData[client][iPlayerSid], szName, color[0], color[1], GetTime()+30*24*60*60);
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, buffer);
	
	PushArrayString(gPlayerData[client][hCName], szName);
	PushArrayArray(gPlayerData[client][hColors], color, 2);
}

DelClientColor(client, String:szName[])
{
	decl String:buffer[250];
	Format(buffer, sizeof(buffer), "DELETE FROM `PlayerColors` WHERE `STEAMID` = '%s' AND `NAME` = '%s'", gPlayerData[client][iPlayerSid], szName);
	SQL_TQuery(gServerData[hDb], SQL_ErrorCheckCallback, buffer);

	new index = -1;
	if((index = FindStringInArray(gPlayerData[client][hCName], szName)) != -1)
	{
		RemoveFromArray(gPlayerData[client][hCName], index);
		RemoveFromArray(gPlayerData[client][hColors], index);
	}
}
