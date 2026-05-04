# CZZY Web Backend (Step 0)

## 1. 环境要求

- Python 3.11+
- SQL Server (本地或局域网)
- ODBC Driver 18 for SQL Server

## 2. 安装依赖

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows 使用 .venv\\Scripts\\activate
pip install -r requirements.txt
```

## 3. 配置环境变量

```bash
cp .env.example .env
# 然后按实际 SQL Server 信息修改 .env
```

## 4. 启动服务

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 5. 验证接口

- 健康检查：`GET http://127.0.0.1:8000/api/health`
- 多库检查：`GET http://127.0.0.1:8000/api/db/check`


## 6. Windows Server 2019 一键部署

提供全自动脚本：

```powershell
backend\\deploy\\windows\\deploy_win_server_2019.ps1
```

管理员 PowerShell 执行示例：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\\backend\\deploy\\windows\\deploy_win_server_2019.ps1 -RepoUrl "https://github.com/shushu8589/like.git" -Branch "main"
```

说明：脚本会自动拉代码、安装后端依赖、构建前端、生成 IIS `web.config`、配置 IIS 站点、注册后端 Windows 服务（NSSM）并开放防火墙端口。
