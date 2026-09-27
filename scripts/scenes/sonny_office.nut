// ==================== Intro 01: Sonny's office, Liberty City ====================
// Runs in the hidden room. Start it with /cut sonny_office
//
// Dialogue: the game's own lines, keys INT1_A .. INT1_Z from TEXT/american.gxt
// (exported to GTAVC_txt/INTRO.txt).
//
// Cutting follows the original: about seven camera setups over the whole scene, each
// holding 6-50 seconds while the camera drifts slowly forward, then a hard cut.
// Subtitles run on their own timeline and are NOT tied to the cuts.

// skins: 115 = Sonny, 146 = man sitting, 147 = man standing (see _docs/skin-grid.html)
// All three stand: the crouch pose this build offers reads as too low for the framing.
// eye = height above the floor the camera aims at.
sonny_cast <- [
    { name = "[NPC]Sonny", skin = 115, pos = Vector(219.958, -1290.82, 19.1979), angle = 0.6, sit = false, eye = 1.00 },
    { name = "[NPC]man1",  skin = 146, pos = Vector(221.039, -1289.61, 19.1891), angle = 1.6, sit = false, eye = 1.00 },
    { name = "[NPC]man2",  skin = 147, pos = Vector(220.364, -1287.98, 19.1773), angle = 2.8, sit = false, eye = 1.00 }
];

// The whole scene lives at roomOffset (scripts/room_replica.nut rebuilds the hotel room there).
// Actor spawn, camera geometry and shot setup are all derived from these positions, so shifting the
// cast is all it takes to move the scene. Guarded so the scene still works without the replica.
// Shift the cast onto the replica, once. Guarded because /reload re-runs onServerStart and dofiles
// this file again: a second shift would drop the actors 250m above the room, out of the scene.
if("roomOffset" in getroottable() && !("roomCastShifted" in getroottable())){
    roomCastShifted <- true;
    foreach(a in sonny_cast){
        a.pos = Vector(a.pos.x + roomOffset.x, a.pos.y + roomOffset.y, a.pos.z + roomOffset.z);
    }
}

// Subtitle times come straight out of the game's own script. In main.scm - decompiled in the
// game's data/main.txt - the cutscene prints a line and then waits for the cutscene clock:
//
//     print_now 'INT1_A' {time} 10000 {flag} 1
//   :INTRO_807
//     if 2708 > $CS_TIME              <- $CS_TIME = get_cutscene_time, in milliseconds
//     goto_if_false @INTRO_874
//   :INTRO_874
//     print_now 'INT1_B' ...
//
// so the constant in front of $CS_TIME is the exact moment the next line appears. Those are
// the times below, in seconds, and they run against the same clock as the cutscene audio we
// play, so nothing has to be offset.
//
// Order matters, and it is NOT the GXT key order: the script prints INT1_A, INT1_B ... INT1_Z
// and only then INT1_A1 and INT1_A2. So "pay him a little visit, right?" and "see how he's
// doing." are the LAST two lines of the scene, not the second and third. Reading the keys as
// A, A1, A2, B ... is what left every earlier version of this table exactly two lines out.
sonny_subs <- [
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

// ---------------------------------------------------------------- camera setups
// Everything is derived from the measured cast: dx,dy is the direction from Sonny
// through the middle of the group, rx,ry is its right hand normal.
function sonny_setupShots()
{
    local S  = sonny_cast[0];
    local M1 = sonny_cast[1];
    local M2 = sonny_cast[2];

    local cx = (S.pos.x + M1.pos.x + M2.pos.x) / 3.0;
    local cy = (S.pos.y + M1.pos.y + M2.pos.y) / 3.0;
    local dx = cx - S.pos.x, dy = cy - S.pos.y;
    local len = sqrt(dx*dx + dy*dy);
    dx = dx/len; dy = dy/len;
    local rx = dy, ry = -dx;

    local fl  = S.pos.z;
    local eye = fl + S.eye;
    // camera height above the floor. The room has no table to measure against, so this is
    // the one number to tune: the lamp hangs low here, so the shots sit close to the ground.
    local ch  = 0.10;
    // which side of the table the camera leans to. In the original the two men sit on the
    // near side and Sonny is across the table, so the camera drifts the other way.
    local sd  = -1.0;
    local shots = [];

    // A: wide master, Sonny centred, one man either side, the near man's back in frame
    shots.append({ cam = Vector(S.pos.x + dx*3.6, S.pos.y + dy*3.6, fl + ch),
                   look = Vector(S.pos.x, S.pos.y, eye), dur = 6.4,
                   cam2 = Vector(S.pos.x + dx*2.5, S.pos.y + dy*2.5, fl + ch) });

    // B: closer, Sonny ends up on the right of the frame. Aim lower than the rest: this shot
    // is nearer the men, so the same aim would tilt up much more than the master shot.
    shots.append({ cam = Vector(S.pos.x + dx*2.4 + rx*0.9*sd, S.pos.y + dy*2.4 + ry*0.9*sd, fl + ch),
                   look = Vector(cx, cy, eye - 0.15), dur = 14.1,
                   cam2 = Vector(S.pos.x + dx*1.7 + rx*0.8*sd, S.pos.y + dy*1.7 + ry*0.8*sd, fl + ch) });

    // C: lowest of the lot, right down by the floor
    shots.append({ cam = Vector(S.pos.x + dx*2.0 + rx*0.5*sd, S.pos.y + dy*2.0 + ry*0.5*sd, fl + ch*0.7),
                   look = Vector(S.pos.x, S.pos.y, eye), dur = 10.0,
                   cam2 = Vector(S.pos.x + dx*1.4 + rx*0.4*sd, S.pos.y + dy*1.4 + ry*0.4*sd, fl + ch*0.7) });

    // D: reverse on the two men, shot from behind Sonny, further back and further right
    local mx = (M1.pos.x + M2.pos.x) * 0.5;
    local my = (M1.pos.y + M2.pos.y) * 0.5;
    shots.append({ cam = Vector(S.pos.x - dx*2.0 + rx*1.6, S.pos.y - dy*2.0 + ry*1.6, fl + ch),
                   look = Vector(mx, my, fl + 1.05), dur = 3.8,
                   cam2 = Vector(S.pos.x - dx*1.7 + rx*1.4, S.pos.y - dy*1.7 + ry*1.4, fl + ch) });

    // E: on Sonny, but far enough back that the camera is not inside his face
    shots.append({ cam = Vector(S.pos.x + dx*2.2 + rx*0.3, S.pos.y + dy*2.2 + ry*0.3, fl + ch*0.9),
                   look = Vector(S.pos.x, S.pos.y, eye), dur = 14.3,
                   cam2 = Vector(S.pos.x + dx*1.8 + rx*0.25, S.pos.y + dy*1.8 + ry*0.25, fl + ch*0.9) });

    // F: two shot, Sonny big on the right and the young man across the table. The cut into this
    // one lands on "Who's our contact down there?" (48.75), which is where the original cuts.
    shots.append({ cam = Vector(S.pos.x + dx*2.9 + rx*1.5*sd, S.pos.y + dy*2.9 + ry*1.5*sd, fl + ch*1.1),
                   look = Vector(cx, cy, eye), dur = 6.3,
                   cam2 = Vector(S.pos.x + dx*2.0 + rx*1.2*sd, S.pos.y + dy*2.0 + ry*1.2*sd, fl + ch*1.1) });

    // G: medium close on Sonny, one long slow push right to the end. The original cuts back to
    // his face 0.8s after "We don't need him to." (54.10), and holds him until the scene ends.
    shots.append({ cam = Vector(S.pos.x + dx*2.6 + rx*0.7, S.pos.y + dy*2.6 + ry*0.7, fl + ch),
                   look = Vector(S.pos.x, S.pos.y, eye), dur = 13.0,
                   cam2 = Vector(S.pos.x + dx*1.8 + rx*0.45, S.pos.y + dy*1.8 + ry*0.45, fl + ch) });

    return shots;
}

sonny_shots <- sonny_setupShots();

// Connects this player's own set of actors, one set per viewer: the scene runs in the viewer's world,
// so a shared cast would be invisible to everyone but the first. The names carry the player id or the
// second viewer could not connect at all. The engine parks them in the viewer's world and kicks them
// again on end (see endCutscene).
function sonny_spawnActors(player)
{
    // middle of the table: everyone looks at it, which reproduces the original blocking
    // (Sonny towards the camera, one man in profile, the near man's back to us)
    local cx = 0.0, cy = 0.0, cz = 0.0;
    foreach(a in sonny_cast){ cx += a.pos.x; cy += a.pos.y; cz += a.pos.z; }
    cx = cx / sonny_cast.len(); cy = cy / sonny_cast.len(); cz = cz / sonny_cast.len() + 0.85;

    local names = [];
    foreach(a in sonny_cast)
    {
        // VC-MP rewrites '#' in player names to '_' (the name tag reads [NPC]Sonny_0), so using '#'
        // here would produce a name FindPlayer can never match and every world change would silently
        // do nothing. Stick to what the engine keeps: letters, digits, brackets, underscore.
        local nm = a.name + "_" + player.ID;
        names.append(nm);
        if(FindPlayer(nm) != null) continue;              // already on stage
        local pose = (a.rawin("sit") && a.sit) ? "sit" : "stand";
        ConnectNPCEx(nm, a.pos, a.angle, a.skin, 19, 0, "sonny_actor.nut", false, "", "",
                     pose, cx.tostring(), cy.tostring(), cz.tostring());
    }
    state[player.ID].cutActors = names;
}

function sonny_onStart(player)
{
    sonny_spawnActors(player);
}

function sonny_onEnd(player)
{
    // nothing to do: the engine deletes this player's room copy and kicks his own actors, so a
    // second viewer's scene is never disturbed
}

cutscenes.sonny_office <- {
    shots   = sonny_shots
    subs    = sonny_subs
    onStart = sonny_onStart
    onEnd   = sonny_onEnd

    // Opening title card: the client shows store/sprites/cutscene/int_a_card.png full screen for
    // cardHold ms, then fades it out over cardFade ms; the scene clock and the audio start when the
    // fade begins, which is the order the original uses.
    // A silent pre-roll is safe here because the room now lives outside the hotel interior - the gap
    // was only dangerous back there, where silence let VC start the hotel's own ambience. cardHold is
    // sized to cover the actor spawn (the npcclient processes need a few seconds).
    card     = "cutscene/int_a_card.png"
    cardHold = 3500
    cardFade = 1500
    delay    = 3.5
    audio    = 50001
    // The scene no longer sits inside the hotel interior (see roomOffset in room_replica.nut), so the
    // body can go back to its normal spot just behind and below the camera. Keep this at zero unless
    // something about the new location needs tuning.
    bodyOffset = Vector(0.0, 0.0, 0.0)
}
