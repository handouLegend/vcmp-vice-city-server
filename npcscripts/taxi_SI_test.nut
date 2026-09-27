//
// A test driver NPC with very basic AI
// Kye 2009
//
//modified by habi 2022

local gStoppedForTraffic = 0;
local gPlaybackActive = 0;

AHEAD_OF_CAR_DISTANCE   <- 11.0
SCAN_RADIUS     		<- 11.0


//------------------------------------------
function move(pos, distance, angle)
{
	local newx = pos.x - sin(angle)*distance;
	local newy = pos.y + cos(angle)*distance;
	return Vector(newx,newy,pos.z);//assuming z more or less same.
}
function move2(pos,pangle,dis,angle)
{
	return move(pos,dis,pangle+angle)
}
function GetXYInfrontOfMe(distance)
{
    local angle, pos;
    pos=GetMyPos();
    angle=GetMyFacingAngle();
    pos=move2(pos,angle,distance,0);//Like Move to the position which is at 'distance' and angle '0'=forward. first 2 parameters=current position and angle.
	return pos;
}

//------------------------------------------

function OnNPCScriptLoad( params )
{
	SetTimer("ScanTimer",200,1);
}

//------------------------------------------

function LookForAReasonToPause()
{
  	local pos;
	local x=0;
	pos=GetMyPos();
	local pos2;
	pos2=GetXYInfrontOfMe(AHEAD_OF_CAR_DISTANCE);
	while(x!=MAX_PLAYERS) {
	    if(IsPlayerConnected(x) && IsPlayerStreamedIn(x)) {
			if( GetPlayerState(x) == PLAYER_STATE_DRIVER ||
			    GetPlayerState(x) == PLAYER_STATE_ONFOOT ||
				GetPlayerState(x) == PLAYER_STATE_ENTER_VEHICLE_PASSENGER )
			{
				if(IsPlayerInRangeOfPoint(x,SCAN_RADIUS,pos2)) {
					return 1;
				}
			}
		}
		x++;
	}
	
	return 0;
}


//------------------------------------------

function ScanTimer()
{
  if(!gPlaybackActive)return;
	
  local ReasonToPause = LookForAReasonToPause();
   
   if(ReasonToPause && !gStoppedForTraffic)
	{
	    //SendChat("I'm pausing");
		PauseRecordingPlayback();
		gStoppedForTraffic = 1;
	}
	else if(!ReasonToPause && gStoppedForTraffic)
	{
	    //SendChat("I'm resuming");
		ResumeRecordingPlayback();
	    gStoppedForTraffic = 0;
	}
}


//------------------------------------------

function StartPlayback()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"taxi_test_1300");
	gStoppedForTraffic = 0;
	gPlaybackActive = 1;
}
	

//------------------------------------------

function OnRecordingPlaybackEnd()
{
    StartPlayback();
}

//------------------------------------------

function OnNPCEnterVehicle(vehicleid, seatid)
{
    StartPlayback();
}

//------------------------------------------

function OnNPCExitVehicle()
{
    StopRecordingPlayback();
}

//------------------------------------------
