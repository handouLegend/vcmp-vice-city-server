// cutscene actor. The server passes parameters:
//   params[0] = the pose, optionally with a silence time: "sit" / "stand" / "stand@14.0"
//               (@ = seconds after SPAWN at which this script stops sending anything at all)
//   params[1..3] = x, y, z of the point the actor should look at (the middle of the table)
// The pose is applied a moment after spawning, because the spawn sync would undo it.
//
// THE SILENCE TIME IS THE BOARDING. The server seats an actor with PutInVehicleSlot, which works (the log
// has all of them landing in the right seats); what undid it was THIS side: every SendOnFootSyncDataLV is
// a "I am standing here" packet, and at one a second the actor was dragged back out of the car - which is
// both "why is Ken ditched again" and the once-a-second flicker. This side's own EnterVehicle exists
// ([bool] EnterVehicle(vehicleid, seatid), plugin docs, npcscript functions.txt) but it left Ken out of
// the car too, so boarding belongs to the server and this script only has to shut up for it.

pose_sit  <- false;
// Once the server has put this actor into a vehicle, this script must STOP talking. Every
// SendOnFootSyncDataLV() says "I am standing here", and that packet is what pulled the actor back out of
// the seat a moment after the server sat him down: the calls succeeded server side (VehicleSlot read back
// fine) and the actor was still on the pavement in the picture. So the resend is switched off the moment
// the client is told it entered a vehicle.
inCar     <- false;
quietAt   <- -1.0;      // seconds after spawn to stop sending state entirely; negative = never
haveLook  <- false;
look_x    <- 0.0;
look_y    <- 0.0;
look_z    <- 0.0;

function OnNPCScriptLoad( params )
{
    print("sonny_actor: loaded\n");
    // params[0] is the pose, and it can carry a silence time: "stand@14.0" means stand now and, 14
    // seconds after SPAWN, stop sending anything. That time has to be a little BEFORE the server seats
    // him: one on-foot packet arriving after the put-in is enough to drag him back out.
    local p = params[0];
    local at = p.find("@");
    if(at != null){
        quietAt = p.slice(at + 1).tofloat();
        p = p.slice(0, at);
    }
    if(p == "sit") pose_sit = true;
    if(params.len() > 3){
        look_x = params[1].tofloat();
        look_y = params[2].tofloat();
        look_z = params[3].tofloat();
        haveLook = true;
    }
    print("sonny_actor: pose " + (pose_sit ? "sit" : "stand") + " look " + haveLook +
          " quiet at " + quietAt + "\n");
}

function OnNPCConnect( myplayerid )
{
    print("sonny_actor: connected as " + myplayerid + "\n");
}

function OnNPCClassSelect()
{
    RequestSpawn();
}

function OnNPCSpawn()
{
    print("sonny_actor: " + GetMyName() + " spawned, skin " + GetMySkin() + "\n");
    SetTimer("TakePose", 1200, 0);
    // shut up before the server seats him, so nothing of ours can pull him back out
    if(quietAt >= 0.0) SetTimer("Quiet", (quietAt * 1000).tointeger(), 0);
}

// STOP TALKING. From here on this actor sends no packets at all, which is what keeps him in the seat the
// server puts him in (and what stops the once-a-second flicker).
function Quiet()
{
    inCar = true;
    print("sonny_actor: " + GetMyName() + " went quiet (boarding)\n");
}

function TakePose()
{
    if(inCar) return;
    if(haveLook) LookAtPos(Vector(look_x, look_y, look_z));
    KeepPose();
    // the client re-sends its own state now and then, which would put the actor back on its
    // feet and the weapon back in its hands; on the npc side repeat=1 means loop
    SetTimer("KeepPose", 1000, 1);
    print("sonny_actor: " + GetMyName() + " posed\n");
}

function KeepPose()
{
    // KEEPS SENDING even when he is in a vehicle, and that is deliberate: the viewer plays the get-in
    // animation when the ped's state flips from on foot to in vehicle, so a client that keeps reporting is
    // also what shows him climbing in. Suppressing this (the `quiet` path, still supported) stopped the
    // once-a-second flicker but removed the animation with it, and the seat is held either way.
    Fists();
    if(pose_sit) Sit();
}

// fired when he is put in a vehicle, by his own EnterVehicle or by the server: from now on do not send
// on-foot state, or the next packet undoes the seat
function OnNPCEnterVehicle( vehicleid, seatid )
{
    print("sonny_actor: " + GetMyName() + " entered vehicle " + vehicleid + " seat " + seatid + "\n");
}

function OnNPCExitVehicle()
{
    inCar = false;
    print("sonny_actor: " + GetMyName() + " left the vehicle\n");
}

// empty hands: the spawn class hands out a shotgun, which nobody wants at a business meeting
function Fists()
{
    SetLocalValue(I_CURWEP, 0);
    SendOnFootSyncDataLV();
}

// crouch pose, which reads as sitting when the actor stands on a chair
function Sit()
{
    SetLocalValue(I_KEYS, GetLocalValue(I_KEYS) | 288);
    SetLocalValue(B_CROUCHING, true);
    SendOnFootSyncDataLV();
}

function Stand()
{
    SetLocalValue(B_CROUCHING, false);
    local keys = GetLocalValue(I_KEYS);
    SetLocalValue(I_KEYS, keys & (~288));
    SendOnFootSyncDataLV();
}

function OnNPCDisconnect( reason )
{
    print("sonny_actor: disconnected, reason " + reason + "\n");
}
