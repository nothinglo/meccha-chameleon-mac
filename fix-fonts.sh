#!/bin/bash
# ============================================================
#  補中文字型 for Sikarugir wrapper
#  把 Windows 中文字型名對應到 macOS 內建繁中字型（wine 本來就讀得到 macOS 字型）。
#  會自動套用到 ~/Applications/Sikarugir 裡所有 wrapper。
#  ⚠️ 執行前請先「完全關閉」該遊戲 / Steam（否則設定會被覆蓋）。
# ============================================================
set -e

# 新增的 FontSubstitutes 對應（明體類→儷宋、黑體類→儷中黑）
SUBSFILE="$(mktemp)"
cat > "$SUBSFILE" <<'EOF'
"MingLiU"="Apple LiSung Light"
"PMingLiU"="Apple LiSung Light"
"SimSun"="Apple LiSung Light"
"NSimSun"="Apple LiSung Light"
"Microsoft JhengHei"="Apple LiGothic Medium"
"Microsoft JhengHei UI"="Apple LiGothic Medium"
"Microsoft YaHei"="Apple LiGothic Medium"
"Microsoft YaHei UI"="Apple LiGothic Medium"
"SimHei"="Apple LiGothic Medium"
EOF
trap 'rm -f "$SUBSFILE"' EXIT

found=0
for app in "$HOME/Applications/Sikarugir/"*.app; do
  REG="$app/Contents/SharedSupport/prefix/system.reg"
  [ -f "$REG" ] || continue
  found=1
  name="$(basename "$app")"
  cp "$REG" "$REG.fontbak"   # 備份

  # (1) 把對話框/安裝精靈常用的字型別名直接指向 macOS 字型（解決 Steam 安裝畫面 □□）
  #     這些 key 預設就存在，所以用替換值的方式（idempotent）
  sed -i '' 's/"MS Shell Dlg"="[^"]*"/"MS Shell Dlg"="Apple LiGothic Medium"/' "$REG" 2>/dev/null || true
  sed -i '' 's/"MS Shell Dlg 2"="[^"]*"/"MS Shell Dlg 2"="Apple LiGothic Medium"/' "$REG" 2>/dev/null || true

  # (2) 加入中文字型對應（若還沒加過）
  if grep -q '"PMingLiU"="Apple LiSung Light"' "$REG"; then
    echo "✓ $name 中文字型對應已存在（已更新對話框字型）"
  else
    orig_lines=$(wc -l < "$REG")
    awk -v subsfile="$SUBSFILE" '
      { print }
      /^\[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontSubstitutes\]/ {
        while ((getline line < subsfile) > 0) print line
        close(subsfile)
      }
    ' "$REG" > "$REG.tmp"
    new_lines=$(wc -l < "$REG.tmp")
    if [ "$new_lines" -ge "$orig_lines" ] && [ "$new_lines" -gt 100 ]; then
      mv "$REG.tmp" "$REG"
      echo "✓ $name 中文字型已補上"
    else
      rm -f "$REG.tmp"
      echo "⚠️ $name 處理異常，已從備份保留原檔"
      cp "$REG.fontbak" "$REG"
    fi
  fi
done

if [ "$found" = 0 ]; then
  echo "⚠️ 在 ~/Applications/Sikarugir 找不到任何 wrapper，請先建立遊戲 wrapper 再執行。"
  exit 1
fi
echo "🎉 完成！把遊戲完全關閉再重開，中文就會正常顯示。"
