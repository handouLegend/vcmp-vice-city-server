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
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (UID TEXT, name TEXT, money INTEGER, wantedLevel INTEGER, PRIMARY KEY (UID, name))");
    }else
    {
        print("[DB] ConnectSQL failed");
    }
}
function queryDB(player)
{
    local plyUID=player.UniqueID;
    local name=player.Name;
    local q=QuerySQL(db,"SELECT UID, name, money, wantedLevel FROM players");
    if(q==null)
    {
        db=ConnectSQL("serverDB.db");
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (UID TEXT, name TEXT, money INTEGER, wantedLevel INTEGER, PRIMARY KEY (UID, name))");
        q=QuerySQL(db,"SELECT UID, name, money, wantedLevel FROM players");
    }
    if(q==null)
    {
        print("[DB] query failed");
        return;
    }
    local found = false;
    while (GetSQLNextRow(q))
    {
        if (GetSQLColumnData(q, 0) == plyUID && GetSQLColumnData(q, 1) == name)
        {
            player.Cash = GetSQLColumnData(q, 2);
            player.WantedLevel = GetSQLColumnData(q, 3);
            found = true;
            break;
        }
    }
    if (!found)
    {
        QuerySQL(db, "INSERT OR IGNORE INTO players (UID, name, money, wantedLevel) VALUES ('"+plyUID+"', '"+name+"', 0, 0)");
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
    QuerySQL(db,"INSERT OR REPLACE INTO players (UID, name, money, wantedLevel) VALUES ('"+plyUID+"', '"+name+"', " + player.Cash + ", " + player.WantedLevel + ")");
}
