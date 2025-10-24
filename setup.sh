#!/bin/bash
# v1.0.1

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 預設語言清單
DEFAULT_LANGS="python,elixir,node"

# 印出訊息函式
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# 檢查指令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 解析參數
parse_arguments() {
    INTERACTIVE=false
    CUSTOM_LANGS=""
    CI_MODE=false
    DRY_RUN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --langs=*)
                CUSTOM_LANGS="${1#*=}"
                shift
                ;;
            --ci)
                CI_MODE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                error "未知參數: $1"
                echo "用法: $0 [--interactive] [--langs=python,node,rust] [--ci] [--dry-run]"
                exit 1
                ;;
        esac
    done
}

# 檢查並安裝 Homebrew
check_homebrew() {
    INSTALL_HOMEBREW=true
    info "檢查 Homebrew..."

    if command_exists brew; then
        success "Homebrew 已安裝"
        INSTALL_HOMEBREW=false
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    info "開始安裝 Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then

        # 設定 Homebrew 環境變數
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        success "Homebrew 安裝完成"
    else
        error "Homebrew 安裝失敗"
        echo ""
        echo "可能原因："
        echo "  1. 網路連線問題"
        echo "  2. 沒有 admin 權限"
        echo "  3. 磁碟空間不足"
        echo ""
        echo "請查看上方錯誤訊息，或訪問 https://brew.sh 手動安裝"
        echo ""
        read -p "按 Enter 鍵關閉..."
        exit 1
    fi
}

# 安裝基礎工具
install_tools() {
    local tools=("git" "mise" "ripgrep" "fzf")

    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    info "開始安裝開發工具..."

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            success "$tool 已安裝，跳過"
        else
            info "安裝 $tool..."
            if brew install "$tool"; then
                success "$tool 安裝完成"
            else
                warning "$tool 安裝失敗，繼續執行..."
            fi
        fi
    done
}

# 互動式選擇語言
select_languages_interactive() {
    echo "" >&2
    echo "請選擇要安裝的語言環境 (輸入數字組合，例如 134)" >&2
    echo -e "${YELLOW}直接按 Enter 使用預設: Python, Elixir, Node${NC}" >&2
    echo "" >&2
    echo "1) Python" >&2
    echo "2) Elixir (自動安裝對應 Erlang 版本)" >&2
    echo "3) Node" >&2
    echo "4) Rust" >&2
    echo "5) Ruby" >&2
    echo "" >&2

    read -p "你的選擇: " choice < /dev/tty

    # 如果直接按 Enter，使用預設
    if [[ -z "$choice" ]]; then
        echo "python,elixir,node"
        return
    fi

    # 解析數字並轉換為語言名稱
    local langs=()
    local seen=()

    for (( i=0; i<${#choice}; i++ )); do
        digit="${choice:$i:1}"

        # 檢查是否已處理過此數字
        if [[ " ${seen[@]} " =~ " ${digit} " ]]; then
            continue
        fi
        seen+=("$digit")

        case $digit in
            1) langs+=("python") ;;
            2) langs+=("elixir") ;;  # Elixir 需要 Erlang
            3) langs+=("node") ;;
            4) langs+=("rust") ;;
            5) langs+=("ruby") ;;
            *)
                echo "⚠ 忽略無效選項: $digit" >&2
                ;;
        esac
    done

    if [[ ${#langs[@]} -eq 0 ]]; then
        echo "⚠ 未選擇任何語言，使用預設配置" >&2
        echo "python,elixir,node"
    else
        echo "${langs[@]}" | tr ' ' ','
    fi
}

# 選擇要安裝的語言
select_languages() {
    if [[ "$INTERACTIVE" == true ]]; then
        SELECTED_LANGS=$(select_languages_interactive)
    elif [[ -n "$CUSTOM_LANGS" ]]; then
        SELECTED_LANGS="$CUSTOM_LANGS"
    else
        SELECTED_LANGS="$DEFAULT_LANGS"
    fi

    # 擴展 elixir 為 erlang,elixir
    SELECTED_LANGS=$(expand_elixir_to_erlang "$SELECTED_LANGS")

    info "將安裝以下語言環境: $SELECTED_LANGS"
}

# 擴展 elixir 為 erlang,elixir
expand_elixir_to_erlang() {
    local langs="$1"
    local result=""

    IFS=',' read -ra LANG_ARRAY <<< "$langs"
    local added_erlang=false

    for lang in "${LANG_ARRAY[@]}"; do
        lang=$(echo "$lang" | xargs)  # trim whitespace

        # 如果是 elixir，先加入 erlang
        if [[ "$lang" == "elixir" ]]; then
            if [[ -n "$result" ]]; then
                result="$result,erlang,elixir"
            else
                result="erlang,elixir"
            fi
            added_erlang=true
        else
            if [[ -n "$result" ]]; then
                result="$result,$lang"
            else
                result="$lang"
            fi
        fi
    done

    echo "$result"
}

dry_info() {
  echo ""
  echo "=========================================="
  info "📋 Dry run 摘要"
  echo "=========================================="
  echo ""
  echo "🍺 將安裝 Homebrew: $([ "$INSTALL_HOMEBREW" = true ] && echo "✅" || echo "❌")"
  echo ""
  echo "📦 將安裝的語言環境:"
  IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
  for lang in "${LANGS[@]}"; do
      echo "  - $lang"
  done
  echo ""
  echo "⚙️ config.toml 預覽:"
  echo "  位置: ~/.config/mise/config.toml"
  echo "  內容:"
  echo "    [tools]"
  for lang in "${LANGS[@]}"; do
      lang=$(echo "$lang" | xargs)
      echo "    $lang = \"latest\""
  done
  echo ""
  info "🏎️ Dry run 完成，未進行實際安裝"
}

# 產生 mise 設定檔
generate_mise_config() {
    local config_dir="$HOME/.config/mise"
    local config_file="$config_dir/config.toml"

    info "產生 mise 設定檔..."

    # 建立目錄
    mkdir -p "$config_dir"

    # 備份現有設定
    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        warning "發現現有設定檔，備份至: $backup_file"
        cp "$config_file" "$backup_file"
    fi

    # 寫入新設定
    cat > "$config_file" << EOF
# Generated by dandori
# $(date)

[tools]
EOF

    IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
    for lang in "${LANGS[@]}"; do
        lang=$(echo "$lang" | xargs) # trim whitespace
        echo "$lang = \"latest\"" >> "$config_file"
    done

    success "設定檔已建立: $config_file"
}

# 設定 mise activate
setup_mise_activate() {
    info "設定 mise shell 整合..."

    local shell_name=""
    local rc_file=""

    # 偵測 shell
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_name="zsh"
        rc_file="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_name="bash"
        rc_file="$HOME/.bashrc"
        # macOS 預設使用 .zprofile
        if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "$HOME/.zprofile" ]]; then
            rc_file="$HOME/.zprofile"
        fi
    else
        warning "無法偵測 shell 類型，請手動設定 mise activate"
        return
    fi

    local activate_cmd="eval \"\$(mise activate $shell_name)\""

    # 檢查是否已經設定
    if [[ -f "$rc_file" ]] && grep -q "mise activate" "$rc_file"; then
        success "mise activate 已設定於 $rc_file"
        return
    fi

    # CI 模式：自動寫入不詢問
    if [[ "$CI_MODE" == true ]]; then
        echo "" >> "$rc_file"
        echo "# mise - Generated by dandori" >> "$rc_file"
        echo "$activate_cmd" >> "$rc_file"
        success "已寫入 $rc_file (CI 模式)"
        eval "$activate_cmd"
        return
    fi

    echo ""
    info "即將加入以下內容到 $rc_file:"
    echo -e "${YELLOW}$activate_cmd${NC}"
    echo ""

    read -p "是否確認? (Y/n): " confirm
    confirm=${confirm:-Y}

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "" >> "$rc_file"
        echo "# mise - added by dandori" >> "$rc_file"
        echo "$activate_cmd" >> "$rc_file"
        success "已寫入 $rc_file"

        # 立即生效
        eval "$activate_cmd"
    else
        warning "跳過寫入，請手動執行: $activate_cmd"
    fi
}

# 執行 mise install
prompt_mise_install() {
    echo ""
    info "mise 設定完成"

    IFS=',' read -ra LANGS <<< "$SELECTED_LANGS"
    local has_elixir=false
    for lang in "${LANGS[@]}"; do
        if [[ "$lang" == *"elixir"* ]]; then
            has_elixir=true
            break
        fi
    done

    if [[ "$has_elixir" == true ]]; then
        warning "注意: Erlang/Elixir 編譯可能需要 20-40 分鐘"
    fi

    # CI 模式：自動執行不詢問
    if [[ "$CI_MODE" == true ]]; then
        info "開始安裝語言環境... (CI 模式)"
        echo ""

        if mise install; then
            success "所有語言環境安裝完成!"
        else
            error "mise install 執行失敗"
            echo ""
            echo "可能原因："
            echo "  1. 編譯依賴套件缺失"
            echo "  2. 磁碟空間不足"
            echo "  3. 網路連線問題"
            echo ""
            echo "除錯步驟："
            echo "  1. 執行: mise doctor"
            echo "  2. 手動安裝: mise install <language>"
            echo "  3. 查看詳細日誌: mise install -v"
            echo ""
            read -p "按 Enter 鍵關閉..."
            exit 1
        fi
        return
    fi

    echo ""
    read -p "是否立即執行 mise install? (Y/n): " install_now
    install_now=${install_now:-Y}

    if [[ "$install_now" =~ ^[Yy]$ ]]; then
        info "開始安裝語言環境..."
        echo ""

        if mise install; then
            success "所有語言環境安裝完成!"
        else
            error "mise install 執行過程中發生錯誤"
            echo ""
            echo "可能原因："
            echo "  1. 編譯依賴套件缺失"
            echo "  2. 磁碟空間不足"
            echo "  3. 網路連線問題"
            echo ""
            echo "除錯步驟："
            echo "  1. 執行: mise doctor"
            echo "  2. 手動安裝: mise install <language>"
            echo "  3. 查看詳細日誌: mise install -v"
            echo ""
            warning "你可以稍後手動執行: mise install"
            echo ""
            read -p "按 Enter 鍵繼續..."
        fi
    else
        info "已跳過安裝，稍後可執行: mise install"
    fi
}

# 主程式
main() {
    echo ""
    echo "=========================================="
    echo " # 🍽️ dandori (段取り) macOS 開發環境設定"
    echo "=========================================="
    echo ""

    parse_arguments "$@"

    if [[ "$DRY_RUN" == true ]]; then
        info "🔍 Dry Run - 只顯示將執行的動作"
        echo ""
    fi

    check_homebrew
    install_tools
    select_languages

    if [[ "$DRY_RUN" == true ]]; then
        dry_info
        exit 0
    fi

    generate_mise_config
    setup_mise_activate
    prompt_mise_install

    echo ""
    echo "=========================================="
    success "安裝完成!"
    echo "=========================================="
    echo ""
    info "下一步:"
    echo "  1. 重新啟動終端機或執行: source ~/.zshrc (或 ~/.bashrc)"
    echo "  2. 驗證安裝: mise list"
    echo "  3. 檢查版本: python --version, elixir --version 等"
    echo ""
}

# Check if we're source the file or execute it directly
# check by `return` work for bash and zsh
(return 0 2>/dev/null) && sourced=1 || sourced=0

if [ $sourced -eq 0 ]; then
    main "$@"
fi
