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
// The room's shell and floor are blocks the map tool built out of one model. They have to follow the
// same roomOffset as the scene: without them there is no floor at the replica and the actors - which
// are real clients with gravity - simply fall out of the sky.
function rp(x, y, z)
{
    if("roomOffset" in getroottable()) return Vector(x + roomOffset.x, y + roomOffset.y, z + roomOffset.z);
    return Vector(x, y, z);
}

// Every room object is created through here. While roomSink is an array the objects land in it, which
// is how a player's own copy of the room is remembered so it can be deleted when his scene ends.
roomSink <- null;
function mk(model, wd, pos)
{
    local o = CreateObject(model, wd, pos, 255);
    if(roomSink != null) roomSink.append(o);
    return o;
}

function objcrt(wd)
{
    mk(318,wd,rp(219.477,-1282.75,18.1755)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(218.232,-1287.21,18.1381)).RotateTo(Quaternion(0.704845,-0.0186311,-0.0202258,0.708828),0); 
    mk(318,wd,rp(214.731,-1289.2,19.5912)).RotateTo(Quaternion(-0.00802745,-0.00120627,0.692122,0.721735),0); 
    mk(318,wd,rp(218.166,-1289.55,18.1631)).RotateTo(Quaternion(0.708734,-0.0176814,-0.0211735,0.704936),0); 
    mk(318,wd,rp(222.246,-1289.52,18.1631)).RotateTo(Quaternion(0.490982,-0.517592,-0.505715,0.485065),0); 
    mk(318,wd,rp(218.04,-1291.52,18.1631)).RotateTo(Quaternion(0.708734,-0.0176814,-0.0211735,0.704936),0); 
    mk(318,wd,rp(214.829,-1295.67,19.4412)).RotateTo(Quaternion(0.0144896,-0.0148729,0.704436,0.709464),0); 
    mk(318,wd,rp(216.113,-1295.77,18.1631)).RotateTo(Quaternion(0.50542,-0.507204,-0.491998,0.49521),0); 
    mk(318,wd,rp(217.378,-1296.02,18.1631)).RotateTo(Quaternion(0.508077,-0.504833,-0.490596,0.496304),0); 
    mk(318,wd,rp(218.664,-1296.04,19.4037)).RotateTo(Quaternion(-0.00056442,0.00267906,0.704564,0.709636),0); 
    mk(318,wd,rp(221.903,-1292.76,19.4162)).RotateTo(Quaternion(-0.0410524,0.00391166,0.998983,-0.0182592),0); 
    mk(318,wd,rp(223.441,-1289.57,19.4037)).RotateTo(Quaternion(-0.000524171,0.00268723,0.69384,0.720124),0); 
    mk(318,wd,rp(224.907,-1285.94,19.4162)).RotateTo(Quaternion(-0.00442892,0.0097334,0.999877,0.0115138),0); 
    mk(318,wd,rp(221.74,-1282.63,19.4162)).RotateTo(Quaternion(-0.0100407,0.00367962,0.710179,-0.703939),0); 
    mk(318,wd,rp(220.672,-1282.68,18.1755)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(218.058,-1282.4,19.4162)).RotateTo(Quaternion(-0.00473683,0.00894749,0.708367,-0.705772),0); 
    mk(318,wd,rp(216.385,-1285.8,20.2161)).RotateTo(Quaternion(-0.723532,-0.00212275,0.690273,0.00454486),0); 
    mk(318,wd,rp(218.073,-1298.97,19.4162)).RotateTo(Quaternion(-0.0410524,0.00391166,0.998983,-0.0182592),0); 
    mk(318,wd,rp(219.477,-1282.75,21.3754)).RotateTo(Quaternion(0.515351,0.483811,0.483924,0.515905),0); 
    mk(318,wd,rp(219.868,-1279.52,19.4662)).RotateTo(Quaternion(-0.999399,0.0322933,0.0021453,0.0124026),0); 
}
state <-{};
missions <- {};
cutscenes <- {};
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
    SetGameModeName("VCS20TH");
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
    NewTimer("cutTick", 50, 0);
    NewTimer("freecamClock", 10, 0);
    dofile("./scripts/missions/ken_01_an_old_friend.nut");
    // The cutscene room, rebuilt as our own objects somewhere the game treats as open air. Inside
    // the hotel interior the room inherits its loud ambience, and VC culls the interior's own
    // objects the moment the player counts as being outside it - so the scene has to move out, and
    // the scenery has to be ours. Loaded before the scene, which applies roomOffset to its cast.
    dofile("./scripts/room_replica.nut");
    roomReplica(roomOffset, 0);
    dofile("./scripts/scenes/sonny_office.nut");
    objcrt(0);
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
    state[player.ID].cut<-null;
    state[player.ID].cutShot<-0;
    state[player.ID].keepPos<-null;
    state[player.ID].shotHold<-0;
    state[player.ID].shotFrames<-1;
    state[player.ID].subIdx<-0;
    state[player.ID].cutT<-0.0;
    // has to be created here with <-: this state table is a plain {} and `=` cannot add a slot
    state[player.ID].cutStart<-0;
    state[player.ID].cutWorld<-0;         // world the scene is being played in (the player's own)
    state[player.ID].cutRoom<-null;       // room objects built for this player, deleted on end
    state[player.ID].cutActors<-null;     // names of this player's own actors, kicked on end
    state[player.ID].wantCut<-false;      // /home asked for the scene (see cutTick)
    state[player.ID].cutCaption<-false;   // opening title card already shown?
    state[player.ID].cutAudio<-false;     // cutscene audio already started?
    state[player.ID].cutWaiting<-false;   // pre-roll still waiting for the actors to exist?
    state[player.ID].preTick<-0;          // last re-trigger of the pre-roll sound hold
    state[player.ID].shotStart<-0.0;
    state[player.ID].shotLen<-1.0;
    state[player.ID].camA<-null;
    state[player.ID].camB<-null;
    state[player.ID].lookA<-null;
    state[player.ID].lookB<-null;
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
        startMission(player, "ken_01_an_old_friend");
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
        ClientMessage("available commands: /heal, /arm, /money, /skin, /weapon, /att, /team, /help", player, 0, 255, 0);
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
        if(!text)
        {
            MessagePlayer("[#ff0000]ERROR:type /goto/tp [playern Name/ID] to teleport to player",player);
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
        // Your own world, then the scene plays there with your own set of actors (see cutTick).
        // Detected by this flag, not by the world number: spawn protection already parks players in
        // their UniqueWorld for three seconds, so the world alone cannot mean "wants a cutscene".
        state[player.ID].wantCut = true;
        player.World = player.UniqueWorld;
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
    if(player.ID in state)
    {
        if(state[player.ID].evade)
        {
            addbanDB(player,"Evade Death",30,"Server");
        }
        if(player.ID in state){
            if("tempVeh" in state[player.ID] && state[player.ID].tempVeh != null){
                state[player.ID].tempVeh.Delete();
            }
        }
    }
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
function onPlayerPart(player, reason)
{
    if(freecam.rawin(player.ID)) freecam.rawset(player.ID, null);
    // if a cutscene was running, its actors would stay on stage forever
    if(state.rawin(player.ID) && state[player.ID].cut != null){
        state[player.ID].cut = null;
        print("[CUT] "+player.Name+" left during a cutscene, clearing the actors");
        KickAllNPC();
    }
}
function playerbh(Name)
{
    local ply=FindPlayer(Name);
    // do not drag anyone out of their own world while a scene is running in it
    if(ply != null && (!state.rawin(ply.ID) || state[ply.ID].cut == null)) ply.World=0;
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

// Announce() only works when called from a function defined in this file.
// Calls made from inside a mission table fail with "No overload matching".
function Msg(player, text)
{
    Announce(text, player, 1);
}

function startMission(player, id)
{
    if(!missions.rawin(id)) return;

    state[player.ID].mission = id;
    state[player.ID].scene   = null;
    state[player.ID].mTick   = 0;

    missions[id].onStart(player);
    print("[MISSION] "+player.Name+" start "+id);
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

// ==================== Cutscene player ====================
// A cutscene is a table with a shots array:
//   shots = [ { cam = Vector, look = Vector, dur = seconds, text = subtitle } ]
// The player is put on the camera position so his own body never shows up in frame.
// Engine calls live here and in sceneClock, never inside a cutscene callback table.

function PlayCutscene(player, name)
{
    if(!cutscenes.rawin(name)) return;

    state[player.ID].cut     = name;
    state[player.ID].cutShot = -1;
    state[player.ID].mTick   = 0;
    state[player.ID].keepPos = player.Pos;
    state[player.ID].subIdx  = 0;
    state[player.ID].cutT    = 0.0;
    // Master clock for the scene. The 50ms timer is only a refresh rate, never the timebase:
    // accumulating 0.05 per tick made the whole scene run slow whenever the timer fired late,
    // which left the subtitles trailing behind the cutscene audio and the shots stretched.
    // A scene may ask for a pre-roll ("delay", seconds). It is done by pushing the start stamp
    // into the future: cutT clamps at zero, so shot 1 is held still while the title card is up
    // and the room and the actors finish streaming in, and the audio starts exactly when the
    // clock does (see cutTick). The original hides that moment behind a black fade; VC-MP has
    // no screen fade, so this is the server side equivalent.
    local c   = cutscenes[name];
    local pre = c.rawin("delay") ? (c.delay * 1000).tointeger() : 0;
    state[player.ID].cutStart   = GetTickCount() + pre;
    state[player.ID].cutCaption = false;
    state[player.ID].cutAudio   = false;
    // A scene with a "wait" list (actor names) holds the pre-roll until every actor really
    // exists. The npcclient processes take seconds to spawn, so a fixed hold either shows the
    // pop-in or wastes time. The client keeps the card up to waitMax and we tell it when to fade
    // (typecode 2), so the card, the first frame of the scene and the audio start together.
    state[player.ID].cutWaiting = c.rawin("wait");
    state[player.ID].shotStart = 0.0;
    state[player.ID].shotLen   = 1.0;
    state[player.ID].camA = null; state[player.ID].camB = null;
    state[player.ID].lookA = null; state[player.ID].lookB = null;

    player.Frozen     = true;
    player.Widescreen = true;

    // Keep the game's sound channel busy for the whole pre-roll with a silent sound. VC starts an
    // interior's ambience only when nothing else is streaming as the room loads: with a silent gap
    // there the hotel music starts and then can never be stopped or masked, which is exactly what
    // happened once the title card added a 5 second silent pre-roll.
    if(c.rawin("preAudio")) PlaySoundForPlayer(player, c.preAudio);
    state[player.ID].preTick = GetTickCount();

    // The scene plays in the player's own world (see /home), so give him his own copy of the room
    // there and remember the objects so they can be deleted when his scene ends. World 0 keeps its
    // permanent copy: that one is the floor the actors' own npcclient processes stand on.
    local wd = 0;
    try { wd = player.World; } catch(e) { wd = 0; }
    state[player.ID].cutWorld = wd;
    if("roomOffset" in getroottable()){
        roomSink = [];
        roomReplica(roomOffset, wd);
        objcrt(wd);
        state[player.ID].cutRoom = roomSink;
        roomSink = null;
    }

    c.onStart(player);

    // The original opens on a black title card and fades into the scene - the same card is what
    // hides the actors and the room streaming in. The client draws it (store/script/main.nut):
    // the sprite at "card", held "cardHold" ms with the scene clock frozen, then faded out over
    // "cardFade" ms while the scene and its audio start (delay = cardHold).
    if(c.rawin("card"))
        SendCutsceneCard(player, c.card,
                         c.rawin("wait") ? (c.rawin("waitMax") ? c.waitMax : 15000)
                                         : (c.rawin("cardHold") ? c.cardHold : 500),
                         c.rawin("cardFade") ? c.cardFade : 2000);
}

function endCutscene(player)
{
    local c = cutscenes[state[player.ID].cut];
    if(c != null && c.rawin("onEnd")) c.onEnd(player);

    // tear down this player's own room and his own actors; other viewers have their own sets
    if(state[player.ID].cutRoom != null){
        foreach(o in state[player.ID].cutRoom) o.Delete();
        state[player.ID].cutRoom = null;
    }
    if(state[player.ID].cutActors != null){
        foreach(n in state[player.ID].cutActors){
            local np = FindPlayer(n);
            if(np != null) np.Kick();
        }
        state[player.ID].cutActors = null;
    }

    player.RestoreCamera();
    player.Widescreen = false;
    player.Frozen     = false;
    player.World      = 0;      // the scene ran in his own world (see /home); back to the normal one
    if(state[player.ID].keepPos != null) player.Pos = state[player.ID].keepPos;

    state[player.ID].cut     = null;
    state[player.ID].cutShot = -1;
    state[player.ID].mTick   = 0;
    state[player.ID].keepPos = null;
    state[player.ID].camA = null; state[player.ID].camB = null;
    state[player.ID].lookA = null; state[player.ID].lookB = null;
}

// Cutscene runner on a 50ms clock: that is fine enough for shot cuts and for subtitles
// that follow the original recording second by second. Inside a shot the camera is a pure
// dolly: it moves from cam to cam2 while the aim direction stays locked.
function cutTick()
{
    foreach(id, st in state)
    {
        local p = FindPlayer(id);
        if(p == null) continue;

        if(st.cut == null){
            if(st.wantCut){
                st.wantCut = false;
                PlayCutscene(p, "sonny_office");   // plays in the player's own world (see /home)
            }
            continue;
        }

        local c = cutscenes[st.cut];
        if(c == null){ st.cut = null; continue; }

        // The actors are this player's own set, and they have to sit in his world or he cannot see
        // them. Their own npcclient processes keep running in world 0, on the world 0 copy of the
        // room, which is what keeps them standing.
        local wd = st.cutWorld;
        if(st.cutActors != null) foreach(n in st.cutActors){
            local np = FindPlayer(n);
            if(np != null && np.World != wd) np.World = wd;
        }

        // The start stamp can be missing if the script was reloaded while a scene was already
        // running (the old PlayCutscene never wrote it). Rebuild it instead of erroring every
        // tick; the scene then simply restarts from its first line.
        if(!st.rawin("cutStart")){
            st.cutStart <- GetTickCount();   // newslot: `=` cannot create the slot
            st.cutT     = 0.0;
            st.subIdx   = 0;
            st.cutShot  = -1;
        }

        local dt = GetTickCount() - st.cutStart;
        if(dt < 0) dt = 0;                  // guard the 32 bit millisecond counter wrapping
        st.cutT = dt / 1000.0;

        // pre-roll: the title card goes up on the first frame, the audio starts when the clock
        // reaches zero. Both are data on the scene table, because Announce cannot be called
        // from inside a scene callback.
        if(!st.cutCaption){
            // text fallback for a scene that has no title card image
            if(!c.rawin("card") && c.rawin("caption")) Announce(c.caption, p, 3);
            st.cutCaption = true;
        }
        // wait for the actors before letting the scene run: everything stays frozen (cutT = 0)
        // until every name in the scene's "wait" list exists, but at least for "delay" and at
        // most for "waitMax" milliseconds. Then the card is told to fade and the clock is rebased
        // so the first frame of the scene, the fade and the audio all begin on the same tick.
        if(st.cutWaiting){
            local ready = true;
            foreach(n in c.wait) if(FindPlayer(n) == null){ ready = false; break; }
            local dpre   = c.rawin("delay") ? (c.delay * 1000).tointeger() : 0;
            local waited = GetTickCount() - (st.cutStart - dpre);
            local cap    = c.rawin("waitMax") ? c.waitMax : 15000;
            if((ready && GetTickCount() >= st.cutStart) || waited >= cap){
                print("[CUT] "+st.cut+": actors ready after "+waited+" ms, scene starts");
                st.cutStart   = GetTickCount();
                st.cutWaiting = false;
                SendCutsceneCardFade(p);
            }
            st.cutT = 0.0;
        }

        if(!st.cutAudio && !st.cutWaiting && GetTickCount() >= st.cutStart){
            // explicit world: the scene plays in the player's own one (verified working off world 0)
            if(c.rawin("audio")) PlaySound(wd, c.audio, p.Pos);
            st.cutAudio = true;
        }

        // keep holding the game's sound channel for the whole pre-roll, so the interior ambience
        // never gets its chance to start while the room loads. The hold sound is short silence, so
        // it is re-triggered; a longer silent file in store/sounds/ would make this unnecessary.
        if(c.rawin("preAudio") && GetTickCount() < st.cutStart){
            if(GetTickCount() - st.preTick >= 900){
                st.preTick = GetTickCount();
                PlaySoundForPlayer(p, c.preAudio);
            }
        }

        local acc = 0.0, idx = -1;
        for(local i = 0; i < c.shots.len(); ++i){
            local d = c.shots[i].dur.tofloat();
            if(st.cutT < acc + d){ idx = i; st.shotStart = acc; st.shotLen = d; break; }
            acc += d;
        }
        if(idx < 0){ endCutscene(p); continue; }

        if(idx != st.cutShot){
            st.cutShot = idx;
            local s = c.shots[idx];
            st.camA  = s.cam;
            st.lookA = s.look;
            if(s.rawin("cam2")) st.camB = s.cam2; else st.camB = s.cam;
        }

        local k = (st.cutT - st.shotStart) / st.shotLen;
        if(k > 1.0) k = 1.0;
        local cam = Vector(st.camA.x + (st.camB.x - st.camA.x)*k, st.camA.y + (st.camB.y - st.camA.y)*k, st.camA.z + (st.camB.z - st.camA.z)*k);
        local dx = st.lookA.x - st.camA.x, dy = st.lookA.y - st.camA.y, dz = st.lookA.z - st.camA.z;
        local look = Vector(cam.x + dx, cam.y + dy, cam.z + dz);

        // Where the invisible body is parked. It has to stay close enough for the room and the
        // actors to keep streaming (they vanish if we park far away), but where it sits also decides
        // which ambience the game picks: parked inside the hotel room, VC treats us as being in that
        // interior and plays the loud Audio/Hotel.mp3, which no server call can stop or mask.
        // A scene can push the body out of the interior volume with "bodyOffset"; the default keeps
        // it just behind and below the camera.
        local bo = c.rawin("bodyOffset") ? c.bodyOffset : Vector(0.0, 0.0, 0.0);
        p.Pos = Vector(cam.x + (cam.x - look.x)*0.5 + bo.x,
                       cam.y + (cam.y - look.y)*0.5 + bo.y,
                       cam.z - 2.0 + bo.z);
        p.SetCameraPos(cam, look);

        // subtitles have their own timeline, several lines can fall inside one shot
        if(c.rawin("subs")){
            while(st.subIdx < c.subs.len() && c.subs[st.subIdx].t <= st.cutT){
                Announce(c.subs[st.subIdx].text, p, 1);
                st.subIdx++;
            }
        }
    }
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