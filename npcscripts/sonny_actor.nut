// cutscene actor. The server passes parameters:
//   params[0] = "sit" or "stand"
//   params[1..3] = x, y, z of the point the actor should look at (the middle of the table)
// The pose is applied a moment after spawning, because the spawn sync would undo it.

pose_sit  <- false;
haveLook  <- false;
look_x    <- 0.0;
look_y    <- 0.0;
look_z    <- 0.0;

function OnNPCScriptLoad( params )
{
    print("sonny_actor: loaded\n");
    if(params.len() > 0 && params[0] == "sit") pose_sit = true;
    if(params.len() > 3){
        look_x = params[1].tofloat();
        look_y = params[2].tofloat();
        look_z = params[3].tofloat();
        haveLook = true;
    }
    print("sonny_actor: pose " + (pose_sit ? "sit" : "stand") + " look " + haveLook + "\n");
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
}

function TakePose()
{
    if(haveLook) LookAtPos(Vector(look_x, look_y, look_z));
    KeepPose();
    // the client re-sends its own state now and then, which would put the actor back on its
    // feet and the weapon back in its hands; on the npc side repeat=1 means loop
    SetTimer("KeepPose", 1000, 1);
    print("sonny_actor: " + GetMyName() + " posed\n");
}

function KeepPose()
{
    Fists();
    if(pose_sit) Sit();
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
