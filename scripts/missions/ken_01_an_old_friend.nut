// ==================== Ken 01: An Old Friend ====================
// coords: measure with /pos, edit these three lines

ken01_HOTEL_POS <- Vector(238.34, -1279.73, 11.0712);
ken01_CAM_POS   <- Vector(238.34, -1279.73, 15.0);
ken01_CAM_LOOK  <- Vector(238.34, -1279.73, 11.0);

function ken01_onStart(player)
{
    state[player.ID].msg = "Go to Ocean View Hotel";
    state[player.ID].CP = CreateCheckpoint(player, player.UniqueWorld, false, ken01_HOTEL_POS, ARGB(150, 255, 0, 255), 2);
}

function ken01_onCheckpoint(player)
{
    PlayScene(player, "phoneCall");
}

function ken01_onPlayerDeath(player)
{
    failMission(player, "died");
}

// cutscene: mission ticks (1 tick = 1 second)
function ken01_phoneCall(player, t)
{
    if(t == 1)
    {
        player.SetCameraPos(ken01_CAM_POS, ken01_CAM_LOOK);
        player.Widescreen   = true;
    }
    else if(t == 3)  state[player.ID].msg = "Sonny: So, how did the deal go?";
    else if(t == 7)  state[player.ID].msg = "Tommy: It went wrong, Sonny.";
    else if(t == 11) state[player.ID].msg = "Sonny: You screwed up.";
    else if(t == 15)
    {
        player.RestoreCamera();
        player.Widescreen   = false;
        PlayScene(player, null);
        endMission(player, true);
    }
}

missions.ken_01_an_old_friend <- {
    title         = "An Old Friend"
    next          = "ken_02_the_party"
    onStart       = ken01_onStart
    onCheckpoint  = ken01_onCheckpoint
    onPlayerDeath = ken01_onPlayerDeath
    scenes = {
        phoneCall = ken01_phoneCall
    }
}
