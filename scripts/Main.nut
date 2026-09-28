class player{
    nogoto = false;
	randspawn = false;
	stat = false;
	spawnloc = false;
	X = 0;
	Y = 0;
	Z = 0;
	spawnwep = false;
	wep1 = 0;
	wep2 = 0;
	wep3 = 0;
	wep4 = 0;
	wep5 = 0;
	wep6 = 0;
	wep7 = 0;
    wep8 = 0;     
    havecar=false;
}
// The room build helpers (rp / mk / objcrt / roomBuild) now live in scripts/room_replica.nut: the room
// is that family's business and this file only owns the engine capability layer.
state <-{};
missions <- {};
shots <- {};
freecam <- {};
npcCount <- 0;
lastAttacker <- {};
local notcar=["155","177","162","160"];
local teamColor = ["red", "blue", "green", "yellow","white", "black" ];
local tcR=[255,0,0,255,255,0];
local tcG=[0,0,255,255,255,0];
local tcB=[0,255,0,0,255,0];
local wepammo= [10,10,10,10,10,100,49,100,20,70,500,600,500,350,300,300,10,10,10,100,20,10];
// NPCs connect as ordinary players; IsPlayerNPC() is the engine's own verdict
function isActor(p)
{
    return IsPlayerNPC(p.ID);
}
function CheckAway()
{
    for (local i = 0; i < GetMaxPlayers(); ++i)
    {
        local p = FindPlayer(i);
        if (p != null)
        {
            // actors never send input, so p.Away is always true and the AFK check would kick them
            if(isActor(p)) continue;
            if(p.Away && state[p.ID].AdminLevel<=2)
            {
                if(!p.IsSpawned)
                {
                    state[p.ID].AFKS=0;
                    continue;
                }
                state[p.ID].AFKS+=0.1;
                if(state[p.ID].AFKS>=1.0)
                {
                    p.World=p.UniqueWorld;
                    CreateExplosion( p.World,6,p.Pos,p.ID,true );
                    CreateExplosion( p.World,6,p.Pos,p.ID,true );
                    p.World=0;
                }if(state[p.ID].AFKS>=10.0)
                {
                    state[p.ID].AFKS=0.0;
                    p.Kick();
                }
            }else{
                state[p.ID].AFKS=0.0;
            }
        }
    }
}
function checkEvade(plyName)
{
    local p=FindPlayer(plyName);
    if(p!=null)
    {
        state[p.ID].evade=false;
    }
}
function onServerStart()
{
    SetMaxPlayers(16);
    SetTimeRate(10000);
    SetFriendlyFire(true);
    SetPassword("");
    SetStuntBike(true);
    SetTaxiBoostJump(true);
    SetFriendlyFire(false);
    SetDeathMessages( false );
    SetMaxHeight(85);
    // 閸欘亜婀銈咁槱閸旂姾娴囬棃娆愨偓浣芥簠鏉堝棴绱皁nServerStart 娴犲懏婀囬崝鈥虫珤閸氼垰濮╅弮鑸靛⒔鐞涘奔绔村▎鈽呯礉
    // 閼存碍婀伴柌宥堟祰閿?reload閿涘褰ф导姘跺櫢鐠?onScriptLoad閿涘奔绗夋导姘跺櫢婢跺秴鍩涙潪?
    print("[Main] onServerStart: loading static vehicles...");
    try {
        dofile("./scripts/Vehicles.nut");
        LoadVehicles();
        print("[Main] static vehicles loaded OK");
    } catch (e) {
        print("[Main] ERROR loading Vehicles.nut: " + e);
    }
    NewTimer("CheckAway", 100, 0);
    dofile("./scripts/Database.nut");
    loadDB();
    loadbanDB();
    NewTimer("sceneClock", 1000, 0);
    // 25 ms, not 50: this is the only clock that can move anything, and a vehicle with nobody driving it
    // is walked by writing its position here. At 50 ms the car advanced 0.26 m per update and the client
    // showed that as a stutter, which reads as "the car is going too fast and it judders".
    NewTimer("missionTick", 25, 0);
    NewTimer("freecamClock", 10, 0);
    // The old mission file (missions/ken_01_an_old_friend.nut) is gone: its content was merged into
    // missions/intro.nut, and the old name still starts the same scene through the forwarders at the
    // bottom of that file (`/m` with no argument defaults to that name, see the /m handler below).
    // The cutscene room, rebuilt as our own objects somewhere the game treats as open air. Inside
    // the hotel interior the room inherits its loud ambience, and VC culls the interior's own
    // objects the moment the player counts as being outside it - so the scene has to move out, and
    // the scenery has to be ours. The world 0 copy built here is permanent: it is the floor the
    // actors' own npcclient processes stand on, whatever world the viewer is in.
    dofile("./scripts/room_replica.nut");
    roomBuild(roomOffset, 0);
    // Missions own their own content; loading the file only registers it in the missions table.
    dofile("./scripts/missions/intro.nut");
}
function weapons(weps)
{
    local ID=-1;
    local ammo=0;
    switch(weps)
    {
        case "fist":
            ID=0;
            break;
        case "brassknuckles":
            ID=1;
            break;
        case "screwdriver":
            ID=2;
            break;
        case "golfclub":
            ID=3;
            break;
        case "nightstick":
            ID=4;
            break;
        case "knife":
            ID=5;
            break;
        case "bat":
            ID=6;
            break;
        case "hammer":
            ID=7;
            break;
        case "meatcleaver":
            ID=8;
            break;
        case "machete":
            ID=9;
            break;
        case "katana":
            ID=10;
            break;
        case "chainsaw":
            ID=11;
            break;
        case "grenade":
            ID=12;
            ammo=10;
            break;
        case "remote":
            ID=13;
            ammo=10;
            break;
        case "teargas":
            ID=14;
            break;
        case "molotov":
            ID=15;
            break;
        case "colt":
            ID=17;
            ammo=100;
            break;
        case "colt45":
            ID=17;
            ammo=100;
            break;
        case "python":
            ID=18;
            ammo=49;
            break;
        case "shotgun":
            ID=19;
            ammo=100;
            break;
        case "spaz":
            ID=20;
            break;
        case "spas12":
            ID=20;
            break;
        case "stubby":
            ID=21;
            break;
        case "tec9":
            ID=22;
            break;
        case "uzi":
            ID=23;
            break;
        case "ingram":
            ID=24;
            break;
        case "mp5":
            ID=25;
            break;
        case "m4":
            ID=26;
            ammo=300;
            break;
        case "ruger":
            ID=27;
            ammo=300;
            break;
        case "sniper":
            ID=28;
            break;
        case "laserscope":
            ID=29;
            break;
        case "rocketlauncher":
            ID=30;
            ammo=10;
            break;
        case "RPG":
            ID=30;
            ammo=10;
            break;
        case "flamethrower":
            ID=31;
            ammo=20;
            break;
        case "m60":
            ID=32;
            ammo=70;
            break;
        case "minigun":
            ID=33;
            ammo=50;
            break;
    }
    return ID;
}
function GetTeamColor(player) {
    local R=tcR[player.Team];
    local G=tcG[player.Team];
    local B=tcB[player.Team];
    local hex=format("%02X%02X%02X",R,G,B);
    return "[#"+ hex +"]";
}
function onScriptLoad()
{
	enter <- BindKey( true, 0x0D, 0, 0 );
    att <- BindKey( true, 0x01, 0x11, 0x60 );
    left <- BindKey( true, 0x25, 0, 0 );
    right <- BindKey( true, 0x27, 0, 0 );
    // free camera keys (WASD move, arrows look, pageup/pagedown height)
    keyW    <- BindKey( true, 0x57, 0, 0 );
    keyA    <- BindKey( true, 0x41, 0, 0 );
    keyS    <- BindKey( true, 0x53, 0, 0 );
    keyD    <- BindKey( true, 0x44, 0, 0 );
    keyUp   <- BindKey( true, 0x26, 0, 0 );
    keyDown <- BindKey( true, 0x28, 0, 0 );
    keyPgUp <- BindKey( true, 0x21, 0, 0 );
    keyPgDn <- BindKey( true, 0x22, 0, 0 );
    keyShift<- BindKey( true, 0x10, 0, 0 );
    AddClass(0,RGB(255,0,0),11,Vector(-490.468,-421.897,11.4417),140.020,19,100,26,300,22,500);
    AddClass(1,RGB(0,0,255),1,Vector(-378.704,-581.025,25.3215),140.020,20,14,25,150,26,500);
    AddClass(2,RGB(0,255,0),16,Vector(-576.806,-447.04,14.9894),140.020,19,80,24,500,26,300);
    AddClass(4,RGB(255,255,255),116,Vector(-103.62,-1604.24,9.2732),140.020,21,70,23,500,27,300);
    // 閸旂姾娴囩粻锛勬倞閸?JSON閿涙nScriptLoad 閸︺劌鎯庨崝銊ユ嫲濮ｅ繑顐?/reload 閺冨爼鍏橀幍褑顢戦敍?
    // 閹靛濮╅弨?admins.json 閸?/reload 閸楀啿褰查悽鐔告櫏閿涘牊妫ら棁鈧柌宥呮儙閺堝秴濮熼崳顭掔礆
    try {
        dofile("./scripts/AdminJson.nut");
        LoadAdmins();
    } catch (e) {
        print("[Main] ERROR loading AdminJson.nut: " + e);
    }
    // reload 閸?state 鐞涖劏顫﹂柌宥囩枂閿涘奔绲?onPlayerJoin 娑撳秳绱版稉鍝勫嚒閸︺劎鍤庨惃鍕负鐎瑰爼鍣哥捄鎴礉
    // 鏉╂瑩鍣锋稉鐑樺閺堝婀痪璺ㄥ负鐎瑰爼鍣稿?state閿涘矂浼╅崗?onPlayerDeath/onPlayerSpawn 缁涘顔栭梻?state[player.ID] 閹躲儵鏁?
    for (local i = 0; i < GetMaxPlayers(); ++i) {
        local p = FindPlayer(i);
        if (p != null && !(p.ID in state)) {
            state[p.ID] <- {};
            state[p.ID].AdminLevel <- 0;
            state[p.ID].CDdiepos <- false;
            state[p.ID].diepos <- {};
            if ("admin" in getroottable()) {
                local uid = GetUid(p);
                if (uid in admin) {
                    state[p.ID].AdminLevel = admin[uid];
                }
            }
        }
    }
}
function onPlayerJoin( player )
{
    if(checkbanDB(player)) return;
    Announce("Welcome ~r~ to  this ~p~ beta ~t~ server ~y~ have fun!", player, 1);
    player.Colour=RGB(tcR[player.Team],tcG[player.Team],tcB[player.Team]);
    if(!(player.ID in state)){
        state[player.ID]<-{};
    }
    state[player.ID].AdminLevel<-0;
    state[player.ID].CDdiepos<-false;
    state[player.ID].diepos<-{};
    state[player.ID].AFKS<-0.0;
    state[player.ID].evade<-false;
    state[player.ID].mission<-null;
    state[player.ID].scene<-null;
    state[player.ID].mTick<-0;
    state[player.ID].CP<-null;
    state[player.ID].msg<-null;
    state[player.ID].cleanCP<-false;
    // engine side bookkeeping for whatever mission this player runs; the mission itself never holds
    // an object handle (see engRun)
    state[player.ID].missionWorld<-0;     // world the mission runs in (the player's own, see /home)
    state[player.ID].missionRoom<-null;   // his copy of the room, deleted on the way out
    state[player.ID].missionObjs<-{};     // objects he asked for, by the mission's own tag
    state[player.ID].missionActors<-[];   // names of his NPCs, kicked on the way out
    state[player.ID].missionVeh<-null;    // a real vehicle the mission asked for, deleted on the way out
    state[player.ID].missionKeepPos<-null;// where to put him back when the mission ends
    if(freecam.rawin(player.ID)) freecam.rawset(player.ID, null);
    if("admin" in getroottable()){
        local uid = GetUid(player);
        if(uid in admin){
            state[player.ID].AdminLevel = admin[uid];
        }
    }
    queryDB(player);
}
function onPlayerCommand(player,cmd,text)
{
    print(player+": /"+cmd+" "+text);
    if(cmd=="clear"){
        if(state[player.ID].CP != null){ state[player.ID].CP.Remove(); state[player.ID].CP = null; }
        MessagePlayer("[#00ff00]checkpoint cleared", player);
    }
    if(cmd=="here"){
        if(state[player.ID].CP != null){ state[player.ID].CP.Remove(); }
        state[player.ID].CP = CreateCheckpoint(player, player.UniqueWorld, false, player.Pos, ARGB(150, 255, 0, 255), 2);
        print("[POS] checkpoint moved to "+player.Pos.x+", "+player.Pos.y+", "+player.Pos.z);
    }
    if(cmd=="m"){
        // /m [mission] [act] - act is optional. No argument at all still starts the old
        // ken_01_an_old_friend name (which mission_intro_begin forwards), exactly as before.
        // Parsed the way /rec does it: no string.split() in this Squirrel, so cut the text by hand.
        local txt = (text == null) ? "" : text;
        local sp  = txt.find(" ");
        local name = ((sp == null) ? txt : txt.slice(0, sp));
        if(name == "") name = "ken_01_an_old_friend";

        local actStr = (sp == null) ? "" : txt.slice(sp + 1);
        local act    = null;                  // null = "use the mission's own first act"
        if(actStr != ""){
            // digits only: tointeger() would happily turn "abc" into 0 or throw; this way a typo is
            // reported instead of silently starting act 0.
            local m = actStr.find("[^0-9]");
            if(m == null){
                try { act = actStr.tointeger(); } catch(e) { act = null; }
            }
            if(act == null){
                MessagePlayer("[#ff0000]bad act number: "+actStr+" - usage: /m <mission> [act], e.g. /m intro 1", player);
                return;
            }
        }

        // Hand the act over without knowing anything about missions: mission_intro_begin reads this
        // one and deletes it (see the note at its definition), so it is set here and cleared in
        // missionTick whether the mission used it or not.
        if(act != null) getroottable()["missionStartAct"] <- act;
        // ENTER HIS OWN WORLD FIRST, exactly as /home does. A mission runs in whatever world the player
        // is in when it starts (missionTick records `missionWorld = p.World`), so starting it from world 0
        // played the whole scene in world 0 - where the server's own static vehicles live, which is how
        // he noticed ("地图上刷的车，这车只会在世界零刷"). /home always did this; /m did not.
        player.World = player.UniqueWorld;
        startMission(player, name);
    }
    if(cmd=="heal"){
        if(player.Health>=100){
            ClientMessage("you are already at full health", player, 255, 0, 0);
        }else if(player.Cash <100){
            ClientMessage("you don't have enough money to heal", player, 255, 0, 0);
        }else{
            player.GiveMoney(-100);
            player.Health = 100;
            ClientMessage("you have been healed", player, 0, 255, 0);
        }
    }else if(cmd=="arm"){
        if(player.Armour>=100){
            ClientMessage("you are already at full armor", player, 255, 0, 0);
        }else if(player.Cash <100){
            ClientMessage("you don't have enough money to get armor", player, 255, 0, 0);
        }else{
            player.GiveMoney(-100);
            player.Armour = 100;
            ClientMessage("you have been armored", player, 0, 255, 0);
        }
    }else if(cmd=="money" && state[player.ID].AdminLevel>=2){
        player.GiveMoney(500);
    }else if(cmd=="skin"){
        if(!text){
            ClientMessage("[#ff0000]usage: /skin <skin ID>", player, 255, 0, 0);
        }else{
            player.Skin = text.tointeger();
        }
    }else if(cmd=="weapon"){
        if (!text){
            MessagePlayer( "type /weapon [weapon name/ID] to give yourself a weapon", player );
        }else{
            local wepID;
            try {
                wepID=text.tointeger();
            }catch (e){
                wepID=null;
            }
            if(wepID==null){
                wepID=weapons(text);
                if(wepID==-1){
                    MessagePlayer( "[#ff0000]weapon not found", player );
                }else{
                    if(wepID<=11){
                        player.GiveWeapon(wepID,114514);
                        MessagePlayer( "[#00ff00]weapon:[#ffff00]"+GetWeaponName(wepID)+" [#00ff00]given,Weapon's ID:[#ffff00]"+wepID, player );
                    }else
                    {
                    player.GiveWeapon(wepID,wepammo[wepID-12]);
                    MessagePlayer( "[#00ff00]weapon:[#ffff00]"+GetWeaponName(wepID)+" [#00ff00]with[#ffff00] "+wepammo[wepID-12]+"[#00ff00] ammo given, Weapon's ID:[#ffff00]"+wepID, player );
                    }
                }
            }else{
                if(wepID >=1 && wepID <=33 && wepID!=16){
                    if(wepID<=11){
                        player.GiveWeapon(wepID,114514);
                        MessagePlayer( "[#00ff00]weapon:[#ffff00]"+GetWeaponName(wepID)+" [#00ff00]given,Weapon's ID:[#ffff00]"+wepID, player );
                    }else
                    {
                    player.GiveWeapon(wepID,wepammo[wepID-12]);
                    MessagePlayer( "[#00ff00]weapon:[#ffff00]"+GetWeaponName(wepID)+" [#00ff00]with[#ffff00] "+wepammo[wepID-12]+"[#00ff00] ammo given, Weapon's ID:[#ffff00]"+wepID, player );
                    }
                }else{
                    MessagePlayer( "[#ff0000]weapon not found", player );
                }
            }
            
        }  
    }else if(cmd=="team" && state[player.ID].AdminLevel>=1){
        if(!text){
            MessagePlayer( "your team is " + teamColor[player.Team] + ". type /team [team color] to change it", player );
        }else{
            for(local i=0; i<teamColor.len(); ++i)
            {
                if(teamColor[i]==text)
                {
                    player.Team=i;
                    MessagePlayer( "your team is changed to "+teamColor[i], player );
                    break;
                }
            }
        }
        player.Colour=RGB(tcR[player.Team],tcG[player.Team],tcB[player.Team]);
    }else if (cmd=="help"){
        ClientMessage("available commands: /m <mission> [act], /heal, /arm, /money, /skin, /weapon, /att, /team, /pos, /rec, /recstop, /help", player, 0, 255, 0);
    }else if(cmd=="pos"){
        local ang = 0;
        try { ang = player.Angle; } catch(e) { ang = 0; }
        local r = ang * 0.0174533;
        local fx = player.Pos.x - sin(r) * 5.0;
        local fy = player.Pos.y + cos(r) * 5.0;
        MessagePlayer("Pos:"+player.Pos+" Angle:"+ang.tointeger()+" Look:("+fx.tostring()+" "+fy.tostring()+" "+player.Pos.z.tostring()+")",player);
        print("[POS] Vector("+player.Pos.x+", "+player.Pos.y+", "+player.Pos.z+") angle "+ang);
    }else if(cmd=="car"){
        if(!text){
            ClientMessage("[#ff0000]usage: /car <vehicle ID>", player, 255, 0, 0);
            return;
        }
        if(notcar.find(text)==0 || notcar.find(text)>=1){
            MessagePlayer("[#ff0000]not this car!",player);
            if(player.ID==1145)
            {
                player.World=player.UniqueWorld;
                CreateExplosion( player.World,6,player.Pos,player.ID,true );
                CreateExplosion( player.World,6,player.Pos,player.ID,true );
                player.World=0;
            }
            return;
        }else{
            if("tempVeh" in state[player.ID] && state[player.ID].tempVeh != null){
                state[player.ID].tempVeh.Delete();
            }
            state[player.ID].tempVeh<-CreateVehicle(text.tointeger(),player.World,player.Pos.x+3,player.Pos.y+3,player.Pos.z+1,player.Angle,68,39);
        }
    }else if(cmd=="rec"){
        // /rec <name> [driver|all]  - record THIS player so the npc plugin can replay him.
        // "driver": be IN the car and driving before this command - the plugin stops the recording the
        //           moment you leave the vehicle (habi [Tutorial: NPC] #3).
        // "all":    stand on foot, type this, then walk/board/drive - that file also carries the
        //           vehicle-request frame, which is what the mission's car needs (recorder type 3).
        // The exact call and its evidence are in the note above the rec* globals.
        // No string.split() in this Squirrel (see AdminJson.nut's note): parse "<name> [type]" by hand.
        local txt  = (text == null) ? "" : text;
        local sp   = txt.find(" ");
        local name = (sp == null) ? txt : txt.slice(0, sp);
        local rest = (sp == null) ? "" : txt.slice(sp + 1);
        local restLow = rest;
        try { restLow = rest.tolower(); } catch(e0) {}
        if(name == ""){
            MessagePlayer("[#ff0000]usage: /rec <name> [driver|all]  (then drive, then /recstop)", player);
        }else{
            // Keep it a plain file name: the plugin makes "<name>.rec" out of it.
            local okName = true;
            try { if(name.len() > 40) okName = false; } catch(e1) {}   // .len() may be missing in this lib
            foreach(bad in [".", "/", "\\", ":", "*", "?", "\"", "<", ">", "|", " "])
                if(name.find(bad) != null) okName = false;
            local typeId = recTypeDriver;
            if(restLow == "all") typeId = recTypeAll;

            if(!okName){
                MessagePlayer("[#ff0000]bad name: use letters, digits, _ or - only (it becomes <name>.rec)", player);
            }else if(recIsOn(player) == true){
                MessagePlayer("[#ffff00]already recording as "+recName+" - /recstop first", player);
                print("[REC] "+player.Name+" is already recording ("+recName+")");
            }else{
                // One documented call. See the api note above the rec* globals.
                local r = recStd(player, name, typeId);
                print("[REC] "+player.Name+" /rec "+name+" (type "+typeId+", id "+player.ID+") "
                    + "StartRecordingPlayerData -> "+r);
                if(r == "ok" || r == "unverifiable"){
                    recShape = "StartRecordingPlayerData(player.ID, rectype, name, flags)";
                    recWho = player;
                    recName = name;
                }
                if(r == "ok"){
                    MessagePlayer("[#00ff00]recording started as [#ffff00]"+name
                        + "[#00ff00] (type "+typeId+", id "+player.ID+") - drive now, /recstop when done", player);
                }else if(r == "unverifiable"){
                    MessagePlayer("[#ffff00]recording call accepted as "+name
                        +" but this build answers nothing for IsPlayerRecording", player);
                }else{
                    MessagePlayer("[#ff0000]recording call was rejected - see server_log.txt ([REC] lines)", player);
                }
                // Where the file goes. The npc plugin writes into the folder named by `recdir` in
                // server.cfg: unset or 1 -> <server folder>\recordings\, = 2 -> npcscripts\recordings\.
                // Playback only ever looks in npcscripts\recordings\, so a file from `recordings\`
                // has to be moved there before an npc can replay it.
                print("[REC] expected file: <server>\\recordings\\"+name+".rec (server.cfg has no recdir"
                    + " key -> default 1); with `recdir 2` in server.cfg it would already land in "
                    + "npcscripts\\recordings\\. Playback reads only npcscripts\\recordings\\, so move it"
                    + " there if it lands in recordings\\. Check the header: "
                    + "node -e \"const b=require('fs').readFileSync('recordings/"+name+".rec');"
                    + "console.log('version',b.readUInt32LE(0),'type',b.readUInt32LE(4),'flags',b.readUInt32LE(8),'bytes',b.length)\""
                    + " - type must be "+typeId+".");
            }
        }
    }else if(cmd=="recstop"){
        local on = recIsOn(player);
        local wasName = recName;
        local stop = recStop(player);
        print("[REC] "+player.Name+" /recstop: "+stop+" (IsPlayerRecording was "+on+")");
        MessagePlayer("[#00ff00]"+stop+" - "+wasName+".rec is in recordings\\ (or npcscripts\\recordings\\"
            +" with recdir 2); move it to npcscripts\\recordings\\ to replay it", player);
        recShape = "";
        recWho = null;
        recName = "";
    }else if(cmd=="refcar"){
        // TEMPORARY reference car: an Admiral (175) dropped at the EXACT pose the mission's own car is
        // parked in, so the spots beside its seats can be measured in the open world (a custom object only
        // exists during the scene, so there is nothing else to measure against).
        // It TRACKS the mission's car: the pose (and model/colours/heading) is read out of the mission's own
        // table `intro_airport_car` (scripts/missions/intro.nut, dofile'd into the root table) instead of
        // being copied here, because the mission shifts the whole car-and-men cluster 1.5 m south
        // (intro_airport_south) AFTER writing that table. A copy of the pre-shift numbers therefore put this
        // reference car 1.5 m NORTH of the real one, and the walking routes recorded against it were
        // measured beside the wrong car. Reading the table means the two can never drift apart again.
        // /refcar again removes it.
        if("refVeh" in state[player.ID] && state[player.ID].refVeh != null){
            state[player.ID].refVeh.Delete();
            state[player.ID].refVeh = null;
            MessagePlayer("[#00ff00]refcar removed",player);
        }else{
            // The pose to use. These are the fallback numbers, i.e. exactly what this command used to
            // hard-code (the pre-1.5 m-shift pose); they are only used if the mission's table is not
            // readable, which is reported below.
            local pose = { x = -1591.560, y = -544.049, z = 14.6985, angle = 1.5707963,
                           model = 175, c1 = 68, c2 = 39 };
            // Why the fallback was used, or null when the mission's table was read.
            local why = null;
            local carTag = getroottable().rawget("intro_airport_car");
            if(carTag == null){
                why = "intro_airport_car is not in the root table (mission file not loaded)";
            }else{
                // Read every field BEFORE writing any of them, so a half-readable table cannot leave the
                // fallback pose with a couple of values swapped in from the mission. A `from` that is not a
                // Vector has no .x and throws on the first read, which is the `from is not a Vector` case.
                try {
                    local from = carTag.from;
                    local fx = from.x, fy = from.y, fz = from.z;     // throws unless `from` is a Vector
                    local fa = carTag.angle, fm = carTag.model, fc1 = carTag.c1, fc2 = carTag.c2;
                    pose.x = fx; pose.y = fy; pose.z = fz;
                    pose.angle = fa; pose.model = fm; pose.c1 = fc1; pose.c2 = fc2;
                } catch(e) {
                    why = "intro_airport_car.from is not a Vector / the table is incomplete ("+e+")";
                }
            }
            if(why != null) print("[REFCAR] fallback pose used: "+why);
            // CreateVehicle takes the heading in RADIANS (player.Angle is in degrees, which is why the
            // /car command above spawns cars at an odd angle). The table's `angle` is radians too: due
            // west = pi/2. Never convert it to degrees here.
            state[player.ID].refVeh <- CreateVehicle(pose.model,player.World,pose.x,pose.y,pose.z,pose.angle,pose.c1,pose.c2);
            // What was actually spawned, so the console shows the numbers any measurement is taken against.
            print("[REFCAR] "+player.Name+" /refcar: admiral at "+fmtPos(Vector(pose.x,pose.y,pose.z))
                +" angle "+format("%.6f",pose.angle)+" ("+(why == null ? "intro_airport_car" : "FALLBACK")+")");
            MessagePlayer("[#00ff00]refcar: Admiral at "+fmtPos(Vector(pose.x,pose.y,pose.z))
                +" facing WEST (pi/2 rad), the pose the mission's car is parked in"
                +(why == null ? "" : " [FALLBACK: "+why+"]"),player);
        }
    }else if(cmd=="uid"){
        MessagePlayer("[#00ff00]your UID: [#ffff00]"+GetUid(player),player);
	}else if((cmd=="admin" || cmd=="Admin") && state[player.ID].AdminLevel>=1){
        MessagePlayer("[#00ff00]your AdminLevel: [#ffff00]"+state[player.ID].AdminLevel,player);
    }else if(cmd=="IP" && state[player.ID].AdminLevel>=2){
        local ply=FindPlayer(text);
        if(ply){
            MessagePlayer("Player's IP:"+ply.IP,player);
            return;
        }else{
            ClientMessage("Player not find",player,255,0,0);
        }
    }else if(cmd=="reload" && state[player.ID].AdminLevel>=3){
        // 闁插秷娴囬崜宥嗙閻炲棙澧嶉張澶屽负鐎?/car 娑撳瓨妞傛潪锔肩窗ReloadScripts 娴兼岸鍣哥純顔垮壖閺堫剛濮搁幀渚婄礄state 鐞涖劍绔荤粚鐚寸礆閿?
        // 娑撳秴鍘涢崚鐘冲竴閻ㄥ嫯鐦芥潻娆庣昂鏉烇缚绱伴崣妯诲灇"鐎涖倕鍔?濞堝鏆€閸︺劌婀撮崶鍙ョ瑐閿涘奔绠ｉ崥搴㈡￥濞夋洖鍟€鐞氼偉鍓奸張顒€鍨归梽銈忕礉閸欘亣鍏樻禍鍝勪紣閹垫挾鍨?
        foreach (pid, st in state) {
            if ("tempVeh" in st && st.tempVeh != null) {
                st.tempVeh.Delete();
                st.tempVeh = null;
            }
        }
        Message("[#ffd200][Server] " + player.Name + " is reloading scripts...");
        ReloadScripts();
    }else if(cmd=="diepos"){
        if(text=="on"){
            state[player.ID].CDdiepos=!state[player.ID].CDdiepos;
            if(state[player.ID].CDdiepos){
                MessagePlayer("[#00ff00]diepos [on]",player);
                return;
            }
            MessagePlayer("[#00ff00]diepos [off]",player);
        }else if(text=="off"){
            state[player.ID].CDdiepos=false;
            MessagePlayer("[#00ff00]diepos [off]",player);
        }else if(text==null){
            state[player.ID].CDdiepos=!state[player.ID].CDdiepos;
            if(state[player.ID].CDdiepos){
                MessagePlayer("[#00ff00]diepos [on]",player);
                return;
            }
            MessagePlayer("[#00ff00]diepos [off]",player);
        }
    }else if(cmd=="boom"){
        if(!text){
            player.World=player.UniqueWorld;
            CreateExplosion( player.World,6,player.Pos,player.ID,true );
            CreateExplosion( player.World,6,player.Pos,player.ID,true );
            player.World=0;
        }else{
            if(state[player.ID].AdminLevel>=3){
                if(text == "@e"){
                    for(local i=0;i<=GetPlayers();i++)
                    {
                        local ply=FindPlayer(i);
                        if(ply!=null){
                            Announce("~r~!!!!B O O M!!!!", ply, 3);
                            CreateExplosion( ply.World,6,ply.Pos,ply.ID,true );
                            CreateExplosion( ply.World,6,ply.Pos,ply.ID,true );
                        }
                    }
                }else{
                    local ply=FindPlayer(text);
                    for(local i=1;i<=1000;i++)
                    {
                        CreateExplosion( ply.World,6,ply.Pos,ply.ID,true );
                        CreateExplosion( ply.World,6,ply.Pos,ply.ID,true );
                    }
                }
            }
        }
    }else if(cmd=="goto" || cmd=="Goto" || cmd=="tp"){
        local t = (text != null) ? split(text, " ") : null;
        if(t != null && t.len() >= 3)
        {
            // authoring helper: /tp <x> <y> <z> drops you on a spot so it can be read back with /pos.
            // Used to measure actor positions for a mission on ground that has no landmark to go by.
            player.Pos = Vector(t[0].tofloat(), t[1].tofloat(), t[2].tofloat());
            MessagePlayer("[#00ff00]moved to "+t[0]+" "+t[1]+" "+t[2],player);
        }else if(!text)
        {
            MessagePlayer("[#ff0000]ERROR: /goto|/tp [player name/ID] or /tp <x> <y> <z>",player);
        }else
        {
            local ply=FindPlayer(text);
            if(ply!=null)
            {
                player.Pos.x=ply.Pos.x;
                player.Pos.y=ply.Pos.y;
                player.Pos.z=-32767;
            }else
            {
                MessagePlayer("[#ff0000]ERROR:player not found",player);
            }
        }
    }else if(cmd=="addadmin" && state[player.ID].AdminLevel>=3){
        HandleAddAdmin(player, text);
    }else if(cmd=="deladmin" && state[player.ID].AdminLevel>=3){
        HandleDelAdmin(player, text);
    }else if(cmd=="ban" && state[player.ID].AdminLevel>=2){
        local t=split(text," ");
        if(t!=null && t.len()>=2)
        {
            local ply=FindPlayer(t[0]);
            if(ply!=null)
            {
                local mins=0;
                local reason=t[1];
                if(t.len()>=3){
                    mins=t[1].tointeger();
                    reason=t[2];
                }
                addbanDB(ply,reason,mins,player.Name);
            }else{
                MessagePlayer("[#ff0000]player not found: "+t[0],player);
            }
        }else{
            MessagePlayer("[#ff0000]usage: /ban <player> [minutes] <reason>",player);
        }
    }else if(cmd=="unban" && state[player.ID].AdminLevel>=2){
        if(text!=null)
        {
            unbanDB(text,player);
        }else{
            MessagePlayer("[#ff0000]usage: /unban <name or UID>",player);
        }
    }else if(cmd=="home")
    {
        // Your own world, then the mission plays there with your own set of actors. The mission is
        // started through the queue, not on the spot: command handlers run on a deep stack and the
        // engine calls a mission makes on its first frame do not like that.
        player.World = player.UniqueWorld;
        startMission(player, "intro");
    }else if(cmd=="depthtest")
    {
        // TEMPORARY: measures how deep the script stack can get before the overloaded engine functions
        // stop resolving. Delete this branch and depthProbe() once the number is known.
        depthProbe(1, player);
    }else{
        ClientMessage("The command "+cmd+" is not available, please type /help for a list of commands", player, 255, 0, 0);
    }
}
function onPlayerEnterVehicle( player, vehicle, door )
{
	local Veh = vehicle.ID;
	MessagePlayer("[#ffffff]Vehicle ID :[#ffbbbb] "+Veh,player);
}
function onVehicleExplode( vehicle )
{
    // 閻溾晛顔?/car 鏉烇讣绱欓崷?state 娑擃厾娅ョ拋鎵畱閿涘鍨归梽銈忕幢闂堟瑦鈧浇婧呮稉宥呭灩閿涘牆绱╅幙搴″斧閸︿即鍣搁悽鐕傜礆閵?
    // 閹?state 閸掋倖鏌囬敍灞肩瑝閸欐绱╅幙搴☆槻閻劏顫﹂柨鈧В浣芥簠鏉?ID 閻ㄥ嫬濂栭崫宥冣偓?
    foreach (pid, st in state) {
        if ("tempVeh" in st && st.tempVeh != null && st.tempVeh.ID == vehicle.ID) {
            st.tempVeh = null;
            vehicle.Delete();
            return;
        }
    }
}
function onPlayerHealthChange( player, lastHP, newHP )
{
    if(lastHP > newHP && lastHP-newHP>=5 && newHP<=50)
    {
        state[player.ID].evade=true;
        NewTimer("checkEvade",5000,1,player.Name);
    }
    if(lastAttacker.rawin(player.ID))
    {
        local shooterID=lastAttacker[player.ID];
        lastAttacker.rawdelete(player.ID);
        hitinfo(shooterID, player.ID);
    }
}
function onPlayerArmourChange(player,lastArmour,nemArmour)
{
    if(lastAttacker.rawin(player.ID))
    {
        local shooterID=lastAttacker[player.ID];
        lastAttacker.rawdelete(player.ID);
        hitinfo(shooterID, player.ID);
    }
}
function onPlayerChat( player, message )
{
    print(player.Name+": "+message);
    if(state[player.ID].AdminLevel>=1){
        local plytc=GetTeamColor(player)
        Message("[#81d8CF][Admin]"+plytc+player.Name+"[#ffffff]: "+message);
    }else{
        local plytc=GetTeamColor(player)
        Message(plytc+player.Name+"[#ffffff]:"+message);
 }
}
function onPlayerPart(player,reason){
    // Everything that must happen when a player leaves, in ONE function. Squirrel silently replaces
    // an earlier definition with a later one of the same name, and a second onPlayerPart used to sit
    // further down this file: it quietly killed saveDB(), so accounts never persisted.
    if(player.ID in state)
    {
        if(state[player.ID].evade)
        {
            addbanDB(player,"Evade Death",30,"Server");
        }
        if("tempVeh" in state[player.ID] && state[player.ID].tempVeh != null){
            state[player.ID].tempVeh.Delete();
        }

        // A viewer leaving mid mission takes his own actors, objects and room with him; other viewers
        // have their own sets, so this must never be a blanket KickAllNPC(). Main owns all of it.
        stopMission(player);
    }
    if(freecam.rawin(player.ID)) freecam.rawset(player.ID, null);
    saveDB(player);
}
function onPlayerKill( killer, player, reason, bodypart )
{
    // 閸戠粯娼冮崗顒€鎲￠敍姘矌閸︺劌鍤弶鈧棃鐐叉倱闂冪喓甯虹€硅埖妞傜憴锕€褰傞敍鍫濇倱闂冪喎鍤弶鈧挧?onPlayerTeamKill閿?
    Message(GetTeamColor(killer) + killer.Name + "[#ffffff] killed " + GetTeamColor(player) + player.Name + "[#ffffff] (" + GetWeaponName( reason ) + ")" );
    state[player.ID].diepos=player.Pos;
    killer.GiveMoney(50);
    if(player.Cash>=50){
        player.GiveMoney(-50);
    }
}
function onPlayerTeamKill( killer, player, reason, bodypart )
{
    Message(GetTeamColor(killer) + killer.Name + "[#ff0000] team-killed " + GetTeamColor(player) + player.Name + "[#ffffff] (" + GetWeaponName( reason ) + ")" );
    state[player.ID].diepos=player.Pos;
    killer.GiveMoney(50);
    if(player.Cash>=50){
        player.GiveMoney(-50);
    }
}
function onPlayerDeath(player,reason){
	if(state[player.ID].mission != null){
		failMission(player, "died");
	}
	switch (reason)
	{
		case 44:
		{
			Message(GetTeamColor(player)+player.Name + "[#33cc99] fell from a great height");
			break;
		}
		case 41:
		{
			Message(GetTeamColor(player)+player.Name + "[#ffaa00] was blown to pieces");
			break;
		}
		case 43:
		{
			Message(GetTeamColor(player)+player.Name + "[#3366ff] drowned\n why in sea?");
			break;
		}
		case 39:
		{
			Message(GetTeamColor(player)+player.Name + "[#ff4400] died in a car crash");
			break;
		}
		case 70:
		{
			Message(GetTeamColor(player)+player.Name + "[#888888] committed suicided");
			break;
		}
	}
    if(reason!=43)
    {
        state[player.ID].diepos=player.Pos;
    }else{
        state[player.ID].diepos=player.Pos;
        state[player.ID].diepos.z=-114514;
    }
}
function onPlayerSpawn( player )
{
    if(state[player.ID].CDdiepos){
        if(state[player.ID].diepos!=null){
            player.Pos=state[player.ID].diepos;
        }
    }
    player.World=player.UniqueWorld;
    NewTimer("playerbh",3000,1,player.Name);
}
function onCheckpointEntered(player,checkpoint)
{
    local cp = state[player.ID].CP;
    if(cp == null || checkpoint.ID != cp.ID) return;

    cp.Remove();
    state[player.ID].CP = null;

    local m = missions[state[player.ID].mission];
    if(m != null) m.onCheckpoint(player);
}
function onClientScriptData(player)
{
    local typecode=Stream.ReadInt();
    if(typecode==0)
    {
        Stream.ReadInt();
        local hitplayer=FindPlayer(Stream.ReadInt());
        lastAttacker[hitplayer.ID] <- player.ID;
    }
}
function playerbh(Name)
{
    local ply=FindPlayer(Name);
    // do not drag anyone out of their own world while a mission is running in it
    if(ply != null && (!state.rawin(ply.ID) || state[ply.ID].mission == null)) ply.World=0;
}
function hitinfo(plyID,hitplyID)
{
    local ply=FindPlayer(plyID);
    local hitplayer=FindPlayer(hitplyID);
    if(hitplayer!=null)
    {
        Stream.StartWrite();
        Stream.WriteInt(0);
        Stream.WriteInt(hitplayer.Health.tointeger());
        Stream.WriteInt(hitplayer.Armour.tointeger());
        Stream.WriteString(hitplayer.Name);
        Stream.SendStream(ply);
    }
}

// typecode 1 to the client: show a full screen cutscene title card (sprite, hold ms, fade ms)
function SendCutsceneCard(player, file, hold, fade)
{
    Stream.StartWrite();
    Stream.WriteInt(1);
    Stream.WriteString(file);
    Stream.WriteInt(hold);
    Stream.WriteInt(fade);
    Stream.SendStream(player);
}

// typecode 2 to the client: start fading the title card now (the actors are on stage)
function SendCutsceneCardFade(player)
{
    Stream.StartWrite();
    Stream.WriteInt(2);
    Stream.SendStream(player);
}

// ==================== Mission system ====================

// Announce() only works when called from a function defined in this file, so nothing outside it calls
// Announce directly: texts are queued here and sent from missionTick (50 ms, invisible on screen).
function Msg(player, text)
{
    state[player.ID].msg = text;
}

// The only way to start a mission. It queues instead of starting on the spot because command handlers
// run on a deep stack, and the engine calls a mission's begin() makes (ConnectNPCEx, CreateObject)
// do not like that; missionTick picks it up one frame later.
function startMission(player, id)
{
    startQ.append([player.ID, id]);
}

function endMission(player, success)
{
    local id = state[player.ID].mission;
    if(id == null) return;

    state[player.ID].cleanCP = true;      // sceneClock removes it (shallow stack)
    state[player.ID].scene   = null;
    state[player.ID].mTick   = 0;
    state[player.ID].mission = null;

    if(success){
        Announce("Mission complete", player, 1);
        print("[MISSION] "+player.Name+" finish "+id);
    }else{
        Announce("Mission failed", player, 1);
    }
}

function failMission(player, reason)
{
    print("[MISSION] "+player.Name+" fail: "+reason);
    endMission(player, false);
}

function PlayScene(player, name)
{
    state[player.ID].scene = name;
    state[player.ID].mTick = 0;
}

// ==================== Free camera (authoring tool) ====================
// /free toggles it. WASD moves, arrows look, PageUp/PageDown goes up/down.
// The body is dragged along with the camera, so you never see yourself in frame,
// and /shot <n> records the camera position and where it points.

function freecamToggle(p)
{
    if(freecam.rawin(p.ID) && freecam[p.ID] != null){
        freecam.rawset(p.ID, null);
        p.RestoreCamera();
        p.Frozen = false;
        print("[CAM] free view off for "+p.Name);
    }else{
        freecam.rawset(p.ID, {
            pos = Vector(p.Pos.x, p.Pos.y, p.Pos.z),
            yaw = p.Angle * 0.0174533,
            pitch = 0.0,
            fwd = false, back = false, slideL = false, slideR = false,
            rise = false, sink = false,
            turnL = false, turnR = false, lookU = false, lookD = false,
            boost = false
        });
        p.Frozen = true;
        print("[CAM] free view on for "+p.Name+" - WASD move, arrows look, pgup/pgdn height, shift = fast");
    }
}

function freecamClock()
{
    foreach(id, c in freecam)
    {
        if(c == null) continue;
        local p = FindPlayer(id);
        if(p == null) continue;

        local step = c.boost ? 2.0 : 0.45;
        local turn = 0.035;

        if(c.turnL) c.yaw -= turn;
        if(c.turnR) c.yaw += turn;
        if(c.lookU) c.pitch += turn;
        if(c.lookD) c.pitch -= turn;
        if(c.pitch >  1.45) c.pitch =  1.45;
        if(c.pitch < -1.45) c.pitch = -1.45;

        local cp = cos(c.pitch), sp = sin(c.pitch);
        local sy = sin(c.yaw),   cy = cos(c.yaw);

        if(c.fwd)   { c.pos.x += cp*sy*step; c.pos.y += cp*cy*step; c.pos.z += sp*step; }
        if(c.back)  { c.pos.x -= cp*sy*step; c.pos.y -= cp*cy*step; c.pos.z -= sp*step; }
        if(c.slideL){ c.pos.x -= cy*step;    c.pos.y += sy*step; }
        if(c.slideR){ c.pos.x += cy*step;    c.pos.y -= sy*step; }
        if(c.rise) c.pos.z += step;
        if(c.sink) c.pos.z -= step;

        p.Pos = Vector(c.pos.x, c.pos.y, c.pos.z);
        p.SetCameraPos(c.pos, Vector(c.pos.x + cp*sy*10.0, c.pos.y + cp*cy*10.0, c.pos.z + sp*10.0));
    }
}

function onKeyDown(player, key)
{
    if(!freecam.rawin(player.ID)) return;
    local c = freecam[player.ID];
    if(c == null) return;
    if(key == keyW)           c.fwd = true;
    else if(key == keyS)      c.back = true;
    else if(key == keyA)      c.slideL = true;
    else if(key == keyD)      c.slideR = true;
    else if(key == keyPgUp)   c.rise = true;
    else if(key == keyPgDn)   c.sink = true;
    else if(key == keyUp)     c.lookU = true;
    else if(key == keyDown)   c.lookD = true;
    else if(key == left)      c.turnL = true;
    else if(key == right)     c.turnR = true;
    else if(key == keyShift)  c.boost = true;
}

function onKeyUp(player, key)
{
    if(!freecam.rawin(player.ID)) return;
    local c = freecam[player.ID];
    if(c == null) return;
    if(key == keyW)           c.fwd = false;
    else if(key == keyS)      c.back = false;
    else if(key == keyA)      c.slideL = false;
    else if(key == keyD)      c.slideR = false;
    else if(key == keyPgUp)   c.rise = false;
    else if(key == keyPgDn)   c.sink = false;
    else if(key == keyUp)     c.lookU = false;
    else if(key == keyDown)   c.lookD = false;
    else if(key == left)      c.turnL = false;
    else if(key == right)     c.turnR = false;
    else if(key == keyShift)  c.boost = false;
}

// ==================== Engine capability layer ====================
// A mission owns the *content* (camera work, subtitles, actors, objects, sound, flow). This layer owns
// the one thing a mission cannot do for itself: calling the engine.
//
// Why it has to exist: Sqrat resolves the overloaded engine functions (Announce, CreateObject,
// ConnectNPCEx, PlaySound ...) against the caller, and a call made from a mission file comes back as
// "No overload matching this argument list". Missions therefore go through the wrappers below and
// never call those engine functions directly.
//
// Subtitles are queued into state[id].msg and sent from missionTick: the queue costs one tick (50 ms),
// which is invisible on screen, and it beats betting on Announce working from a mission file.

startQ <- [];      // [playerID, missionName] waiting for the next tick (command handlers are too deep)

function camSet(p, cam, look)   { p.SetCameraPos(cam, look); }
function camFree(p)             { p.RestoreCamera(); }
function cineOn(p)              { p.Frozen = true;  p.Widescreen = true;  }
function cineOff(p)             { p.Frozen = false; p.Widescreen = false; }

// ---- what a mission asks for, and who actually does it ----
// MISSIONS DO NOT CALL THE ENGINE. They queue a request here; missionTick (the timer callback) then
// performs it one frame deep. Reason, measured in game: these overloaded engine functions only
// resolve from a shallow stack. CreateObject worked in the old code five frames down and comes back
// as "No overload matching this argument list" seven frames down; PlaySoundForPlayer works three
// frames down while PlaySound(world, sound, pos) failed outright. So the rule is depth, not file:
// the mission owns the content and the flow, Main owns the calls.
//
// Main also keeps the handles, so a mission never tracks its own objects and stopMission() deletes
// everything it asked for.

engQ <- [];

function qRoom(p, off)                 { engQ.append(["room",  p.ID, off]); }
function qObj(p, tag, model, pos, quat){ engQ.append(["obj",   p.ID, tag, model, pos, quat]); }
function qMove(p, tag, pos, ms)        { engQ.append(["move",  p.ID, tag, pos, ms]); }
function qRot(p, tag, quat)            { engQ.append(["rot",   p.ID, tag, quat]); }
// The npc script defaults to the shared actor script; an act can name its own (the driver replays a
// recording instead, see npcscripts/ken_driver.nut).
function qActor(p, nm, pos, angle, skin, pose, look) { engQ.append(["actor", p.ID, nm, pos, angle, skin, pose, look, null]); }
function qActorScript(p, nm, pos, angle, skin, pose, look, script) { engQ.append(["actor", p.ID, nm, pos, angle, skin, pose, look, script]); }
function qActorPos(p, nm, pos)         { engQ.append(["apos",  p.ID, nm, pos]); }
function qActorGone(p, nm)             { engQ.append(["agone", p.ID, nm]); }
function qCar(p, model, pos, angle, c1, c2) { engQ.append(["car",    p.ID, model, pos, angle, c1, c2]); }
function qCarPos(p, pos)               { engQ.append(["carpos", p.ID, pos]); }
function qPutIn(p, nm, slot)           { engQ.append(["putin",  p.ID, nm, slot]); }
function qWep(p, nm)                   { engQ.append(["wep",    p.ID, nm]); }
function qSound(p, id)                 { engQ.append(["sound", p.ID, id]); }
function qCard(p, file, hold, fade)    { engQ.append(["card",  p.ID, file, hold, fade]); }
function qCam(p, cam, look)            { engQ.append(["cam",   p.ID, cam, look]); }
function qBody(p, pos)                 { engQ.append(["body",  p.ID, pos]); }
function qAnim(p, group, id)           { engQ.append(["anim",  p.ID, group, id]); }
function qClear(p)                     { engQ.append(["clear", p.ID]); }
function qEnd(p)                       { engQ.append(["end",   p.ID]); }
function qProbe(p, cam, look)          { engQ.append(["probe", p.ID, cam, look]); }

// The performers. Only ever called from engRun(), i.e. one frame under the timer callback.
function objNew(model, wd, pos) { return CreateObject(model, wd, pos, 255); }
function objRot(o, quat)        { o.RotateTo(quat, 0); }
function objGone(o)             { o.Delete(); }

// Object.MoveTo is overloaded too and no reliable source documents its argument list: try the Vector
// form, then the numeric one, and if neither works say so ONCE - a mover that throws every tick would
// flood the log while the object simply stands still.
moverBad <- false;
vehBad   <- false;
wepTold  <- false;      // the weapon-clearing call only reports which shape works, once

// Actor names the engine has actually accepted into a vehicle. A mission must be able to tell whether a
// put-in has already happened, because RE-SENDING it makes the occupant climb out and get back in: that
// was a visible bug, and there is no reliable way to ask an NPC which seat he is in (Vehicle and
// VehicleSlot both read as nothing useful for an npc).
putInOk <- {};
function wasPutIn(nm) { return putInOk.rawin(nm); }

// ==================== /rec, /recstop: recording a real player's driving ====================
// Why these exist: the npc plugin can only replay a DRIVER recording that was made by a real player
// driving in game, so the route for the cutscene's car has to be recorded here, by hand (see
// _docs/KEN-DRIVE-NOTES.md and _docs/REC-API-EVIDENCE.md).
//
// THE API (settled, no more guessing). Two independent sources agree:
//  * _docs/_npc/rel006/.../npcscript functions.txt:312-313 (the plugin's own function list)
//      [bool]StartRecordingPlayerData( [integer] playerid, [integer] recordtype=3, [string]recordname="", [integer]flags=60 )
//      [bool]StopRecordingPlayerData( [integer] playerid )
//    and line 333 [bool/throwerror-invalid-playerid]IsPlayerRecording( [integer] playerid ).
//  * habi (the plugin author) posts the exact working gamemode code in his own tutorial
//    "[Tutorial: NPC] #2 Recording player actions":
//      s = StartRecordingPlayerData(player.ID, PLAYER_RECORDING_TYPE_ONFOOT, text);   // onfoot
//      s = StartRecordingPlayerData(player.ID, PLAYER_RECORDING_TYPE_DRIVER, text);   // in a car
//      s = StopRecordingPlayerData(player.ID);
//    (forum.vc-mp.org topic 8803, msg 52127; #3, topic 8806, adds "You must be in a vehicle when the
//    recording starts. The recording will not continue if you exit vehicle.")
// So: they are GLOBALS in the gamemode script (like ConnectNPC/IsPlayerNPC), the first argument is the
// numeric player id (player.ID), and the file name is a plain string WITHOUT ".rec".
//
// What the shipped binary confirms (plugins/npc04rel64.dll):
//  * functions present: StartRecordingPlayerData / StopRecordingPlayerData / IsPlayerRecording /
//    StartRecordingAllPlayerData / StopRecordingAllPlayerData / PutServerInRecordingMode /
//    StopServerInRecordingMode / IsServerInRecordingMode (strings near file offsets 0x3e6d0-0x3e770).
//  * it type-checks the id itself - "Error: plrid not provided", "Player not connected",
//    "Error getting ID of player instance" - then "The recname parameter must be string",
//    "The flags parameter must be integer", "The rectype parameter must be integer"; it validates the
//    type with "Error: recordtype must be %u, %u or %u" before "Error: Could not start recording for % u"
//    / "Success. Recording Started for player %u". These are the server-side argument checks.
//  * the CPlayer METHOD form does not exist: an earlier /rec attempt calling
//    player.StartRecordingPlayerData(...) failed with Squirrel's "Member Variable not found".
//
// Type / filter ids (docs lines 343-345, same on both sides):
//   PLAYER_RECORDING_TYPE_ONFOOT 1, PLAYER_RECORDING_TYPE_DRIVER 2, PLAYER_RECORDING_TYPE_ALL 3
//   REC_* filters: REC_ONFOOT_NORMAL 4 | REC_ONFOOT_AIM 8 | REC_VEHICLE_DRIVER 16 | REC_VEHICLE_PASSENGER 32
//   -> REC_STANDARD = 60 (the plugin's own default when flags is omitted).
recTypeDriver <- 2;                    // PLAYER_RECORDING_TYPE_DRIVER
recTypeAll    <- 3;                    // PLAYER_RECORDING_TYPE_ALL
recFilterStd  <- 60;                   // REC_STANDARD
recShape      <- "";                   // diagnostic: which call shape started the recording
recWho        <- null;                 // the player object /rec started a recording for
recName       <- "";                   // and its recording name
recCalls      <- 0;                    // diagnostic: how many calls were needed

// IsPlayerRecording(playerid) - global, integer id (docs line 333). Tried as the id form first, then the
// old method form purely so an unexpected registration still gets reported instead of crashing /rec.
// Returns true/false, or null when neither shape exists.
function recIsOn(p)
{
    try { return (IsPlayerRecording(p.ID) == true); } catch(e) {}
    try { return (p.IsPlayerRecording() == true); } catch(e2) {}
    return null;
}

// ONE call, the documented one, with the documented argument types:
//   StartRecordingPlayerData( [integer] playerid, [integer] recordtype, [string] recordname, [integer] flags )
// p.ID is an integer (VC:MP Player member), the type id is an integer and the name is a string without
// ".rec". flags = 60 = REC_STANDARD, the plugin's own default, so the recording carries the standard
// onfoot/vehicle event set.
// Returns "ok" (started and IsPlayerRecording agrees), "unverifiable" (the call went through but this
// build answers nothing for IsPlayerRecording), "no-recording", or "threw".
function recStd(p, name, typeId)
{
    recCalls++;
    local err = "";
    try { StartRecordingPlayerData(p.ID, typeId, name, recFilterStd); }
    catch(e) {
        err = e;
        // ONE fallback, only for a genuinely different registration (a Player-instance method taking the
        // name first). It is NOT a guess at the argument order - that is settled above.
        try { p.StartRecordingPlayerData(name, typeId, recFilterStd); err = ""; }
        catch(e2) { err = err+" | fallback: "+e2; }
    }
    if(err != ""){ print("[REC] rejected StartRecordingPlayerData(player.ID="+p.ID+", "+typeId+", \""+name+"\", "+recFilterStd+"): "+err); return "threw"; }
    local on = recIsOn(p);
    if(on == true)  return "ok";
    if(on == null)  return "unverifiable";     // the call went through but IsPlayerRecording is missing
    return "no-recording";
}

// StopRecordingPlayerData(playerid) - global, integer id. Returns a one-line report for player and log.
function recStop(p)
{
    local errors = "";
    try { StopRecordingPlayerData(p.ID); return "stop via StopRecordingPlayerData("+p.ID+")"; }
    catch(e) { errors += e+" / "; }
    try { p.StopRecordingPlayerData(); return "stop via player.StopRecordingPlayerData()"; }
    catch(e2) { errors += e2; }
    return "STOP FAILED: "+errors;
}
function objMove(o, pos, ms)
{
    if(moverBad) return;
    try { o.MoveTo(pos, ms); return; } catch(e) {}
    try { o.MoveTo(pos.x, pos.y, pos.z, ms); return; } catch(e2) {
        moverBad = true;
        print("[MOV] Object.MoveTo rejected both argument lists: " + e2);
    }
}

// Actors (NPCs). Never put a '#' in the name: VC-MP rewrites it to '_' and FindPlayer never matches.
// lookAt is optional - when given, the actor turns to face that point.
// The pose may carry a silence time ("stand@14.0"): the actor stops sending state that many seconds after
// spawn, which is what lets the server seat him and keep him seated. See npcscripts/sonny_actor.nut.
//
// The LAST vararg is the engine's id of the car this act uses, or -1 when there is none. It travels as a
// plain string because ConnectNPCEx's trailing arguments are what the npc client forwards to its own
// script: npcclient is started with -w "<arg> ..." and SquirrelVM.cpp::call_OnNPCScriptLoad turns those
// into the 0-based array the script sees. So pose = params[0], the three look-at values = params[1..3]
// and this id = params[4] - which is the slot npcscripts/ken_driver.nut reads for its one-shot
// EnterVehicle() test. No script is obliged to look at it (every other npc script ignores it).
function actorNew(nm, pos, angle, skin, pose, lookAt, script, vehId)
{
    local sc = (script != null) ? script : "sonny_actor.nut";
    local vs = (vehId == null) ? "-1" : vehId.tostring();
    if(lookAt != null)
        ConnectNPCEx(nm, pos, angle, skin, 19, 0, sc, false, "", "",
                     pose, lookAt.x.tostring(), lookAt.y.tostring(), lookAt.z.tostring(), vs);
    else
        ConnectNPCEx(nm, pos, angle, skin, 19, 0, sc, false, "", "",
                     pose, "0", "0", "0", vs);
}

// Sound, PER PLAYER and not by world. Every viewer watches a mission in his own world, so there is
// nobody else it could be meant for, and PlaySoundForPlayer is the form this build accepts - the
// world + position form that used to sit here came back as "No overload matching this argument list"
// in 0.4 rel006. (The world form is PlaySoundForWorld(world, sound): two arguments, no position.)
function sndPlay(p, id) { PlaySoundForPlayer(p, id); }

// Drains the queue. Every engine call in here sits one frame under missionTick.
function engRun()
{
    while(engQ.len() > 0)
    {
        local e = engQ.remove(0);
        if(!state.rawin(e[1])) continue;
        local st = state[e[1]];
        local p  = FindPlayer(e[1]);
        if(p == null) continue;
        local wd = st.missionWorld;
        local k  = e[0];

        if(k == "room"){
            st.missionRoom = roomBuild(e[2], wd);
        }else if(k == "obj"){
            local o = objNew(e[3], wd, e[4]);
            if(e[5] != null) objRot(o, e[5]);
            st.missionObjs.rawset(e[2], o);
        }else if(k == "move"){
            if(st.missionObjs.rawin(e[2])) objMove(st.missionObjs[e[2]], e[3], e[4]);
        }else if(k == "rot"){
            if(st.missionObjs.rawin(e[2])) objRot(st.missionObjs[e[2]], e[3]);
        }else if(k == "actor"){
            st.missionActors.append(e[2]);
            // The car this act queued, for the actor scripts that may try to get in by themselves (the npc
            // side calls EnterVehicle with it - see actorNew). Read here and not handed in by the mission:
            // the "car" queue entry is what creates the vehicle, and a mission must not have to know an
            // engine id. -1 means "this act has no car", which the npc script reads as "nothing to try".
            local vehId = -1;
            if(st.missionVeh != null){
                try { vehId = st.missionVeh.ID; }
                catch(e0) { vehId = -1; print("[CAR] Vehicle.ID unreadable for "+e[2]+": "+e0); }
            }
            actorNew(e[2], e[3], e[4], e[5], e[6], e[7], e[8], vehId);
        }else if(k == "apos"){
            local np = FindPlayer(e[2]);
            if(np != null) np.Pos = e[3];
        }else if(k == "agone"){
            local np = FindPlayer(e[2]);
            if(np != null) np.Kick();
        }else if(k == "car"){
            // a REAL vehicle, not a custom object: the game's own vehicle models are handled natively
            // (no RenderWare version question, no burying, no reliance on Object.MoveTo). Note the
            // heading is in RADIANS here, unlike Player.Angle.
            st.missionVeh = CreateVehicle(e[2], wd, e[3].x, e[3].y, e[3].z, e[4], e[5], e[6]);
        }else if(k == "carpos"){
            if(st.missionVeh != null){
                try { st.missionVeh.Pos = e[2]; }
                catch(e3) { if(!vehBad){ vehBad = true; print("[CAR] Vehicle.Pos is not writable: "+e3); } }
            }
        }else if(k == "putin"){
            // PutInVehicleSlot is a METHOD, not a global: calling it as a global comes back as
            // "the index 'PutInVehicleSlot' does not exist". Which class owns it is not documented, so
            // both are tried and whichever worked is what gets reported.
            local np = FindPlayer(e[2]);
            if(np != null && st.missionVeh != null){
                local done = false;
                try { np.PutInVehicleSlot(st.missionVeh, e[3]); done = true; }
                catch(e4) {
                    try { st.missionVeh.PutInVehicleSlot(np, e[3]); done = true; }
                    catch(e5) { print("[CAR] PutInVehicleSlot rejected on both Player and Vehicle: "+e4+" / "+e5); }
                }
                if(done){
                    putInOk.rawset(e[2], true);   // never re-sent: a second call makes him climb out again
                    // Report what the engine made of it: the seat asked for and the seat it reports are
                    // not always the same number, and a second actor landing in the same seat is one
                    // that would look like he never got in at all.
                    local got = "?";
                    try { got = np.VehicleSlot.tostring(); } catch(e6) { got = "unreadable"; }
                    local inv = "?";
                    try { inv = (np.Vehicle != null) ? "yes" : "no"; } catch(e7) { inv = "unreadable"; }
                    print("[CAR] "+e[2]+" -> asked seat "+e[3]+", VehicleSlot="+got+", inVehicle="+inv);
                }
            }
        }else if(k == "wep"){
            // Empty hands, from the server. The spawn class gives every actor a shotgun and the npc side
            // normally empties them itself (sonny_actor.nut Fists), but an actor who is put into a car
            // stops talking on purpose - otherwise his on-foot packet pulls him back out of the seat - so
            // nothing ever clears it and Ken drives with the shotgun on his lap. Which weapon call this
            // build accepts is not documented, so all the shapes are tried and the one that works is
            // printed once.
            local np = FindPlayer(e[2]);
            if(np != null){
                if(!wepTold){
                    try { np.SetWeapon(0, 0);  print("[CAR] "+e[2]+" weapon cleared via Player.SetWeapon"); wepTold = true; }
                    catch(e8) {
                        try { SetWeapon(np, 0, 0);  print("[CAR] "+e[2]+" weapon cleared via SetWeapon"); wepTold = true; }
                        catch(e9) {
                            try { np.RemoveWeapon(0); print("[CAR] "+e[2]+" weapon cleared via Player.RemoveWeapon"); wepTold = true; }
                            catch(e10) {
                                try { RemoveWeapon(np, 0); print("[CAR] "+e[2]+" weapon cleared via RemoveWeapon"); wepTold = true; }
                                catch(e11){ print("[CAR] no weapon call worked for "+e[2]+": "+e11); wepTold = true; }
                            }
                        }
                    }
                }else{
                    // already know which shape works: same chain, silently
                    try { np.SetWeapon(0, 0); }
                    catch(e12){ try { SetWeapon(np, 0, 0); } catch(e13){ try { np.RemoveWeapon(0); } catch(e14){ try { RemoveWeapon(np, 0); } catch(e15){} } } }
                }
            }
        }else if(k == "sound"){
            sndPlay(p, e[2]);
        }else if(k == "card"){
            SendCutsceneCard(p, e[2], e[3], e[4]);
        }else if(k == "cam"){
            camSet(p, e[2], e[3]);
        }else if(k == "body"){
            p.Pos = e[2];
        }else if(k == "anim"){
            foreach(n in st.missionActors){
                local np = FindPlayer(n);
                if(np != null) np.SetAnim(e[2], e[3]);
            }
        }else if(k == "clear"){
            missionClearEngine(st);
        }else if(k == "end"){
            stopMission(p);
        }else if(k == "probe"){
            // TEMPORARY placement probe (see mission_intro_tick). Wrapped because Object.Pos and
            // Player.Pos are the two things here that could be missing, and an error in engRun would
            // not be caught by the tick's own handler.
            try {
                print("[PROBE] "+p.Name+" cam "+fmtPos(e[2])+" aim "+fmtPos(e[3])+" world "+p.World);
                foreach(n in st.missionActors){
                    local np = FindPlayer(n);
                    if(np != null) print("[PROBE] npc "+n+" at "+fmtPos(np.Pos));
                }
                foreach(tag, o in st.missionObjs) print("[PROBE] obj "+tag+" at "+fmtPos(o.Pos));
            } catch(e2) {
                print("[PROBE] failed: "+e2);
            }
        }
    }
}

function fmtPos(v) { return format("%.2f,%.2f,%.2f", v.x, v.y, v.z); }

// Everything the engine built for a player's mission: his actors, his objects, his copy of the room.
// Main owns all of it, which is why a mission never even sees a handle.
function missionClearEngine(st)
{
    foreach(n in st.missionActors){
        local np = FindPlayer(n);
        if(np != null) np.Kick();
    }
    st.missionActors = [];
    foreach(tag, o in st.missionObjs) objGone(o);
    st.missionObjs = {};
    if(st.missionRoom != null){
        foreach(o in st.missionRoom) objGone(o);
        st.missionRoom = null;
    }
    if(st.missionVeh != null){
        st.missionVeh.Delete();
        st.missionVeh = null;
    }
}

// The one thing /m may pass to a mission besides its name: which act to open with. It is a ROOT
// variable (not a mission API) so Main still knows nothing about any mission's internals - it only
// sets a number here; a mission that cares reads it once inside its own begin() and clears it.
// Name is prefixed `mission` to keep it out of the way of the engine's own globals; the only writer
// is the /m handler and the only reader is mission_intro_begin (scripts/missions/intro.nut).
// Do not index this with [] when it may be absent: that throws, see the rawget note below.
missionStartAct <- null;

// ==================== missionTick, 50 ms ====================
// A mission is a set of plain global functions named mission_<name>_begin / _tick / _stop. They are
// looked up on the ROOT table and never through a table member: a mission must not be called as
// table.member(..), which is another way the engine's overloaded calls stop resolving.
//
// Everything a mission asks the engine to do goes through engQ and is performed here, at the top of
// the stack (see the note above engQ). Order per tick:
//   1) release the queued start requests
//   2) send the queued subtitles
//   3) tick whatever mission that player is running
//   4) perform the engine work the missions queued
function missionTick()
{
    while(startQ.len() > 0){
        local q = startQ.remove(0);
        local p = FindPlayer(q[0]);
        if(p == null) continue;
        // rawget, not []: indexing the root table for a name that is not there THROWS, so a mistyped
        // mission name used to kill the tick outright - which is exactly what "/m ken_01_an_old_friend"
        // did after that mission was renamed to `intro` ("AN ERROR HAS OCCURED [the index
        // 'mission_ken_01_an_old_friend_begin' does not exist]"). A wrong name should do nothing.
        local begin = getroottable().rawget("mission_"+q[1]+"_begin");
        if(begin == null) continue;
        state[p.ID].mission = q[1];
        state[p.ID].scene   = null;
        state[p.ID].mTick   = 0;
        local wd = 0;
        try { wd = p.World; } catch(e) { wd = 0; }
        state[p.ID].missionWorld = wd;
        cineOn(p);                       // frozen + widescreen: the mission is a film, not gameplay
        // A begin() that says false refused to start (mission_intro_begin does that for an act number
        // that is out of range): put the film back and take the name off him. The mission has already
        // reported why, and it did not set up any of its own state, so there is nothing to stop.
        local ok = true;
        try { ok = begin(p); } catch(e) { ok = false; print("[MISSION] "+q[1]+" begin failed: "+e); }
        // Whatever happened the pending act is used up; never carry it into the next start.
        getroottable().rawdelete("missionStartAct");
        if(ok == false){
            state[p.ID].mission = null;
            cineOff(p);
            p.World = wd;
            print("[MISSION] "+p.Name+" start "+q[1]+" refused");
            continue;
        }
        print("[MISSION] "+p.Name+" start "+q[1]);
    }

    foreach(id, st in state)
    {
        local p = FindPlayer(id);
        if(p == null) continue;

        if(st.msg != null){ Announce(st.msg, p, 1); st.msg = null; }

        if(st.mission == null) continue;

        // Keep the actors in the viewer's world - their own npcclient process stays in world 0, on the
        // world 0 copy of the room, which is what keeps them standing.
        // NEVER for an actor who is in a vehicle: assigning World re-instances the ped, and that is what
        // pulled the seated men out again (the log: Ken was in seat 0 at 2.5 s and back on the pavement by
        // 24 s) and what made them flicker - the client keeps reporting world 0, so this line wrote the
        // world again on nearly every tick.
        foreach(n in st.missionActors){
            local np = FindPlayer(n);
            if(np == null) continue;
            local vs = -1;
            try { vs = np.VehicleSlot; } catch(e) { vs = -1; }
            if(vs < 0 && np.World != st.missionWorld) np.World = st.missionWorld;
        }

        local tick = getroottable()["mission_"+st.mission+"_tick"];
        if(tick == null) continue;
        // A tick that throws would fire again 50 ms later, flood the log and quietly leave the player
        // stuck in a scene that never advances. Report it once and stop that mission cleanly.
        try { tick(p); }
        catch(e){
            print("[MISSION] "+st.mission+" tick failed, stopping it: "+e);
            stopMission(p);
        }
    }

    engRun();
}

// Main owns the engine side of a mission: its room, its objects, its actors, the camera, the world the
// player was moved to and the position to put him back at. The mission clears its own bookkeeping in
// mission_<name>_stop, which runs at the end of this.
function stopMission(player)
{
    if(player == null || !(player.ID in state)) return;
    local st = state[player.ID];

    missionClearEngine(st);

    camFree(player);
    cineOff(player);
    player.World = 0;                                  // the mission ran in his own world (see /home)
    if(st.missionKeepPos != null) player.Pos = st.missionKeepPos;
    st.missionKeepPos = null;

    local name = st.mission;
    if(name != null){
        local stop = getroottable()["mission_"+name+"_stop"];
        if(stop != null) try { stop(player); } catch(e) {}
    }
    st.mission = null;
}
// TEMPORARY diagnostic for /depthtest. Adds one script frame per level and tries two engine calls of
// different arity there, which separates the two candidate explanations:
//   * if BOTH start failing at the same depth, it is purely the depth (a plain limit);
//   * if the 4 argument call fails earlier than the 2 argument one, it is stack pressure - the
//     overload matcher needs room for its own temporaries, and a deeper stack leaves it less.
// Called straight from the command handler: at level 1 the calls sit 3 script frames down
// (command dispatcher -> onPlayerCommand -> depthProbe -> engine).
function depthProbe(level, player)
{
    local a = true, b = true;
    try { local o = CreateObject(318, 0, Vector(0.0, 0.0, 3.0), 255); o.Delete(); } catch(e) { a = false; }
    try { PlaySoundForPlayer(player, 50000); } catch(e) { b = false; }
    print("[DEPTH] level " + level + " (" + (level + 2) + " frames): CreateObject(4) " +
          (a ? "OK" : "FAIL") + ", PlaySoundForPlayer(2) " + (b ? "OK" : "FAIL"));
    if(level < 12) depthProbe(level + 1, player);
}

function sceneClock()
{
    foreach(id, st in state)
    {
        local p = FindPlayer(id);
        if(p == null) continue;

        // engine calls must happen here (timer callback = shallow stack)
        if(st.cleanCP == true){
            if(st.CP != null){ st.CP.Remove(); st.CP = null; }
            st.cleanCP = false;
        }
        if(st.msg != null){
            Announce(st.msg, p, 1);
            st.msg = null;
        }

        if(st.scene == null) continue;

        local m = missions[st.mission];
        if(m == null || !m.rawin("scenes")) continue;

        state[id].mTick++;
        m.scenes[st.scene](p, state[id].mTick);
    }
}