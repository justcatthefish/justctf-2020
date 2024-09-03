#include <sourcemod>
#include <socket>
#include <morecolors>

new Handle:hTrieSocket;
public OnPluginStart_Listen()
{
	if(hTrieSocket == INVALID_HANDLE)
		hTrieSocket = CreateTrie();
	else
		ClearTrie(hTrieSocket);

	gServerData[iPort] = GetConVarInt(FindConVar("hostport")) + 25555;
	
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketErrorListen);
	SocketBind(socket, "0.0.0.0", gServerData[iPort]);
	SocketListen(socket, OnSocketIncoming);
}

public OnSocketIncoming(Handle:socket, Handle:newSocket, String:remoteIP[], remotePort, any:arg)
{
	//new bool:jest_ip = false;
	//for(new i=0; i<sizeof(SOCKET_IP); i++)
	//{
	//	if(StrContains(remoteIP, SOCKET_IP[i]) != -1)
	//	{
	//		jest_ip = true;
	//		break;
	//	}
	//}
	//if(!jest_ip)
	//{
	//	CloseHandle(newSocket);
	//	return;
	//}
    LogMessage("conn ip %s", remoteIP);

	SocketSetReceiveCallback(newSocket, OnChildSocketReceive);
	SocketSetDisconnectCallback(newSocket, OnChildSocketDisconnected);
	SocketSetErrorCallback(newSocket, OnChildSocketError);
}

public OnChildSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:arg) 
{
	new String:szInt[10], value = 0;
	IntToString(_:socket, szInt, sizeof(szInt));
    LogMessage("gotcmd: %s", receiveData);

	if(strncmp(receiveData, "open", 4) == 0)
	{
		LogMessage("password check was %s need %s", receiveData[5], gServerData[iHash]);
		LogMessage("password valid by force!");
		SetTrieValue(hTrieSocket, szInt, 1);

//		if(strcmp(receiveData[5], gServerData[iHash]) != 0) //invalid password
//		{
//			CloseHandle(socket);
//		}
		return;
	}
	else if(!GetTrieValue(hTrieSocket, szInt, value)) //jezeli nie jest podane "open:asdasda" lub nie ma "trie"
	{
		CloseHandle(socket);
		//TODO: return?
	}
	
	RemoveFromTrie(hTrieSocket, szInt); //usuwanie socketa z trie!
	if(strncmp(receiveData, "quit", 4) == 0)
	{
		CloseHandle(socket);
		return;
	}
	
	if(strncmp(receiveData, "ping", 4) == 0)
	{
		SocketSend(socket, "OK"); //odeslanie echa
		return;
	}
	
#if defined UPDATER
	if(strncmp(receiveData, "update", 6) == 0)
	{
		if(LibraryExists("updater")) {
			Updater_ForceUpdate();
		}
		SocketSend(socket, "OK"); //odeslanie echa
		return;
	}
#endif
	if(strncmp(receiveData, "cmd", 3) == 0 && strlen(receiveData[4]) > 4)
	{
		ServerCommand("%s", receiveData[4]);
		SocketSend(socket, "OK"); //odeslanie echa
		return;
	}
	
	if(strncmp(receiveData, "kolory", 6) != 0)
		return;
	
	decl String:szLang[256];
	new String:DaneArray[4][60], DaneCount, id_client = 0;
	DaneCount = ExplodeString(receiveData[7], ";", DaneArray, sizeof(DaneArray), sizeof(DaneArray[]));
	if(DaneCount != 4)
	{
		Format(szLang, sizeof(szLang), "%T", "WebBadData", LANG_SERVER);
		SocketSend(socket, szLang);
		return;
	}

	for(new client=1; client<=MaxClients; client++)
	{
		if(!IsClientInGame(client))
			continue;
	
		if(StrEqual(DaneArray[0], gPlayerData[client][iPlayerSid]))
		{
			id_client = client;
			break;
		}
	}
	
	if(!IsClientInGame(id_client))
	{
		Format(szLang, sizeof(szLang), "%T", "WebBadClient", LANG_SERVER);
		SocketSend(socket, szLang);
		return;
	}
	
	new String:userFlag[10], arrayDaneFlags[3];
	if(GetUserFlagByTrie(id_client, userFlag, sizeof(userFlag)) == false)
	{
		CPrintToChat(id_client, "%t", "AccessToVip");
		return;
	}
	GetTrieArray(gServerData[hAccessTrie], userFlag, arrayDaneFlags, sizeof(arrayDaneFlags));
	
	new ilosc = GetArraySize(gPlayerData[id_client][hColors]);
	if(ilosc >= arrayDaneFlags[1] && arrayDaneFlags[1])
	{
		Format(szLang, sizeof(szLang), "%T", "WebTooManyColors", LANG_SERVER, ilosc);
		SocketSend(socket, szLang);
		
		CPrintToChat(id_client, "%t", "TooManyColors", ilosc);
		return;
	}

	new arrayDane[2] = {0, 0};
	arrayDane[0] = StringToInt(DaneArray[2]);
	arrayDane[1] = StringToInt(DaneArray[3]);
	AddClientColor(id_client, arrayDane, DaneArray[1]);
	
	Format(szLang, sizeof(szLang), "%T", "WebInfoAddColor", LANG_SERVER);
	SocketSend(socket, szLang);
	
	CPrintToChat(id_client, "%t", "InfoAddColor");
}

public OnChildSocketDisconnected(Handle:socket, any:arg) {
	CloseHandle(socket);
}

public OnChildSocketError(Handle:socket, const errorType, const errorNum, any:ary) {
	LogError("OnChildSocketError error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public OnSocketErrorListen(Handle:socket, const errorType, const errorNum, any:arg) 
{
	LogError("OnSocketErrorListen error %d (errno %d)", errorType, errorNum);
	SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOSOCKET);
	CloseHandle(socket);
}

#if defined UPDATER
public Updater_OnPluginUpdated()
{
	ServerCommand("sm plugins reload efekty_new.smx");
}
#endif
