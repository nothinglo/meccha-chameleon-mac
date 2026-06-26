#!/bin/bash
# ============================================================
#  在 Mac 上玩 MECCHA CHAMELEON（及大多數 Windows Steam 遊戲）— 環境一鍵安裝
#  自動處理：Rosetta 2 + Homebrew + Sikarugir Creator
#  適用：Apple Silicon (M 系列) Mac
#  這個腳本只裝「工具」，不會碰你的個人檔案；可重複執行。
#  支援兩種跑法：
#    A) curl -fsSL <url> | bash
#    B) curl -fsSL <url> -o setup.sh && bash setup.sh
# ============================================================
set -e

echo ""
echo "🦎 環境安裝開始"
echo "----------------------------------------------"

# 0) 必須是 Apple Silicon
if [ "$(uname -m)" != "arm64" ]; then
  echo "⚠️  這個方法需要 Apple Silicon（M 系列）Mac。你的是 Intel，無法使用。"
  exit 1
fi

# 0.5) 預先取得 sudo 授權（從控制終端機讀密碼，避免管線環境讀不到）
#      這樣後面 Homebrew / Rosetta 的 sudo 都用快取、不會再卡。
if [ -e /dev/tty ]; then
  echo "→ 需要管理員權限來安裝系統工具，請輸入開機密碼："
  sudo -v < /dev/tty || { echo "⚠️ 取得 sudo 失敗，請確認此帳號為管理員。"; exit 1; }
  # 背景續期 sudo，避免安裝中途過期
  ( while true; do sudo -n true 2>/dev/null; sleep 50; done ) &
  SUDO_KEEPALIVE_PID=$!
  trap '[ -n "$SUDO_KEEPALIVE_PID" ] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
fi

# 1) Rosetta 2（x86 模擬，wine 需要）
if /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
  echo "✓ Rosetta 2 已安裝"
else
  echo "→ 安裝 Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license
fi

# 2) Homebrew（套件管理器）
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if ! command -v brew >/dev/null 2>&1; then
  echo "→ 安裝 Homebrew..."
  # 關鍵：< /dev/tty 把控制終端機接給安裝器，讓它維持互動模式、能正常用 sudo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
  # 寫進 PATH，之後開新終端機才找得到 brew
  {
    echo ''
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  } >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
echo "✓ Homebrew: $(brew --version | head -1)"

# 3) Sikarugir Creator（免費的 wine + 原生 Metal 包裝工具）
echo "→ 安裝 Sikarugir Creator..."
brew tap sikarugir-app/sikarugir 2>/dev/null || true
brew trust sikarugir-app/sikarugir 2>/dev/null || true
HOMEBREW_CASK_OPTS="--no-quarantine" brew install --cask sikarugir-app/sikarugir/sikarugir

echo ""
echo "🎉 工具安裝完成！接下來是 GUI 操作（無法腳本化）："
echo "----------------------------------------------"
echo "1. 開啟「Sikarugir Creator」（在 /Applications 或 啟動台）"
echo "2. Download Template → Change 選引擎【WS12WineSikarugir10.0】→ Create 命名"
echo "3. 跳出 Configure 視窗後，勾選【DXMT (DirectX to Metal)】"
echo "4. Install Software → 選 SteamSetup.exe 裝 Steam"
echo "5. Windows app 設成 Steam.exe → Test Run → 登入 → 裝遊戲"
echo "6. 遊戲右鍵→內容→啟動選項貼（路徑依遊戲不同）："
echo '   "C:\Program Files (x86)\Steam\steamapps\common\<遊戲>\...\Binaries\Win64\xxx-Shipping.exe" %command%'
echo "7. 從 Steam 按 Play 開玩！"
echo "----------------------------------------------"
echo "⚠️ 引擎一定選 Wine 10、渲染一定勾 DXMT（不要 DXVK，會黑畫面）"
