seterrorhandler(function (e) {
    local a = getstackinfos(2);
    if (a) {
        local b = "";
        foreach (i, j in a.locals) b = b + "[" + i + "] " + j + "\n";
        local c = "";
        local d = 2;
        do {
            c += "*FUNCTION [" + a.func + "()] " + a.src + " line [" + a.line + "]\n";
            d++;
        } while ((a = getstackinfos(d)));
        Console.Print("AN ERROR HAS OCCURRED [" + e + "]\n\nCALLSTACK\n" + c + "\nLOCALS\n" + b);
    }
});
dofile("decui/decui.nut");
local hitLabel=null;

// ---- cutscene title card: the original's black card, then a fade into the scene ----
// These are file level locals, NOT `<-` slots. A client script is compiled into a Sqrat class, so
// `<-` would make them class members, and a plain function assigning to a class member throws
// "trying to set 'class'" (this is why hitLabel above is a local too).
local cutCardOn    = false;
local cutCardId    = "cutsceneCard";
local cutCardHold  = 0;      // ms fully opaque
local cutCardFade  = 0;      // ms to fade out
local cutCardShown = 0;      // Script.GetTicks() when it appeared

function cutCardShow(file, hold, fade)
{
    if(UI.Sprite(cutCardId) == null)
        UI.Sprite({ id = cutCardId, file = file, Size = GUI.GetScreenSize() });

    local sp = UI.Sprite(cutCardId);
    if(sp != null) sp.Alpha = 255;

    cutCardHold  = hold;
    cutCardFade  = fade;
    cutCardShown = Script.GetTicks();
    cutCardOn    = true;
}
function Script::ScriptProcess()
{
    UI.events.scriptProcess();
    if(hitLabel !=null &&hitLabel.Alpha) hitLabel.Alpha -= 2;

    // title card: hold it, then fade out against the real clock (Script.GetTicks is ms)
    if(cutCardOn)
    {
        local sp = UI.Sprite(cutCardId);
        if(sp == null){ cutCardOn = false; }
        else
        {
            local el = Script.GetTicks() - cutCardShown;
            local a  = 255;
            if(el > cutCardHold){
                a = cutCardFade > 0 ? 255 - (255 * (el - cutCardHold) / cutCardFade) : 0;
                if(a < 0) a = 0;
            }
            if(a <= 0){
                sp.destroy();
                cutCardOn = false;
            } else {
                sp.Alpha = a;
            }
        }
    }
}
function Script::ScriptLoad()
{
    hitLabel = UI.Label({
        id="hit"
        Text=""
        FontSize=30
        align="center"
        TextColour=Colour(255,255,255)
        Alpha=0
    });
    hitLabel.TextAlignment = GUI_ALIGN_LEFT;
}
function Player::PlayerShoot(player,weapon,hitEntity,hitPosition)
{
    local target=hitEntity;
    if(player.ID != World.FindLocalPlayer().ID) return;
    if(target==null) return;
    if(hitEntity.Type==OBJ_PLAYER)
    {
        local hit=Stream();
        hit.WriteInt(0);
        hit.WriteInt(player.ID);
        hit.WriteInt(target.ID); 
        Server.SendData(hit);
    }
}
function Server::ServerData(Stream)
{
    local typecode=Stream.ReadInt();
    if(typecode == 1)
    {
        // cutscene title card: sprite path, hold ms, fade ms
        local file = Stream.ReadString();
        local hold = Stream.ReadInt();
        local fade = Stream.ReadInt();
        cutCardShow(file, hold, fade);
        return;
    }
    if(typecode == 2)
    {
        // the server says the actors are on stage: start fading the card right now
        cutCardHold = Script.GetTicks() - cutCardShown;
        return;
    }
    if(typecode == 0)
    {
        local pHeal=Stream.ReadInt();
        local pArm=Stream.ReadInt();
        local pnm=Stream.ReadString();
        hitLabel.Text=format("Hit %s, HP: %d / %d", pnm, pHeal, pArm);
        hitLabel.Alpha=255;
    }
}