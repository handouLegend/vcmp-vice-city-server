//
// A Driver NPC that goes around a path continuously
// Kye 2009
//
// modified by habi 2022

//------------------------------------------

function NextPlayback()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"car7060");
}
	

//------------------------------------------

function OnRecordingPlaybackEnd()
{
    NextPlayback();
}

//------------------------------------------

function OnNPCEnterVehicle(vehicleid, seatid)
{
    NextPlayback();
}

//------------------------------------------

function OnNPCExitVehicle()
{
    StopRecordingPlayback();
}

//------------------------------------------
