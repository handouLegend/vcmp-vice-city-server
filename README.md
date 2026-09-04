# VC-MP Vice City Server Scripts

罪恶都市gta吧社区的 Vice City Multiplayer (VC:MP) 0.4 服务器脚本。

本项目是基于 VC:MP 0.4 的服务器游戏逻辑脚本，包含静态车辆布置、管理员管理、死亡位置追踪、击杀奖励、临时刷车、爆炸等玩法功能。

## 功能特性

- **静态车辆**：全图 746 辆静态载具（含涂装修正），启动时一次性刷出
- **管理员 JSON 管理**：管理员 IP 存于 `admins.json`，游戏内 `/addadmin`、`/deladmin` 即时增删并自动写回文件（持久化，重启后仍生效）
- **管理员识别**：玩家按 IP 自动识别为管理员
- **击杀公告与奖励**：击杀播报 `killed`/`team-killed`，击杀者 +$50、被击杀者 -$50
- **死亡位置追踪** `/diepos on/off`：开启后重生在死亡位置（溺水除外）
- **临时刷车** `/car <车辆ID>`：即刷即用，爆炸自动删除
- **爆炸** `/boom`：对自己或指定玩家/全体（管理员）
- **独立世界处理**：部分操作在独立世界进行再还原

## 环境要求

- **VC:MP 0.4 server**（`server64.exe`，64 位）
- **Squirrel 插件**（`squirrel04rel64` / `squirreel04rel64`）
- **json04rel64** —— 管理员 JSON 存储依赖此插件

## 安装

1. 将脚本放到服务器对应位置：
   - `scrips/Main.nut` —— 游戏模式（`server.cfg` 的 `sqgamemode` 指向它）
   - `Vehicles.nut`、`AdminJson.nut`、`admins.json` —— 服务器根目录
   - `plugins/` —— 需要的插件 dll
2. 配置 `server.cfg`，在 `plugins` 行加入 `json04rel64`（管理员 JSON 需要）：
   ```
   plugins ... json04rel64
   ```
3. 启动 `server64.exe`。

## 配置

### 管理员（`admins.json`，放服务器根目录）

```json
{
  "admins": ["111.111.111.111", "222.222.222.222"]
}
```

- 服务器启动/`/reload` 时读取；
- 管理员可在游戏内用 `/addadmin <玩家名或IP>`、`/deladmin <IP>` **改管理员并立即写回文件**；
- `admins.json.example` 是示例（不含真实 IP）。

## 游戏内命令

| 命令 | 说明 | 权限 |
|---|---|---|
| `/heal` | 花 $100 满血 | 所有人 |
| `/arm` | 花 $100 满护甲 | 所有人 |
| `/money` | +$500 | 管理员 |
| `/skin <ID>` | 换皮肤 | 所有人 |
| `/weapon <名或ID>` | 给自己武器 | 所有人 |
| `/team <颜色>` | 换队（同队无效） | 管理员 |
| `/car <车辆ID>` | 临时刷车 | 所有人 |
| `/pos` | 显示坐标 | 所有人 |
| `/diepos on/off` | 死亡位置追踪开关 | 所有人 |
| `/boom [@e / 玩家名]` | 爆炸 | 自己；`@e`/指定玩家需管理员 |
| `/addadmin <玩家名或IP>` | 加管理员 | 管理员 |
| `/deladmin <IP>` | 删管理员 | 管理员 |
| `/IP <玩家名>` | 查玩家 IP | 管理员 |
| `/reload` | 重载脚本（会重读 admins.json） | 管理员 |
| `/help` | 命令列表 | 所有人 |

## 说明

- 本脚本最初从 VC-MP 论坛下载并修改，适用于 VC:MP 0.4（Public Beta）。
- 部分功能依赖服务器**已加载的插件**（如 `json04rel64` 用于管理员 JSON）；缺少插件时相关命令会提示报错。
- 静态车辆、管理员等改动**建议在服务器重启后验证**；`/reload` 会重读 `admins.json` 但不重刷静态车。

## 许可证

本项目基于 [MIT License](LICENSE)。
