# Backpack 做市机器人 Docker 部署指南

## 项目概述

本项目提供了 Backpack Exchange 做市交易程序的 Docker 化部署方案，使用 Alpine Linux 镜像，支持根据不同的资金量自动配置对应的交易参数

## 支持的配置

### 资金量配置

| 资金量 | 杠杆倍率 | 最终磨损 | 最终交易量 | 最终磨损率 | 策略类型 |
|--------|----------|----------|------------|------------|----------|
| 100 USDC | 50x | 51 | 215381 | 0.0236% | maker_hedge |
| 500 USDC | 50x | 150 | 918740.66 | 0.0163% | standard |
| 1000 USDC | 50x | 312 | 1248215 | 0.0249% | standard |

## 部署方式

### 方式一：GitHub Container Registry (推荐)

#### 2. 拉取最新镜像
```bash
docker pull ghcr.io/uykb/backpack-mm-simple:latest
```

#### 3. 在生产环境运行
```bash
# 使用生产环境配置
docker-compose -f docker-compose.prod.yml up -d
```

### 方式二：本地构建

#### 1. 环境配置
复制环境变量模板并配置您的 API 密钥：

```bash
cp .env.example .env
```

编辑 `.env` 文件，设置您的 Backpack API 密钥：

```env
BACKPACK_KEY=your_actual_api_key
BACKPACK_SECRET=your_actual_secret_key
CAPITAL=100  # 可选：100, 500, 1000
SYMBOL=SOL_USDC_PERP
```

#### 2. 构建 Docker 镜像
```bash
docker-compose build
```

#### 3. 启动服务
```bash
docker-compose up -d
```

#### 4. 查看日志
```bash
docker-compose logs -f backpack-market-maker
```

## 环境变量配置

### 必需配置
- `BACKPACK_KEY`: Backpack API 密钥
- `BACKPACK_SECRET`: Backpack API 密钥

### 可选配置
- `CAPITAL`: 资金量 (100, 500, 1000)，默认 100
- `SYMBOL`: 交易对，默认 SOL_USDC_PERP
- `EXCHANGE`: 交易所，默认 backpack
- `MARKET_TYPE`: 市场类型，默认 perp
- `BACKPACK_PROXY_WEBSOCKET`: WebSocket 代理
- `BASE_URL`: API 基础 URL
- `ENABLE_DATABASE`: 是否启用数据库

## 使用示例

### 使用 500 USDC 资金量运行

```bash
CAPITAL=500 docker-compose up -d
```

### 使用自定义交易对

```bash
CAPITAL=1000 SYMBOL=BTC_USDC_PERP docker-compose up -d
```

### 在容器平台使用 (claw.cloud 等)

#### 1. 配置环境变量
在容器平台设置以下环境变量：
- `BACKPACK_KEY`: 您的 API 密钥
- `BACKPACK_SECRET`: 您的 API 密钥
- `CAPITAL`: 资金量 (100, 500, 1000)
- `SYMBOL`: 交易对 (默认 SOL_USDC_PERP)

#### 2. 使用 ghcr.io 镜像
镜像地址：`ghcr.io/uykb/backpack-mm-simple:latest`

#### 3. 直接使用 Docker 运行

```bash
# 从 ghcr.io 拉取镜像运行
docker run -d \
  --name backpack-bot \
  -e BACKPACK_KEY=your_key \
  -e BACKPACK_SECRET=your_secret \
  -e CAPITAL=500 \
  ghcr.io/your-username/backpack-mm-simple:latest

# 或者使用本地构建的镜像
docker build -t backpack-market-maker .
docker run -d \
  --name backpack-bot \
  -e BACKPACK_KEY=your_key \
  -e BACKPACK_SECRET=your_secret \
  -e CAPITAL=500 \
  backpack-market-maker
```

## 参数说明

### 100 USDC 配置
- 策略: maker_hedge
- 价差: 0.01%
- 订单数量: 0.3
- 目标持仓: 1.5
- 最大持仓: 5
- 持仓阈值: 3
- 更新间隔: 8秒

### 500 USDC 配置
- 策略: standard
- 价差: 0.01%
- 订单数量: 0.2
- 最大订单数: 3
- 目标持仓: 10
- 最大持仓: 12
- 持仓阈值: 1
- 止损: -2
- 止盈: 8
- 更新间隔: 10秒

### 1000 USDC 配置
- 策略: standard
- 价差: 0.01%
- 订单数量: 0.5
- 最大订单数: 3
- 目标持仓: 3
- 最大持仓: 10
- 持仓阈值: 6
- 止损: -2
- 止盈: 8
- 更新间隔: 10秒

## GitHub Actions 自动构建

项目已配置自动构建工作流，当您：
- 推送到 main/master 分支
- 创建版本标签 (v*)
- 创建 Pull Request

会自动构建 Docker 镜像并推送到 GitHub Container Registry。

### 手动触发构建
在 GitHub 仓库的 Actions 标签页中，选择 "Build and Push Docker Image" 工作流，点击 "Run workflow"。

## 监控和管理

### 查看运行状态
```bash
# 开发环境
docker-compose ps

# 生产环境
docker-compose -f docker-compose.prod.yml ps
```

### 停止服务
```bash
# 开发环境
docker-compose down

# 生产环境
docker-compose -f docker-compose.prod.yml down
```

### 重启服务
```bash
# 开发环境
docker-compose restart

# 生产环境
docker-compose -f docker-compose.prod.yml restart
```

### 查看实时日志
```bash
# 开发环境
docker-compose logs -f --tail=100

# 生产环境
docker-compose -f docker-compose.prod.yml logs -f --tail=100
```

## 故障排除

### 常见问题

1. **API 密钥错误**
   - 检查 `.env` 文件中的 `BACKPACK_KEY` 和 `BACKPACK_SECRET` 是否正确
   - 在容器平台确保环境变量已正确设置

2. **容器启动失败**
   - 检查 Docker 是否运行: `docker info`
   - 查看详细错误日志: `docker-compose logs`
   - 检查镜像是否成功构建和推送: 在 GitHub Packages 页面查看

3. **网络连接问题**
   - 检查网络连接和代理设置
   - 验证 `BACKPACK_PROXY_WEBSOCKET` 配置

4. **GitHub Actions 构建失败**
   - 检查工作流权限设置
   - 确保仓库设置了正确的 secrets（如果需要）
   - 查看 Actions 日志了解具体错误

### 日志位置
- 容器日志: `docker-compose logs`
- 挂载日志: `./logs/` 目录（如果启用）
- GitHub Actions 日志: 仓库的 Actions 标签页

## 安全建议

1. 妥善保管 API 密钥，不要提交到版本控制
2. 使用强密码保护 `.env` 文件
3. 定期更新 Docker 镜像和安全补丁
4. 监控容器运行状态和资源使用情况
5. 使用 GitHub Secrets 存储敏感信息，避免在代码中硬编码

## GitHub Container Registry 配置

### 设置仓库权限
在仓库设置中启用 Packages 权限，确保 GitHub Actions 可以推送镜像。

### 拉取镜像认证
从私有仓库拉取镜像时需要认证：
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## 技术支持

如有问题，请查看项目主 README 或提交 Issue。
