// ==================== intro: the whole opening (ONE mission, ONE file) ====================   [moved: INTRO-CODE-NOTES.md block 1]

// ---------------------------------------------------------------- shared helpers
// A game heading (radians) -> the quaternion a static object wants: yaw about z, then the model stood
// upright. Verified against the baked actor objects this server shipped before (angle -2.384 gave
// Quaternion(0.2615, -0.6570, -0.6570, 0.2615)).
function intro_quat(yaw)
{
    local h = yaw * 0.5;
    return Quaternion(cos(h) * 0.70710678, sin(h) * 0.70710678, sin(h) * 0.70710678, cos(h) * 0.70710678);
}

// ==================== THE BISECT SWITCH (ONE line, see _docs/RUN-HISTORY.md) ====================   [moved: INTRO-CODE-NOTES.md block 2]

// ==================== THE AUDIO SWITCH (ONE line, see _docs/AUDIO-CUTOFF.md) ====================   [moved: INTRO-CODE-NOTES.md block 3]

// ==================== THE AUDIO ROOT-CAUSE EXPERIMENTS (ONE line each) ====================   [moved: INTRO-CODE-NOTES.md block 4]

// ---- EXPERIMENT B: the same bytes under a DIFFERENT id --------------------------------------...   [moved: INTRO-CODE-NOTES.md block 5]

// ---- EXPERIMENT C: the CHANNEL/POOL hypothesis, tested by making the pieces OVERLAP ---------...   [moved: INTRO-CODE-NOTES.md block 6]

// ---- EXPERIMENT D: PIN THE HIDDEN PLAYER BODY (the ambience / audio-zone hypothesis) --------...   [moved: INTRO-CODE-NOTES.md block 7]
INTRO_FIXED_BODY <- true;
INTRO_FIXED_BODY_POS <- Vector(-1594.35, -533.23, 16.76);

//    [moved: INTRO-CODE-NOTES.md block 8]

// ---------------------------------------------------------------- act 1: Sonny's office (INT_A)   [moved: INTRO-CODE-NOTES.md block 9]
intro_office_cam <- [
    { pos  = Vector(222.368, -1287.097, 19.714),
      pos2 = Vector(221.895, -1286.774, 19.693),
      look = Vector(219.863, -1290.266, 19.484),
      look2 = Vector(219.890, -1290.309, 19.500),
      dur = 7.1312 },
    { pos  = Vector(218.982, -1286.413, 19.690),
      pos2 = Vector(218.112, -1286.599, 19.644),
      look = Vector(220.608, -1290.273, 19.548),
      look2 = Vector(220.792, -1290.128, 19.536),
      dur = 14.1000 },
    { pos  = Vector(219.461, -1287.938, 19.678),
      pos2 = Vector(219.393, -1288.148, 19.693),
      look = Vector(220.302, -1290.273, 19.541),
      look2 = Vector(220.351, -1290.243, 19.560),
      dur = 9.9688 },
    { pos  = Vector(218.594, -1291.993, 19.770),
      pos2 = Vector(218.533, -1291.979, 19.757),
      look = Vector(220.236, -1290.066, 19.744),
      look2 = Vector(220.211, -1290.124, 19.748),
      dur = 3.7000 },                 // reverse on the two men
    { pos  = Vector(219.857, -1289.027, 19.503),
      pos2 = Vector(219.794, -1288.886, 19.492),
      look = Vector(219.989, -1291.111, 19.624),
      look2 = Vector(220.002, -1291.135, 19.622),
      dur = 14.3313 },
    { pos  = Vector(217.587, -1289.804, 19.597),
      pos2 = Vector(217.730, -1289.110, 19.590),
      look = Vector(220.404, -1290.475, 19.715),
      look2 = Vector(220.408, -1290.395, 19.715),
      dur = 6.5999 },
    { pos  = Vector(220.810, -1288.566, 19.543),
      pos2 = Vector(220.799, -1289.140, 19.585),
      look = Vector(219.894, -1290.793, 19.770),
      look2 = Vector(219.990, -1290.788, 19.681),
      dur = 13.9001 }                 // holds to the end
];

// Dialogue: times are the original's own cutscene clock ($CS_TIME), in seconds, and they run against
// the same clock as the audio. Order matters and it is NOT the GXT key order: the script prints
// INT1_A .. INT1_Z and only then INT1_A1 / INT1_A2, so "pay him a little visit, right?" and "see how
// he's doing." are the LAST two lines, not the second and third.
intro_office_subs <- [
    { t = 1.246,  text = "Tommy Vercetti... Huh! shit." },
    { t = 2.708,  text = "Didn't think they'd ever let him out." },
    { t = 4.796,  text = "He kept his head down, helps people forget." },
    { t = 7.086,  text = "People will remember soon enough." },
    { t = 8.404,  text = "When they see him walking down the streets of their neighborhoods." },
    { t = 10.756, text = "It will be bad for business." },
    { t = 12.614, text = "Well, what are we gonna do, Sonny?" },
    { t = 14.813, text = "We treat him like an old friend and keep him busy out of town. OK?" },
    { t = 18.741, text = "We been talking about expanding down South, right?" },
    { t = 21.294, text = "Vice City is twenty-four carat gold these days." },
    { t = 24.399, text = "The Colombians, the Mexicans, hell," },
    { t = 26.496, text = "even those Cuban refugees are cutting themselves a piece of some nice action." },
    { t = 31.264, text = "But it's all drugs, Sonny," },
    { t = 32.904, text = "None of the families will touch that shit!" },
    { t = 35.200, text = "Times are changing." },
    { t = 36.522, text = "The families can't keep their backs turned while our enemies reap the rewards." },
    { t = 41.196, text = "So, we send someone down to do the dirty work for us..." },
    { t = 45.232, text = "and cut ourselves a nice quiet slice. OK?" },
    { t = 48.992, text = "Who's our contact down there?" },
    { t = 50.206, text = "Ken Rosenberg, schmuck of a lawyer." },
    { t = 52.509, text = "How's he gonna hold Vercetti's leash?" },
    { t = 54.340, text = "We don't need him to." },
    { t = 56.291, text = "We just set him loose in Vice City," },
    { t = 57.900, text = "we give him a little cash to get started. OK?" },
    { t = 61.168, text = "Give it a few months." },
    { t = 62.518, text = "Then we go down," },
    { t = 64.169, text = "pay him a little visit, right?" },
    { t = 65.706, text = "see how he's doing." }
];

// Cast: the three ORIGINAL cutscene models shipped as custom pedestrian skins (201 = CSsonny,   [moved: INTRO-CODE-NOTES.md block 10]
intro_office_cast <- [
    { name = "[NPC]Sonny", skin = 201, pos = Vector(219.958, -1290.82, 19.1979), angle = 0.6, sit = false },
    { name = "[NPC]man1",  skin = 202, pos = Vector(221.039, -1289.61, 19.1891), angle = 1.6, sit = false },
    { name = "[NPC]man2",  skin = 203, pos = Vector(220.364, -1287.98, 19.1773), angle = 2.8, sit = false }
];

// ---------------------------------------------------------------- act 2: the airport (INT_M)   [moved: INTRO-CODE-NOTES.md block 11]
intro_airport_cam <- [
    { dur = 6.4313, keys = [
        { t = 0.0000, pos = Vector(-1609.033, -541.265, 14.873), look = Vector(-1332.202, -708.131, 61.196) },
        { t = 4.8312, pos = Vector(-1609.033, -541.265, 14.873), look = Vector(-1418.946, -567.448, 23.929) },
        { t = 6.4000, pos = Vector(-1608.074, -541.179, 14.930), look = Vector(-1429.755, -566.089, 23.396) },
    ] },   // shot 1   0.0000 .. 6.4313   the plane comes in
    { dur = 7.9688, keys = [
        { t = 0.0000, pos = Vector(-1594.652, -540.035, 15.732), look = Vector(-1581.116, -547.071, 15.949) },
        { t = 2.1000, pos = Vector(-1593.645, -540.688, 15.774), look = Vector(-1592.368, -545.847, 15.573) },
        { t = 7.9313, pos = Vector(-1593.839, -540.977, 15.722), look = Vector(-1592.453, -545.811, 15.579) },
    ] },   // shot 2   6.4313 .. 14.4000
    { dur = 14.5625, keys = [
        { t = 0.0000,  pos = Vector(-1596.609, -544.197, 15.015), look = Vector(-1593.205, -545.174, 15.502) },
        { t = 9.7313,  pos = Vector(-1596.811, -543.097, 14.964), look = Vector(-1593.263, -545.154, 15.497) },
        { t = 11.1313, pos = Vector(-1596.811, -543.097, 14.964), look = Vector(-1593.263, -545.156, 15.497) },
        { t = 12.7625, pos = Vector(-1596.811, -543.001, 14.964), look = Vector(-1593.263, -545.156, 15.497) },
        { t = 13.5625, pos = Vector(-1596.811, -543.001, 14.964), look = Vector(-1599.744, -543.709, 15.241) },
        { t = 14.5312, pos = Vector(-1598.030, -542.984, 15.053), look = Vector(-1599.866, -544.263, 15.288) },
    ] },   // shot 3   14.4000 .. 28.9625   the grille close up: slide, hold, then follow the car out
    { dur = 2.6375, keys = [
        { t = 0.0000, pos = Vector(-1615.096, -542.748, 16.294), look = Vector(-1601.576, -552.009, 15.951) },
    ] },   // shot 4   28.9625 .. 31.6000   the car pulls away (the original holds this pose, no dolly)
];

// Dialogue: INT2_A .. INT2_J, the $CS_TIME thresholds again. The first 4.86 s have no line at all -
// that is the aeroplane landing, and shot 1 is exactly that.
intro_airport_subs <- [
    { t = 4.860,  text = "Hey, hey, guys! It's, uh, Ken Rosenberg here! Hey! Heh, heh, hey, great, hey!" },
    { t = 9.600,  text = "Well, uh, I'm gonna drive you guys to the meet, okay?" },
    { t = 12.342, text = "Now, I've talked to the suppliers and they are very, very, huh-ha," },
    { t = 15.840, text = "keen to start a business relationship, so, uh," },
    { t = 17.556, text = "if all goes well, we should, uh," },
    { t = 20.640, text = "be doing very nicely for ourselves, which is, y'know..." },
    { t = 23.018, text = "good.." },
    { t = 25.863, text = "Okay, so. They're brothers, okay." },
    { t = 27.624, text = "One operates the uh, the business," },
    { t = 29.348, text = "and the other one does the flying." }
];

// The four men at the airport, as NPCs wearing custom ped SKINS made from the ORIGINAL cutscene...   [moved: INTRO-CODE-NOTES.md block 12]
intro_airport_cast <- [
    // `board` = the act-clock second at which each man gets into the car, and `seat` = which seat. The   [moved: INTRO-CODE-NOTES.md block 13]
    { name = "[NPC]Ken",   skin = 204, pos = Vector(-1591.740, -545.500, 14.8681), angle = 0.055, sit = false, script = "ken_driver.nut", real = 19342, seat = 0 },
    // The passengers replay their own recording instead of being only seated by the server. (Tommy,...   [moved: INTRO-CODE-NOTES.md block 14]
    { name = "[NPC]Tommy", skin = 205, pos = Vector(-1593.000, -538.783, 14.8681), angle = -3.142, sit = false, script = "passenger_ride.nut", ride = "tomy", real = 8431, loop = "ken_ride3", seat = 3 },
    { name = "[NPC]GoonA", skin = 206, pos = Vector(-1591.780, -538.735, 14.8681), angle = -3.106, sit = false, script = "passenger_ride.nut", ride = "ga",   real = 8431, loop = "ken_ride1", seat = 1 },
    { name = "[NPC]GoonB", skin = 207, pos = Vector(-1591.630, -537.331, 14.8674), angle = -3.002, sit = false, script = "passenger_ride.nut", ride = "gb",   real = 8431, loop = "ken_ride2", seat = 2 }
];

// Where they stand beside their seats, reached at the cut into shot 3. ALL THREE ARE HIS MEASUR...   [moved: INTRO-CODE-NOTES.md block 15]
intro_airport_beside <- [
    { name = "[NPC]Tommy", pos = Vector(-1590.370, -542.239, 14.8681) },
    { name = "[NPC]GoonA", pos = Vector(-1590.350, -546.489, 14.6985) },
    { name = "[NPC]GoonB", pos = Vector(-1591.740, -542.808, 14.8681) }
];

// The aeroplane is an object (there is no flyable jet in Vice City to spawn instead). The CAR is NOT:
// it is a real vehicle, see intro_airport_car below.
//   airplan: the whole reason shot 1 exists - 258 m of descent in 6.03 s, one constant orientation.
intro_airport_movers <- [
    { model = 6707, from = Vector(-1305.30, -744.40, 64.190), to = Vector(-1419.35, -518.07, 18.050),
      t0 = 0.0,  t1 = 6.03,
      quat  = Quaternion(-0.0723, -0.0164, -0.2201, 0.9727),
      quat2 = Quaternion(-0.0723, -0.0164, -0.2201, 0.9727) }
];

// Ken's car is a REAL VEHICLE, created with CreateVehicle - not a custom object. That was a mis...   [moved: INTRO-CODE-NOTES.md block 16]
intro_airport_car <- {
    model = 175, c1 = 84, c2 = 84,
    from  = Vector(-1591.560, -544.049, 14.6985),
    to    = Vector(-1631.290, -545.000, 14.6985),
    angle = 1.5707963,
    t0    = 23.9,                   // the original's own first moving frame
    // TRUE while an actor's own client drives this car by replaying a recording (npcscripts/ken_driver.nut
    // + recordings/ken_drive.rec). Then the server must keep its hands off the car entirely.
    driven = true,
    // HOW it moves: the original's distance profile, 0 .. 1 of the way to `to`, measured off the me...   [moved: INTRO-CODE-NOTES.md block 17]
    slow  = 1.0,
    track = [
        { t = 23.9000, f = 0.0000 },
        { t = 24.1500, f = 0.0005 },
        { t = 24.4000, f = 0.0012 },
        { t = 24.6500, f = 0.0046 },
        { t = 24.9000, f = 0.0111 },
        { t = 25.1500, f = 0.0190 },
        { t = 25.4000, f = 0.0305 },
        { t = 25.6500, f = 0.0429 },
        { t = 25.9000, f = 0.0595 },
        { t = 26.1500, f = 0.0763 },
        { t = 26.4000, f = 0.0981 },
        { t = 26.6500, f = 0.1194 },
        { t = 26.9000, f = 0.1463 },
        { t = 27.1500, f = 0.1720 },
        { t = 27.4000, f = 0.2040 },
        { t = 27.6500, f = 0.2342 },
        { t = 27.9000, f = 0.2713 },
        { t = 28.1500, f = 0.3060 },
        { t = 28.4000, f = 0.3482 },
        { t = 28.6500, f = 0.3873 },
        { t = 28.9000, f = 0.4346 },
        { t = 29.1500, f = 0.4782 },
        { t = 29.4000, f = 0.5306 },
        { t = 29.6500, f = 0.5787 },
        { t = 29.9000, f = 0.6362 },
        { t = 30.1500, f = 0.6888 },
        { t = 30.4000, f = 0.7514 },
        { t = 30.6500, f = 0.8084 },
        { t = 30.9000, f = 0.8655 },
        { t = 31.1500, f = 0.9103 },
        { t = 31.4000, f = 0.9616 },
        { t = 31.6000, f = 1.0000 }
    ]
};

// How far to move the whole car-and-men cluster towards the middle of the road, in metres. He measured
// the spots standing on the pavement side, so the group sits a little too far north; this is the single
// number that slides all of it (negative y is south, i.e. towards the middle of the road). The
// walk-out points are NOT shifted - those are on the terminal side and were measured separately.
intro_airport_south <- 1.5;
intro_airport_car.from = Vector(intro_airport_car.from.x,
                                intro_airport_car.from.y - intro_airport_south,
                                intro_airport_car.from.z);
intro_airport_car.to   = Vector(intro_airport_car.to.x,
                                intro_airport_car.to.y - intro_airport_south,
                                intro_airport_car.to.z);
foreach(b in intro_airport_beside)
    b.pos = Vector(b.pos.x, b.pos.y - intro_airport_south, b.pos.z);
// Ken is a door spot like theirs (he is NOT the driver's seat any more - a cast position on the seat's
// own coordinates draws him standing ON the car), so he slides with the group.
foreach(c in intro_airport_cast)
    if(c.name == "[NPC]Ken") c.pos = Vector(c.pos.x, c.pos.y - intro_airport_south, c.pos.z);

// THE CLOCK: they are at their doors from the FIRST CUT (shot 1 -> shot 2, 6.43125 s). An earli...   [moved: INTRO-CODE-NOTES.md block 18]
intro_airport_beside_t <- 6.43125;

// The seat plan lives on the cast above (`board` / `seat`), not here: one source of truth.

// Ken is the one entry of the cast that is NOT shifted and does NOT stand outside: he is the driver, so
// his spawn point is the driver's seat itself (0.85 m south of the car's centre line, a little forward of
// it), and the mission puts him in seat 0 within the first tick. Being spawned at the door and hoisted in
// a second later was the version that showed him on the pavement.
// Quaternions are built here at load, never inside a running mission.
foreach(mv in intro_airport_movers){
    if(!mv.rawin("quat"))  mv.quat  <- intro_quat(0.0);
    if(!mv.rawin("quat2")) mv.quat2 <- mv.quat;
}

// ---------------------------------------------------------------- the airport's audio, cut int...   [moved: INTRO-CODE-NOTES.md block 19]

// ---------------------------------------------------------------- the acts, in order   [moved: INTRO-CODE-NOTES.md block 20]
intro_acts <- [
    {
        name     = "office",
        cam      = intro_office_cam,
        subs     = intro_office_subs,
        cast     = intro_office_cast,
        shifted  = true,
        room     = true,
        card     = "cutscene/int_a_card.png",
        cardHold = 3500,
        cardFade = 1500,
        delay    = 3.5,
        audio    = 50001,               // store/sounds/s50001_sonny_office.mp3 (the original int_a.mp3)
        anim     = [0, 169]             // group 0 = "man", 169 = sit
    },
    {
        name     = "airport",
        cam      = intro_airport_cam,
        subs     = intro_airport_subs,
        cast     = intro_airport_cast,
        movers   = intro_airport_movers,
        car      = intro_airport_car,
        shifted  = false,
        room     = false,
        delay    = 0.0,
        // The office act opens with this card. Here it must only BLINK: `cardHold = 0` means it is not held
        // at all - it appears and starts disappearing immediately, fading out over 800 ms. No `delay`
        // either, so the act clock, the camera, the subtitles and the audio all still start at 0 s and the
        // card just plays over the first moment. (Office, for contrast: hold 3500 + fade 1500 + delay 3.5,
        // i.e. several seconds of black on purpose.)
        card     = "cutscene/int_a_card.png",
        cardHold = 0,
        cardFade = 800,
        audio    = 50003,               // store/sounds/s50003_airport.mp3 (the original int_m.mp3)
    }
];

intro_run <- {};        // player id -> the run of the whole mission

// ---------------------------------------------------------------- begin
function mission_intro_begin(p)
{
    // Which act to open with. Main's /m <mission> [act] leaves the number in the root variable
    // missionStartAct (it is cleared there right after this returns, so it is read exactly once and a
    // stale number can never leak into the next play); plain /m or /home means "the first act".
    // `in getroottable()` rather than getroottable()["missionStartAct"]: indexing a table with a key
    // that is not there THROWS, and this has to keep working when nobody set it.
    local act = 0;
    if("missionStartAct" in getroottable() && missionStartAct != null) act = missionStartAct;
    if(typeof act != "integer" || act < 0 || act >= intro_acts.len()){
        // Out of range (or a number that got mangled on the way): say so and start nothing. Returning
        // false makes missionTick undo the frozen widescreen and drop the mission name, so the player
        // gets a message instead of a broken or half-set-up scene.
        local last = intro_acts.len() - 1;
        local shown = act;
        try { shown = act.tostring(); } catch(e) {}   // the message must not throw on a strange value
        MessagePlayer("[#ff0000]intro: act "+shown+" is out of range (this mission has "+intro_acts.len()+
                      " acts, 0-"+last+"), not started", p);
        print("[MISSION] intro: bad start act "+shown+" from "+p.Name);
        return false;
    }

    // Main already put the player in his own world and took over the camera; all this needs to do is
    // remember where to put him back and start the requested act.
    state[p.ID].missionKeepPos = p.Pos;
    intro_run[p.ID] <- {
        act = -1,
        t0 = 0, shot = -1, shotStart = 0.0, shotLen = 1.0,
        sub = 0, audio = false, cam = [], movers = [], car = null, 
        beside = false, boardTry = -99.0, putTry = -99.0, 
        // the audio pieces (INTRO_AUDIO_CHUNKED): `ac` = how many have been issued, `aprobe` = the act
        // second of the last once-a-second [AUDIO] probe line (starts at -1 so the probe fires at t = 0)
        ac = 0, aprobe = -1.0,
        ox = 0.0, oy = 0.0, oz = 0.0
    };
    // ------------------------------------------------------ CLEAR THE ENGINE'S STALE "ALREADY PUT IN"   [moved: INTRO-CODE-NOTES.md block 21]
    if("putInOk" in getroottable()){
        foreach(c in intro_airport_cast)
            if(c.rawin("put"))
                try { putInOk.rawdelete(c.name + "_" + p.ID); } catch(e) {}
    }
    print("[MISSION] intro begins at act "+act+" ("+intro_acts[act].name+")");
    intro_act_begin(p, act);
    return true;
}

// ---------------------------------------------------------------- one act at a time
function intro_act_begin(p, idx)
{
    local r = intro_run[p.ID];
    local a = intro_acts[idx];
    r.act = idx;

    // clear whatever the act before left standing, then set this one up; engRun drains both in order
    qClear(p);

    r.audio = false; r.sub = 0; r.shot = -1;
    r.cam = []; r.movers = [];

    // the pre-roll is a start stamp pushed into the future: t clamps at zero, so the first shot is
    // held still while the card is up and everything streams in, and the audio starts exactly when the
    // clock starts moving. VC-MP has no screen fade, so this is the server side equivalent.
    r.t0 = GetTickCount() + ((a.rawin("delay") ? a.delay : 0.0) * 1000).tointeger();

    r.ox = 0.0; r.oy = 0.0; r.oz = 0.0;
    if(a.shifted && ("roomOffset" in getroottable())){
        r.ox = roomOffset.x; r.oy = roomOffset.y; r.oz = roomOffset.z;
    }

    if(a.room) qRoom(p, roomOffset);

    // the camera, shifted onto the replica once per run. BOTH shapes of shot have to be copied: reading
    // pos/pos2 off a key-list shot (the airport's) is what threw "the index 'pos' does not exist" and
    // killed the mission the moment the airport act began.
    foreach(c in a.cam){
        if(c.rawin("keys")){
            local ks = [];
            foreach(k in c.keys)
                ks.append({ t    = k.t,
                            pos  = Vector(k.pos.x  + r.ox, k.pos.y  + r.oy, k.pos.z  + r.oz),
                            look = Vector(k.look.x + r.ox, k.look.y + r.oy, k.look.z + r.oz) });
            r.cam.append({ dur = c.dur, keys = ks });
        }else{
            r.cam.append({ dur  = c.dur,
                           pos   = Vector(c.pos.x   + r.ox, c.pos.y   + r.oy, c.pos.z   + r.oz),
                           pos2  = Vector(c.pos2.x  + r.ox, c.pos2.y  + r.oy, c.pos2.z  + r.oz),
                           look  = Vector(c.look.x  + r.ox, c.look.y  + r.oy, c.look.z  + r.oz),
                           look2 = Vector(c.look2.x + r.ox, c.look2.y + r.oy, c.look2.z + r.oz) });
        }
    }

    // static objects (the airport's four men)
    if(a.rawin("props")) foreach(pr in a.props)
        qObj(p, pr.model, pr.model, Vector(pr.pos.x + r.ox, pr.pos.y + r.oy, pr.pos.z + r.oz), pr.quat);

    // objects that travel a straight line over a window of the act (the plane, the car)
    if(a.rawin("movers")) foreach(mv in a.movers){
        qObj(p, mv.model, mv.model, Vector(mv.from.x + r.ox, mv.from.y + r.oy, mv.from.z + r.oz), mv.quat);
        r.movers.append({ mv = mv, started = false });
    }

    // a real vehicle, if the act asks for one (see intro_airport_car)
    r.car = a.rawin("car") ? a.car : null;
    if(r.car != null) qCar(p, r.car.model,
                           Vector(r.car.from.x + r.ox, r.car.from.y + r.oy, r.car.from.z + r.oz),
                           r.car.angle, r.car.c1, r.car.c2);

    // actors (NPCs with a custom skin), this viewer's own set. The name carries his id or a second
    // viewer could not connect at all, and it must never contain '#': VC-MP rewrites that to '_' and
    // FindPlayer then silently never matches.
    if(a.rawin("cast")){
        local cx = 0.0, cy = 0.0, cz = 0.0;
        foreach(c in a.cast){ cx += c.pos.x; cy += c.pos.y; cz += c.pos.z; }
        cx = cx / a.cast.len(); cy = cy / a.cast.len(); cz = cz / a.cast.len() + 0.85;
        foreach(c in a.cast){
            local nm = c.name + "_" + p.ID;
            local pose = (c.rawin("sit") && c.sit) ? "sit" : "stand";
            // "stand@14.0" = stand now, and stop sending state 14 s after this actor spawns. That silence
            // is what lets the server seat him: see the cast table.
            if(c.rawin("quiet")) pose = pose + "@" + c.quiet.tostring();
            // A passenger script also needs the NAME of the recording it replays, and the pose string is   [moved: INTRO-CODE-NOTES.md block 22]
            if(c.rawin("real")) pose = pose + "@real:" + c.real.tointeger().tostring();
                if(c.rawin("ride")) pose = pose + "@ride:" + c.ride;
                if(c.rawin("loop")) pose = pose + "@loop:" + c.loop;
            local cpos = Vector(c.pos.x + r.ox, c.pos.y + r.oy, c.pos.z + r.oz);
            local clook = Vector(cx + r.ox, cy + r.oy, cz + r.oz);
            // an act may name its own npc script for an actor: the driver replays a recording
            if(c.rawin("script")) qActorScript(p, nm, cpos, c.angle, c.skin, pose, clook, c.script);
            else qActor(p, nm, cpos, c.angle, c.skin, pose, clook);
        }
    }

    if(a.rawin("card")) qCard(p, a.card, a.cardHold, a.cardFade);
}

// ---------------------------------------------------------------- tick (50 ms)

// The `[CAR]` placement probe's sample times, in act seconds. Three samples because the recording's
// first throttle frame is at file +20867 ms and the act's own camera ruler ends at 31.6001 s, so with
// the put landing at act 3.0 the drive-away has 7.7 s of act left: 24 s and 29 s bracket it and 31 s
// is the last tick that is still inside the act (the car's endpoint is x = -1631.46, the parked
// position is x = -1591.56, so 17-40 m is the whole question). Delete with the rest of the debugging.

// Is the man REALLY in a vehicle as far as the ENGINE is concerned? Two independent handles are...   [moved: INTRO-CODE-NOTES.md block 23]
function intro_inCar(nm)
{
    local np = FindPlayer(nm);
    if(np == null) return false;
    try { if(np.Vehicle != null) return true; } catch(e) {}
    try { if(np.VehicleSlot >= 0) return true; } catch(e) {}
    return false;
}

// True for the cast entries that replay a REAL recording (`real` in the cast table). Their posi...   [moved: INTRO-CODE-NOTES.md block 24]
function intro_is_realrec(name)
{
    foreach(c in intro_airport_cast)
        if(c.name == name && c.rawin("real")) return true;
    return false;
}

// ------------------------------------------ THE GET-IN ANIMATION IS THE RECORDING'S TO FINISH   [moved: INTRO-CODE-NOTES.md block 25]
intro_realrec_ms <- {
    tomy = 11484, ga = 11625, gb = 13016, ken2 = 13969
};
KEN_REAL_FILE_NAME <- "ken2";        // keep in sync with npcscripts/ken_driver.nut's KEN_REAL_FILE

// HOW LONG AFTER AN ACTOR SPAWNS THE ACT CLOCK IS WHEN HIS RECORDING IS ACCEPTED.   [moved: INTRO-CODE-NOTES.md block 26]

// THE GATE'S OWN SPAWN LAG, and it is 0.0 on purpose: the one value that cannot be wrong in the   [moved: INTRO-CODE-NOTES.md block 27]
INTRO_GATE_LAG <- 0.0;

// The margin added to the END of every real-recording window: the recordings' own get-in animation, which
// is 2109 ms in ken2.rec (+672 -> +2781 ms) and 2063-2078 ms in the three passenger files. Rounded up.
INTRO_GETIN_MARGIN <- 2.2;

// True while `name`'s real recording is still being replayed at act second t.   [moved: INTRO-CODE-NOTES.md block 28]
function intro_realrec_playing(name, t)
{
    foreach(c in intro_airport_cast){
        if(c.name != name || !c.rawin("real")) continue;
        // The file this man replays: the passengers name it in `ride`, the driver in his script.
        local file = c.rawin("ride") ? c.ride : (c.rawin("script") ? KEN_REAL_FILE_NAME : "");
        if(!intro_realrec_ms.rawin(file)) continue;      // unknown file: do not invent a window
        local start = INTRO_GATE_LAG + (c.real / 1000.0);   // playback accepted (gate lag, see above)
        local end   = start + intro_realrec_ms[file] / 1000.0;
        if(t >= start && t <= end + INTRO_GETIN_MARGIN) return true;
        return false;
    }
    return false;
}

// The world form of the sound call, for EXPERIMENT A (see INTRO_AUDIO_WORLD_PATH at the top of ...   [moved: INTRO-CODE-NOTES.md block 29]

function mission_intro_tick(p)
{
    local r = intro_run.rawin(p.ID) ? intro_run[p.ID] : null;
    if(r == null || r.act < 0) return;
    local a = intro_acts[r.act];

    // raw counts up from the start stamp and is NEGATIVE through the pre-roll; dt and t are that
    // clamped at zero, which is what holds the first shot still. The audio has to test the RAW value,
    // otherwise it starts on the first tick - during the black card - instead of when the card begins
    // to fade and the scene clock starts moving.
    local raw = GetTickCount() - r.t0;
    local dt  = raw < 0 ? 0 : raw;              // guard the 32 bit millisecond counter wrapping
    local t   = dt / 1000.0;

    // ---------------------------------------------------------------- the act's audio   [moved: INTRO-CODE-NOTES.md block 30]
    if(raw >= 0 && !r.audio){
        qSound(p, a.audio);
        r.audio = true;
    }

    // objects on the move: straight line between their two track points over t0 .. t1
    foreach(m in r.movers){
        local mv = m.mv;
        if(!m.started && t >= mv.t0){
            m.started = true;
            local ms = ((mv.t1 - mv.t0) * 1000).tointeger();
            if(ms < 1) ms = 1;
            qRot(p, mv.model, mv.quat2);
            qMove(p, mv.model, Vector(mv.to.x + r.ox, mv.to.y + r.oy, mv.to.z + r.oz), ms);
        }
    }

    // The car drives off. It is a REAL vehicle, so moving it a little every tick moves the whole th...   [moved: INTRO-CODE-NOTES.md block 31]
    if(r.car != null && !r.car.driven && t >= r.car.t0){
        local c = r.car;
        local ct = c.t0 + (t - c.t0) / c.slow;      // slow < 1 stretches the whole departure out
        local f = 1.0;
        local kk = c.track;
        local i0 = 0;
        for(local i = 0; i < kk.len(); ++i) if(kk[i].t <= ct) i0 = i;
        local i1 = (i0 + 1 < kk.len()) ? i0 + 1 : i0;
        if(i1 > i0) f = kk[i0].f + (kk[i1].f - kk[i0].f) * (ct - kk[i0].t) / (kk[i1].t - kk[i0].t);
        else        f = kk[i0].f;
        if(f < 0.0) f = 0.0;
        if(f > 1.0) f = 1.0;
        qCarPos(p, Vector(c.from.x + (c.to.x - c.from.x)*f + r.ox,
                          c.from.y + (c.to.y - c.from.y)*f + r.oy,
                          c.from.z + (c.to.z - c.from.z)*f + r.oz));
    }

    // pick the shot: the durations are a ruler and t falls somewhere on it
    local acc = 0.0, idx = -1;
    for(local i = 0; i < r.cam.len(); ++i){
        local d = r.cam[i].dur.tofloat();
        if(t < acc + d){ idx = i; r.shotStart = acc; r.shotLen = d; break; }
        acc += d;
    }
    if(idx < 0){                                // this act is over
        if(r.act + 1 < intro_acts.len()) intro_act_begin(p, r.act + 1);
        else qEnd(p);
        return;
    }

    if(idx != r.shot) r.shot = idx;             // a cut is simply the shot number changing

    // They are at their doors from the FIRST CUT (see intro_airport_beside_t). A teleport is only   [moved: INTRO-CODE-NOTES.md block 32]
    if(r.act == 1 && !r.beside && t >= intro_airport_beside_t){
        r.beside = true;
        foreach(b in intro_airport_beside){
            // A real-recording man is skipped by name: this teleport is the fake version of the walk his own
            // recording performs for real (that comment at the top of this block says the walk could only be
            // done by replaying a recording, and there was none in the install - now there is one, for Tommy
            // and GoonB). Teleporting him here would jump him to the car at 6.43 s and the recording would
            // then drag him back to the terminal at 9.5 s, in shot 2, in front of the camera.
            if(intro_is_realrec(b.name)) continue;
            qActorPos(p, b.name + "_" + p.ID, b.pos);
        }
    }

    // Where the camera is inside this shot. Two shapes of shot table are supported:   [moved: INTRO-CODE-NOTES.md block 33]
    local sh = r.cam[idx];
    local cam, look;
    if(sh.rawin("keys")){
        local kk = sh.keys;
        local i0 = 0;
        for(local i = 0; i < kk.len(); ++i) if(kk[i].t <= t - r.shotStart) i0 = i;
        local i1 = (i0 + 1 < kk.len()) ? i0 + 1 : i0;
        local f = 0.0;
        if(i1 > i0) f = (t - r.shotStart - kk[i0].t) / (kk[i1].t - kk[i0].t);
        if(f < 0.0) f = 0.0;
        if(f > 1.0) f = 1.0;
        cam  = Vector(kk[i0].pos.x + (kk[i1].pos.x - kk[i0].pos.x)*f,
                      kk[i0].pos.y + (kk[i1].pos.y - kk[i0].pos.y)*f,
                      kk[i0].pos.z + (kk[i1].pos.z - kk[i0].pos.z)*f);
        look = Vector(kk[i0].look.x + (kk[i1].look.x - kk[i0].look.x)*f,
                      kk[i0].look.y + (kk[i1].look.y - kk[i0].look.y)*f,
                      kk[i0].look.z + (kk[i1].look.z - kk[i0].look.z)*f);
    }else{
        // one straight dolly across the whole shot: this shape of table carries the two ends itself
        local camA = sh.pos, camB = sh.pos2, lookA = sh.look, lookB = sh.look2;
        local k = (t - r.shotStart) / r.shotLen;    // how far into this shot we are, 0 .. 1
        if(k > 1.0) k = 1.0;
        cam = Vector(camA.x + (camB.x - camA.x)*k,
                     camA.y + (camB.y - camA.y)*k,
                     camA.z + (camB.z - camA.z)*k);
        if(lookB != null)
            look = Vector(lookA.x + (lookB.x - lookA.x)*k,
                          lookA.y + (lookB.y - lookA.y)*k,
                          lookA.z + (lookB.z - lookA.z)*k);
        else
            // no second aim key: keep the direction this shot started with, so the shot is a pure dolly
            look = Vector(cam.x + (lookA.x - camA.x),
                          cam.y + (lookA.y - camA.y),
                          cam.z + (lookA.z - camA.z));
    }

    // Where the invisible body is parked. It has to stay close enough for the room and the actors to   [moved: INTRO-CODE-NOTES.md block 34]
    local bo = a.rawin("bodyOffset") ? a.bodyOffset : Vector(0.0, 0.0, 0.0);
    local bp;
    if(INTRO_FIXED_BODY && r.act == 1){
        bp = INTRO_FIXED_BODY_POS;
    }else{
        bp = Vector(cam.x + (cam.x - look.x)*0.5 + bo.x,
                    cam.y + (cam.y - look.y)*0.5 + bo.y,
                    cam.z - 2.0 + bo.z);
    }
    qBody(p, bp);
    qCam(p, cam, look);

    // the actors' seat. Sent every tick and not once: an actor's own npcclient keeps resending its
    // on-foot state (npcscripts/sonny_actor.nut sends one every second) and that packet drops the pose
    // again. Sent this often a drop can only last until the next tick, which is one frame.
    if(a.rawin("anim")) qAnim(p, a.anim[0], a.anim[1]);

    // the dialogue has its own timeline; several lines can fall inside one shot
    while(r.sub < a.subs.len() && a.subs[r.sub].t <= t){
        Msg(p, a.subs[r.sub].text);
        r.sub++;
    }

    // TEMPORARY placement probe: two samples a few seconds apart, so it is visible whether the actors
    // are standing on something or still falling. Delete with the rest of the debugging.

    // The men with a `put` are put in BY THE SERVER, each at his own original time (the cast's
    // `put`/`seat`). It used to be "once per man and never re-sent, because `wasPutIn` remembers what the
    // engine has already accepted" - that is what silently broke every round after the first one of a
    // server session (the flag is never cleared, see mission_intro_begin and _docs/RUN-HISTORY.md 2).
    // It is now "until the engine's own answer says he is in", which is both stricter and self-limiting.
    if(r.act == 1){
        // ------------------------------------------------------ THE PUT-IN, DONE RIGHT   [moved: INTRO-CODE-NOTES.md block 35]
        if(t - r.putTry >= 1.0){
            foreach(c in intro_airport_cast){
                if(!c.rawin("put")) continue;
                if(t < c.put) continue;
                local nm = c.name + "_" + p.ID;
                if(intro_inCar(nm)) continue;       // really seated: nothing left to do for him
                r.putTry = t;
                qPutIn(p, nm, c.seat);
            }
        }
        // Empty hands, from the server, once a second for the men who are IN the car. The npc side   [moved: INTRO-CODE-NOTES.md block 36]
        if(t - r.boardTry >= 1.0){
            r.boardTry = t;
            // The weapon queue's own gate, and the ONE line that can verify its arithmetic from a single
            // run: it prints, once, the window each real-recording actor is being excused for. If a run
            // ever shows an animation still being cut, compare the printed window with the act time the
            // log's other lines put the boarding at - the window must contain it.
            foreach(c in intro_airport_cast){
                if(intro_realrec_playing(c.name, t)) continue;
                if(intro_inCar(c.name + "_" + p.ID)) qWep(p, c.name + "_" + p.ID);
            }
        }
    }
}

// ---------------------------------------------------------------- stop
// Main has already deleted the room, the objects and the actors, and put the player back; all that is
// left is this mission's own bookkeeping. It also runs when the player leaves mid mission.
function mission_intro_stop(p)
{
    if(intro_run.rawin(p.ID)) intro_run.rawset(p.ID, null);
}

// ---------------------------------------------------------------- registration   [moved: INTRO-CODE-NOTES.md block 38]
function mission_ken_01_an_old_friend_begin(p) { mission_intro_begin(p); }
function mission_ken_01_an_old_friend_tick(p)  { mission_intro_tick(p); }
function mission_ken_01_an_old_friend_stop(p)  { mission_intro_stop(p); }
