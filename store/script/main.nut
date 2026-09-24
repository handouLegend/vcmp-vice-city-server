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
function Script::ScriptProcess()
{
    UI.events.scriptProcess();
    if(hitLabel !=null &&hitLabel.Alpha) hitLabel.Alpha -= 2;
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
        hitLabel.Text = "Hit " + hitEntity.Name;
        hitLabel.Alpha = 255;
    }
}
function Server::ServerData(Stream)
{
    local typecode=Stream.ReadInt();
    if(typecode == 0)
    {
        local pHeal=Stream.ReadInt();
        local pArm=Stream.ReadInt();
        local pnm=Stream.ReadString();
        hitLabel.Text=format("Hit %s, HP: %d / %d", pnm, pHeal, pArm);
    }
}