#include <sourcemod>
#include <socket>
#include <morecolors>

public OnPluginStart_Update()
{	
	RegAdminCmd("sm_items_update", StworzSocketUpdate, ADMFLAG_ROOT, "Aktualizuje baze czapke dostepnych w menu"); 
}

new bool:update = false;
new ktory_plik = 0;

new String:szUpdatePliki[2][64] = { "hats_info_pl.txt", "efekt_info.txt" };
public Action:StworzSocketUpdate(client, args) 
{
	if(update)
	{
		ReplyToCommand(client, "Poczekaj! Trwa pobieranie aktualizacji");
		return Plugin_Handled;
	}

	update = true;
	gServerData[iFile] = false;
	ktory_plik = 0;
	
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketErrorUpdate);
	SocketSetArg(socket, client);
	SocketConnect(socket, OnSocketConnectedUpdate, OnSocketReceiveUpdate, OnSocketDisconnectedUpdate, SOCKET_URL[index_socket], 80);
	
	ReplyToCommand(0, "Trwa pobieranie aktualizacji");
	return Plugin_Handled;
}

public OnSocketConnectedUpdate(Handle:socket, any:client) 
{
	decl String:requestStr[200];
	Format(requestStr, sizeof(requestStr), "GET %s/hats/?update=1&port=%i HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", SOCKET_HOME[index_socket], gServerData[iPort], SOCKET_URL[index_socket]);
	
	SocketSend(socket, requestStr);
	update = true;
	gServerData[iFile] = false;
}

public OnSocketReceiveUpdate(Handle:socket, String:receiveData[], const dataSize, any:client) 
{
	update = false;
	gServerData[iFile] = false;
	
	new idx = get_pointer_pos(receiveData);
	if(receiveData[idx] == '1')
	{
		SocketAktualizacaPliku(szUpdatePliki[ktory_plik]);
		return;
	}
	ReplyToCommand(client, "Aktualizacja przerwana!!! Sprobuj pozniej");
}

public SocketAktualizacaPliku(String:nazwaPliku[])
{
	decl String:requestStr[200];
	Format(requestStr, sizeof(requestStr), "GET %s/hats/?file=%s&port=%i HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", SOCKET_HOME[index_socket], nazwaPliku, gServerData[iPort], SOCKET_URL[index_socket]);
	
	decl String:szFile[128];
	BuildPath(Path_SM, szFile, sizeof(szFile), "data/%s", nazwaPliku);
	new Handle:hFile = OpenFile(szFile, "wb");
	
	new Handle:hPack = CreateDataPack();
	WritePackCell(hPack, 0);			// 0 - bParsedHeader
	WritePackCell(hPack, _:hFile);		// 8
	WritePackString(hPack, requestStr);	// 16

	new Handle:sockets = SocketCreate(SOCKET_TCP, OnSocketErrorUpdate);
	SocketSetArg(sockets, hPack);
	SocketConnect(sockets, OnSocketConnectedUpdateFile, OnSocketReceiveUpdateFile, OnSocketDisconnectedUpdateFile, SOCKET_URL[index_socket], 80);
	
	gServerData[iFile] = false;
	
	update = true;
}

public OnSocketConnectedUpdateFile(Handle:socket, any:hPack) 
{
	decl String:requestStr[200];
	SetPackPosition(hPack, 2);
	ReadPackString(hPack, requestStr, sizeof(requestStr));
	
	SocketSend(socket, requestStr);
	gServerData[iFile] = false;
	
	update = true;
}

public OnSocketReceiveUpdateFile(Handle:socket, String:receiveData[], const dataSize, any:hPack) 
{
	update = false;
	new idx = 0;
	
	SetPackPosition(hPack, 0);
	new bool:bParsedHeader = bool:ReadPackCell(hPack);
	
	if(!bParsedHeader)
	{
		if((idx = StrContains(receiveData, "\r\n\r\n")) == -1)
			idx = 0;
		else
			idx += 4;
		
		SetPackPosition(hPack, 0);
		WritePackCell(hPack, 1);
	}

	SetPackPosition(hPack, 1);
	new Handle:open = Handle:ReadPackCell(hPack);
	
	while(idx < dataSize)
	{
		WriteFileCell(open, receiveData[idx++], 1);
	}
}

public OnSocketDisconnectedUpdateFile(Handle:socket, any:hPack)
{
	SetPackPosition(hPack, 1);
	CloseHandle(Handle:ReadPackCell(hPack));	// hFile
	CloseHandle(hPack);
	CloseHandle(socket);

	ktory_plik++;
	if(ktory_plik >= sizeof(szUpdatePliki))
	{
		gServerData[iFile] = true;
	
		update = false;
		
		ReplyToCommand(0, "Aktualizacja przebiegla pomyslnie");
		WczytajNazwyCzapek();
	}
	else
	{
		SocketAktualizacaPliku(szUpdatePliki[ktory_plik]);
	}
}

public OnSocketDisconnectedUpdate(Handle:socket, any:client)
{
	CloseHandle(socket);
	update = false;
}

public OnSocketErrorUpdate(Handle:socket, const errorType, const errorNum, any:client) 
{
	LogMessage("OnSocketErrorUpdate error %d (errno %d)", errorType, errorNum);
	
	CloseHandle(socket);
	gServerData[iFile] = false;
	
	update = false;
}