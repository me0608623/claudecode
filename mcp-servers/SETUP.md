# MCP Servers 安裝指南

## 1. isaac-sim（NVIDIA 官方 MCP — 16 tools）

完整的 Isaac Sim 控制：建立場景、生成機器人、物理模擬、關節控制等。

### 前置需求
- NVIDIA Isaac Sim 已安裝並運行
- uv (Python package manager)

### 安裝
```bash
# Clone
git clone https://github.com/NVIDIA-Omniverse/IsaacSim-MCP.git ~/nvidia-isaac-mcp
cd ~/nvidia-isaac-mcp

# 安裝 uv (如果沒有)
pip install uv

# 在 Isaac Sim 中啟用 MCP extension (port 9876)
```

### Claude Code 配置
```bash
claude mcp add isaac-sim -- uv run --directory ~/nvidia-isaac-mcp nvidia-isaac-mcp
```

### 可用工具（16 個）
| 工具 | 用途 |
|------|------|
| ping | 測試連線 |
| get_stage_info | 取得 USD stage 概覽 |
| get_prim_info | 查詢特定 prim |
| create_prim | 建立 3D 物件 |
| modify_prim | 變換物件 |
| delete_prim | 刪除物件 |
| execute_code | 在 Isaac Sim 內執行 Python |
| create_physics_scene | 啟用物理模擬 |
| add_rigid_body | 加入剛體物理 |
| add_ground_plane | 建立地面 |
| simulation_control | 播放/暫停/停止模擬 |
| load_usd_asset | 載入 USD 檔案 |
| spawn_robot | 生成機器人（90+ 模型） |
| list_available_robots | 列出可用機器人 |
| get_joint_positions | 查詢關節狀態 |
| set_joint_positions | 控制關節 |

---

## 2. isaacsim-mcp（輕量版 — 3 tools）

透過 VSCode 擴展連接 Isaac Sim，適合快速執行 Python code。

### 安裝
```bash
python -m venv ~/isaacsim-mcp-venv
source ~/isaacsim-mcp-venv/bin/activate
pip install isaacsim-mcp
```

### Claude Code 配置
```bash
claude mcp add isaacsim-mcp -- ~/isaacsim-mcp-venv/bin/isaac-mcp-server
```

### 可用工具（3 個）
| 工具 | 用途 |
|------|------|
| check_isaac_connection | 檢查 Isaac Sim 連線 |
| execute_isaac_code | 在 Isaac Sim 內執行 Python |
| get_isaac_console_errors_warnings | 取得錯誤/警告 |
