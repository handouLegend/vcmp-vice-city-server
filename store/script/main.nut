function Player::PlayerShoot(player,weapon,hitEntity,hitPosition)
{
    local target=hitEntity;
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