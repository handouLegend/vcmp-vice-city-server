// ============================================================================
//  AdminJson.nut  —  管理员列表“JSON 文件 + 游戏内永久修改”示例
//  （配合 json04rel64 插件）
// ----------------------------------------------------------------------------
//  功能：
//    1. 启动时从 admins.json 读入管理员 IP 列表（fromJSONFile）
//    2. 提供 /addadmin <玩家名或IP>、/deladmin <IP> 命令（仅管理员可用）
//    3. 增删后立即写回 admins.json（toJSONFile），重启服务器后仍生效
//  集成到 Main.nut（把它当作“把本文件内容合并进 Main.nut”的参考）：
//    - 在 onServerStart 里调用 LoadAdmins()
//    - 在 onPlayerCommand 里加两个分支：
//        else if(cmd=="addadmin" && player.Admin){ HandleAddAdmin(player, text); }
//        else if(cmd=="deladmin" && player.Admin){ HandleDelAdmin(player, text); }
//    - 注意：Main.nut 里原有的 `local admin=[...]` 要删除/改成这里的全局 `admin <- []`
// ============================================================================

// ---------- 全局管理员列表（替代原 Main.nut 里的 local admin=[...]）----------
admin <- [];

// ---------- 启动时从文件加载 ----------
function LoadAdmins()
{
    try {
        local data = fromJSONFile("admins.json");
        if ("admins" in data) admin = data.admins;
        print("[AdminJson] loaded " + admin.len() + " admins");
    } catch (e) {
        print("[AdminJson] admins.json load failed: " + e);
        admin = [];   // 兜底：加载失败时无人是管理员（安全）
    }
}

// ---------- 写回文件（永久保存）----------
function SaveAdmins()
{
    try {
        toJSONFile("admins.json", { admins = admin }, JSON_C_TO_STRING_PRETTY);
        print("[AdminJson] saved " + admin.len() + " admins");
    } catch (e) {
        print("[AdminJson] save failed: " + e);
    }
}

// ---------- 辅助：判断是否标准 IPv4（x.x.x.x）----------
function IsIp(s)
{
    if (s == null) return false;
    local dots = 0;
    for (local i = 0; i < s.len(); ++i) {
        local c = s[i];
        if (c == 46) dots++;                    // '.'
        else if (c < 48 || c > 57) return false; // 非数字
    }
    return dots == 3;
}

// ---------- 辅助：把输入解析成 { ip, player } ----------
// 玩家名 -> 在线玩家取其 IP；或直接是 IP（不要求玩家在线）
function ResolveAdminArg(text)
{
    local p = FindPlayer(text);
    if (p != null) return { ip = p.IP, player = p };
    if (IsIp(text)) return { ip = text, player = null };
    return null;    // 既不是在线玩家名，也不是 IP
}

// ---------- /addadmin 处理 ----------
function HandleAddAdmin(player, text)
{
    if (!text) { MessagePlayer("[#ff0000]usage: /addadmin <player name or IP>", player); return; }
    local r = ResolveAdminArg(text);
    if (r == null) { MessagePlayer("[#ff0000]player not found: " + text + " (offline? add by IP)", player); return; }
    local ip = r.ip;
    if (admin.find(ip) >= 0) { MessagePlayer("[#ffd200]already an admin: " + ip, player); return; }
    admin.append(ip);
    SaveAdmins();
    if (r.player != null) {
        r.player.Admin = true;                    // 在线则立即生效
        MessagePlayer("[#00ff00]added admin " + r.player.Name + " (" + ip + ")", player);
    } else {
        MessagePlayer("[#00ff00]added admin IP: " + ip, player);
    }
}

// ---------- /deladmin 处理 ----------
function HandleDelAdmin(player, text)
{
    if (!text) { MessagePlayer("[#ff0000]usage: /deladmin <player name or IP>", player); return; }
    local r = ResolveAdminArg(text);
    if (r == null) { MessagePlayer("[#ff0000]player not found: " + text, player); return; }
    local ip = r.ip;
    local idx = admin.find(ip);
    if (idx < 0) { MessagePlayer("[#ffd200]not in admin list: " + ip, player); return; }
    admin.remove(idx);
    SaveAdmins();
    if (r.player != null) {
        r.player.Admin = false;                   // 在线则立即取消
        MessagePlayer("[#00ff00]removed admin " + r.player.Name + " (" + ip + ")", player);
    } else {
        MessagePlayer("[#00ff00]removed admin IP: " + ip, player);
    }
}

// ---------- admins.json 示例（放服务器根目录）----------
// {
//   "admins": ["183.197.59.66", "171.13.191.55", "113.25.140.245"]
// }
