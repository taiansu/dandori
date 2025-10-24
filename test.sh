#!/bin/bash

# 測試 setup.sh 中的特定函式
# 可以在 bash 或 zsh 中執行

# 載入 setup.sh 的所有函式（不執行 main）
source ./setup.sh

# 顏色定義（如果還沒定義）
CYAN='\033[0;36m'
NC='\033[0m'

echo "=========================================="
echo "  測試 dandori 函式"
echo "=========================================="
echo ""

# ============================================
# 測試 expand_elixir_to_erlang 函式
# ============================================
echo -e "${CYAN}測試 expand_elixir_to_erlang:${NC}"
echo ""

test_cases=(
    "python,elixir,node"
    "elixir"
    "erlang,elixir"
    "python,erlang,elixir,rust"
    "ruby,elixir,python"
    "python,node"
    "elixir,python,elixir"
)

for test in "${test_cases[@]}"; do
    result=$(expand_elixir_to_erlang "$test")
    echo "輸入: $test"
    echo "輸出: $result"
    echo ""
done

# ============================================
# 測試語言選擇邏輯
# ============================================
echo ""
echo -e "${CYAN}測試語言選擇邏輯:${NC}"
echo ""

echo "1. 預設值測試"
INTERACTIVE=false
CUSTOM_LANGS=""
DEFAULT_LANGS="python,elixir,node"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "2. 自訂語言測試"
CUSTOM_LANGS="python,rust"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "3. 只選 Elixir"
CUSTOM_LANGS="elixir"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

echo "4. 已包含 Erlang"
CUSTOM_LANGS="erlang,python"
select_languages
echo "結果: $SELECTED_LANGS"
echo ""

# ============================================
# 測試 config.toml 產生（預覽模式）
# ============================================
echo ""
echo -e "${CYAN}測試 config.toml 產生預覽:${NC}"
echo ""

CUSTOM_LANGS="python,elixir,rust"
select_languages

echo "[tools]"
IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
for lang in "${LANGS[@]}"; do
    lang=$(echo "$lang" | xargs)
    echo "$lang = \"latest\""
done
echo ""

echo "=========================================="
echo "  測試完成"
echo "=========================================="
