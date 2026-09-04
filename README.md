# VC-MP Vice City Server Scripts

罪恶都市gta吧的 Vice City Multiplayer (VC:MP) 0.4 服务器脚本。

## 环境要求

- **VC:MP 0.4 server**（`server64.exe`，64 位）
- **Squirrel 插件**（`squirrel04rel64` / `squirreel04rel64`）
- **json04rel64** —— 管理员 JSON 存储依赖此插件

## 安装

1. 对应位置：
   - `scripts/Main.nut` —— 主脚本
   - `scripts/Vehicles.nut`、`scripts/AdminJson.nut` —— 脚本目录
   - `admins.json` —— 服务器根目录（配置）
   - `plugins/` —— 需要的插件 dll
2. 配置 `server.cfg`
   ```
   plugins ... json04rel64
   ```
3. 启动 `server64.exe`。

## 配置

### 管理员（`admins.json`，服务器根目录）

```json
{
  "admins": ["111.111.111.111", "222.222.222.222"]
}
```

- 服务器启动/重载时读取；
- `admins.json.example` 示例（不含真实 IP）。

## 插件下载

所需插件可从以下地址下载：

- **announce**：https://bitbucket.org/stormeus/0.4-announce/downloads/
- **squirrel**：https://bitbucket.org/stormeus/0.4-squirrel/downloads/
- **sqlite**：https://bitbucket.org/stormeus/0.4-sqlite/downloads/
- **iniparser**：https://bitbucket.org/stormeus/0.4-iniparser/downloads/
- **hashing**：https://bitbucket.org/stormeus/0.4-hashing-algorithms/downloads/

## 说明

- 部分功能依赖服务器**已加载的插件**；缺少插件时相关功能可能不可用。

## 许可证

本项目基于 [MIT License](LICENSE)。
