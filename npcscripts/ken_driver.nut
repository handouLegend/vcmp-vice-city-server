//
// Ken at the wheel: a recording replay that includes his OWN get-in, not a seated extra.
// Part of the INT_M ("An Old Friend") cutscene recreation: he stands at the driver's door, gets in and drives
// the Admiral away from the kerb. THE RECORDING IN USE IS npcscripts/recordings/ken2.rec - a REAL in-game
// recording the user made with his own character (`/rec ken2 all`), played as type 3 with the override flags.
// Everything about it is in "==== THE REAL-RECORDING MODE" below. The synthesised route
// (npcscripts/recordings/ken_drive_t3.rec, rebuilt from ken_drive.rec - see "WHICH RECORDING, AND WHY IT IS
// PLAYED AS TYPE 3") is still in the file and is the ONE-LINE fallback: KEN_REAL_REC <- false.
//
// WHY A RECORDING AND NOT A SEAT. The server can put a ped into a seat, but the POSE of an occupant is
// owned by his own npc client: a server-seated man is drawn standing on the car, the client's own
// periodic state report drags him back out, and a car pushed around from the server leaves its wheels
// floating behind - and, with a real recording, the server's put is also what ABORTS the recording's own
// enter-request frame. An npc that replays a recording is really driving: his pose is the seated one,
// the wheels turn, the speed comes from the recording, and no server state fights him.
//
// ---------------------------------------------------------------- WHEN THE PLAYBACK CLOCK STARTS
//
// This is the one fact that decides where StartRecordingPlayback may be called, and it is no longer a
// guess: it was read out of the source the shipped npcclient.exe was built from (github.com/habi498/
// NPC-VCMP - npcclient.exe carries that project's own .pdb path).
//
//   fn_StartRecordingPlayback (npcclient/client/NPCFunctions.cpp)
//       mPlayback.prevtick = <the first record's own timestamp>;   // read straight from the file
//       mPlayback.running  = true;
//   ProcessPlaybacks -> ReadAndSendDataBlock (npcclient/client/Playback.cpp) then walks the file's own
//   tick deltas forward from GetTickCount() AT THAT MOMENT (one frame per delta; the file is at 1/30 s, so
//   30 driver syncs a second). So:
//
//       *** a DRIVER playback's clock starts the instant the client ACCEPTS the playback ***
//
//   ...and the file's timeline means "time since the playback was accepted", not "time since the npc was
//   put in the car". Nothing waits for the car and nothing re-anchors the clock when it arrives.
//
// That has two consequences, and both are why this script looks the way it does:
//
//  1. STARTING IT BEFORE HE IS IN THE CAR BURNS THE RECORDING'S HEAD IN REAL TIME. The first packet of
//     ken_drive.rec is due on the very first cycle after the accept; if he is not in a vehicle by then,
//     Playback.cpp's PACKET_DRIVER arm sends nothing and treats the situation as a failure: it checks
//     `GetTickCount() - dw_VehicleRequestedTime > 5000` and, when that field is still 0 - which it is for
//     a file like ours, because only a recorded PACKET_VEHICLE_REQ_ENTER ever sets it - it prints
//     "Error. Vehicle not acquired by npc" and DROPS THE PLAYBACK. A pure DRIVER file has no such packet,
//     so a playback accepted while he is still on foot dies on its first frame.
//     The author's one-liner in the Changelog can start at class select because it plays
//     PLAYER_RECORDING_TYPE_ALL - a whole-session recording that carries its own vehicle-enter packet and
//     therefore legitimately waits up to 5 s. A pure DRIVER file cannot.
//
//  2. SO PLAYBACK IS STARTED WHEN THE CAR IS ACTUALLY HIS, and the recording's head is exactly the
//     padding between that moment and the drive-away. The mission seats him at act 3.0 s and the file
//     was written with a 20.9 s head, so the car pulls away at act 3.0 + 20.9 = 23.9 s, the original's
//     own first moving frame (_docs/KEN-DRIVE-RECORDING.md 1).
//
// KEN_CLASS_SELECT_START below puts the author's documented "start at class select" shape back as a ONE
// LINE switch, for the case where a log proves this client does survive an early accept. It is off
// because the source above says the first driver frame would abort the playback, and because an early
// accept would also start the clock ~2.7 s too soon and pull the car away early.
//
// ---------------------------------------------------------------- HOW IT STARTS, AND WHY TWICE
//
// The plugin's own tutorial ("[Tutorial:NPC] #3 Recording vehicle drivings", forum.vc-mp.org) puts a
// vehicle playback in OnNPCEnterVehicle, and both shipped sample scripts do the same (car_test.nut,
// taxi_SI_test.nut). The client fires that event on the ID_GAME_MESSAGE_VEHICLE_ENTER packet the plugin
// sends when the server puts the npc in a car - exactly the moment the car becomes his.
//
// The server's put is what makes it work, and it is the mission's job (intro.nut, `put = 3.0`). No call
// of EnterVehicle() is made here on purpose: when this script asked the client to enter a car itself it
// ended up standing on the pavement instead (see intro.nut's notes), and the server's put is already
// confirmed working for the other three actors in the same car.
//
// OnNPCEnterVehicle is the primary trigger. A slow timer is armed behind it only so that the log always
// says what happened even if that event is ever missed: it reports, and starts the playback itself if he
// is in a car and nothing is running. Both paths go through TryDrivePlayback, whose ONE-SHOT flag is
// what keeps the clock from ever being restarted - a second start resets the file to its first frame and
// the car would leave 20.9 s too late.
//
// THE WEAPON. The actor class spawns holding a shotgun and the original's driver does not. Clearing the
// client's own current-weapon value is enough, and it must NOT be followed by SendOnFootSyncDataLV():
// that is an on-foot packet, and an on-foot packet arriving from a man who is in a car is exactly what
// drags an occupant out of his seat. The recording's own weapon field is 0 too, so the in-car sync he
// sends while driving carries empty hands to the server as well. The server clears it from its own side
// too (Main.nut, the "wep" queue entry), and that matters: an actor who has been put in a car stops
// sending anything and may never reach this code.
//
// How the recording was built: _docs/KEN-DRIVE-NOTES.md 11-12 (tools in _docs/_extract/: ken_route33.js,
// rec_write.js, rec_keys.js, rec_t3driver.js, ken_cadence_check.js). The older 100 ms route/tools
// (ken_route.js, ken_trim_verify.js) are kept for comparison only.

// ------------------------------------------

// The author's documented "start the playback in OnNPCClassSelect" shape. SEE THE NOTE ABOVE: off by
// default. Switch it on ONLY if a run's log shows a class-select start surviving the drive-away (a "playback
// STARTED at class select" line with NO "Vehicle not acquired by npc" line after it). If you do switch it
// on, the recording's head must be LONGER, because the clock then starts at SPAWN (act ~0.3) instead of at
// the put (act 3.0) - the car moves at (acceptance + head), so the head has to grow by the same ~2.7 s:
// 23.6 s instead of 20.9 s. With the 20.9 s head the car would leave at act 21.2.
//   The route now lives in _docs/_extract/ken_route33.js, and everything except the length of the parked
//   head is derived there. For this switch, add `--first-move 23600` (23.6 s = 708 x 1/30 s) to the first
//   command; the tool prints the exact rec_keys --seg value to use (23567 with that head):
//     node _docs/_extract/ken_route33.js --first-move 23600
//     node _docs/_extract/rec_write.js --txt _docs/_extract/out/ken_drive_waypoints33.txt  <line continues>
//          --out npcscripts/recordings/ken_drive.rec --type driver --version 1005 --flags 14  <line continues>
//          --dt exact --keys 0 --veh 0 --base 0
//     node _docs/_extract/rec_keys.js npcscripts/recordings/ken_drive.rec --seg 0:0 --seg 23567:0x400
//   AND THEN REBUILD THE FILE THIS SCRIPT ACTUALLY PLAYS (the route lives in a type 2 master and is played
//   from a type 3 repack, so changing one without the other does nothing), and re-check the cadence:
//     node _docs/_extract/rec_t3driver.js make npcscripts/recordings/ken_drive.rec  <line continues>
//          npcscripts/recordings/ken_drive_t3.rec
//     node _docs/_extract/rec_t3driver.js verify npcscripts/recordings/ken_drive_t3.rec
//     node _docs/_extract/ken_cadence_check.js _docs/_extract/out/ken_drive_100ms_286f.rec  <line continues>
//          npcscripts/recordings/ken_drive.rec
//   (After an experiment like this, re-run ken_route33.js with NO --first-move to put the waypoints file
//    back to the 20900 ms default before regenerating anything else.)
KEN_CLASS_SELECT_START <- false;

// ------------------------------------------ WHICH RECORDING, AND WHY IT IS PLAYED AS TYPE 3
//
// The file used here is npcscripts/recordings/ken_drive_t3.rec: the route of ken_drive.rec (the car still
// first moves 20.9 s after the playback is accepted), REPACKED from a TYPE 2 (DRIVER) file into a TYPE 3
// (ALL) file whose every frame is PACKET_DRIVER - and, since the judder fix, carrying a frame every
// 1/30 s instead of every 100 ms (858 frames / 28.567 s; see "THE CADENCE" below).
//
// WHY THE REPACK - it is the reason the car would not move. A TYPE 2 file is read by ReadAndSendDataBlock's
// DRIVER branch (npcclient/client/Playback.cpp:90-102), which does this and NOTHING else:
//
//     INCAR_DATABLOCK m_pIcDatablock;
//     fread(&m_pIcDatablock, sizeof(m_pIcDatablock), 1, pFile);
//     #ifdef PLAYBACK_OVERRIDE_VEHICLEID
//         m_pIcDatablock.m_pIcSyncData.VehicleID = npc->m_wVehicleId;
//     #endif
//     SendNPCSyncData(&m_pIcDatablock.m_pIcSyncData);
//
// There is no validation on that path at all, and mPlayback.dw_Flags is never looked at - so the third
// argument of StartRecordingPlayback did nothing for ken_drive.rec, and the vehicle id that reached the
// server was the one STORED IN THE FILE (the u16 at offset 4 of every 71 byte record). A synthesised file
// cannot know the server's runtime vehicle id - it is 747 on a fresh server, but any vehicle created
// before this one shifts it - so that field was 0 (INVALID_VEHICLE_ID) and the plugin received "driver
// sync for vehicle 0" once every 100 ms. That is a live playback driving a car that does not exist: the
// npc sits in the right seat, IsPlaybackRunning() stays true, and nothing moves. (The author's own
// samples do the opposite - car7060.rec carries id 114 in all 296 records, taxi_test_1300.rec carries 74
// in all 832 - i.e. a DRIVER recording is expected to name its car. None of them is synthesised.)
//
// A TYPE 3 file takes the other branch of the same function (Playback.cpp:103-115), so every frame goes
// through SendPacketFromFile, whose PACKET_DRIVER arm (Playback.cpp:560-598) DOES consult those flags:
//
//     if (data->VehicleID != npc->m_wVehicleId) {
//         if (!(mPlayback.dw_Flags & PLAY_IGNORE_VEHICLEID)) { printf("Error. Vehicle id from rec file
//             different. See flags for overriding\n"); free(buffer); return 0; }
//         else data->VehicleID = npc->m_wVehicleId;//needed        <- the author's own comment
//     }
//
// With PLAY_IGNORE_VEHICLEID the CLIENT substitutes the REAL car id at playback time, so the file needs no
// id, nothing is hardcoded, and the same file works on a server where the car got a different slot. This
// is exactly the mechanism the three passenger recordings already rely on (Playback.cpp:528-539), and
// nothing about the route or the timing changes: the payload of each frame is byte-identical to the type 2
// record's, and only the container differs. Checked offline with
//     node _docs/_extract/rec_t3driver.js verify npcscripts/recordings/ken_drive_t3.rec
// (same file drives vehicle 1 / 12 / 747 / 1023; with the vehicle-id flag cleared it aborts).
//
// ------------------------------------------ THE CADENCE (why the file is 858 frames and not 286)
//
// The first version of this recording was sampled on a 100 ms grid, so the client sent one driver sync per
// 100 ms and the car was moved in 10 visible steps per second while the game draws 30 - the "一卡一卡" the
// user saw. The client's playback loop sends exactly ONE frame per file frame and then waits
// `nexttick - prevtick` (Playback.cpp:69-137), so the file's own cadence IS the sync rate. Both the type 2
// master and this repack are therefore 1/30 s (33/34 ms) - 858 frames, 28.567 s, and the parked head is
// sampled at 30 fps as well, because a two-frame head would have gone silent for 20.9 s while the car
// waited in its seat. The car is moved 0.17 m per sync instead of 0.53 m, and the first moving frame is
// still file time 20900 ms = act 23.9 s (the arithmetic above is untouched by the cadence).
// Built from the cutscene's own 30 fps track (_docs/_extract/out/int_m_merced_track.csv), so the drive
// frames are original frames rather than interpolations - see _docs/_extract/ken_route33.js.
// Verified offline with:
//     node _docs/_extract/ken_cadence_check.js _docs/_extract/out/ken_drive_100ms_286f.rec  <line continues>
//          npcscripts/recordings/ken_drive.rec
//
// ken_drive.rec stays type 2 even though nothing plays it directly: _docs/_extract/gen_ride.js reads the
// passenger recordings' span out of it, so it is kept as the master. If it is ever rebuilt, re-run
// `rec_t3driver.js make` to rebuild this one AND re-run the three gen_ride.js commands (the recipes are in
// _docs/KEN-DRIVE-NOTES.md 11 and 12).
KEN_REC_TYPE  <- PLAYER_RECORDING_TYPE_ALL;      // 3 - a DRIVER (type 2) file cannot carry these flags
KEN_REC_FILE  <- "ken_drive_t3";
KEN_REC_FLAGS <- PLAY_IGNORE_SEATID | PLAY_IGNORE_VEHMODEL | PLAY_IGNORE_VEHICLEID;   // 2|4|8 = 14

// ==== THE REAL-RECORDING MODE: ON. This is what the mission uses now. ==================================
//
// The user recorded Ken himself in game (`/rec ken2 all`, the recipe in _docs/KEN-DRIVE-NOTES.md 11.5): he
// stood outside, turned to the driver's door, got in, waited, and drove west. That file -
// npcscripts/recordings/ken2.rec - replaces the synthesised route completely, and it is the ONE thing this
// script needed that no synthesised file could ever have: HIS OWN GET-IN ANIMATION. The server could seat
// him, but a server-seated man is drawn standing on the car; only a recording of a man really getting in
// shows him getting in. A previous, shorter take (`recordings\ken.rec`, 88 frames / 11.531 s) is kept in the
// server's own `recordings\` folder but is NOT used: the longer one drives for 7.5 s instead of 5.8 s.
//
// WHAT IS IN THE FILE (offline parse, `node _docs/_extract/realrec_dump.js recordings\ken2.rec`; the full
// numbers are in _docs/REAL-RECORDINGS.md 11):
//     7802 B, header 1005 / type 3 (ALL) / flags 0, 110 frames, span 13 969 ms, parsed to EOF exactly
//       PACKET_ONFOOT      x6    +0 .. +625 ms   (141/109/141/109/125 ms apart; he turns to the door -
//                                                 angle 0.0423 -> -1.7619 - and moves all of 0.28 m)
//       PACKET_VEHICLE_REQ_ENTER x1  +672 ms     veh 747, model 175 (Admiral), seat 0
//       PACKET_VEHICLE_ENTER     x1  +2781 ms    veh 747, seat 0   <- his own 2.109 s get-in sits between
//                                                 those two, exactly like the three passengers' files
//       PACKET_DRIVER     x102   +2781 .. +13969 ms, veh 747 everywhere, 84 moving frames
//       PACKET_VEHICLE_EXIT  ABSENT   <- he does NOT get thrown out at the end of playback
//       PACKET_SPAWN / CHOOSECLASS / DISCONNECT  ABSENT   <- nothing in it can abort a spawned npc
//     the car first moves at file +6469 ms (that very frame carries the throttle key 0x400) and is still
//     being driven at the last frame: 83.79 m of straight westward travel (position -1591.560 -> -1675.562),
//     7.500 s of driving at ~11.2 m/s = 40 km/h, sampled at ~11 Hz (78/94/203/62 ms deltas).
//
// SO THE SERVER MUST NOT SEAT HIM: scripts/missions/intro.nut's Ken cast entry has `real = 14219` and NO
// `put` (the same change the three passengers got). With a `put`, the file's +672 ms enter-request frame
// would hit "Error. Cannot send vehicle enter request when inside vehicle" and abort the whole playback.
//
// THE START TIME is `real = 14219` ms after HIS OWN SPAWN (the npc client has no act clock; the mission
// counts from the act, the client counts from spawn, and the ~1 s difference is the spawn lag the cast
// table documents). Its arithmetic, all of it derived with
//     node _docs/_extract/realrec_plan.js recordings\ken2.rec 20.30 --start-at 15.219 --lag 1.0 --move-ms 6469
//     playback accepted  act 15.219   file     0 ms   he stands at his door
//     enter request      act 15.891   file   672 ms   veh 747, seat 0
//     in the car         act 18.000   file  2781 ms   <- the user's target: after Tommy (17.49)
//     drive-away         act 21.688   file  6469 ms   the first moving frame carries the throttle
//     recording ends     act 29.188   file 13969 ms   still driving, 83.8 m west
// The gap he asked about - "how long after he sits down does the car start moving" - is 3.688 s (file
// 2781 -> 6469 ms), and 2.109 s of that is the get-in animation itself. It is a property of the recording
// and no server-side number can shorten it; the earlier take had the same 3.69 s gap.
// Choosing 21.69 s instead of the original's 23.9 s is deliberate (act 18.0 was what the user asked for);
// the ONE number to change is `real` in the cast entry (+1000 = 1 s later), and its comment lists 12219 /
// 15219 / 16419 for drive-aways at 19.69 / 22.69 / 23.89.
//
// WHAT THE FLAGS HAVE TO DO - and what they CANNOT do. The recording carries vehicle id 747 in EVERY frame,
// which is the id the car had when he recorded it (the server's first dynamic vehicle; measured
// `Loaded vehicles: speeded=746` -> 747 - see _docs/REAL-RECORDINGS.md 4.1). On replay:
//   * the enter-request frame (PACKET_VEHICLE_REQ_ENTER) is checked in Playback.cpp:437/443/451 against
//     IsVehicleStreamedIn(data->wVehicleID) and the model; there is NO flag on that path at all
//     (_docs/KEN-DRIVE-NOTES.md 11.5 risk 2). So he can only board vehicle 747 while that car is streamed
//     in, whatever this script passes. Nothing here can change that - it is a property of the file, and
//     hardcoding was explicitly rejected (a real recording cannot be id-independent; only a synthesised
//     file can, which is exactly why the synthetic route exists as the fallback below).
//   * the DRIVER frames are a different path (Playback.cpp:560-598) and that one DOES consult the flags:
//     a frame whose VehicleID differs from the npc's real car aborts the playback with "Error. Vehicle id
//     from rec file different. See flags for overriding" UNLESS PLAY_IGNORE_VEHICLEID is set, in which case
//     the client writes the REAL car id into the frame ("//needed" - the author's own comment).
//   * so PLAY_IGNORE_VEHICLEID IS SET NOW (flags 14, same as the synthetic file and the three passenger
//     recordings - it used to be 6 for the real mode when the plan was "the file names its own car and a
//     mismatch is worth seeing"). With 14 the drive frames follow whatever car he is actually in, the
//     playback cannot abort on an id mismatch, and the only id that still has to match is the recording's
//     own 747 - which the [CAR] probe confirms (REAL-RECORDINGS 0/8.2: every logged round has the mission's
//     car at 747, `[CAR] [NPC]Ken_0 -> asked seat 0, VehicleSlot=0, inVehicle=yes`).
//
// WHAT HAPPENS AT THE END OF THE RECORDING: nothing is chained. The last frame ends with the car still
// moving, so re-playing the file (or chaining a passenger file, which carries passenger frames instead of
// driver ones) would either walk him back out of the car or replace the driver's sync - see
// OnRecordingPlaybackEnd below.
//
// ---- AND HOW TO GO BACK TO THE SYNTHETIC ROUTE (one line) ----------------------------------------------
//     KEN_REAL_REC <- true;     ->     KEN_REAL_REC <- false;
// That is the whole revert. It makes TryDrivePlayback use KEN_REC_TYPE / KEN_REC_FILE / KEN_REC_FLAGS
// (ken_drive_t3.rec, the synthesised 100 ms route, unchanged and still in npcscripts/recordings/) exactly
// as it did before this round, and it changes nothing else in this file. The synthetic route needs the
// server's put, so the revert is TWO lines in total:
//     1) npcscripts/ken_driver.nut:  KEN_REAL_REC <- false;
//     2) scripts/missions/intro.nut: put the `put = 3.0, ` field back into Ken's cast entry and delete its
//        `real = 14219` (the synthetic file has no enter-request frame, so the server HAS to seat him at
//        act 3.0 - that is what the 20.9 s head of ken_drive_t3.rec is built around).
// The one-line switch alone is enough to SEE the difference (nothing will board him, so the car sits
// still); both lines together are the full revert.
KEN_REAL_REC   <- true;                          // true = play KEN_REAL_FILE instead of the synthetic route
KEN_REAL_FILE  <- "ken2";                        // npcscripts/recordings/ken2.rec (copy of recordings\ken2.rec):
                                                 //   7802 B, type 3, 110 frames, 13.969 s - he walks to his door,
                                                 //   turns, boards (enter request +672 ms, his own get-in animation
                                                 //   +672..+2781 ms), sits, then DRIVES: 83.79 m west in 7.50 s
                                                 //   = 11.17 m/s = 40.2 km/h, first moving frame at +6469 ms.
                                                 // *** TIME-STRETCHED VARIANT, BUILT BUT NOT HOOKED UP. *** The user
                                                 //   saw this drive in game and says the speed is fine, so the mission
                                                 //   plays the ORIGINAL file. If a slower drive is ever wanted there is
                                                 //   no need to re-record: npcscripts/recordings/ken2_slow.rec is the
                                                 //   same 110 frames with the TICK DELTAS after the drive-away frame
                                                 //   x1.5 (11.17 -> 7.45 m/s, positions/rotation/keys byte-identical),
                                                 //   built by `node _docs/_extract/rec_timescale.js --src npcscripts\
                                                 //   recordings\ken2.rec --out npcscripts\recordings\ken2_slow.rec
                                                 //   --factor 1.5`. To use it: put "ken2_slow" here AND set the
                                                 //   mission's `real` to what the tool prints (with 1.5x it is 10944,
                                                 //   NOT 16419: the drive-away frame is unchanged at file +6469 ms,
                                                 //   but the stretched tail needs 11.25 s instead of 7.50 s, so the
                                                 //   whole recording no longer fits before the act's 31.6001 s
                                                 //   teardown). See _docs/REAL-RECORDINGS.md 12.
KEN_REAL_TYPE  <- PLAYER_RECORDING_TYPE_ALL;     // "all" -> 3; a `/rec <name> driver` file would be 2
KEN_REAL_FLAGS <- PLAY_IGNORE_SEATID | PLAY_IGNORE_VEHMODEL | PLAY_IGNORE_VEHICLEID;  // 2|4|8 = 14, see above

// ------------------------------------------ ONE-SHOT ENTER-VEHICLE TEST (now OFF - see below)
//
// *** OFF as of this round, and it must stay off while the recording is what drives the car: this test is
// what kept the playback clock from ever reaching the drive-away. The full evidence is on KEN_ENTER_TEST
// below. It was ON for exactly one run and that run answered its question. ***
//
// What it does and why it decides the whole design: the server's PutInVehicleSlot() writes the seat in
// the server's own bookkeeping, and at the time this test was written no log had ever shown an
// OnNPCEnterVehicle line for Ken (see _docs/KEN-DRIVE-NOTES.md; the 04:37 run finally did, at the put).
// If the client can get itself into the car instead, the
// server side put is not needed at all. The client API does have EnterVehicle(vehicleid, seatid)
// (npcscript functions.txt); it sends ID_GAME_MESSAGE_ENTER_VEHICLE_REQUEST to the server
// (ClientFunctions.cpp:1169 RequestVehicleEnter) and the server then decides. So the answer comes back as
// an OnNPCEnterVehicle event, not as the return value, which is why this test prints the boolean AND the
// vehicle id AND the playback state.
//
// 4 s after spawn: the spawn state packet has gone by then, and EnterVehicle would be refused before that
// (Playback.cpp's own enter-request arm requires IsSpawned()). The id comes from the server: Main.nut's
// actorNew appends the act's car id as the last ConnectNPCEx vararg, which arrives here as params[4].
//
// *** OFF, AND IT HAS TO STAY OFF WHILE THE RECORDING IS WHAT DRIVES THE CAR. ***  The last run's log
// (npcscripts/logs/2026-09-29 04-37-37 AM [NPC]Ken_0-log.txt) shows what it does: SetTimer's third
// argument is not a repetition COUNT but "loop forever if non-zero" (npcscript functions.txt:58,
// "repeat=1 means loop"), so `SetTimer("KenEnterTest", 4000, 1)` fired every 4 s for the whole act, and
// every firing did this -
//     ENTER TEST: EnterVehicle(747, 0) returned true
//     out of the vehicle, playback stopped        <- OnNPCExitVehicle -> StopRecordingPlayback()
//     in vehicle 747 seat 0
//     playback STARTED at OnNPCEnterVehicle, veh 747, tick <4 s later>
// - i.e. he was ejected and re-seated every 4 seconds and the playback clock was RESTARTED FROM FRAME 0
// every time. The route holds the car still for its first 626 frames (20.867 s), so a clock that is reset
// every 4 s can never reach the drive-away: the car cannot move, whatever else is wrong or right. That is
// the measured reason for the "the car does not move at all" of that run. (The run was made with the old
// 100 ms file, whose head was 208 frames; the head has not changed, only how finely it is sampled.)
// The test itself has served its purpose (the log answers it: EnterVehicle(747, 0) returns true, but the
// server does not move him - he is already recorded in seat 0 there). Turning it back on is safe now: it
// refuses to fire while he is already in a vehicle, so it can no longer eject him.
KEN_ENTER_TEST    <- false;   // true = call EnterVehicle(veh, 0) ~4 s after spawn, once
KEN_ENTER_TEST_MS <- 4000;    // when, in ms after OnNPCSpawn

gDriveStarted <- false;   // one-shot: the clock is never restarted while this is true
gProbeTicks   <- 0;
gVehId        <- -1;      // the act's car id, from the server (params[4]); -1 = none came through
gEnterTry     <- false;   // the test fires once and never again
KEN_PROBE_TICKS <- 24;    // 24 x 500 ms = the 12 s the probe was always meant to cover

// ---- THE REAL-RECORDING MODE'S OWN STATE ---------------------------------------------------------------
gRealMs    <- 0;          // > 0 = real mode: accept KEN_REAL_FILE this many ms after spawn, ON FOOT
gRealOn    <- false;      // the real recording has been accepted at least once
gRealDone  <- false;      // it has ended (EOF, or the watchdog found it gone) - never started again
gRealTick  <- 0;          // GetTickCount() at the moment it was accepted (evidence, for the log lines)
gWatchTick <- 0;          // GetTickCount() at the last watchdog report
gWatchDone <- false;      // the watchdog has had its say and stopped
KEN_WATCH_MS   <- 500;    // the watchdog's own period (repeat=1 = loop, per npcscript functions.txt:58)
KEN_WATCH_AFTER <- 16000; // report this many ms AFTER THE PLAYBACK WAS ACCEPTED - must be past +13969

// ------------------------------------------

function OnNPCScriptLoad( params )
{
    // The mission passes the shared actor params: params[0] is the pose string, params[1..3] the look-at
    // point, and params[4] is the engine's id of the act's car, or "-1" when the act has no car.
    //
    // The pose string is where a driver's own parameters ride (same channel as npcscripts/passenger_ride.nut,
    // same token syntax): "<pose>[@real:<ms>]", built by scripts/missions/intro.nut's intro_act_begin from
    // Ken's cast entry. It is parsed one token at a time so a later token cannot eat an earlier one. The pose
    // itself is IGNORED: posing him, or turning his head, means sending on-foot state, which is the thing
    // that unseats an occupant.
    gVehId = -1;
    if(params.len() > 4){
        try { gVehId = params[4].tointeger(); }
        catch(e) { gVehId = -1; }
    }
    local p = (params.len() > 0) ? params[0] : "";
    local s = p;
    local guard = 0;
    while(guard++ < 16){
        local at = s.find("@");
        if(at == null) break;
        s = s.slice(at + 1);
        local nxt = s.find("@");
        local tok = (nxt == null) ? s : s.slice(0, nxt);
        if(tok.find("real:") == 0) gRealMs = tok.slice(5).tointeger();
        if(nxt == null) break;
        s = s.slice(nxt);
    }
    if(KEN_REAL_REC && gRealMs <= 0)
        print("ken_driver: *** real mode is ON but the pose string carries no @real:<ms> token, so nothing "
            + "can be scheduled - check Ken's cast entry in scripts/missions/intro.nut (it needs `real = ...`)\n");
    print("ken_driver: loaded (pose \"" + p + "\" ignored, params "
        + params.len() + " items, vehId " + gVehId + (params.len() > 4 ? " from params[4]" : " - NO params[4]")
        + (KEN_REAL_REC ? (", REAL mode: \"" + KEN_REAL_FILE + "\" accepted at spawn +" + gRealMs
                           + " ms (on foot, its own enter-request frame boards him)")
                        : ", synthetic mode: \"" + KEN_REC_FILE + "\" (the server puts him in the car)")
        + ")\n");
}

// ------------------------------------------

function OnNPCConnect( myplayerid )
{
    print("ken_driver: connected as " + myplayerid + "\n");
}

// ------------------------------------------

function OnNPCClassSelect()
{
    print("ken_driver: class select, my class " + GetMyClass() + "\n");
    if(KEN_CLASS_SELECT_START) TryDrivePlayback("class select");
    // Spawn. The class is already the right one - ConnectNPCEx passes classId = 0, so the server's spawn
    // packet carries class 0, the client's PotentialClassID is 0, and an earlier round's log shows the
    // spawn being granted (class ids only have to agree for the spawn to be accepted at all, and they
    // do). RequestClassAbs(0) would say it even more explicitly, but it is registered with a type mask
    // that demands two arguments ("RequestClassAbs( classId )" hides the VM handle), so calling it the
    // documented way is not safe to rely on here and is not needed.
    RequestSpawn();
}

// ------------------------------------------

function OnNPCSpawn()
{
    print("ken_driver: " + GetMyName() + " spawned, skin " + GetMySkin() + ", class " + GetMyClass()
        + ", veh " + GetPlayerVehicleID(GetMyID()) + ", playing " + IsPlaybackRunning() + "\n");
    NoWeapon();
    // 12 s of one-line state reports. In real mode the playback is accepted at 14219 ms, i.e. just after the
    // LAST of them (probe 24 fires at 12 s), so what they show is him standing on foot sending nothing and
    // "playing=false started=no" - which is correct here, NOT a failure: the recording has not started yet.
    // From then on the real-mode lines (KenRealStart, in vehicle, played to the end, watchdog) are the record.
    SetTimer("KenProbe", 500, 24);
    if(KEN_ENTER_TEST) SetTimer("KenEnterTest", KEN_ENTER_TEST_MS, 1);   // the one-shot test, see the top

    if(KEN_REAL_REC && gRealMs > 0){
        // ---- REAL MODE. The player's own recording is what boards him and drives the car, so the server has
        // seated nobody (Ken's cast entry has no `put` - see the constants at the top). What this timer does
        // is only what a real recording needs and a synthetic one cannot: accept the playback ON FOOT, so
        // the file's own PACKET_VEHICLE_REQ_ENTER frame (+672 ms) can ask the server for the driver's seat.
        // repeat=0 -> fires once (unlike the 500 ms probe above and the keep-alive, whose repeat=1 means
        // "loop forever", not "once").
        print("ken_driver: REAL recording \"" + KEN_REAL_FILE + "\" will be accepted in " + gRealMs
            + " ms, ON FOOT (the file itself asks for the car at +672 ms and drives it to its end at +13969 ms)\n");
        SetTimer("KenRealStart", gRealMs, 0);
        // The watchdog: it starts with the scheduled start and loops every 500 ms. Its job is only to REPORT
        // once, KEN_WATCH_AFTER ms after the playback was accepted (16 s > the file's 13.969 s), whether the
        // recording got to its end; it never starts or stops anything.
        SetTimer("KenRealWatch", KEN_WATCH_MS, 1);
        return;
    }
    // He may already be in the car (the server's put can land before the spawn is complete). If so this
    // is the right moment; if not, OnNPCEnterVehicle and the probe below will not let it be missed.
    TryDrivePlayback("spawn");
}

// ------------------------------------------

// The real recording's start. Deliberately NOT TryDrivePlayback: that one refuses to leave the ground while
// he is on foot (correct for the synthetic route, whose first driver frame would be dropped), while for a
// real whole-session file being on foot is the REQUIREMENT.
function KenRealStart()
{
    if(gRealOn || gRealDone) return;
    if(!KEN_REAL_REC) return;
    if(KEN_REAL_FILE == ""){
        print("ken_driver: KenRealStart: no recording name configured\n");
        return;
    }
    local veh = 0;
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) { veh = 0; }
    if(veh != 0){
        // A whole-session recording cannot be played from a seat: its PACKET_VEHICLE_REQ_ENTER arm prints
        // "Error. Cannot send vehicle enter request when inside vehicle" and aborts the whole playback. If
        // this line appears, the server seated him anyway - Ken's cast entry still has a `put`.
        print("ken_driver: *** REAL mode: ALREADY IN VEHICLE " + veh + " when the recording was due - a real "
            + "recording cannot be played from a seat (its enter frame would abort). Remove `put` from Ken's "
            + "cast entry in scripts/missions/intro.nut.\n");
        return;
    }
    local ok = false;
    try { ok = StartRecordingPlayback(KEN_REAL_TYPE, KEN_REAL_FILE, KEN_REAL_FLAGS); }
    catch(e) { print("ken_driver: StartRecordingPlayback(\"" + KEN_REAL_FILE + "\") threw: " + e + "\n"); return; }
    if(ok == false || ok == null){
        print("ken_driver: StartRecordingPlayback returned " + ok + " for \"" + KEN_REAL_FILE + "\" type "
            + KEN_REAL_TYPE + " flags " + KEN_REAL_FLAGS + "\n");
        return;
    }
    gRealOn   = true;
    gRealTick = GetTickCount();
    gDriveStarted = true;     // an accepted playback is never restarted, in either mode
    print("ken_driver: playback STARTED at KenRealStart (on foot), file \"" + KEN_REAL_FILE + "\" type "
        + KEN_REAL_TYPE + " flags " + KEN_REAL_FLAGS + ", veh " + veh + ", tick " + gRealTick
        + "   [file: enter request +672 ms, in the car +2781 ms, drives from +6469 ms, ends +13969 ms]\n");
}

// ------------------------------------------

// The watchdog: it reports ONCE, KEN_WATCH_AFTER ms after the playback was accepted - which is past the
// file's own 13.969 s, so the only two things it can say are "it is still running" (unexpected that late)
// or "it is gone and OnRecordingPlaybackEnd never ran". The second one matters: the client aborts a playback
// on a failed frame check WITHOUT firing that event, and an aborted playback leaves the car standing at the
// kerb while the rest of the log looks normal - the client's own "Error. ..." line is the real reason.
// It never starts or stops anything, and it says nothing at all if the recording ended properly (gRealDone).
//
// *** WAIT FOR THE ALARM BEFORE BELIEVING IsPlaybackRunning(). *** The timer is armed in OnNPCSpawn with a
// 500 ms interval, so its fire times are on that grid and the FIRST fire after the playback was accepted is
// only a few tens of milliseconds later - measured in every run of 06-17 .. 06-28: the elapsed time at the
// first fire was 78 / 94 / 281 ms, and the report was a false
//     "*** real recording is GONE 94 ms in (playing=true, veh=0) ... the client aborted it"
// every single time, while the same log's later lines prove the file played its whole 13.969 s and reached
// EOF ("played to the end 14203 ms after it was accepted"). What IsPlaybackRunning() actually answers that
// early is "the client has not run its first playback cycle yet", not "the recording died". gWatchTick is
// therefore only advanced once the alarm is genuinely due, so the timer keeps polling (it is harmless: this
// function only reads state) until then and a real death is still reported.
function KenRealWatch()
{
    if(!KEN_REAL_REC || !gRealOn || gWatchDone) return;
    local now = GetTickCount();
    local elapsed = now - gRealTick;
    if(elapsed < KEN_WATCH_AFTER) return;        // too early to mean anything - see above
    gWatchTick = now;
    gWatchDone = true;
    if(gRealDone){
        print("ken_driver: watchdog at +" + elapsed + " ms: the recording ended normally (nothing to report)\n");
        return;
    }
    local running = false;
    try { running = IsPlaybackRunning(); } catch(e) {}
    local veh = "?";
    try { veh = GetPlayerVehicleID(GetMyID()); } catch(e) {}
    if(running && veh != 0)
        print("ken_driver: real recording is STILL RUNNING " + elapsed + " ms in, veh " + veh
            + " - unexpected (the file is 13969 ms long); it is looping or the clock is stuck\n");
    else
        print("ken_driver: *** real recording is GONE " + elapsed + " ms in (playing=" + running + ", veh=" + veh
            + ") and OnRecordingPlaybackEnd never ran: the client aborted it. Its own Error line is right above "
            + "this one. If the car never moved, that is why. See _docs/REAL-RECORDINGS.md 11.\n");
}

// ------------------------------------------

// THE TEST (KEN_ENTER_TEST above). Asks the server to put him in the act's car by himself, 4 s after
// spawn, and prints every step so one npc log answers the question:
//   * "vehId ... from params[4]" - did the server's id make it through Main.nut -> ConnectNPCEx -> -w ->
//     OnNPCScriptLoad? (If it says NO params[4] or vehId <= 0 the test cannot run at all: the plumbing,
//     not the client, is what failed.)
//   * the bool EnterVehicle() returned - false means the CLIENT refused the request before it was even
//     sent (not spawned yet, already in a vehicle, ...).
//   * GetPlayerVehicleID() right after - the request is asynchronous, so 0 here is normal even on success.
//   * whether StartRecordingPlayback was accepted - TryDrivePlayback only starts a DRIVER playback when
//     the client already believes it is in a car, so a "playback STARTED" line means the enter really
//     landed. If the enter lands a moment later, OnNPCEnterVehicle starts it instead (both paths are
//     gated by the same one-shot flag, so the clock still starts exactly once).
function KenEnterTest()
{
    gEnterTry = true;

    local vehBefore = "?";
    try { vehBefore = GetPlayerVehicleID(GetMyID()); } catch(e) {}
    local spawned = "?";
    try { spawned = AmISpawned(); } catch(e) {}
    print("ken_driver: ENTER TEST: vehId=" + gVehId + " spawned=" + spawned
        + " inVehicleBefore=" + vehBefore + "\n");

    if(gVehId <= 0){
        print("ken_driver: ENTER TEST SKIPPED - no usable vehicle id came from the server (params[4]), "
            + "so there is nothing to enter\n");
        return;
    }
    // NEVER call it while he is already in a vehicle: the last run's log shows what that costs - the
    // client asks the server to enter a car he is already in, the server takes him out and puts him back,
    // OnNPCExitVehicle stops the playback and OnNPCEnterVehicle restarts it from FRAME 0. Repeated every
    // 4 s that makes the drive-away (frame 626, +20.867 s) unreachable. See KEN_ENTER_TEST at the top.
    if(vehBefore != 0 && vehBefore != "?"){
        print("ken_driver: ENTER TEST SKIPPED - already in vehicle " + vehBefore
            + "; EnterVehicle() would eject him and restart the playback clock\n");
        return;
    }

    local ok = "threw";
    try { ok = EnterVehicle(gVehId, 0); }
    catch(e) { print("ken_driver: ENTER TEST: EnterVehicle(" + gVehId + ", 0) threw: " + e + "\n"); return; }
    print("ken_driver: ENTER TEST: EnterVehicle(" + gVehId + ", 0) returned " + ok + "\n");

    local vehAfter = "?";
    try { vehAfter = GetPlayerVehicleID(GetMyID()); } catch(e) {}
    print("ken_driver: ENTER TEST: GetPlayerVehicleID right after = " + vehAfter
        + " (0 here is normal, the enter is a request to the server)\n");

    local started = false;
    try { started = TryDrivePlayback("enter test"); }
    catch(e) { print("ken_driver: ENTER TEST: TryDrivePlayback threw: " + e + "\n"); }
    local playing = "?";
    try { playing = IsPlaybackRunning(); } catch(e) {}
    print("ken_driver: ENTER TEST: playbackAcceptedNow=" + started + " playing=" + playing
        + " -> " + (started ? "THE CLIENT GOT IN BY ITSELF"
                            : "not in a car yet; watch for an OnNPCEnterVehicle line in the next 12 s") + "\n");
}

// ------------------------------------------

// The actor class spawns holding a shotgun and the original's driver does not. See the note at the top:
// the value is cleared on the client only, and deliberately NOT followed by an on-foot sync packet.
function NoWeapon()
{
    try { SetLocalValue(I_CURWEP, 0); print("ken_driver: weapon cleared client-side\n"); }
    catch(e) { print("ken_driver: clearing the weapon failed: " + e + "\n"); }
}

// ------------------------------------------

// The one place a SYNTHETIC playback is ever started. Called from the class-select switch (normally off),
// from OnNPCEnterVehicle, from OnNPCSpawn and from the probe timer; the flag makes the FIRST successful
// start final and every later call a no-op, which is what protects the recording's clock.
//
// In REAL mode (KEN_REAL_REC, the mission's wiring now) this function never starts anything: the real
// recording is accepted by KenRealStart on its own scheduled, ON FOOT, because the file has to be running
// while he is still outside - that is where its PACKET_VEHICLE_REQ_ENTER frame is. Every call here then just
// says why it did nothing, so the log cannot be misread as "the playback was never started".
function TryDrivePlayback( where )
{
    if(gDriveStarted) return false;
    if(KEN_REAL_REC){
        print("ken_driver: (synthetic route is OFF - real mode) " + where + ": nothing started here, the real "
            + "recording owns the playback\n");
        return false;
    }

    local inCar = false;
    try { inCar = (GetPlayerVehicleID(GetMyID()) != 0); } catch(e) {}
    local running = false;
    try { running = IsPlaybackRunning(); } catch(e) {}

    // WHICH FILE, AND WHETHER IT MAY BE STARTED ON FOOT. Only a real whole-session (type 3) recording may:
    // it carries its own PACKET_VEHICLE_REQ_ENTER, which is the frame that asks the server for the car and
    // sets dw_VehicleRequestedTime, so a playback accepted while he is still outside is expected and safe.
    // The synthetic route has no such frame, so on foot it would be dropped on its first frame
    // (Playback.cpp:562-574, "Error. Vehicle not acquired by npc").
    local recType = KEN_REAL_REC ? KEN_REAL_TYPE  : KEN_REC_TYPE;
    local recFile = KEN_REAL_REC ? KEN_REAL_FILE  : KEN_REC_FILE;
    local recFlags = KEN_REAL_REC ? KEN_REAL_FLAGS : KEN_REC_FLAGS;
    local mayStartOnFoot = KEN_REAL_REC && (recType == PLAYER_RECORDING_TYPE_ALL);

    // Everything below is the SYNTHETIC route, which is now the FALLBACK (KEN_REAL_REC = false is the one
    // line that gets here). There is no "on foot" case left to handle: a synthetic DRIVER file has no
    // enter-request frame, so on foot the client would drop it on its first frame
    // (Playback.cpp:562-574, "Error. Vehicle not acquired by npc") - which is why the mission used to put
    // him in the car at act 3.0 and why that `put` has to come back with this switch (see the constants).
    if(running){
        // Already playing and he is in the car: that is ours. Adopt it rather than restart the clock.
        gDriveStarted = true;
        print("ken_driver: playback already running (" + where + "), clock left alone\n");
        return true;
    }
    if(!inCar){
        // Never start the synthetic route on foot: the client aborts it on the first frame, and an
        // accepted playback burns the recording's head in real time even while no packet can be sent.
        print("ken_driver: not in a car yet (" + where + "), playback NOT started\n");
        return false;
    }

    local ok = false;
    // THE FLAGS ARE LOAD BEARING on a type 3 file, and this call used to be made against a type 2 one, on
    // which the client never reads them at all (see the file note at the top): the id that reached the
    // server was the 0 stored in ken_drive.rec, so the playback ran without driving anything.
    //   14 = PLAY_IGNORE_SEATID(2) | PLAY_IGNORE_VEHMODEL(4) | PLAY_IGNORE_VEHICLEID(8)
    // PLAY_IGNORE_VEHICLEID is what makes the client write the REAL car id into every frame
    // (Playback.cpp:591-594, "//needed"), which is why the file itself carries no id and nothing here is
    // hardcoded: the same recording works whoever got which vehicle slot.
    try { ok = StartRecordingPlayback(recType, recFile, recFlags); }
    catch(e) { print("ken_driver: StartRecordingPlayback threw: " + e + " (" + where + ")\n"); return false; }
    if(ok == false || ok == null){
        print("ken_driver: StartRecordingPlayback returned " + ok + " for \"" + recFile + "\" type " + recType
            + " flags " + recFlags + " (" + where + ")\n");
        return false;
    }
    gDriveStarted = true;
    // GetPlayerSeat is NOT reported: the client implements it (CFunctions::GetPlayerSeat) but never
    // registers it with the VM - "GetPlayerSeat" is absent from npcclient.exe's own name table, while
    // GetPlayerVehicleID is there - so a call to it would only ever throw. Seat 0 is the driver's seat
    // and that is the seat the mission asks for, so the vehicle id is the thing worth logging.
    print("ken_driver: playback STARTED at " + where + ", file \"" + recFile + "\" type " + recType
        + " flags " + recFlags + ", veh " + GetPlayerVehicleID(GetMyID()) + ", tick " + GetTickCount() + "\n");
    return true;
}

// ------------------------------------------

// One line of state every 500 ms, for the first 12 s (KEN_PROBE_TICKS). This is the record that tells an
// unstarted playback apart from a started-then-dropped one: "playing" going true and then false with no
// drive-away means the client dropped it (the "Vehicle not acquired by npc" abort); a playback that never
// goes true, together with veh staying 0, means the server's put never reached the client.
//
// The timer is created with repeat=1, which means "loop forever" and NOT "one repetition" (npcscript
// functions.txt:58) - it used to run for the whole act, 62 lines of log. It now stops itself after
// KEN_PROBE_TICKS, which is the 12 s it was always documented to cover; the drive-away is 20.9 s in and
// the act's own teardown removes this npc a moment after it, so nothing is left unobserved.
function KenProbe()
{
    gProbeTicks++;
    if(gProbeTicks > KEN_PROBE_TICKS) return;
    local veh = "?", playing = "?", spawned = "?", state = "?";
    try { veh     = GetPlayerVehicleID(GetMyID()); } catch(e) {}
    try { playing = IsPlaybackRunning(); } catch(e) {}
    try { spawned = AmISpawned(); } catch(e) {}
    try { state   = GetPlayerState(GetMyID()); } catch(e) {}
    print("ken_driver: probe " + gProbeTicks + " spawned=" + spawned + " state=" + state
        + " veh=" + veh + " playing=" + playing
        + " started=" + (gDriveStarted ? "yes" : "no")
        + " entertest=" + (gEnterTry ? "done" : "pending") + "\n");
    TryDrivePlayback("probe " + gProbeTicks);
}

// ------------------------------------------

function OnNPCEnterVehicle( vehicleid, seatid )
{
    // In real mode this is the SERVER accepting the recording's own enter-request frame, and the delta is
    // the evidence that the frame landed where the file says it should: the file asks at +672 ms, so this
    // line should read about 672 ms after the "playback STARTED at KenRealStart" tick (the same check the
    // three passengers' logs get). The next 2.109 s of the file are silent ON PURPOSE - that silence IS the
    // get-in animation (the human client produced the very same silence when he recorded it), so nothing in
    // this script may send an on-foot packet inside it.
    print("ken_driver: in vehicle " + vehicleid + " seat " + seatid
        + ((KEN_REAL_REC && gRealTick != 0) ? ("  [" + (GetTickCount() - gRealTick) + " ms into the real recording \""
                                              + KEN_REAL_FILE + "\", expected ~672]") : "") + "\n");
    NoWeapon();
    TryDrivePlayback("OnNPCEnterVehicle");
}

// ------------------------------------------

function OnRecordingPlaybackEnd()
{
    // NOT restarted, in either mode. Two different reasons, and the real one is the dangerous one:
    //   * synthetic (ken_drive_t3.rec, the fallback): 28.6 s of playback is the end of the act and the car
    //     has left the stage by then; starting it again would teleport the Admiral back onto its parking
    //     spot. The act's own teardown removes the car and this npc a moment later.
    //   * real (ken2.rec, in use now): THE FILE STARTS ON FOOT AND ITS +672 ms FRAME IS "LET ME IN THE CAR".
    //     Replaying it would walk Ken back OUT of the car and then abort on that enter frame from inside a
    //     vehicle - he would be standing on the pavement in the last shot. So the real pass is one-shot:
    //     gRealDone latches it, and TryDrivePlayback refuses to start anything afterwards (in real mode it
    //     never starts anything anyway).
    //
    // This event IS reached by a type 3 file whose last frame has no trailing next-tick (the reader's fread
    // for nexttick comes up short, which is the one path that calls call_OnRecordingPlaybackEnd() -
    // Playback.cpp:116-124). BOTH files are built/saved like that, so this line means "the recording really
    // was played to its end" - for ken2.rec that is file +13969 ms, and the car is already 83.8 m west.
    if(KEN_REAL_REC){
        gRealDone = true;
        print("ken_driver: real recording \"" + KEN_REAL_FILE + "\" played to the end "
            + ((gRealTick != 0) ? ((GetTickCount() - gRealTick) + " ms after it was accepted") : "")
            + " - NOT restarting it (its first frames are on foot and its enter-request frame would abort "
            + "from inside the car). The car keeps the last pose it was given\n");
    }else{
        print("ken_driver: drive-away finished\n");
    }
    gDriveStarted = false;
    try { StopRecordingPlayback(); } catch(e) {}
}

// ------------------------------------------

function OnNPCExitVehicle()
{
    // In real mode, being taken out of the car after the recording boarded him is a FAILURE: the recording
    // cannot put him back (its enter-request frame is long past, and replaying it would abort), so the last
    // shots would show the car driving itself with him standing on the pavement. The client's own reason, if
    // it printed one, is on the line above.
    if(KEN_REAL_REC && gRealOn && !gRealDone)
        print("ken_driver: *** " + GetMyName() + " was pulled OUT of the vehicle while the real recording was "
            + "still running (veh " + GetPlayerVehicleID(GetMyID()) + ") - the seat did not hold. See "
            + "_docs/REAL-RECORDINGS.md 5/11\n");
    print("ken_driver: out of the vehicle, playback stopped\n");
    gDriveStarted = false;
    try { StopRecordingPlayback(); } catch(e) {}
}

// ------------------------------------------

function OnNPCDisconnect( reason )
{
    print("ken_driver: disconnected, reason " + reason + "\n");
}
