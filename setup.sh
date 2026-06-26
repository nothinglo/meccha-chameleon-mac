#!/bin/bash
# ============================================================
#  在 Mac 上玩 MECCHA CHAMELEON — 環境一鍵安裝
#  自動處理：Rosetta 2 + Homebrew + Sikarugir Creator
#  適用：Apple Silicon (M 系列) Mac
#  這個腳本只裝「工具」，不會碰你的個人檔案；可重複執行。
# ============================================================
set -e

echo ""
echo "🦎 MECCHA CHAMELEON on Mac — 環境安裝開始"
echo "----------------------------------------------"

# 0) 必須是 Apple Silicon
if [ "$(uname -m)" != "arm64" ]; then
  echo "⚠️  這個方法需要 Apple Silicon（M 系列）Mac。你的是 Intel，無法使用。"
  exit 1
fi

# 1) Rosetta 2（x86 模擬，wine 需要）
if /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
  echo "✓ Rosetta 2 已安裝"
else
  echo "→ 安裝 Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license
fi

# 2) Homebrew（套件管理器）
if ! command -v brew >/dev/null 2>&1; then
  if [ -x /opt/homebrew/bin/brew ]; then
    # 已安裝但沒進 PATH
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "→ 安裝 Homebrew（過程會要你按 Return 並輸入開機密碼，正常現象）..."
    NONINTERACTIVE=0 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # 寫進 PATH，之後開終端機才找得到 brew
    {
      echo ''
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    } >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
echo "✓ Homebrew: $(brew --version | head -1)"

# 3) Sikarugir Creator（免費的 wine + 原生 Metal 包裝工具）
echo "→ 安裝 Sikarugir Creator..."
brew tap sikarugir-app/sikarugir 2>/dev/null || true
brew trust sikarugir-app/sikarugir 2>/dev/null || true
export HOMEBREW_CASK_OPTS="--no-quarantine"
brew install --cask sikarugir-app/sikarugir/sikarugir

echo ""
echo "🎉 工具安裝完成！接下來是 GUI 操作（無法腳本化）："
echo "----------------------------------------------"
echo "1. 開啟「Sikarugir Creator」（在 /Applications 或 啟動台）"
echo "2. 按 Download Template → 按 Change 選引擎【WS12WineSikarugir10.0】→ 按 Create 命名"
echo "3. 跳出 Configure 視窗後，勾選【DXMT (DirectX to Metal)】"
echo "4. 按 Install Software → 選 SteamSetup.exe 裝 Steam"
echo "5. Windows app 設成 Steam.exe → Test Run → 登入 → 裝 MECCHA CHAMELEON"
echo "6. 遊戲右鍵→內容→啟動選項貼："
echo '   "C:\Program Files (x86)\Steam\steamapps\common\MECCHA CHAMELEON\Chameleon\Binaries\Win64\PenguinHotel-Win64-Shipping.exe" %command%'
echo "7. 按 Play 開玩！(務必從 Steam 啟動)"
echo "----------------------------------------------"
echo "⚠️ 引擎一定選 wine 10、渲染一定勾 DXMT（不要 DXVK，會黑畫面）"
