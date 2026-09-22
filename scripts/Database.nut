local db;
function bankick(ply,adminName,reason)
{
    if(ply!=null)
    {
        Message("[#ff0000][BAN] Player: "+ply.Name+"has been banned by [#00ff00]"+adminName+"[#ff0000]. Reason: "+reason);
        ply.Kick(); 
    }
}
function loadDB()
{
    db=ConnectSQL("serverDB.db");
    if(db!=null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS bans (UID TEXT, UID2 TEXT, IP TEXT, Name TEXT, reason TEXT, admin TEXT, expire INTEGER, PRIMARY KEY (UID))");
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (UID TEXT, name TEXT, money INTEGER, wantedLevel INTEGER, PRIMARY KEY (UID, name))");
    }else
    {
        print("[DB] ConnectSQL failed");
    }
}
function loadbanDB()
{
    local q=QuerySQL(db,"SELECT IP, expire FROM bans");
    if(q==null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS bans (UID TEXT, UID2 TEXT, IP TEXT, Name TEXT, reason TEXT, admin TEXT, expire INTEGER, PRIMARY KEY (UID))");
    }else{
        local first=true;
        while(true)
        {
            if(!first){ if(!GetSQLNextRow(q)){ break; } }
            first=false;
            local now=time();
            local pexpire=GetSQLColumnData(q,1);
            local pIP=GetSQLColumnData(q,0);
            if(pexpire == 0 || pexpire>now)
            {
                print("[DB] Load banned IP [#00ff00]"+pIP);
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
    local q=QuerySQL(db,"SELECT UID, UID2, IP, Name, reason, admin, expire FROM bans");
    if(q!=null)
    {
        local first=true;
        local now=time();
        while(true)
        {
            if(!first){ if(!GetSQLNextRow(q)){ break; } }
            first=false;
            local bUID=GetSQLColumnData(q, 0);
            local bUID2=GetSQLColumnData(q, 1);
            local bIP=GetSQLColumnData(q, 2);
            local breason=GetSQLColumnData(q, 4);
            local badmin=GetSQLColumnData(q, 5);
            local bexpire=GetSQLColumnData(q, 6);
            if(ply.UniqueID==bUID || ply.UniqueID2==bUID || ply.UniqueID==bUID2 || ply.UniqueID2==bUID2 || ply.IP==bIP)
            {
                if(bexpire ==0 || bexpire>now)
                {
                    BanPlayer(ply);
                    bankick(ply,badmin,breason);
                    FreeSQLQuery(q);
                    return true;
                }
            }
        }
        FreeSQLQuery(q);
        return false;
    }
}
function addbanDB(ply,breason,tim,badmin)
{
    local q=QuerySQL(db,"SELECT UID, UID2, IP, Name, expire FROM bans");
    if(q!=null)
    {
        local now=time();
        local first=true;
        while(true)
        {
            if(!first){ if(!GetSQLNextRow(q)){ break; } }
            first=false;
            local bUID=GetSQLColumnData(q, 0);
            local bUID2=GetSQLColumnData(q, 1);
            local bIP=GetSQLColumnData(q, 2);
            local bexpire=GetSQLColumnData(q, 4);
            if(ply.UniqueID==bUID || ply.UniqueID2==bUID || ply.UniqueID==bUID2 || ply.UniqueID2==bUID2 || ply.IP==bIP)
            {
                if(bexpire!=0 && bexpire<=now)
                {
                    QuerySQL(db,"INSERT OR REPLACE INTO bans (UID, UID2, IP, Name, reason, admin, expire) VALUES('"+ply.UniqueID+"','"+ply.UniqueID2+"','"+ply.IP+"','"+ply.Name+"','"+breason+"','"+badmin.Name+"',"+0+")");
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
    local expire = 0;
    if (tim > 0) expire = time() + (tim * 60);
    QuerySQL(db,"INSERT OR REPLACE INTO bans (UID, UID2, IP, Name, reason, admin, expire) VALUES('"+ply.UniqueID+"','"+ply.UniqueID2+"','"+ply.IP+"','"+ply.Name+"','"+breason+"','"+badmin.Name+"',"+expire+")");
    checkbanDB(ply);
}
function queryDB(player)
{
    local plyUID=player.UniqueID;
    local name=player.Name;
    local q=QuerySQL(db,"SELECT UID, name, money, wantedLevel FROM players");
    if(q==null)
    {
        QuerySQL(db, "CREATE TABLE IF NOT EXISTS players (UID TEXT, name TEXT, money INTEGER, wantedLevel INTEGER, PRIMARY KEY (UID, name))");
        q=QuerySQL(db,"SELECT UID, name, money, wantedLevel FROM players");
    }
    if(q==null)
    {
        print("[DB] query failed");
        return;
    }
    local found = false;
    local first=true;
    while(true)
    {
        if(!first){ if(!GetSQLNextRow(q)){ break; } }
        first=false;

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
