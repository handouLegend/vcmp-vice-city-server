//
// A passenger's own recording: the three men who climb into the Admiral with Ken replay a
// PASSENGER recording so that their OWN client keeps telling the server it is riding in a car, for the
// whole drive-away. Without it they are seated by the server (PutInVehicleSlot lands, the log says
// "VehicleSlot=1/2/3") and then fall straight back out the moment the car moves.
//
// WHY THE SEAT DID NOT HOLD, AND WHY A RECORDING DOES
// --------------------------------------------------
// An npc's seat and pose are owned by HIS OWN client, not by the server. The old script (sonny_actor.nut)
// kept the men alive by repeatedly calling SendOnFootSyncDataLV() - and that is an on-foot packet from a
// man who is in a car, so the server has no choice but to put him back on the pavement. Suppressing it
// (sonny_actor's "quiet" path) stopped him being dragged out but left the client sending nothing at all,
// so the car simply drove away from a man who thought he was still standing there.
//
// A recording fixes both halves at once, because a replayed passenger frame IS the packet that says "I am
// in seat N of this car", and the client sends one every 100 ms without this script touching the on-foot
// sync call at all. That call is deliberately absent from this file: the only mentions of it below are
// these comments explaining why.
//
// ---------------------------------------------------------------- THE RECORDINGS ARE COUPLED TO THE DRIVER'S
//
// `ken_ride1/2/3.rec` were generated from `ken_drive.rec` and borrow its span, so if that file is ever
// rewritten these three must be regenerated too (three commands, `_docs/PASSENGER-RECORDING.md` section 6).
// A stale pair is not fatal - every frame of a ride file is identical, so a shorter span only means the
// passenger sync stops early - but it is worth knowing.
//
// ---------------------------------------------------------------- WHICH CONSTANT IS "PASSENGER"
//
// There is no PLAYER_RECORDING_TYPE_PASSENGER. The plugin registers exactly three types
// (npcscript functions.txt "Constants"; the same three in include/Utils.h upstream, and in the shipped
// npcclient.exe's own constant table - NPCFunctions.cpp lines 502-504):
//
//     PLAYER_RECORDING_TYPE_ONFOOT = 1
//     PLAYER_RECORDING_TYPE_DRIVER = 2
//     PLAYER_RECORDING_TYPE_ALL    = 3      <-- this is the one a passenger uses
//
// Type 3 is not a guess. ReadAndSendDataBlock (npcclient/client/Playback.cpp) branches three ways: type 1
// reads an ONFOOT_DATABLOCK and sends on-foot sync, type 2 reads an INCAR_DATABLOCK and sends DRIVER sync,
// and type 3 alone goes through SendPacketFromFile(), whose switch is the ONLY place a PACKET_PASSENGER
// frame is ever handled. A type 2 file played by a passenger is rejected outright by the PACKET_DRIVER arm:
//
//     if (npc->m_byteSeatId != 0) { printf("Error. Cannot send drive vehicle in passenger seat\n"); ... }
//
// so PLAYER_RECORDING_TYPE_DRIVER cannot carry a passenger. The files are therefore type 3 and every frame
// in them is PACKET_PASSENGER (9). See `_docs/PASSENGER-RECORDING.md`.
//
// ---------------------------------------------------------------- THE THREE ARGUMENT CALL IS REAL
//
// StartRecordingPlayback( type, "name", flags ) - the third argument exists, it is just undocumented:
// fn_StartRecordingPlayback (NPCFunctions.cpp) registers as variadic ("tis") and does
//
//     SQInteger flags = 0;
//     if (sq_gettop(v) > 3) { if (sq_gettype(v,4) == OT_INTEGER) sq_getinteger(v, 4, &flags);
//                             else return sq_throwerror(v, "Flags parameter must be integer"); }
//     ...
//     mPlayback.dw_Flags = (uint32_t)flags;          // line 112
//
// and BOTH those strings are in the shipped npcclient.exe, so this build honours them. (An earlier note in
// these docs claimed the flags were read and thrown away; that was a misreading - the file's own header u32
// is the one that is read and discarded, the CALL's third argument is what reaches dw_Flags.)
//
// The flags used here are PLAY_IGNORE_SEATID|PLAY_IGNORE_VEHICLEID|PLAY_IGNORE_VEHMODEL = 2|4|8 = 14. They
// matter because a passenger frame is validated against the client's real seat, vehicle and model:
//
//     if (data->SeatId != npc->m_byteSeatId)      { if (!(dw_Flags & PLAY_IGNORE_SEATID))    { ...abort } else data->SeatId    = npc->m_byteSeatId; }
//     if (data->wVehicleID != npc->m_wVehicleId)  { if (!(dw_Flags & PLAY_IGNORE_VEHICLEID))  { ...abort } else data->wVehicleID= npc->m_wVehicleId; }
//     if (data->wModel != GetVehicleModel(...))   { if (!(dw_Flags & PLAY_IGNORE_VEHMODEL))   { ...abort } else data->wModel    = ...; }
//
// The recording's vehicle id is 0 (INVALID_VEHICLE_ID) because the server hands out that id at run time and
// nothing can know it when the file is written, so WITHOUT the flags the very first frame aborts with
// "Error. Vehicle id from rec file different". With them the client substitutes its own values. The seat is
// still written correctly in each file (seat 1 / 2 / 3) as a second line of defence, and the model is 175,
// the Admiral the mission creates.
//
// ---------------------------------------------------------------- WHEN THE PLAYBACK MAY START
//
// The same constraint the driver has, for the same reason (KEN-DRIVE-NOTES.md 3): the PACKET_PASSENGER arm
// checks `if (!npc->m_wVehicleId)` and, because dw_VehicleRequestedTime is only ever set by a recorded
// PACKET_VEHICLE_REQ_ENTER - which these files do not contain - that field is 0, so the check
// `GetTickCount() - 0 > 5000` is true and the playback is DROPPED on its first frame. The client must
// therefore already be in the car when playback starts, which is exactly why playback starts from
// OnNPCEnterVehicle (the plugin's own tutorial and both shipped sample scripts do the same) and never from
// OnNPCClassSelect or OnNPCSpawn.
//
// The playback clock starts when the client ACCEPTS the playback, so starting it at the put is also what
// makes the first "I am in this seat" packet go out immediately and every 100 ms after that.
//
// ---------------------------------------------------------------- THE FALLBACK
//
// If OnNPCEnterVehicle is ever missed, TryRidePlayback from a timer would find the client already in a car
// and start the playback then - but every frame until that moment sent nothing, and the man would have been
// dropped. So a second, cruder mechanism runs behind it: RideKeepAlive() calls SendPassengerSyncData()
// directly, which is a registered client function (NPCFunctions3.cpp) that sends the same passenger packet
// from the client's own state without a recording. That is the safety net, not the mechanism: the recording
// is what gives him a continuous, properly paced passenger stream.
// ---------------------------------------------------------------- THE SHOTGUN
//
// The spawn class hands every actor a shotgun, and the original's passengers are not armed. On an ordinary
// on-foot actor the script clears it itself (`sonny_actor.nut`'s `Fists()` does `SetLocalValue(I_CURWEP, 0)`
// and then sends an on-foot packet, which is what carries "empty hands" to the server). A PASSENGER can do
// neither half of that: the on-foot packet is the thing that pulls him out of the seat, and these scripts
// must not send one (see the top of this file). So the men sit in the Admiral holding the class's shotgun:
// the last thing the server was ever told about their weapon was the spawn-time shotgun, and a PASSENGER
// SYNC CARRIES NO WEAPON FIELD AT ALL - `SendPassengerSyncData()` (UpdateNPC.cpp) writes only the vehicle,
// the health/armour nibbles and the seat. Nothing in the replayed passenger frames can correct it either
// (PASSENGERDATA is `wVehicleID, wModel, health, armour, SeatId`).
//
// Two halves therefore have to be covered by two different agents, and both are needed:
//
//   1. THE SERVER clears it from its own side - `scripts/Main.nut`'s `wep` queue entry (`np.SetWeapon(0,0)`
//      and three fallbacks, queued once a second by `intro.nut` for every man that `wasPutIn`). That is
//      the only side that can change what OTHER players' clients draw, because a script-set weapon is
//      relayed by the server, not by this client. *** Nothing in this file can replace it. ***
//   2. THIS CLIENT stops claiming to hold one, so that whatever it does send next (an in-car sync from a
//      future recording, a state change, a re-spawn) carries 0 instead of 26, and so that the local ped
//      does not keep the weapon in hand.
//
// `SetLocalValue(I_CURWEP, 0)` is the call for half 2 - the same one `sonny_actor.nut` uses - and it is
// safe here because it ONLY writes a value: it sends no packet, it does not touch the playback (a passenger
// frame is rebuilt from the seat/vehicle/health fields, not from the weapon), and it does not stop or
// restart anything. Two things about it are worth knowing, both read out of `fn_SetLocalValue`
// (NPCFunctions3.cpp:498-507):
//
//     byteNewWeapon = 0; byteSlot = GetSlotIdFromWeaponId(0) = 0;
//     if (npc->GetSlotWeapon(0) == 0) npc->SetCurrentWeapon(0); else return 0;   // silently does nothing
//
//    * it only works if slot 0 (the unarmed/melee slot) holds weapon 0, which it does on a fresh spawn -
//      the shotgun lives in slot 6 (weapon 26/27 -> `GetSlotIdFromWeaponId`) - so the clear should take;
//    * when it does NOT take, the call returns silently and the value stays 26. That is why
//      RideClearWeapon() reads the value back with `GetLocalValue(I_CURWEP)` and prints the result: one
//      log line decides it, and there is no game here to look at.
// ---------------------------------------------------------------- REAL IN-GAME RECORDINGS ("real")
//
// There are two kinds of file this script can replay, and they need opposite handling:
//
//   PASSENGER file (`ken_ride1/2/3.rec`). Synthesised here: every frame is PACKET_PASSENGER and says
//   "still in seat N", the file is 28.6 s long, and the SERVER seats the man (`put`). The playback may only
//   start once he is already in the car (the PACKET_PASSENGER arm of Playback.cpp drops it otherwise).
//
//   REAL recording (`tomy.rec`, `gb.rec`). Made by the user with `/rec <name> all` and his own character:
//   type 3, VARIABLE frame lengths (on-foot frames 66 B, the vehicle-enter request 5 B, a vehicle-enter
//   frame 5 B, passenger frames 7 B - see _docs/REAL-RECORDINGS.md and `realrec_dump.js`). It contains his
//   own walk from the terminal to the car AND his own boarding, so:
//
//     * the SERVER MUST NOT SEAT HIM (`put` gone from the cast entry). If it does, the recording's own
//       PACKET_VEHICLE_REQ_ENTER frame aborts the playback:
//       "Error. Cannot send vehicle enter request when inside vehicle" (KEN-DRIVE-NOTES 11.5);
//     * the playback must be accepted while he is ON FOOT, a fixed time after his own spawn (`@real:<ms>`),
//       because the playback's clock starts when the client accepts it and every frame time in the file is
//       relative to that. He must also be SPAWNED by then: the request frame checks IsSpawned();
//     * the enter-request frame names the RECORDING PLAYER'S vehicle id (747) and no flag can override that
//       one (Playback.cpp:437/443/451 - there is no PLAY_IGNORE_VEHICLEID on that path). So the car in the
//       mission has to really be that vehicle. This is the one unavoidable id dependency of a real
//       recording; the driver's synthesised type 3 file does not have it (KEN-DRIVE-NOTES 11.5 risk 2);
//     * when it ENDS it must not be restarted from frame 0 (its first frames are an on-foot walk, and an
//       on-foot packet from a seated man pulls him out of the car). Instead it chains into the man's old
//       passenger file (`@loop:<file>`), which holds the seat for the rest of the act.
//
// The flags are the same 14 as ever (PLAY_IGNORE_SEATID|PLAY_IGNORE_VEHICLEID|PLAY_IGNORE_VEHMODEL). Note
// what they do and do not cover on a real file: the ENTER REQUEST ignores all of them (it asks for the
// file's own vehicle id and seat - Tommy's file asks vehicle 747 seat 3, which matches the cast entry;
// GoonB's asks seat 1, not the 2 the cast table plans - see _docs/REAL-RECORDINGS.md 4), while the
// PASSENGER frames that follow are the ones the flags rescue, exactly as they do for a ride file.
KEEP_ALIVE_MS <- 500;     // how often the fallback checks that he is still riding (and re-starts a dead playback)

// One place for the play-override flags: 2|4|8 = PLAY_IGNORE_SEATID|PLAY_IGNORE_VEHICLEID|PLAY_IGNORE_VEHMODEL
RIDE_FLAGS <- PLAY_IGNORE_SEATID | PLAY_IGNORE_VEHICLEID | PLAY_IGNORE_VEHMODEL;

gRideFile  <- "";         // the PASSENGER recording to replay, or (in real mode) the REAL recording
gRealMs    <- 0;          // > 0 = real-recording mode: accept the playback this many ms after spawn, ON FOOT
gLoopFile  <- "";         // passenger recording to chain into when the real one ends
gRealOn    <- false;      // the real recording has been accepted at least once
gRealEnded <- false;      // the real recording has ended (EOF) or died (abort) - logged once
gRealTick  <- 0;          // GetTickCount() at the moment the real recording was accepted (evidence only)
gRealQuiet <- false;      // the "keep-alive is silent while the real recording runs" line has been printed
gStarted   <- false;      // a playback has been accepted at least once
gReleased  <- false;      // the mission has taken him off the stage; stop everything
gWepReport <- -2;         // the last I_CURWEP value this script reported (-2 = nothing reported yet)

// ------------------------------------------

function OnNPCScriptLoad( params )
{
    // EVERYTHING THIS SCRIPT NEEDS ARRIVES IN THE POSE STRING, as "<pose>[@token]...". The mission builds it
    // from the cast entry (scripts/missions/intro.nut, intro_act_begin) because the pose string is already
    // the channel that carries a script's own first parameter:
    //
    //     cast entry -> pose string -> qActorScript -> ConnectNPCEx's trailing varargs
    //                -> npcclient's -w -> SquirrelVM.cpp call_OnNPCScriptLoad -> params[0] here
    //
    //   @ride:<file>   the recording to replay (passenger file, or the real one in real mode)
    //   @real:<ms>     real-recording mode: start the playback this many ms after this actor spawns, on foot
    //   @loop:<file>   passenger file to chain into when the real recording runs out
    //
    // The tokens are parsed one by one in any order, so a new one cannot break the others (the old code
    // sliced from "@ride:" to the END of the string, which is why a second token has to be handled properly
    // rather than appended blindly). The pose itself ("stand") is deliberately ignored: posing him, or
    // turning his head, means sending on-foot state, and for a passenger that is the packet that pulls him
    // out of his seat.
    local p = (params.len() > 0) ? params[0] : "";
    local s = p;
    local guard = 0;
    while(guard++ < 16){
        local at = s.find("@");
        if(at == null) break;
        s = s.slice(at + 1);
        local nxt = s.find("@");
        local tok = (nxt == null) ? s : s.slice(0, nxt);
        if(tok.find("ride:") == 0)       gRideFile = tok.slice(5);
        else if(tok.find("real:") == 0)  gRealMs   = tok.slice(5).tointeger();
        else if(tok.find("loop:") == 0)  gLoopFile = tok.slice(5);
        if(nxt == null) break;
        s = s.slice(nxt);
    }
    // A bare first parameter that is not a pose is also accepted, so the file can be named directly.
    if(gRideFile == "" && p.find("@") == null && p != "stand" && p != "sit") gRideFile = p;
    print("passenger_ride: loaded, pose string \"" + p + "\", recording \"" + gRideFile + "\""
        + (gRealMs > 0 ? ("  REAL mode, start +" + gRealMs + " ms after spawn, then loop \"" + gLoopFile + "\"")
                       : "  passenger mode (the server seats him)")
        + (gRideFile == "" ? "  *** EMPTY: the cast entry needs ride = \"ken_rideN\" ***" : "") + "\n");
}

// ------------------------------------------

// Empty hands on the CLIENT side. Called at spawn, at the put and from the 500 ms timer (the timer is what
// re-clears it if the server ever hands it back). See "THE SHOTGUN" at the top for why this is only half of
// the fix, and why it is safe to call from inside a running playback.
//
// It sends NOTHING: `SetLocalValue(I_CURWEP, 0)` only writes `npc->m_byteWeapon` (NPCFunctions3.cpp:498).
// In particular it does NOT call SendOnFootSyncDataLV(), which is the packet that would drag him out of the
// seat, and it does not touch the playback. The value is read back because `fn_SetLocalValue` fails
// SILENTLY when the slot that should hold weapon 0 is not empty - one log line then says which happened.
function RideClearWeapon( where )
{
    local before = -1;
    try { before = GetLocalValue(I_CURWEP); } catch(e) { before = -1; }
    if(before != 0){
        try { SetLocalValue(I_CURWEP, 0); }
        catch(e) {
            print("passenger_ride: clearing the weapon threw: " + e + " (" + where + ")\n");
            return false;
        }
    }
    local after = -1;
    try { after = GetLocalValue(I_CURWEP); } catch(e) { after = -1; }
    // One line per CHANGE of the value, so a 500 ms timer cannot flood the log.
    if(after != gWepReport){
        gWepReport = after;
        if(after == 0)
            print("passenger_ride: weapon cleared client-side, I_CURWEP " + before + " -> 0 (" + where + ")\n");
        else
            print("passenger_ride: weapon NOT cleared - I_CURWEP is still " + after
                + " after SetLocalValue(I_CURWEP, 0) (" + where + "). The client took no action (the slot "
                + "holding weapon 0 is not empty); the SERVER side has to empty it (Main.nut's wep queue)\n");
    }
    return after == 0;
}

// ------------------------------------------

function OnNPCConnect( myplayerid )
{
    print("passenger_ride: connected as " + myplayerid + "\n");
}

// ------------------------------------------

function OnNPCClassSelect()
{
    print("passenger_ride: class select, my class " + GetMyClass() + "\n");
    // NO playback start here, on purpose - see the note above: on foot it would be dropped on frame 1.
    RequestSpawn();
}

// ------------------------------------------

function OnNPCSpawn()
{
    print("passenger_ride: " + GetMyName() + " spawned, skin " + GetMySkin() + ", class " + GetMyClass()
        + ", veh " + GetPlayerVehicleID(GetMyID()) + ", playing " + IsPlaybackRunning() + "\n");
    // The server's put can land before or after the spawn; OnNPCEnterVehicle is the trigger either way,
    // and the timer covers the case where that event is missed. The timer is repeat=1, i.e. it keeps going.
    RideClearWeapon("spawn");
    SetTimer("RideKeepAlive", KEEP_ALIVE_MS, 1);
    if(gRealMs > 0){
        // REAL-RECORDING MODE. The clock to count is this moment (the client has no act clock), and the
        // playback has to be accepted while he is still ON FOOT: the file's first 8-9 s are his walk and
        // its PACKET_VEHICLE_REQ_ENTER frame is what gets him into the car. No `put` is queued for him, so
        // nothing else will move him. repeat=0 -> fires once, unlike the keep-alive above.
        print("passenger_ride: REAL recording \"" + gRideFile + "\" will start in " + gRealMs
            + " ms, on foot (the file walks him to the car and boards him)"
            + (gLoopFile == "" ? "" : "; then chaining into passenger file \"" + gLoopFile + "\"") + "\n");
        SetTimer("RideRealStart", gRealMs, 0);
        return;
    }
    TryRidePlayback("spawn");
}

// ------------------------------------------

// The real recording's start. It is deliberately NOT TryRidePlayback: that one refuses to start while the man
// is on foot, and for a real file being on foot is exactly the requirement (its first frames move him).
function RideRealStart()
{
    if(gReleased || gRealOn) return;
    if(gRideFile == ""){
        print("passenger_ride: RideRealStart: NO recording name (no @ride: token in the pose string)\n");
        return;
    }
    local veh = 0;
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) { veh = 0; }
    if(veh != 0){
        // The file's PACKET_VEHICLE_REQ_ENTER arm aborts when the man is already inside a vehicle, so a real
        // recording can never be played from a seat. If this line appears, the cast entry still has a `put`
        // (or something else seated him) and the test is mis-wired - no playback was started.
        print("passenger_ride: RideRealStart: ALREADY IN VEHICLE " + veh + " - a real recording cannot be "
            + "played from a seat (its enter frame would abort). Remove `put` from the cast entry.\n");
        return;
    }
    if(StartRideFile(gRideFile, "RideRealStart (on foot)")){
        gRealOn = true;
        gRealTick = GetTickCount();     // evidence only: the entry line below prints the delta from here
    }
}

// ------------------------------------------

// The one place a playback is actually accepted. `name` is either the real recording or a passenger file;
// every call uses the same type (3) and the same override flags (RIDE_FLAGS), which is what makes them
// interchangeable at run time.
function StartRideFile( name, where )
{
    local veh = 0;
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) { veh = 0; }
    local ok = false;
    try {
        ok = StartRecordingPlayback(PLAYER_RECORDING_TYPE_ALL, name, RIDE_FLAGS);
    }
    catch(e) {
        print("passenger_ride: StartRecordingPlayback(\"" + name + "\") threw: " + e + " (" + where + ")\n");
        return false;
    }
    if(ok == false || ok == null){
        print("passenger_ride: StartRecordingPlayback returned " + ok + " for \"" + name + "\" (" + where + ")\n");
        return false;
    }
    gStarted = true;
    print("passenger_ride: playback STARTED at " + where + ", file \"" + name + "\", type 3, flags "
        + RIDE_FLAGS + ", veh " + veh + ", state " + GetPlayerState(GetMyID()) + ", tick " + GetTickCount() + "\n");
    return true;
}

// ------------------------------------------

// The only place a PASSENGER playback is ever started, and `gStarted` makes the first success final: a
// second start resets the file to its first frame, which for a stream of identical frames is harmless but
// pointless. In real-recording mode the real file is started by RideRealStart instead (on foot, on its own
// clock); what is left here is starting the passenger file it chains into, and reporting the cases that mean
// the wiring is wrong.
function TryRidePlayback( where )
{
    if(gReleased) return false;
    if(gStarted)  return true;

    local veh = 0, seat = 0;
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) {}

    if(gRealMs > 0){
        // REAL-RECORDING MODE.
        if(!gRealOn){
            // Not started yet: the man is on foot and RideRealStart owns this phase. Starting anything here
            // would be wrong twice over - a passenger file played on foot is dropped on its first frame, and
            // the real file must not be played from a seat.
            print("passenger_ride: real recording has not started yet (" + where + "), veh " + veh
                + " - nothing started here\n");
            return false;
        }
        if(veh == 0){
            print("passenger_ride: not in a car yet (" + where + "), playback NOT started\n");
            return false;
        }
        // In a car and nothing running: the real recording ended (OnRecordingPlaybackEnd clears gStarted)
        // or was aborted. Either way the passenger file is what holds the seat from here.
        if(gLoopFile != "")
            return StartRideFile(gLoopFile, where + " [passenger fallback after the real recording]");
        print("passenger_ride: real recording is over and no @loop: passenger file was named (" + where + ")\n");
        return false;
    }

    if(veh == 0){
        // Never start it here: a passenger playback accepted while on foot is dropped on its first frame.
        // RideKeepAlive() below is what keeps him seated until the put arrives.
        print("passenger_ride: not in a car yet (" + where + "), playback NOT started\n");
        return false;
    }
    local running = false;
    try { running = IsPlaybackRunning(); } catch(e) {}
    if(running){
        gStarted = true;
        print("passenger_ride: playback already running (" + where + "), clock left alone\n");
        return true;
    }

    // The recording name comes from the pose string's "@ride:" token; there is no convention to fall back
    // on, because guessing a file name would fail silently at run time.
    local name = RideName();
    if(name == ""){
        print("passenger_ride: NO recording name was passed (no @ride: in the pose string) - " + where + "\n");
        return false;
    }
    // PLAYER_RECORDING_TYPE_ALL (3), the file's own name, and the play-override flags (RIDE_FLAGS at the top).
    return StartRideFile(name, where);
}

// ------------------------------------------

// Which recording belongs to this man. It is the "@ride:" token of the pose string the cast table built;
// the file name lives in ONE place (intro_airport_cast's `ride` field) so that the seat and the file can
// never drift apart.
function RideName()
{
    return gRideFile;
}

// ------------------------------------------

// Fired by the server's put-in (ID_GAME_MESSAGE_VEHICLE_ENTER). This is the moment the car becomes his and
// the moment a passenger playback may legally start.
function OnNPCEnterVehicle( vehicleid, seatid )
{
    // The delta is the evidence that the recording's own PACKET_VEHICLE_REQ_ENTER frame is what seated
    // him, and WHEN: it has to land on the file's own REQ_ENTER time (+8062 ms for tomy, +9547 ga,
    // +10500 gb), because everything the recording does is timed from its first frame. The next 2.06-2.08 s
    // of the file are silent ON PURPOSE - that silence IS the get-in animation (the same silence the human
    // client produced when he recorded it), so anything this script sends inside it cuts the animation.
    print("passenger_ride: " + GetMyName() + " in vehicle " + vehicleid + " seat " + seatid
        + (gRealTick != 0 ? ("  [" + (GetTickCount() - gRealTick) + " ms into the real recording \""
                             + gRideFile + "\"]") : "") + "\n");
    // Before the playback starts, exactly like the driver does (ken_driver.nut's OnNPCEnterVehicle ->
    // NoWeapon() -> TryDrivePlayback). Clearing a local value cannot disturb the playback that is about to
    // begin, and doing it here means the FIRST passenger frame is already sent by a man with empty hands.
    RideClearWeapon("OnNPCEnterVehicle");
    TryRidePlayback("OnNPCEnterVehicle");
}

// ------------------------------------------

function OnNPCExitVehicle()
{
    // In real-recording mode an exit after the boarding means the seat did not hold: the recording cannot
    // put him back (its enter-request frame is long past and re-playing it would walk him out of the car),
    // so this is a failure line, not a normal event. The client's own reason (if any) is above it.
    if(gRealMs > 0 && gRealOn)
        print("passenger_ride: *** " + GetMyName() + " was pulled OUT of the vehicle while a real recording "
            + "was running - the seat did not hold, see _docs/REAL-RECORDINGS.md 5\n");
    print("passenger_ride: " + GetMyName() + " out of the vehicle, playback stopped\n");
    gStarted = false;
    try { StopRecordingPlayback(); } catch(e) {}
}

// ------------------------------------------

// The file's frames are identical, so reaching the end simply means "keep going"; the mission ends the act
// long before this matters. Restarting without clearing gStarted would be pointless, so this is the one
// place that start-and-restart is allowed.
//
// A REAL recording is the one file that must NEVER be restarted from frame 0: its first frames are an
// ON-FOOT walk (an on-foot packet from a seated man pulls him straight back out of the car - see
// _docs/PASSENGER-RECORDING.md 5) and its PACKET_VEHICLE_REQ_ENTER frame would abort from inside the car.
// So the real pass hands over to the passenger file named by @loop: instead, which is the old, proven way
// of holding the seat for the rest of the act (the car does not leave until 23.9 s).
function OnRecordingPlaybackEnd()
{
    if(gReleased || !gStarted) return;
    if(gRealOn && !gRealEnded){
        print("passenger_ride: REAL recording \"" + gRideFile + "\" played to the end for " + GetMyName()
            + " - NOT restarting it (its first frames are an on-foot walk)\n");
        gRealEnded = true;
        gStarted = false;
        TryRidePlayback("OnRecordingPlaybackEnd [after the real recording]");
        return;
    }
    print("passenger_ride: recording ended, restarting for " + GetMyName() + "\n");
    gStarted = false;
    TryRidePlayback("OnRecordingPlaybackEnd");
}

// ------------------------------------------

// The fallback and the health check. If the playback died (the client aborts it if any frame fails a
// check), the man is left sending nothing and the car drives out from under him; this puts him back on the
// air. SendPassengerSyncData() is a registered client function and sends the same packet the recording
// sends, straight from the client's own seat and vehicle.
function RideKeepAlive()
{
    if(gReleased) return;
    local veh = 0;
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) {}
    local running = false;
    try { running = IsPlaybackRunning(); } catch(e) {}
    if(gRealMs > 0 && !gRealOn){
        // REAL-RECORDING MODE, before the scheduled start: he is on foot (that is the point) and
        // RideRealStart owns this phase. Send nothing and leave the clock alone.
        return;
    }
    if(gRealOn && !running && !gRealEnded){
        // The real recording is gone but OnRecordingPlaybackEnd never ran: that is the ABORT path (the
        // client aborts a playback on a failed frame check and only reports the end normally at EOF). The
        // client's own "Error. ..." line is printed right above this one and is the actual reason.
        gRealEnded = true;
        gStarted = false;
        print("passenger_ride: REAL recording is no longer running (veh " + veh + ") - it was aborted; "
            + "see the Error line above and _docs/REAL-RECORDINGS.md for what each one means\n");
    }
    // ---------------------------------------------------------------- THE GET-IN ANIMATION
    //
    // While the REAL recording is still running, THIS SCRIPT SENDS NOTHING OF ITS OWN. That is the fix for
    // "he is pulled into the seat half way through getting in". Everything below - the passenger sync and
    // the weapon re-clear - is a packet about a man who is already seated, and one of them landing inside
    // the get-in animation is what ended that animation: the seat assignment starts the animation on the
    // game clients, a passenger sync ("I am in seat N of vehicle V") ends it and puts him in the seat.
    //
    // Why this is certain enough to act on:
    //   * the recording itself is silent for exactly that window - 2.06-2.08 s between its REQ_ENTER frame
    //     and its first passenger frame (+8062 -> +10140 for tomy, +9547 -> +11625 ga, +10500 -> +12563 gb)
    //     - and that is the same silence the user's own client produced while he was recording it, i.e. it
    //     IS the animation, and his seat held through it;
    //   * the two logs that bracket the window prove the file's timeline is played faithfully: the real
    //     start and the loop start are 11484-11625/13016 ms apart plus one poll (see the 05-25-38 logs);
    //   * so the only packets that can arrive inside the window are these timer ones, and the first of them
    //     is at most 500 ms after the seat landed - which is what "cut in half" looks like.
    //
    // The recording is the only writer in this phase, and it stops being one exactly when it ends; from
    // there the @loop: passenger file (and this fallback) take over again. Note this is INDEPENDENT of when
    // the walk starts: moving the cast's `real` by 3 s (see intro.nut) does not change this window.
    if(gRealMs > 0 && gRealOn && !gRealEnded){
        if(!gRealQuiet){
            gRealQuiet = true;
            print("passenger_ride: real recording is in charge - the keep-alive sends NOTHING (no passenger "
                + "sync) until it ends, so nothing can cut the get-in animation\n");
        }
        return;
    }
    if(veh == 0) return;                     // not seated yet: nothing to do, and nothing safe to send
    if(!running){
        print("passenger_ride: playback is not running while in vehicle " + veh + ", trying again\n");
        gStarted = false;
        if(!TryRidePlayback("RideKeepAlive")) return;
    }
    // Keep the server's idea of the seat fresh even if the recording had to be restarted late.
    try { SendPassengerSyncData(); } catch(e) { print("passenger_ride: SendPassengerSyncData failed: " + e + "\n"); }
    // And keep the hands empty. This is a local value write (no packet, see RideClearWeapon) so it cannot
    // restart the playback or unseat him; it only prints when the value changes.
    RideClearWeapon("keepalive");
}

// ------------------------------------------

// Called by the mission when the act tears the car down. From here this man sends nothing at all, which is
// what lets the server remove him cleanly.
function RideRelease()
{
    gReleased = true;
    gStarted  = false;
    try { StopRecordingPlayback(); } catch(e) {}
    print("passenger_ride: released, playback stopped\n");
}

// ------------------------------------------

function OnNPCDisconnect( reason )
{
    print("passenger_ride: disconnected, reason " + reason + "\n");
}
