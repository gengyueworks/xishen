#!/usr/bin/env bash
#
# 喜神 · 八字暖读（xishen）—— 通用安装脚本
#
# 把本仓库（即 skill 文件夹）安装到任意 agent runtime 的 skills 目录。
# 适用于 macOS / Linux / Git Bash；Windows 原生 PowerShell 请用同目录下的 install.ps1。
#
# 用法概览：
#   ./install.sh                     # 自动检测并安装到所有已装的 runtime
#   ./install.sh --claude --codex    # 只装到 Claude 和 Codex
#   ./install.sh --target DIR        # 装到自定义目录
#   ./install.sh --link --claude     # 开发模式：用符号链接，改仓库即生效
#   ./install.sh --dry-run --all     # 只预览，不做改动
#
set -euo pipefail

# 仓库根目录（本脚本所在目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 配置 ----
NAME="xishen"      # 安装后的文件夹名（可用 --name 修改）
LINK_MODE=0        # 0=复制，1=符号链接
DRY_RUN=0          # 0=真装，1=只预览
ALL_MODE=0         # 1=显式要求 --all
TARGETS=()         # 要安装到的 skills 目录列表
TARGET_LABELS=()   # 每个目录对应的 runtime 名（用于显示）

# OpenCode 目录尊重 $XDG_CONFIG_HOME
OPENCODE_SKILLS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"

usage() {
  cat <<'EOF'
喜神 · 八字暖读（xishen）—— 通用安装脚本

用法：
  ./install.sh [选项]

选项：
  --all            安装到所有检测到的 runtime（不指定任何 runtime 时也是默认行为）
  --claude         安装到 ~/.claude/skills
  --opencode       安装到 ~/.config/opencode/skills（尊重 $XDG_CONFIG_HOME）
  --codex          安装到 ~/.codex/skills
  --gemini         安装到 ~/.gemini/skills
  --cursor         安装到 ~/.cursor/skills
  --workbuddy      安装到 ~/.workbuddy/skills
  --agents         安装到 ~/.agents/skills（Codex / Copilot / Gemini CLI 通用）
  --target DIR     安装到自定义目录（DIR 是 skills 目录，skill 文件夹放在它里面）
  --link           用符号链接代替复制（开发模式：改仓库里的文件立即生效）
  --dry-run        只预览将要安装的位置，不做任何改动
  --name NAME      安装后的文件夹名（默认：xishen）
  -h, --help       显示本帮助并退出

示例：
  ./install.sh                      # 自动检测并安装到所有已装的 runtime
  ./install.sh --claude --codex     # 只装到 Claude 和 Codex
  ./install.sh --target ~/my-skills --name xishen
  ./install.sh --link --claude      # 开发模式：符号链接到 Claude

检测规则（--all 或未指定任何 runtime 时）：
  命令行里能找到对应 CLI（claude / opencode / codex / gemini / cursor / workbuddy），
  或对应的配置目录已存在，就视为该 runtime 已安装。
EOF
}

die() {
  echo "错误：$*" >&2
  echo >&2
  usage >&2
  exit 1
}

# 把开头的 ~ 展开成 $HOME（--target 可能收到 ~/... 或 '~/...'）
expand_tilde() {
  local p="$1"
  if [[ "$p" == \~/* ]]; then
    p="${HOME}${p#\~}"
  elif [[ "$p" == \~ ]]; then
    p="$HOME"
  fi
  printf '%s' "$p"
}

# 往目标列表里加一个目录（去重）
# 注：bash 3.2 在 set -u 下展开空数组会报 unbound variable，故先判长度再展开
add_target() {
  local dir="$1" label="$2" t
  if [[ ${#TARGETS[@]} -gt 0 ]]; then
    for t in "${TARGETS[@]}"; do
      if [[ "$t" == "$dir" ]]; then
        return 0
      fi
    done
  fi
  TARGETS+=("$dir")
  TARGET_LABELS+=("$label")
}

# ---- runtime 检测：CLI 在 PATH 上，或对应目录已存在，即视为已安装 ----
detect_claude()    { command -v claude    >/dev/null 2>&1 || [[ -d "$HOME/.claude/skills" ]]; }
detect_opencode()  { command -v opencode  >/dev/null 2>&1 || [[ -d "$OPENCODE_SKILLS_DIR" ]]; }
detect_codex()     { command -v codex     >/dev/null 2>&1 || [[ -d "$HOME/.codex/skills" ]]; }
detect_gemini()    { command -v gemini    >/dev/null 2>&1 || [[ -d "$HOME/.gemini/skills" ]]; }
detect_cursor()    { command -v cursor    >/dev/null 2>&1 || [[ -d "$HOME/.cursor" ]]; }
detect_workbuddy() { command -v workbuddy >/dev/null 2>&1 || [[ -d "$HOME/.workbuddy" ]]; }
detect_agents()    { command -v codex >/dev/null 2>&1 || command -v gemini >/dev/null 2>&1 || command -v copilot >/dev/null 2>&1 || [[ -d "$HOME/.agents/skills" ]]; }

# ---- 安装到单个目标 ----
install_to() {
  local dir="$1" label="$2"
  local dest="$dir/$NAME"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "（试运行）将安装到：$dest（$label）"
    return 0
  fi

  mkdir -p "$dir"

  # 目标已存在 = 更新安装（重新跑一遍安装脚本即可升级，不做任何询问）
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "更新已有安装：$dest"
    rm -rf "$dest"
  fi

  if [[ $LINK_MODE -eq 1 ]]; then
    # 开发模式：符号链接，改仓库里的文件立即生效（不复制 .git）
    ln -s "$SCRIPT_DIR" "$dest"
    echo "✔ 已安装（符号链接）：$dest（$label）"
  else
    # 常规模式：复制一份，安装副本不带 .git
    mkdir -p "$dest"
    cp -R "$SCRIPT_DIR/." "$dest/"
    rm -rf "$dest/.git"
    echo "✔ 已安装：$dest（$label）"
  fi
  return 0
}

# ---- 入口检查 ----
if [[ ! -f "$SCRIPT_DIR/SKILL.md" ]]; then
  die "在 $SCRIPT_DIR 下找不到 SKILL.md，请确认是在 xishen 仓库目录内运行本脚本"
fi

# ---- 解析参数 ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)        ALL_MODE=1 ;;
    --claude)     add_target "$HOME/.claude/skills" "Claude" ;;
    --opencode)   add_target "$OPENCODE_SKILLS_DIR" "OpenCode" ;;
    --codex)      add_target "$HOME/.codex/skills" "Codex" ;;
    --gemini)     add_target "$HOME/.gemini/skills" "Gemini" ;;
    --cursor)     add_target "$HOME/.cursor/skills" "Cursor" ;;
    --workbuddy)  add_target "$HOME/.workbuddy/skills" "WorkBuddy" ;;
    --agents)     add_target "$HOME/.agents/skills" "Agents" ;;
    --target)
      shift
      if [[ $# -lt 1 ]]; then die "--target 需要一个目录参数"; fi
      add_target "$(expand_tilde "$1")" "自定义目录"
      ;;
    --name)
      shift
      if [[ $# -lt 1 ]]; then die "--name 需要一个名称参数"; fi
      NAME="$1"
      ;;
    --link)       LINK_MODE=1 ;;
    --dry-run)    DRY_RUN=1 ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "未知参数：$1" ;;
  esac
  shift
done

# ---- 组装目标列表 ----
# 显式 --all，或没指定任何 runtime / --target → 自动检测（等价于 --all）
if [[ $ALL_MODE -eq 1 || ${#TARGETS[@]} -eq 0 ]]; then
  detect_claude    && add_target "$HOME/.claude/skills" "Claude"      || true
  detect_opencode  && add_target "$OPENCODE_SKILLS_DIR" "OpenCode"    || true
  detect_codex     && add_target "$HOME/.codex/skills" "Codex"        || true
  detect_gemini    && add_target "$HOME/.gemini/skills" "Gemini"      || true
  detect_cursor    && add_target "$HOME/.cursor/skills" "Cursor"      || true
  detect_workbuddy && add_target "$HOME/.workbuddy/skills" "WorkBuddy" || true
  detect_agents    && add_target "$HOME/.agents/skills" "Agents"      || true
fi

# 一个都没检测到，也没给 --target → 友好提示并退出（不算错误）
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo
  echo "没有检测到任何 runtime，也没有指定 --target。"
  echo "支持安装到：Claude、OpenCode、Codex、Gemini、Cursor、WorkBuddy、Agents。"
  echo
  echo "示例："
  echo "  ./install.sh --claude --codex"
  echo "  ./install.sh --target /你的/skills目录"
  echo "Windows 用户请用同目录下的 install.ps1。"
  echo
  exit 0
fi

# ---- 执行安装 ----
for ((i = 0; i < ${#TARGETS[@]}; i++)); do
  install_to "${TARGETS[$i]}" "${TARGET_LABELS[$i]}"
done

# ---- 汇总 ----
echo
echo "喜神 · 八字暖读 安装完成。"
echo "位置："
for ((i = 0; i < ${#TARGETS[@]}; i++)); do
  echo "  - ${TARGETS[$i]}/$NAME"
done
echo
if [[ $DRY_RUN -eq 1 ]]; then
  echo "（试运行模式：以上只是预览，没有做任何改动。）"
  echo "正式安装后，在对话里说「算我八字：公历 1995 年 8 月 12 日 14 时 30 分，女」即可触发。"
else
  echo "在对话里说「算我八字：公历 1995 年 8 月 12 日 14 时 30 分，女」即可触发。"
fi
