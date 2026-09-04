// ============================================================================
//  AdminJson.nut  —  admin list (IP -> level), stored in admins.json
//  level 1 = normal, 2 = senior, 3 = top. Only 3 can add/del/reload.
//  /addadmin only sets level 1 or 2; /deladmin cannot delete level 3.
//  (requires json04rel64 plugin: fromJSONFile / toJSONFile)
// ============================================================================

// global admin table : ip -> level
admin <- {};

// ---------- load from admins.json on boot / /reload ----------
function LoadAdmins()
{
    try {
        local data = fromJSONFile("admins.json");
        admin = {};
        if (data != null && ("admins" in data)) {
            local a = data.admins;
            if (a != null) {
                foreach (ip, lv in a) {
                    admin[ip] <- lv;
                }
            }
        }
        print("[AdminJson] loaded " + admin.len() + " admins");
    } catch (e) {
        print("[AdminJson] admins.json load failed: " + e);
        admin = {};
    }
}

// ---------- write back to admins.json (permanent) ----------
function SaveAdmins()
{
    try {
        local obj = {};
        obj.admins <- admin;
        toJSONFile("admins.json", obj, JSON_C_TO_STRING_PRETTY);
        print("[AdminJson] saved " + admin.len() + " admins");
    } catch (e) {
        print("[AdminJson] save failed: " + e);
    }
}

// ---------- is this a standard IPv4 "x.x.x.x" ? ----------
function IsIp(s)
{
    if (s == null) return false;
    local dots = 0;
    for (local i = 0; i < s.len(); ++i) {
        local c = s[i];
        if (c == 46) dots++;
        else if (c < 48 || c > 57) return false;
    }
    return dots == 3;
}

// ---------- resolve input into { ip, player } ----------
function ResolveAdminArg(text)
{
    local p = FindPlayer(text);
    if (p != null) {
        local r = {};
        r.ip <- p.IP;
        r.player <- p;
        return r;
    }
    if (IsIp(text)) {
        local r = {};
        r.ip <- text;
        r.player <- null;
        return r;
    }
    return null;
}

// ---------- /addadmin <name or IP> [1|2] ----------
function HandleAddAdmin(player, text)
{
    if (!text) {
        MessagePlayer("[#ff0000]usage: /addadmin <player name or IP> [1|2]", player);
        return;
    }
    local level = 1;
    local arg = text;
    // this Squirrel has no string.split(); parse "name [level]" via find/slice
    local sp = -1;
    local pos = text.find(" ");
    while (pos != null) {
        sp = pos;
        pos = text.find(" ", pos + 1);
    }
    if (sp >= 0) {
        local tail = text.slice(sp + 1);
        if (tail == "1" || tail == "2") {
            level = tail.tointeger();
            arg = text.slice(0, sp);
        }
    }
    if (level != 1 && level != 2) {
        MessagePlayer("[#ff0000]level must be 1 or 2 (default 1)", player);
        return;
    }
    local r = ResolveAdminArg(arg);
    if (r == null) {
        MessagePlayer("[#ff0000]player not found: " + arg + " (offline? add by IP)", player);
        return;
    }
    local ip = r.ip;
    if (ip in admin) {
        MessagePlayer("[#ffd200]already an admin: " + ip + " (level " + admin[ip] + ")", player);
        return;
    }
    admin[ip] <- level;
    SaveAdmins();
    if (r.player != null) {
        if (r.player.ID in state) {
            state[r.player.ID].AdminLevel = level;
        }
        MessagePlayer("[#00ff00]added admin " + r.player.Name + " (" + ip + ") level " + level, player);
    } else {
        MessagePlayer("[#00ff00]added admin IP: " + ip + " level " + level, player);
    }
}

// ---------- /deladmin <name or IP> (level 3 protected) ----------
function HandleDelAdmin(player, text)
{
    if (!text) {
        MessagePlayer("[#ff0000]usage: /deladmin <player name or IP>", player);
        return;
    }
    local r = ResolveAdminArg(text);
    if (r == null) {
        MessagePlayer("[#ff0000]player not found: " + text, player);
        return;
    }
    local ip = r.ip;
    if (!(ip in admin)) {
        MessagePlayer("[#ffd200]not in admin list: " + ip, player);
        return;
    }
    if (admin[ip] == 3) {
        MessagePlayer("[#ff0000]cannot delete level 3 admin", player);
        return;
    }
    delete admin[ip];
    SaveAdmins();
    if (r.player != null) {
        if (r.player.ID in state) {
            state[r.player.ID].AdminLevel = 0;
        }
        MessagePlayer("[#00ff00]removed admin " + r.player.Name + " (" + ip + ")", player);
    } else {
        MessagePlayer("[#00ff00]removed admin IP: " + ip, player);
    }
}

// admins.json example (server root, ip -> level):
// {
//   "admins": { "111.111.111.111": 3, "222.222.222.222": 2 }
// }
