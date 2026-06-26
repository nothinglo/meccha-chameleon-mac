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
echo "⏱  預計需要 10–15 分鐘（下載 Homebrew + Sikarugir 引擎）。"
echo "    請耐心等候、中途不要關閉終端機。"
echo "    過程只會在一開始問你一次開機密碼。"
echo "----------------------------------------------"

# 0) 必須是 Apple Silicon
if [ "$(uname -m)" != "arm64" ]; then
  echo "⚠️  這個方法需要 Apple Silicon（M 系列）Mac。你的是 Intel，無法使用。"
  exit 1
fi

# 0.5) 預先取得 sudo 授權（從控制終端機讀密碼，避免管線環境讀不到）
if [ -e /dev/tty ]; then
  echo "→ 需要管理員權限來安裝系統工具，請輸入開機密碼："
  sudo -v < /dev/tty || { echo "⚠️ 取得 sudo 失敗，請確認此帳號為管理員。"; exit 1; }
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
  echo "→ 安裝 Homebrew（這步最久，約 5–10 分鐘）..."
  # 關鍵：< /dev/tty 把控制終端機接給安裝器，讓它維持互動模式、能正常用 sudo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
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

# 4) 預先下載 Steam 安裝檔到 ~/Downloads（之後步驟 3「Choose Setup Executable」要用）
echo "→ 下載 Steam 安裝檔到 ~/Downloads ..."
if curl -fsSL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -o "$HOME/Downloads/SteamSetup.exe"; then
  echo "✓ 已下載：~/Downloads/SteamSetup.exe"
else
  echo "（Steam 下載失敗，請手動到 store.steampowered.com 下載 SteamSetup.exe 放到 ~/Downloads）"
fi

echo ""
echo "🎉 工具安裝完成！正在自動開啟 Sikarugir Creator..."
open -a "Sikarugir Creator" 2>/dev/null || open "/Applications/Sikarugir Creator.app" 2>/dev/null || \
  echo "（若沒自動開，請到 啟動台 或 /Applications 開啟「Sikarugir Creator」）"

# 開啟 Finder 到「wrapper 之後會出現、日後啟動遊戲」的資料夾
mkdir -p "$HOME/Applications/Sikarugir"
open "$HOME/Applications/Sikarugir" 2>/dev/null || true
echo "📂 已開啟 Finder 到「~/Applications/Sikarugir」"
echo "    你建立的遊戲（wrapper .app）之後會出現在這個資料夾，"
echo "    以後要玩就到這裡點兩下它即可。"

echo ""
echo "----------------------------------------------"
echo "接下來在 Sikarugir Creator 視窗操作（無法腳本化）："
echo "1. Download Template → Change 選引擎【WS12WineSikarugir10.0】→ Create → 命名（例如 MeccaChameleon）"
echo "   （按 Create 後建立 wrapper 約需 5 分鐘、畫面會轉圈圈，請耐心等）"
echo "2. 跳出 Configure 視窗 → 勾選【DXMT (DirectX to Metal)】"
echo "3. Install Software → 選【~/Downloads/SteamSetup.exe】→ 安裝視窗一路按「確定/下一步」(不用改任何設定)"
echo "   ⚠️ 安裝中要點【右下角/選單列的 wine 酒杯圖示】，Steam 安裝視窗才會跳出來"
echo "   裝完過幾分鐘 Steam 會自動打開（若問你選主程式就選 Steam.exe）"
echo "4. Steam 打開後 → 登入 → 安裝你的遊戲（例如 MECCHA CHAMELEON）"
echo "5. （重要）補中文字型，避免遊戲內中文變成方框，回終端機跑這行："
echo "   curl -fsSL https://gist.githubusercontent.com/nothinglo/45eea044c3bb8fc2b6ab972e696180ac/raw/fix-fonts.sh -o fix-fonts.sh && bash fix-fonts.sh"
echo "6. 遊戲右鍵→內容→啟動選項貼上（玩其他遊戲請換成該遊戲的對應路徑）："
echo '   "C:\Program Files (x86)\Steam\steamapps\common\MECCHA CHAMELEON\Chameleon\Binaries\Win64\PenguinHotel-Win64-Shipping.exe" %command%'
echo "7. 從 Steam 按 Play 開玩！"
echo "----------------------------------------------"
echo "⚠️  引擎一定選 Wine 10、渲染一定勾 DXMT（不要 DXVK，會黑畫面）"
