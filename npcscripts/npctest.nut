//
// NPC Test Script
// Kye 2009
//

//Modified by habi 2022

function OnNPCScriptLoad( params )
{
	print("npctest: OnNPCScriptLoad()\n");
	if( params.len() > 0 )
	{
		print("Parameters passed to script are: \n");
		for( local i=0; i < params.len(); i++ )
			print(params[i] + "\n");
	}
	SetTimer("TimerTest",10000,1);
}

function OnNPCScriptUnload()
{
	print("npctest: OnNPCScriptUnload\n");
}

function TimerTest()
{
	local msg;
    local name;
	local pos;
	local Distance;
	local x;
	local num_streamed_in = 0;
	local num_connected = 0;
	x=0;
	while(x!=MAX_PLAYERS) {
	    if(IsPlayerConnected(x)) {
	        num_connected++;
	        if(IsPlayerStreamedIn(x)) {
	            num_streamed_in++;
	       		name=GetPlayerName(x);
				pos=GetPlayerPos(x);
				Distance=GetDistanceFromMeToPoint(pos);
				msg=format("I see %s @ %f units with state:%d health:%d armour:%d weapon:%d",
						name,Distance,GetPlayerState(x),GetPlayerHealth(x),GetPlayerArmour(x),GetPlayerArmedWeapon(x));
				SendChat(msg);

				if(GetPlayerState(x) == PLAYER_STATE_DRIVER) {
				    msg=format("I see %s driving vehicle: %d",name,GetPlayerVehicleID(x));
					SendChat(msg);
				}
				
			}
		}
		x++;
	}
	
	msg=format("I have %d connected players with %d streamed in",num_connected,num_streamed_in);
	SendChat(msg);
	//SendChat("I am waiting around patiently");
}

function OnNPCConnect(myplayerid)
{
	print("npctest: OnNPCConnect(My playerid="+myplayerid+")\n");
}

function OnNPCDisconnect(reason)
{
	print("npctest: OnNPCDisconnect(reason="+reason+")\n");
}
function OnNPCClassSelect()
{
	print("npctest: OnNPCClassSelect\n");
}
function OnNPCSpawn()
{
    print("npctest: OnNPCSpawn\n");
}

//------------------------------------------

function OnNPCEnterVehicle(vehicleid, seatid)
{
	print("npctest: OnNPCEnterVehicle(vehicleid="+vehicleid+",seatid="+seatid+")\n");
}

//------------------------------------------

function OnNPCExitVehicle()
{
    print("npctest: OnNPCExitVehicle\n");
}

//------------------------------------------

function OnClientMessage(r,g,b, text)
{
    print("npctest: OnClientMessage(color=["+r+","+g+","+b+"] text="+text+")\n");
}

//------------------------------------------

function OnPlayerDeath(playerid)
{
    print("npctest: OnPlayerDeath(playerid="+playerid+")\n");
}

//------------------------------------------

function OnPlayerText(playerid, text)
{
    print("npctest: (CHAT)(from="+playerid+", text="+text+")\n");
}

//------------------------------------------

function OnPlayerStreamIn(playerid)
{
    print("npctest: OnPlayerStreamIn(playerid="+playerid+")\n");
}

//------------------------------------------

function OnPlayerStreamOut(playerid)
{
    print("npctest: OnPlayerStreamOut(playerid="+playerid+")\n");
}

//------------------------------------------

function OnVehicleStreamIn(vehicleid)
{
    print("npctest: OnVehicleStreamIn(vehicleid="+vehicleid+")\n");
}

//------------------------------------------

function OnVehicleStreamOut(vehicleid)
{
    print("npctest: OnVehicleStreamOut(vehicleid="+vehicleid+")\n");
}

//------------------------------------------

function OnTimeWeatherSync(timerate, minute, hour, weather) 
{
	print("npctest: OnTimeWeatherSync(timerate="+timerate+", time="+hour+":"+minute+", weather="+weather+")\n");
}

//-----------------------------------------

function OnServerShareTick(tickcount)
{
	print("npctest: OnServerShareTick(tickcount="+tickcount+")\n");
}

//-----------------------------------------

function OnServerData(data) 
{
    local str="";
	while(data.tell() < data.len())
		str+=format("%.2x",ReadByte(data))+" ";
	print("npctest: OnServerData(data="+str+")\n");
}