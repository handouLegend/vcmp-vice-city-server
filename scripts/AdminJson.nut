// ============================================================================
//  AdminJson.nut  —  admin list (UID -> level), stored in admins.json
//  level 1 = normal, 2 = senior, 3 = top. Only 3 can add/del/reload.
//  /addadmin only sets level 1 or 2; /deladmin cannot delete level 3.
//  (requires json04rel64 plugin: fromJSONFile / toJSONFile)
//  UID = player.UniqueID (stable per player, vs IP which is unstable).
// ============================================================================

// global admin table : uid(string) -> level
admin <- {};

// get a player's UID as a string; falls back to "0" if not available
function GetUid(p)
{
    try {
        return p.UniqueID.tostring();
    } catch (e) {
        return "0";
    }
}

// ---------- load from admins.json on boot / /reload ----------
function LoadAdmins()
{
    try {
        local data = fromJSONFile("admins.json");
        admin = {};
        if (data != null && ("admins" in data)) {
            local a = data.admins;
            if (a != null) {
                foreach (uid, lv in a) {
                    admin[uid] <- lv;
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

// ---------- resolve input into { uid, player } ----------
// online player name -> their UID; otherwise treat the raw arg as a UID string.
function ResolveAdminArg(text)
{
    if (text == null || text.len() == 0) return null;
    local p = FindPlayer(text);
    if (p != null) {
        local r = {};
        r.uid <- GetUid(p);
        r.player <- p;
        return r;
    }
    local r = {};
    r.uid <- text;
    r.player <- null;
    return r;
}

// ---------- /addadmin <name or UID> [1|2] ----------
function HandleAddAdmin(player, text)
{
    if (!text) {
        MessagePlayer("[#ff0000]usage: /addadmin <player name or UID> [1|2]", player);
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
        MessagePlayer("[#ff0000]invalid input: " + arg, player);
        return;
    }
    local uid = r.uid;
    if (uid in admin) {
        MessagePlayer("[#ffd200]already an admin: " + uid + " (level " + admin[uid] + ")", player);
        return;
    }
    admin[uid] <- level;
    SaveAdmins();
    if (r.player != null) {
        if (r.player.ID in state) {
            state[r.player.ID].AdminLevel = level;
        }
        MessagePlayer("[#00ff00]added admin " + r.player.Name + " (UID " + uid + ") level " + level, player);
    } else {
        MessagePlayer("[#00ff00]added admin UID: " + uid + " level " + level, player);
    }
}

// ---------- /deladmin <name or UID> (level 3 protected) ----------
function HandleDelAdmin(player, text)
{
    if (!text) {
        MessagePlayer("[#ff0000]usage: /deladmin <player name or UID>", player);
        return;
    }
    local r = ResolveAdminArg(text);
    if (r == null) {
        MessagePlayer("[#ff0000]invalid input: " + text, player);
        return;
    }
    local uid = r.uid;
    if (!(uid in admin)) {
        MessagePlayer("[#ffd200]not in admin list: " + uid, player);
        return;
    }
    if (admin[uid] == 3) {
        MessagePlayer("[#ff0000]cannot delete level 3 admin", player);
        return;
    }
    delete admin[uid];
    SaveAdmins();
    if (r.player != null) {
        if (r.player.ID in state) {
            state[r.player.ID].AdminLevel = 0;
        }
        MessagePlayer("[#00ff00]removed admin " + r.player.Name + " (UID " + uid + ")", player);
    } else {
        MessagePlayer("[#00ff00]removed admin UID: " + uid, player);
    }
}

// admins.json example (server root, uid -> level):
// {
//   "admins": { "123456789012345": 3, "987654321098765": 2 }
// }
