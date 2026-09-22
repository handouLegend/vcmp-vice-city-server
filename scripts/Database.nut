local db;
function bankick(ply,adminName,reason)
{
    if(ply!=null)
    {
        Message("[#ff0000][BAN] Player: "+ply+"has been banned by [#00ff00]"+adminName+"[#ff0000]. Reason: "+reason);
        ply.Kick(); 
    }
}
function loadDB()
{
    db=ConnectSQL("serverDB.db");
    if(db!=null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS ban (UID TEXT, UID2 TEXT, IP TEXT, Name TEXT, reason TEXT, admin TEXT, expire INTEGER, PRIMARY KEY (UID))");
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (UID TEXT, name TEXT, money INTEGER, wantedLevel INTEGER, PRIMARY KEY (UID, name))");
    }else
    {
        print("[DB] ConnectSQL failed");
    }
}
function loadbanDB()
{
    local q=QuerySQL(db,"SELECT IP, expire, strftime('%s','now') FROM ban");
    if(q==null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS ban (UID TEXT, UID2 TEXT, IP TEXT, Name TEXT, reason TEXT, admin TEXT, expire INTEGER, PRIMARY KEY (UID))");
    }else{
        while (GetSQLNextRow(q))
        {
            local now=GetSQLColumnData(q,2);
            local pexpire=GetSQLColumnData(q,1);
            local pIP=GetSQLColumnData(q,0);
            if(pexpire == 0 || pexpire>now)
            {
                BanIP(pIP);
            }
        }
        FreeSQLQuery(q);
    }
}
function checkbanDB(ply)
{
    local plyIP=ply.IP;
    local plyUID=ply.UniqueID;
    local plyUID2=ply.UniqueID2;
    local plyname=ply.Name;
    local q=QuerySQL(db,"SELECT UID, UID2, IP, Name, reason, admin, expire, strftime('%s','now') FROM ban");
    if(q!=null)
    {
        while (GetSQLNextRow(q))
        {
            local bUID=GetSQLColumnData(q, 0);
            local bUID2=GetSQLColumnData(q, 1);
            local bIP=GetSQLColumnData(q, 2);
            local breason=GetSQLColumnData(q, 4);
            local badmin=GetSQLColumnData(q, 5);
            local bexpire=GetSQLColumnData(q, 6);
            local now=GetSQLColumnData(q, 7);
            if(ply.UniqueID==bUID || ply.UniqueID2==bUID || ply.UniqueID==bUID2 || ply.UniqueID2==bUID2 || ply.IP==bIP)
            {
                if(bexpire ==0 || bexpire>now)
                {
                    BanIP(ply.IP);
                    BanPlayer(ply);
                    bankick(ply,badmin,breason);
                    FreeSQLQuery(q);
                    return true;
                }else{
                    UnbanIP(ply.IP);
                }
            }
        }
        FreeSQLQuery(q);
        return false;
    }
}
function addbanDB(ply,breason,time,badmin)
{
    local q=QuerySQL(db,"SELECT UID, UID2, IP, Name, expire, strftime('%s','now') FROM ban");
    if(q!=null)
    {
        while (GetSQLNextRow(q))
        {
            local bUID=GetSQLColumnData(q, 0);
            local bUID2=GetSQLColumnData(q, 1);
            local bIP=GetSQLColumnData(q, 2);
            local bexpire=GetSQLColumnData(q, 4);
            local now=GetSQLColumnData(q, 5);
            if(ply.UniqueID==bUID || ply.UniqueID2==bUID || ply.UniqueID==bUID2 || ply.UniqueID2==bUID2 || ply.IP==bIP)
            {
                if(bexpire!=0 && bexpire<=now)
                {
                    QuerySQL(db,"INSERT OR REPLACE INTO ban (UID, UID2, IP, Name, reason, admin, expire) VALUES('"+ply.UniqueID+"','"+ply.UniqueID2+"','"+ply.IP+"','"+ply.Name+"','"+breason+"','"+badmin.Name+"',"+0+")");
                    checkbanDB(ply);
                }else if(bexpire==0)
                {
                    checkbanDB(ply);
                }
                FreeSQLQuery(q);
                return;
            }
        }
    }
    local expire = "0";
    if (time > 0) expire = "strftime('%s','now') + " + (time * 60);
    QuerySQL(db,"INSERT OR IGNORE INTO ban (UID, UID2, IP, Name, reason, admin, expire) VALUES('"+ply.UniqueID+"','"+ply.UniqueID2+"','"+ply.IP+"','"+ply.Name+"','"+breason+"','"+badmin.Name+"',"+expire+")");
    checkbanDB(ply);
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
