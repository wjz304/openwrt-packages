#!/bin/bash
# Copyright (C) 2019-2026 sirpdboy
# Fixed version - correct image URL handling

RESULT_FILE='/tmp/netspeedtest_result'
LOG_FILE='/tmp/netspeedtest.log'
LOCK_FILE='/var/run/netspeedtest.lock'
PID_FILE='/var/run/netspeedtest.pid'
TIMEOUT=120

# 默认设置
PREFERRED_VERSION="auto"
SELECTED_SERVER="auto"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 检查进程锁
check_running() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null)
        if kill -0 "$old_pid" 2>/dev/null; then
            log "Another speedtest is already running (PID: $old_pid)"
            echo "Testing" > "$RESULT_FILE"
            exit 1
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    exec 200>"$LOCK_FILE"
    if ! flock -n 200; then
        log "Another speedtest is already running (flock)"
        echo "Testing" > "$RESULT_FILE"
        exit 1
    fi
    
    echo $$ > "$PID_FILE"
}

# 清理函数
cleanup() {
    rm -f "$PID_FILE"
    flock -u 200 2>/dev/null
    exec 200>&-
}

trap cleanup EXIT INT TERM

# 检测可用的speedtest版本
detect_speedtest() {
    local preferred="$1"
    local available_versions=""
    
    # 检查Ookla官方版
    if [ -f '/usr/bin/ookla-speedtest' ] && [ -x '/usr/bin/ookla-speedtest' ]; then
        available_versions="ookla:/usr/bin/ookla-speedtest"
    fi
    
    # 检查Python版
    if [ -f '/usr/bin/speedtest' ] && [ -x '/usr/bin/speedtest' ]; then
        if [ -n "$available_versions" ]; then
            available_versions="$available_versions|python:/usr/bin/speedtest"
        else
            available_versions="python:/usr/bin/speedtest"
        fi
    fi
    
    # 如果没有找到任何版本
    if [ -z "$available_versions" ]; then
        log "No speedtest versions found"
        return 1
    fi
    
    # 如果指定了偏好版本
    if [ "$preferred" != "auto" ]; then
        IFS='|' read -ra versions <<< "$available_versions"
        for ver in "${versions[@]}"; do
            if [[ "$ver" == "$preferred:"* ]]; then
                echo "$ver"
                return 0
            fi
        done
    fi
    
    echo "$available_versions" | cut -d'|' -f1
    return 0
}

# 运行Ookla版测试
run_ookla_test() {
    local speedtest_bin=$1
    local server_id=$2
    
    local cmd="$speedtest_bin --accept-gdpr --accept-license --progress=no"
    [ -n "$server_id" ] && [ "$server_id" != "auto" ] && cmd="$cmd --server-id=$server_id"
    # 使用临时文件存储输出
    local tmp_output=$(mktemp)
    
    if command -v timeout >/dev/null 2>&1; then
        timeout $TIMEOUT $cmd > "$tmp_output" 2>&1
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log "Error: Test timed out"
            rm -f "$tmp_output"
            return 1
        fi
    else
        $cmd > "$tmp_output" 2>&1
    fi
    
    cat "$tmp_output"
    rm -f "$tmp_output"
    return 0
}

# 运行Python版测试
run_python_test() {
    local speedtest_bin=$1
    local server_id=$2
    
    local cmd="$speedtest_bin --share --simple"
    if [ -n "$server_id" ] && [ "$server_id" != "auto" ]; then
        cmd="$speedtest_bin --server $server_id --share --simple"
    fi
    
    
    local tmp_output=$(mktemp)
    
    if command -v timeout >/dev/null 2>&1; then
        timeout 90 $cmd > "$tmp_output" 2>&1
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log "Error: Python test timed out"
            
            # 尝试使用常用服务器
            timeout 90 $speedtest_bin --server 59016 --share --simple > "$tmp_output" 2>&1
            if [ $? -eq 124 ]; then
                log "Error: Second attempt also timed out"
                rm -f "$tmp_output"
                return 1
            fi
        fi
    else
        $cmd > "$tmp_output" 2>&1
    fi
    
    cat "$tmp_output"
    rm -f "$tmp_output"
    return 0
}

# 解析Python版结果
parse_python_result() {
    local result="$1"
    
    # 检查是否包含错误信息
    if echo "$result" | grep -q -i "error\|failed\|cannot\|timeout"; then
        return 1
    fi
    
    # 提取分享链接
    local share_url=$(echo "$result" | grep -o 'http://www.speedtest.net/result/[0-9]*\.png' | head -1)
    if [ -n "$share_url" ]; then
        echo "$share_url"
        return 0
    fi
    
    # 提取速度数据
    local download=$(echo "$result" | grep -i "download" | head -1)
    local upload=$(echo "$result" | grep -i "upload" | head -1)
    local latency=$(echo "$result" | grep -i "latency" | head -1)
    
    if [ -n "$download" ] && [ -n "$upload" ]; then
        {
            echo "$download"
            echo "$upload"
            [ -n "$latency" ] && echo "$latency"
        }
        return 0
    fi
    
    return 1
}

parse_ookla_result() {
    local result="$1"
    
    # 提取结果URL
    local result_url=$(echo "$result" | grep -i "result url" | grep -o 'https\?://[^ ]*' | head -1)
    
    if [ -n "$result_url" ]; then
        echo "$result_url.png"
        return 0
    fi
    local download=$(echo "$result" | grep -i "download" | grep -o "[0-9.]\+ [Mk]bits" | head -1)
    local upload=$(echo "$result" | grep -i "upload" | grep -o "[0-9.]\+ [Mk]bits" | head -1)
    local latency=$(echo "$result" | grep -i "latency" | grep -o "[0-9.]\+ ms" | head -1)
    
    if [ -n "$download" ] && [ -n "$upload" ]; then
        {
            echo "Download: $download"
            echo "Upload: $upload"
            [ -n "$latency" ] && echo "Latency: $latency"
        }
        return 0
    fi
    
    return 1
}

# 主测试函数
main_test() {
    log "=== Speedtest started (PID: $$) ==="
    
    # 检测可用的speedtest版本
    local version_info=$(detect_speedtest "$PREFERRED_VERSION")
    if [ -z "$version_info" ]; then
        log "Error: No speedtest version found"
        echo "Test failed" > "$RESULT_FILE"
        exit 1
    fi
    
    local version_type=${version_info%:*}
    local speedtest_bin=${version_info#*:}
    log "Using $version_type version: $speedtest_bin"
    TEST_SUCCESS=0
    
    # 运行测试
    case $version_type in
        ookla)
            RUNTEST=$(run_ookla_test "$speedtest_bin" "$SELECTED_SERVER")
            ;;
        python)
            RUNTEST=$(run_python_test "$speedtest_bin" "$SELECTED_SERVER")
            ;;
    esac
    
    echo "$RUNTEST" >> "$LOG_FILE"
    
    # 解析结果
    case $version_type in
        ookla) RESULT=$(parse_ookla_result "$RUNTEST") ;;
        python) RESULT=$(parse_python_result "$RUNTEST") ;;
    esac
    
    if [ -n "$RESULT" ]; then
        echo "$RESULT" > "$RESULT_FILE"
        TEST_SUCCESS=1
        log "Test successful"
    fi
    
    # 如果失败，尝试自动选择
    if [ $TEST_SUCCESS -eq 0 ] && [ "$SELECTED_SERVER" != "auto" ]; then
        log "Test failed with selected server, trying automatic server selection"
        SELECTED_SERVER="auto"
        
        case $version_type in
            ookla)
                RUNTEST=$(run_ookla_test "$speedtest_bin" "auto")
                ;;
            python)
                RUNTEST=$(run_python_test "$speedtest_bin" "auto")
                ;;
        esac
        
        echo "$RUNTEST" >> "$LOG_FILE"
        
        case $version_type in
            ookla) RESULT=$(parse_ookla_result "$RUNTEST") ;;
            python) RESULT=$(parse_python_result "$RUNTEST") ;;
        esac
        
        if [ -n "$RESULT" ]; then
            echo "$RESULT" > "$RESULT_FILE"
            log "Test successful with automatic server selection"
            TEST_SUCCESS=1
        fi
    fi
    
    # 最终检查
    if [ $TEST_SUCCESS -eq 0 ]; then
        echo "Test failed" > "$RESULT_FILE"
        log "All tests failed"
    fi
    
    log "=== Speedtest completed (PID: $$) ==="
    echo "" >> "$LOG_FILE"
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --version VERSION          Preferred version (ookla/python/auto)"
    echo "  --server SERVER_ID         Server ID to test with"
    echo "  --help                      Show this help message"
}

# 命令行参数处理
while [ $# -gt 0 ]; do
    case "$1" in
        --version)
            if [ -n "$2" ]; then
                PREFERRED_VERSION="$2"
                shift 2
            else
                echo "Error: --version requires an argument"
                exit 1
            fi
            ;;
        --server)
            if [ -n "$2" ]; then
                SELECTED_SERVER="$2"
                shift 2
            else
                echo "Error: --server requires an argument"
                exit 1
            fi
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# 运行测试
check_running
main_test
exit 0