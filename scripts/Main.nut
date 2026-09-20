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
state <-{};
local notcar=["155","177","162","160"];
local teamColor = ["red", "blue", "green", "yellow","white", "black" ];
local tcR=[255,0,0,255,255,0];
local tcG=[0,0,255,255,255,0];
local tcB=[0,255,0,0,255,0];
local wepammo= [10,10,10,10,10,100,49,100,20,70,500,600,500,350,300,300,10,10,10,100,20,10];
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
    // 只在此处加载静态车辆：onServerStart 仅服务器启动时执行一次，
    // 脚本重载（/reload）只会重跑 onScriptLoad，不会重复刷车
    print("[Main] onServerStart: loading static vehicles...");
    try {
        dofile("./scripts/Vehicles.nut");
        LoadVehicles();
        print("[Main] static vehicles loaded OK");
    } catch (e) {
        print("[Main] ERROR loading Vehicles.nut: " + e);
    }
    dofile("./scripts/Database.nut");
    loadDB();
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
    AddClass(0,RGB(255,0,0),11,Vector(-490.468,-421.897,11.4417),140.020,19,100,26,300,22,500);
    AddClass(1,RGB(0,0,255),0,Vector(-378.704,-581.025,25.3215),140.020,20,14,25,150,26,500);
    AddClass(2,RGB(0,255,0),16,Vector(-576.806,-447.04,14.9894),140.020,19,80,24,500,26,300);
    AddClass(4,RGB(255,255,255),116,Vector(-103.62,-1604.24,9.2732),140.020,21,70,23,500,27,300);
    // 加载管理员 JSON：onScriptLoad 在启动和每次 /reload 时都执行，
    // 手动改 admins.json 后 /reload 即可生效（无需重启服务器）
    try {
        dofile("./scripts/AdminJson.nut");
        LoadAdmins();
    } catch (e) {
        print("[Main] ERROR loading AdminJson.nut: " + e);
    }
    // reload 后 state 表被重置，但 onPlayerJoin 不会为已在线的玩家重跑，
    // 这里为所有在线玩家重建 state，避免 onPlayerDeath/onPlayerSpawn 等访问 state[player.ID] 报错
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
    Announce("Welcome ~r~ to  this ~p~ beta ~t~ server ~y~ have fun!", player, 1);
    player.Colour=RGB(tcR[player.Team],tcG[player.Team],tcB[player.Team]);
    if(!(player.ID in state)){
        state[player.ID]<-{};
    }
    state[player.ID].AdminLevel<-0;
    state[player.ID].CDdiepos<-false;
    state[player.ID].diepos<-{};
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
        MessagePlayer("Pos:"+player.Pos,player);
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
        // 重载前清理所有玩家 /car 临时车：ReloadScripts 会重置脚本状态（state 表清空），
        // 不先删掉的话这些车会变成"孤儿"残留在地图上，之后无法再被脚本删除，只能人工打爆
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
            MessagePlayer("[#00ff00]diepos [on]",player);
            state[player.ID].CDdiepos=true;
        }else if(text=="off"){
            MessagePlayer("[#00ff00]diepos [off]",player);
            state[player.ID].CDdiepos=false;
        }else{
            MessagePlayer("[#ff0000]Please type /diepos on/off to set diepos",player);
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
    // 玩家 /car 车（在 state 中登记的）删除；静态车不删（引擎原地重生）。
    // 按 state 判断，不受引擎复用被销毁车辆 ID 的影响。
    foreach (pid, st in state) {
        if ("tempVeh" in st && st.tempVeh != null && st.tempVeh.ID == vehicle.ID) {
            st.tempVeh = null;
            vehicle.Delete();
            return;
        }
    }
}
function onPlayerChat( player, message )
{
    print(player.Name+":"+message);
    if(state[player.ID].AdminLevel>=1){
        local plytc=GetTeamColor(player)
        Message("[#81d8CF][Admin]"+plytc+player.Name+"[#ffffff]:"+message);
    }else{
        local plytc=GetTeamColor(player)
        Message(plytc+player.Name+"[#ffffff]:"+message);
 }
}
function onPlayerPart(player,reason){
    if(player.ID in state){
        if("tempVeh" in state[player.ID] && state[player.ID].tempVeh != null){
            state[player.ID].tempVeh.Delete();
        }
    }
    saveDB(player);
}
function onPlayerKill( killer, player, reason, bodypart )
{
    // 击杀公告：仅在击杀非同队玩家时触发（同队击杀走 onPlayerTeamKill）
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
        state[player.ID].diepos=null;
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
function onClientScriptData(player)
{
    local type=Stream.ReadInt();
    if(type==0)
    {
        local ply=FindPlayer(Stream.ReadInt());
        local hitplayer=FindPlayer(Stream.ReadInt());
        if(hitplayer!=null)
        {
            Message(ply.Name+" hit "+hitplayer.Name);
        }
    }
}
function playerbh(Name)
{
    local ply=FindPlayer(Name);
    if(ply) ply.World=0;
}