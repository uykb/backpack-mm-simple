#!/bin/sh

# 启动脚本 - 根据资金量选择对应的参数配置
echo "=== Backpack 做市机器人 Docker 启动脚本 ==="

# 设置默认值
CAPITAL=${CAPITAL:-100}
SYMBOL=${SYMBOL:-SOL_USDC_PERP}
EXCHANGE=${EXCHANGE:-backpack}
MARKET_TYPE=${MARKET_TYPE:-perp}

echo "资金量: $CAPITAL USDC"
echo "交易对: $SYMBOL"
echo "交易所: $EXCHANGE"
echo "市场类型: $MARKET_TYPE"

# 根据资金量选择参数配置
case $CAPITAL in
    100)
        echo "使用 100 USDC 资金配置"
        SPREAD="0.01"
        QUANTITY="0.3"
        STRATEGY="maker_hedge"
        TARGET_POSITION="1.5"
        MAX_POSITION="5"
        POSITION_THRESHOLD="3"
        DURATION="99999"
        INTERVAL="8"
        ;;
    500)
        echo "使用 500 USDC 资金配置"
        SPREAD="0.01"
        QUANTITY="0.2"
        MAX_ORDERS="3"
        TARGET_POSITION="10"
        MAX_POSITION="12"
        POSITION_THRESHOLD="1"
        INVENTORY_SKEW="0"
        STOP_LOSS="-2"
        TAKE_PROFIT="8"
        DURATION="99999"
        INTERVAL="10"
        ;;
    1000)
        echo "使用 1000 USDC 资金配置"
        SPREAD="0.01"
        QUANTITY="0.5"
        MAX_ORDERS="3"
        TARGET_POSITION="3"
        MAX_POSITION="10"
        POSITION_THRESHOLD="6"
        INVENTORY_SKEW="0"
        STOP_LOSS="-2"
        TAKE_PROFIT="8"
        DURATION="99999"
        INTERVAL="10"
        ;;
    spot)
        echo "直接運行 Maker-Taker 對沖現貨"
        EXCHANGE="backpack"
        SYMBOL="SOL_USDC"
        SPREAD="0.1"
        STRATEGY="maker_hedge"
        DURATION="3600"
        INTERVAL="30"
        MARKET_TYPE="spot"
        ;;
    futures)
        echo "直接運行 Maker-Taker 對沖永續"
        EXCHANGE="backpack"
        MARKET_TYPE="perp"
        SYMBOL="SOL_USDC_PERP"
        SPREAD="0.01"
        QUANTITY="0.1"
        STRATEGY="maker_hedge"
        TARGET_POSITION="0"
        MAX_POSITION="5"
        POSITION_THRESHOLD="2"
        DURATION="3600"
        INTERVAL="15"
        ;;
    *)
        echo "错误: 不支持的资金量 $CAPITAL"
        echo "支持的金额: 100, 500, 1000, spot, futures"
        exit 1
        ;;
esac

# 构建命令参数
CMD="python run.py --exchange $EXCHANGE --market-type $MARKET_TYPE --symbol $SYMBOL --spread $SPREAD"

# 添加通用参数
CMD="$CMD --duration $DURATION --interval $INTERVAL"

# 添加特定参数
case $CAPITAL in
    100)
        CMD="$CMD --quantity $QUANTITY --strategy $STRATEGY --target-position $TARGET_POSITION --max-position $MAX_POSITION --position-threshold $POSITION_THRESHOLD"
        ;;
    500|1000)
        CMD="$CMD --quantity $QUANTITY --max-orders $MAX_ORDERS --target-position $TARGET_POSITION --max-position $MAX_POSITION --position-threshold $POSITION_THRESHOLD --inventory-skew $INVENTORY_SKEW --stop-loss $STOP_LOSS --take-profit $TAKE_PROFIT"
        ;;
    spot)
        CMD="$CMD --strategy $STRATEGY"
        ;;
    futures)
        CMD="$CMD --quantity $QUANTITY --strategy $STRATEGY --target-position $TARGET_POSITION --max-position $MAX_POSITION --position-threshold $POSITION_THRESHOLD"
        ;;
esac

echo "启动命令: $CMD"
echo "=========================================="

# 执行命令
exec $CMD
