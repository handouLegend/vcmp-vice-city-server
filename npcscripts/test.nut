// test NPC for this server: the server passes classId, so the class screen appears,
// we ask to spawn, then the npc just stands there and talks.
// runs inside npcclient.exe (see "npcscript functions.txt" for the full API)

function OnNPCScriptLoad( params )
{
    print("test.nut: loaded\n");
}

function OnNPCConnect( myplayerid )
{
    print("test.nut: connected as " + myplayerid + "\n");
}

function OnNPCClassSelect()
{
    print("test.nut: class select\n");
    RequestSpawn();
}

function OnNPCSpawn()
{
    print("test.nut: spawned, skin " + GetMySkin() + "\n");
    SetMyFacingAngle( 1.5 );
    SetTimer( "Say", 3000, 0 );
}

function Say()
{
    SendChat( "test npc is here at " + GetMyPos() );
}

function OnNPCDisconnect( reason )
{
    print("test.nut: disconnected, reason " + reason + "\n");
}
