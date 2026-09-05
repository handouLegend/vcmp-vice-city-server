local db;
function kick(Name)
{
    local ply=FindPlayer(Name);
    if(ply!=null)
    {
        ply.Kick();
    }
}
function loadDB()
{
    db=ConnectSQL("serverDB.db");
    if(db!=null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (name TEXT PRIMARY KEY, UID TEXT, money INTEGER, wantedLevel INTEGER)");
    }else
    {
        print("[DB] ConnectSQL failed");
    }
}
function queryDB(player)
{
    local plyUID=player.UniqueID;
    local name=player.Name;
    local q=QuerySQL(db,"SELECT name, UID, money, wantedLevel FROM players");
    if(q==null)
    {
        print("[DB] query failed");
        return;
    }
    local found = false;
    while (GetSQLNextRow(q))
    {
        local rowName = GetSQLColumnData(q, 0);
        if (rowName == name)
        {
            local UID = GetSQLColumnData(q, 1);
            if (plyUID == UID)
            {
                player.Cash = GetSQLColumnData(q, 2);
                player.WantedLevel = GetSQLColumnData(q, 3);
            }
            else
            {
                MessagePlayer("This name is already registered to another player.",player);
                NewTimer("kick",3000,1,player.Name);
            }
            found = true;
            break;
        }
    }
    if (!found)
    {
        QuerySQL(db, "INSERT OR IGNORE INTO players (name, UID, money, wantedLevel) VALUES ('"+name+"', '"+plyUID+"', 0, 0)");
        player.Cash = 0;
        player.WantedLevel = 0;
        MessagePlayer("registered a new player :"+player.Name,player);
        print("[DB] registered " + name);
    }
    FreeSQLQuery(q);
}
function saveDB(player)
{
    local name=player.Name;
    local plyUID=player.UniqueID;
    QuerySQL(db,"INSERT OR REPLACE INTO players (name,UID,money,wantedLevel) VALUES ('"+name+"', '"+plyUID+"', " + player.Cash + ", " + player.WantedLevel + ")");
}
