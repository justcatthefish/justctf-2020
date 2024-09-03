#include <sourcemod>
#include <sdktools>

new Handle:hSDKSchema;
new Handle:hSDKSetRuntimeValue;
new Handle:hSDKRemoveAttribute;

new Handle:hSDKGetAttributeDef;

public OnPluginStart_Attributes()
{
	new Handle:hGameConf = LoadGameConfigFile("tf2.attributes");
	if (hGameConf == INVALID_HANDLE)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOATTRIB);
		SetFailState("Could not locate gamedata file tf2.attributes.txt for TF2Attributes, pausing plugin");
	}
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKSchema = EndPrepSDKCall();
	if (hSDKSchema == INVALID_HANDLE)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOATTRIB);
		SetFailState("Could not initialize call to GEconItemSchema");
	}
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKGetAttributeDef = EndPrepSDKCall();
	if (hSDKGetAttributeDef == INVALID_HANDLE)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOATTRIB);
		SetFailState("Could not initialize call to CEconItemSchema::GetAttributeDefinition");
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::RemoveAttribute");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKRemoveAttribute = EndPrepSDKCall();
	if (hSDKRemoveAttribute == INVALID_HANDLE)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOATTRIB);
		SetFailState("Could not initialize call to CAttributeList::RemoveAttribute");
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CAttributeList::SetRuntimeAttributeValue");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hSDKSetRuntimeValue = EndPrepSDKCall();
	if (hSDKSetRuntimeValue == INVALID_HANDLE)
	{
		SetConVarInt(gServerData[hCvarInfo], GetConVarInt(gServerData[hCvarInfo]) | CVAR_NOATTRIB);
		SetFailState("Could not initialize call to CAttributeList::SetRuntimeAttributeValue");
	}
}

public TF2Attrib_SetByDefIndex(entity, iAttrib, Float:flVal)
{
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "TF2Attrib_SetByDefIndex: Invalid entity index %d passed", entity);
	}

	new offs = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offs <= 0)
	{
		return false;
	}
	new Address:pEntity = GetEntityAddress(entity);
	if (pEntity == Address_Null)
		return false;
	
	new Address:pSchema = SDKCall(hSDKSchema);
	if (pSchema == Address_Null)
		return false;
	
	new Address:pAttribDef = SDKCall(hSDKGetAttributeDef, pSchema, iAttrib);
	if (pAttribDef < Address_MinimumValid)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "TF2Attrib_SetByDefIndex: Attribute %d not valid", iAttrib);
	}
	new bool:bSuccess = !!SDKCall(hSDKSetRuntimeValue, pEntity+Address:offs, pAttribDef, flVal);
	return bSuccess;
}

public TF2Attrib_RemoveByDefIndex(entity, iAttrib)
{
	if (!IsValidEntity(entity))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "TF2Attrib_RemoveByDefIndex: Invalid entity index %d passed", entity);
		return false;
	}

	new offs = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offs <= 0)
	{
		return false;
	}
	new Address:pEntity = GetEntityAddress(entity);
	if (pEntity == Address_Null)
		return false;

	if (pEntity == Address_Null)
		return false;
	
	new Address:pSchema = SDKCall(hSDKSchema);
	if (pSchema == Address_Null)
		return false;
	
	new Address:pAttribDef = SDKCall(hSDKGetAttributeDef, pSchema, iAttrib);
	if (pAttribDef < Address_MinimumValid)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "TF2Attrib_RemoveByDefIndex: Attribute %d not valid", iAttrib);
	}
	SDKCall(hSDKRemoveAttribute, pEntity+Address:offs, pAttribDef);
	return true;
}

