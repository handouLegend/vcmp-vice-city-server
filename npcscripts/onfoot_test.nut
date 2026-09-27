/* Copyright SA-MP 2009
modified by habi 2022*/

function OnNPCScriptLoad( params ){ }
//------------------------------------------

function NextPlayback()
{
   StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT,"shotrun");
}

//------------------------------------------

function OnRecordingPlaybackEnd()
{
    NextPlayback();
}

//------------------------------------------

function OnNPCSpawn()
{
    NextPlayback();
}

//------------------------------------------

function OnNPCExitVehicle()
{
    StopRecordingPlayback();
}

//------------------------------------------
