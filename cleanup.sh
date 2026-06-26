#!/bin/bash
# ============================================================
#  清除腳本 — 移除本教學「安裝/下載」的東西（若有人不想玩了）
#  會移除：
#    ① 所有遊戲 wrapper（~/Applications/Sikarugir 內，含 Steam 登入與已下載的遊戲）
#    ② Sikarugir Creator（Homebrew cask）
#    ③ 下載的 Steam 安裝檔（~/Downloads/SteamSetup.exe）
#  不會動：Homebrew、Rosetta 2（系統共用工具；如真要移除見最後說明）
#  用法：curl -fsSL <url>/cleanup.sh -o cleanup.sh && bash cleanup.sh
# ============================================================

echo ""
echo "🧹 清除工具 — 將移除本教學安裝/下載的內容"
echo "----------------------------------------------"

WRAPPERS="$HOME/Applications/Sikarugir"
STEAMSETUP="$HOME/Downloads/SteamSetup.exe"

echo "將移除："
if [ -d "$WRAPPERS" ]; then
  sz=$(du -sh "$WRAPPERS" 2>/dev/null | cut -f1)
  echo "  ① 遊戲 wrapper：$WRAPPERS （約 ${sz:-?}）"
  echo "     ⚠ 內含你的 Steam 登入與已下載的遊戲，刪掉要重新下載/登入！"
else
  echo "  ①（找不到 $WRAPPERS，略過）"
fi
echo "  ② Sikarugir Creator（Homebrew cask）"
if [ -f "$STEAMSETUP" ]; then echo "  ③ $STEAMSETUP"; else echo "  ③（找不到 SteamSetup.exe，略過）"; fi
echo "----------------------------------------------"
echo "不會移除：Homebrew、Rosetta 2（系統共用工具）。"
echo ""

printf "確定要全部移除嗎？輸入 yes 繼續："
if [ -e /dev/tty ]; then read -r ans < /dev/tty; else read -r ans; fi
if [ "$ans" != "yes" ]; then echo "已取消，沒有刪除任何東西。"; exit 0; fi

echo ""
# ① wrappers
if [ -d "$WRAPPERS" ]; then
  rm -rf "$WRAPPERS" && echo "✓ 已移除 wrapper 資料夾"
fi
# ② Sikarugir Creator（cask + tap）
if command -v brew >/dev/null 2>&1; then
  brew uninstall --cask sikarugir 2>/dev/null \
    || brew uninstall --cask sikarugir-app/sikarugir/sikarugir 2>/dev/null || true
  brew untap sikarugir-app/sikarugir 2>/dev/null || true
  echo "✓ 已移除 Sikarugir Creator（若先前有裝）"
else
  echo "（找不到 brew，略過 Sikarugir Creator）"
fi
rm -rf "/Applications/Sikarugir Creator.app" 2>/dev/null || true
rm -rf "$HOME/Applications/Sikarugir Creator.app" 2>/dev/null || true
# ③ SteamSetup.exe
if [ -f "$STEAMSETUP" ]; then rm -f "$STEAMSETUP" && echo "✓ 已移除 SteamSetup.exe"; fi

echo ""
echo "🎉 清除完成！"
echo ""
echo "（選用）若連 Homebrew / Rosetta 也要移除（會影響其他用到它們的程式，請自行斟酌）："
echo '  移除 Homebrew：/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"'
echo "  移除 Rosetta ：sudo rm -rf /Library/Apple/usr/share/rosetta（需管理員，通常建議保留）"
