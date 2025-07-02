# Action-ssh

本项目可以使用 GitHub Actions 创建临时的开发环境。

## 功能

*   在 GitHub Actions 的运行器 (runner) 中快速启动一个临时环境。
*   使用 Cloudflare Tunnel 将 SSH 或 RDP 服务暴露到公网，无需公网 IP。
*   自动从您的 GitHub 个人资料中获取公钥并配置 SSH，实现免密登录。
*   允许您通过 Cloudflare Tunnel 连接到 Windows 环境，或通过 SSH 隧道连接到带有 KDE 桌面的 Linux 环境。

## 如何使用

### 准备工作

1.  **Fork 本仓库**
    点击本页面右上角的 "Fork" 按钮，将此仓库复制到您自己的 GitHub 账户下。

2.  **在 Actions 页面中启用 Workflows**
    Fork 之后，进入您自己仓库的 "Actions" 页面，GitHub 会提示您启用 Workflows，点击 "I understand my workflows, go ahead and enable them" 按钮。

### 连接到 SSH 环境 (Linux)

1.  **准备 SSH 密钥**
    请确保您已经在您的 GitHub 账户中添加了您的 SSH 公钥。您可以在[这里](https://github.com/settings/keys)查看和添加。

2.  **运行相关的 Workflow**
    - 在您仓库的 "Actions" 页面，从左侧选择一个您想要运行的 Workflow (例如 `bare SSH Github-runner`)。
    - 点击 "Run workflow" 下拉菜单并启动。

3.  **获取连接命令并连接**
    - Workflow 启动后，点击进入该 Workflow 的运行日志页面。
    - 等待一段时间，日志中会输出一个 `ssh` 命令。它看起来像这样：
      ```bash
      ssh-keygen -R action-sshd-cloudflared && echo 'action-sshd-cloudflared ...' >> ~/.ssh/known_hosts && ssh -o ProxyCommand='cloudflared access tcp --hostname https://....trycloudflare.com' runner@action-sshd-cloudflared
      ```
    - 在您自己的电脑上，安装 `cloudflared` 客户端。
    - 复制并粘贴日志中生成的完整命令到您的终端并运行即可连接。

### 连接到 RDP 环境 (Windows)

1.  **设置 RDP 密码**
    - 进入您 Fork 的仓库的 `Settings` -> `Secrets and variables` -> `Actions` 页面。
    - 创建一个新的仓库秘密 (repository secret)，名称为 `RDPW`，值为您想要设置的 RDP 连接密码。

2.  **运行相关的 Workflow**
    - 在您仓库的 "Actions" 页面，从左侧选择一个您想要运行的 Workflow (例如 `Windows RDP Github-runner x64`)。
    - 点击 "Run workflow" 下拉菜单并启动。

3.  **获取连接地址并连接**
    - Workflow 启动后，点击进入该 Workflow 的运行日志页面。
    - 等待一段时间，日志中会输出一个 Cloudflare 隧道的地址，看起来像 `https://....trycloudflare.com`。
    - 在您自己的电脑上，安装 `cloudflared` 客户端。
    > [!TIP]
    > 推荐使用我的 [Cloudflared 连接小工具](https://github.com/lingyicute/Cloudflared-Helper)。
    >
    - 使用 RDP 客户端 (如 Windows 自带的 "远程桌面连接") 连接到 `localhost:port`。密码为您在第一步中设置的 `RDPW`。

### 连接到 RDP 环境 (Linux Desktop)

1.  **准备 SSH 密钥**
    请确保您已经在您的 GitHub 账户中添加了您的 SSH 公钥。您可以在[这里](https://github.com/settings/keys)查看和添加。

2.  **运行相关的 Workflow**
    - 在您仓库的 "Actions" 页面，从左侧选择一个您想要运行的 Workflow (例如 `KDE Github-runner`)。
    - 点击 "Run workflow" 下拉菜单并启动。

3.  **获取连接命令并连接**
    - Workflow 启动后，点击进入该 Workflow 的运行日志页面。
    - 等待一段时间，日志中会输出一个含端口转发参数的 `ssh` 命令。
    - 在您自己的电脑上，安装 `cloudflared` 客户端。
    - 复制并粘贴日志中生成的完整命令到您的终端，并使用 RDP 客户端 (如 Windows 自带的 "远程桌面连接") 连接。

## 可用的环境 (Workflows)

*   `bare-ssh.yml`: 在 Ubuntu 环境下提供一个基础的 **SSH** 环境。
*   `KDE.yml`: 提供一个带有 KDE 桌面环境，同时支持 **SSH** 和 **RDP**。
*   `winx64-github.yml`: 在 Windows (x64) 环境下提供 **RDP**。
*   `winx64-depot.yml`: 在 Depot Ci Windows (x64) 环境下提供 **RDP**。
*   `winarm-github.yml` / `bare-ssh-arm.yml`: 针对 ARM 架构的相应版本。

您可以根据您的需求选择不同的 workflow，也可以自行修改 workflow 文件以定制您需要的环境。 