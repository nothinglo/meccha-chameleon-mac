#!/bin/bash
# ============================================================
#  補中文字型 for Sikarugir wrapper
#  把 Windows 中文字型名對應到 macOS 內建繁中字型（wine 本來就讀得到 macOS 字型）。
#  會自動套用到 ~/Applications/Sikarugir 裡所有 wrapper。
#  ⚠️ 執行前請先「完全關閉」該遊戲 / Steam（否則設定會被覆蓋）。
# ============================================================
set -e

# 要加入 FontSubstitutes 的對應（明體類→儷宋、黑體類→儷中黑）
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

  if grep -q '"PMingLiU"="Apple LiSung Light"' "$REG"; then
    echo "✓ $name 已有中文字型設定，略過"
    continue
  fi

  orig_lines=$(wc -l < "$REG")
  # 在 FontSubstitutes 區段標頭後，把 SUBSFILE 內容逐行插入
  awk -v subsfile="$SUBSFILE" '
    { print }
    /^\[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\FontSubstitutes\]/ {
      while ((getline line < subsfile) > 0) print line
      close(subsfile)
    }
  ' "$REG" > "$REG.tmp"

  new_lines=$(wc -l < "$REG.tmp")
  # 安全檢查：新檔行數必須 >= 原檔，否則視為失敗、不覆蓋
  if [ "$new_lines" -ge "$orig_lines" ] && [ "$new_lines" -gt 100 ]; then
    cp "$REG" "$REG.fontbak"          # 備份
    mv "$REG.tmp" "$REG"
    echo "✓ $name 中文字型已補上（備份在 system.reg.fontbak）"
  else
    rm -f "$REG.tmp"
    echo "⚠️ $name 處理異常，未更動（原檔保持不變）"
  fi
done

if [ "$found" = 0 ]; then
  echo "⚠️ 在 ~/Applications/Sikarugir 找不到任何 wrapper，請先建立遊戲 wrapper 再執行。"
  exit 1
fi
echo "🎉 完成！把遊戲完全關閉再重開，中文就會正常顯示。"
