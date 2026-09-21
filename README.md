# VC-MP Vice City Server Scripts

罪恶都市gta吧的 Vice City Multiplayer (VC:MP) 0.4 服务器脚本。

## 环境要求

- **VC:MP 0.4 server**（`server64.exe`，64 位）
- **Squirrel 插件**（`squirrel04rel64`）
- **json04rel64** —— 管理员 JSON 存储依赖此插件

## 安装

1. 对应位置：
   - `scripts/Main.nut` —— 主脚本
   - `scripts/Vehicles.nut`、`scripts/AdminJson.nut`、`scripts/DataBase.nut` —— 脚本目录
   - `admins.json` —— 服务器根目录（配置）
   - `plugins/` —— 需要的插件 dll
2. 配置 `server.cfg`
   ```
   plugins ... 
   ```
3. 启动 `server64.exe`。

## 配置

### 管理员（`admins.json`，服务器根目录）

```json
{
  "admins": {
    "0123456789abcdef0123456789abcdef01234567": 3,
    "abcdef0123456789abcdef0123456789abcdef01": 2
  }
}
```

- 键是**玩家 UID**（`player.UniqueID`，40 位十六进制字符串）—— **不是 IP**（IP 会变，UID 稳定）；
- 值是**管理员等级**：`1` 普通 / `2` 高级 / `3` 顶级；只有 3 级能增删管理员；
- 服务器启动和 `/reload` 时读取，也可用 `/addadmin` 添加；
- 参考同目录下的 `admins.json.example`。

## 插件

`server.cfg` 里 `plugins` 一行实际加载的插件：

```
plugins announce04rel64 sqlite04rel64 squirrel04rel64 squirreel04rel64 hashing04rel64 actor04rel64 ini04rel64 json04rel64
```

| 插件 | 用途 | 来源 |
|---|---|---|
| **squirrel04rel64** | Squirrel 脚本引擎（核心，必需） | [Stormeus](https://bitbucket.org/stormeus/0.4-squirrel/downloads/) |
| **announce04rel64** | 向 masterlist 上报服务器 | [Stormeus](https://bitbucket.org/stormeus/0.4-announce/downloads/) |
| **sqlite04rel64** | 玩家存档数据库 | [Stormeus](https://bitbucket.org/stormeus/0.4-sqlite/downloads/) |
| **json04rel64** | 管理员表读写（`fromJSONFile` / `toJSONFile`） | Crys |
| **hashing04rel64** | 哈希算法 | [Stormeus](https://bitbucket.org/stormeus/0.4-hashing-algorithms/downloads/) |
| **ini04rel64** | ini 读写（已标注 deprecated，但被依赖） | [Stormeus](https://bitbucket.org/stormeus/0.4-iniparser/downloads/) |
| **actor04rel64** | `create_actor` 模块（地图 NPC） | 论坛 |
| **squirreel04rel64** | Squirrel 扩展（部分脚本函数来自它） | 论坛 |

**全部为 64 位**（服务器是 `server64.exe`）—— `plugins/` 里的 `*32.dll` 在本项目里用不到。

`plugins/` 目录里还有几个**没启用**的：`sqhash04rel64`、`sqlite-win64`、`sockets04rel32`、`sqlit1e04rel32`（最后这个文件名像是手滑重命名的废文件）。

### 日志插件

`logfile64.dll` 会把控制台内容写进服务器目录的 `logfile.txt`，用于排查崩溃和回溯玩家操作：

- 下载：[论坛帖](https://forum.vc-mp.org/?topic=8070.0) / [MediaFire](https://www.mediafire.com/file/6vwtnuymmua9spw/logfile64.dll/file)
- 放进 `plugins/` 后，**必须确认它也在 `server.cfg` 的 `plugins` 行里**，否则不会加载。

## 说明

- 部分功能依赖服务器**已加载的插件**；缺少插件时相关功能可能不可用。

## 许可证

本项目基于 [MIT License](LICENSE)。
