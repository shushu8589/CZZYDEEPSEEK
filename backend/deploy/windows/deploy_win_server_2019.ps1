Param(
    [string]$RepoUrl = "https://github.com/shushu8589/like.git",
    [string]$Branch = "main",
    [string]$DeployRoot = "C:\deploy\CZZY",
    [string]$BackendServiceName = "CZZYBackend",
    [string]$BackendHost = "127.0.0.1",
    [int]$BackendPort = 8000,
    [int]$IISPort = 80,
    [string]$SiteName = "CZZYWeb",
    [string]$AppPoolName = "CZZYWebPool",
    [string]$NssmPath = "C:\tools\nssm\win64\nssm.exe"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
    Write-Host "`n==== $Message ====" -ForegroundColor Cyan
}

function Require-Command([string]$Name, [string]$InstallHint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "缺少命令: $Name。请先安装：$InstallHint"
    }
}

function Ensure-IIS {
    Write-Step "启用 IIS 与管理模块"
    Install-WindowsFeature -Name Web-Server,Web-Common-Http,Web-Default-Doc,Web-Static-Content,Web-Http-Errors,Web-Http-Redirect,Web-Http-Logging,Web-Request-Monitor,Web-Filtering,Web-Stat-Compression,Web-Mgmt-Tools,Web-Scripting-Tools -IncludeManagementTools | Out-Null
    Import-Module WebAdministration
}

function Ensure-Repo([string]$Path, [string]$Url, [string]$BranchName) {
    Write-Step "拉取代码"
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    if (-not (Test-Path (Join-Path $Path ".git"))) {
        git clone $Url $Path
    }

    Push-Location $Path
    git fetch --all
    git checkout $BranchName
    git pull origin $BranchName
    Pop-Location
}

function Ensure-Backend([string]$BackendPath) {
    Write-Step "部署后端"
    Push-Location $BackendPath

    if (-not (Test-Path ".venv")) {
        py -3.11 -m venv .venv
    }

    & .\.venv\Scripts\python.exe -m pip install --upgrade pip
    & .\.venv\Scripts\python.exe -m pip install -r requirements.txt

    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Warning "首次部署：已创建 backend/.env，请根据 SQL Server 实际参数修改后重跑脚本。"
    }

    Pop-Location
}

function Ensure-Frontend([string]$FrontendPath) {
    Write-Step "部署前端"
    Push-Location $FrontendPath
    npm install
    npm run build
    Pop-Location
}

function Ensure-WebConfig([string]$DistPath, [string]$Host, [int]$Port) {
    Write-Step "生成前端 web.config（IIS 反向代理 + Vue 路由回退）"
    if (-not (Test-Path $DistPath)) {
        throw "前端 dist 目录不存在: $DistPath"
    }

    $webConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="API Reverse Proxy" stopProcessing="true">
          <match url="^api/(.*)" />
          <action type="Rewrite" url="http://$Host`:$Port/api/{R:1}" />
        </rule>
        <rule name="Vue Router History" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/" />
        </rule>
      </rules>
    </rewrite>
    <staticContent>
      <remove fileExtension=".json" />
      <mimeMap fileExtension=".json" mimeType="application/json" />
    </staticContent>
  </system.webServer>
</configuration>
"@

    Set-Content -Path (Join-Path $DistPath "web.config") -Value $webConfig -Encoding UTF8
}

function Ensure-IISSite([string]$Site, [string]$AppPool, [string]$DistPath, [int]$Port) {
    Write-Step "配置 IIS 站点"
    Import-Module WebAdministration

    if (-not (Test-Path "IIS:\AppPools\$AppPool")) {
        New-WebAppPool -Name $AppPool | Out-Null
    }

    Set-ItemProperty "IIS:\AppPools\$AppPool" -Name processModel.identityType -Value ApplicationPoolIdentity

    if (Test-Path "IIS:\Sites\$Site") {
        Set-ItemProperty "IIS:\Sites\$Site" -Name physicalPath -Value $DistPath
        Set-ItemProperty "IIS:\Sites\$Site" -Name applicationPool -Value $AppPool
    }
    else {
        New-Website -Name $Site -Port $Port -PhysicalPath $DistPath -ApplicationPool $AppPool | Out-Null
    }
}

function Ensure-BackendService([string]$ServiceName, [string]$BackendPath, [string]$Host, [int]$Port, [string]$NssmExe) {
    Write-Step "配置后端 Windows 服务（NSSM）"

    if (-not (Test-Path $NssmExe)) {
        throw "未找到 NSSM：$NssmExe。请下载后重试。"
    }

    $uvicorn = Join-Path $BackendPath ".venv\Scripts\uvicorn.exe"
    $args = "app.main:app --host $Host --port $Port"

    $serviceExists = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if (-not $serviceExists) {
        & $NssmExe install $ServiceName $uvicorn $args | Out-Null
    }

    & $NssmExe set $ServiceName AppDirectory $BackendPath | Out-Null
    & $NssmExe set $ServiceName Start SERVICE_AUTO_START | Out-Null
    & $NssmExe stop $ServiceName | Out-Null
    & $NssmExe start $ServiceName | Out-Null
}

function Ensure-Firewall([int]$WebPort) {
    Write-Step "配置防火墙"
    $ruleName = "CZZY-IIS-$WebPort"
    $exists = netsh advfirewall firewall show rule name="$ruleName" | Select-String $ruleName
    if (-not $exists) {
        netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=$WebPort | Out-Null
    }
}

# ---------- 主流程 ----------
Require-Command "git" "Git for Windows"
Require-Command "py" "Python 3.11+"
Require-Command "npm" "Node.js LTS"
Require-Command "iisreset" "IIS"

Ensure-IIS
Ensure-Repo -Path $DeployRoot -Url $RepoUrl -BranchName $Branch

$backendPath = Join-Path $DeployRoot "backend"
$frontendPath = Join-Path $DeployRoot "frontend"
$distPath = Join-Path $frontendPath "dist"

Ensure-Backend -BackendPath $backendPath
Ensure-Frontend -FrontendPath $frontendPath
Ensure-WebConfig -DistPath $distPath -Host $BackendHost -Port $BackendPort
Ensure-IISSite -Site $SiteName -AppPool $AppPoolName -DistPath $distPath -Port $IISPort
Ensure-BackendService -ServiceName $BackendServiceName -BackendPath $backendPath -Host $BackendHost -Port $BackendPort -NssmExe $NssmPath
Ensure-Firewall -WebPort $IISPort

iisreset | Out-Null

Write-Host "`n部署完成。" -ForegroundColor Green
Write-Host "访问地址: http://<服务器IP>:$IISPort/"
Write-Host "后端服务: $BackendServiceName"
Write-Host "若首次创建 .env，请先补全 SQL Server 配置后重跑脚本。"
