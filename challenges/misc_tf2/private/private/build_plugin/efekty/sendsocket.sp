#include <sourcemod>
#include <socket>
#include <morecolors>
#include <sha1>

new index_socket = 0;
public StworzSocket(client) 
{
	if(gPlayerData[client][iPlayerSocket])
	{
		CPrintToChat(client, "%t", "Waiting");
		return;
	}
	gPlayerData[client][iPlayerSocket] = true;
	
	decl String:requestStr[256];
	Format(requestStr, sizeof(requestStr), "GET %s/hats/?sid=%s&port=%i HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", SOCKET_HOME[index_socket], gPlayerData[client][iPlayerSid], gServerData[iPort], SOCKET_URL[index_socket]);
	
	new Handle:hPack = CreateDataPack();
	new Handle:hArray = CreateArray();
	WritePackCell(hPack, client);		// 0
	WritePackCell(hPack, _:hArray);		// 8
	WritePackString(hPack, requestStr);	// 16
	
	new Handle:socket = SocketCreate(SOCKET_TCP, OnOneSocketError);
	SocketSetArg(socket, hPack);
	SocketConnect(socket, OnOneSocketConnected, OnOneSocketReceive, OnOneSocketDisconnected, SOCKET_URL[index_socket], 80);
}

public OnOneSocketConnected(Handle:socket, any:hPack) 
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	gPlayerData[client][iPlayerSocket] = true;
	
	ReadPackCell(hPack); //przesuniecie kursora w packu
	new String:requestStr[256];
	ReadPackString(hPack, requestStr, sizeof(requestStr));
	
	SocketSend(socket, requestStr);
}

public OnOneSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:hPack) 
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	if(!gPlayerData[client][iPlayerSocket])
		return;
		
	new idx = get_pointer_pos(receiveData);
	if(!CorrectSteamApi(client, receiveData[idx], receiveData[idx+1]))
		return;

	new Handle:hArray = Handle:ReadPackCell(hPack);
	ArrayExplodeString(hArray, receiveData, dataSize, idx+2);
}

stock ArrayExplodeString(Handle:array, String:data[], const dataSize, const dataStart, const strip = ' ', const bool:cell = true)
{
	static String:napis[32];
	static num = 0; 
	new idx = dataStart;
	while (idx < dataSize)
	{
		if(data[idx] == strip || num >= 31)
		{
			if(napis[0])
			{
				if(cell)
					PushArrayCell(array, StringToInt(napis));
				else
					PushArrayString(array, napis);
			}
			napis[0] = 0;
			num = 0;
		}
		else
		{
			napis[num] = data[idx];
			napis[num+1] = 0;
			num++;
		}
		idx++;
	}
}

public OnOneSocketDisconnected(Handle:socket, any:hPack)
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	gPlayerData[client][iPlayerSocket] = false;
	
	CreateClientHats(client, Handle:ReadPackCell(hPack));
	
	CloseHandle(hPack);
	CloseHandle(socket);
}

public OnOneSocketError(Handle:socket, const errorType, const errorNum, any:hPack)
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	gPlayerData[client][iPlayerSocket] = false;
	
	ChangeToNextHost(errorType);
	LogError("OnSocketError error %d (errno %d)", errorType, errorNum);
	CloseHandle(hPack);
	CloseHandle(socket);
}

public CorrectSteamApi(client, num, przecinek)
{
	if(przecinek != ',')
		return 1;
	
	switch(num)
	{
		case '1': {
			CPrintToChat(client, "%t", "InfoSteamApi1");
			return 1;
		}
		case '2': CPrintToChat(client, "%t", "InfoSteamApi2");
		case '3': CPrintToChat(client, "%t", "InfoSteamApi3");
		case '4': CPrintToChat(client, "%t", "InfoSteamApi4");
		case 'I': CPrintToChat(client, "Brak aktywnej licencji!"), SET_LICENSE;
		default: CPrintToChat(client, "%t", "InfoSteamApi5"); 
	}
	return 0;
}

//////////////////////////////
public SendSocketOnce(client) 
{
	new String:requestStr[256], String:szIP[17];
	if(client) GetClientIP(client, szIP, 17);
	Format(requestStr, sizeof(requestStr), "GET %s/colors/?sid=%s&port=%i&ip=%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", SOCKET_HOME[index_socket], gPlayerData[client][iPlayerSid], gServerData[iPort], szIP, SOCKET_URL[index_socket]);
	
	new Handle:hPack = CreateDataPack();
	WritePackCell(hPack, client);	// 0
	WritePackString(hPack, requestStr);	// 0
	
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSendSocketError);
	SocketSetArg(socket, hPack);
	SocketConnect(socket, OnSendSocketConnected, OnSendSocketReceive, OnSendSocketDisconnected, SOCKET_URL[index_socket], 80);
}

public OnSendSocketConnected(Handle:socket, any:hPack) 
{
	new String:requestStr[256];
	ResetPack(hPack);
	ReadPackCell(hPack);
	ReadPackString(hPack, requestStr, sizeof(requestStr));
	
	SocketSend(socket, requestStr);
}

public OnSendSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:hPack) 
{
	ResetPack(hPack);
	new idx = get_pointer_pos(receiveData);
	gEfekty = ((receiveData[idx] == 'I' /* && receiveData[idx+11] == 'a' */)? 2: 0);
	if(!(gEfekty == 0 && ReadPackCell(hPack) == 0))
		return;

	new String:str[82];
	FormatEx(str, sizeof(str), "c17e7d02ef1bbd2f87d269143bfeef7983e33124%s", receiveData[idx]);
	SHA1String(str, gServerData[iHash], true);
	//PrintToServer(receiveData[idx]);
	//PrintToServer(str);
	//PrintToServer(gServerData[iHash]);
}

public OnSendSocketDisconnected(Handle:socket, any:hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}

public OnSendSocketError(Handle:socket, const errorType, const errorNum, any:hPack)
{
	LogError("OnSendSocketError error %d (errno %d)", errorType, errorNum);
	ChangeToNextHost(errorType);
	
	CloseHandle(hPack);
	CloseHandle(socket);
}

public get_pointer_pos(String:szData[])
{
	return (StrContains(szData, "<header>") == -1)? 0: StrContains(szData, "<header>")+8;
}

public ChangeToNextHost(errorType)
{
	if(errorType != CONNECT_ERROR)
		return;
	
	index_socket++;
	if(index_socket >= sizeof(SOCKET_URL))
		index_socket = 0;
}